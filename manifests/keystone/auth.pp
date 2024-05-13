# == Class: aodh::keystone::auth
#
# Configures Aodh user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (Required) Password for aodh user.
#
# [*auth_name*]
#   (Optional) Username for aodh service.
#   Defaults to 'aodh'.
#
# [*email*]
#   (Optional) Email for aodh user.
#   Defaults to 'aodh@localhost'.
#
# [*tenant*]
#   (Optional) Tenant for aodh user.
#   Defaults to 'services'.
#
# [*roles*]
#   (Optional) List of roles assigned to aodh user.
#   Defaults to ['admin']
#
# [*system_scope*]
#   (Optional) Scope for system operations.
#   Defaults to 'all'
#
# [*system_roles*]
#   (Optional) List of system roles assigned to aodh user.
#   Defaults to []
#
# [*configure_endpoint*]
#   (Optional) Should aodh endpoint be configured?
#   Defaults to true.
#
# [*configure_user*]
#   (Optional) Should the service user be configured?
#   Defaults to true.
#
# [*configure_user_role*]
#   (Optional) Should the admin role be configured for the service user?
#   Defaults to true.
#
# [*service_type*]
#   (Optional) Type of service.
#   Defaults to 'alarming'.
#
# [*region*]
#   (Optional) Region for endpoint.
#   Defaults to 'RegionOne'.
#
# [*service_name*]
#   (Optional) Name of the service.
#   Defaults to 'aodh'.
#
# [*service_description*]
#   (Optional) Description of the service.
#   Default to 'OpenStack Alarming Service'
#
# [*public_url*]
#   (Optional) The endpoint's public url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8042'.
#
# [*admin_url*]
#   (Optional) The endpoint's admin url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8042'.
#
# [*internal_url*]
#   (Optional) The endpoint's internal url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8042'.
#
class aodh::keystone::auth (
  String[1] $password,
  String[1] $auth_name                    = 'aodh',
  String[1] $email                        = 'aodh@localhost',
  String[1] $tenant                       = 'services',
  Array[String[1]] $roles                 = ['admin'],
  String[1] $system_scope                 = 'all',
  Array[String[1]] $system_roles          = [],
  Boolean $configure_endpoint             = true,
  Boolean $configure_user                 = true,
  Boolean $configure_user_role            = true,
  String[1] $service_description          = 'OpenStack Alarming Service',
  String[1] $service_name                 = 'aodh',
  String[1] $service_type                 = 'alarming',
  String[1] $region                       = 'RegionOne',
  Keystone::PublicEndpointUrl $public_url = 'http://127.0.0.1:8042',
  Keystone::EndpointUrl $internal_url     = 'http://127.0.0.1:8042',
  Keystone::EndpointUrl $admin_url        = 'http://127.0.0.1:8042',
) {

  include aodh::deps

  Keystone::Resource::Service_identity['aodh'] -> Anchor['aodh::service::end']

  keystone::resource::service_identity { 'aodh':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    service_name        => $service_name,
    service_type        => $service_type,
    service_description => $service_description,
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    roles               => $roles,
    system_scope        => $system_scope,
    system_roles        => $system_roles,
    public_url          => $public_url,
    internal_url        => $internal_url,
    admin_url           => $admin_url,
  }

}
