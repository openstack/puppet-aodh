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
# [*keystone_user*]
#   (optional) The name of the auth user
#   Defaults to aodh
#
# [*keystone_tenant*]
#   (optional) Tenant to authenticate with.
#   Defaults to 'services'.
#
# [*keystone_project_domain_name*]
#   (optional) Project domain name to authenticate with.
#   Defaults to 'default'.
#
# [*keystone_user_domain_name*]
#   (optional) User domain name to authenticate with.
#   Defaults to 'default'.
#
# [*keystone_auth_type*]
#   (optional) An authentication type to use with an OpenStack Identity server.
#   The value should contain auth plugin name.
#   Defaults to 'password'.
#
# [*keystone_password*]
#   Password to authenticate with.
#   Mandatory.
#
# [*keystone_auth_uri*]
#   (optional) Public Identity API endpoint.
#   Defaults to 'false'.
#
# [*keystone_auth_url*]
#   (optional) URL used by the plugin to know where to authenticate the service user.
#   Defaults to $::os_service_default.
#
# [*memcached_servers*]
#   (optinal) a list of memcached server(s) to use for caching. If left
#   undefined, tokens will instead be cached in-process.
#   Defaults to $::os_service_default.
#
# [*host*]
#   (optional) The aodh api bind address.
#   Defaults to 0.0.0.0
#
# [*port*]
#   (optional) The aodh api port.
#   Defaults to 8042
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
# DEPRECATED PARAMETERS
#
# [*keystone_identity_uri*]
#   (optional) DEPRECATED. Complete admin Identity API endpoint.
#   Defaults to: undef
#

class aodh::api (
  $manage_service               = true,
  $enabled                      = true,
  $package_ensure               = 'present',
  $keystone_user                = 'aodh',
  $keystone_tenant              = 'services',
  $keystone_password            = false,
  $keystone_auth_uri            = false,
  $keystone_auth_url            = $::os_service_default,
  $memcached_servers            = $::os_service_default,
  $keystone_project_domain_name = 'default',
  $keystone_user_domain_name    = 'default',
  $keystone_auth_type           = 'password',
  $host                         = '0.0.0.0',
  $port                         = '8042',
  $service_name                 = $::aodh::params::api_service_name,
  $sync_db                      = false,
  # DEPRECATED PARAMETERS
  $keystone_identity_uri        = undef,
) inherits aodh::params {

  if $keystone_identity_uri {
    warning('keystone_identity_uri is deprecated, and will be removed in a future release.')
    $keystone_auth_url_real = $keystone_identity_uri
  } else {
    $keystone_auth_url_real = $keystone_auth_url
  }

  include ::aodh::params
  include ::aodh::policy

  validate_string($keystone_password)

  Aodh_config<||> ~> Service[$service_name]
  Class['aodh::policy'] ~> Service[$service_name]

  Package['aodh-api'] -> Service[$service_name]
  Package['aodh-api'] -> Service['aodh-api']
  Package['aodh-api'] -> Class['aodh::policy']
  package { 'aodh-api':
    ensure => $package_ensure,
    name   => $::aodh::params::api_package_name,
    tag    => ['openstack', 'aodh-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  if $sync_db {
    include ::aodh::db::sync
  }

  if $service_name == $::aodh::params::api_service_name {
    service { 'aodh-api':
      ensure     => $service_ensure,
      name       => $::aodh::params::api_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      require    => Class['aodh::db'],
      tag        => 'aodh-service',
    }
  } elsif $service_name == 'httpd' {
    include ::apache::params
    service { 'aodh-api':
      ensure => 'stopped',
      name   => $::aodh::params::api_service_name,
      enable => false,
      tag    => 'aodh-service',
    }
    Class['aodh::db'] -> Service[$service_name]

    # we need to make sure aodh-api/eventlet is stopped before trying to start apache
    Service['aodh-api'] -> Service[$service_name]
  } else {
    fail('Invalid service_name. Either aodh/openstack-aodh-api for running as a standalone service, or httpd for being run by a httpd server')
  }

  aodh_config {
    'keystone_authtoken/auth_uri'            : value => $keystone_auth_uri;
    'keystone_authtoken/auth_url'            : value => $keystone_auth_url_real;
    'keystone_authtoken/project_name'        : value => $keystone_tenant;
    'keystone_authtoken/project_domain_name' : value => $keystone_project_domain_name;
    'keystone_authtoken/user_domain_name'    : value => $keystone_user_domain_name;
    'keystone_authtoken/auth_type'           : value => $keystone_auth_type;
    'keystone_authtoken/username'            : value => $keystone_user;
    'keystone_authtoken/password'            : value => $keystone_password, secret => true;
    'keystone_authtoken/memcached_servers'   : value => join(any2array($memcached_servers), ',');
    'api/host'                               : value => $host;
    'api/port'                               : value => $port;
  }

}
