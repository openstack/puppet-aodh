#
# Unit tests for aodh::keystone::auth
#

require 'spec_helper'

describe 'aodh::keystone::auth' do
  shared_examples_for 'aodh::keystone::auth' do
    context 'with default class parameters' do
      let :params do
        { :password => 'aodh_password' }
      end

      it { is_expected.to contain_keystone__resource__service_identity('aodh').with(
        :configure_endpoint  => true,
        :configure_user      => true,
        :configure_user_role => true,
        :configure_service   => true,
        :service_name        => 'aodh',
        :service_type        => 'alarming',
        :service_description => 'OpenStack Alarming Service',
        :region              => 'RegionOne',
        :auth_name           => 'aodh',
        :password            => 'aodh_password',
        :email               => 'aodh@localhost',
        :tenant              => 'services',
        :roles               => ['admin', 'service'],
        :system_scope        => 'all',
        :system_roles        => [],
        :public_url          => 'http://127.0.0.1:8042',
        :internal_url        => 'http://127.0.0.1:8042',
        :admin_url           => 'http://127.0.0.1:8042',
      ) }
    end

    context 'when overriding parameters' do
      let :params do
        { :password            => 'aodh_password',
          :auth_name           => 'alt_aodh',
          :email               => 'alt_aodh@alt_localhost',
          :tenant              => 'alt_service',
          :roles               => ['admin'],
          :system_scope        => 'alt_all',
          :system_roles        => ['admin', 'member', 'reader'],
          :configure_endpoint  => false,
          :configure_user      => false,
          :configure_user_role => false,
          :configure_service   => false,
          :service_description => 'Alternative OpenStack Alarming Service',
          :service_name        => 'alt_service',
          :service_type        => 'alt_alarming',
          :region              => 'RegionTwo',
          :public_url          => 'https://10.10.10.10:80',
          :internal_url        => 'http://10.10.10.11:81',
          :admin_url           => 'http://10.10.10.12:81' }
      end

      it { is_expected.to contain_keystone__resource__service_identity('aodh').with(
        :configure_endpoint  => false,
        :configure_user      => false,
        :configure_user_role => false,
        :configure_service   => false,
        :service_name        => 'alt_service',
        :service_type        => 'alt_alarming',
        :service_description => 'Alternative OpenStack Alarming Service',
        :region              => 'RegionTwo',
        :auth_name           => 'alt_aodh',
        :password            => 'aodh_password',
        :email               => 'alt_aodh@alt_localhost',
        :tenant              => 'alt_service',
        :roles               => ['admin'],
        :system_scope        => 'alt_all',
        :system_roles        => ['admin', 'member', 'reader'],
        :public_url          => 'https://10.10.10.10:80',
        :internal_url        => 'http://10.10.10.11:81',
        :admin_url           => 'http://10.10.10.12:81',
      ) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'aodh::keystone::auth'
    end
  end
end
