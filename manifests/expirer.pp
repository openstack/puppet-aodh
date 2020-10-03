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
class aodh::expirer (
  $ensure         = 'present',
  $package_ensure = 'present',
  $minute         = 1,
  $hour           = 0,
  $monthday       = '*',
  $month          = '*',
  $weekday        = '*',
  $maxdelay       = 0,
) {

  include aodh::params
  include aodh::deps

  ensure_resource( 'package', [$::aodh::params::expirer_package_name],
    { ensure => $package_ensure,
      tag    => ['openstack', 'aodh-package'] }
  )

  if $maxdelay == 0 {
    $sleep = ''
  } else {
    $sleep = "sleep `expr \${RANDOM} \\% ${maxdelay}`; "
  }

  cron { 'aodh-expirer':
    ensure      => $ensure,
    command     => "${sleep}${aodh::params::expirer_command}",
    environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
    user        => 'aodh',
    minute      => $minute,
    hour        => $hour,
    monthday    => $monthday,
    month       => $month,
    weekday     => $weekday,
    require     => Anchor['aodh::install::end'],
  }

}
