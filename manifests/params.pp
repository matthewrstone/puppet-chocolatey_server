# == Class chocolatey_server::params
#
# This class is meant to be called from chocolatey_server.
# It sets variables according to platform.
#
class chocolatey_server::params {
  case $::osfamily {
    'windows': {
      $port = hiera('chocolatey_server::port','80')
      $location = hiera('chocolatey_server::location','c:\tools\chocolatey')
      $app_poole = hiera('chocolatey_server::app_pool', 'chocolatey.server')
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
