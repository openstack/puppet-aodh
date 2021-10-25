# == Class: aodh::coordination
#
# Setup and configure Aodh coordination settings.
#
# === Parameters
#
# [*backend_url*]
#   (Optional) Coordination backend URL.
#   Defaults to $::os_service_default
#
# [*heartbeat_interval*]
#   (Optional) Number of seconds between hearbeats for distributed
#   coordintation.
#   Defaults to $::os_service_default
#
# [*retry_backoff*]
#   (Optional) Retry backoff factor when retrying to connect with coordination
#   backend.
#   Defaults to $::os_service_default
#
# [*max_retry_interval*]
#   (Optional) Maximum number of seconds between retry to join partitioning
#   group
#   Defaults to $::os_service_default
#
# DEPRECATED PARAMETERS
#
# [*heartbeat*]
#   (Optional) Number of seconds between hearbeats for distributed
#   coordintation.
#   Defaults to undef
#
class aodh::coordination (
  $backend_url        = $::os_service_default,
  $heartbeat_interval = $::os_service_default,
  $retry_backoff      = $::os_service_default,
  $max_retry_interval = $::os_service_default,
  # DEPRECATED PARAMETERS
  $heartbeat          = undef,
) {

  include aodh::deps

  $backend_url_real = pick($::aodh::evaluator::coordination_url, $backend_url)

  if $heartbeat != undef {
    warning('The heartbeat parmaeter is deprecated. Use the heartbeat_interval parameter instead')
  }
  $heartbeat_interval_real = pick($heartbeat, $heartbeat_interval)

  oslo::coordination{ 'aodh_config':
    backend_url => $backend_url_real
  }

  aodh_config {
    'coordination/heartbeat_interval': value => $heartbeat_interval_real;
    'coordination/retry_backoff':      value => $retry_backoff;
    'coordination/max_retry_interval': value => $max_retry_interval;
  }

  # TODO(tkajinam): Remove this when the hearbeat parameter is removed.
  aodh_config {
    'coordination/heartbeat': ensure => absent;
  }
}
