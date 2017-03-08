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
# DEPRECATED PARAMETERS
#
# [*ensure_package*]
#   (optional) The state of panko packages
#   Defaults to undef
#
class panko (
  $package_ensure      = 'present',
  $purge_config        = false,
  # DEPRECATED PARAMETERS
  $ensure_package      = undef,
) inherits panko::params {

  include ::panko::deps
  include ::panko::logging

  if $ensure_package {
    warning("panko::ensure_package is deprecated and will be removed in \
the future release. Please use panko::package_ensure instead.")
    $package_ensure_real = $ensure_package
  } else {
    $package_ensure_real = $package_ensure
  }

  package { 'panko':
    ensure => $package_ensure_real,
    name   => $::panko::params::common_package_name,
    tag    => ['openstack', 'panko-package'],
  }

  resources { 'panko_config':
    purge => $purge_config,
  }

}
