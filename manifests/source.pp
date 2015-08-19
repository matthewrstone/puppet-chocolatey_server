# chocolatey sources
class chocolatey::source(
  $source_url,
  $source_name,
  $source_user = 'none',
  $source_pass = 'none',
  $ensure = 'present',
){
  $ps_source_check = "If ((choco source list | sls ${source_name}) -match '${source_name}')"
  case $ensure {
    'present' : { add { $source_name : source_url => $source_url, source_name => $source_name } }
    'absent'  : { remove { $source_name: source_url => $source_url, source_name => $source_name } }
    'enabled' : {
      add { $source_name : source_url => $source_url, source_name => $source_name }
      enable { $source_name: source_url => $source_url, source_name => $source_name }
    }
    'disabled' : {
      add { $source_name : source_url => $source_url, source_name => $source_name }
      disable { $source_name: source_url => $source_url, source_name => $source_name }
    }
    default : { fail('You must set ensure status...') }
  }
  Exec { provider => powershell }
  define add($source_name,$source_url) {
    $command = $source_user ? {
      default => "choco source add -n=${source_name} -s \"${source_url}\" -u=${source_user} -p=${source_pass}",
      'none'  => "choco source add -n=${source_name} -s \"${source_url}\"",
    }
    exec { "add_${source_name}" :
      command => $command,
      onlyif  => "If ((choco source list | sls ${source_name}) -match '${source_name}') { exit 1 }",
    }
  }

  define remove($source_name,$source_url) {
    exec { "remove_${source_name}" :
      command => "choco source remove -n=${source_name}",
      onlyif  => "If ((choco source list | sls ${source_name}) -match '${source_name}') { exit 0 }",
    }
  }
  
  define enable($source_name,$source_url) {
    exec { "enable_${source_name}" :
      command => "choco source enable -n=${source_name}",
      onlyif  => "If (((choco source list) | sls '${source_url}') -match '[Disabled]'){exit 0} else {exit 1}",
    }

  }

  define disable($source_name,$source_url) {
    exec { "disable_${source_name}" :
      command => "choco source disable -n=${source_name}",
      onlyif  => "If (((choco source list) | sls '${source_url}') -match '[Disabled]'){exit 1} else {exit 0}",
    }
  }
}
