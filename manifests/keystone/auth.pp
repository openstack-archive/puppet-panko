# == Class: panko::keystone::auth
#
# Configures panko user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (Required) Password for panko user.
#
# [*auth_name*]
#   (Optional) Username for panko service.
#   Defaults to 'panko'.
#
# [*email*]
#   (Optional) Email for panko user.
#   Defaults to 'panko@localhost'.
#
# [*tenant*]
#   (Optional) Tenant for panko user.
#   Defaults to 'services'.
#
# [*configure_endpoint*]
#   (Optional) Should panko endpoint be configured?
#   Defaults to true.
#
# [*configure_user*]
#   (Optional) Should the service user be configured?
#   Defaults to true.
#
# [*configure_user_role*]
#   (Optional) Should the admin role be configured for the service user?
#   Defaults to true.
#
# [*service_type*]
#   (Optional) Type of service.
#   Defaults to 'event'.
#
# [*region*]
#   (Optional) Region for endpoint.
#   Defaults to 'RegionOne'.
#
# [*service_name*]
#   (Optional) Name of the service.
#   Defaults to the value of 'panko'.
#
# [*service_description*]
#   (Optional) Description of the service.
#   Default to 'OpenStack Event Service'
#
# [*public_url*]
#   (0ptional) The endpoint's public url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8977'
#
# [*admin_url*]
#   (Optional) The endpoint's admin url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8977'
#
# [*internal_url*]
#   (Optional) The endpoint's internal url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8977'
#
# === Examples:
#
#  class { 'panko::keystone::auth':
#    public_url   => 'https://10.0.0.10:8977',
#    internal_url => 'https://10.0.0.11:8977',
#    admin_url    => 'https://10.0.0.11:8977',
#  }
#
class panko::keystone::auth (
  $password,
  $auth_name           = 'panko',
  $email               = 'panko@localhost',
  $tenant              = 'services',
  $configure_endpoint  = true,
  $configure_user      = true,
  $configure_user_role = true,
  $service_name        = 'panko',
  $service_description = 'OpenStack Event Service',
  $service_type        = 'event',
  $region              = 'RegionOne',
  $public_url          = 'http://127.0.0.1:8977',
  $admin_url           = 'http://127.0.0.1:8977',
  $internal_url        = 'http://127.0.0.1:8977',
) {

  include ::panko::deps

  keystone::resource::service_identity { 'panko':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    service_name        => $service_name,
    service_type        => $service_type,
    service_description => $service_description,
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => $public_url,
    internal_url        => $internal_url,
    admin_url           => $admin_url,
  }

}
