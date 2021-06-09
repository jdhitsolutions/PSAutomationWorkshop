---
external help file: HelpDesk-help.xml
Module Name: HelpDesk
online version:
schema: 2.0.0
---

# Get-VolumeReport

## SYNOPSIS
Get volume report summary information.

## SYNTAX

### computer (Default)
```
Get-VolumeReport [[-Computername] <String>] [-Drive <String>] [<CommonParameters>]
```

### session
```
Get-VolumeReport -Cimsession <CimSession[]> [-Drive <String>] [<CommonParameters>]
```

## DESCRIPTION
Use this command to get summary information about a storage volume on a remote server.

## EXAMPLES

### Example 1
```
PS C:\> Get-VolumeReport -computername SRV7

Driveletter   : C
Size          : 254721126400
SizeRemaining : 11003076608
HealthStatus  : Healthy
Date          : 8/6/2018 12:10:10 PM
Computername  : SRV7
```

Get volume summary information for drive C on SRV7.

## PARAMETERS

### -Cimsession
A Cimsession object to a remote computer.

```yaml
Type: CimSession[]
Parameter Sets: session
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Computername
Enter a computername

```yaml
Type: String
Parameter Sets: computer
Aliases:

Required: False
Position: 0
Default value: Local host
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Drive
Enter a drive letter like C or D without the colon.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: C
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Microsoft.Management.Infrastructure.CimSession[]

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Get-HWInfo]()

