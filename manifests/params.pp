# Parameters for puppet-aodh
#
class aodh::params {
  include openstacklib::defaults

  $pyver3 = $openstacklib::defaults::pyver3

  $client_package_name = 'python3-aodhclient'
  $user                = 'aodh'
  $group               = 'aodh'
  $expirer_command     = 'aodh-expirer'

  case $facts['os']['family'] {
    'RedHat': {
      $common_package_name     = 'openstack-aodh-common'
      $api_package_name        = 'openstack-aodh-api'
      $api_service_name        = undef
      $notifier_package_name   = 'openstack-aodh-notifier'
      $notifier_service_name   = 'openstack-aodh-notifier'
      $evaluator_package_name  = 'openstack-aodh-evaluator'
      $evaluator_service_name  = 'openstack-aodh-evaluator'
      $expirer_package_name    = 'openstack-aodh-expirer'
      $expirer_service_name    = 'openstack-aodh-expirer'
      $listener_package_name   = 'openstack-aodh-listener'
      $listener_service_name   = 'openstack-aodh-listener'
      $aodh_wsgi_script_dir    = '/var/www/cgi-bin/aodh'
      $aodh_wsgi_script_source = "/usr/lib/python${pyver3}/site-packages/aodh/wsgi/api.py"
    }
    'Debian': {
      $common_package_name     = 'aodh-common'
      $api_package_name        = 'aodh-api'
      case $facts['os']['name'] {
        'Ubuntu': {
          $api_service_name = undef
        }
        default: {
          $api_service_name = 'aodh-api'
        }
      }
      $notifier_package_name   = 'aodh-notifier'
      $notifier_service_name   = 'aodh-notifier'
      $evaluator_package_name  = 'aodh-evaluator'
      $evaluator_service_name  = 'aodh-evaluator'
      $expirer_package_name    = 'aodh-expirer'
      $expirer_service_name    = 'aodh-expirer'
      $listener_package_name   = 'aodh-listener'
      $listener_service_name   = 'aodh-listener'
      $aodh_wsgi_script_dir    = '/usr/lib/cgi-bin/aodh'
      $aodh_wsgi_script_source = '/usr/bin/aodh-api'
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }
}
