#
# Class to execute panko-manage db_sync
#
# == Parameters
#
# [*extra_params*]
#   (optional) String of extra command line parameters to append
#   to the panko-dbsync command.
#   Defaults to undef
#
class panko::db::sync(
  $extra_params  = undef,
) {
  exec { 'panko-db-sync':
    command     => "panko-manage db_sync ${extra_params}",
    path        => '/usr/bin',
    user        => 'panko',
    refreshonly => true,
    subscribe   => [Package['panko'], Panko_config['database/connection']],
  }

  Exec['panko-manage db_sync'] ~> Service<| title == 'panko' |>
}
