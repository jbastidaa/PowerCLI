$i = 1
$j = 1
$vservers = get-cluster | Out-GridView -OutputMode Single | Get-VMHost | Out-GridView -OutputMode Multiple
$vlans = import-csv  -path vlans.csv

foreach ($esx in $vservers){
	Write-Progress -Activity "Creando portgroups en ESX : $esx" -Status "ESXi $i de $($vservers.Count)" -PercentComplete (($i / $vservers.Count) * 100)  
        $i++
        foreach ($line in $vlans){
                New-VirtualPortGroup -VirtualSwitch ($esx | get-virtualswitch -name $line.vSwitch) -Name "STD_$($line.Portgroup)" -vlanid $line.vlanID
                Write-Progress -Activity "Creando portgroup : $line.Portgroup" -Status "Portgroup $j de $($vlans.Count)" -PercentComplete (($j / $vlans.Count) * 100)  
                $j++
        }
}