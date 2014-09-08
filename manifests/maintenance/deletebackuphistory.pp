define windows_sql::maintenance::deletebackuphistory(
  $servername          = '',
  $daystokeep          = 7,
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
  if(empty($jobname)){
    fail('You need to provide a jobname')
  }
  if(empty($schedulename)){
    fail('You need to provide a schedulename')
  }
  if(empty($servername)){
    fail('You need to provide a servername. EX : srvsql01 or sqlsrv01\\msssqlserver if an instance is set. [protocol:]server[\\instance_name][,port]')
  }

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
  if (!defined(File["${scriptpath}\\DeleteBackupHistory.sql"])){
    file{"${scriptpath}\\DeleteBackupHistory.sql":
      content    => template('windows_sql/DeleteBackupHistory.sql.erb'),
      notify     => Exec["DeleteBackupHistory"],
    }
    exec{"DeleteBackupHistory":
      command     => "invoke-sqlcmd -inputfile \"${scriptpath}\\DeleteBackupHistory.sql\" -serverinstance ${servername}",
      provider    => "powershell",
      timeout     => 600,
      refreshonly => true,
    }
  }
}