define windows_sql::maintenance::integritycheck(
  $databases           = 'USER_DATABASES',
  $directory           = "C:\\Backups\\SQL",
  $noindex             = 'N',
  $checkcommands       = 'CHECKDB',
  $servername          = '',
  $jobname             = '',
  $schedulename        = '',
  $scheduletime        = '021200',
  $freq_type           = 'Daily',
  $freq_interval       = '',
  $scriptpath          = 'C:\\Puppet-SQL',
){
  if($freq_type == 'Once'){
    $freq_type_code = 1
  }
  elsif($freq_type == 'Daily'){
    $freq_type_code = 4
  }
  elsif($freq_type == 'Weekly'){
    $freq_type_code = 32
  }
  elsif($freq_type == 'Monthly'){
    $freq_type_code = 16
  }else{
    fail('This freq_type is not correct. Please use Daily, Weekly, Monthly, Cnce')
  }
  
  if($freq_interval == 'Sunday'){
    $freq_interval_code = 1
  }
  elsif($freq_interval == 'Monday'){
    $freq_interval_code = 2
  }
  elsif($freq_interval == 'Tuesday'){
    $freq_interval_code = 3
  }
  elsif($freq_interval == 'Wednesday'){
    $freq_interval_code = 4
  }
  elsif($freq_interval == 'Thursday'){
    $freq_interval_code = 5
  }
  elsif($freq_interval == 'Friday'){
    $freq_interval_code = 6
  }
  elsif($freq_interval == 'Saturday'){
    $freq_interval_code = 7
  }
  elsif($freq_interval == ''){
    $freq_interval_code = 1
  }else{
    fail('You doesnt provide a correct freq_interval')
  }

  if(empty($databases)){
    fail('You need to provide a database or a set of databases. Ex : USER_DATABASES, SYSTEM_DATABASES, ALL_DATABASES, or a database name')
  }
  if(empty($jobname)){
    fail('You need to provide a jobname')
  }
  if(empty($schedulename)){
    fail('You need to provide a schedulename')
  }
  if(empty($servername)){
    fail('You need to provide a servername. EX : srvsql01 or sqlsrv01\\msssqlserver if an instance is set. [protocol:]server[\\instance_name][,port]')
  }
  
  validate_re($noindex, '^(Y|N)$', 'valid values for noindex are \'Y\' or \'N\'')
  
  if(!defined(File["$scriptpath"])){
    file{"$scriptpath":
      ensure => 'directory',
    }
  }
  if (!defined(File["$scriptpath\\CommandExecute.sql"])){
    file{"$scriptpath\\CommandExecute.sql":
      source             => "puppet:///modules/windows_sql/CommandExecute.sql",
      source_permissions => ignore,
      notify             => Exec['OLAHALLENGREN CommandExecute script'],
    }
    exec{"OLAHALLENGREN CommandExecute script":
      command     => "invoke-sqlcmd -inputfile \"$scriptpath\\CommandExecute.sql\" -serverinstance ${servername}",
      provider    => "powershell",
      timeout     => 600,
      refreshonly => true,
    }
  }
  
  if (!defined(File["$scriptpath\\DatabaseIntegrityCheck.sql"])){
    file{"$scriptpath\\DatabaseIntegrityCheck.sql":
      source             => "puppet:///modules/windows_sql/DatabaseIntegrityCheck.sql",
      source_permissions => ignore,
      notify             => Exec['OLAHALLENGREN DatabaseIntegrityCheck script'],
    }
    exec{"OLAHALLENGREN DatabaseIntegrityCheck script":
      command     => "invoke-sqlcmd -inputfile \"$scriptpath\\DatabaseIntegrityCheck.sql\" -serverinstance ${servername}",
      provider    => "powershell",
      timeout     => 600,
      refreshonly => true,
    }
  }
  if (!defined(File["${scriptpath}\\integrity-${databases}-${checkcommands}.sql"])){
    file{"${scriptpath}\\integrity-${databases}-${checkcommands}.sql":
      content    => template('windows_sql/DatabaseIntegrityCheck.sql.erb'),
      notify     => Exec["Integrity - $databases - $checkcommands"],
      require    => File["$scriptpath\\DatabaseIntegrityCheck.sql"],
    }
    exec{"Integrity - $databases - $checkcommands":
      command     => "invoke-sqlcmd -inputfile \"${scriptpath}\\integrity-${databases}-${checkcommands}.sql\" -serverinstance ${servername}",
      provider    => "powershell",
      timeout     => 600,
      refreshonly => true,
    }
  }
}