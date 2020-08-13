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
#  [*maxdelay*]
#    (optional) In Seconds. Should be a positive integer.
#    Induces a random delay before running the cronjob to avoid running
#    all cron jobs at the same time on all hosts this job is configured.
#    Defaults to 0.
#
class panko::expirer (
  $enable_cron = true,
  $minute      = 1,
  $hour        = 0,
  $monthday    = '*',
  $month       = '*',
  $weekday     = '*',
  $maxdelay    = 0,
) {

  include panko::params
  include panko::deps

  if $enable_cron {
    $ensure = 'present'
  } else {
    $ensure = 'absent'
  }

  if $maxdelay == 0 {
    $sleep = ''
  } else {
    $sleep = "sleep `expr \${RANDOM} \\% ${maxdelay}`; "
  }

  cron { 'panko-expirer':
    ensure      => $ensure,
    command     => "${sleep}${panko::params::expirer_command}",
    environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
    user        => 'panko',
    minute      => $minute,
    hour        => $hour,
    monthday    => $monthday,
    month       => $month,
    weekday     => $weekday,
    require     => Anchor['panko::install::end'],
  }

}
