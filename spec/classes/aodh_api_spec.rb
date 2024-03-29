require 'spec_helper'

describe 'aodh::api' do

  let :pre_condition do
    "include apache
     class { 'aodh': }
     include aodh::db
     class { 'aodh::keystone::authtoken':
       password => 'a_big_secret',
     }"
  end

  let :params do
    { :enabled           => true,
      :manage_service    => true,
      :package_ensure    => 'latest',
    }
  end

  shared_examples 'aodh-api' do

    it { is_expected.to contain_class('aodh::deps') }
    it { is_expected.to contain_class('aodh::params') }
    it { is_expected.to contain_class('aodh::policy') }

    it 'installs aodh-api package' do
      is_expected.to contain_package('aodh-api').with(
        :ensure => 'latest',
        :name   => platform_params[:api_package_name],
        :tag    => ['openstack', 'aodh-package'],
      )
    end

    it 'configures api' do
      is_expected.to contain_aodh_config('api/gnocchi_external_project_owner').with_value('services')
      is_expected.to contain_aodh_config('api/gnocchi_external_domain_name').with_value('Default')
      is_expected.to contain_aodh_config('api/paste_config').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_oslo__middleware('aodh_config').with(
        :enable_proxy_headers_parsing => '<SERVICE DEFAULT>',
        :max_request_body_size        => '<SERVICE DEFAULT>',
      )
    end

    context 'with sync_db set to true' do
      before do
        params.merge!(
          :sync_db => true)
      end
      it { is_expected.to contain_class('aodh::db::sync') }
    end

    context 'with enable_proxy_headers_parsing' do
      before do
        params.merge!({:enable_proxy_headers_parsing => true })
      end

      it { is_expected.to contain_oslo__middleware('aodh_config').with(
        :enable_proxy_headers_parsing => true,
      )}
    end

    context 'with max_request_body_size' do
      before do
        params.merge!({:max_request_body_size => '102400' })
      end

      it { is_expected.to contain_oslo__middleware('aodh_config').with(
        :max_request_body_size => '102400',
      )}
    end

    context 'with paste_config' do
      before do
        params.merge!({:paste_config => '/etc/aodh/api-paste.ini' })
      end

      it { is_expected.to contain_aodh_config('api/paste_config').with_value('/etc/aodh/api-paste.ini') }
    end

    context 'with gnocchi parameters' do
      before do
        params.merge!({
          :gnocchi_external_project_owner => 'gnocchi-project',
          :gnocchi_external_domain_name   => 'MyDomain'
        })
      end

      it 'configures gnocchi parameters' do
        is_expected.to contain_aodh_config('api/gnocchi_external_project_owner').with_value('gnocchi-project')
        is_expected.to contain_aodh_config('api/gnocchi_external_domain_name').with_value('MyDomain')
      end
    end

    context 'when service_name is not valid' do
      before do
        params.merge!({ :service_name   => 'foobar' })
      end

      let :pre_condition do
        "include apache
         include aodh::db
         class { 'aodh': }
         class { 'aodh::keystone::authtoken':
           password => 'a_big_secret',
         }"
      end

      it_raises 'a Puppet::Error', /Invalid service_name/
    end
  end


  shared_examples_for 'aodh-api without standalone service' do

    let :pre_condition do
      "include apache
       include aodh::db
       class { 'aodh': }
       class {'aodh::keystone::authtoken':
         password => 'password',
       }"
    end

    it { is_expected.to_not contain_service('aodh-api') }
  end


  shared_examples 'aodh-api with standalone service' do

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures aodh-api service' do
          is_expected.to contain_service('aodh-api').with(
            :ensure     => (params[:manage_service] && params[:enabled]) ? 'running' : 'stopped',
            :name       => platform_params[:api_service_name],
            :enable     => params[:enabled],
            :hasstatus  => true,
            :hasrestart => true,
            :tag        => 'aodh-service',
          )
        end
        it { is_expected.to contain_service('aodh-api').that_subscribes_to('Anchor[aodh::service::begin]')}
        it { is_expected.to contain_service('aodh-api').that_notifies('Anchor[aodh::service::end]')}
      end
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it 'should not configure aodh-api service' do
        is_expected.to_not contain_service('aodh-api')
      end
    end

    context 'when running aodh-api in wsgi' do
      before do
        params.merge!({ :service_name   => 'httpd' })
      end

      let :pre_condition do
        "include apache
         include aodh::db
         class { 'aodh': }
         class { 'aodh::keystone::authtoken':
           password => 'a_big_secret',
         }"
      end

      it 'configures aodh-api service with Apache' do
        is_expected.to contain_service('aodh-api').with(
          :ensure     => 'stopped',
          :name       => platform_params[:api_service_name],
          :enable     => false,
          :tag        => 'aodh-service',
        )
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          if facts[:os]['name'] == 'Ubuntu'
            { :api_package_name => 'aodh-api',
              :api_service_name => 'httpd' }
          else
            { :api_package_name => 'aodh-api',
              :api_service_name => 'aodh-api' }
          end
        when 'RedHat'
          { :api_package_name => 'openstack-aodh-api',
            :api_service_name => 'httpd' }
        end
      end

      if facts[:os]['family'] == 'Debian' and facts[:os]['name'] != 'Ubuntu'
        it_behaves_like 'aodh-api with standalone service'
      else
        it_behaves_like 'aodh-api without standalone service'
      end
      it_behaves_like 'aodh-api'
    end
  end

end
