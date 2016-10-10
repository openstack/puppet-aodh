require 'spec_helper'

describe 'aodh::api' do

  let :pre_condition do
    "class { 'aodh': }
     include ::aodh::db"
  end

  let :params do
    { :enabled           => true,
      :manage_service    => true,
      :keystone_password => 'aodh-passw0rd',
      :package_ensure    => 'latest',
      :port              => '8042',
      :host              => '0.0.0.0',
    }
  end

  shared_examples_for 'aodh-api' do

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
      is_expected.to contain_aodh_config('api/host').with_value( params[:host] )
      is_expected.to contain_aodh_config('api/port').with_value( params[:port] )
      is_expected.to contain_aodh_config('oslo_middleware/enable_proxy_headers_parsing').with_value('<SERVICE DEFAULT>')
    end

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
            :require    => 'Class[Aodh::Db]',
            :tag        => 'aodh-service',
          )
        end
      end
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

      it { is_expected.to contain_aodh_config('oslo_middleware/enable_proxy_headers_parsing').with_value(true) }
    end

    context 'with deprecated parameters' do
      before do
        params.merge!({
          :keystone_user                => 'dummy',
          :keystone_password            => 'mypassword',
          :keystone_tenant              => 'tenant',
          :keystone_auth_uri            => 'https://10.0.0.1:5000/deprecated',
          :keystone_identity_uri        => 'https://10.0.0.1:35357/deprecated',
          :keystone_auth_url            => 'https://10.0.0.1:35357/deprecated',
          :memcached_servers            => ['memcached01:11211','memcached02:11211'],
          :keystone_project_domain_name => 'domainX',
          :keystone_user_domain_name    => 'domainX',
          :keystone_auth_type           => 'auth',
        })
      end
      it 'configures keystone_authtoken middleware' do
        is_expected.to contain_aodh_config(
          'keystone_authtoken/auth_uri').with_value('https://10.0.0.1:5000/deprecated')
        is_expected.to contain_aodh_config(
          'keystone_authtoken/username').with_value(params[:keystone_user])
        is_expected.to contain_aodh_config(
          'keystone_authtoken/password').with_value(params[:keystone_password]).with_secret(true)
        is_expected.to contain_aodh_config(
          'keystone_authtoken/auth_url').with_value(params[:keystone_identity_uri])
        is_expected.to contain_aodh_config(
          'keystone_authtoken/project_name').with_value(params[:keystone_tenant])
        is_expected.to contain_aodh_config(
          'keystone_authtoken/user_domain_name').with_value(params[:keystone_user_domain_name])
        is_expected.to contain_aodh_config(
          'keystone_authtoken/project_domain_name').with_value(params[:keystone_project_domain_name])
        is_expected.to contain_aodh_config(
          'keystone_authtoken/auth_type').with_value(params[:keystone_auth_type])
        is_expected.to contain_aodh_config(
          'keystone_authtoken/memcached_servers').with_value('memcached01:11211,memcached02:11211')
      end
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it 'configures aodh-api service' do
        is_expected.to contain_service('aodh-api').with(
          :ensure     => nil,
          :name       => platform_params[:api_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => 'aodh-service',
        )
      end
    end

    context 'when running aodh-api in wsgi' do
      before do
        params.merge!({ :service_name   => 'httpd' })
      end

      let :pre_condition do
        "include ::apache
         include ::aodh::db
         class { 'aodh': }"
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

    context 'when service_name is not valid' do
      before do
        params.merge!({ :service_name   => 'foobar' })
      end

      let :pre_condition do
        "include ::apache
         include ::aodh::db
         class { 'aodh': }"
      end

      it_raises 'a Puppet::Error', /Invalid service_name/
    end

    context "with deprecated keystone options" do
      before do
        params.merge!({
          :keystone_user                => 'user',
          :keystone_password            => 'userpassword',
          :keystone_tenant              => 'tenant',
          :keystone_project_domain_name => 'domainx',
          :keystone_user_domain_name    => 'domainx',
          :keystone_auth_type           => 'password',
          :keystone_auth_uri            => 'https://foo.bar:5000',
          :keystone_auth_url            => 'https://foo.bar:35357/deprecated',
          :keystone_identity_uri        => 'https://foo.bar:35357/deprecated',
        })
      end
      it 'configures auth_uri but deprecates old auth settings' do
        is_expected.to contain_aodh_config('keystone_authtoken/auth_uri').with_value("https://foo.bar:5000");
        is_expected.to contain_aodh_config('keystone_authtoken/auth_url').with_value("https://foo.bar:35357/deprecated");
        is_expected.to contain_aodh_config('keystone_authtoken/username').with_value('user')
        is_expected.to contain_aodh_config('keystone_authtoken/password').with_value('userpassword')
        is_expected.to contain_aodh_config('keystone_authtoken/project_name').with_value('tenant')
        is_expected.to contain_aodh_config('keystone_authtoken/user_domain_name').with_value('domainx')
        is_expected.to contain_aodh_config('keystone_authtoken/project_domain_name').with_value('domainx')
        is_expected.to contain_aodh_config('keystone_authtoken/auth_type').with_value('password')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :fqdn           => 'some.host.tld',
          :processorcount => 2,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :api_package_name => 'aodh-api',
            :api_service_name => 'aodh-api' }
        when 'RedHat'
          { :api_package_name => 'openstack-aodh-api',
            :api_service_name => 'openstack-aodh-api' }
        end
      end
      it_configures 'aodh-api'
    end
  end

end
