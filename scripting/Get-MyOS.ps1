#requires -version 5.1
#requires -module CimCmdlets

<#
This is a copy of:

CommandType Name            Version Source    
----------- ----            ------- ------    
Cmdlet      Get-CimInstance 1.0.0.0 CimCmdlets

Created: 06 August 2018
Author : jeff

#>
Function Get-MyOS {

<#
insert comment based help
#>


    [CmdletBinding(DefaultParameterSetName = 'ClassNameComputerSet')]
    param(
        [Parameter(ParameterSetName = 'CimInstanceSessionSet', ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession, 

        [Parameter(ParameterSetName = 'ClassNameComputerSet', Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('CN', 'ServerName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:computername, 

        [Alias('OT')]
        [uint32]$OperationTimeoutSec
     
    ) 
    begin {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            #ADD parameters
            $PSBoundParameters.Add("Namespace", "Root\CimV2")
            $PSBoundParameters.Add("Classname", "Win32_OperatingSystem")

            #the function invokes the full Get-Ciminstance command
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('CimCmdlets\Get-CimInstance', [System.Management.Automation.CommandTypes]::Cmdlet)
         
            #MODIFIED SCRIPT COMMAND
            $scriptCmd = {& $wrappedCmd @PSBoundParameters  | 
                    Select-object -property @{Name = "Computername"; Expression = {$_.CSName}},
                @{Name = "FullName"; Expression = { $_.Caption}},
                Version, BuildNumber, InstallDate, OSArchitecture }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch {
            throw
        }
    }
 
    process {
        try {
            $steppablePipeline.Process($_)
        }
        catch {
            throw
        }
    }
 
    end {
        try {
            $steppablePipeline.End()
        }
        catch {
            throw
        }
    }

} #end function Get-MyOS