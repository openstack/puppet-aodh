# The aodh::service_credentials class helps configure service_credentials
# settings
#
# == Parameters
#
#  [*password*]
#    the keystone password for aodh services
#    Required.
#
#  [*auth_url*]
#    the keystone public endpoint
#    Optional. Defaults to 'http://localhost:5000/v3'
#
#  [*region_name*]
#    the keystone region of this node
#    Optional. Defaults to 'RegionOne'
#
#  [*username*]
#    the keystone user for aodh services
#    Optional. Defaults to 'aodh'
#
#  [*project_name*]
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
#  [*auth_type*]
#    An authentication type to use with an OpenStack Identity server.
#    The value should contain auth plugin name.
#    Optional. Defaults to 'password'.
#
#  [*cacert*]
#    Certificate chain for SSL validation.
#    Optional. Defaults to $::os_service_default
#
#  [*interface*]
#    Type of endpoint in Identity service catalog to use for
#    communication with OpenStack services.
#    Optional. Defaults to $::os_service_default.
#
class aodh::service_credentials (
  $password,
  $auth_url            = 'http://localhost:5000/v3',
  $region_name         = 'RegionOne',
  $username            = 'aodh',
  $project_name        = 'services',
  $project_domain_name = 'Default',
  $user_domain_name    = 'Default',
  $auth_type           = 'password',
  $cacert              = $::os_service_default,
  $interface           = $::os_service_default,
) {

  include aodh::deps

  aodh_config {
    'service_credentials/auth_url'            : value => $auth_url;
    'service_credentials/region_name'         : value => $region_name;
    'service_credentials/username'            : value => $username;
    'service_credentials/password'            : value => $password, secret => true;
    'service_credentials/project_name'        : value => $project_name;
    'service_credentials/project_domain_name' : value => $project_domain_name;
    'service_credentials/user_domain_name'    : value => $user_domain_name;
    'service_credentials/cacert'              : value => $cacert;
    'service_credentials/interface'           : value => $interface;
    'service_credentials/auth_type'           : value => $auth_type;
  }
}
