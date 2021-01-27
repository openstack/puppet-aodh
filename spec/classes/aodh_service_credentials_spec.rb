require 'spec_helper'

describe 'aodh::service_credentials' do

  let :params do
    { :auth_url     => 'http://localhost:5000/v3',
      :region_name  => 'RegionOne',
      :username     => 'aodh',
      :password     => 'password',
      :project_name => 'services',
    }
  end

  shared_examples_for 'aodh::service_credentials' do

    it 'configures authentication' do
      is_expected.to contain_aodh_config('service_credentials/auth_url').with_value('http://localhost:5000/v3')
      is_expected.to contain_aodh_config('service_credentials/region_name').with_value('RegionOne')
      is_expected.to contain_aodh_config('service_credentials/project_domain_name').with_value('Default')
      is_expected.to_not contain_aodh_config('service_credentials/project_domain_id')
      is_expected.to contain_aodh_config('service_credentials/user_domain_name').with_value('Default')
      is_expected.to_not contain_aodh_config('service_credentials/user_domain_id')
      is_expected.to contain_aodh_config('service_credentials/auth_type').with_value('password')
      is_expected.to contain_aodh_config('service_credentials/username').with_value('aodh')
      is_expected.to contain_aodh_config('service_credentials/password').with_value('password').with_secret(true)
      is_expected.to contain_aodh_config('service_credentials/project_name').with_value('services')
      is_expected.to contain_aodh_config('service_credentials/cacert').with(:value => '<SERVICE DEFAULT>')
    end

    context 'when overriding parameters' do
      before do
        params.merge!(
          :cacert    => '/tmp/dummy.pem',
          :interface => 'internalURL',
        )
      end
      it { is_expected.to contain_aodh_config('service_credentials/cacert').with_value(params[:cacert]) }
      it { is_expected.to contain_aodh_config('service_credentials/interface').with_value(params[:interface]) }
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'aodh::service_credentials'
    end
  end

end
