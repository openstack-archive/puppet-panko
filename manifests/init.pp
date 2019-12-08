# == Class: panko
#
# Full description of class panko here.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of panko packages
#   Defaults to 'present'
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the panko config.
#   Defaults to false.
#
class panko (
  $package_ensure      = 'present',
  $purge_config        = false,
) inherits panko::params {

  include panko::deps

  package { 'panko':
    ensure => $package_ensure,
    name   => $::panko::params::common_package_name,
    tag    => ['openstack', 'panko-package'],
  }

  resources { 'panko_config':
    purge => $purge_config,
  }

}
