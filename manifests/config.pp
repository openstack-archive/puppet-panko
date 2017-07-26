# == Class: panko::config
#
# This class is used to manage arbitrary panko configurations.
#
# === Parameters
#
# [*panko_config*]
#   (optional) Allow configuration of arbitrary panko configurations.
#   The value is an hash of panko_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   panko_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
# [*panko_api_paste_ini*]
#   (optional) Allow configuration of /etc/panko/api_paste.ini options.
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class panko::config (
  $panko_config        = {},
  $panko_api_paste_ini = {},
) {

  include ::panko::deps

  validate_hash($panko_config)
  validate_hash($panko_api_paste_ini)

  create_resources('panko_config', $panko_config)
  create_resources('panko_api_paste_ini', $panko_api_paste_ini)
}
