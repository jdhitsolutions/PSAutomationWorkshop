#requires -version 5.1


<#
This is a copy of:

CommandType Name        Version Source                         
----------- ----        ------- ------                         
Cmdlet      Get-Service 3.1.0.0 Microsoft.PowerShell.Management

Created: 06 August 2018
Author : jeff

#>


Function Get-BitsService {
<#

.SYNOPSIS

Gets the services on a local or remote computer.


.DESCRIPTION

The Get-BitsService cmdlet gets the Bits service

.PARAMETER ComputerName

Gets the services running on the specified computers. The default is the local computer.

Type the NetBIOS name, an IP address, or a fully qualified domain name (FQDN) of a remote computer. To specify the local computer, type the computer name, a dot (.), or localhost.

This parameter does not rely on Windows PowerShell remoting. You can use the ComputerName parameter of Get-BitsService even if your computer is not configured to run remote commands.

PS C:\>Get-BitsService

.EXAMPLE

PS C:\>Get-BitsService $domaincomputers

This command retrieves the bits services from the $domaincomputers variable.


.INPUTS

System.String


.OUTPUTS

System.ServiceProcess.ServiceController

.LINK

New-Service

.LINK

Restart-Service

.LINK

Resume-Service

.LINK

Set-Service

.LINK

Start-Service

.LINK

Stop-Service

.LINK

Suspend-Service

#>
    [CmdletBinding()]
    [Alias("gbs")]
    Param(

        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('Cn')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:computername

    )

    Begin {

        Write-Verbose "[BEGIN  ] Starting $($MyInvocation.Mycommand)"
        Write-Verbose "[BEGIN  ] Using parameter set $($PSCmdlet.ParameterSetName)"
        Write-Verbose ($PSBoundParameters | Out-String)

    } #begin

    Process {
        $PSBoundParameters.add("Name", "bits")
        if (-Not $PSBoundParameters.ContainsKey("Computername")) {
            $PSBoundParameters.add("Computername", $computername)
        }
        Get-Service @PSBoundParameters | 
            Select-Object -Property @{Name = "Computername"; expression = {$_.MachineName.toUpper()}},
        Name, Status, StartType

    } #process

    End {
   
        Write-Verbose "[END    ] Ending $($MyInvocation.Mycommand)"

    } #end

} #end function Get-BitsService