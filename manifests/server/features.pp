# Install Windows Features
class chocolatey::server::features {
  windowsfeature { 'Web-WebServer':
    ensure => present,
    installmanagementtools => true,
    before => Exec['Install Choco'],
  }
  windowsfeature { 'Web-Asp-Net45':
    ensure  => present,
    require => Windowsfeature['Web-WebServer'],
  }
}
