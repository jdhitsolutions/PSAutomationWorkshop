#requires -version 4.0

#this version includes a timout parameter
#comment based help and splatting

Function Get-ServerInfo {

<#
.Synopsis
Get help desk server information

.Description
Use this command to get basic server information.

.Parameter Computername
The name of the computer to query. You must have admin rights.

.Parameter Timeout
Enter the number of seconds between 1 and 10 to wait for a WMI connection.

.Example
PS C:\> Get-ServerInfo SRV1

Operatingsystem    : Microsoft Windows Server 2016 Standard Evaluation
Version            : 10.0.14393
Uptime             : 1.05:39:22.5945412
MemoryGB           : 4
PhysicalProcessors : 2
LogicalProcessors  : 4
ComputerName       : SRV1

Get server configuration data from SRV1.

.Example
PS C:\> Get-ServerInfo SRV1,SRV2 | Export-CSV -path c:\reports\data.csv -append

Get server info and append to a CSV file.

.Link
Get-CimInstance

.Link
http://google.com

.Notes
Last Updated May 18, 2018
version 1.1

#>

    [cmdletbinding()]

    Param (
        [Parameter(Position = 0)]
        [Alias("cow", "cn")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Computername = $env:computername,

        [ValidateRange(1,10)]
        [int32]$Timeout
    )

    Write-Verbose "[BEGIN] Starting $($MyInvocation.MyCommand)"

    #define a hashtable of parameter values to splat to Get-CimInstance
    $cimParams = @{
        Classname    = "win32_Operatingsystem"
        ErrorAction  = "Stop"
        Computername = ""
    }
    
    if ($timeout) {
        Write-Verbose "[BEGIN] Adding timeout value of $timeout"
        $cimParams.add("OperationTimeOutSec", $Timeout)
    }

    foreach ($computer in $computername) {

        Write-Verbose "[PROCESS] Processing computer: $($computer.toUpper())"

        $cimParams.computername = $computer

        Try {
            $os = Get-CimInstance @cimparams
             
            #moved this to the Try block so if there
            #is an error querying win32_computersystem, the same
            #catch block will be used  
            if ($os) {
                Write-Verbose "[PROCESS] Getting Computersystem info"

                $csparams = @{
                    Classname    = "win32_computersystem"
                    computername = $os.csname
                    Property     = 'NumberOfProcessors', 'NumberOfLogicalProcessors'
                    ErrorAction  = 'Stop'
                }

                if ($timeout) {
                    $csParams.add("OperationTimeOutSec", $Timeout)
                }

                $cs = Get-CimInstance @csparams
    
                Write-Verbose "[PROCESS] Creating output object"  
                $properties = [ordered]@{
                    Operatingsystem    = $os.caption
                    Version            = $os.version
                    Uptime             = (Get-Date) - $os.lastbootuptime
                    MemoryGB           = $os.totalvisiblememorysize / 1MB -as [int32]
                    PhysicalProcessors = $cs.NumberOfProcessors
                    LogicalProcessors  = $cs.NumberOfLogicalProcessors
                    ComputerName       = $os.CSName
                }

                New-Object -TypeName PSObject -Property $properties

                Remove-Variable os
            } #if
        }
        Catch {
            #variation on warning message
            $msg = "Failed to contact $($computer.ToUpper()). $($_.exception.message)"

            Write-Warning $msg
            
        }

      } #foreach

    Write-verbose "[END] Exiting $($MyInvocation.MyCommand)"

} #end Get-ServerInfo

