$datastores = get-datastore (Get-Content -Path datastores.txt)
$reporte=@()
$reporte = foreach($ds in $datastores){
              $ds | Select-Object @{N="Nombre";E={$ds.name}},@{N="NAA";E={$_.ExtensionData.Info.Vmfs.Extent[0].DiskName}}
              }
$reporte | Export-Csv -Path DS-NAA.csv -NoTypeInformation