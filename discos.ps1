$vms= Get-Content -Path vms.txt
$report = @()
$i=1
$report +=  foreach($vm in $vms){
             $vm | Select @{N='Nombre';E={$vm}} ,memoryGB, name, @{N='RAM';E={$_.memoryGB}} ,@{N="TamañoGB";E={(Get-HardDisk -vm $vm | Measure-Object -Sum capacityGB).sum}}
             Write-Progress -Activity "Calculando el tamaño total de los discos de $vm" -Status "Maquina $i de $($vms.Count)" -PercentComplete (($i / $vms.Count) * 100)  
             $i++
               }
$report | Export-Csv -Path discos.csv -NoTypeInformation
