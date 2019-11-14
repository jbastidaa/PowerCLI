$vhosts = Get-VMHost
$reporte = @()
$reporte = foreach($vhost in $vhosts){
   $vhosts | select @{N='Esxi';E={$vhost.name}}, @{N='NTP Actual';E={$vhost | Get-VMHostNtpServer}}
   }
$reporte | Export-Csv -Path NTPSENHA14.csv -NoTypeInformation