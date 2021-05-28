require 'spec_helper'

describe 'aodh::evaluator' do

  let :pre_condition do
    "class { '::aodh': }"
  end

  let :params do
    { :enabled => true }
  end

  shared_examples_for 'aodh-evaluator' do

    context 'with coordination' do
      before do
        params.merge!({ :coordination_url => 'redis://localhost:6379' })
      end

      it 'configures backend_url' do
        is_expected.to contain_aodh_config('coordination/backend_url').with_value('redis://localhost:6379')
      end

      it 'configures workers' do
        is_expected.to contain_aodh_config('evaluator/workers').with_value(4)
      end

      it 'installs python-redis package' do
        is_expected.to contain_package('python-redis').with(
          :name => platform_params[:redis_package_name],
          :tag  => 'openstack'
        )
      end
    end

    context 'with coordination and workers' do
      before do
        params.merge!({
          :coordination_url => 'redis://localhost:6379',
          :workers          => 8,
        })
      end

      it 'configures backend_url' do
        is_expected.to contain_aodh_config('coordination/backend_url').with_value('redis://localhost:6379')
      end

      it 'configures workers' do
        is_expected.to contain_aodh_config('evaluator/workers').with_value(8)
      end
    end

    context 'with evaluation interval' do
      before do
        params.merge!({ :evaluation_interval => '10' })
      end
      it 'configures interval' do
        is_expected.to contain_aodh_config('DEFAULT/evaluation_interval').with_value('10')
      end
    end

    context 'with workers' do
      before do
        params.merge!({ :workers => 8 })
      end
      it 'does not configure workers' do
        is_expected.to contain_aodh_config('evaluator/workers').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'when enabled' do
      it { is_expected.to contain_class('aodh::params') }

      it 'installs aodh-evaluator package' do
        is_expected.to contain_package(platform_params[:evaluator_package_name]).with(
          :ensure => 'present',
          :tag    => ['openstack', 'aodh-package']
        )
      end

      it 'configures aodh-evaluator service' do
        is_expected.to contain_service('aodh-evaluator').with(
          :ensure     => 'running',
          :name       => platform_params[:evaluator_service_name],
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => ['aodh-service','aodh-db-sync-service']
        )
      end

      it 'sets default values' do
        is_expected.to contain_aodh_config('DEFAULT/evaluation_interval').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_aodh_config('evaluator/workers').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_aodh_config('coordination/backend_url').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'when disabled' do
      let :params do
        { :enabled => false }
      end

      # Catalog compilation does not crash for lack of aodh::db
      it { is_expected.to compile }
      it 'configures aodh-evaluator service' do
        is_expected.to contain_service('aodh-evaluator').with(
          :ensure     => 'stopped',
          :name       => platform_params[:evaluator_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => ['aodh-service','aodh-db-sync-service']
        )
      end
    end

    context 'when service management is disabled' do
      let :params do
        { :enabled        => false,
          :manage_service => false }
      end

      it 'should not configure aodh-evaluator service' do
        is_expected.to_not contain_service('aodh-evaluator')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({ :os_workers => 4 }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :evaluator_package_name => 'aodh-evaluator',
            :evaluator_service_name => 'aodh-evaluator',
            :redis_package_name     => 'python3-redis' }
        when 'RedHat'
          { :evaluator_package_name => 'openstack-aodh-evaluator',
            :evaluator_service_name => 'openstack-aodh-evaluator',
            :redis_package_name     => 'python3-redis' }
        end
      end
      it_configures 'aodh-evaluator'
    end
  end


end
