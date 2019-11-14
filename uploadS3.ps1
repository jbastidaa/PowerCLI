param
(
   $Servers = @("tqtcvct01.senha.sat.mx","tqtcvct02.senha.sat.mx"),
   $BasePath = "C:\Users\baaj850406\Documents\RVtools",
   $Key = "rvtools_queretaro",
   $Bucket = "senha-metrics",
   $port = "443",
   $addr = "10.99.24.10"
)

$Date = (Get-Date -f "yyyyMMdd")
Set-AWSProxy -Hostname $addr -port $port
foreach ($server in $servers)
  {
    $folders = Get-ChildItem -Directory "$BasePath\$server"
    foreach ($folder in $folders)
      {
        Write-S3Object -BucketName $Bucket -Folder "$BasePath\$server\$Date" -KeyPrefix $Key
      }
  }