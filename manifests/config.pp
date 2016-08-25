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
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class panko::config (
  $panko_config = {},
) {

  validate_hash($panko_config)

  create_resources('panko_config', $panko_config)
}
