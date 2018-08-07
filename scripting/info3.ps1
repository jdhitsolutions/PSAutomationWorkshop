#requires -version 4.0

<#
an improved version that supports multiple computer names
and simplifies the Get-CimInstance queries
#>

Function Get-ServerInfo {
[cmdletbinding()]
    Param (
        [Parameter(Mandatory,HelpMessage = "Enter the name of a cow" )] 
        [alias("cow","cn")]  
        [ValidateNotNullOrEmpty()]
        [string[]]$Computername
    )

    Write-Verbose "[$(Get-date)] Starting Get-ServerInfo"

    foreach ($computer in $computername) {
            
            Write-Verbose "[$(Get-Date)] Querying $Computer"
            #for the sake of the demo I am suppressing verbose output
            #from Get-CimInstance
            $cs = Get-CimInstance -ClassName win32_operatingsystem -ComputerName $computer -verbose:$false

        if ($cs) {
            Write-Verbose "[$(Get-Date)] Getting details"

            $cs | select-Object -Property Caption, Version,
            @{Name = "Uptime"; Expression = {(Get-Date) - $_.lastbootuptime}},
            @{Name = "MemoryGB"; Expression = {$_.totalvisiblememorysize / 1MB -as [int32]}},
            @{Name = "PhysicalProcessors"; Expression = { (Get-CimInstance win32_computersystem -ComputerName $_.csname -Property NumberOfProcessors -verbose:$false).NumberOfProcessors }},
            @{Name = "LogicalProcessors"; Expression = { (Get-CimInstance win32_computersystem -ComputerName $_.csname -property NumberOfLogicalProcessors -verbose:$false).NumberOfLogicalProcessors }},
            @{Name = "ComputerName"; Expression = {$_.CSName}}
        } #if

    } #foreach

    Write-Verbose "[$(Get-date)] Ending Get-ServerInfo"

} #end Get-ServerInfo function

