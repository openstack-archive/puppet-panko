#
# == Class: panko::expirer
#
# Setups Panko Expirer service to enable TTL feature.
#
# === Parameters
#
#  [*enable_cron*]
#    (optional) Whether to configure a crontab entry to run the expiry.
#    When set to False, Puppet will try to remove the crontab.
#    Defaults to true.
#
#  [*minute*]
#    (optional) Defaults to '1'.
#
#  [*hour*]
#    (optional) Defaults to '0'.
#
#  [*monthday*]
#    (optional) Defaults to '*'.
#
#  [*month*]
#    (optional) Defaults to '*'.
#
#  [*weekday*]
#    (optional) Defaults to '*'.
#
class panko::expirer (
  $enable_cron = true,
  $minute      = 1,
  $hour        = 0,
  $monthday    = '*',
  $month       = '*',
  $weekday     = '*',
) {

  include panko::params
  include panko::deps

  Anchor['panko::install::end'] ~> Class['panko::expirer']

  if $enable_cron {
    $ensure = 'present'
  } else {
    $ensure = 'absent'
  }

  cron { 'panko-expirer':
    ensure      => $ensure,
    command     => $panko::params::expirer_command,
    environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
    user        => 'panko',
    minute      => $minute,
    hour        => $hour,
    monthday    => $monthday,
    month       => $month,
    weekday     => $weekday
  }

}
