# == Class: panko::db::postgresql
#
# Class that configures postgresql for panko
# Requires the Puppetlabs postgresql module.
#
# === Parameters
#
# [*password*]
#   (Required) Password to connect to the database.
#
# [*dbname*]
#   (Optional) Name of the database.
#   Defaults to 'panko'.
#
# [*user*]
#   (Optional) User to connect to the database.
#   Defaults to 'panko'.
#
#  [*encoding*]
#    (Optional) The charset to use for the database.
#    Default to undef.
#
#  [*privileges*]
#    (Optional) Privileges given to the database user.
#    Default to 'ALL'
#
class panko::db::postgresql(
  $password,
  $dbname     = 'panko',
  $user       = 'panko',
  $encoding   = undef,
  $privileges = 'ALL',
) {

  include ::panko::deps

  ::openstacklib::db::postgresql { 'panko':
    password_hash => postgresql_password($user, $password),
    dbname        => $dbname,
    user          => $user,
    encoding      => $encoding,
    privileges    => $privileges,
  }

  Anchor['panko::db::begin']
  ~> Class['panko::db::postgresql']
  ~> Anchor['panko::db::end']

}
