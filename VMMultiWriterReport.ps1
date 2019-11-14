$report = @()
foreach ($vm in (Get-VM)){
$view = Get-View $vm
$settings=Get-AdvancedSetting -Entity $vm
   if ($view.config.hardware.Device.Backing.sharing -eq "sharingMultiWriter" -or $settings.value -eq "multi-writer"){
   $row = '' | select Name
      $row.Name = $vm.Name
   $report += $row
   }
   
}
$report | Out-GridView