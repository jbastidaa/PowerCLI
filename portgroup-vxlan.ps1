#variables globales
$auxs = Import-Csv -Path vms.csv
$vms_objs = get-vm (Get-Content -Path vms.txt)
foreach ($vms_obj in $vms_objs){
   foreach ($aux in $auxs){
      if ($vms_obj.Name -like $aux.VM){
         $vms_obj | Get-NetworkAdapter | where {$_.MacAddress -eq $aux.mac} | Set-NetworkAdapter -NetworkName $aux.Network -Confirm:$false
         }
   }
}