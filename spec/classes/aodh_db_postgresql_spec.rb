require 'spec_helper'

describe 'aodh::db::postgresql' do

  let :req_params do
    { :password => 'aodhpass' }
  end

  let :pre_condition do
    'include postgresql::server'
  end

  shared_examples 'aodh::db::postgresql' do
    context 'with only required parameters' do
      let :params do
        req_params
      end

      it { is_expected.to contain_class('aodh::deps') }

      it { is_expected.to contain_openstacklib__db__postgresql('aodh').with(
        :user       => 'aodh',
        :password   => 'aodhpass',
        :dbname     => 'aodh',
        :encoding   => nil,
        :privileges => 'ALL',
      )}
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_configures 'aodh::db::postgresql'
    end
  end


end
