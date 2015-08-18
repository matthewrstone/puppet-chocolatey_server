# == Class: chocolatey_server
class chocolatey_server (
  $port     = $::chocolatey_server::params::port,
  $location = $::chocolatey_server::params::location,
  $app_pool = $::chocolatey_server::params::app_pool,
) inherits chocolatey_server::params {
  require chocolatey_server::features
  require chocolatey_server::choco

  # Install the chocolatey server package
  package {'chocolatey.server':
    ensure   => installed,
    provider => chocolatey,
  } 

  # Create the IIS App Pool
  iis::manage_app_pool { $app_pool :
    enable_32_bit           => true,
    managed_runtime_version => 'v4.0',
  }

  iis::manage_site {'chocolatey.server':
    site_path  => $location,
    port       => $port,
    ip_address => '*',
    app_pool   => $app_pool,
    require    => Iis::Manage_app_pool[$app_pool],
  } 

 # remove default web site
  iis::manage_site {'Default Web Site':
    ensure    => absent,
    site_path => 'c:\inetpub\wwwroot',
    app_pool  => 'DefaultAppPool',
    require   => Iis::Manage_site['chocolatey.server'],
  }

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
    require   => Iis::Manage_site['chocolatey.server'],
  }
  acl { "${location}/App_Data":
    permissions => [
      { identity => "IIS APPPOOL\\${app_pool}",
        rights   => ['modify'] },
      { identity => 'IIS_IUSRS',
        rights   => ['modify'] }
    ],
    require   => Iis::Manage_app_pool[$app_pool],
  }
  # technically you may only need IIS_IUSRS but I have not tested this yet.

  reboot { 'Post Choco Install' :
    when => pending,
    subscribe => Package['chocolatey.server'],
  }

  iis::manage_site_state { 'chocolatey.server' :
    site_name => 'chocolatey.server',
    require => Iis::Manage_site['chocolatey.server'], 
  }
}
