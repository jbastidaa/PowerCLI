$vms = Get-VM (get-content -path vms.txt)
$report = @()
$report = foreach ($vm in $vms){
$vm | Select-Object @{N='VM';E={$vm.name}}, @{N='Uptime';E={$vm.ExtensionData.Summary.QuickStats.UptimeSeconds}} 
}
$report | Export-Csv uptime-vm.csv -NoTypeInformation
