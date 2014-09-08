class windows_sql::autocomplete(
$agtsvcaccount  = $windows_sql::params::agtsvcaccount,
$agtsvcpassword = $windows_sql::params::agtsvcpassword,
$sqlsvcaccount  = $windows_sql::params::sqlsvcaccount,
$sqlsvcpassword = $windows_sql::params::sqlsvcpassword,
$rssvcaccount   = $windows_sql::params::rssvcaccount,
$rssvcpassword  = $windows_sql::params::rssvcpassword,
$issvcaccount   = $windows_sql::params::issvcaccount,
$issvcpassword  = $windows_sql::params::issvcpassword,
$assvcaccount   = $windows_sql::params::assvcaccount,
$assvcpassword  = $windows_sql::params::assvcpassword,
$userxml        = $windows_sql::params::userxml,
){
  if(!empty($agtsvcaccount)){
    if(!empty($agtsvcpassword)){
      $agtpwd = $agtsvcpassword
    }else{
      $agtpwd = get_password($agtsvcaccount,$userxml)
    }
  }
  if(!empty($sqlsvcaccount)){
    if(!empty($sqlsvcpassword)){
      $sqlpwd = $sqlsvcpassword
    }else{
      $sqlpwd = get_password($sqlsvcaccount,$userxml)
    }
  }
  if(!empty($rssvcaccount)){
    if(!empty($rssvcpassword)){
      $rspwd = $rssvcpassword
    }else{
      $rspwd = get_password($rssvcaccount,$userxml)
    }
  }
  if(!empty($issvcaccount)){
    if(!empty($issvcpassword)){
      $ispwd = $issvcpassword
    }else{
      $ispwd = get_password($issvcaccount,$userxml)
    }
  }
  if(!empty($assvcaccount)){
    if(!empty($assvcpassword)){
      $aspwd = $assvcpassword
    }else{
      $aspwd = get_password($assvcaccount,$userxml)
    }
  }
}