# == Class: panko::client
#
# Installs the panko python library.
#
# === Parameters:
#
# [*ensure*]
#   (Optional) Ensure state for pachage.
#   Defaults to 'present'.
#
class panko::client (
  $ensure = 'present'
) {

  include ::panko::deps
  include ::panko::params

  package { 'python-pankoclient':
    ensure => $ensure,
    name   => $::panko::params::client_package_name,
    tag    => 'openstack',
  }

}

