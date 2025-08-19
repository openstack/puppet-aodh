# The aodh::quota class helps configure quota settings
#
# == Params
#
#  [*user_alarm_quota*]
#    (optional) Maximum number of alarms defined for a user.
#    Defaults to $facts['os_service_default'].
#
#  [*project_alarm_quota*]
#    (optional) Maximum number of alarms defined for a project.
#    Defaults to $facts['os_service_default'].
#
#  [*alarm_max_actions*]
#    (optional) Maximum count of actions for each state of an alarm.
#    Defaults to $facts['os_service_default'].
#
class aodh::quota (
  $user_alarm_quota    = $facts['os_service_default'],
  $project_alarm_quota = $facts['os_service_default'],
  $alarm_max_actions   = $facts['os_service_default'],
) {
  include aodh::deps
  include aodh::params

  aodh_config {
    'api/user_alarm_quota':    value => $user_alarm_quota;
    'api/project_alarm_quota': value => $project_alarm_quota;
    'api/alarm_max_actions':   value => $alarm_max_actions;
  }
}
