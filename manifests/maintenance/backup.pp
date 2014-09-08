define windows_sql::maintenance::backup(
  $databases           = 'USER_DATABASES',
  $directory           = "C:\\Backups\\SQL",
  $backuptype          = 'FULL',
  $verify              = 'N',
  $compress            = 'Y',
  $cleanuptime         = '',
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
  validate_re($backuptype, '^(FULL|DIFF|LOG)$', 'valid values for backuptype are \'FULL\' or \'DIFF\' or \'LOG\'')
  if(empty($directory)){
    fail('You need to provide a directory path.')
  }
  validate_re($verify, '^(Y|N)$', 'valid values for verify are \'Y\' or \'N\'')
  validate_re($compress, '^(Y|N)$', 'valid values for compress are \'Y\' or \'N\'')
  
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
  if (!defined(File["$scriptpath\\DatabaseBackup.sql"])){
    file{"$scriptpath\\DatabaseBackup.sql":
      source             => "puppet:///modules/windows_sql/DatabaseBackup.sql",
      source_permissions => ignore,
      notify             => Exec['OLAHALLENGREN DatabaseBackup script'],
    }
    exec{"OLAHALLENGREN DatabaseBackup script":
      command     => "invoke-sqlcmd -inputfile \"$scriptpath\\DatabaseBackup.sql\" -serverinstance ${servername}",
      provider    => "powershell",
      timeout     => 600,
      refreshonly => true,
    }
  }
  if (!defined(File["${scriptpath}\\backup-${databases}-${backuptype}.sql"])){
    file{"${scriptpath}\\backup-${databases}-${backuptype}.sql":
      content    => template('windows_sql/BackupDatabase.sql.erb'),
      notify     => Exec["Backup - $databases - $backuptype"],
      require    => File["$scriptpath\\DatabaseBackup.sql"],
    }
    exec{"Backup - $databases - $backuptype":
      command     => "invoke-sqlcmd -inputfile \"${scriptpath}\\backup-${databases}-${backuptype}.sql\" -serverinstance ${servername}",
      provider    => "powershell",
      timeout     => 600,
      refreshonly => true,
    }
  }
}