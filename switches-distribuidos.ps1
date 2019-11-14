$clusters = Get-Cluster | Out-GridView -Title "Selecciona el cluster" -OutputMode Multiple
$j = 0
foreach ($cluster in $clusters){
   Write-Progress -Activity "Recuperando informacion del cluster" -Status ("Cluster: {0}" -f $cluster.Name) -PercentComplete (($j / $clusters.Count) * 100)  -Id 0
   mkdir $cluster
   $vhosts = $cluster | Get-VMHost
   $i = 0
   $reporte = @()
      foreach ($vhost in $vhosts){
         Write-Progress -Activity "Recuperando portgroups del ESXi" -Status ("Host: {0}" -f $vhost.Name) -PercentComplete (($i / $vhosts.Count) * 100)  -Id 1
         $reporte = $vhost | Get-VirtualSwitch -name vswitch0 | get-virtualPortgroup | select name, vlanid, @{Label="ESXi";Expression={$vhost.Name}}
         $reporte | Export-Csv -Path $cluster'/'$vhost.csv -NoTypeInformation
         Clear-Variable reporte
         $i++ 
      }
   $i = 0
   $j++
   }