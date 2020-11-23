require 'spec_helper'

describe 'aodh::db::sync' do

  shared_examples_for 'aodh-dbsync' do

    it { is_expected.to contain_class('aodh::deps') }

    it 'runs aodh-db-sync' do
      is_expected.to contain_exec('aodh-db-sync').with(
        :command     => 'aodh-dbsync --config-file /etc/aodh/aodh.conf',
        :path        => '/usr/bin',
        :refreshonly => 'true',
        :user        => 'aodh',
        :try_sleep   => 5,
        :tries       => 10,
        :timeout     => 300,
        :logoutput   => 'on_failure',
        :subscribe   => ['Anchor[aodh::install::end]',
                         'Anchor[aodh::config::end]',
                         'Anchor[aodh::dbsync::begin]'],
        :notify      => 'Anchor[aodh::dbsync::end]',
        :tag         => 'openstack-db',
      )
    end

    describe "overriding db_sync_timeout" do
      let :params do
        {
          :db_sync_timeout => 750,
        }
      end

      it {
        is_expected.to contain_exec('aodh-db-sync').with(
          :command     => 'aodh-dbsync --config-file /etc/aodh/aodh.conf',
          :path        => '/usr/bin',
          :refreshonly => 'true',
          :user        => 'aodh',
          :try_sleep   => 5,
          :tries       => 10,
          :timeout     => 750,
          :logoutput   => 'on_failure',
          :subscribe   => ['Anchor[aodh::install::end]',
                           'Anchor[aodh::config::end]',
                           'Anchor[aodh::dbsync::begin]'],
          :notify      => 'Anchor[aodh::dbsync::end]',
          :tag         => 'openstack-db',
        )
        }
      end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :os_workers     => 8,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_configures 'aodh-dbsync'
    end
  end

end
