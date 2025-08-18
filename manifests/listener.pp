# Installs the aodh listener service
#
# == Params
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to true.
#
# [*manage_service*]
#   (optional)  Whether the service should be managed by Puppet.
#   Defaults to true.
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*workers*]
#   (optional) Number of workers for evaluator service.
#   Defaults to $facts['os_workers'].
#
# [*event_alarm_topic*]
#   (optional) The topic that aodh uses for event alarm evaluation.
#   Defaults to $facts['os_service_default'].
#
# [*batch_size*]
#   (optional) Number of notification messages to wait before dispatching them.
#   Defaults to $facts['os_service_default'].
#
# [*batch_timeout*]
#   (optional) Number of seconds to wait before dispatching samples when
#   batch_size is not reached.
#   Defaults to $facts['os_service_default'].
#
class aodh::listener (
  Boolean $manage_service = true,
  Boolean $enabled        = true,
  $package_ensure         = 'present',
  $workers                = $facts['os_workers'],
  $event_alarm_topic      = $facts['os_service_default'],
  $batch_size             = $facts['os_service_default'],
  $batch_timeout          = $facts['os_service_default'],
) {

  include aodh::deps
  include aodh::params

  aodh_config {
    'listener/workers':           value => $workers;
    'listener/event_alarm_topic': value => $event_alarm_topic;
    'listener/batch_size':        value => $batch_size;
    'listener/batch_timeout':     value => $batch_timeout;
  }

  package { 'aodh-listener':
    ensure => $package_ensure,
    name   => $aodh::params::listener_package_name,
    tag    => ['openstack', 'aodh-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    service { 'aodh-listener':
      ensure     => $service_ensure,
      name       => $aodh::params::listener_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      tag        => 'aodh-service',
    }
  }
}
