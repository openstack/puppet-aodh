#
# == Class: aodh::expirer
#
# Setups Aodh Expirer service to enable TTL feature.
#
# === Parameters
#
#  [*ensure*]
#    (optional) The state of cron job.
#    Defaults to present.
#
#  [*package_ensure*]
#    (optional) ensure state for package.
#    Defaults to 'present'
#
#  [*minute*]
#    (optional) Defaults to '1'.
#
#  [*hour*]
#    (optional) Defaults to '0'.
#
#  [*monthday*]
#    (optional) Defaults to '*'.
#
#  [*month*]
#    (optional) Defaults to '*'.
#
#  [*weekday*]
#    (optional) Defaults to '*'.
#
#  [*maxdelay*]
#    (optional) In Seconds. Should be a positive integer.
#    Induces a random delay before running the cronjob to avoid running
#    all cron jobs at the same time on all hosts this job is configured.
#    Defaults to 0.
#
#  [*alarm_histories_delete_batch_size*]
#    (optional) Limit number of deleted alarm histories in single purge run
#    Defaults to $facts['os_service_default'].
#
class aodh::expirer (
  Enum['present', 'absent'] $ensure  = 'present',
  $package_ensure                    = 'present',
  $minute                            = 1,
  $hour                              = 0,
  $monthday                          = '*',
  $month                             = '*',
  $weekday                           = '*',
  $maxdelay                          = 0,
  $alarm_histories_delete_batch_size = $facts['os_service_default'],
) {

  include aodh::params
  include aodh::deps

  package { 'aodh-expirer':
    ensure => $package_ensure,
    name   => $::aodh::params::expirer_package_name,
    tag    => ['openstack', 'aodh-package']
  }

  if $maxdelay == 0 {
    $sleep = ''
  } else {
    $sleep = "sleep `expr \${RANDOM} \\% ${maxdelay}`; "
  }

  aodh_config { 'database/alarm_histories_delete_batch_size':
    value => $alarm_histories_delete_batch_size
  }

  cron { 'aodh-expirer':
    ensure      => $ensure,
    command     => "${sleep}${aodh::params::expirer_command}",
    environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
    user        => $::aodh::params::user,
    minute      => $minute,
    hour        => $hour,
    monthday    => $monthday,
    month       => $month,
    weekday     => $weekday,
    require     => Anchor['aodh::dbsync::end'],
  }

}
