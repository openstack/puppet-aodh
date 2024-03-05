#
# Class to execute "aodh-dbsync"
#
# [*user*]
#   (Optional) User to run dbsync command.
#   Defaults to $::aodh::params::user
#
# [*db_sync_timeout*]
#   (Optional) Timeout for the execution of the db_sync
#   Defaults to 300
#
class aodh::db::sync (
  $user            = $::aodh::params::user,
  $db_sync_timeout = 300,
) inherits aodh::params {

  include aodh::deps

  exec { 'aodh-db-sync':
    command     => ['aodh-dbsync'],
    path        => '/usr/bin',
    refreshonly => true,
    user        => $user,
    try_sleep   => 5,
    tries       => 10,
    timeout     => $db_sync_timeout,
    logoutput   => on_failure,
    subscribe   => [
      Anchor['aodh::install::end'],
      Anchor['aodh::config::end'],
      Anchor['aodh::dbsync::begin']
    ],
    notify      => Anchor['aodh::dbsync::end'],
    tag         => 'openstack-db',
  }
}
