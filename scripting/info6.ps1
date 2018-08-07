#requires -version 4.0

#accept pipeline input and log failures

Function Get-Info {

<#
.Synopsis
Get help desk server information
.Description
Use this command to get basic server information.
.Parameter Computername
The name of the computer to query. You must have admin rights.
.Example
PS C:\> Get-Info SRV2

Operatingsystem    : Microsoft Windows Server 2016 Standard Evaluation
Version            : 10.0.14393
Uptime             : 91.05:39:22.5945412
MemoryGB           : 32
PhysicalProcessors : 2
LogicalProcessors  : 8
ComputerName       : SRV2
.Link
Get-CimInstance
.Notes
Last Updated May 18, 2018
version 1.1

#>

    [cmdletbinding()]

    Param (
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("cn")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Computername = $env:computername,

        [pscredential]$Credential,
        
        [switch]$LogFailures
    )
    
    Begin {
        Write-Verbose "[BEGIN] Starting $($MyInvocation.mycommand)"
        

        #define a hashtable of parameters to splat to
        
        #New-Cimsession
        $cimSess = @{
            Erroraction = "Stop"
            SkipTestconnection = $True
            Computername = ""
        }

        if ($credential) {
            Write-Verbose "[BEGIN] Adding credential $($credential.username)"
            $cimSess.Add("Credential",$Credential)
        }
        
        

        if ($LogFailures) {

            #create a logfile name using the current date and time
            $logname = "{0}-InfoError.txt" -f (Get-Date -format yyyyMMddhhmm)
            #define the output path of the log file
            $logpath = Join-Path -Path $env:TEMP -ChildPath $logname

            Write-Verbose "[BEGIN] Errors will be logged to $Logpath"

            #define a header to add to the log file
            $msg = @"
Execution Data
    Username      : $env:USERDOMAIN\$env:username
    Computername  : $env:computername
    PSVersion     : $($PSVersionTable.psversion)
    Date          : $(Get-Date)
    ScriptVersion : 1.1
**************************************************

"@
            $msg | Out-file -FilePath $logpath

        } #if logfailures

    } #begin

    Process {
        foreach ($computer in $computername) {
            #Get-CimInstance
            $cimParams = @{
                Classname    = "win32_Operatingsystem"
                Property     = "caption","csname","lastbootuptime","version","totalvisiblememorysize"
                CimSession   = ""
            }    
            
            $cimSess.computername = $computer
            Try {
                Write-Verbose "[PROCESS] Creating CIMSession to $computer"
                $cimsess | Out-String | Write-Verbose
                $sess = New-CimSession @cimSess
                        
            #add the session to the hashtable of parameters
            $cimParams.Cimsession = $sess

            Write-Verbose "[PROCESS] Processing $computer"
                $os = Get-CimInstance @cimparams

                    Write-Verbose "[PROCESS] Getting Computersystem info"

                    #define a hashtable of parameters to splat 
                    $cimparams.Classname  = "win32_computersystem"
                    $cimparams.property ='NumberOfProcessors', 'NumberOfLogicalProcessors'                   

                    $cs = Get-CimInstance @cimparams
    
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

                    #write the object to the pipeline
                    New-Object -TypeName PSObject -Property $properties

                    #clear the os variable for the next computer
                    #shouldn't need to do this but just in case
                    #something weird happens
                    Remove-Variable OS,CS
                    Write-Verbose "[PROCESS] Cleaning up CimSession"
                    Remove-CimSession -cimsession $sess
            } #try
            Catch {
                Write-warning "Failed to contact $computer. $($_.exception.message)"
                If ($LogFailures) {
                    #Write data to the log file
                    "[$(Get-Date)] $($computer.toUpper())" | Out-File -FilePath $logpath -Append
                    "[$(Get-Date)] $($_.exception.message)" | Out-File -FilePath $logpath -Append
                } #if logfailures
                if ($sess) {
                  Remove-CimSession -CimSession $sess
                }
            } #Catch 
        } #foreach
    } #process

    End {
    
        If ( $LogFailures -AND (Test-Path -Path $logpath)) {
            Write-Host "Errors were logged to $logpath" -ForegroundColor yellow
        }

        Write-verbose "[END] Exiting $($MyInvocation.MyCommand)"
    
    } #end
    
} #close Get-Info
