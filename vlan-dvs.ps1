$dvs = get-vdswitch
$reporte= @()
$reporte = foreach ($dv in $dvs){
             $dv | Get-VDPortgroup | Select-Object name, vlanconfiguration
  		}
$reporte | export-csv -path vlans-id.csv -notypeinformation