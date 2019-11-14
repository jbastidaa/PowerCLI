#Jorge Bastida Alvarez
#VCP-DCV 6
#VMware Tools

New-VIProperty -Name ToolsVersionStatus -ObjectType VirtualMachine -ValueFromExtensionProperty 'Guest.ToolsVersionStatus'-Force
New-VIProperty -Name ToolsVersion -ObjectType VirtualMachine -ValueFromExtensionProperty 'Config.tools.toolsVersion'-Force

Write-Host "Recolectando Informacion de  Maquinas virtuales" -foregroundcolor green

$vms = get-content -path zagaceta.txt
$tools = get-vm $vms | Select Name, Version, ToolsVersion, ToolsVersionStatus
Write-Host "Generando archivo" -foregroundcolor yellow
$tools | Export-Csv -path VMware-Tools.csv -NoTypeInformation
