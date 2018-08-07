
Function Get-Info {
    
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
            Erroraction        = "Stop"
            SkipTestconnection = $True
            Computername       = ""
        }
    
        if ($credential) {
            Write-Verbose "[BEGIN] Adding credential $($credential.username)"
            $cimSess.Add("Credential", $Credential)
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
                Classname  = "win32_Operatingsystem"
                Property   = "caption", "csname", "lastbootuptime", "version", "totalvisiblememorysize"
                CimSession = ""
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
                $cimparams.Classname = "win32_computersystem"
                $cimparams.property = 'NumberOfProcessors', 'NumberOfLogicalProcessors'                   
    
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
                Remove-Variable OS, CS
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
    
Function Get-HWInfo {
    [cmdletbinding()]
    Param([string]$Computername = $env:computername)
    $data = Dofoo
    [pscustomobject]@{
        Name    = $computername.toUpper()
        Version = $data.version
        OS      = "Windows Unicorn"
        FreeGB  = $data.size
    }
}

Function Get-VolumeReport {
    [cmdletbinding(DefaultParameterSetName = "computer")]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = "session")]
        [ValidateNotNullorEmpty()]
        [Microsoft.Management.Infrastructure.CimSession[]]$Cimsession,
        [Parameter(Position = 0, ValueFromPipeline,ValueFromPipelineByPropertyName,
         HelpMessage = "Enter a computername", ParameterSetName = "computer")]
        [ValidateNotNullorEmpty()]
        [string]$Computername = $env:computername,
        [Parameter(HelpMessage = "Enter a drive letter like C or D without the colon.")]
        [ValidatePattern("[c-zC-Z")]
        [string]$Drive = "C"
    )

    Begin {
        Write-Verbose "[BEGIN] Starting $($myinvocation.MyCommand)"
    }
    Process {
        if ($pscmdlet.ParameterSetName -eq "computer") {
            Write-Verbose "[PROCESS] Creating a temporary CimSession to $($Computername.toUpper())"
            Try {
            $Cimsession = New-CimSession -ComputerName $computername -ErrorAction Stop
            #set a flag to indicate this session was created here
            #so PowerShell can clean up
            $tempsession = $True
            }
            Catch {
                Write-Warning "Failed to create a CIMSession to $($Computername.toUpper()). $($_.exception.message)"
                #bail out
                return
            }
        }
    
        $params = @{
            Erroraction = "Stop"
            driveletter = $Drive.toUpper()
            CimSession  = $Cimsession
        }
        Write-Verbose "[PROCESS] Getting volume information for drive $Drive on $(($cimsession.computername).toUpper())"

        Get-Volume @params |
            Select-Object Driveletter, Size, SizeRemaining, HealthStatus,
        @{Name = "Date"; Expression = {(Get-Date)}},
        @{Name = "Computername"; Expression = {$_.pscomputername.toUpper()}} 

        if ($tempsession) {
            Write-Verbose "[PROCESS] Removing temporary CimSession"
            Remove-CimSession -CimSession $Cimsession
        }
    } #process
    End {
        Write-Verbose "[END] Ending $($myinvocation.MyCommand)"
    
    }
} #close Get-VolumeReport

# private helper function
Function dofoo {
    [pscustomobject]@{
        size    = [math]::Round((Get-Random -Minimum 1gb -Maximum 10gb) / 1GB, 2)
        Version = "v{0}.0.0" -f (Get-Random -Minimum 2 -Maximum 6) 
    }
}
