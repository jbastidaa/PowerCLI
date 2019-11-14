$clus = get-cluster | Out-GridView -Title "Selecciona el cluster a Modificar" -OutputMode Multiple
foreach($clu in $clus){
    $vhosts = get-cluster $clu | get-vmhost
    foreach($vhost in $vhosts){
        Remove-VmHostNtpServer -NtpServer 10.55.40.40, 10.55.50.50 -VMHost $vhost -Confirm:$false
        Add-VmHostNtpServer -NtpServer "10.55.199.222" -VMHost $vhost -Confirm:$false
        Get-VMHostService -vmhost $vhost | where {$_.key -eq "ntpd"} | Stop-VMHostService -Confirm:$false
        Get-VMHostService -vmhost $vhost | where {$_.key -eq "ntpd"} | Start-VMHostService -Confirm:$false
        Get-VMHostService -vmhost $vhost | where {$_.key -eq "ntpd"} | Set-VMHostService -Policy "Automatic" -Confirm:$false
        }
    }



