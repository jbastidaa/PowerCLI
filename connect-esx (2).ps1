function Show-Menu
{
    param (
        [string]$Title = 'Aca las tortas'
    )
    Clear-Host
    Write-Host "================ $Title ================" -ForegroundColor "Blue"
    
    Write-Host "1:  Conectar ESX." -ForegroundColor "Green"
    Write-Host "2:  Desconectar ESX." -ForegroundColor "Green"
    Write-Host "3:  Cambiar Usuario y Password" -ForegroundColor "Green"
    Write-Host "4:  Agregar ESX al inventario de SPAC." -ForegroundColor "Green"
    Write-Host "5:  Agregar ESX al inventario de SENHA." -ForegroundColor "Green"
    Write-Host "6:  Realizar vMotion" -ForegroundColor "Green"
    Write-Host "S:  Salir." -ForegroundColor "Red"
}
Write-Host "================ Credenciales para trabajar con los ESX ================" -ForegroundColor "Blue"
$user = Read-Host "Ingresa el usuario a utilizar"
$passwd = Read-Host "Ingresa el password a utilizar"
do
{
    Show-Menu -Title 'Conectar - Desconectar ESX'
    $selection = Read-Host "Selecciona una opcion"
    switch ($selection)
    {
        '1' {
            Write-Host "1.Conectar ESX. " -ForegroundColor "Yellow"
            $vservers = Get-VMHost (Get-Content -Path esx.txt)
            foreach ($vserver in $vservers){
                Set-VMHost -VMHost $vserver -State "Connected"
            }
            Clear-Variable vservers 
        } '2' {
            Write-Host "2:  Desconectar ESX." -ForegroundColor "Yellow"
            $vhosts = Get-VMHost (Get-Content -Path esx.txt)
            foreach($esx in $vhosts){
                Write-Host "Desconectando ESX $esx ..."
                Set-VMHost -VMHost $esx -State "Disconnected"
            }
            Clear-Variable vhosts
        } '3' {
            Write-Host "3:  Cambiar Usuario y Password" -ForegroundColor "Yellow"
            Clear-Variable user
            Clear-Variable passwd
            $user = Read-Host "Ingresa el usuario a utilizar"
            $passwd = Read-Host "Ingresa el password a utilizar"
            Write-Host "Valores actualizados:"
            Write-Host "Usuario: $user" -ForegroundColor Green 
            Write-Host "Password: $passwd" -ForegroundColor Green
        } '4'{
            Write-Host "4:  Agregar ESX al inventario SPAC." -ForegroundColor "Green"
            $vhosts = Get-Content -Path esx.txt
            $DC=Get-Datacenter | Out-GridView -OutputMode Multiple
            $clus=Get-Cluster | Out-GridView -OutputMode Multiple
            foreach($vhost in $vhosts){
                Write-Host "Agregando ESX $vhost al inventario..."
                Get-Datacenter $DC | Get-Cluster $clus | Add-VMHost -Name $vhost -User $user -Password $passwd -Force
            }
            Clear-Variable vhosts
            Clear-Variable DC
            Clear-Variable clus
        } '5'{
            Write-Host "5:  Agregar ESX al inventario de SENHA." -ForegroundColor "Yellow"
            $vhosts = Get-Content -Path ipesx.txt
            $DC=Get-Datacenter | Out-GridView -OutputMode Multiple
            $clus=Get-Cluster | Out-GridView -OutputMode Multiple
            ForEach($vhost in $vhosts){
                Write-Host "Agregando ESX $vhost al inventario de SENHA..."
                Get-Datacenter $DC | Get-Cluster $clus | Add-VMHost -Name $vhost -User $user -Password $passwd -Force
            }
            Clear-Variable vhosts
            Clear-Variable DC
            Clear-Variable clus
        } '6'{
            Write-Host "6:  Realizar vMotion." -ForegroundColor "Yellow"
            Get-VM -Name (get-content -path vms.txt) | move-vm –destination (get-cluster | Out-GridView -OutputMode Multiple | Get-VMHost | Sort-Object MemoryUsageGB, CpuUsageMhz | Select-Object -first 1)
        }
    }
    pause
}
until ($selection -eq 's')