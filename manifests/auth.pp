# The aodh::auth class helps configure auth settings
#
# == Parameters
#  [*auth_url*]
#    the keystone public endpoint
#    Optional. Defaults to 'http://localhost:5000/v3'
#
#  [*auth_region*]
#    the keystone region of this node
#    Optional. Defaults to 'RegionOne'
#
#  [*auth_user*]
#    the keystone user for aodh services
#    Optional. Defaults to 'aodh'
#
#  [*auth_password*]
#    the keystone password for aodh services
#    Required.
#
#  [*auth_tenant_name*]
#    the keystone tenant name for aodh services
#    Optional. Defaults to 'services'
#
#  [*project_domain_name*]
#    the keystone project domain name for aodh services
#    Optional. Defaults to 'Default'
#
#  [*user_domain_name*]
#    the keystone user domain name for aodh services
#    Optional. Defaults to 'Default'
#
#  [*auth_tenant_id*]
#    the keystone tenant id for aodh services.
#    Optional. Defaults to $::os_service_default.
#
#  [*auth_type*]
#    An authentication type to use with an OpenStack Identity server.
#    The value should contain auth plugin name.
#    Optional. Defaults to 'password'.
#
#  [*auth_cacert*]
#    Certificate chain for SSL validation.
#    Optional. Defaults to $::os_service_default
#
#  [*interface*]
#    Type of endpoint in Identity service catalog to use for
#    communication with OpenStack services.
#    Optional. Defaults to $::os_service_default.
#
# DEPRECATED PARAMETERS
#
#  [*project_domain_id*]
#    the keystone project domain id for aodh services
#    Optional. Defaults to undef
#
#  [*user_domain_id*]
#    the keystone user domain id for aodh services
#    Optional. Defaults to undef
#
class aodh::auth (
  $auth_password,
  $auth_url            = 'http://localhost:5000/v3',
  $auth_region         = 'RegionOne',
  $auth_user           = 'aodh',
  $auth_tenant_name    = 'services',
  $project_domain_name = 'Default',
  $user_domain_name    = 'Default',
  $auth_type           = 'password',
  $auth_tenant_id      = $::os_service_default,
  $auth_cacert         = $::os_service_default,
  $interface           = $::os_service_default,
  # DEPRECATED PARAMETERS
  $project_domain_id   = undef,
  $user_domain_id      = undef,
) {

  include aodh::deps

  aodh_config {
    'service_credentials/auth_url'          : value => $auth_url;
    'service_credentials/region_name'       : value => $auth_region;
    'service_credentials/username'          : value => $auth_user;
    'service_credentials/password'          : value => $auth_password, secret => true;
    'service_credentials/project_name'      : value => $auth_tenant_name;
    'service_credentials/cacert'            : value => $auth_cacert;
    'service_credentials/tenant_id'         : value => $auth_tenant_id;
    'service_credentials/interface'         : value => $interface;
    'service_credentials/auth_type'         : value => $auth_type;
  }

  if $project_domain_id != undef {
    warning('aodh::auth::project_domain_id is deprecated and will be removed \
in a future release. Use project_domain_name instead.')
    aodh_config{
      'service_credentials/project_domain_id' : value => $project_domain_id;
    }
  } else {
    aodh_config{
      'service_credentials/project_domain_name' : value => $project_domain_name;
    }
  }

  if $user_domain_id != undef {
    warning('aodh::auth::user_domain_id is deprecated and will be removed \
in a future release. Use user_domain_name instead.')
    aodh_config{
      'service_credentials/user_domain_id' : value => $user_domain_id;
    }
  } else {
    aodh_config{
      'service_credentials/user_domain_name' : value => $user_domain_name;
    }
  }

}
