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
# [*max_request_body_size*]
#   (Optional) Set max request body size
#   Defaults to $::os_service_default.
#
# [*max_retries*]
#   (Optional) Maximum number of connection retries during startup.
#   Set to -1 to specify an infinite retry count. (integer value)
#   Defaults to $::os_service_default.
#
# [*retry_interval*]
#   (Optional) Interval between retries of connection.
#   Defaults to $::os_service_default.
#
# [*es_ssl_enabled*]
#   (Optional) Enable HTTPS connection in the Elasticsearch connection.
#   Defaults to $::os_service_default.
#
# [*es_index_name*]
#   (Optional) The name of the index in Elasticsearch (string value).
#   Defaults to $::os_service_default.
#
# [*event_time_to_live*]
#   (Optional) Number of seconds that events are kept in the database for
#   (<= 0 means forever)
#   Defaults to $::os_service_default.
#
# DEPRECATED PARAMETERS
#
# [*host*]
#   (optional) The panko api bind address.
#   Defaults to undef
#
# [*port*]
#   (optional) The panko api port.
#   Defaults to undef
#
# [*workers*]
#   (optional) Number of workers for Panko API server.
#   Defaults to undef
#
# [*max_limit*]
#   (optional) The maximum number of items returned in a
#   single response from a collection resource.
#   Defaults to undef
#
class panko::api (
  $manage_service               = true,
  $enabled                      = true,
  $package_ensure               = 'present',
  $service_name                 = $::panko::params::api_service_name,
  $sync_db                      = false,
  $auth_strategy                = 'keystone',
  $enable_proxy_headers_parsing = $::os_service_default,
  $max_request_body_size        = $::os_service_default,
  $max_retries                  = $::os_service_default,
  $retry_interval               = $::os_service_default,
  $es_ssl_enabled               = $::os_service_default,
  $es_index_name                = $::os_service_default,
  $event_time_to_live           = $::os_service_default,
  # DEPRECATED PARAMETERS
  $host                         = undef,
  $port                         = undef,
  $workers                      = undef,
  $max_limit                    = undef,
) inherits panko::params {

  if $host != undef {
    warning('The panko::api::host parameter is deprecated and has no effect')
  }
  if $port != undef {
    warning('The panko::api::port parameter is deprecated and has no effect')
  }
  if $workers != undef {
    warning('The panko::api::workers parameter is deprecated and has no effect')
  }
  if $max_limit != undef {
    warning('The panko::api::max_limit parameter is deprecated and has no effect')
  }

  include panko::deps
  include panko::policy

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
    include panko::db::sync
  }

  $api_service_name = $::panko::params::api_service_name
  if $api_service_name != 'httpd' and $service_name == $api_service_name {
    service { 'panko-api':
      ensure     => $service_ensure,
      name       => $api_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      tag        => ['panko-service', 'panko-db-sync-service'],
    }
  } elsif $service_name == 'httpd' {
    include apache::params
    Service <| title == 'httpd' |> {
      tag +> ['panko-service', 'panko-db-sync-service']
    }
    Class['panko::db'] -> Service[$service_name]

    if $api_service_name != 'httpd' {
      service { 'panko-api':
        ensure => 'stopped',
        name   => $api_service_name,
        enable => false,
        tag    => ['panko-service', 'panko-db-sync-service'],
      }
      # we need to make sure panko-api/eventlet is stopped before trying to start apache
      Service['panko-api'] -> Service[$service_name]
    }
  } else {
    fail('Invalid service_name.')
  }

  panko_config {
    'storage/max_retries':         value => $max_retries;
    'storage/retry_interval':      value => $retry_interval;
    'storage/es_ssl_enabled':      value => $es_ssl_enabled;
    'storage/es_index_name':       value => $es_index_name;
    'database/event_time_to_live': value => $event_time_to_live;
  }

  if $auth_strategy == 'keystone' {
    include panko::keystone::authtoken
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
    max_request_body_size        => $max_request_body_size,
  }

}
