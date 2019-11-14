$vhosts = Get-content esx.txt
foreach($vhost in $vhosts){
   echo y | &("C:\Users\Soporte\Downloads\plink.exe") -pw "contraeñaSegura" root@$vhost "hostname"
   }