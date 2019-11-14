$backupdir = “C:\Users\baaj850406\Documents\WindowsPowerShell\scripts_JBA\VMX“

Get-VM (Get-Content -Path vms.txt) | Get-View | ForEach-Object {
    $vmxfile = $_.Config.Files.VmPathName
    $dsname = $vmxfile.split(” “)[0].TrimStart(“[“).TrimEnd(“]”)
    $ds = Get-Datastore -Name $dsname
    New-PSDrive -Name ds -PSProvider VimDatastore -Root ‘\’ -Location $ds
    Copy-DatastoreItem -Item “ds:$($vmxfile.split(‘]’)[1].TrimStart(‘ ‘))” -Destination $backupdir
    Remove-PSDrive -Name ds
  }

