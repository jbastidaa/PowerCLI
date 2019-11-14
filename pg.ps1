$clusters = get-cluster | Out-GridView -Title "Selecciona el cluster" -OutputMode Single
Foreach($clu in $clusters){
    $output = $clu | Get-VMhost | Get-VDSwitch | Get-VDPortgroup | Select VDswitch, Name, @{N='VlanId';E={$_.VlanConfiguration.VlanId}}
    $output | Export-Csv salida.csv -NoTypeInformation
}