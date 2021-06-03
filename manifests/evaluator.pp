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
#  [*evaluation_interval*]
#    (optional) Period of evaluation cycle
#    Defaults to $::os_service_default.
#
# DEPRECATED PARAMETERS
#
#  [*coordination_url*]
#    (optional) The url to use for distributed group membership coordination.
#    Defaults to undef.
#
class aodh::evaluator (
  $manage_service      = true,
  $enabled             = true,
  $package_ensure      = 'present',
  $workers             = $::os_workers,
  $evaluation_interval = $::os_service_default,
  # DEPRECATED PARAMETERS
  $coordination_url    = undef,
) {

  include aodh::deps
  include aodh::params

  if $coordination_url != undef {
    warning('The coordination_url parameter is deprecated. Use the aodh::coordination class instead')
    include aodh::coordination
  }

  aodh_config {
    'DEFAULT/evaluation_interval' : value => $evaluation_interval;
    'evaluator/workers'           : value => $workers;
  }

  ensure_packages($::aodh::params::evaluator_package_name, {
    ensure => $package_ensure,
    tag    => ['openstack', 'aodh-package'],
  })

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
