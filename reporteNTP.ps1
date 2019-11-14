$vhosts = Get-VMHost
$reporte = @()
$reporte = foreach($vhost in $vhosts){
   $vhost | select @{N='Esxi';E={$vhost.name}}, @{N='NTP Actual';E={Get-VMHostNtpServer -VMHost $vhost}}
   }
$reporte | Export-Csv -Path NTPSPAC.csv -NoTypeInformation