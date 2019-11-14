$clus = get-cluster
$reporte = @()
$reporte = foreach ($clu in $clus){
            $rules = $clu | get-drsrule
	        foreach ($rule in $rules){
	          $vms = $rule | select vmids
              foreach ($vm in $vms){
                get-vm -id $vm | Select-Object @{N='VM';E={$_.name}}, @{N='Cluster';E={$clu.name}}, @{N='Regla';E={$rule.name}}
              }
            }
          }
$reporte | Export-Csv drs.csv -NoTypeInformation