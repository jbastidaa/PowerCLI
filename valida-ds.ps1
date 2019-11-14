$clus = Get-Cluster 
$ds = get-content -Path ds.txt
foreach ($clu in $clus){
   Write-host "------------------------------"
   Write-host "|"        $clu.name   "|"                   
   Write-host "------------------------------"
   foreach ($d in $ds){
      if ($clu | get-datastore $d -ErrorAction Ignore){
         Write-Host "Datastore $d esta en el cluster $clu" -ForegroundColor "Green"
         }
      }
    }
