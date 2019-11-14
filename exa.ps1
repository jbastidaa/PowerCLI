$scroll = "/-\|/-\|"
$idx = 0
$job = Invoke-Command -ComputerName $env:ComputerName -ScriptBlock { Start-Sleep -Seconds 10 } -AsJob

$origpos = $host.UI.RawUI.CursorPosition
$origpos.Y += 1

while (($job.State -eq "Running") -and ($job.State -ne "NotStarted"))
{
	$host.UI.RawUI.CursorPosition = $origpos
	Write-Host $scroll[$idx] -NoNewline
	$idx++
	if ($idx -ge $scroll.Length)
	{
		$idx = 0
	}
	Start-Sleep -Milliseconds 100
}
# It's over - clear the activity indicator.
$host.UI.RawUI.CursorPosition = $origpos
Write-Host ''