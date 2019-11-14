$a = Get-Process | Select -First 5 | ConvertTo-HTML -Title "Report Prozesse" -PreContent "<h1>Report Process</h1>"
$b = Get-Service | Select -First 5 | ConvertTo-HTML -Title "Report Service" -PreContent "<h1>Report Service</h1>"
$c = Get-WmiObject -class Win32_OperatingSystem | Select -First 5 | ConvertTo-HTML -Property * -Title "Report OS" -PreContent "<h1>Report OS</h1>"

ConvertTo-HTML -body "$a $b $c" -CSSUri "PSHtmlReport.css" | Set-Content "ReporteInfra.html"