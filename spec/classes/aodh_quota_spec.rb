require 'spec_helper'

describe 'aodh::quota' do

  shared_examples_for 'aodh::quota' do

    context 'with default parameters' do
      let :params do
        {}
      end

      it 'configures default values' do
        is_expected.to contain_aodh_config('api/user_alarm_quota').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_aodh_config('api/project_alarm_quota').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_aodh_config('api/alarm_max_actions').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'when specific parameters' do
      let :params do
        {
          :user_alarm_quota    => 10,
          :project_alarm_quota => 20,
          :alarm_max_actions   => 5,
        }
      end

      it 'configures specified values' do
        is_expected.to contain_aodh_config('api/user_alarm_quota').with_value(10)
        is_expected.to contain_aodh_config('api/project_alarm_quota').with_value(20)
        is_expected.to contain_aodh_config('api/alarm_max_actions').with_value(5)
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'aodh::quota'
    end
  end

end
