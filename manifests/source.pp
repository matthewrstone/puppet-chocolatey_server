# chocolatey sources
define chocolatey::source(
  $source_url,
  $source_name = $title,
  $source_user = 'none',
  $source_pass = 'none',
  $ensure = 'present',
){

  Exec { provider => powershell }
  $choco = 'C:\ProgramData\chocolatey\bin\choco.exe'
#  $ps_source_check = "If ((${choco} source list | sls ${source_name}) -match '${source_name}')"
  case $ensure {
    'present' : { 
      $command = $source_user ? {
        default => "${choco} source add -n=${source_name} -s \"${source_url}\" -u=${source_user} -p=${source_pass}",
        'none'  => "${choco} source add -n=${source_name} -s \"${source_url}\"",
      }
      exec { "add_${source_name}" :
        command => $command,
        onlyif  => "If ((${choco} source list | sls ${source_name}) -match '${source_name}') { exit 1 }",
      }
    }
    'absent'  : { 
      exec { "remove_${source_name}" :
        command => "${choco} source remove -n=${source_name}",
        onlyif  => "If ((${choco} source list | sls ${source_name}) -match '${source_name}') { exit 0 }",
      }
    } 
    'enabled' : {
      $command = $source_user ? {
        default => "${choco} source add -n=${source_name} -s \"${source_url}\" -u=${source_user} -p=${source_pass}",
        'none'  => "${choco} source add -n=${source_name} -s \"${source_url}\"",
      }
      exec { "add_${source_name}" :
        command => $command,
        onlyif  => "If ((${choco} source list | sls ${source_name}) -match '${source_name}') { exit 1 }",
      }
      exec { "enable_${source_name}" :
        command => "${choco} source enable -n=${source_name}",
        onlyif  => "If (((${choco} source list) | sls '${source_url}') -match '[Disabled]'){exit 0} else {exit 1}",
      }
    }
    'disabled' : {
      $command = $source_user ? {
        default => "${choco} source add -n=${source_name} -s \"${source_url}\" -u=${source_user} -p=${source_pass}",
        'none'  => "${choco} source add -n=${source_name} -s \"${source_url}\"",
      }
      exec { "add_${source_name}" :
        command => $command,
        onlyif  => "If ((${choco} source list | sls ${source_name}) -match '${source_name}') { exit 1 }",
      }
      exec { "disable_${source_name}" :
        command => "${choco} source disable -n=${source_name}",
        onlyif  => "If (((${choco} source list) | sls '${source_url}') -match '[Disabled]'){exit 1} else {exit 0}",
      }
    }
    default : { fail('You must set ensure status...') }
  }

}
