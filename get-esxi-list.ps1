$clusters = Get-Cluster
$reporte = @()
$reporte = foreach ($clu in $clusters){
                $vhosts = $clu | Get-VMHost
                foreach($vhost in $vhosts){
                    $vhost | select @{Label="ESXi";Expression={$_.name}},@{Label="Cluster";Expression={$clu}}, ConnectionState, PowerState, CpuUsageMhz, MemoryUsageGB, CpuTotalMhz, MemoryTotalGB
                }
           }
$reporte | Export-Csv -Path esxi.csv -NoTypeInformation