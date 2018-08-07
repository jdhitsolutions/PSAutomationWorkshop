#requires -version 3.0

Write-Warning "this is a walk-through demo"
Return 

#disable my psdefaultparameter values to avoid conflicts
$PSDefaultParameterValues["disabled"] = $True

workflow Basic {

Param()

write-verbose -Message "Starting a basic workflow $($workflowcommandname)"

$p = Get-Process -Name svchost
# $p
$p | Export-Clixml -path c:\svchosts.xml

write-verbose -Message "Ending a basic workflow"

}

get-command -CommandType Workflow
help basic
#check dynamic parameters
(Get-Command basic).Parameters 

Get-PSSessionConfiguration -Name *workflow*
Basic -PSComputerName srv1,srv2 -PSCredential company\artd -verbose
invoke-command { dir c:\svchosts.xml} -computername srv1,srv2

Workflow ParamDemo {

Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter a path")]
[ValidateNotNullorEmpty()]
[string]$Path
)

Write-Verbose -Message "Scanning $path"
$start = Get-Date

if (Test-Path -Path $path) {
$stats = Get-ChildItem -Path $path -Recurse -File |
Measure-Object -Property length -Sum

<#
$obj=New-Object -TypeName PSObject -Property @{
  Path=$Path
  Size=$stats.sum
  Count=$stats.count
  }

$obj
#>

#.NET Code used to not work
[pscustomobject]@{
  Path=$Path
  Size=$stats.sum
  Count=$stats.count
  }
}
else {
    Write-Error "Cannot find $path"
}

$endtime = Get-Date

Write-verbose -Message "Finished workflow in $($endtime-$start)"

}

paramdemo -path c:\windows\softwaredistribution -pscomputername srv1,srv2 -verbose

Workflow RestartMe {

#this log should be created on $PSComputername
$log="c:\wflog.txt"

$t="{0} Starting {1}" -f (Get-date).TimeOfDay,$workflowcommandname

$t | out-file -FilePath $log -encoding ascii 

#add some sample data to simulate doing something
get-Process | 
Measure-Object -sum -maximum -average -property WS | 
Out-file -FilePath $log -append

$t="{0} restarting" -f (Get-date).TimeOfDay
$t | out-file -FilePath $log -append

#this only works for remote computers
Restart-Computer -force -Wait -for PowerShell

$t="{0} Finished {1}" -f (Get-date).TimeOfDay,$workflowcommandname
$t | Out-File -FilePath $log -Append

}

#demo InlineScript
Workflow DemoInline {

 Write-verbose -Message "Starting the workflow"
 
    5..1 | foreach-object {
    write-verbose -message $_ 
    [math]::Pow($_,3)
    start-sleep 1
    }
         
  write-verbose -Message "Done"
}

Workflow DemoSequence {

write-verbose -message ("{0} starting" -f (Get-Date).TimeofDay)
$a=10
$b=1

"`$a = $a"
"`$b = $b"
"`$c = $c"

    Sequence {
        "{0} sequence 1" -f (Get-Date).TimeOfDay
        $workflow:a++
        $c=1
        start-sleep -seconds 1
    }

    Sequence {
        "{0} sequence 2" -f (Get-Date).TimeofDay
        $workflow:a++
        $workflow:b=100
        $c++
        start-sleep -seconds 1
    }

    Sequence {
        "{0} sequence 3" -f (Get-Date).TimeofDay
        $workflow:a++
        $workflow:b*=2
        $c++
        start-sleep -seconds 1
    }
 "`$a = $a"
 "`$b = $b"
 "`$c = $c"
 
write-verbose -Message ("{0} ending" -f (Get-Date).TimeOfDay)

}


Workflow ShowCommonParam {

#demo running this from the console with tab completion

$PSComputerName
$PSCredential
$PSConnectionRetryCount
$PSActionRetryCount
$PSPersist

}

