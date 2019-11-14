$vhosts = Get-Cluster tqclapp36_temporal | get-vmhost
$ds = get-content -Path ds.txt
foreach ($vhost in $vhosts){
   Write-host "------------------------------"
   Write-host "|"        $vhost.name   "|"                   
   Write-host "------------------------------"
   foreach ($d in $ds){
      if ($vhost | get-datastore $d -ErrorAction Ignore){
         Write-Host "Datastore $d OK" -ForegroundColor "Green"}
      else{
         Write-Host "Datastore $d BAD" -ForegroundColor "Red"}
   }
}
