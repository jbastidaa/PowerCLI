Write-Host "Configurando VMkernel port para vMotion..." -ForegroundColor Yellow
$keys = Import-Csv -Path .\pod4.csv
$clusters = Get-Datacenter CPN_POD4 | Get-Cluster | Out-GridView -Title "Selecciona el cluster..." -OutputMode Multiple
foreach ($cluster in $clusters){
   $vhosts= $cluster | Get-VMHost
   foreach ($line in $keys){
      foreach ($vhost in $vhosts){
         if ($line.esx -eq $vhost.name){
            Write-Host "Obteniendo vSwitch de $vhost ..."
            $sw = $vhost | Get-VirtualSwitch -name vSwitch0
            Write-Host "Creando portgroup para vmotion ..."
            $vportgroup =  New-VirtualPortGroup -VirtualSwitch $sw -Name vMotion -VLanId 410
            Write-Host "Creando vmkernel ... en $vhost"
            New-VMHostNetworkAdapter -VMHost $vhost -VirtualSwitch $sw -PortGroup $vportgroup -IP $line.ip -SubnetMask $line.mask -VMotionEnabled $true     
         }
      }
   }
}