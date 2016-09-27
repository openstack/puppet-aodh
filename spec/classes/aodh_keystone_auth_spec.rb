#
# Unit tests for aodh::keystone::auth
#

require 'spec_helper'

describe 'aodh::keystone::auth' do
  shared_examples_for 'aodh::keystone::auth' do
    context 'with default class parameters' do
      let :params do
        { :password => 'aodh_password',
          :tenant   => 'foobar' }
      end

      it { is_expected.to contain_keystone_user('aodh').with(
        :ensure   => 'present',
        :password => 'aodh_password',
      ) }

      it { is_expected.to contain_keystone_user_role('aodh@foobar').with(
        :ensure  => 'present',
        :roles   => ['admin']
      )}

      it { is_expected.to contain_keystone_service('aodh::alarming').with(
        :ensure      => 'present',
        :description => 'OpenStack Alarming Service'
      ) }

      it { is_expected.to contain_keystone_endpoint('RegionOne/aodh::alarming').with(
        :ensure       => 'present',
        :public_url   => 'http://127.0.0.1:8042',
        :admin_url    => 'http://127.0.0.1:8042',
        :internal_url => 'http://127.0.0.1:8042',
      ) }
    end

    context 'when overriding URL parameters' do
      let :params do
        { :password     => 'aodh_password',
          :public_url   => 'https://10.10.10.10:80',
          :internal_url => 'http://10.10.10.11:81',
          :admin_url    => 'http://10.10.10.12:81' }
      end

      it { is_expected.to contain_keystone_endpoint('RegionOne/aodh::alarming').with(
        :ensure       => 'present',
        :public_url   => 'https://10.10.10.10:80',
        :internal_url => 'http://10.10.10.11:81',
        :admin_url    => 'http://10.10.10.12:81'
      ) }
    end

    context 'when overriding auth name' do
      let :params do
        { :password => 'foo',
          :auth_name => 'aodhany' }
      end

      it { is_expected.to contain_keystone_user('aodhany') }
      it { is_expected.to contain_keystone_user_role('aodhany@services') }
      it { is_expected.to contain_keystone_service('aodh::alarming') }
      it { is_expected.to contain_keystone_endpoint('RegionOne/aodh::alarming') }
    end

    context 'when overriding service name' do
      let :params do
        { :service_name => 'aodh_service',
          :auth_name    => 'aodh',
          :password     => 'aodh_password' }
      end

      it { is_expected.to contain_keystone_user('aodh') }
      it { is_expected.to contain_keystone_user_role('aodh@services') }
      it { is_expected.to contain_keystone_service('aodh_service::alarming') }
      it { is_expected.to contain_keystone_endpoint('RegionOne/aodh_service::alarming') }
    end

    context 'when disabling user configuration' do

      let :params do
        {
          :password       => 'aodh_password',
          :configure_user => false
        }
      end

      it { is_expected.not_to contain_keystone_user('aodh') }
      it { is_expected.to contain_keystone_user_role('aodh@services') }
      it { is_expected.to contain_keystone_service('aodh::alarming').with(
        :ensure      => 'present',
        :description => 'OpenStack Alarming Service'
      ) }

    end

    context 'when disabling user and user role configuration' do

      let :params do
        {
          :password            => 'aodh_password',
          :configure_user      => false,
          :configure_user_role => false
        }
      end

      it { is_expected.not_to contain_keystone_user('aodh') }
      it { is_expected.not_to contain_keystone_user_role('aodh@services') }
      it { is_expected.to contain_keystone_service('aodh::alarming').with(
        :ensure      => 'present',
        :description => 'OpenStack Alarming Service'
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
