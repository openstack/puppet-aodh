#
# Copyright 2021 Thomas Goirand <zigo@debian.org>
#
# Author: Thomas Goirand <zigo@debian.org>
#
# == Class: aodh::wsgi::uwsgi
#
# Configure the UWSGI service for Aodh API.
#
# == Parameters
#
# [*processes*]
#   (Optional) Number of processes.
#   Defaults to $::os_workers.
#
# [*threads*]
#   (Optional) Number of threads.
#   Defaults to 32.
#
# [*listen_queue_size*]
#   (Optional) Socket listen queue size.
#   Defaults to 100
#
class aodh::wsgi::uwsgi (
  $processes         = $::os_workers,
  $threads           = 32,
  $listen_queue_size = 100,
){

  include aodh::deps

  if $::os_package_type != 'debian'{
    warning('This class is only valid for Debian, as other operating systems are not using uwsgi by default.')
  }

  aodh_api_uwsgi_config {
    'uwsgi/processes': value => $processes;
    'uwsgi/threads':   value => $threads;
    'uwsgi/listen':    value => $listen_queue_size;
  }
}
