# == Class: aodh::db
#
#  Configure the aodh database
#
# === Parameters
#
# [*database_db_max_retries*]
#   (optional) Maximum retries in case of connection error or deadlock error
#   before error is raised. Set to -1 to specify an infinite retry count.
#   Defaults to $::os_service_default
#
# [*database_connection*]
#   Url used to connect to database.
#   (Optional) Defaults to "sqlite:////var/lib/aodh/aodh.sqlite".
#
# [*slave_connection*]
#   (optional) Connection url to connect to aodh slave database (read-only).
#   Defaults to $::os_service_default.
#
# [*database_connection_recycle_time*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to $::os_service_default.
#
# [*database_max_pool_size*]
#   Maximum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to $::os_service_default.
#
# [*database_max_retries*]
#   Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to $::os_service_default.
#
# [*database_retry_interval*]
#   Interval between retries of opening a database connection.
#   (Optional) Defaults to $::os_service_default.
#
# [*database_max_overflow*]
#   If set, use this value for max_overflow with sqlalchemy.
#   (Optional) Defaults to $::os_service_default.
#
# [*database_pool_timeout*]
#   (Optional) If set, use this value for pool_timeout with SQLAlchemy.
#   Defaults to $::os_service_default
#
# [*mysql_enable_ndb*]
#   (Optional) If True, transparently enables support for handling MySQL
#   Cluster (NDB).
#   Defaults to $::os_service_default
#
# DEPRECATED PARAMETERS
#
# [*database_min_pool_size*]
#   Minimum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to undef.
#
class aodh::db (
  $database_db_max_retries          = $::os_service_default,
  $database_connection              = 'sqlite:////var/lib/aodh/aodh.sqlite',
  $slave_connection                 = $::os_service_default,
  $database_connection_recycle_time = $::os_service_default,
  $database_max_pool_size           = $::os_service_default,
  $database_max_retries             = $::os_service_default,
  $database_retry_interval          = $::os_service_default,
  $database_max_overflow            = $::os_service_default,
  $database_pool_timeout            = $::os_service_default,
  $mysql_enable_ndb                 = $::os_service_default,
  # DEPRECATED PARAMETERS
  $database_min_pool_size           = undef,
) {

  include aodh::deps

  if defined('$::aodh::database_min_pool_size') {
    $database_min_pool_size_real = $::aodh::database_min_pool_size
  } else {
    $database_min_pool_size_real = $database_min_pool_size
  }
  if $database_min_pool_size_real {
    warning('The database_min_pool_size parameter is deprecated, and will be removed in a future release.')
  }

  $database_connection_real = pick($::aodh::database_connection, $database_connection)
  $slave_connection_real = pick($::aodh::slave_connection, $slave_connection)
  $database_max_pool_size_real = pick($::aodh::database_max_pool_size, $database_max_pool_size)
  $database_max_retries_real = pick($::aodh::database_max_retries, $database_max_retries)
  $database_retry_interval_real = pick($::aodh::database_retry_interval, $database_retry_interval)
  $database_max_overflow_real = pick($::aodh::database_max_overflow, $database_max_overflow)
  $database_connection_recycle_time_real = pick($::aodh::database_idle_timeout, $database_connection_recycle_time)

  oslo::db { 'aodh_config':
    db_max_retries          => $database_db_max_retries,
    connection              => $database_connection_real,
    slave_connection        => $slave_connection_real,
    connection_recycle_time => $database_connection_recycle_time_real,
    max_pool_size           => $database_max_pool_size_real,
    max_retries             => $database_max_retries_real,
    retry_interval          => $database_retry_interval_real,
    max_overflow            => $database_max_overflow_real,
    pool_timeout            => $database_pool_timeout,
    mysql_enable_ndb        => $mysql_enable_ndb,
  }
}
