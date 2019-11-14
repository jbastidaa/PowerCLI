$vms = get-vm (Get-Content -Path vms.txt)
$i=1
$reporte = @()
$reporte += foreach($vm in $vms){
                $vm | select name, memoryGB, @{N="TamañoGB";E={(Get-HardDisk -vm $vm | Measure-Object -Sum capacityGB).sum}}
                Write-Progress -Activity "Calculando el tamaño total de los discos de $vm" -Status "Maquina $i de $($vms.Count)" -PercentComplete (($i / $vms.Count) * 100)  
                $i++
                }
$reporte | Export-Csv -Path discos.csv -NoTypeInformation