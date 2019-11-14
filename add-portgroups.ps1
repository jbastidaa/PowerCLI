$ports = Import-Csv -Path .\portgroups.csv
$vds = Get-VDSwitch -Name "DVS-PRO-GestionHeartBeat"
foreach ($port in $ports){
   $vds | New-VDPortgroup -Name "vlan$($port.vlanid)APP_$($port.segmento)" -VLanId $port.vlanid
   $vds | New-VDPortgroup -Name "vlan$($port.vlanid)WEB_$($port.segmento)" -VLanId $port.vlanid
   $vds | New-VDPortgroup -Name "vlan$($port.vlanid)DBX_$($port.segmento)" -VLanId $port.vlanid
   }