function Show-Menu
{
    param (
        [string]$Title = 'Aca las tortas'
    )
    Clear-Host
    Write-Host "================ $Title ================" -ForegroundColor "Yellow"
    
    Write-Host "1:  Obtener ruta del arcvhivo .vmx en SPAC" -ForegroundColor "Green"
    Write-Host "2:  Remover maquinas del inventario SPAC" -ForegroundColor "Green"
    Write-Host "3:  Registar maquinas en inventario de SENHA." -ForegroundColor "Green"
    Write-Host "4:  Acomodar maquinas en ESXi." -ForegroundColor "Green"
    Write-Host "S:  Salir." -ForegroundColor "Green"
}
do
{
    Show-Menu -Title 'Migrar maquinas apagadas SPAC / SENHA'
    $selection = Read-Host "Selecciona una opcion"
    switch ($selection)
    {
        '1' {
            Write-Host "1:  Obtener ruta del arcvhivo .vmx en SPAC" -ForegroundColor "Green"
            $vmxfile =@()
            $vms = get-vm (Get-Content -Path vms.txt) 
            $vmxfile = foreach ($vm in $vms){
                $vm | Select-Object Name,@{E={$_.ExtensionData.Config.Files.VmPathName};L="VMX"},@{N='Cluster';E={$_.vmhost.parent}}
            }
            $vmxfile | Export-Csv vmxfile.csv -NoTypeInformation
            Clear-Variable vms
        } '2' {
            Write-Host "2:  Remover maquinas del inventario SPAC" -ForegroundColor "Green"
            $vms = get-vm (Get-Content -Path vms.txt) 
            foreach ($vm in $vms){
                Remove-VM $vm -Confirm:$true
            }
        } '3' {
            Write-Host "3:  Registar maquinas en inventario de SENHA." -ForegroundColor "Green"
            $X = Import-Csv -path vmxfile.csv
            foreach ($line in $x){
                New-VM -ResourcePool $line.cluster -VMFilePath $line.VMX -RunAsync
            }
        } '4' {
            Write-Host "4:  Acomodar maquinas en ESXi." -ForegroundColor "Green"
            $X = Import-Csv -path vmxfile.csv
            foreach ($line in $x){
                Get-VM -Name $line.name | move-vm –destination $line.esx
            }
        }
    }
    pause
}
until ($selection -eq 's')


