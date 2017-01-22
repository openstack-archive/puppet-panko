# == Class: panko::deps
#
#  Panko anchors and dependency management
#
class panko::deps {
  # Setup anchors for install, config and service phases of the module.  These
  # anchors allow external modules to hook the begin and end of any of these
  # phases.  Package or service management can also be replaced by ensuring the
  # package is absent or turning off service management and having the
  # replacement depend on the appropriate anchors.  When applicable, end tags
  # should be notified so that subscribers can determine if installation,
  # config or service state changed and act on that if needed.
  anchor { 'panko::install::begin': }
  -> Package<| tag == 'panko-package'|>
  ~> anchor { 'panko::install::end': }
  -> anchor { 'panko::config::begin': }
  -> Panko_config<||>
  ~> anchor { 'panko::config::end': }
  -> anchor { 'panko::db::begin': }
  -> anchor { 'panko::db::end': }
  ~> anchor { 'panko::dbsync::begin': }
  -> anchor { 'panko::dbsync::end': }
  ~> anchor { 'panko::service::begin': }
  ~> Service<| tag == 'panko-service' |>
  ~> anchor { 'panko::service::end': }

  # policy config should occur in the config block also.
  Anchor['panko::config::begin']
  -> Openstacklib::Policy::Base<||>
  ~> Anchor['panko::config::end']

  # api paste ini config should occur in the config block also.
  Anchor['panko::config::begin']
  -> Panko_api_paste_ini<||>
  ~> Anchor['panko::config::end']

  # all db settings should be applied and all packages should be installed
  # before dbsync starts
  Oslo::Db<||> -> Anchor['panko::dbsync::begin']

  # Installation or config changes will always restart services.
  Anchor['panko::install::end'] ~> Anchor['panko::service::begin']
  Anchor['panko::config::end']  ~> Anchor['panko::service::begin']
}
