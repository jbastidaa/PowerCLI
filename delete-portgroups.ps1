$i = 1
$j = 1
$vservers = Get-VMHost | Out-GridView -OutputMode Multiple
$vlans = import-csv  -path vlans.csv

foreach ($esx in $vservers){
	Write-Progress -Activity "Eliminando portgroups en ESXi" -Status ("Host: {0}" -f $esx.Name) -PercentComplete (($i / $vservers.Count) * 100)  -Id 0
        $i++
        foreach ($line in $vlans){
           $esx | get-virtualswitch -name vSwitch0 | get-virtualportgroup -name $line.Name | Remove-VirtualPortGroup -confirm:$false #-VirtualPortGroup $line.Name
           #New-VirtualPortGroup -VirtualSwitch ($esx | get-virtualswitch -name vSwitch0) -Name $line.Name -vlanid $line.vlanID
           Write-Progress -Activity "Eliminando portgroup en vSwitch" -Status ("Portgroup: {0}" -f $line.Name) -PercentComplete (($j / $vlans.Count) * 100) -Id 1
           $j++
        }
        $j=1
}