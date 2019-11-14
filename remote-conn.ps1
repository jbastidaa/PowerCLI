$root = "root" 
$Passwd = "3sxS4tQr0"
$list = get-vmhost | where {$_.connectionstate -eq "connected"} | select name | Out-File esx.txt -NoClobber
$esxlist = Get-Content -Path esx.txt
$cmd = "vdf -h "
$plink = "plink.exe"
$remoteCommand = '"' + $cmd + '"'
$message = @()

foreach ($esx in $esxlist) {
   Connect-VIServer $esx -User  $root -Password $Passwd
   Write-Host "Executing Command on $esx"
   $output = $plink + " " + "-ssh" + " " + $root + "@" + $esx + " " + "-pw" + " " + $Passwd + " " + $remoteCommand
   $message = Invoke-Expression -command $output
   }
$message