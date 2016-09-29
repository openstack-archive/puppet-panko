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
    command     => "panko-dbsync --config-file /etc/panko/panko.conf ${extra_params}",
    path        => '/usr/bin',
    user        => 'panko',
    refreshonly => true,
    try_sleep   => 5,
    tries       => 10,
    logoutput   => 'on_failure',
  }

  Package<| tag == 'panko-package' |> ~> Exec['panko-db-sync']
  Exec['panko-db-sync'] ~> Service<| tag == 'panko-db-sync-service' |>
  Panko_config<||> ~> Exec['panko-db-sync']
  Panko_config<| title == 'database/connection' |> ~> Exec['panko-db-sync']
}
