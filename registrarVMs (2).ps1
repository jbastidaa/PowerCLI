Function Get-VMX {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [String[]]$VMName
    )
Get-VM $VMName | Select-Object Name,@{E={$_.ExtensionData.Config.Files.VmPathName};L="VM Path"},@{N='Cluster';E={$_.vmhost.parent}}
}
function Show-Menu
{
    param (
        [string]$Title = 'Aca las tortas'
    )
    Clear-Host
    Write-Host "================ $Title ================" -ForegroundColor "Blue"
    
    Write-Host "1:  Obetener ruta del arcvhivo .vmx en SPAC" -ForegroundColor "Green"
    Write-Host "2:  Remover maquinas del inventario SPAC" -ForegroundColor "Green"
    Write-Host "3:  Registar maquinas en inventario de SENHA." -ForegroundColor "Green"
    Write-Host "S:  Salir." -ForegroundColor "Green"
}
do
{
    Show-Menu -Title 'Migrar maquinas apagadas SPAC / SENHA'
    $selection = Read-Host "Selecciona una opcion"
    switch ($selection)
    {
        '1' {
            Write-Host "1:  Obetener ruta del arcvhivo .vmx en SPAC" -ForegroundColor "Green"
            $vmxfile =@()
            $vms = get-vm (Get-Content -Path vms.txt) 
            $vmxfile = foreach ($vm in $vms){
                $vm | Get-VMX
            }
            $vmxfile | Export-Csv vmxfile.csv -NoTypeInformation
            Clear-Variable vms
        } '2' {
            Write-Host "2:  Remover maquinas del inventario SPAC" -ForegroundColor "Green"
            $vms = get-vm (Get-Content -Path vms.txt) 
            foreach ($vm in $vms){
                Remove-VM $vm -Confirm:$false
            }
        } '3' {
            Write-Host "3:  Registar maquinas en inventario de SENHA." -ForegroundColor "Green"
            $X = Import-Csv -path vmxfile.csv
            $esx = Get-Cluster $X.Cluster | Get-VMHost | Out-GridView -OutputMode Single
            foreach ($line in $x){
                New-VM -VMFilePath $x.vmx -VMHost $esx -RunAsync
            }
        }
    }
    pause
}
until ($selection -eq 's')