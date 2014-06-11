windows_sql

This is the windows_sql puppet module.


##Description

This module allows you to generate and install SQL Server 2012 on windows Server.

This module have been tested with SQL Server 2012 SP1 on Windows Server 2012 R2

Should work, on Windows Server since 2012 and with SQL Server since 2012.


##Last Fix/Update
v 0.0.1 Module creation:
 - Read password from users.xml
 - Majority of sql installation parameters is available (based on [MSDN](http://msdn.microsoft.com/en-us/library/ms144259(v=sql.110).aspx))
 - Some verification are made for prevent bad use of variable.
 - You can use only Action Install, Uninstall. Others are not tested yet. Action RunDiscovery is used to test if SQL is already install or not

## Generate configurationfile.ini
Generate Microsoft SQL Server 2012 file configuration from parameters you define.
If you create your service account with [windows_ad module](https://forge.puppetlabs.com/jriviere/windows_ad) and his xml file before calling the windows_sql class the password for each service account will be automatically retrieve from the users.xml file, 
else you can provide manually your password.

The user domain doesn't need to be provided, it will be supplied by the $env:userdomain powershell variable for each service account variable (like AGTSVCACCOUNT) and SQLSYSADMINACCOUNTS

PS : since we can't reassign variable or access variable data inside a resource definition, 
it was mandatory to create template for retrieve password in xml for each SQL account we need :(.
If anyone have a idea to do that stuff with only one template it will be great.

##Setup Requirements
Depends on the following modules:
 - ['joshcooper/powershell', '>=0.0.6'](https://forge.puppetlabs.com/joshcooper/powershell),
 - ['puppetlabs/stdlib', '>= 4.2.1'](https://forge.puppetlabs.com/puppetlabs/stdlib).
 + Optional
   - ['jriviere/windows_isos', '>= 0.0.3'](https://forge.puppetlabs.com/jriviere/windows_isos) (if you supply $isopath variable),
   - ['jriviere/windows_ad', '>= 0.0.9'](https://forge.puppetlabs.com/jriviere/windows_ad)] (fill password automatically for each account specified with this module and with his xml file)

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
	isopath             # iso path of SQL iso. Need jriviere/windows_isos puppet module
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
 

Other parameter
	configurationfile # path of configurationfile.ini. Default C:\\configurationfile.ini
	userxml           # path of users.xml file created by jriviere/windows_ad module. Default C:\\users.xml
	isopath           # Full iso path
	sqlpath           # for Drive use E:\\, for directory use C:\SQL where SQL is the folder that contains setup.exe
```	
## Known issues

If you declare the users with windows_ad::users in the same manifest of windows_sql Class, a error will occur and will inform you that you haven't provide a password.
You need to declare your users first and then declare your SQL class (users must exist in AD before calling SQL class). 
	
License
-------
Apache License, Version 2.0

Contact
-------
[Jerome RIVIERE](http://www.jerome-riviere.re)

Support
-------
Please log tickets and issues on [GitHub](https://github.com/ninja-2/windows_sql/issues)
