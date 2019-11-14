$clusters = Get-Cluster | Out-GridView -Title "Selecciona el cluster" -OutputMode Multiple
$i = 0
$j = 0
$l= 0
$reporte = @()
$reporte = foreach ($cluster in $clusters){
               Write-Progress -Activity "Recuperando informacion del cluster" -Status ("Cluster: {0}" -f $cluster.Name) -PercentComplete (($j / $clusters.Count) * 100)  -Id 0
               $vhosts = $cluster | Get-VMHost
               $j++
                  foreach ($vhost in $vhosts){
                     Write-Progress -Activity "Recuperando switches del ESXi" -Status ("Host: {0}" -f $vhost.Name) -PercentComplete (($i / $vhosts.Count) * 100)  -Id 1
                     $switches = $vhost | Get-VirtualSwitch
                     $i++ 
                     foreach ($switch in $switches){
                        Write-Progress -Activity "Recuperando Portgroups del Switch" -Status ("Switch: {0}" -f $switch.Name) -PercentComplete (($l / $switches.Count) * 100)  -Id 2
                        $switch | get-virtualPortgroup | select name, vlanid, @{Label="ESXi";Expression={$vhost.Name}}, @{Label="Cluster";Expression={$cluster.Name}}
                        $l++
                     }
                     $l = 0 
                  }
                  $i=0
               }
 $reporte | Export-Csv -Path switches.csv -NoTypeInformation