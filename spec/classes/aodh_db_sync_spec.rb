require 'spec_helper'

describe 'aodh::db::sync' do

  shared_examples_for 'aodh-dbsync' do

    it 'runs aodh-db-sync' do
      is_expected.to contain_exec('aodh-db-sync').with(
        :command     => 'aodh-dbsync --config-file /etc/aodh/aodh.conf',
        :path        => '/usr/bin',
        :refreshonly => 'true',
        :user        => 'aodh',
        :logoutput   => 'on_failure'
      )
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :processorcount => 8,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_configures 'aodh-dbsync'
    end
  end

end
