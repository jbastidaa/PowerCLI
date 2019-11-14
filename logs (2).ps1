$vm = get-vm tqsecproexch*
$target = New-Item -ItemType Directory -Force -Path C:\Users\baaj850406\Documents\WindowsPowerShell\scripts_JBA\Logs\$vm
$datastore = get-vm $vm | Get-Datastore
New-PSDrive -Location $datastore -Name ds -PSProvider VimDatastore -Root "\"
Set-Location ds:\
cd $vm
Copy-DatastoreItem -Item *.log -Destination $target
set-Location C:
Remove-PSDrive -Name ds -Confirm:$false