# Installs & configure the aodh api service
#
# == Parameters
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to true.
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*service_name*]
#   (optional) Name of the service that will be providing the
#   server functionality of aodh-api.
#   If the value is 'httpd', this means aodh-api will be a web
#   service, and you must use another class to configure that
#   web service. For example, use class { 'aodh::wsgi::apache'...}
#   to make aodh-api be a web app using apache mod_wsgi.
#   Defaults to '$::aodh::params::api_service_name'
#
# [*sync_db*]
#   (optional) Run gnocchi-upgrade db sync on api nodes after installing the package.
#   Defaults to false
#
# [*auth_strategy*]
#   (optional) Type of authentication to be used.
#   Defaults to 'keystone'
#
# [*enable_proxy_headers_parsing*]
#   (Optional) Enable paste middleware to handle SSL requests through
#   HTTPProxyToWSGI middleware.
#   Defaults to $::os_service_default.
#
# [*max_request_body_size*]
#   (Optional) Set max request body size
#   Defaults to $::os_service_default.
#
# [*paste_config*]
#   (Optional) Configuration file for WSGI definition of API
#   Defaults to $::os_service_default.
#
# [*gnocchi_external_project_owner*]
#   (optional) Gnocchi external project owner (usually Ceilometer project name)
#   Defaults to 'services'
#
class aodh::api (
  $manage_service                 = true,
  $enabled                        = true,
  $package_ensure                 = 'present',
  $service_name                   = $::aodh::params::api_service_name,
  $sync_db                        = false,
  $auth_strategy                  = 'keystone',
  $enable_proxy_headers_parsing   = $::os_service_default,
  $max_request_body_size          = $::os_service_default,
  $paste_config                   = $::os_service_default,
  $gnocchi_external_project_owner = 'services',
) inherits aodh::params {


  include aodh::deps
  include aodh::params
  include aodh::policy

  if $auth_strategy == 'keystone' {
    include aodh::keystone::authtoken
  }

  package { 'aodh-api':
    ensure => $package_ensure,
    name   => $::aodh::params::api_package_name,
    tag    => ['openstack', 'aodh-package'],
  }

  if $sync_db {
    include aodh::db::sync
  }

  if $manage_service {
    $api_service_name = $::aodh::params::api_service_name
    if $api_service_name != 'httpd' and $service_name == $api_service_name {
      if $enabled {
        $service_ensure = 'running'
      } else {
        $service_ensure = 'stopped'
      }

      service { 'aodh-api':
        ensure     => $service_ensure,
        name       => $api_service_name,
        enable     => $enabled,
        hasstatus  => true,
        hasrestart => true,
        tag        => 'aodh-service',
      }
    } elsif $service_name == 'httpd' {
      include apache::params
      Service <| title == 'httpd' |> { tag +> 'aodh-service' }

      if $api_service_name != 'httpd' {
        service { 'aodh-api':
          ensure => 'stopped',
          name   => $api_service_name,
          enable => false,
          tag    => 'aodh-service',
        }
        # we need to make sure aodh-api/eventlet is stopped before trying to start apache
        Service['aodh-api'] -> Service[$service_name]
      }
    } else {
      fail('Invalid service_name.')
    }
  }

  aodh_config {
    'api/gnocchi_external_project_owner': value => $gnocchi_external_project_owner;
    'api/paste_config':                   value => $paste_config;
  }

  oslo::middleware { 'aodh_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
    max_request_body_size        => $max_request_body_size,
  }
}
