#
# == Class: panko::expirer
#
# Setups Panko Expirer service to enable TTL feature.
#
# === Parameters
#
#  [*ensure*]
#    (optional) The state of cron job.
#    Defaults to present.
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
#  [*events_delete_batch_size*]
#    (optional) Limit number of deleted events in single purge run.
#    Defaults to $::os_service_default.
#
# DEPRECATED PARAMETERS
#
#  [*enable_cron*]
#    (optional) Whether to configure a crontab entry to run the expiry.
#    When set to False, Puppet will try to remove the crontab.
#    Defaults to undef,
#
class panko::expirer (
  $ensure                   = 'present',
  $minute                   = 1,
  $hour                     = 0,
  $monthday                 = '*',
  $month                    = '*',
  $weekday                  = '*',
  $maxdelay                 = 0,
  $events_delete_batch_size = $::os_service_default,
  # DEPRECATED PARAMETERS
  $enable_cron = undef,
) {

  include panko::params
  include panko::deps

  if $enable_cron != undef {
    warning('The panko::expirer::enable_cron is deprecated and will be removed \
in a future release. Use panko::expirer::ensure instead')

    if $enable_cron {
      $ensure_real = 'present'
    } else {
      $ensure_real = 'absent'
    }
  } else {
    $ensure_real = $ensure
  }

  if $maxdelay == 0 {
    $sleep = ''
  } else {
    $sleep = "sleep `expr \${RANDOM} \\% ${maxdelay}`; "
  }

  panko_config { 'database/events_delete_batch_size':
    value => $events_delete_batch_size
  }

  cron { 'panko-expirer':
    ensure      => $ensure_real,
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
