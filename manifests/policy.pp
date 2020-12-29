# == Class: aodh::policy
#
# Configure the aodh policies
#
# === Parameters
#
# [*policies*]
#   (Optional) Set of policies to configure for aodh
#   Example :
#     {
#       'aodh-context_is_admin' => {
#         'key' => 'context_is_admin',
#         'value' => 'true'
#       },
#       'aodh-default' => {
#         'key' => 'default',
#         'value' => 'rule:admin_or_owner'
#       }
#     }
#   Defaults to empty hash.
#
# [*policy_path*]
#   (Optional) Path to the nova policy.yaml file
#   Defaults to /etc/aodh/policy.yaml
#
class aodh::policy (
  $policies    = {},
  $policy_path = '/etc/aodh/policy.yaml',
) {

  include aodh::deps
  include aodh::params

  validate_legacy(Hash, 'validate_hash', $policies)

  Openstacklib::Policy::Base {
    file_path   => $policy_path,
    file_user   => 'root',
    file_group  => $::aodh::params::group,
    file_format => 'yaml',
  }

  create_resources('openstacklib::policy::base', $policies)

  oslo::policy { 'aodh_config': policy_file => $policy_path }

}
