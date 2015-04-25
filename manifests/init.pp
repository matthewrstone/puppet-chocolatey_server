# == Class: chocolatey_server
class chocolatey_server (
  $port = $chocolatey_server::params::_port,
  $location = $chocolatey_server::params::location,
  $app_pool = $chocolatey_server::params::app_pool,
) {

  # package install
  package {'chocolatey.server':
    ensure   => installed,
    provider => chocolatey,
  } ->

  # add windows features
  windowsfeature { 'Web-WebServer':
  installmanagementtools => true,
  } ->
  windowsfeature { 'Web-Asp-Net45':
  } ->

  # remove default web site
  iis::manage_site {'Default Web Site':
    ensure    => absent,
    site_path => 'any',
    app_pool  => 'DefaultAppPool'
  } ->

  # application in iis
  iis::manage_app_pool { $app_pool :
    enable_32_bit           => true,
    managed_runtime_version => 'v4.0',
  } ->
  iis::manage_site {'chocolatey.server':
    site_path  => $location,
    port       => $port,
    ip_address => '*',
    app_pool   => $app_pool,
  } ->

  # lock down web directory
  acl { $location :
    purge                      => true,
    inherit_parent_permissions => false,
    permissions                => [
      { identity => 'Administrators',
        rights   => ['full'] },
      { identity => 'IIS_IUSRS',
        rights   => ['read'] },
      { identity => 'IUSR',
        rights   => ['read'] },
      { identity => "IIS APPPOOL\\${app_pool}",
        rights   => ['read'] }
    ],
  } ->
  acl { "${location}/App_Data":
    permissions => [
      { identity => "IIS APPPOOL\\${app_pool}",
        rights   => ['modify'] },
      { identity => 'IIS_IUSRS',
        rights   => ['modify'] }
    ],
  }
  # technically you may only need IIS_IUSRS but I have not tested this yet.
}
