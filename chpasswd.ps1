$esxlist = Import-CSV -Path "esxisenha.csv"
foreach($esx in $esxlist){
	$Myesx = $esx.esx
	$Myuser = $esx.user
	$Mypssw = $esx.pass
        $Newpass = $esx.newpass
	
    Connect-VIServer -Server $Myesx -User root -Password $Mypssw
    Get-VMHostAccount -User root | Set-VMHostAccount -Password $Newpass
       
    Disconnect-VIServer -Confirm:$false
	}