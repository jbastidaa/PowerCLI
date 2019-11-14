$dateTime = @()
$vmhosts = Get-VMHost #Get-cluster | Out-GridView -Title "Selecciona el cluster" -OutputMode Sinlge | Get-VMHost
foreach ($vmhost in $vmhosts){
	$VMhost.name
	$esxcli=$VMHost | Get-EsxCli
    $dateTime = (get-date) -split(' ') -split('/') -split(':')
    $esxcli.system.time.set($dateTime[01], 1 ,$dateTime[04],$dateTime[00],$dateTime[05],$dateTime[02])
    $esxcli.system.time.get()
    Clear-Variable dateTime
    $dateTime = (get-date) -split(' ') -split('/') -split(':')
    $esxcli.hardware.clock.set($dateTime[01], 1 ,$dateTime[04],$dateTime[00],$dateTime[05],$dateTime[02])
    $esxcli.hardware.clock.get()
    }
#$dateTime[00], 00 - Mes, 01 - Dia, 02 - Año, 03 - Hora, 04 - Minutos, 05 - Segundos
#boolean set(long day, long hour, long min, long month, long sec, long year)