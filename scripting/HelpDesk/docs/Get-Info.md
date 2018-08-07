---
external help file: HelpDesk-help.xml
Module Name: HelpDesk
online version:
schema: 2.0.0
---

# Get-Info

## SYNOPSIS

Get help desk server information

## SYNTAX

```yaml
Get-Info [[-Computername] <String[]>] [-Credential <PSCredential>] [-LogFailures] [<CommonParameters>]
```

## DESCRIPTION

Use this command to get basic server information.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-Info SRV1


Operatingsystem    : Microsoft Windows Server 2016 Standard Evaluation
Version            : 10.0.14393
Uptime             : 1.05:39:22.5945412
MemoryGB           : 1
PhysicalProcessors : 1
LogicalProcessors  : 1
ComputerName       : SRV1
```

## PARAMETERS

### -Computername

The name of the computer to query. You must have admin rights.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: cn
 
Required: False
Position: 1
Default value: $env:computername
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -LogFailures

Create a log file of computers that failed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Specify an alternate credential.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Last Updated: 6 August, 2018

## RELATED LINKS

[Get-CimInstance]()

[Get-HWInfo]()

[Get-VolumeReport]()