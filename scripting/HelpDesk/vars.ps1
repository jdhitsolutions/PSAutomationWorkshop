#functions to export to user in this module

$HelpDesk = "Please contact the HelpDesk at x1234"

#import the list of computers, filtering out blanks and trimming spaces.
$DomainComputers = (Get-Content $PSScriptRoot\computers.txt).where({$_ -match "\w+"}).foreach({$_.trim()})
