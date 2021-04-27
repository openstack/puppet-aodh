# Installs the aodh notifier service
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
#    (optional) Number of workers for notifier service.
#    Defaults to $::os_workers.
#
#  [*batch_size*]
#    (optional) Number of notification messages to wait before dispatching
#    them.
#    Defaults to $::os_service_default.
#
#  [*batch_timeout*]
#    (optional) Number of seconds to wait before dispatching samples when
#    batch_size is not reached.
#    Defaults to $::os_service_default
#
class aodh::notifier (
  $manage_service = true,
  $enabled        = true,
  $package_ensure = 'present',
  $workers        = $::os_workers,
  $batch_size     = $::os_service_default,
  $batch_timeout  = $::os_service_default,
) {

  include aodh::deps
  include aodh::params

  aodh_config {
    'notifier/workers':       value => $workers;
    'notifier/batch_size':    value => $batch_size;
    'notifier/batch_timeout': value => $batch_timeout
  }

  ensure_resource( 'package', [$::aodh::params::notifier_package_name],
    { ensure => $package_ensure,
      tag    => ['openstack', 'aodh-package'] }
  )

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    service { 'aodh-notifier':
      ensure     => $service_ensure,
      name       => $::aodh::params::notifier_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      tag        => 'aodh-service',
    }
  }
}
