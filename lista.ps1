#calculando por cluster
$clus = get-cluster
$report = @()
$report = foreach ($clu in $clus){ 
  Get-MemoryOvercommit -cluster $Clu 
  }
$report | Export-Csv overmemclu.csv -NoTypeInformation
Clear-Variable report
$report = @()
$report = foreach ($clu in $clus){ 
  Get-CPUOvercommit -cluster $Clu 
  }
$report | Export-Csv overCPUclu.csv -NoTypeInformation

#calculando por Host
$vhosts = Get-VMHost
$reportesx = @()
$reportesx = foreach ($esx in $vhosts){
  $esx |Get-MemoryOvercommit 
  }
$reportesx | Export-Csv overmemhost.csv -NoTypeInformation
Clear-Variable reportesx
$reportesx = @()
$reportesx = foreach ($esx in $vhosts){
  $esx |Get-CPUOvercommit 
  }
$reportesx | Export-Csv overcpuhost.csv -NoTypeInformation