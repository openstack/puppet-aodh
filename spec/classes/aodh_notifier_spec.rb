require 'spec_helper'

describe 'aodh::notifier' do

  let :pre_condition do
    "class { '::aodh': }"
  end

  shared_examples_for 'aodh-notifier' do

    context 'with workers' do
      let :params do
        { :workers => 8 }
      end

      it 'configures workers' do
        is_expected.to contain_aodh_config('notifier/workers').with_value(8)
      end
    end

    context 'with batch parameters' do
      let :params do
        {
          :batch_size    => 100,
          :batch_timeout => 60,
        }
      end

      it 'configures batch options' do
        is_expected.to contain_aodh_config('notifier/batch_size').with_value(100)
        is_expected.to contain_aodh_config('notifier/batch_timeout').with_value(60)
      end
    end

    context 'when enabled' do
      it { is_expected.to contain_class('aodh::params') }

      it 'installs aodh-notifier package' do
        is_expected.to contain_package('aodh-notifier').with(
          :ensure => 'present',
          :name   => platform_params[:notifier_package_name],
          :tag    => ['openstack', 'aodh-package']
        )
      end

      it 'configures aodh-notifier service' do
        is_expected.to contain_service('aodh-notifier').with(
          :ensure     => 'running',
          :name       => platform_params[:notifier_service_name],
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => 'aodh-service',
        )
      end

      it 'sets default values' do
        is_expected.to contain_aodh_config('notifier/workers').with_value(4)
        is_expected.to contain_aodh_config('notifier/batch_size').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_aodh_config('notifier/batch_timeout').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'when disabled' do
      let :params do
        { :enabled => false }
      end

      # Catalog compilation does not crash for lack of aodh::db
      it { is_expected.to compile }
      it 'configures aodh-notifier service' do
        is_expected.to contain_service('aodh-notifier').with(
          :ensure     => 'stopped',
          :name       => platform_params[:notifier_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => 'aodh-service',
        )
      end
    end

    context 'when service management is disabled' do
      let :params do
        { :enabled        => false,
          :manage_service => false }
      end

      it 'should not configure aodh-notifier service' do
        is_expected.to_not contain_service('aodh-notifier')
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
          { :notifier_package_name => 'aodh-notifier',
            :notifier_service_name => 'aodh-notifier' }
        when 'RedHat'
          { :notifier_package_name => 'openstack-aodh-notifier',
            :notifier_service_name => 'openstack-aodh-notifier' }
        end
      end
      it_configures 'aodh-notifier'
    end
  end

end
