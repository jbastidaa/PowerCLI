$esxihosts = Get-VMHost
$i=0

$report = ForEach ($esxi in $esxihosts) {
    $i++
    Write-Progress -Activity "Scanning hosts" -Status ("Host: {0}" -f $esxi.Name) -PercentComplete ($i/$esxihosts.count*100) -Id 0
    $hbas = $esxi | Get-VMHostHba
    $j=0
    ForEach ($hba in $hbas) {
        $j++
        Write-Progress -Activity "Scanning HBAs" -Status ("HBA: {0}" -f $hba.Device) -PercentComplete ($j/$hbas.count*100) -Id 1
        $scsiluns = $hba | Get-ScsiLun
        $k=0
        ForEach ($scsilun in $scsiluns) {
            $k++
            Write-Progress -Activity "Scanning Luns" -Status ("Lun: {0}" -f $scsilun.CanonicalName) -PercentComplete ($k/$scsiluns.count*100) -Id 2
            $scsipaths = $scsilun | Get-Scsilunpath
            $l=0
            ForEach ($scsipath in $scsipaths) {
                $l++
                Write-Progress -Activity "Scanning Paths" -Status ("Path: {0}" -f $scsipath.Name) -PercentComplete ($l/$scsipaths.count*100) -Id 3
                New-Object PSObject -Property @{
                    Host = $esxi.name
                    Cluster = $esxi.parent
                    NameHBA = $hba.Device
                    PathSelectionPolicy = $scsilun.MultiPathPolicy
                    Status = $scsipath.state
                    LUN = (($scsilun.RunTimeName -Split "L")[1] -as [Int])
                    Path = $scsipath.LunPath
                    NAA = $scsilun.CanonicalName
                    
                } 
            }           
        }
    }
}

$report | Export-Csv -NoTypeInformation 'ESXiStorageInfo.csv'