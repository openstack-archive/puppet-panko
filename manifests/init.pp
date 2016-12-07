# == Class: panko
#
# Full description of class panko here.
#
# === Parameters
#
# [*ensure_package*]
#   (optional) The state of panko packages
#   Defaults to 'present'
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the panko config.
#   Defaults to false.
#
class panko (
  $ensure_package      = 'present',
  $purge_config        = false,
) inherits panko::params {

  include ::panko::deps
  include ::panko::logging

  package { 'panko':
    ensure => $ensure_package,
    name   => $::panko::params::common_package_name,
    tag    => ['openstack', 'panko-package'],
  }

  resources { 'panko_config':
    purge => $purge_config,
  }

}
