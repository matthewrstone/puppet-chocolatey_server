# install chocolatey client
class chocolatey::client {
  exec { 'Install Choco' :
    command  => 'iex ((new-object net.webclient).DownloadString("https://chocolatey.org/install.ps1"))',
    unless   => 'If (!(Test-Path "c:\programdata\chocolatey\bin")) { exit 1 } else { exit 0 }',
    provider => powershell,
  }
}
