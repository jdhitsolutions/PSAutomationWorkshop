#this is the PowerShell code that works interactively in the console

$computername = Read-Host "Enter a computername"

gcim win32_operatingsystem -comp $computername | 
Select Caption,Version,
@{Name="Uptime";Expression={(Get-Date) - $_.lastbootuptime}},
@{Name="MemoryGB";Expression={$_.totalvisiblememorysize/1MB -as [int32]}},
@{Name="PhysicalProcessors";Expression = { (gcim win32_computersystem -ComputerName $computername -Property NumberOfProcessors).NumberOfProcessors }},
@{Name="LogicalProcessors";Expression = { (gcim win32_computersystem -ComputerName $computername -property NumberOfLogicalProcessors).NumberOfLogicalProcessors }},
@{Name="ComputerName";Expression={$_.CSName}}
