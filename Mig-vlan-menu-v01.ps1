function Show-Menu
{
    param (
        [string]$Title = 'Aca las tortas'
    )
    Clear-Host
    Write-Host "================ $Title ================" -ForegroundColor "Blue"
    
    Write-Host "1:  Desconectar Uplink DVS y conectar a vSwitch." -ForegroundColor "Green"
    Write-Host "2:  Cambiar portgroup  VDS a VSS." -ForegroundColor "Green"
    Write-Host "3:  Cambiar portgroup  VSS a VDS." -ForegroundColor "Green"
    Write-Host "4:  Realizar vMotion." -ForegroundColor "Green"
    Write-Host "5:  Deshabilitar vMotion y habilitarlo en Management." -ForegroundColor "Green"
    Write-Host "6:  Deshabilitar HA y DRS en el cluster." -ForegroundColor "Green"
    Write-Host "S:  Salir." -ForegroundColor "Green"
}
do
{
    Show-Menu -Title 'Migracion'
    $selection = Read-Host "Selecciona una opcion"
    switch ($selection)
    {
        '1' {
            Write-Host "Desconectar Uplink DVS PRODUCCION y conectar a vSwitch." -ForegroundColor "Green"
            Get-cluster | Out-GridView -OutputMode Multiple | Get-VMhost | Get-VMHostNetworkAdapter -Physical -Name "vmnic1" | Remove-VDSwitchPhysicalNetworkAdapter
            $vhosts= Get-Cluster | Out-GridView -OutputMode Multiple | Get-VMHost
            foreach($esx in $vhosts){
                Get-VMHost $esx | Get-VirtualSwitch -name vSwitch2 | Set-VirtualSwitch -Nic vmnic1
            }
            
            Write-Host "Desconectar Uplink DVS NAS y conectar a vSwitch." -ForegroundColor "Blue"
            Get-cluster | Out-GridView -OutputMode Multiple | Get-VMhost | Get-VMHostNetworkAdapter -Physical -Name "vmnic5" | Remove-VDSwitchPhysicalNetworkAdapter
            foreach($esx in $vhosts){
                Get-VMHost $esx | Get-VirtualSwitch -name vSwitch3 | Set-VirtualSwitch -Nic vmnic5
            }
            
        } '2' {
            Write-Host "Cambiar portgroup  VDS a VSS." -ForegroundColor "Green"
            $portVDS=(Get-Content -Path portVDS.txt)
            $vmsVDS=get-vm (get-content -path VDSVM.txt)
            foreach($pVDS in $portVDS){
                foreach($vmVDS in $vmsVDS){
		        Write-Host "Modificando $vmVDS ..." -ForegroundColor "yellow"
                $vmVDS  | Get-NetworkAdapter | Where-Object {$_.NetworkName -eq $pVDS } | Set-NetworkAdapter -NetworkName "STD_$pVDS" -Confirm:$false
                }
            }
            Clear-Variable portVDS
            Clear-Variable vmsVDS
        } '3' {
            Write-Host "Cambiar portgroup  VSS a VDS." -ForegroundColor "Green"
            $portVDS=(Get-Content -Path portVDS.txt)
            $vmsVSS=get-vm (get-content -path VSSVM.txt)
            foreach($pVDS in $portVDS){
                foreach($vmVSS in $vmsVSS){
                Write-Host "Modificando $vmVSS ..." -ForegroundColor "yellow"
                $vmVSS  | Get-NetworkAdapter | Where-Object {$_.NetworkName -eq "STD_$pVDS"} | Set-NetworkAdapter -NetworkName $pVDS -Confirm:$false
                }
            }
            Clear-Variable portVDS
            Clear-Variable vmsVSS
        } '4' {
            Write-Host "Realizar vMotion." -ForegroundColor "Green"
            Get-VM -Name (get-content -path vssVM.txt) | move-vm –destination (get-cluster | Out-GridView -OutputMode Single | Get-VMHost | Out-GridView -OutputMode Single)
        } '5' {
            Write-Host "Deshabilitar vMotion y habilitarlo en Management." -ForegroundColor "Green"
            Write-Host "Deshabilitar vMotion." -ForegroundColor "Yellow"
            Get-Cluster | Out-GridView -Title "Selecciona el cluster" -OutputMode Single | Get-VMHost | Out-GridView -OutputMode Multiple | Get-VMHostNetworkAdapter -VMKernel | Where-Object {$_.portgroupname -eq "vmotion"} | Set-VMHostNetworkAdapter -VMotionEnabled $false
            Write-Host "Habilitar vMotion en Management." -ForegroundColor "Yellow"
            Get-Cluster | Out-GridView -Title "Selecciona el cluster" -OutputMode Single | Get-VMHost | Out-GridView -OutputMode Multiple | Get-VMHostNetworkAdapter -VMKernel | Where-Object {$_.portgroupname -eq "Management network"} | Set-VMHostNetworkAdapter -VMotionEnabled $True
        } '6' {
            Write-Host "Deshabilitar HA y DRS en el cluster." -ForegroundColor "Green"
            Get-Cluster | Out-GridView -Title "Selecciona el cluster" -OutputMode Single | Set-Cluster -HAEnabled $false -DrsEnabled $false -Confirm:$false
        }
    }
    pause
}
until ($selection -eq 's')