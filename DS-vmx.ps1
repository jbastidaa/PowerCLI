$vms= get-vm (Get-Content -Path vms.txt)
#$ds= $vms | get-datastore
foreach($vm in $vms){
  Write-Host "Obteniendo ruta del arcvhivo .vmx y los DS utilizados" -ForegroundColor "Green"
  $vmxfile =@() 
  $vmxfile = foreach ($vm in $vms){
      $vm | Select-Object Name,@{E={$_.ExtensionData.Config.Files.VmPathName};L="VMX"},@{N="Nombre";E={$_.harddisks.name}}, @{N="Path";E={$_.HardDisks.Filename}}
      }
  $vmxfile | export-csv -path DS-VMX.csv -NoTypeInformation
  }
