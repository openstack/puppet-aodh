require 'spec_helper_acceptance'

describe 'basic aodh' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::rabbitmq
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

      rabbitmq_user { 'aodh':
        admin    => true,
        password => 'an_even_bigger_secret',
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

      rabbitmq_user_permissions { 'aodh@/':
        configure_permission => '.*',
        write_permission     => '.*',
        read_permission      => '.*',
        provider             => 'rabbitmqctl',
        require              => Class['rabbitmq'],
      }

      class { '::aodh':
        debug                 => true,
        default_transport_url => 'rabbit://aodh:an_even_bigger_secret@127.0.0.1:5672',
        database_connection   => 'mysql://aodh:a_big_secret@127.0.0.1/aodh?charset=utf8',
      }
      class { '::aodh::db::mysql':
        password => 'a_big_secret',
      }
      class { '::aodh::keystone::auth':
        password => 'a_big_secret',
      }
      class { '::aodh::keystone::authtoken':
        password => 'a_big_secret',
      }
      class { '::aodh::api':
        enabled      => true,
        service_name => 'httpd',
        sync_db      => true,
      }
      include ::apache
      class { '::aodh::wsgi::apache':
        ssl => false,
      }
      class { '::aodh::auth':
        auth_url      => 'http://127.0.0.1:5000/v3',
        auth_password => 'a_big_secret',
      }
      class { '::aodh::client': }
      class { '::aodh::notifier': }
      class { '::aodh::listener': }
      class { '::aodh::evaluator': }
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
