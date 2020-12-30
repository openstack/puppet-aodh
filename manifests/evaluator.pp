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
#    Defaults to $::os_workers.
#
#  [*coordination_url*]
#    (optional) The url to use for distributed group membership coordination.
#    Defaults to $::os_service_default.
#
#  [*evaluation_interval*]
#    (optional) Period of evaluation cycle
#    Defaults to $::os_service_default.
#
class aodh::evaluator (
  $manage_service      = true,
  $enabled             = true,
  $package_ensure      = 'present',
  $workers             = $::os_workers,
  $coordination_url    = $::os_service_default,
  $evaluation_interval = $::os_service_default,
) {

  include aodh::deps
  include aodh::params

  if !$coordination_url {
    warning('Use $::os_service_default for the coordination_url parameter. \
The current behavior will be changed in a future release')
    $coordination_url_real = $::os_service_default
  } else {
    $coordination_url_real = $coordination_url
  }

  if is_service_default($coordination_url_real) and !is_service_default($workers) and $workers > 1 {
    warning('coordination_url should be set to use multiple workers')
    $workers_real = $::os_service_default
  } else {
    $workers_real = $workers
  }

  aodh_config {
    'DEFAULT/evaluation_interval' : value => $evaluation_interval;
    'evaluator/workers'           : value => $workers_real;
    'coordination/backend_url'    : value => $coordination_url_real;
  }

  if !is_service_default($coordination_url_real) and ($coordination_url_real =~ /^redis/ ) {
    ensure_resource('package', 'python-redis', {
      name   => $::aodh::params::redis_package_name,
      tag    => 'openstack',
    })
  }

  ensure_resource( 'package', [$::aodh::params::evaluator_package_name],
    { ensure => $package_ensure,
      tag    => ['openstack', 'aodh-package'] }
  )

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
