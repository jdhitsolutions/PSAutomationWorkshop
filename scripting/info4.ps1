#requires -version 4.0

Function Get-ServerInfo {

    [cmdletbinding()]

    Param (
        [Parameter(Position = 0)] 
        [Alias("cn")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Computername = $env:computername
    )

    Write-Verbose "[BEGIN] Starting $($myinvocation.MyCommand)"

    #loop through each computername that is part of $Computername
    foreach ($computer in $computername) {

        Write-verbose "[PROCESS] Processing $computer"

        Try {
            #get Operating system information from WMI on each computer
            $os = Get-CimInstance -ClassName win32_operatingsystem -ComputerName $computer -ErrorAction stop
            
            #moved this to the Try block so if there
            #is an error querying win32_computersystem, the same
            #catch block will be used    
            if ($os) {
                Write-Verbose "[PROCESS] Getting Computersystem info"

                #get computer system information from WMI on each computer
                $cs = Get-CimInstance win32_computersystem -ComputerName $os.csname -Property NumberOfProcessors,NumberOfLogicalProcessors -ErrorAction Stop
  
                #create an ordered hashtable that will be turned into an object
                $properties = [ordered]@{
                    Operatingsystem    = $os.caption
                    Version            = $os.version
                    Uptime             = (Get-Date) - $os.lastbootuptime
                    MemoryGB           = $os.totalvisiblememorysize / 1MB -as [int32]
                    PhysicalProcessors = $cs.NumberOfProcessors
                    LogicalProcessors  = $cs.NumberOfLogicalProcessors
                    ComputerName       = $os.CSName
                }

                #create a custom object using the hashtable as properties and values
                New-Object -TypeName PSObject -Property $properties
            
           } #if $OS has a value
           
        } #try

        Catch {
            Write-Warning "Failed to contact $($computer.ToUpper())"
            Write-Warning $_.exception.message
        } #catch
                
    } #foreach

    Write-verbose "[END] Exiting $($myinvocation.MyCommand)"

} #end Get-ServerInfo

