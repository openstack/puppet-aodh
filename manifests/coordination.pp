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
# [*heartbeat*]
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
class aodh::coordination (
  $backend_url        = $::os_service_default,
  $heartbeat          = $::os_service_default,
  $retry_backoff      = $::os_service_default,
  $max_retry_interval = $::os_service_default,
) {

  include aodh::deps

  $backend_url_real = pick($::aodh::evaluator::coordination_url, $backend_url)

  oslo::coordination{ 'aodh_config':
    backend_url => $backend_url_real
  }

  aodh_config {
    'coordination/heartbeat':          value => $heartbeat;
    'coordination/retry_backoff':      value => $retry_backoff;
    'coordination/max_retry_interval': value => $max_retry_interval;
  }
}
