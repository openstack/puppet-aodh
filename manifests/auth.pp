# DEPRECATED ! Use the aodh::service_credentails class instead
# The aodh::auth class helps configure auth settings
#
# == Parameters
#  [*auth_url*]
#    the keystone public endpoint
#    Optional. Defaults to undef.
#
#  [*auth_region*]
#    the keystone region of this node
#    Optional. Defaults to undef.
#
#  [*auth_user*]
#    the keystone user for aodh services
#    Optional. Defaults to undef.
#
#  [*auth_password*]
#    the keystone password for aodh services
#    Required.
#
#  [*auth_project_name*]
#    the keystone tenant name for aodh services
#    Optional. Defaults to undef.
#
#  [*project_domain_name*]
#    the keystone project domain name for aodh services
#    Optional. Defaults to undef.
#
#  [*user_domain_name*]
#    the keystone user domain name for aodh services
#    Optional. Defaults to undef.
#
#  [*auth_type*]
#    An authentication type to use with an OpenStack Identity server.
#    The value should contain auth plugin name.
#    Optional. Defaults to undef.
#
#  [*auth_cacert*]
#    Certificate chain for SSL validation.
#    Optional. Defaults to undef.
#
#  [*interface*]
#    Type of endpoint in Identity service catalog to use for
#    communication with OpenStack services.
#    Optional. Defaults to undef.
#
class aodh::auth (
  $auth_password,
  $auth_url            = undef,
  $auth_region         = undef,
  $auth_user           = undef,
  $auth_project_name   = undef,
  $project_domain_name = undef,
  $user_domain_name    = undef,
  $auth_type           = undef,
  $auth_cacert         = undef,
  $interface           = undef,
) {

  warning('The aodh::auth class has been deprecated. Use the aodh::service_credentials class')

  include aodh::service_credentials
}
