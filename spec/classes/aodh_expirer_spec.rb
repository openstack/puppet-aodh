require 'spec_helper'

describe 'aodh::expirer' do
  shared_examples 'aodh::expirer' do
    let :params do
      {}
    end

    context 'with default' do
      it { is_expected.to contain_class('aodh::deps') }
      it { is_expected.to contain_class('aodh::params') }

      it 'installs aodh-expirer package' do
        is_expected.to contain_package(platform_params[:expirer_package_name]).with(
          :ensure => 'present',
          :tag    => ['openstack', 'aodh-package']
        )
      end

      it { is_expected.to contain_cron('aodh-expirer').with(
        :ensure      => 'present',
        :command     => 'aodh-expirer',
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'aodh',
        :minute      => 1,
        :hour        => 0,
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*',
        :require     => 'Anchor[aodh::install::end]'
      )}
    end

    context 'with overridden parameters' do
      before do
        params.merge!(
          :ensure   => 'absent',
          :maxdelay => 300
        )
      end

      it { is_expected.to contain_class('aodh::deps') }
      it { is_expected.to contain_class('aodh::params') }

      it 'installs aodh-expirer package' do
        is_expected.to contain_package(platform_params[:expirer_package_name]).with(
          :ensure => 'present',
          :tag    => ['openstack', 'aodh-package']
        )
      end

      it { is_expected.to contain_cron('aodh-expirer').with(
        :ensure      => 'absent',
        :command     => 'sleep `expr ${RANDOM} \\% 300`; aodh-expirer',
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'aodh',
        :minute      => 1,
        :hour        => 0,
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*',
        :require     => 'Anchor[aodh::install::end]'
      )}
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
        case facts[:osfamily]
        when 'Debian'
          { :expirer_package_name => 'aodh-expirer' }
        when 'RedHat'
          { :expirer_package_name => 'openstack-aodh-expirer' }
        end
      end
      it_behaves_like 'aodh::expirer'
    end
  end
end
