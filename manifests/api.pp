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
# [*auth_strategy*]
#   (optional) Type of authentication to be used.
#   Defaults to 'keystone'
#
# [*enable_proxy_headers_parsing*]
#   (Optional) Enable paste middleware to handle SSL requests through
#   HTTPProxyToWSGI middleware.
#   Defaults to $::os_service_default.
#
# = DEPRECATED PARAMETERS
#
# [*keystone_identity_uri*]
#   (optional) DEPRECATED. Use aodh::keystone::authtoken::auth_url instead.
#   Defaults to: undef
#
# [*keystone_user*]
#   (optional) DEPRECATED. Use aodh::keystone::authtoken::username instead.
#   Defaults to undef
#
# [*keystone_tenant*]
#   (optional) DEPRECATED. Use aodh::keystone::authtoken::project_name instead.
#   Defaults to undef
#
# [*keystone_project_domain_name*]
#   (optional) DEPRECATED. Use aodh::keystone::authtoken::project_domain_name instead.
#   Defaults to undef
#
# [*keystone_user_domain_name*]
#   (optional) DEPRECATED. Use aodh::keystone::authtoken::user_domain_name instead.
#   Defaults to undef
#
# [*keystone_auth_type*]
#   (optional) DEPRECATED. Use aodh::keystone::authtoken::auth_type instead.
#   Defaults to undef
#
# [*keystone_password*]
#   (optional) DEPRECATED. Use aodh::keystone::authtoken::password instead.
#   Defaults to undef
#
# [*keystone_auth_uri*]
#   (optional) DEPRECATED. Use aodh::keystone::authtoken::auth_uri instead.
#   Defaults to undef
#
# [*keystone_auth_url*]
#   (optional) DEPRECATED. Use aodh::keystone::authtoken::auth_url instead.
#   Defaults to undef
#
# [*memcached_servers*]
#   (optinal) DEPRECATED. Use aodh::keystone::authtoken::memcached_servers.
#   Defaults to undef
#
class aodh::api (
  $manage_service                 = true,
  $enabled                        = true,
  $package_ensure                 = 'present',
  $host                           = '0.0.0.0',
  $port                           = '8042',
  $service_name                   = $::aodh::params::api_service_name,
  $sync_db                        = false,
  $auth_strategy                  = 'keystone',
  $enable_proxy_headers_parsing   = $::os_service_default,
  # DEPRECATED PARAMETERS
  $keystone_identity_uri          = undef,
  $keystone_user                  = undef,
  $keystone_tenant                = undef,
  $keystone_password              = undef,
  $keystone_auth_uri              = undef,
  $keystone_auth_url              = undef,
  $keystone_project_domain_name   = undef,
  $keystone_user_domain_name      = undef,
  $keystone_auth_type             = undef,
  $memcached_servers              = undef,
) inherits aodh::params {

  if $keystone_identity_uri {
    warning('aodh::api::keystone_identity_uri is deprecated, user aodh::keystone::authtoken::auth_url instead.')
  }

  if $keystone_user {
    warning('aodh::api::keystone_user is deprecated, use aodh::keystone::authtoken::username instead')
  }

  if $keystone_tenant {
    warning('aodh::api::keystone_tenant is deprecated, use aodh::keystone::authtoken::project_name instead')
  }

  if $keystone_password {
    warning('aodh::api::keystone_password is deprecated, use aodh::keystone::authtoken::password instead')
  }

  if $keystone_auth_uri {
    warning('aodh::api::keystone_auth_uri is deprecated, use aodh::keystone::authtoken::auth_uri instead')
  }

  if $keystone_project_domain_name {
    warning('aodh::api::keystone_project_domain_name is deprecated, use aodh::keystone::authtoken::project_domain_name instead')
  }

  if $keystone_user_domain_name {
    warning('aodh::api::keystone_user_domain_name is deprecated, use aodh::keystone::authtoken::user_domain_name instead')
  }

  if $keystone_auth_type {
    warning('aodh::api::keystone_auth_type is deprecated, use aodh::keystone::authtoken::auth_type instead')
  }

  if $memcached_servers {
    warning('aodh::api::memcached_servers is deprecated, use aodh::keystone::authtoken::memcached_servers instead.')
  }

  include ::aodh::params
  include ::aodh::policy

  if $auth_strategy == 'keystone' {
    include ::aodh::keystone::authtoken
  }

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
    fail("Invalid service_name. Either aodh/openstack-aodh-api for running \
as a standalone service, or httpd for being run by a httpd server")
  }

  aodh_config {
    'api/host': value => $host;
    'api/port': value => $port;
  }

  oslo::middleware { 'aodh_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
  }
}
