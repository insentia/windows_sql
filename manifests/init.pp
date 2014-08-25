# == Class: windows_sql
#
# This module allows you to install a mssql server 2012.
# This module have been tested on windows server 2012 r2 with sql server 2012 sp1.
#
# === Parameters
#
#  Can be found on read me
#
# === Examples
#
#  Can Be found on read me
#
# === Authors
#
# Jerome RIVIERE (www.jerome-riviere.re)
#
# === Copyright
#
# Copyright 2014 Jerome RIVIERE, unless otherwise noted.
#
class windows_sql (
  # Default option for SQL install
  $action                         = 'Install',
  $enu                            = true,
  $quiet                          = true,
  $quietsimple                    = false,
  $uimode                         = '',
  $help                           = false,
  $indicateprogress               = false,
  $x86                            = false,
  $sqmreporting                   = false,
  $errorreporting                 = false,
  $sqlcollation                   = 'Latin1_General_CI_AS',
  $tcpenabled                     = '1',
  $npenabled                      = '0',
  $browsersvcstartuptype          = 'Disabled',
  $iacceptsqlserverlicenseterms   = true,
  $enableranu                     = false,
  $filestreamlevel                = '0',

  # Instance
  $instancename                   = 'MSSQLSERVER',
  $instanceid                     = '',
  $instancedir                    = '',

  $features                       = '',
  
  ## SVC Account
  # SQL Agt
  $agtsvcaccount                  = '',
  $agtsvcpassword                 = '',
  $agtsvcstartuptype              = 'Automatic',

  #SQL SVC
  $sqlsvcaccount                  = '',
  $sqlsvcpassword                 = '',
  $sqlsvcstartuptype              = 'Automatic',

  #SQL AS
  $assvcaccount                   = '',
  $assvcpassword                  = '',
  $assvcstartuptype               = 'Automatic',
  $ascollation                    = 'Latin1_General_CI_AS',
  $asbackupdir                    = '',
  $asdatadir                      = '',
  $aslogdir                       = '',
  $asservermode                   = 'MULTIDIMENSIONAL',
  $astempdir                      = '',
  $asconfigdir                    = '',
  $assysadminaccounts             = 'Administrator',
  
  #SQL RS
  $rssvcaccount                   = '',
  $rssvcpassword                  = '',
  $rssvcstartuptype               = 'Automatic',
  $rsinstallmode                  = '',
  
  #SQL IS
  $issvcaccount                   = '',
  $issvcpassword                  = '',
  $issvcstartuptype               = 'Automatic',
  
  $sqlsysadminaccounts            = 'Administrator',
  $addcurrentuserassqladmin       = false,
  
  #SQL Server Engine Database
  $sqltempdbdir                   = '',
  $sqltempdblogdir                = '',
  $sqluserdbdir                   = '',
  $sqluserdblogdir                = '',
  
  #SQL

  $securitymode                   = '',
  $sapwd                          = '',

  $pid                            = '',
  $configurationfile              = 'C:\\configurationfile.ini',
  
  $userxml                        = 'C:\\users.xml',              #path of users xml file for load automatically his password
  $mode                           = 'agent',                      # mode for getting back from xml the svc account password. Default 'agent'. Other value 'master'
  $forcerestart                   = true,
  ## Installation parameters
  $sqlpath                        = '',
  $isopath                        = '',                           # work with xmlpath can't be set in same time that sqlpath
  $xmlpath                        = 'C:\\isos.xml',               # Can be define with isopath. Default C:\isos.xml
){
  class{'windows_sql::params':
    action                       => $action,
    enu                          => $enu,
    quiet                        => $quiet,
    quietsimple                  => $quietsimple,
    uimode                       => $uimode,
    help                         => $help,
    indicateprogress             => $indicateprogress,
    x86                          => $x86,
    sqmreporting                 => $sqmreporting,
    errorreporting               => $errorreporting,
    sqlcollation                 => $sqlcollation,
    tcpenabled                   => $tcpenabled,
    npenabled                    => $npenabled,
    browsersvcstartuptype        => $browsersvcstartuptype,
    iacceptsqlserverlicenseterms => $iacceptsqlserverlicenseterms,
    enableranu                   => $enableranu,
    filestreamlevel              => $filestreamlevel,

    instancename                 => $instancename,
    instanceid                   => $instanceid,
    features                     => $features,

  # AGT
    agtsvcaccount                => $agtsvcaccount,
    agtsvcpassword               => $agtsvcpassword,
    agtsvcstartuptype            => $agtsvcstartuptype,

  # SVC
    sqlsvcaccount                => $sqlsvcaccount,
    sqlsvcpassword               => $sqlsvcpassword,
    sqlsvcstartuptype            => $sqlsvcstartuptype,

  # AS
    assvcaccount                 => $assvcaccount,
    assvcpassword                => $assvcpassword,
    assvcstartuptype             => $assvcstartuptype,
    ascollation                  => $ascollation,
    asbackupdir                  => $asbackupdir,
    asdatadir                    => $asdatadir,
    aslogdir                     => $aslogdir,
    asservermode                 => $asservermode,
    astempdir                    => $astempdir,
    asconfigdir                  => $asconfigdir,
    assysadminaccounts           => $assysadminaccounts,

  # RS
    rssvcaccount                 => $rssvcaccount,
    rssvcpassword                => $rssvcpassword,
    rssvcstartuptype             => $rssvcstartuptype,
    rsinstallmode                => $rsinstallmode,

  # IS
    issvcaccount                 => $issvcaccount,
    issvcpassword                => $issvcpassword,
    issvcstartuptype             => $issvcstartuptype,

  #SQL Server Engine Database
    sqltempdbdir                 => $sqltempdbdir,
    sqltempdblogdir              => $sqltempdblogdir,
    sqluserdbdir                 => $sqluserdbdir,
    sqluserdblogdir              => $sqluserdblogdir,

    instancedir                  => $instancedir,
    sqlsysadminaccounts          => $sqlsysadminaccounts,
    securitymode                 => $securitymode,
    sapwd                        => $sapwd,
    pid                          => $pid,
    addcurrentuserassqladmin     => $addcurrentuserassqladmin,
    configurationfile            => $configurationfile,

    userxml                      => $userxml,
    mode                         => $mode,
  }

  class {'windows_sql::install' :
    sqlpath           => $sqlpath,
    isopath           => $isopath,
    xmlpath           => $xmlpath,
    configurationfile => $configurationfile,
    action            => $action,
    forcerestart      => $forcerestart,
  }

  if(!empty($isopath)){
    windows_isos{'SQLServer':
      ensure   => present,
      isopath  => $isopath,
      xmlpath  => $xmlpath,
    }
    anchor {'windows_sql::begin':} -> Windows_isos['SQLServer'] -> Class['windows_sql::params'] -> Class['windows_sql::install'] -> anchor {'windows_sql::end':}
  }else{
    anchor {'windows_sql::begin':} -> Class['windows_sql::params'] -> Class['windows_sql::install'] -> anchor {'windows_sql::end':}
  }
}
