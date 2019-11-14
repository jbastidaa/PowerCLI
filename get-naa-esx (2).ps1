#####################################
# VMware VirtualCenter server name, #
#Cluster Name and output file(csv) #
#####################################
Connect-VIServer "10.55.199.201"
$outputFile = "tqcldbx22.CSV"
$cltName = "tqcldbx22"

new-variable -Name clusterName -Scope global -Value $cltName -Force
new-variable -Name LUNDetails -Scope global -Value @() -Force
new-variable -Name LUNDetTemp -Scope global -Value @() -Force
new-variable -Name LUNDetFinal -Scope global -Value @() -Force

####################################################
#Function to creeate objects and insert into array.#
####################################################
function insert-obj(){
[CmdletBinding()]
param(
[PSObject]$esxHost,
[PSObject]$vmName,
[PSObject]$dsName,
[PSObject]$cnName,
[PSObject]$rnName,
[PSObject]$Type,
[PSObject]$CapacityGB,
[PSObject]$ArrayName
)
$object = New-Object -TypeName PSObject
$object | Add-Member -Name 'Cluster' -MemberType Noteproperty -Value $global:clusterName
$object | Add-Member -Name 'Host' -MemberType Noteproperty -Value $esxHost
$object | Add-Member -Name 'DatastoreName' -MemberType Noteproperty -Value $dsName
$object | Add-Member -Name 'VMName' -MemberType Noteproperty -Value $vmName
$object | Add-Member -Name 'CanonicalNames' -MemberType Noteproperty -Value $cnName
$object | Add-Member -Name 'LUN' -MemberType Noteproperty -Value $rnName.Substring($rnName.LastIndexof(“L”)+1)
$object | Add-Member -Name 'Type' -MemberType Noteproperty -Value $Type
$object | Add-Member -Name 'CapacityGB' -MemberType Noteproperty -Value $CapacityGB
if ($ArrayName -eq "LUNDetails"){
$global:LUNDetails += $object
}
elseif($ArrayName -eq "LUNDetTemp"){
$global:LUNDetTemp += $object
}
}
######################################
#Collect the hostnames in the cluster#
######################################
$Hosts = Get-Cluster $clusterName | Get-VMHost | select -ExpandProperty Name
#############################################
#Collecting datastore, RDM and LUN Details.#
#############################################
foreach($vmHost in $Hosts) {
Write-Host "Collecting Datastore details from host $vmHost ...."
get-vmhost -Name $vmHost | Get-Datastore | % {
$naaid = $_.ExtensionData.Info.Vmfs.Extent | select -ExpandProperty DiskName
$RuntimeName = Get-ScsiLun -vmhost $vmHost -CanonicalName $naaid | Select -ExpandProperty RuntimeName
insert-obj -esxHost $vmHost -dsName $_.Name -cnName $naaid -rnName $RuntimeName -Type $_.Type -CapacityGB $_.CapacityGB -ArrayName LUNDetails
}
Write-Host "Collecting RDM Disk details from host $vmHost ...."
get-vmhost -Name $vmHost | Get-VM | Get-HardDisk -DiskType "RawPhysical","RawVirtual" | % {
$naaid = $_.SCSICanonicalName
$RuntimeName = Get-ScsiLun -vmhost $vmHost -CanonicalName $naaid | Select -ExpandProperty RuntimeName
insert-obj -esxHost $vmHost -vmName $_.Parent -cnName $naaid -rnName $RuntimeName -Type RDM -CapacityGB $_.CapacityGB -ArrayName LUNDetails
}
Write-Host "Collecting Free SCSI LUN(Non-RDM/VMFS) details from host $vmHost ...."
(get-view (get-vmhost -name $vmHost | Get-View ).ConfigManager.DatastoreSystem).QueryAvailableDisksForVmfs($null) | %{
$naaid = $_.CanonicalName
$DiskTemp = Get-ScsiLun -vmhost $vmHost -CanonicalName $naaid
insert-obj -esxHost $vmHost -cnName $naaid -rnName $DiskTemp.RuntimeName -Type FREE -CapacityGB $DiskTemp.CapacityGB -ArrayName LUNDetails
}
Write-Host "Collecting details of Unallocated LUNs from host $vmHost ...."
Get-ScsiLun -VmHost $vmHost | %{
$naaid = $_.CanonicalName
$naaidTemp = $LUNDetails | select -ExpandProperty CanonicalNames
If ($naaidTemp -notcontains $naaid){
insert-obj -esxHost $vmHost -cnName $naaid -rnName $_.RuntimeName -Type UNKNOWN -CapacityGB $_.CapacityGB -ArrayName LUNDetTemp
}
}
$global:LUNDetails += $global:LUNDetTemp
$global:LUNDetFinal += $global:LUNDetails
$global:LUNDetails.Clear()
$global:LUNDetTemp.Clear()
}
############################
#Export output to CSV file #
############################
$global:LUNDetFinal | Sort-Object Host,{[int]$_.LUN} | 
select Cluster,Host,CanonicalNames,Type,LUN,DatastoreName,VMName,CapacityGB  | Export-Csv -NoTypeInformation  $outputFile
$global:LUNDetFinal.Clear()