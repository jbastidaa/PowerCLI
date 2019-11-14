$vms = Get-VM
$report = @()
$report = foreach ($vm in $vms){
$vm | Select-Object @{N='VM';E={$vm.name}}, @{N='UptimeDias';E={(($vm.ExtensionData.Summary.QuickStats.UptimeSeconds/60)/60)/24}} , @{N='UptimeFecha';E={$vm.ExtensionData.Summary.Runtime.BootTime.DateTime}}
}
$report | Export-Csv uptime-vm01.csv -NoTypeInformation
