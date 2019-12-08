#
# Class to execute panko-manage db_sync
#
# == Parameters
#
# [*extra_params*]
#   (Optional) String of extra command line parameters to append
#   to the panko-dbsync command.
#   Defaults to undef
#
class panko::db::sync(
  $extra_params = undef,
) {

  include panko::deps

  exec { 'panko-db-sync':
    command     => "panko-dbsync --config-file /etc/panko/panko.conf ${extra_params}",
    path        => '/usr/bin',
    user        => 'panko',
    refreshonly => true,
    try_sleep   => 5,
    tries       => 10,
    logoutput   => 'on_failure',
    subscribe   => [
      Anchor['panko::install::end'],
      Anchor['panko::config::end'],
      Anchor['panko::dbsync::begin']
    ],
    notify      => Anchor['panko::dbsync::end'],
    tag         => 'openstack-db',
  }

}
