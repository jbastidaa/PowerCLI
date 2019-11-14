param
(
   $Servers = @("tqtcvct01.senha.sat.mx", "tqtcvct02.senha.sat.mx"),
   $BasePath = "C:\Users\baaj850406\Documents\RVtools",
   $OldFileDays = 30
)

$Date = (Get-Date -f "yyyyMMdd")

foreach ($Server in $Servers)
{
   # Create Directory
   New-Item -Path "$BasePath\$Server\$Date" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null 

   # Run Export
   cd "C:\Program Files (x86)\Robware\RVTools"
   $command = "cmd.exe /C RVTools.exe -passthroughAuth -s $Server -c ExportAll2xlsx -d $BasePath\$Server\$Date -f $server-$Date.xlsx"
   Invoke-Expression -Command:$command

   # Cleanup old files
   $Items = Get-ChildItem -Directory "$BasePath\$server"
   foreach ($item in $items)
   {
      $itemDate = ("{0}/{1}/{2}" -f $item.name.Substring(6,2),$item.name.Substring(4,2),$item.name.Substring(0,4))
      
      if ((((Get-date).AddDays(-$OldFileDays))-(Get-Date($itemDate))).Days -gt 0)
      {
         $item | Remove-Item -Recurse
      }
   }
}
