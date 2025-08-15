# == Class: aodh::coordination
#
# Setup and configure Aodh coordination settings.
#
# === Parameters
#
# [*backend_url*]
#   (Optional) Coordination backend URL.
#   Defaults to $facts['os_service_default']
#
# [*heartbeat_interval*]
#   (Optional) Number of seconds between heartbeats for distributed
#   coordination.
#   Defaults to $facts['os_service_default']
#
# [*retry_backoff*]
#   (Optional) Retry backoff factor when retrying to connect with coordination
#   backend.
#   Defaults to $facts['os_service_default']
#
# [*max_retry_interval*]
#   (Optional) Maximum number of seconds between retry to join partitioning
#   group
#   Defaults to $facts['os_service_default']
#
class aodh::coordination (
  $backend_url        = $facts['os_service_default'],
  $heartbeat_interval = $facts['os_service_default'],
  $retry_backoff      = $facts['os_service_default'],
  $max_retry_interval = $facts['os_service_default'],
) {

  include aodh::deps

  oslo::coordination { 'aodh_config':
    backend_url => $backend_url,
  }

  aodh_config {
    'coordination/heartbeat_interval': value => $heartbeat_interval;
    'coordination/retry_backoff':      value => $retry_backoff;
    'coordination/max_retry_interval': value => $max_retry_interval;
  }

  # all coordination settings should be applied and all packages should be
  # installed before service startup
  Oslo::Coordination['aodh_config'] -> Anchor['aodh::service::begin']
}
