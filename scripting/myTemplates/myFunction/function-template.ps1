#requires -version 5.0

<%
@"
# version: $PLASTER_PARAM_version
# created: $PLASTER_Date
"@
%>

<%
"Function $PLASTER_PARAM_Name {"
%>
<%
    If ($PLASTER_PARAM_Help -eq 'Yes')
    {
        @"
  <#
    .SYNOPSIS
      Short description
    .DESCRIPTION
      Long description
    .PARAMETER XXX
      Describe the parameter
    .EXAMPLE
      Example of how to use this cmdlet
    .NOTES
      insert any notes
    .LINK
      insert links
  #>
"@
    }
%>
<%
    if ($PLASTER_PARAM_ShouldProcess -eq 'Yes') {
        "[cmdletbinding(SupportsShouldProcess)]"
    }
    else {
        "[cmdletbinding()]"
    }
%>
<%
"[OutputType($PLASTER_PARAM_OutputType)]"
%>

<%
    if ($PLASTER_PARAM_computername -eq 'Yes') {
    @'
    Param(
        [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
'@
    }
    else {
    @'
    Param()
'@ 
    }
%>

    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    } #begin

    Process {
<%
        if ($PLASTER_PARAM_computername -eq 'Yes') {
            @'
            Foreach ($computer in $Computername) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing $($computer.toUpper())"
              #<insert code here>
            }
'@
        }
        else {
            'Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing"'
        }
%>       
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end 

<%
"} #close $PLASTER_PARAM_Name "
%>
