# == Class chocolatey_server::params
#
# This class is meant to be called from chocolatey_server.
# It sets variables according to platform.
#
class chocolatey::server::params {
  case $::osfamily {
    'windows': {
      $port = hiera('chocolatey::server::port','80')
      $location = hiera('chocolatey::server::location','c:\tools\chocolatey.server')
      $app_pool = hiera('chocolatey::server::app_pool', 'chocolatey.server')
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
