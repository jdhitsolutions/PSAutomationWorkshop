#requires -version 4.0

# get server information for the help desk

Param (       
  [alias("cow","cn")]  
  [string]$Computername
)

Set-StrictMode -Version 2.0

<#
 Get computer information with Get-CimInstance (WMI) and
 create a custom object
#>

write-host "Getting server information for $Computername" -ForegroundColor Cyan

Get-CimInstance -ClassName win32_operatingsystem -ComputerName $computername | 
    Select-Object -Property Caption, Version,
@{Name = "Uptime"; Expression = {(Get-Date) - $_.lastbootuptime}},
@{Name = "MemoryGB"; Expression = {$_.totalvisiblememorysize / 1MB -as [int32]}},
@{Name = "PhysicalProcessors"; Expression = { (Get-CimInstance win32_computersystem -ComputerName $computername -Property NumberOfProcessors).NumberOfProcessors }},
@{Name = "LogicalProcessors"; Expression = { (Get-CimInstance win32_computersystem -ComputerName $computername -property NumberOfLogicalProcessors).NumberOfLogicalProcessors }},
@{Name = "ComputerName"; Expression = {$_.CSName}}

