write-warning 'This is a set of walk through demos, not a script you doofus.'
return


#region Managing at Scale

$computers = "dom1","srv1","srv2","win10","srv4"

Measure-Command {
$r = Get-service bits,winrm -ComputerName $computers | 
 Select Name,Status,Machinename
}

$r

Measure-Command {
#some additional overhead here
$r = Invoke-Command { get-service bits,winrm} -computername $computers |
Select Name,Status,PSComputername

}

$r

$s = new-pssession -ComputerName $computers
Measure-Command {
#some additional overhead here
$r = Invoke-Command { get-service bits,winrm} -session $s |
Select Name,Status,PSComputername

}

Remove-PSSession $s

#repeat with a problem
$computers = "dom1","srv1","srv2","srv3","win10","srv4"

#improve with sessions
#leverage the pipeline
#make remote servers do the work

$computers = "dom1","srv1","srv2","srv4"

#you could do this
$data = foreach ($computer in $computers) {
  Get-ciminstance -ClassName Win32_OperatingSystem -ComputerName $computer
}

$data | Select @{Name="Computername";Expression={$_.CSName}},
 @{Name="OS";Expression={$_.Caption}},LastBootUptime,
 @{Name="Uptime";Expression = { (Get-Date) - $_.LastbootupTime}} |
 Sort Uptime -Descending

Invoke-Command {
 Get-ciminstance -ClassName Win32_OperatingSystem | 
 Select @{Name="Computername";Expression={$_.CSName}},
 @{Name="OS";Expression={$_.Caption}},LastBootUptime,
 @{Name="Uptime";Expression = { (Get-Date) - $_.LastbootupTime}}
} -HideComputerName -computername $computers | 
Select -Property * -ExcludeProperty runspaceID | Sort Uptime -Descending


#endregion

#region Command to Tool

#take GetInfo.ps1 from interactive command to tool
psedit .\scripting\infoscript.ps1
psedit .\scripting\info6.ps1

#modules
dir .\scripting\HelpDesk
code .\scripting\HelpDesk
#explore module structure
#Platyps documentation
#demo

#endregion

#region Controller Scripts

#create an HTML report based on HelpDesk tools
psedit .\scripting\CreateVolumeReport.ps1
start .\DiskReport.htm

#endregion

#region Proxy and Wrappers

Find-Module psscripttools
Import-Module PSScriptTools
Get-Command -Module PSScriptTools
help copy-command

Copy-Command -Command Get-Service -NewName Get-BitsService
psedit .\scripting\Get-BitsService.ps1

Copy-Command -Command Get-Ciminstance -NewName Get-MyOS -IncludeDynamic -AsProxy -UseForwardHelp

psedit .\scripting\Get-MyOS.ps1

#endregion

#region Scheduled Jobs
psedit .\Demo-ScheduledJob.ps1

#endregion

#region Plaster Templates

#https://github.com/powershell/plaster
find-module plaster

get-command -Module plaster
Get-PlasterTemplate

help New-PlasterManifest
#must be this file name
$new = "c:\work\plastermanifest.xml"
$params = @{
    Path = $new 
    TemplateName = "MyTool" 
    TemplateType = "Project" 
    Title = "My Tool" 
    Description = "Scaffold a MyTool project" 
    Author = "Jeff Hicks" 
    Tags = "module" 
    TemplateVersion = "0.0.1"
}
New-PlasterManifest @params 
psedit $new

code .\scripting\myTemplates

#mytemplates has been copied to Programfiles
Get-PlasterTemplate -IncludeInstalledModules | tee -Variable t

Invoke-Plaster -TemplatePath $t[2].TemplatePath C:\scripts\PSChatt

#add a command
Invoke-Plaster -TemplatePath $t[3].TemplatePath -DestinationPath c:\scripts\PSChatt
psedit $t[3].TemplatePath

#you can also skip interactive
$hash = @{
  TemplatePath = $t[3].TemplatePath
  DestinationPath = "c:\scripts\pschatt"
  #these are template parameters
  Name = "Set-Magic"
  Version = "0.1.0"
  OutputType = "[PSCustomobject]"
  ShouldProcess = "yes"
  Help = "no"
  Computername = "yes"
  Force = $True
  NoLogo = $True
}

Invoke-Plaster @hash
#open new project in VS Code
code c:\scripts\pschatt

#reset demo
# del c:\scripts\pschatt -Recurse -force

#endregion

#region PowerShell Workflow

psedit .\demo-workflows.ps1
psedit .\demo-workflowparallel.ps1

#endregion

#region Desired State Configuration

#walk through concepts
#create and deploy a config to SRV4

#endregion

