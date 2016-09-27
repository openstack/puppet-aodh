require 'spec_helper'

describe 'aodh::db::mysql' do

  let :pre_condition do
    [
      'include mysql::server',
      'include aodh::db::sync'
    ]
  end

  let :params do
    {
      'password'      => 'fooboozoo_default_password',
    }
  end

  shared_examples_for 'aodh::db::mysql' do
    context 'with only required params' do
      it { is_expected.to contain_openstacklib__db__mysql('aodh').with(
        'user'          => 'aodh',
        'password_hash' => '*3DDF34A86854A312A8E2C65B506E21C91800D206',
        'dbname'        => 'aodh',
        'host'          => '127.0.0.1',
        'charset'       => 'utf8',
        :collate        => 'utf8_general_ci',
      )}
    end

    context "overriding allowed_hosts param to array" do
      let :params do
        {
          :password       => 'aodhpass',
          :allowed_hosts  => ['127.0.0.1','%']
        }
      end

    end
    context "overriding allowed_hosts param to string" do
      let :params do
        {
          :password       => 'aodhpass2',
          :allowed_hosts  => '192.168.1.1'
        }
      end

    end

    context "overriding allowed_hosts param equals to host param " do
      let :params do
        {
          :password       => 'aodhpass2',
          :allowed_hosts  => '127.0.0.1'
        }
      end

    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'aodh::db::mysql'
    end
  end
end
