$dvs = Get-VDSwitch
$gests = Get-Content -Path .\gestion.txt
$prods = Get-Content -Path .\produccion.txt
$NAss = Get-Content -Path .\NAS.txt
Write-host "------------------------------"
   Write-host "|"        Vlans de Gestion   "|"                   
   Write-host "------------------------------"
foreach ($dv in $dvs){
   $dvsports = $dv | Get-VDPortgroup
   foreach ($dvsport in $dvsports){
      foreach ($gest in $gests){
         if ($dvsport.VlanConfiguration.VlanId -eq "$gest"){
            Write-Host "La vlan $gest existe en el Dvs $dv" -ForegroundColor Green
         }
      }
   }
}
Write-host "------------------------------"
   Write-host "|"        Vlans de Producción   "|"                   
   Write-host "------------------------------"
foreach ($dv in $dvs){
   $dvsports = $dv | Get-VDPortgroup
   foreach ($dvsport in $dvsports){
      foreach ($prod in $prods){
         if ($dvsport.VlanConfiguration.VlanId -eq "$prod"){
            Write-Host "La vlan $prod existe en el Dvs $dv" -ForegroundColor Green
         }
      }
   }
}
Write-host "------------------------------"
   Write-host "|"        Vlans de NAS   "|"                   
   Write-host "------------------------------"
foreach ($dv in $dvs){
   $dvsports = $dv | Get-VDPortgroup
   foreach ($dvsport in $dvsports){
      foreach ($nas in $nass){
         if ($dvsport.VlanConfiguration.VlanId -eq "$nas"){
            Write-Host "La vlan $nas existe en el Dvs $dv" -ForegroundColor Green
         }
      }
   }
}