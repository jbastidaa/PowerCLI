function Show-Menu
{
    param (
        [string]$Title = 'Aca las tortas'
    )
    Clear-Host
    Write-Host "================ $Title ================" -ForegroundColor "Yellow"
    
    Write-Host "1:  Actualizar VMware tools." -ForegroundColor "Green"
    Write-Host "2:  Actualizar HW virtual." -ForegroundColor "Green"
    Write-Host "S:  Salir." -ForegroundColor "Green"
}
do
{
    Show-Menu -Title 'Crear snapshots y actualizar VMware tools'
    $selection = Read-Host "Selecciona una opcion"
    switch ($selection)
    {
        '1' {
            'Actualizar VMware tools'
            $vms = Get-vm (Get-Content -path vms.txt)
            foreach($vm in $vms){
              Update-Tools -VM $vm -Verbose
              }
            Clear-Variable vms
        } '2' {
            'Actualizar HW virtual'
            $vms = Get-vm (Get-Content -path vms.txt)
            foreach($vm in $vms){
            Set-VM -VM $vm -HardwareVersion vmx-13 -Confirm:$false
            }
            Clear-Variable vms
        } 
    }
    pause
}
until ($selection -eq 's')




