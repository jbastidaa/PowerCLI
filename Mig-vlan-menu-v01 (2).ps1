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
            $vmsVDS=(get-content -path VDSVM.txt)
            foreach($pVDS in $portVDS){
                foreach($vmVDS in $vmsVDS){
                Get-VM -Name $vmVDS  | Get-NetworkAdapter | Where-Object {$_.NetworkName -eq $pVDS } | Set-NetworkAdapter -NetworkName "STD_$pVDS" -Confirm:$false
                }
            }
            Clear-Variable portVDS
            Clear-Variable vmsVDS
        } '3' {
            Write-Host "Cambiar portgroup  VSS a VDS." -ForegroundColor "Green"
            $portVDS=(Get-Content -Path portVDS.txt)
            $vmsVSS=get-vm (get-content -path VSSVM.txt)
            foreach($pVDS in $portVDS){
                foreach($vmVDS in $vmsVSS){
                Write-Host "Modificando $vmVDS ..." -ForegroundColor "yellow"
                $vmVDS  | Get-NetworkAdapter | Where-Object {$_.NetworkName -eq "STD_$pVDS"} | Set-NetworkAdapter -NetworkName $pVDS -Confirm:$false
                }
            }
            Clear-Variable portVDS
            Clear-Variable vmsVSS
        } '4' {
            Write-Host "Realizar vMotion." -ForegroundColor "Green"
            Get-VM -Name (get-content -path vssVM.txt) | move-vm –destination (get-cluster | Out-GridView -OutputMode Multiple | Get-VMHost | Sort-Object MemoryUsageGB, CpuUsageMhz | Select-Object -first 1)
        }
    }
    pause
}
until ($selection -eq 's')