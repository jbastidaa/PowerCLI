function Show-Menu
{
    param (
        [string]$Title = 'Aca las tortas'
    )
    Clear-Host
    Write-Host "================ $Title ================" -ForegroundColor "Yellow"
    
    Write-Host "1:  Probar password antes de cambiarlo." -ForegroundColor "Green"
    Write-Host "2:  Cambiar password de root en ESXi." -ForegroundColor "Green"
    Write-Host "3:  Probar password despues de cambiarlo." -ForegroundColor "Green"
    Write-Host "S:  Salir." -ForegroundColor "Green"
}
do
{
    Show-Menu -Title 'Probar / Cambiar password ESXi'
    $selection = Read-Host "Selecciona una opcion"
    switch ($selection)
    {
        '1' {
            Write-Host "1:  Probar password antes de cambiarlo." -ForegroundColor "Green"
            $reporte = @()
            $x = Import-Csv -Path esxisenha.csv
            $i=1
            $reporte =foreach($line in $x){
                Write-Progress -Activity "Probando el password de root en $line.esx" -Status "ESXi $i de $($x.Count)" -PercentComplete (($i / $x.Count) * 100)  
                Connect-VIServer -server $line.esx -User $line.user -Password $line.pass 
                Get-VMHost $line.esx
                Disconnect-VIServer -server $line.esx -Confirm:$false
                $i++
                }
            $reporte | Export-Csv -Path password.csv -NoTypeInformation
            Clear-Variable x
            Clear-Variable reporte
            Clear-Variable i
        } '2' {
            Write-Host "2:  Cambiar password de root en ESXi." -ForegroundColor "Green"
            $x = Import-Csv -Path esxisenha.csv
            $i=1
                foreach($line in $x){
                Write-Progress -Activity "Actualizando password de root en $line.esx" -Status "ESXi $i de $($x.Count)" -PercentComplete (($i / $x.Count) * 100)  
                Connect-VIServer -server $line.esx -User $line.user -Password $line.pass 
                Set-VMHostAccount -UserAccount $line.user -Password $line.newpass -Confirm:$false
                Disconnect-VIServer -server $line.esx -Confirm:$false
                $i++
                }
            Clear-Variable x
            Clear-Variable i
        } '3' {
             Write-Host "3: Probar password despues de cambiarlo." -ForegroundColor "Green"
            $reporte = @()
            $x = Import-Csv -Path esxisenha.csv
            $i=1
            $reporte =foreach($line in $x){
                Write-Progress -Activity "Probando el password de root en $line.esx" -Status "ESXi $i de $($x.Count)" -PercentComplete (($i / $x.Count) * 100)  
                Connect-VIServer -server $line.esx -User pruebaio@senha.sat.mx -Password Admin1234$ 
                #Get-VMHostAccount -User root
                Get-VMHostService | where {$_.key -eq "vpxa"}
                Disconnect-VIServer -server $line.esx -Confirm:$false
                $i++
                }
            $reporte | Export-Csv -Path angentes.csv -NoTypeInformation
            Clear-Variable x
            Clear-Variable reporte
            Clear-Variable i
        }
   }
    pause
}
until ($selection -eq 's')