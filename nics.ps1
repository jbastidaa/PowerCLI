$vhosts = get-cluster tqclweb02, tqclweb03, tqclweb06 | get-vmhost 
foreach($esx in $vhosts){
$esx | Get-VMHostNetworkAdapter | Select @{N='Host';E={$esx.Name}}, Name
}
