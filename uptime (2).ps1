$VMs = Get-VM | Where-Object {$_.PowerState -eq "PoweredOn"}
$Output = ForEach ($VM in $VMs)

    { 
    "" | Select @{N="Name";E={$VM.Name}},
    @{N="Powered On";E={$Event = Get-VM $VM.Name | Get-VIEvent -MaxSamples [int]::MaxValue | Where-Object {$_.FullFormattedMessage -like "*powered on*"} | Select-First 1 
    $Event.CreatedTime}},
    @{N="Up Time";E={$Timespan = New-Timespan -Seconds (Get-Stat -Entity $VM.Name -Stat sys.uptime.latest -Realtime -MaxSamples 1).Value
    "" + $Timespan.Days + " Days, "+ $Timespan.Hours + " Hours, " +$Timespan.Minutes + " Minutes"}}
    } 
    
$Output | Export-Csv -Path "VMUptimeReport.csv "-NoTypeInformation