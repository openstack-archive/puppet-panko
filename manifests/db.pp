# == Class: panko::db
#
#  Configure the panko database
#
# === Parameters
#
# [*database_connection*]
#   (Optional) Url used to connect to database.
#   Defaults to 'sqlite:////var/lib/panko/panko.sqlite'.
#
# [*database_connection_recycle_time*]
#   (Optional) Timeout when db connections should be reaped.
#   Defaults to $::os_service_default
#
# [*database_db_max_retries*]
#   (optional) Maximum retries in case of connection error or deadlock error
#   before error is raised. Set to -1 to specify an infinite retry count.
#   Defaults to $::os_service_default
#
# [*database_max_retries*]
#   (Optional) Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   Defaults to $::os_service_default
#
# [*database_retry_interval*]
#   (Optional) Interval between retries of opening a database connection.
#   Defaults to $::os_service_default
#
# [*database_max_pool_size*]
#   (Optional)Maximum number of SQL connections to keep open in a pool.
#   Defaults to $::os_service_default
#
# [*database_max_overflow*]
#   (Optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to $::os_service_default
#
# [*database_pool_timeout*]
#   (Optional) If set, use this value for pool_timeout with SQLAlchemy.
#   Defaults to $::os_service_default
#
# DEPRECATED PARAMETERS
#
# [*database_min_pool_size*]
#   (Optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to undef
#
class panko::db (
  $database_connection              = 'sqlite:////var/lib/panko/panko.sqlite',
  $database_connection_recycle_time = $::os_service_default,
  $database_max_pool_size           = $::os_service_default,
  $database_db_max_retries          = $::os_service_default,
  $database_max_retries             = $::os_service_default,
  $database_retry_interval          = $::os_service_default,
  $database_max_overflow            = $::os_service_default,
  $database_pool_timeout            = $::os_service_default,
  # DEPRECATED PARAMETERS
  $database_min_pool_size           = undef,
) {

  include panko::deps

  if $database_min_pool_size {
    warning('The database_min_pool_size parameter is deprecated, and will be removed in a future release.')
  }

  validate_legacy(Oslo::Dbconn, 'validate_re', $database_connection,
    ['^(sqlite|mysql(\+pymysql)?|postgresql(\+psycopg2)?):\/\/(\S+:\S+@\S+\/\S+)?'])

  oslo::db { 'panko_config':
    connection              => $database_connection,
    connection_recycle_time => $database_connection_recycle_time,
    db_max_retries          => $database_db_max_retries,
    max_retries             => $database_max_retries,
    retry_interval          => $database_retry_interval,
    max_pool_size           => $database_max_pool_size,
    max_overflow            => $database_max_overflow,
    pool_timeout            => $database_pool_timeout,
  }
}
