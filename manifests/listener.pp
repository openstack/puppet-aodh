# Installs the aodh listener service
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
class aodh::listener (
  $manage_service = true,
  $enabled        = true,
  $package_ensure = 'present',
  $workers        = $::os_workers,
) {

  include aodh::deps
  include aodh::params

  aodh_config {
    'listener/workers': value => $workers
  }

  ensure_resource( 'package', [$::aodh::params::listener_package_name],
    { ensure => $package_ensure,
      tag    => ['openstack', 'aodh-package'] }
  )

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    service { 'aodh-listener':
      ensure     => $service_ensure,
      name       => $::aodh::params::listener_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      tag        => 'aodh-service',
    }
  }
}
