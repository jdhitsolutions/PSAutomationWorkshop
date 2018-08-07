#requires -version 5.0

#dot source supporting files
. $PSScriptRoot\functions.ps1
. $PSScriptroot\vars.ps1

#define an alias
Set-Alias -Name gn -Value Get-Info

#Export-ModuleMember -Function Get-Info,Get-Hwinfo -Alias gn -Variable helpdesk
#there is a bug where variables won't get exported from the manifest
Export-ModuleMember -Variable helpdesk,domaincomputers 