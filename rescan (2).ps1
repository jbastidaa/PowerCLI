$esxs = (Get-Cluster | Out-GridView -title "Clusters" -OutputMode Single) | Get-VMHost
foreach($esx in $esxs){
$esx
Get-VmHostStorage -VMHost $esx -RescanAllHba
}