# Parameters for puppet-panko
#
class panko::params {
  include ::openstacklib::defaults

  case $::osfamily {
    'RedHat': {
      $api_package_name       = 'openstack-panko-api'
      $api_service_name       = 'openstack-panko-api'
    }
    'Debian': {
      $api_package_name       = 'panko-api'
      $api_service_name       = 'panko-api'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }

  } # Case $::osfamily
}
