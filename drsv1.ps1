$rules = get-cluster | get-drsrule
$reporte = @()
$reporte = foreach ($rule in $rules){
             get-vm -id $rule.vmids | Select-Object Name, @{N='Cluster';E={$rule.cluster}}, @{N='Regla';E={$rule.name}} 
	                 }
$reporte | Export-Csv drs.csv -NoTypeInformation