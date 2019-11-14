$vms = get-vm (Get-Content -Path vms.txt)
$usuarios = Get-Content -Path usuarios.txt
foreach($vm in $vms){
    foreach($usr in $usuarios){
        #Invoke-VMScript -VM $vm -ScriptText "useradd -m $usr -e 2019-06-22; su - $usr; passwd $usr HandsOff" -GuestUser root -GuestPassword Handsoff
        Invoke-VMScript -VM $vm -ScriptText "su - $usr; passwd HandsOff; cat /etc/passwd" -GuestUser root -GuestPassword Handsoff -ScriptType Bash
        }
    }