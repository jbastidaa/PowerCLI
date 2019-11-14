#variables
#$vms = Get-VM 
#$vms_off = $vms | where {$_.PowerState -eq "PoweredOff"}
#$vms_on = $vms | where {$_.PowerState -eq "PoweredOn"}
#$snaps = $vms | Get-Snapshot
#$templates = Get-Template
#$linux_flavor = $templates | where {$_.ExtensionData.Guest.GuestFullName -Like "*Linux*"}
#$windows_flavor = $templates | where {$_.ExtensionData.Guest.GuestFullName -Like "*Microsoft*"}
$vhosts = Get-VMHost
#$clusters = Get-Cluster
#$DCS = Get-Datacenter
#$Datastores = Get-Datastore
#Remove-Item errores.txt -Confirm:$false
$a =$defaultviserver | select name, version, build, user | ConvertTo-HTML -Title "Datos vCenter" -PreContent "<h3 style=color:Green;>Reporte vCenter $(get-date)</h3>"
$b =$vhosts | Select @{Label="Total";Expression={$vhosts.count}},@{Label="Conectados";Expression={($vhosts | where {$_.ConnectionState -eq "Connected"}).count}}, @{Label="Mantenimiento";Expression={($vhosts | where {$_.ConnectionState -eq "Maintenance"}).count}}, @{Label="Desconectados";Expression={($vhosts | where {$_.ConnectionState -eq "Disconnected"}).count}}, @{Label="Not Responding";Expression={($vhosts | where {$_.ConnectionState -eq "Notresponding"}).count}} -Unique | ConvertTo-HTML -Title "Datos Hosts" -PreContent "<h3>Hosts</h3>"
$c = $vhosts | where {$_.ConnectionState -eq "Notresponding"} | select Name, ConnectionState, PowerState | ConvertTo-HTML -Title "Hosts Not Responding" -PreContent "<h3>Hosts Not Responding</h3>"
$reporte = @()
   $reporte =foreach ($vhost in (get-vmhost $vhosts)){
      Try{
        $esxcli = $vhost | get-esxcli -v2 -erroraction ignore
        $esxcli.network.nic.list.Invoke() | where {$_.Link -eq "Down"} | Select @{Label="ESXi";Expression={$vhost.Name}}, name, macaddress, @{Label="Cluster";Expression={$vhost.parent}}, @{Label="State";Expression={$vhost.connectionstate}}
        }
      Catch{
        $ErrorMessage = $_.Exception.Message
        "Fallo la conexion al host $vhost con el mensaje: $errorMessage" >> errores.txt
        }
   }
$d = $reporte | ConvertTo-HTML -Title "Nics Down" -PreContent "<h3 style=color:red;>Interfaces de Red Down de los Hosts</h3>"
<#
Write-Host "------------------------------------------------------------------------------------------------------" 
Write-Host "                  Maquinas virtuales" -ForegroundColor "Green"
Write-Host "------------------------------------------------------------------------------------------------------"
Write-Host "Maquinas Totales : $($vms.count)" -NoNewline
Write-Host "   Maquinas Encendidas : $($vms_on.count)" -NoNewline
Write-Host "   Maquinas Apagadas : $($vms_off.count)"  
Write-Host "------------------------------------------------------------------------------------------------------"
Write-Host "                  Snapshots" -ForegroundColor "Green"
Write-Host "------------------------------------------------------------------------------------------------------" 
Write-Host "Totales : $($snaps.count)" 
Write-Host "Espacio Total usado en GB : $(($snaps | Measure-Object -Sum SizeGb).Sum)" 
Write-Host "------------------------------------------------------------------------------------------------------"
Write-Host "                  Datastores" -ForegroundColor "Green"
Write-Host "------------------------------------------------------------------------------------------------------" 
Write-Host "Datastores : $($Datastores.count)" -NoNewline
Write-Host "   Normales: $(($Datastores | where {$_.ExtensionData.OverallStatus -eq "Green"}).count)" -NoNewline
Write-Host "   warnings: $(($Datastores | where {$_.ExtensionData.OverallStatus -eq "Yellow"}).count)" -NoNewline
Write-Host "   alarmas: $(($Datastores | where {$_.ExtensionData.OverallStatus -eq "Red"}).count)"
Write-Host "Recuperando Datastores con problemas de espacio" -ForegroundColor "Yellow"
$($Datastores | where {$_.ExtensionData.OverallStatus -eq "Red" -and $_.FreeSpaceGB -lt 100} | Select Name, FreeSpaceGb, CapacityGB | Out-GridView -Title "Datastores con problemas de espacio. Menos de 100 GB")
Write-Host "------------------------------------------------------------------------------------------------------" 
Write-Host "                  Templates" -ForegroundColor "Green"
Write-Host "------------------------------------------------------------------------------------------------------" 
Write-Host "Totales : $($templates.count)" -NoNewline
Write-Host "   Linux Flavor : $($linux_flavor.count)" -NoNewline
Write-Host "   Windows : $($windows_flavor.count)"
Write-Host "------------------------------------------------------------------------------------------------------"
Invoke-Item errores.txt #>
ConvertTo-HTML -Title "Reporte de Infraestructura" -body "$a $b $c $d" -CSSUri "PSHtmlReport.css" | Set-Content "ReporteInfra.html"
Invoke-Item ReporteInfra.html