$vm = get-vm test | Out-GridView -title "Selecciona la maquina" -OutputMode Single
$ $vm.ExtensionData.Config.Hardware.NumCoresPerSocket = 4
$vm | Set-VM -MemoryGB 32 -NumCPU 8 