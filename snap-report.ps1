$vms = Get-VM #(Get-Content -Path vms.txt) 
$reporte = @()
$i=1
#$j=1
$reporte = foreach($vm in $vms){
              Write-Progress -Activity "Obteniendo información de la maquina $vm" -Status "Maquina $i de $($vms.Count)" -PercentComplete (($i / $vms.Count) * 100)  
               $DSS = Get-Datastore -RelatedObject $vm
               foreach($DS in $DSS){
                   $vm | Select @{Label="VMName";Expression={$_.name}}, ToolsVersion, ToolsVersionStatus, version, @{Label="#Snapshots";Expression={(Get-Snapshot -VM $_ | Measure-Object).Count}}, @{Label="GBTotal Snapshot";Expression={(Get-Snapshot -VM $_ | Measure-Object -Sum SizeGb).Sum}}, @{Label="Fecha de Creacion Snapshot";Expression={(Get-Snapshot -VM $_).Created}} , @{Label="Datastore";Expression={$DS.name}}, @{Label="EspacioLibre Datastore";Expression={$DS.FreeSpaceGB}}, @{Label="TamañoDatastore";Expression={$DS.CapacityGB}}, @{Label="% Libre Datastore";Expression={($DS.FreeSpaceGB*100)/$DS.CapacityGB}}
                                      }
               $i++
                }
$reporte | export-csv -Path snapreportSPAC.csv -NoTypeInformation