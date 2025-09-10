# The aodh::service_credentials class helps configure service_credentials
# settings
#
# == Parameters
#
# [*password*]
#  (Required) the keystone password for aodh services
#
# [*auth_url*]
#  (Optional) the keystone public endpoint
#  Defaults to 'http://localhost:5000'
#
# [*region_name*]
#  (Optional) the keystone region of this node
#  Defaults to 'RegionOne'
#
# [*username*]
#  (Optional) the keystone user for aodh services
#  Defaults to 'aodh'
#
# [*project_name*]
#  (Optional) the keystone tenant name for aodh services
#  Defaults to 'services'
#
# [*project_domain_name*]
#  (Optional) the keystone project domain name for aodh services
#  Defaults to 'Default'
#
# [*user_domain_name*]
#  (Optional) the keystone user domain name for aodh services
#  Defaults to 'Default'
#
# [*system_scope*]
#  (Optional) Scope for system operations.
#  Defaults to $facts['os_service_default']
#
# [*auth_type*]
#  (Optional) An authentication type to use with an OpenStack Identity server.
#  The value should contain auth plugin name.
#  Defaults to 'password'.
#
# [*cacert*]
#  (Optional) Certificate chain for SSL validation.
#  Defaults to $facts['os_service_default']
#
# [*interface*]
#  (Optional) Type of endpoint in Identity service catalog to use for
#  communication with OpenStack services.
#  Optional. Defaults to $facts['os_service_default'].
#
class aodh::service_credentials (
  $password,
  $auth_url            = 'http://localhost:5000',
  $region_name         = 'RegionOne',
  $username            = 'aodh',
  $project_name        = 'services',
  $project_domain_name = 'Default',
  $user_domain_name    = 'Default',
  $system_scope        = $facts['os_service_default'],
  $auth_type           = 'password',
  $cacert              = $facts['os_service_default'],
  $interface           = $facts['os_service_default'],
) {
  include aodh::deps

  if is_service_default($system_scope) {
    $project_name_real = $project_name
    $project_domain_name_real = $project_domain_name
  } else {
    $project_name_real = $facts['os_service_default']
    $project_domain_name_real = $facts['os_service_default']
  }

  aodh_config {
    'service_credentials/auth_url'            : value => $auth_url;
    'service_credentials/region_name'         : value => $region_name;
    'service_credentials/username'            : value => $username;
    'service_credentials/password'            : value => $password, secret => true;
    'service_credentials/project_name'        : value => $project_name_real;
    'service_credentials/project_domain_name' : value => $project_domain_name_real;
    'service_credentials/system_scope'        : value => $system_scope;
    'service_credentials/user_domain_name'    : value => $user_domain_name;
    'service_credentials/cacert'              : value => $cacert;
    'service_credentials/interface'           : value => $interface;
    'service_credentials/auth_type'           : value => $auth_type;
  }
}
