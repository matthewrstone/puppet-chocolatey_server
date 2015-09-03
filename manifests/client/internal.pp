# Installs the chocolatey client from an internal source.
# requires chocolatey nupkg to be downloaded, renamed to
# chocolatey.zip and stored on an internal HTTP server
# (preferrably the internal chocolatey package serve).
class chocolatey::client::internal(
  $source_uri,
  $temp_folder
) {
  file { $temp_folder : ensure => directory }
  file { "${temp_folder}\\prep_chocolatey.ps1":
    ensure  => file,
    content => template("${module_name}/prep_chocolatey.ps1.erb"),
    require => File[$temp_folder],
    notify  => Exec['PrepChoco'],
  }
  exec { 'PrepChoco' :
    command     => "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy remotesigned -Command ${temp_folder}\\prep_chocolatey.ps1",
    creates     => "${temp_folder}\\choco\\tools\\chocolateyInstall.ps1",
    path        => $temp_folder,
    refreshonly => true,
  }
  exec { 'InstallChoco' :
    command  => "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy remotesigned -Command ${temp_folder}\\choco\\tools\\chocolateyInstall.ps1",
    creates  => "C:\\programdata\\chocolatey\\bin\\choco.exe",
    path     => $temp_folder,
  }
}
