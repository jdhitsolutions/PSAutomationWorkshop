#requires -version 3.0

Write-Warning "this is a walk-through demo"
Return 

#disable my psdefaultparameter values to avoid conflicts
$PSDefaultParameterValues["disabled"] = $True

#demo Foreach Parallel

#DemoForeachParallel "C:\work","C:\windows\SoftwareDistribution",$pshome

Workflow DemoParallel {

 Write-Verbose -message "Starting parallel demo workflow"

parallel {  

    write-verbose -Message "Getting WMI data from $pscomputername"

    #one line commands
    #scope is super critical here if you want to access variables 
    #in other scriptblocks in this workflow  
    
    #these commands execute in parallel  
    write-verbose -message "$((Get-Date).TimeOfDay) BIOS"
    $workflow:bios = Get-CimInstance -class win32_bios 
    write-verbose -message "$((Get-Date).TimeOfDay) OS"
    $workflow:os = Get-CimInstance -class win32_operatingsystem
    write-verbose -message "$((Get-Date).TimeOfDay) Computersystem" 
    $workflow:cs = Get-CimInstance -class win32_computersystem 
    write-verbose -message "$((Get-Date).TimeOfDay) Disk"
    $workflow:disks = Get-CimInstance -Class win32_logicaldisk -filter "Drivetype=3" 
 
 } #parallel

$hash=[ordered]@{
    Computername=$workflow:cs.Name
    Bios=$workflow:bios
    OperatingSystem=$workflow:os
    ComputerSystem=$workflow:cs
    Disks=$workflow:disks
}

#the output of new-Object must be assigned to a variable
$obj = New-Object -TypeName PSObject -Property $hash

$obj

write-verbose -message "Finished with WMI data"

} #close workflow 
    
demoparallel -pscomputername srv1,srv2,dom1 -verbose

Workflow DemoForEachParallel {

Param([string[]]$paths)

Write-Verbose -message "Starting $WorkflowCommandName"

$start=Get-Date

foreach -parallel ($path in $paths) {
 
 if (Test-Path -path $path) {
    write-verbose -message $path
    $stat=dir -path $path -file -recurse | 
    measure-object -Property Length -sum
    $obj=New-Object -TypeName PSObject -Property @{
      Path=$Path
      TotalFiles=$stat.count
      TotalSizeMB=$stat.sum/1MB
      }
    $obj
    }
    else {
        Write-Verbose "Failed to find $path"
    }
  } #foreach

$endtime = Get-Date

Write-verbose -message ("Finished workflow in {0}" -f ($endtime-$start))

} #close workflow

demoForEachparallel -paths c:\users,C:\windows\SoftwareDistribution,C:\windows\Temp -PSComputerName srv1,srv2,dom1 -verbose

#region parallel demo 1
Workflow New-Config {

Parallel {
  Set-Service -ServiceName Browser -StartupType Manual 
  Get-Process | 
   Where-Object -filter {$_.ws -ge 50MB} |
    Export-Clixml -Path "C:\work\Proc50MB.xml"
  If (-Not (Test-Path "C:\Reports")) {
    New-Item -Path "C:\Reports" -ItemType Directory
  }
} #end Parallel
} #end workflow

#endregion

#region parallel demo 2
Workflow New-Config2 {

Parallel {
  Set-Service -ServiceName Browser -StartupType Manual 
  Get-Process | Where-Object -filter {$_.ws -ge 50MB} |
    Export-Clixml -Path "C:\work\Proc50MB.xml"
  If (-Not (Test-Path "C:\Reports")) {
    New-Item -Path "C:\Reports" -ItemType Directory
  }
  Limit-EventLog -LogName System -MaximumSize 16MB
 } #end Parallel
} #end workflow

#endregion

Workflow SequenceSample {

Write-Verbose -message "Starting $workflowcommandname"
Sequence {
  Write-Verbose -message "Sequence 1"

  $users = "adam","bob","charlie","david" 
  foreach -parallel ($user in $users) {
    Write-Verbose -message "...Creating $user local account"
    start-sleep -Seconds (Get-Random -Minimum 1 -Maximum 5)
  }
}
Sequence {
 Write-Verbose -message "Sequence 2"
 Write-Verbose -message "...Doing something else"
}
Write-Verbose -message "Ending $workflowcommandname"
} #end workflow

Workflow ForEachParallelSample {
 foreach -parallel ($i in (1..100)) {$i*2}
} #end workflow

Workflow ForEachSample {
 foreach ($i in (1..100)) {$i*2; Start-Sleep -milliseconds 500 }
} #end workflow

Workflow DemoParallelSequence {

"{0} Starting" -f (Get-date).TimeOfDay
 $a=10

"`$a = $a"
"`$b = $b"

 Parallel {
 Write-verbose -Message "In parallel"
    Sequence {
        "{0} sequence 1" -f (get-Date).TimeOfDay
        $workflow:a++
        "  `$a = $a"
        "  `$b = $b"
        start-sleep -Seconds 1
    }
    Sequence {
        "{0} sequence 2" -f (get-Date).TimeOfDay
        $workflow:a++
        $workflow:b=100
        "  `$a = $a"
        "  `$b = $b"
        start-sleep -Seconds 1
    }

    Sequence {
        "{0} sequence 3" -f (get-Date).TimeOfDay
        $workflow:a++
        $workflow:b*=2
        "  `$a = $a"
        "  `$b = $b"
        start-sleep -Seconds 1
    }

 #this runs in parallel with the sequences
 "{0} Parallel" -f (Get-Date).TimeOfDay
 "`$a in parallel = $a"
 "`$b in parallel = $b"

} #parallel

#the results after Parallel
"{0} Final Results" -f (get-date).TimeOfDay
 "`$a final = $a"
 "`$b final = $b"
 
"{0} Ending" -f (get-date).TimeOfDay

} #close workflow
