---
external help file: HelpDesk-help.xml
Module Name: HelpDesk
online version:
schema: 2.0.0
---

# Get-HWInfo

## SYNOPSIS

Get hardware information.

## SYNTAX

```yaml
Get-HWInfo [[-Computername] <String>] [<CommonParameters>]
```

## DESCRIPTION

Get server hardware detail

## EXAMPLES

### Example 1

```powershell
PS C:\> get-hwinfo srv1

Name Version OS              FreeGB
---- ------- --              ------
SRV1 v2.0.0  Windows Unicorn   7.97
```

## PARAMETERS

### -Computername

The name of a computer to check.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Get-Info]()