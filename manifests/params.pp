# == class: mssql::params
#
# This class manages MSSQL paraameters
#
# == Paramaters
#
# majority of parameters can be found on microsoft site. Others in Readme File
# http://msdn.microsoft.com/en-us/library/ms144259(v=sql.110).aspx
#
# === Authors
#
# Jerome RIVIERE (www.jerome-riviere.re)
#
# === Copyright
#
# Copyright 2014 Jerome RIVIERE.
#
class windows_sql::params (
  $action                       = $action,
  $enu                          = $enu,
  $quiet                        = $quiet,
  $quietsimple                  = $quietsimple,
  $uimode                       = $uimode,
  $help                         = $help,
  $indicateprogress             = $indicateprogress,
  $x86                          = $x86,
  $sqmreporting                 = $sqmreporting,
  $errorreporting               = $errorreporting,
  $sqlcollation                 = $sqlcollation,
  $tcpenabled                   = $tcpenabled,
  $npenabled                    = $npenabled,
  $browsersvcstartuptype        = $browsersvcstartuptype,
  $iacceptsqlserverlicenseterms = $iacceptsqlserverlicenseterms,
  $enableranu                   = $enableranu,
  $filestreamlevel              = $filestreamlevel,

  $instancename                 = $instancename,
  $instanceid                   = $instanceid,
  $features                     = $features,

  # AGT
  $agtsvcaccount                = $agtsvcaccount,
  $agtsvcpassword               = $agtsvcpassword,
  $agtsvcstartuptype            = $agtsvcstartuptype,

  # SVC
  $sqlsvcaccount                = $sqlsvcaccount,
  $sqlsvcpassword               = $sqlsvcpassword,
  $sqlsvcstartuptype            = $sqlsvcstartuptype,

  # AS
  $assvcaccount                 = $assvcaccount,
  $assvcpassword                = $assvcpassword,
  $assvcstartuptype             = $assvcstartuptype,
  $ascollation                  = $ascollation,
  $asbackupdir                  = $asbackupdir,
  $asdatadir                    = $asdatadir,
  $aslogdir                     = $aslogdir,
  $asservermode                 = $asservermode,
  $astempdir                    = $astempdir,
  $asconfigdir                  = $asconfigdir,
  $assysadminaccounts           = $assysadminaccounts,

  # RS
  $rssvcaccount                 = $rssvcaccount,
  $rssvcpassword                = $rssvcpassword,
  $rssvcstartuptype             = $rssvcstartuptype,
  $rsinstallmode                = $rsinstallmode,

  # IS
  $issvcaccount                 = $issvcaccount,
  $issvcpassword                = $issvcpassword,
  $issvcstartuptype             = $issvcstartuptype,

  #SQL Server Engine Database
  $sqltempdbdir                 = $sqltempdbdir,
  $sqltempdblogdir              = $sqltempdblogdir,
  $sqluserdbdir                 = $sqluserdbdir,
  $sqluserdblogdir              = $sqluserdblogdir,
  
  $instancedir                  = $instancedir,
  $sqlsysadminaccounts          = $sqlsysadminaccounts,
  $securitymode                 = $securitymode,
  $sapwd                        = $sapwd,
  $addcurrentuserassqladmin     = $addcurrentuserassqladmin,
  $pid                          = $pid,
  $configurationfile            = $configurationfile,

  #use for load password. Default C:\\users.xml
  $userxml                      = $userxml,
){  
  # String Validation
  validate_string($instancename)
  validate_string($uimode)
  validate_string($features)
  validate_string($securitymode)
  validate_string($ascollation)
  validate_string($sqlcollation)
  validate_string($sapwd)
  validate_string($agtsvcpassword)
  validate_string($sqlsvcpassword)
  validate_string($assvcpassword)
  validate_string($rssvcpassword)
  validate_string($issvcpassword)

  # Boolean part Validation
  validate_bool($enu)
  validate_bool($quiet)
  validate_bool($quietsimple)
  validate_bool($help)
  validate_bool($indicateprogress)
  validate_bool($x86)
  validate_bool($sqmreporting)
  validate_bool($errorreporting)
  validate_bool($iacceptsqlserverlicenseterms)
  validate_bool($enableranu)
  validate_bool($addcurrentuserassqladmin)
  
  # Value Validation
  validate_re($tcpenabled, '^(0|1)$', 'valid values for tcpenabled are \'0\' or \'1\'')
  validate_re($npenabled, '^(0|1)$', 'valid values for npenabled are \'0\' or \'1\'')
  validate_re($filestreamlevel, '^(0|1)$', 'valid values for filestreamlevel are \'0\' or \'1\'')
  validate_re($asservermode, '^(MULTIDIMENSIONAL|POWERPIVOT|TABULAR)$', 'valid values for ASSERVERMODE are \'MULTIDIMENSIONAL\' or \'POWERPIVOT\' or \'TABULAR\' in uppercase ')

  # Startup type Validation
  validate_re($browsersvcstartuptype, '^(Disabled|Automatic|Manual)$', 'valid values for browsersvcstartuptype are \'Disabled\' or \'Automatic\' or \'Manual\'')
  validate_re($agtsvcstartuptype, '^(Disabled|Automatic|Manual)$', 'valid values for agtsvcstartuptype are \'Disabled\' or \'Automatic\' or \'Manual\'')
  validate_re($sqlsvcstartuptype, '^(Disabled|Automatic|Manual)$', 'valid values for sqlsvcstartuptype are \'Disabled\' or \'Automatic\' or \'Manual\'')
  validate_re($assvcstartuptype, '^(Disabled|Automatic|Manual)$', 'valid values for assvcstartuptype are \'Disabled\' or \'Automatic\' or \'Manual\'')
  validate_re($rssvcstartuptype, '^(Disabled|Automatic|Manual)$', 'valid values for rssvcstartuptype are \'Disabled\' or \'Automatic\' or \'Manual\'')
  validate_re($issvcstartuptype, '^(Disabled|Automatic|Manual)$', 'valid values for issvcstartuptype are \'Disabled\' or \'Automatic\' or \'Manual\'')
  
  validate_re($action, '^(Install|Uninstall|RunDiscovery)$', 'valid values available action are \'Install\' or \'Uninstall\'. Others will be tested soon as possible')

  if(capitalize($action) == 'Install' and empty($features)){
    fail('You can\'t use Action=Install and not defined Features')
  }
  
  if($quiet and $quietsimple){
    fail('You can\'t set true to $quiet and $quietsimple in the same time. One have to be set to false.')
  }
  if(($quiet or $quietsimple) and !empty($uimode)){
    fail('You can\'t set true to $quiet or $quietsimple and in the same time use a value for uimode. Choose what kind of install you really want')
  }
  if(($quiet or $quietsimple) and !$iacceptsqlserverlicenseterms){
    fail('If you use quiet or quiet simple option, iacceptsqlserverlicenseterms must be defined')
  }
  if(upcase($securitymode) != 'SQL' ){
    fail('Security mode only support SQL value, if no value is supplied, then Windows-Only authentication mode is used')
  }
  if((upcase($securitymode) == 'SQL') and empty($sapwd)){
    fail('You can\'t put $securitymode to \'SQL\' without specify a SQL Admin password with $sapwd variable')
  }
  if(empty($features) and $config == 'Install'){
    fail('You try to install SQL Server without specify any feature, this is not possible !!')
  }
  if(!empty($agtsvcaccount)){
    if(empty($agtsvcpassword)){
      $agtpwd = get_password($agtsvcaccount,$userxml)
	  if (unique($agtpwd) =~ 'nil' or empty($agtpwd)){
        fail('You specified a account for the SQL Agent service but doesn\'t provide a password for it. Please fill the xml or the parameters in your manifest')
      }
    }else{
      $agtpwd = $agtsvcpassword
    }
  }
  if(!empty($sqlsvcaccount)){
    if(empty($sqlsvcpassword)){
      $sqlpwd = get_password($sqlsvcaccount,$userxml)
	  if (unique($sqlpwd) =~ 'nil' or empty($sqlpwd)){
       fail('You specified a account for the SQL service but doesn\'t provide a password for it. Please fill the xml or the parameters in your manifest')
      }
    }else{
      $sqlpwd = $agtsvcpassword
    }
  }
  if(!empty($rssvcaccount)){
    if(empty($rssvcpassword)){
      $rspwd = get_password($rssvcaccount,$userxml)
	  if (unique($rspwd) =~ 'nil' or empty($rspwd)){
       fail('You specified a account for the Reporting service but doesn\'t provide a password for it. Please fill the xml or the parameters in your manifest')
      }
    }else{
      $rspwd = $rssvcpassword
    }
  }
  if(!empty($issvcaccount)){
    if(empty($issvcpassword)){
      $ispwd = get_password($issvcaccount,$userxml)
	  if (unique($ispwd) =~ 'nil' or empty($ispwd)){
       fail('You specified a account for the Integration service but doesn\'t provide a password for it. Please fill the xml or the parameters in your manifest')
      }
    }else{
      $ispwd = $issvcpassword
    }
  }
  if(!empty($assvcaccount)){
    if(empty($assvcpassword)){
      $aspwd = get_password($assvcaccount,$userxml)
	  if (unique($aspwd) =~ 'nil' or empty($aspwd)){
       fail('You specified a account for the Analysis service but doesn\'t provide a password for it. Please fill the xml or the parameters in your manifest')
      }
    }else{
      $aspwd = $assvcpassword
    }
    validate_re($asservermode, '^(MULTIDIMENSIONAL|POWERPIVOT|TABULAR)$', 'valid values for ASSERVERMODE are \'MULTIDIMENSIONAL\' or \'POWERPIVOT\' or \'TABULAR\' in uppercase ')
    if(empty($assysadminaccounts)){
      fail('Analysis Administrator account must be set when you set the as svc account')
    }
  }
  file { "$configurationfile":
    content => template('windows_sql/config.erb'),
    replace => yes,
  }
}