This module provides methods for formatting the appearance of decimal data types in fields on tables, reports, and pages.

Use this module to do the following:
- Format decimals for text messages in the same way that the system formats decimals in fields.
- Get the default rounding precision.

For on-premises versions, you can also use this module to personalize expressions for formatting data.

Remarks
This module introduces the following changes:
- The procedure AutoFormatTranslate has been renamed to ResolveAutoFormat.
- Enum type 59 Auto Format is new. 
- The parameter AutoFormatType: Enum Auto Format replaces the parameter AutoFormatType: Integer.
- The logic for cases other than 0 (Enum DefaultFormat) and 11 (Enum CustomFormatExpr) has been moved to Base Application but the behavior is unchanged.
- The publisher OnResolveAutoFormat has the scope OnPrem, but everyone can subscribe to it and implement a new logic for formatting decimal numbers in text messages.

# Public Objects
## Auto Format (Codeunit 45)

 Exposes functionality to format the appearance of decimal data types in fields of a table, report, or page.
 

### ResolveAutoFormat (Method) <a name="ResolveAutoFormat"></a> 

 Formats the appearance of decimal data types.
 Use this method if you need to format decimals for text message in the same way how system formats decimals in fields.
 

#### Syntax
```
procedure ResolveAutoFormat(AutoFormatType: Enum "Auto Format"; AutoFormatExpr: Text[80]): Text[80]
```
#### Parameters
*AutoFormatType ([Enum "Auto Format"]())* 


 A value that determines how data is formatted.
 The values that are available are "0" and "11".
 Use "0" to ignore the value that AutoFormatExpr passes and use the standard format for decimals instead.
 Use "11" to apply a specific format in AutoFormatExpr without additional transformation.
 

*AutoFormatExpr ([Text[80]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

An expression that specifies how to format data.

#### Return Value
*[Text[80]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The resolved expression that defines data formatting
### ReadRounding (Method) <a name="ReadRounding"></a> 

 Gets the default rounding precision.
 

#### Syntax
```
procedure ReadRounding(): Decimal
```
#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

Returns the rounding precision.
### OnAfterResolveAutoFormat (Event) <a name="OnAfterResolveAutoFormat"></a> 

 Integration event to resolve the ResolveAutoFormat procedure.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnAfterResolveAutoFormat(AutoFormatType: Enum "Auto Format"; AutoFormatExpr: Text[80]; var Result: Text[80])
```
#### Parameters
*AutoFormatType ([Enum "Auto Format"]())* 

A value that determines how data is formatted.

*AutoFormatExpr ([Text[80]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

An expression that specifies how to format data.

*Result ([Text[80]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A resolved expression that defines how to format data.

### OnResolveAutoFormat (Event) <a name="OnResolveAutoFormat"></a> 

 Event that is called to resolve cases for AutoFormatTypes other that "0" and "11".
 Subscribe to this event if you want to introduce new AutoFormatTypes.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnResolveAutoFormat(AutoFormatType: Enum "Auto Format"; AutoFormatExpr: Text[80]; var Result: Text[80]; var Resolved: Boolean)
```
#### Parameters
*AutoFormatType ([Enum "Auto Format"]())* 

A value that determines how data is formatted.

*AutoFormatExpr ([Text[80]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

An expression that specifies how to format data.

*Result ([Text[80]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 


 The resolved expression that defines data formatting.
 For example '<Precision,4:4><Standard Format,2> suffix' that depending on your regional settings
 will format decimal into "-12345.6789 suffix" or "-12345,6789 suffix".
 

*Resolved ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

A value that describes whether the data formatting expression is correct.

### OnReadRounding (Event) <a name="OnReadRounding"></a> 

 Integration event to resolve the ReadRounding procedure.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnReadRounding(var AmountRoundingPrecision: Decimal)
```
#### Parameters
*AmountRoundingPrecision ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The decimal value precision.


## Auto Format (Enum 59)

 Formats the appearance of decimal data types.
 

### DefaultFormat (value: 0)


 Ignore the value that AutoFormatExpr passes and use the standard format for decimals instead.
 

### CustomFormatExpr (value: 11)


 Apply a specific format in AutoFormatExpr without additional transformation.
 

