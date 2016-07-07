#
# Installs the aodh python library.
#
# == parameters
#  [*ensure*]
#    ensure state for pachage.
#
class aodh::client (
  $ensure = 'present',
  $package_name = $::os_service_default,
) {

  include ::aodh::params

  if $package_name != $::os_service_default {
    $client_package_name = $client_package_name
  } else {
    $client_package_name = $::aodh::params::client_package_name
  }

  package { 'python-aodhclient':
    ensure => $ensure,
    name   => $client_package_name,
    tag    => 'openstack',
  }

}