Workflow DemoInlineScript {

Write-verbose -Message "Starting the workflow"
$a=1
"`$a = $a"

 Inlinescript {
     5..1 | foreach {$_ ; start-sleep 1}
     get-ciminstance -class "Win32_baseboard"
     $a++
  }

 InlineScript {
    $p=get-process | sort-object -property WS -descending |
    Select-object -first 1
    $a++
 }

 "`$a = $a"
 "Here is the top process:"
 $p
  write-verbose -Message "Done"
}

Workflow DemoNotUsing {

Param([string]$log="System",[int]$newest=10)

#creating a variable within the workflow
$source="Service Control Manager"

Write-verbose -message "Log parameter is $log"
Write-Verbose -message "Source is $source"

InlineScript {

    <#
    What happens when we try to access 
    out of scope variables?
    #>
   "Getting newest {0} logs from {1} on {2}" -f $newest,$log,$pscomputername
   get-eventlog -LogName $log -Newest $newest -Source $source

 } #inlinescript
 
 Write-verbose -message "Ending workflow"

} #close workflow

Workflow DemoUsing {

Param([string]$log="System",[int]$newest=10)

#creating a variable within the workflow
$source="Service Control Manager"

Write-verbose -message "Log parameter is $log"
Write-Verbose -message "Source is $source"

InlineScript {

    <#
    this is the way to access out of scope variables.
    #>
   "Getting newest {0} logs from {1} on {2}" -f $using:newest,$using:log,$pscomputername
   get-eventlog -LogName $using:log -Newest $using:newest -Source $using:source

 } #inlinescript

} #close workflow

Workflow Test-NoPersistence {

Write-Verbose -Message "Starting $workflowcommandname"
<#
 run this workflow, then restart the computer
 when you see the countdown. When the computer 
 comes back up run the workflow again.
#>
$p=get-process -Name lsass
start-sleep -Seconds 5

$n=(Get-Process).Count..0
    foreach ($i in $n) {
     $i
     (get-process)[$i] 
     Start-Sleep -Seconds 1
    } #foreach

$p | export-clixml -Path c:\lsass.xml
Write-Verbose -Message "Finished $workflowcommandname"
}

Workflow Test-WFPersistence {

Write-Verbose -Message "Starting $workflowcommandname"
$p=get-process -Name lsass
start-sleep -Seconds 5

$n=(Get-Process).Count..0
    foreach ($i in $n) {
     $i
     (get-process)[$i] 
     Start-Sleep -Seconds 1
     if ($i -eq 75) {
     Suspend-Workflow
     }
    } #foreach

$p | export-clixml -Path c:\lsass.xml
Write-Verbose -Message "Finished $workflowcommandname"
} #test-wfpersistence

<#
this doesn't seem to really make much difference 
unless you plan on suspending the workflow.
#>
Workflow Test-PersistenceCheckpoint {

Write-Verbose -Message "Starting $workflowcommandname"

<#
 run this workflow, then restart the computer
 when you see the countdown. When the computer 
 comes back up run the workflow again.
#>
$p=get-process -Name lsass
start-sleep -Seconds 5
Checkpoint-Workflow

<#
 we can't use Checkpoint-Workflow within InlineScript
 so we'll have to restructure
#>
foreach ($i in (30..1)) {
     $i
     (get-process)[$i] 
     Start-Sleep -Seconds 1
     #checkpoint on odd numbers
     if ($i%2) {
       Write-verbose -message "checkpoint"
       Checkpoint-Workflow
      }
 } #foreach
 
Write-Verbose -message "Exporting process to xml"
$p | export-clixml -Path c:\lsass.xml

Write-Verbose -Message "Finished $workflowcommandname"
}

Workflow Test-Suspend {

"{0} Starting $WorkflowCommandName on {1}" -f (Get-Date).TimeOfDay

$start=Get-Date
$p=get-process -Name lsass

start-sleep -Seconds 5
$a=123
"a originally = $a"

#suspending will automatically create a job
Suspend-workflow

<#
  look at jobs
  exit PowerShell sessions
  open a new session
  Run Get-Job
  Import-module PSWorkflow
  Run Get-Job
  Resume job
  receive job results
#>

#we'll only see results from this point on when you resume the job
$a*=2

"a is finally $a"

InlineScript { $using:p}

$endtime=Get-Date

"Total elapsed time = {0}" -f ($endtime-$start)

"{0} Ending $workflowcommandname on {1}" -f (Get-Date).TimeOfDay,$($pscomputername)

}


