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
#  [*events_delete_batch_size*]
#    (optional) Limit number of deleted events in single purge run.
#    Defaults to $::os_service_default.
#
class panko::expirer (
  $enable_cron              = true,
  $minute                   = 1,
  $hour                     = 0,
  $monthday                 = '*',
  $month                    = '*',
  $weekday                  = '*',
  $events_delete_batch_size = $::os_service_default,
) {

  include panko::params
  include panko::deps

  Anchor['panko::install::end'] ~> Class['panko::expirer']

  if $enable_cron {
    $ensure = 'present'
  } else {
    $ensure = 'absent'
  }

  panko_config { 'database/events_delete_batch_size':
    value => $events_delete_batch_size
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
