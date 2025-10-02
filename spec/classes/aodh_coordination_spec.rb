require 'spec_helper'

describe 'aodh::coordination' do
  shared_examples 'aodh::coordination' do
    context 'with default parameters' do
      it {
        is_expected.to contain_oslo__coordination('aodh_config').with(
          :backend_url            => '<SERVICE DEFAULT>',
          :manage_backend_package => true,
          :package_ensure         => 'present',
        )
        is_expected.to contain_aodh_config('coordination/heartbeat_interval').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_aodh_config('coordination/retry_backoff').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_aodh_config('coordination/max_retry_interval').with_value('<SERVICE DEFAULT>')
      }
    end

    context 'with specified parameters' do
      let :params do
        {
          :backend_url            => 'etcd3+http://127.0.0.1:2379',
          :heartbeat_interval     => 1,
          :retry_backoff          => 1,
          :max_retry_interval     => 30,
          :manage_backend_package => false,
          :package_ensure         => 'latest',
        }
      end

      it {
        is_expected.to contain_oslo__coordination('aodh_config').with(
          :backend_url            => 'etcd3+http://127.0.0.1:2379',
          :manage_backend_package => false,
          :package_ensure         => 'latest',
        )
        is_expected.to contain_aodh_config('coordination/heartbeat_interval').with_value(1)
        is_expected.to contain_aodh_config('coordination/retry_backoff').with_value(1)
        is_expected.to contain_aodh_config('coordination/max_retry_interval').with_value(30)
      }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_behaves_like 'aodh::coordination'
    end
  end
end
