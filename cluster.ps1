Try
{
    $vms = get-vm (get-content -path vms.txt)
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    "Fallaron las maquinas $FailedItem. El error fue $ErrorMessage"
}
$reporte = @()
$reporte = foreach ($vm in $vms){
	   $PGS = $vm | Get-VirtualPortGroup
	foreach ($PG in $PGS){
	$vm |Select-Object @{N='VM';E={$vm.name}}, NumCPu, MemoryGB, @{N='Cluster';E={$vm.vmhost.parent}}, @{N='ESXi';E={$vm.vmhost}}, @{N='PortGroup';E={$PG.name}}, Version
	}
}
$reporte | Export-csv -path VMs-PortGroups.csv -NoTypeInformation