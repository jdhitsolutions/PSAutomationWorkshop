#requires -version 5.0
#requires -module Storage

#create a disk space report
[cmdletbinding()]
Param(
    #the name of the html file. Do not specify the path
    [string]$Path = "DiskReport.htm"
)

#manually import the module because it isn't part of my
#usual %PSMODULEPATH% which you would use.
Import-Module $PSScriptRoot\helpdesk\helpdesk.psd1

$Computername = $domaincomputers

#initialize an array
$fragments = @("<h1>Company.pri</h1>")

$progParam = @{
    Activity         = "Domain Volume Report"
    Status           = "Querying domain members"
    Percentcomplete  = 0
    CurrentOperation = ""
}

#initialize a counter for the progress bar
$i = 0

foreach ($computer in $Computername) {
    $i++
    $progParam.CurrentOperation = $Computer

    $progparam.percentcomplete = ($i / $computername.count) * 100
    Write-Progress @progParam

    Try {
   
        $disk = Get-volumeReport -computername $computer

        $fragments += "<H2>$($computer.toUpper())</H2>"
        $fragments += $disk | Select-object -property DriveLetter, HealthStatus,
        @{Name = "SizeGB"; Expression = {$_.size / 1gb -as [int]}},
        @{Name = "RemainingGB"; Expression = {$_.sizeremaining / 1gb }} |
            ConvertTo-Html

    }
    Catch {
        Write-warning "$_.Exception.message"
    }
} #foreach

If ($fragments.count -gt 0) {

    $head = @"
<title>Domain Volume Report</title>
<style>
Body {
font-family: "Tahoma", "Arial", "Helvetica", sans-serif;
background-color:#F0E68C;
}
table
{
border-collapse:collapse;
width:75%
}
td 
{
font-size:12pt;
border:1px #0000FF solid;
padding:2px 2px 2px 2px;
}
th 
{
font-size:14pt;
text-align:center;
padding-top:2px;
padding-bottom:2px;
padding-left:2px;
padding-right:2px;
background-color:#0000FF;
color:#FFFFFF;
}
name tr
{
color:#000000;
background-color:#0000FF;
}
h2
{
font-size:12pt;
}
</style>
"@

    $footer = @"
<h5><i>Run date: $(Get-Date)<br>
Computer: $env:computername<br>
Script: $((get-item $myinvocation.InvocationName).fullname)</i></h5>
"@

    #define a hashtable of parameters to splat to ConvertTo-Html
    $cParams = @{
        Head        = $head
        Body        = $fragments 
        PostContent = $footer    
    }

    #create the HTML and save it to a file
    ConvertTo-Html @cParams | Out-File -FilePath $path -Encoding ascii
    Write-Host "See $path for your report." -ForegroundColor green 
}