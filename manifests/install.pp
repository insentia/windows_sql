# == class: windows_sql::install
#
# This class manages MSSQL installation
#
# == Paramaters
#
#  sqlpath               # Path of SQL install directory
#  isopath               # Path of SQL iso
#  xmlpath               # Path where users.xml is located
#  configurationfile     # Path where you want to put the config file for sql
#  action                # install or uninstall mssql
#
# === Authors
#
# Jerome RIVIERE (www.jerome-riviere.re)
#
# === Copyright
#
# Copyright 2014 Jerome RIVIERE.
#
class windows_sql::install(
  $sqlpath           = $sqlpath,
  $isopath           = $isopath,
  $xmlpath           = $xmlpath,
  $configurationfile = $configurationfile,
  $action            = $action,
  $forcerestart      = $forcerestart,
){
  validate_bool($forcerestart)
  if(!empty($sqlpath)){
    $path = $sqlpath
    file{'C:\checkifinstall.ps1':
      content => template('windows_sql/checkifinstall.erb'),
    }
    exec{"${action} SQL":
      command  => "setup.exe /CONFIGURATIONFILE='${configurationfile}';",
      cwd      => "$sqlpath",
      path     => "$sqlpath",
      provider => 'powershell',
      onlyif   => 'C:\\checkifinstall.ps1',
      timeout  => 0,
    }
  }elsif(!empty($isopath) and !empty(xmlpath)){
    file{'C:\checkifinstall.ps1':
      content => template('windows_sql/checkifinstall.erb'),
      require  => Windows_isos['SQLServer'],
    }
    exec{"${action} SQL":
      command  => "\$letter = \$null;if(test-path '${xmlpath}'){[xml]\$xml = New-Object system.Xml.XmlDocument;[xml]\$xml = Get-Content '${xmlpath}';foreach(\$iso in \$xml.configuration.isos.iso){if(\$iso.ImagePath -eq '${isopath}'){\$letter = \$iso.DriveLetter;}}if(\$letter -ne \$null){Push-Location;cd \$letter':';.\\setup.exe /CONFIGURATIONFILE='${configurationfile}';Pop-Location;}}{exit 0;}",
      onlyif   => 'C:\\checkifinstall.ps1',
      provider => 'powershell',
      timeout  => 0,
    }
  }else{
    fail('You need to provide $isopath or $sqlpath')
  }
}
