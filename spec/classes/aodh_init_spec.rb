require 'spec_helper'

describe 'aodh' do

  shared_examples 'aodh' do

    it { is_expected.to contain_class('aodh::deps') }
    it { is_expected.to contain_class('aodh::db') }

    context 'with default parameters' do
      let :params do
        { :purge_config => false  }
      end

      it 'installs packages' do
        is_expected.to contain_package('aodh').with(
          :name   => platform_params[:aodh_common_package],
          :ensure => 'present',
          :tag    => ['openstack', 'aodh-package']
        )
      end

      it 'configures rabbit' do
        is_expected.to contain_oslo__messaging__default('aodh_config').with(
          :executor_thread_pool_size => '<SERVICE DEFAULT>',
          :transport_url             => '<SERVICE DEFAULT>',
          :rpc_response_timeout      => '<SERVICE DEFAULT>',
          :control_exchange          => '<SERVICE DEFAULT>'
        )
        is_expected.to contain_oslo__messaging__rabbit('aodh_config').with(
          :rabbit_use_ssl                  => '<SERVICE DEFAULT>',
          :heartbeat_timeout_threshold     => '<SERVICE DEFAULT>',
          :heartbeat_rate                  => '<SERVICE DEFAULT>',
          :heartbeat_in_pthread            => nil,
          :rabbit_qos_prefetch_count       => '<SERVICE DEFAULT>',
          :kombu_reconnect_delay           => '<SERVICE DEFAULT>',
          :kombu_failover_strategy         => '<SERVICE DEFAULT>',
          :amqp_durable_queues             => '<SERVICE DEFAULT>',
          :amqp_auto_delete                => '<SERVICE DEFAULT>',
          :kombu_compression               => '<SERVICE DEFAULT>',
          :kombu_ssl_ca_certs              => '<SERVICE DEFAULT>',
          :kombu_ssl_certfile              => '<SERVICE DEFAULT>',
          :kombu_ssl_keyfile               => '<SERVICE DEFAULT>',
          :kombu_ssl_version               => '<SERVICE DEFAULT>',
          :rabbit_ha_queues                => '<SERVICE DEFAULT>',
          :rabbit_retry_interval           => '<SERVICE DEFAULT>',
          :rabbit_quorum_queue             => '<SERVICE DEFAULT>',
          :rabbit_transient_quorum_queue   => '<SERVICE DEFAULT>',
          :rabbit_transient_queues_ttl     => '<SERVICE DEFAULT>',
          :rabbit_quorum_delivery_limit    => '<SERVICE DEFAULT>',
          :rabbit_quorum_max_memory_length => '<SERVICE DEFAULT>',
          :rabbit_quorum_max_memory_bytes  => '<SERVICE DEFAULT>',
          :enable_cancel_on_failover       => '<SERVICE DEFAULT>',
          :use_queue_manager               => '<SERVICE DEFAULT>',
          :hostname                        => '<SERVICE DEFAULT>',
          :processname                     => '<SERVICE DEFAULT>',
          :rabbit_stream_fanout            => '<SERVICE DEFAULT>',
        )
        is_expected.to contain_oslo__messaging__notifications('aodh_config').with(
          :transport_url => '<SERVICE DEFAULT>',
          :driver        => '<SERVICE DEFAULT>',
          :topics        => '<SERVICE DEFAULT>',
          :retry         => '<SERVICE DEFAULT>',
        )
      end

      it 'configures other parameters' do
        is_expected.to contain_aodh_config('database/alarm_history_time_to_live').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_oslo__concurrency('aodh_config').with(
          :lock_path => '<SERVICE DEFAULT>'
        )
      end

      it 'passes purge to resource' do
        is_expected.to contain_resources('aodh_config').with({
          :purge => false
        })
      end
    end

    context 'with overridden parameters' do
      let :params do
        {
          :executor_thread_pool_size          => '128',
          :default_transport_url              => 'rabbit://rabbit_user:password@localhost:5673',
          :rpc_response_timeout               => '30',
          :control_exchange                   => 'aodh',
          :rabbit_use_ssl                     => true,
          :rabbit_heartbeat_timeout_threshold => '60',
          :rabbit_heartbeat_rate              => '10',
          :rabbit_heartbeat_in_pthread        => true,
          :rabbit_qos_prefetch_count          => 0,
          :kombu_reconnect_delay              => '5.0',
          :amqp_durable_queues                => true,
          :amqp_auto_delete                   => true,
          :kombu_compression                  => 'gzip',
          :kombu_ssl_ca_certs                 => '/etc/ca.cert',
          :kombu_ssl_certfile                 => '/etc/certfile',
          :kombu_ssl_keyfile                  => '/etc/key',
          :kombu_ssl_version                  => 'TLSv1',
          :rabbit_ha_queues                   => true,
          :rabbit_quorum_queue                => true,
          :rabbit_transient_quorum_queue      => true,
          :rabbit_transient_queues_ttl        => 60,
          :rabbit_quorum_delivery_limit       => 3,
          :rabbit_quorum_max_memory_length    => 5,
          :rabbit_quorum_max_memory_bytes     => 1073741824,
          :rabbit_enable_cancel_on_failover   => false,
          :rabbit_use_queue_manager           => false,
          :rabbit_hostname                    => 'node1.example.com',
          :rabbit_processname                 => 'procname',
          :rabbit_stream_fanout               => false,
          :notification_transport_url         => 'rabbit://rabbit_user:password@localhost:5673',
          :notification_driver                => 'ceilometer.compute.aodh_notifier',
          :notification_topics                => 'openstack',
          :notification_retry                 => 10,
          :package_ensure                     => '2012.1.1-15.el6',
          :alarm_history_time_to_live         => '604800',
          :lock_path                          => '/var/lock/aodh',
        }
      end

      it 'configures rabbit' do
        is_expected.to contain_oslo__messaging__default('aodh_config').with(
          :executor_thread_pool_size => '128',
          :transport_url             => 'rabbit://rabbit_user:password@localhost:5673',
          :rpc_response_timeout      => '30',
          :control_exchange          => 'aodh',
        )
        is_expected.to contain_oslo__messaging__rabbit('aodh_config').with(
          :rabbit_use_ssl                  => true,
          :heartbeat_timeout_threshold     => '60',
          :heartbeat_rate                  => '10',
          :heartbeat_in_pthread            => true,
          :rabbit_qos_prefetch_count       => 0,
          :kombu_reconnect_delay           => '5.0',
          :amqp_durable_queues             => true,
          :amqp_auto_delete                => true,
          :kombu_compression               => 'gzip',
          :kombu_ssl_ca_certs              => '/etc/ca.cert',
          :kombu_ssl_certfile              => '/etc/certfile',
          :kombu_ssl_keyfile               => '/etc/key',
          :kombu_ssl_version               => 'TLSv1',
          :rabbit_ha_queues                => true,
          :rabbit_quorum_queue             => true,
          :rabbit_transient_quorum_queue   => true,
          :rabbit_transient_queues_ttl     => 60,
          :rabbit_quorum_delivery_limit    => 3,
          :rabbit_quorum_max_memory_length => 5,
          :rabbit_quorum_max_memory_bytes  => 1073741824,
          :enable_cancel_on_failover       => false,
          :use_queue_manager               => false,
          :hostname                        => 'node1.example.com',
          :processname                     => 'procname',
          :rabbit_stream_fanout            => false,
        )
        is_expected.to contain_oslo__messaging__notifications('aodh_config').with(
          :transport_url => 'rabbit://rabbit_user:password@localhost:5673',
          :driver        => 'ceilometer.compute.aodh_notifier',
          :topics        => 'openstack',
          :retry         => 10,
        )
      end

      it 'configures other parameters' do
        is_expected.to contain_aodh_config('database/alarm_history_time_to_live').with_value('604800')
        is_expected.to contain_oslo__concurrency('aodh_config').with(
          :lock_path => '/var/lock/aodh'
        )
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

      let(:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { :aodh_common_package => 'aodh-common' }
        when 'RedHat'
          { :aodh_common_package => 'openstack-aodh-common' }
        end
      end
      it_behaves_like 'aodh'
    end
  end


end
