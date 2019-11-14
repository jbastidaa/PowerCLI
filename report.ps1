Add-Type -Path “$PSScriptRoot\itextsharp.dll”
Import-Module "$PSScriptRoot\PDF.psm1"
#variables
$vms = Get-VM 
$vms_off = $vms | where {$_.PowerState -eq "PoweredOff"}
$vms_on = $vms | where {$_.PowerState -eq "PoweredOn"}
$snaps = $vms | Get-Snapshot
$templates = Get-Template
$linux_flavor = $templates | where {$_.ExtensionData.Guest.GuestFullName -Like "*Linux*"}
$windows_flavor = $templates | where {$_.ExtensionData.Guest.GuestFullName -Like "*Microsoft*"}
$vhosts = Get-VMHost
#$clusters = Get-Cluster
#$DCS = Get-Datacenter
$Datastores = Get-Datastore
Remove-Item errores.txt -Confirm:$false -ErrorAction Ignore
$pdf = New-Object iTextSharp.text.Document
Create-PDF -Document $pdf -File "$PSScriptRoot\Reporte.pdf" -TopMargin 20 -BottomMargin 20 -LeftMargin 20 -RightMargin 20 -Author "$($global:defaultviserver.user)"
$pdf.Open()
Add-Title -Document $pdf -Text "Reporte de Infraestructura" -Color "Red" -Centered
Add-Text -Document $pdf -Text "$(Get-Date)" -Color blue
Add-Text -Document $pdf -Text "                  vCenter" -Color "blue"
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------" 
Add-Text -Document $pdf -Text "vCenter: $($global:defaultviserver.name)"  -Color blue
Add-Text -Document $pdf -Text "Version: $($global:defaultviserver.Version)"  -Color blue
Add-Text -Document $pdf -Text "Build: $($global:defaultviserver.Build)"  -Color blue
Add-Text -Document $pdf -Text "User: $($global:defaultviserver.user)" -Color blue
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------" 
Add-Text -Document $pdf -Text "                  Hosts" -Color "blue"
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------" 
Add-Text -Document $pdf -Text "Totales : $($vhosts.Count)" 
Add-Text -Document $pdf -Text "Conectados : $(($vhosts | where {$_.ConnectionState -eq "Connected"}).count)" -Color blue 
Add-Text -Document $pdf -Text "Modo Mantenimiento : $(($vhosts | where {$_.ConnectionState -eq "Maintenance"}).count)" -Color Black 
Add-Text -Document $pdf -Text "Desconectados : $(($vhosts | where {$_.ConnectionState -eq "Disconnected"}).count)" -Color Black 
Add-Text -Document $pdf -Text "Not Responding : $(($vhosts | where {$_.ConnectionState -eq "Notresponding"}).count)" -Color Black  
Add-Text -Document $pdf -Text "Hosts Not Responding  $($vhosts | where {$_.ConnectionState -eq "Notresponding"})" -Color Red 
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------" 
Add-Text -Document $pdf -Text "                  Interfaces de Red Down de los Hosts" -Color "Black"
   foreach ($vhost in (get-vmhost $vhosts)){
      Try{
        $esxcli = $vhost | get-esxcli -v2 -erroraction ignore
        Add-Text -Document $pdf -Text " $(($esxcli.network.nic.list.Invoke() | where {$_.Link -eq "Down"} | Select @{Label="ESXi";Expression={$vhost.Name}}, name, macaddress, @{Label="Cluster";Expression={$vhost.parent}}, @{Label="State";Expression={$vhost.connectionstate}}))"
        }
      Catch{
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        "Fallo la conexion al host $vhost con el mensaje: $errorMessage" >> errores.txt
        }
   }
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------" 
Add-Text -Document $pdf -Text "                  Maquinas virtuales" -Color "blue"
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------"
Add-Text -Document $pdf -Text "Total : $($vms.count)" 
Add-Text -Document $pdf -Text "Encendidas : $($vms_on.count)" 
Add-Text -Document $pdf -Text "Apagadas : $($vms_off.count)"  
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------"
Add-Text -Document $pdf -Text "                  Snapshots" -Color "blue"
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------" 
Add-Text -Document $pdf -Text "Totales : $($snaps.count)" 
Add-Text -Document $pdf -Text "Espacio Total usado en GB : $(($snaps | Measure-Object -Sum SizeGb).Sum)" 
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------"
Add-Text -Document $pdf -Text "                  Datastores" -Color "blue"
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------" 
Add-Text -Document $pdf -Text "Datastores : $($Datastores.count)" 
Add-Text -Document $pdf -Text "Normales: $(($Datastores | where {$_.ExtensionData.OverallStatus -eq "green"}).count)" 
Add-Text -Document $pdf -Text "Con warnings: $(($Datastores | where {$_.ExtensionData.OverallStatus -eq "Yellow"}).count)" 
Add-Text -Document $pdf -Text "Alarmados: $(($Datastores | where {$_.ExtensionData.OverallStatus -eq "Red"}).count)"
Add-Text -Document $pdf -Text "Datastores con problemas de espacio. Menos de 100 GB" -Color "Black"
foreach($ds in $datastores){
  if($ds.ExtensionData.OverallStatus -eq "Red" -and $ds.FreeSpaceGB -lt 100){
     Add-Text -Document $pdf -Text "$(($ds | Select Name, FreeSpaceGb, CapacityGB))"
     }
   }
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------" 
Add-Text -Document $pdf -Text "                  Templates" -Color "blue"
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------" 
Add-Text -Document $pdf -Text "Totales : $($templates.count)" 
Add-Text -Document $pdf -Text "Linux Flavor : $($linux_flavor.count)" 
Add-Text -Document $pdf -Text "Windows : $($windows_flavor.count)"
Add-Text -Document $pdf -Text "------------------------------------------------------------------------------------------------------"
$pdf.Close()
Invoke-Item errores.txt