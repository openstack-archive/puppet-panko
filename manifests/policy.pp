# == Class: panko::policy
#
# Configure the panko policies
#
# === Parameters
#
# [*policies*]
#   (Optional) Set of policies to configure for panko
#   Example :
#     {
#       'panko-context_is_admin' => {
#         'key' => 'context_is_admin',
#         'value' => 'true'
#       },
#       'panko-default' => {
#         'key' => 'default',
#         'value' => 'rule:admin_or_owner'
#       }
#     }
#   Defaults to empty hash.
#
# [*policy_path*]
#   (Optional) Path to the nova policy.json file
#   Defaults to /etc/panko/policy.json
#
class panko::policy (
  $policies    = {},
  $policy_path = '/etc/panko/policy.json',
) {

  include ::panko::deps
  include ::panko::params

  validate_legacy(Hash, 'validate_hash', $policies)

  Openstacklib::Policy::Base {
    file_path  => $policy_path,
    file_user  => 'root',
    file_group => $::panko::params::group,
  }

  create_resources('openstacklib::policy::base', $policies)

  oslo::policy { 'panko_config': policy_file => $policy_path }

}
