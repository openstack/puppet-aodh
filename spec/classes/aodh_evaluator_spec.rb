require 'spec_helper'

describe 'aodh::evaluator' do

  let :params do
    { :enabled => true }
  end

  shared_examples_for 'aodh-evaluator' do

    context 'with defaults' do
      it 'configures defaults' do
        is_expected.to contain_aodh_config('evaluator/workers').with_value(4)
        is_expected.to contain_aodh_config('evaluator/evaluation_interval').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_aodh_config('DEFAULT/event_alarm_cache_ttl').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_aodh_config('DEFAULT/additional_ingestion_lag').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with workers' do
      before do
        params.merge!({ :workers => 8 })
      end

      it 'configures workers' do
        is_expected.to contain_aodh_config('evaluator/workers').with_value(8)
      end
    end

    context 'with parameters defined' do
      before do
        params.merge!({
          :evaluation_interval      => 10,
          :event_alarm_cache_ttl    => 60,
          :additional_ingestion_lag => 20,
        })
      end
      it 'configures parameters accordingly' do
        is_expected.to contain_aodh_config('evaluator/evaluation_interval').with_value(10)
        is_expected.to contain_aodh_config('DEFAULT/event_alarm_cache_ttl').with_value(60)
        is_expected.to contain_aodh_config('DEFAULT/additional_ingestion_lag').with_value(20)
      end
    end

    context 'with deprecated coordination_url' do
      before do
        params.merge!({ :coordination_url => 'redis://localhost:6379' })
      end
      it 'configures coordination and workers' do
        is_expected.to contain_aodh_config('coordination/backend_url').with_value('redis://localhost:6379')
        is_expected.to contain_aodh_config('evaluator/workers').with_value(4)
      end
    end

    context 'when enabled' do
      it { is_expected.to contain_class('aodh::params') }

      it 'installs aodh-evaluator package' do
        is_expected.to contain_package('aodh-evaluator').with(
          :ensure => 'present',
          :name   => platform_params[:evaluator_package_name],
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
        is_expected.to contain_aodh_config('evaluator/evaluation_interval').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_aodh_config('evaluator/workers').with_value(4)
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
            :evaluator_service_name => 'aodh-evaluator' }
        when 'RedHat'
          { :evaluator_package_name => 'openstack-aodh-evaluator',
            :evaluator_service_name => 'openstack-aodh-evaluator' }
        end
      end
      it_configures 'aodh-evaluator'
    end
  end


end
