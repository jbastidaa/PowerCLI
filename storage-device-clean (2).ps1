function Show-Menu
{
    param (
        [string]$Title = 'Aca las tortas'
    )
    Clear-Host
    Write-Host "================ $Title ================" -ForegroundColor "Blue"
    
    Write-Host "1:  Validar naa desconectados por Cluster." -ForegroundColor "Green"
    Write-Host "2:  Eliminar naa desconectados por Cluster." -ForegroundColor "Green"
    Write-Host "S:  Salir." -ForegroundColor "Green"
}
do
{
    Show-Menu -Title 'Limpiar naa desconectados' | Out-GridView
    $selection = Read-Host "Selecciona una opcion"
    switch ($selection)
    {
        '1' {
            Write-Host "1:  Validar naa desconectados por Cluster."
            $vmhosts = Get-VMHost | Out-GridView -OutputMode Multiple -Title "Selecciona los hosts"
            $Lista = @()
            foreach($vmhost in $vmhosts)
                {
                    Write-Progress -Activity "Validando naa desconectados en $vmhost" -Status "ESX $i de $($vmhosts.Count)" -PercentComplete (($i / $vmhosts.Count) * 100)
                    $esxcli = $VMHost | Get-EsxCli
                    $VMHostname = $VMhost.name
                    $Lista+= $esxcli.storage.core.device.detached.list() | Select-Object @{N="VMHostname";E={$VMHostname}}, DeviceUID, state, @{N="Cluster";E={$VMHost.parent}}          
                    $i++
                }
             $Lista | export-csv "naa.csv" -NoTypeInformation
	     clear-variable i
        } '2' {
            Write-Host "2:  Eliminar naa desconectados por Cluster."
        }
    }
    pause
}
until ($selection -eq 's')
