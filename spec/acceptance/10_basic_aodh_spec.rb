require 'spec_helper_acceptance'

describe 'basic aodh' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include openstack_integration
      include openstack_integration::repos
      include openstack_integration::apache
      include openstack_integration::rabbitmq
      include openstack_integration::mysql
      include openstack_integration::memcached
      include openstack_integration::redis
      include openstack_integration::keystone
      include openstack_integration::aodh
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(8042) do
      it { is_expected.to be_listening }
    end
  end

end