Workflow Test-Persistence2 {

<#
1. Run with no parameters then reboot after the countdown has begun.
   Open PowerShell and check for workflows or jobs. Don't forget to
   import the PSWorkflow module. If there is a job, resume it and get
   job results. What did you get?

2. Run with workflow with -pspersist $True and repeat.

3. Run the workflow -asJob. 
   Run Get-Job
   Suspend the job with Suspend-Job
   Exit Powershell and start a new session or reboot.
   Import the PSWorkflow module
   Resume the job
   Get results. Did you use -PSPersist $True? What did you get?
#>

"{0} Starting $workflowcommandname" -f (Get-Date).TimeOfDay

$start=Get-Date

$a=0

Do {
  $a
  #get a random process to simulate some activity
  get-process | get-random
  $a++
  Start-Sleep -milliseconds 500
} until ($a -gt 100)

$endtime=Get-Date

"Total elapsed time = {0}" -f ($endtime-$start)

"{0} Ending $WorkflowCommandName" -f (Get-Date).TimeOfDay

}


Workflow Test-SuspendMe {

#this log should be created on $PSComputername
$log="c:\wflog.txt"

$s=Get-Service -name w*

$t="{0} Starting" -f (Get-date).TimeOfDay,$workflowcommandname

$t | out-file -FilePath $log 

#add some sample data to simulate doing something
get-Process | 
Measure-Object -sum -maximum -average -property WS | 
Out-file -FilePath $log -append

$t="{0} restarting" -f (Get-date).TimeOfDay
$t | out-file -FilePath $log -append

#suspending automatically creates a checkpoint
Suspend-workflow

$s | Out-File -FilePath $log -Append
$t="{0} Finished" -f (Get-date).TimeOfDay,$workflowcommandname
$t | Out-File -FilePath $log -Append

}

Workflow Test-SuspendOnError {

Write-Verbose -Message "Starting $workflowcommandname"

<#
 run this workflow, then restart the computer
 when you see the countdown. When an error is
 detected, suspend the workflow which should automatically
 checkpoint the workflow and create a suspended job.

 What happens when you resume the job? Do you get results?
#>

$n=(get-Process).count..0
$p=get-process -Name lsass
start-sleep -Seconds 5

foreach ($i in $n) {
    Try {
        $i
        (get-process -erroraction Stop)[$i] | export-clixml -path "C:\process-$i.xml"
        Start-Sleep -Seconds 1
    }
    Catch {
     Write-Warning -message "An error was detected. Suspending the workflow."
     #Suspend-Workflow automatically creates a checkpoint
     Suspend-Workflow

    } #Catch
    
} #foreach

Write-Verbose -message "Getting variables"
$p
$n.count

Write-Verbose -Message "Finished $workflowcommandname"

} #end Test-SuspendOnError


Workflow Test-SuspendOnError2 {

Write-Verbose -Message "Starting $workflowcommandname"

<#
 run this workflow, then restart the computer
 when you see the countdown. When an error is
 detected, suspend the workflow which should automatically
 checkpoint the workflow and create a suspended job.

 What happens when you resume the job? Do you get results?
#>

$n=(get-Process).count..0
$p=get-process -Name lsass
Write-Verbose -message "Initial checkpoint"
Checkpoint-Workflow
start-sleep -Seconds 5

foreach ($i in $n) {
    Try {
        $i
        (get-process -erroraction Stop)[$i] | export-clixml -path "C:\process-$i.xml"
        Start-Sleep -Seconds 1
    }
    Catch {
     Write-Warning -message "An error was detected. Suspending the workflow."
     Suspend-Workflow

    } #Catch

    #checkpoint on odd numbers
    if ($i%2) {
       Write-verbose -message "Checkpoint $i"
       Checkpoint-Workflow
     }
    
} #foreach

Write-Verbose -message "Getting variables"
$p
$n.count
Write-Verbose -Message "Finished $workflowcommandname"

} #end Test-SuspendOnError2

