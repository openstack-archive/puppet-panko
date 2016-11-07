# Installs & configure the panko api service
#
# == Parameters
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to true.
#
# [*host*]
#   (optional) The panko api bind address.
#   Defaults to 0.0.0.0
#
# [*port*]
#   (optional) The panko api port.
#   Defaults to 8041
#
# [*workers*]
#   (optional) Number of workers for Panko API server.
#   Defaults to $::os_workers
#
# [*max_limit*]
#   (optional) The maximum number of items returned in a
#   single response from a collection resource.
#   Defaults to 1000
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*service_name*]
#   (optional) Name of the service that will be providing the
#   server functionality of panko-api.
#   If the value is 'httpd', this means panko-api will be a web
#   service, and you must use another class to configure that
#   web service. For example, use class { 'panko::wsgi::apache'...}
#   to make panko-api be a web app using apache mod_wsgi.
#   Defaults to '$::panko::params::api_service_name'
#
# [*sync_db*]
#   (optional) Run panko-upgrade db sync on api nodes after installing the package.
#   Defaults to false
#
# [*auth_strategy*]
#   (optional) Configure panko authentication.
#   Can be set to noauth and keystone.
#   Defaults to 'keystone'.
#
# [*enable_proxy_headers_parsing*]
#   (Optional) Enable paste middleware to handle SSL requests through
#   HTTPProxyToWSGI middleware.
#   Defaults to $::os_service_default.
#
class panko::api (
  $manage_service               = true,
  $enabled                      = true,
  $package_ensure               = 'present',
  $host                         = '0.0.0.0',
  $port                         = '8779',
  $workers                      = $::os_workers,
  $max_limit                    = 1000,
  $service_name                 = $::panko::params::api_service_name,
  $sync_db                      = false,
  $auth_strategy                = 'keystone',
  $enable_proxy_headers_parsing = $::os_service_default,
) inherits panko::params {

  include ::panko::policy

  Panko_config<||> ~> Service[$service_name]
  Panko_api_paste_ini<||> ~> Service[$service_name]
  Class['panko::policy'] ~> Service[$service_name]

  Package['panko-api'] -> Service[$service_name]
  Package['panko-api'] -> Service['panko-api']
  Package['panko-api'] -> Class['panko::policy']
  package { 'panko-api':
    ensure => $package_ensure,
    name   => $::panko::params::api_package_name,
    tag    => ['openstack', 'panko-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  if $sync_db {
    include ::panko::db::sync
  }

  if $service_name == $::panko::params::api_service_name {
    service { 'panko-api':
      ensure     => $service_ensure,
      name       => $::panko::params::api_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      require    => Class['panko::db'],
      tag        => ['panko-service', 'panko-db-sync-service'],
    }
  } elsif $service_name == 'httpd' {
    include ::apache::params
    service { 'panko-api':
      ensure => 'stopped',
      name   => $::panko::params::api_service_name,
      enable => false,
      tag    => ['panko-service', 'panko-db-sync-service'],
    }
    Class['panko::db'] -> Service[$service_name]
    Service <<| title == 'httpd' |>> { tag +> 'panko-db-sync-service' }

    # we need to make sure panko-api/eventlet is stopped before trying to start apache
    Service['panko-api'] -> Service[$service_name]
  } else {
    fail("Invalid service_name. Either panko/openstack-panko-api for \
running as a standalone service, or httpd for being run by a httpd server")
  }

  panko_config {
    'api/host':      value => $host;
    'api/port':      value => $port;
    'api/workers':   value => $workers;
    'api/max_limit': value => $max_limit;
  }

  if $auth_strategy == 'keystone' {
    include ::panko::keystone::authtoken
    panko_api_paste_ini {
      'pipeline:main/pipeline':  value => 'panko+auth',
    }
  } else {
    panko_api_paste_ini {
      'pipeline:main/pipeline':  value => 'panko+noauth',
    }
  }

  oslo::middleware { 'panko_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
  }

}
