require 'spec_helper'

describe 'aodh::auth' do

  let :params do
    { :auth_url         => 'http://localhost:5000/v2.0',
      :auth_region      => 'RegionOne',
      :auth_user        => 'aodh',
      :auth_password    => 'password',
      :auth_tenant_name => 'services',
    }
  end

  shared_examples_for 'aodh-auth' do

    it 'configures authentication' do
      is_expected.to contain_aodh_config('service_credentials/auth_url').with_value('http://localhost:5000/v2.0')
      is_expected.to contain_aodh_config('service_credentials/region_name').with_value('RegionOne')
      is_expected.to contain_aodh_config('service_credentials/project_domain_id').with_value('default')
      is_expected.to contain_aodh_config('service_credentials/user_domain_id').with_value('default')
      is_expected.to contain_aodh_config('service_credentials/auth_type').with_value('password')
      is_expected.to contain_aodh_config('service_credentials/username').with_value('aodh')
      is_expected.to contain_aodh_config('service_credentials/password').with_value('password').with_secret(true)
      is_expected.to contain_aodh_config('service_credentials/project_name').with_value('services')
      is_expected.to contain_aodh_config('service_credentials/cacert').with(:value => '<SERVICE DEFAULT>')
    end

    context 'when overriding parameters' do
      before do
        params.merge!(
          :auth_cacert        => '/tmp/dummy.pem',
          :auth_endpoint_type => 'internalURL',
        )
      end
      it { is_expected.to contain_aodh_config('service_credentials/cacert').with_value(params[:auth_cacert]) }
      it { is_expected.to contain_aodh_config('service_credentials/endpoint_type').with_value(params[:auth_endpoint_type]) }
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'aodh-auth'
    end
  end

end
