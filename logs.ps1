$vm = get-vm trpkiprofiac04
$target = New-Item -ItemType Directory -Force -Path C:\Users\BAAJ8504\Documents\scripts_JBA\$vm
$datastore = get-vm $vm | Get-Datastore
New-PSDrive -Location $datastore -Name ds -PSProvider VimDatastore -Root "\"
Set-Location ds:\
cd $vm
Copy-DatastoreItem -Item *.log -Destination $target
set-Location C:
Remove-PSDrive -Name ds -Confirm:$false