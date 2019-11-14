Function GotoXY($X, $Y) {
 $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $X,$Y
}

function prompt {
  $XPos = $Host.UI.RawUI.CursorPosition.x
  $YPos = $Host.UI.RawUI.CursorPosition.y  
  $str = (Get-Location).path

  GotoXY $XPos $YPos
  Write-Host -NoNewline -ForegroundColor green "["
  $XPos++

  GotoXY ($XPos + ($str.length)) $YPos
  Write-Host -NoNewline -ForegroundColor green "]"

  GotoXY $XPos $YPos


 #fade it in one char at a time
  $Counter = 0  
  foreach ($char in $str.toCharArray()) {
  
    GotoXY ($XPos + $Counter) $YPos
    Write-Host -NoNewline -ForegroundColor white $char #main char
 
    $Remember = $char
    
    if ($str.length -gt 20) {
     sleep -Milliseconds 20 #speed up the prompt for longer paths
    } elseif ($str.length -gt 10) {
     sleep -Milliseconds 30
    } else {
     sleep -Milliseconds 50
    }
    
    $Counter++
    GotoXY (($XPos + $Counter)-1) $YPos
    
    if ($remember -eq "\") {
     Write-Host -NoNewline -ForegroundColor green $Remember #write the \ in the path as green
    } else {
     Write-Host -NoNewline -ForegroundColor gray $Remember #char trailing after main char
    }
       } #end foreach

  GotoXY ($XPos + $str.length + 1 ) $ypos

  return " "

}

Function TypeIN($str, $textcolor, $highlightcolor, $typespeed, $center) {
 if ($center -eq $true) {
  $XPos = [math]::truncate($Host.UI.RawUI.WindowSize.width / 2) - [math]::truncate($str.length / 2)
  $YPos = [math]::truncate($Host.UI.RawUI.WindowSize.height / 2)
 } else {
  $XPos = $Host.UI.RawUI.CursorPosition.x
  $YPos = $Host.UI.RawUI.CursorPosition.y
 }
 
 $Encoding = ([Console]::OutputEncoding).codepage
 #437 is the  OEM United States  encoding 1252 is european
 [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(1252)
 $cursor = [char]219
  
 #blink the cursor a few times
  for($i=1;$i -le $cursorblink;$i++) {
   sleep -Milliseconds 300
   GotoXY $XPos $YPos
   Write-Host -NoNewline -ForegroundColor gray $cursor #cursor char
   
   sleep -Milliseconds 300
   GotoXY $XPos $YPos  
   Write-Host -NoNewline " " #cursor char
  }
  
  
  #fade it in one char at a time
  $Counter = 0  
  foreach ($char in $str.toCharArray()) {
  
    GotoXY ($XPos + $Counter) $YPos
    Write-Host -ForegroundColor $highlightcolor $char #main char
    
    GotoXY (($XPos + $Counter)+1) $YPos 
    Write-Host -ForegroundColor white $cursor #cursor char
    
    $Remember = $char
    sleep -Milliseconds $typespeed

    $Counter++
    
    GotoXY (($XPos + $Counter)-1) $YPos
    Write-Host -ForegroundColor $textcolor $Remember #char trailing after main char
   
    
  } #end foreach
  
  
  #blink the cursor a few times
  GotoXY ($XPos + $Counter) $YPos  
  Write-Host " " #cursor char
  for($i=0;$i -le 2;$i++) {

   sleep -Milliseconds 300
   GotoXY ($XPos + $Counter) $YPos
   Write-Host -NoNewline -ForegroundColor gray $cursor #cursor char
   
   sleep -Milliseconds 300
   GotoXY ($XPos + $Counter) $YPos  
   Write-Host -NoNewline " " #cursor char
  }
  
  
 #now fade it out cuz were baws
 
  $fade = 200
  sleep -Milliseconds $fade
  GotoXY $XPos $YPos
  Write-Host -ForegroundColor gray $str
  
  sleep -Milliseconds $fade
  GotoXY $XPos $YPos
  Write-Host -ForegroundColor darkgray $str
  
  sleep -Milliseconds $fade
  GotoXY $XPos $YPos
  Write-Host -ForegroundColor black $str
  
  #sleep -Milliseconds $fade
  
  [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding($Encoding)
  
} #end FadeIN function

Function Set-Color ($Color) {
 $con = (Get-Host).UI.RawUI
 $con.ForegroundColor = $Color
}

Clear-Host
$con = (Get-Host).UI.RawUI
$con.BackgroundColor = "black"
$con.ForegroundColor = "gray"
$con.CursorSize = 100
$con.WindowTitle = "Jorge Bastida - PowerCLI Prompt"
Clear-Host

#Setup our drives...
$RetVal = New-PSDrive -name Scripts -psprovider FileSystem -root "C:\Users\BAAJ8504\Documents\WindowsPowerShell\scripts_JBA"
Set-Location Scripts:

Clear-Host

TypeIN "Una de jamon con Huevo..." Red white 40 $true
Clear-Host
#set-location -Path "C:\Users\BAAJ8504\Documents\scripts_JBA"
# Load Windows PowerShell cmdlets for managing vSphere
Add-PsSnapin VMware.VimAutomation.Core -ea "SilentlyContinue"
connect-viserver 10.55.199.201
invoke-item "C:\Program Files (x86)\VMware\Infrastructure\Virtual Infrastructure Client\Launcher\VpxClient.exe"

function Get-RecentVITask() {
<# 
  .SYNOPSIS
    Displays current vCenter tasks as they would appear using the Web or C# client.
  .DESCRIPTION 
    Displays current vCenter tasks as they would appear using the C# or Web client. Tasks eventually drop out of the recent task pane. If no task appear in the Web or C# client, they will not appear with this script.
  .EXAMPLE
    Get-RecentVITask
  .EXAMPLE
    Get-RecentVITask -loop $true
  .EXAMPLE
    Get-RecentVITask -loop $true $sleep 2
  #>
 
  param(
    [Parameter(Mandatory=$false,Position=0)]
    [string]$loop=$true,

    [Parameter(Mandatory=$false,Position=1)]
    [Int32]$sleep_timer=5
  ) 

  while ($true) {
    clear
    Write-Host "vCenter Recent Task"
    write-host "-------------------"
    get-task | select -last 10 | select Description, `
                                   @{N='Target';E={$_.ExtensionData.Info.EntityName}}, `
                                   @{N='Status';E={$_.State}}, `
                                   @{N='Percent';E={$_.PercentComplete}}, `
                                   @{N='vCenter';E={$_.ServerId.split('@')[1].split(':')[0]}}, `
                                   @{N='Start Time';E={$_.StartTime}}, `
                                   @{N='Completed Time';E={$_.FinishTime}}, `
                                   @{N='Requested Start Time';E={$_.ExtensionData.Info.QueueTime}} | ` 
                                   sort 'Start Time' | `
                                   ft -auto

     if ($loop -eq $true) { 
       sleep $sleep_timer
     } else {
       break
     }
  }
}