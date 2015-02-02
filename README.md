windows_sql

This is the windows_sql puppet module.

##Description

This module allows you to generate and install SQL Server 2012 on windows Server. You can also configure maintenance plan.

This module have been tested with SQL Server 2012 SP1 on Windows Server 2012 R2.
Should work, on Windows Server since 2012 and with SQL Server since 2012.

This module have been tested with puppet open source v3.5.1 and v3.6.2, the puppetmaster version is v3.4.3 (on ubuntu 14.04 LTS). 
Should work since version 3.5.1 of puppet

## Last Fix/Update
v 0.0.9 :
 - Pull request 4 from StefanSchoof/master
 - Add pid when use master mode. (powershell)
 - Fix execution of installation script when using master mode
 
## Generate configurationfile.ini
Generate Microsoft SQL Server 2012 file confsiguration from parameters you define.
If you create your service account with [windows_ad module](https://forge.puppetlabs.com/jriviere/windows_ad) and his xml file before calling the windows_sql class the password for each service account will be automatically retrieve from the users.xml file, 
else you can provide manually your password.
All password manually provided have priority on xml password.

The user domain doesn't need to be provided, it will be supplied by the $env:userdomain powershell variable for each service account variable (like AGTSVCACCOUNT) and SQLSYSADMINACCOUNTS

## Setup Requirements
Depends on the following modules:
 - ['puppetlabs/powershell', '>=1.0.2'](https://forge.puppetlabs.com/puppetlabs/powershell),
 - ['puppetlabs/stdlib', '>= 4.2.1'](https://forge.puppetlabs.com/puppetlabs/stdlib).
 + Optional
   - ['jriviere/windows_isos', '>= 0.0.4'](https://forge.puppetlabs.com/jriviere/windows_isos) (if you supply $isopath variable),
   - ['jriviere/windows_ad', '>= 0.1.2'](https://forge.puppetlabs.com/jriviere/windows_ad)] (fill password automatically for each account specified with this module and with his xml file)

## Example
```
class {'windows_sql':
  features            => 'SQL,RS_SHP,RS_SHPWFE,TOOLS',
  pid                 => 'SYOUR-PRODU-CTKEY-OFSQL-2012S',
  sqlsysadminaccounts => 'SQLAdmin',
  agtsvcaccount       => 'svc_sqlagt',
  isopath             => 'C:\\Users\\Administrator\\Desktop\\SQLServer2012SP1-FullSlipstream-ENU-x64.iso',
  sqlsvcaccount       => 'svc_sqlsvc',
  securitymode        => 'sql',
  sapwd               => 'MySup3rGre@tp@ssw0rDO3nOT',
  mode                => 'master',
}
```
### Parameters 

Complete list and parameter options can be found on [MSDN](http://msdn.microsoft.com/en-us/library/ms144259(v=sql.110).aspx)
```
SQL
	action              # Default Install. For now only Install, Uninstall action works
	features            # list of feature that should be install
	pid                 # product key. Default its empty.
	agtsvcaccount       # svc account for sql agt
	agtsvcpassword      # his password
	agtsvcstartuptype   # Startup. Default Automatic
	sqlpath             # install dir of SQL
	isopath             # iso path of SQL iso. Need [jriviere/windows_isos](https://forge.puppetlabs.com/jriviere/windows_isos) puppet module
	securitymode        # if SQL is supply sapwd is mandatory
	sapwd               # local admin of sql
	instancename        # instancename. Default MSSQLSERVER
	instanceid          # instanceid
	instancedir         # instancedir
	sqltempdbdir        # Default empty so, will use the default path of provide by sql
	sqltempdblogdir     # Default empty so, will use the default path of provide by sql
	sqluserdbdir        # Default empty so, will use the default path of provide by sql
	sqluserdblogdir     # Default empty so, will use the default path of provide by sql
	
	rssvcaccount        # When you provide one of this, specific options will be available.
	issvcaccount        # This 3, have same default account parameters as agtsvcpassword.
	assvcaccount        # If their features are provide and you don't provide them account, an error will occur.


Common parameter (default value)
	action                       # Install
	enu                          # true
	quiet                        # false
	quietsimple                  # true
	uimode                       # empty
	help                         # false
	indicateprogress             # false
	x86                          # false
	sqmreporting                 # false
	errorreporting               # false
	$sqlcollation                # Latin1_General_CI_AS
	tcpenabled                   # 1
	npenabled                    # 0
	browsersvcstartuptype        # Disabled
	iacceptsqlserverlicenseterms # true
	enableranu                   # false
	filestreamlevel              # 0
	forcerestart                 # Default : true
 

Other parameter
	configurationfile  # path of configurationfile.ini. Default C:\\configurationfile.ini
	userxml            # path of users.xml file created by [jriviere/windows_ad](https://forge.puppetlabs.com/jriviere/windows_ad) module. Default C:\\users.xml
	isopath            # Full iso path
	sqlpath            # for Drive use E:\\, for directory use C:\SQL where SQL is the folder that contains setup.exe
	mode               # the way how you want to deploy SQL, by using a master or only a agent. Default value agent.
```	

##Plan Backup JOB
Resource: windows_sql::maintenanceplan::backup
```
	windows_sql::maintenance::backup{'full':
	  backuptype   => 'FULL',
	  databases    => 'USER_DATABASES',
	  servername   => 'srvsql01',
	  jobname      => 'Full Backup - USER_Databases',
	  scheduletime => '021900',
	  schedulename => 'Daily Backup - Backup',
	  freq_type    => 'Daily'
	}
	windows_sql::maintenance::integritycheck{'integrity':
	  noindex      => 'N',
	  databases    => 'USER_DATABASES',
	  servername   => 'srvsql01',
	  jobname      => 'Check Integrity - USER_DATABASES',
	  scheduletime => '021100',
	  schedulename => 'Daily Backup - Integrity',
	  freq_type    => 'Daily'
	}
	windows_sql::maintenance::indexoptimize{'indexop':
	  databases    => 'USER_DATABASES',
	  servername   => 'srvsql01',
	  jobname      => 'Index Optimize - USER_DATABASES',
	  scheduletime => '023000',
	  schedulename => 'Daily Backup - Index Optimize',
	  freq_type    => 'Daily'
	}
	windows_sql::maintenance::deletebackuphistory{'delete':
	  servername   => 'srvsql01',
	  jobname      => 'Delete Backup History',
	  scheduletime => '030000',
	  schedulename => 'Daily Backup - Delete History',
	  freq_type    => 'Daily'
	}
```
Parameters:
```
	$databases           # Database to maintain
	$directory           # Directory to save backup
	$backuptype          # FULL, LOG, DIFF. Default FULL
	$verify              # 'N' or 'Y'
	$compress            # 'Y' or 'N'
	$servername          # 
	$fragmentationlow    # 'NULL',
	$fragmentationmedium # 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	$fragmentationhigh   # 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	$fragmentationlevel1 # 5,
	$fragmentationlevel2 # 30,
	$noindex             # 'N' or 'Y', don't create index ?
	$checkcommands       # List of Available commands on ola hallengren site
	$scriptpath          # Where to save the maintenance script. Default C:\\Puppet-SQL
	$jobname             # Job Name
	$scheduletime        # Time to execute ex : 020000 -> exec at 02am
	$schedulename        # Scheduled name
	$freq_type           # Can be once, daily, Weekly, Monthly
	$freq_freq_interval  # Can be empty or any days of the week
	$daystokeep          # Number of days to keep backup. Default 7 (one week).
```

## Known issues

If you declare the users with windows_ad::users in the same manifest of windows_sql Class, a error will occur and will inform you that you haven't provide a password.
You need to declare your users first and then declare your SQL class (users must exist in AD before calling SQL class). 

License
-------
Apache License, Version 2.0

Contact
-------
[Jerome RIVIERE](https://github.com/ninja-2)

Support
-------
Please log tickets and issues on [GitHub](https://github.com/insentia/windows_sql/issues)
