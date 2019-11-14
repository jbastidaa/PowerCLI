$clus= get-cluster | Out-GridView -title "Selecciona el cluster" -outputmode single
$report = @()
$esxihosts = $clus | Get-VMHost

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
                    New-Object PSObject -Property @{
                    Host = $esxi.name
                    Cluster = $esxi.parent
                    NameHBA = $hba.Device
                    PathSelectionPolicy = $scsilun.MultiPathPolicy
                    LUN = (($scsilun.RunTimeName -Split "L")[1] -as [Int])
                    NAA = $scsilun.CanonicalName
                } 
            }           
        }
    }

$report | Export-Csv -NoTypeInformation 'ESXiStorageInfoFaltante.csv'