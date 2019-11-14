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
$report = @()
Write-Host "$(Get-Date)" -ForegroundColor Green
Write-Host "                  vCenter" -ForegroundColor "Green"
Write-Host "------------------------------------------------------------------------------------------------------" 
Write-Host "vCenter: $($global:defaultviserver.name)" -NoNewline
Write-Host "   Version: $($global:defaultviserver.Version)" -NoNewline
Write-Host "   Build: $($global:defaultviserver.Build)" -NoNewline
Write-Host "   User: $($global:defaultviserver.user)"
Write-Host "------------------------------------------------------------------------------------------------------" 
Write-Host "                  Hosts" -ForegroundColor "Green"
Write-Host "------------------------------------------------------------------------------------------------------" 
Write-Host "Totales : $($vhosts.Count)" -NoNewline
Write-Host "   Conectados : $(($vhosts | where {$_.ConnectionState -eq "Connected"}).count)" -ForegroundColor Green -NoNewline
Write-Host "   Modo Mantenimiento : $(($vhosts | where {$_.ConnectionState -eq "Maintenance"}).count)" -ForegroundColor Yellow -BackgroundColor Blue -NoNewline
Write-Host "   Desconectados : $(($vhosts | where {$_.ConnectionState -eq "Disconnected"}).count)" -ForegroundColor Magenta -NoNewline
Write-Host "   Not Responding : $(($vhosts | where {$_.ConnectionState -eq "Notresponding"}).count)" -ForegroundColor Red -BackgroundColor Black   
Write-Host "------------------------------------------------------------------------------------------------------" 
Write-Host "                  Interfaces de Red Down de los Hosts" -ForegroundColor "Yellow"
   foreach ($vhost in (get-vmhost $vhosts)){
             $esxcli = $vhost | get-esxcli -v2
             $esxcli.network.nic.list.Invoke() | where {$_.Link -eq "Down"} | Select @{Label="ESXi";Expression={$vhost.Name}}, name, macaddress
          }
#Write-Host "$report"
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
Write-Host "   Datastores Normales: $(($Datastores | where {$_.ExtensionData.OverallStatus -eq "Green"}).count)" -NoNewline
Write-Host "   Datastores con warnings: $(($Datastores | where {$_.ExtensionData.OverallStatus -eq "Yellow"}).count)" -NoNewline
Write-Host "   Datastores con alarmas: $(($Datastores | where {$_.ExtensionData.OverallStatus -eq "Red"}).count)"
Write-Host "   Datastores con problemas de espacio"
$($Datastores | where {$_.ExtensionData.OverallStatus -eq "Red" -and $_.FreeSpaceGB -lt 500})
Write-Host "------------------------------------------------------------------------------------------------------" 
Write-Host "                  Templates" -ForegroundColor "Green"
Write-Host "------------------------------------------------------------------------------------------------------" 
Write-Host "Totales : $($templates.count)" -NoNewline
Write-Host "   Linux Flavor : $($linux_flavor.count)" -NoNewline
Write-Host "   Windows : $($windows_flavor.count)"
Write-Host "------------------------------------------------------------------------------------------------------"

 