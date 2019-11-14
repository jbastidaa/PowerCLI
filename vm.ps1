$vms = Get-VM tqidndevlagsc06
foreach ($vm in $vms)
    {
        $vm
        $vm | Get-HardDisk | select name,capacityGB, ConnectionState, Filename
        $vm | Get-NetworkAdapter | Select-Object @{N="VM";E={$_.Parent.Name}},@{N="NIC";E={$_.Name}},@{N="Network";E={$_.NetworkName}}
    }