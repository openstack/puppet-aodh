# Installs the aodh evaluator service
#
# == Params
#  [*enabled*]
#    (optional) Should the service be enabled.
#    Defaults to true.
#
#  [*manage_service*]
#    (optional)  Whether the service should be managed by Puppet.
#    Defaults to true.
#
#  [*package_ensure*]
#    (optional) ensure state for package.
#    Defaults to 'present'
#
#  [*workers*]
#    (optional) Number of workers for evaluator service.
#    Defaults to $facts['os_workers'].
#
#  [*evaluation_interval*]
#    (optional) Period of evaluation cycle
#    Defaults to $facts['os_service_default'].
#
#  [*event_alarm_cache_ttl*]
#    (optional) TTL of event alarm caches, in seconds.
#    Defaults to $facts['os_service_default'].
#
#  [*additional_ingestion_lag*]
#    (optional) The number of seconds to extend the evaluation windows to
#    compensate the reporting/ingestion lag.
#    Defaults to $facts['os_service_default'].
#
class aodh::evaluator (
  Boolean $manage_service   = true,
  Boolean $enabled          = true,
  $package_ensure           = 'present',
  $workers                  = $facts['os_workers'],
  $evaluation_interval      = $facts['os_service_default'],
  $event_alarm_cache_ttl    = $facts['os_service_default'],
  $additional_ingestion_lag = $facts['os_service_default'],
) {

  include aodh::deps
  include aodh::params

  aodh_config {
    'evaluator/evaluation_interval':    value => $evaluation_interval;
    'DEFAULT/event_alarm_cache_ttl':    value => $event_alarm_cache_ttl;
    'DEFAULT/additional_ingestion_lag': value => $additional_ingestion_lag;
    'evaluator/workers':                value => $workers;
  }

  package { 'aodh-evaluator':
    ensure => $package_ensure,
    name   => $::aodh::params::evaluator_package_name,
    tag    => ['openstack', 'aodh-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    service { 'aodh-evaluator':
      ensure     => $service_ensure,
      name       => $::aodh::params::evaluator_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      tag        => ['aodh-service','aodh-db-sync-service']
    }
  }
}
