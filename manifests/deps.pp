# == Class: aodh::deps
#
#  Aodh anchors and dependency management
#
class aodh::deps {
  # Setup anchors for install, config and service phases of the module.  These
  # anchors allow external modules to hook the begin and end of any of these
  # phases.  Package or service management can also be replaced by ensuring the
  # package is absent or turning off service management and having the
  # replacement depend on the appropriate anchors.  When applicable, end tags
  # should be notified so that subscribers can determine if installation,
  # config or service state changed and act on that if needed.
  anchor { 'aodh::install::begin': }
  -> Package<| tag == 'aodh-package'|>
  ~> anchor { 'aodh::install::end': }
  -> anchor { 'aodh::config::begin': }
  -> Aodh_config<||>
  ~> anchor { 'aodh::config::end': }
  -> anchor { 'aodh::db::begin': }
  -> anchor { 'aodh::db::end': }
  ~> anchor { 'aodh::dbsync::begin': }
  -> anchor { 'aodh::dbsync::end': }
  ~> anchor { 'aodh::service::begin': }
  ~> Service<| tag == 'aodh-service' |>
  ~> anchor { 'aodh::service::end': }

  Anchor['aodh::config::begin']
  -> Aodh_api_paste_ini<||>
  -> Anchor['aodh::config::end']

  Anchor['aodh::config::begin']
  -> Aodh_api_uwsgi_config<||>
  -> Anchor['aodh::config::end']

  # Installation or config changes will always restart services.
  Anchor['aodh::install::end'] ~> Anchor['aodh::service::begin']
  Anchor['aodh::config::end']  ~> Anchor['aodh::service::begin']
}
