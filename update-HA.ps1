$vclusters = get-cluster (Get-Content -Path clusters.txt)
foreach($clu in $vclusters){
    New-AdvancedSetting -Entity $clu -Name "das.ignoreRedundantNetWarning" -Value "true" -Type ClusterHA
    }
