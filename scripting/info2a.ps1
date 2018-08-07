#requires -version 4.0

# get server information for the help desk

Function Get-Cow {

[cmdletbinding()]

Param (       
  [Parameter(Mandatory, HelpMessage = "Enter the name of a cow." )] 
  [alias("cow","cn")]  
  [ValidateNotNullOrEmpty()]
  [ValidateSet("think51","foo","bar")]
  [ValidateScript( { Test-Connection -ComputerName $_ -Count 1 -Quiet })]
  [string]$Computername 
)

Set-StrictMode -Version 2.0

<#
 Get computer information with Get-CimInstance (WMI) and
 create a custom object
#>

Write-Verbose "[$(Get-date)] Starting Get-Cow"

write-Host "Getting server information for $Computername" -ForegroundColor Cyan

Write-Verbose "[$(Get-Date) Querying $computername"

Get-CimInstance -ClassName win32_operatingsystem -ComputerName $computername | 
Select-Object -Property Caption, Version,
@{Name = "Uptime"; Expression = {(Get-Date) - $_.lastbootuptime}},
@{Name = "MemoryGB"; Expression = {$_.totalvisiblememorysize / 1MB -as [int32]}},
@{Name = "PhysicalProcessors"; Expression = { (Get-CimInstance win32_computersystem -ComputerName $computername -Property NumberOfProcessors).NumberOfProcessors }},
@{Name = "LogicalProcessors"; Expression = { (Get-CimInstance win32_computersystem -ComputerName $computername -property NumberOfLogicalProcessors).NumberOfLogicalProcessors }},
@{Name = "ComputerName"; Expression = {$_.CSName}}

Write-Verbose "[$(Get-date)] Ending Get-Cow"

} #end Get-Cow function