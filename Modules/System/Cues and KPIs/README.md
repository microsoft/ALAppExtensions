This module provides setup pages and interface methods to manage cues in Business Central.

Use this module to do the following:
- Open the Cue Setup End User page with an implicit filter on table ID.
- Retrieve a Cues And KPIs Style enum.
- Convert a Cues And KPIs Style enum to a style text.
- Insert cue setup data.

For on-premises versions, you can also use this module to do the following:
- Change the user of a cue setup entry.
- Publish an event to convert from the style enum to a text value in case of extended enum values.


# Public Objects
## Cues And KPIs (Codeunit 9701)

 Exposes functionality to set up and retrieve styles for cues.
 

### OpenCustomizePageForCurrentUser (Method) <a name="OpenCustomizePageForCurrentUser"></a> 

 Opens the cue setup user page with an implicit filter on table id.
 The page shows previously added entries in the Cue Setup Administration page that have the UserId being either the current user or blank.
 The page also displays all other fields the that the passed table might have of type decimal or integer.
 Closing this page will transfer any changed or added setup entries to the cue setup table.
 

#### Syntax
```
procedure OpenCustomizePageForCurrentUser(TableId: Integer)
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table for which the page will be customized.

### ChangeUserForSetupEntry (Method) <a name="ChangeUserForSetupEntry"></a> 

 Changes the user of a cue setup entry.
 A Recref pointing to the newly modified record is returned by var.
 

#### Syntax
```
[Scope('OnPrem')]
procedure ChangeUserForSetupEntry(var RecRef: RecordRef; Company: Text[30]; UserName: Text[50])
```
#### Parameters
*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

The recordref that poins to the record that will be modified.

*Company ([Text[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The company in which the table will be modified.

*UserName ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The new UserName to which the setup entry will belong to.

### SetCueStyle (Method) <a name="SetCueStyle"></a> 

 Retrieves a Cues And KPIs Style enum based on the cue setup of the provided TableId, FieldID and Amount.
 The computed cue style is returned by var.
 

#### Syntax
```
procedure SetCueStyle(TableID: Integer; FieldID: Integer; Amount: Decimal; var FinalStyle: enum "Cues And KPIs Style")
```
#### Parameters
*TableID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table containing the field for which the style is wanted.

*FieldID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field for which the style is wanted.

*Amount ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The amount for which the style will be calculated based on the threshold values of the setup.

*FinalStyle ([enum "Cues And KPIs Style"]())* 

The amount for which the style will be calculated based on the threshold values of the setup

### ConvertStyleToStyleText (Method) <a name="ConvertStyleToStyleText"></a> 

 Converts a Cues And KPIs Style enum to a style text.
 Enum values 0,7,8,9,10 are defined by default, if custom values are needed take a look at OnConvertStyleToStyleText event.
 

#### Syntax
```
procedure ConvertStyleToStyleText(CueStyle: enum "Cues And KPIs Style"): Text
```
#### Parameters
*CueStyle ([enum "Cues And KPIs Style"]())* 

A Cues And KPIs Style enum from which the style text will be converted.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The converted style
### InsertData (Method) <a name="InsertData"></a> 

 Inserts cue setup data. The entries inserted via this method will have no value for the userid field.
 

#### Syntax
```
procedure InsertData(TableID: Integer; FieldNo: Integer; LowRangeStyle: Enum "Cues And KPIs Style"; Threshold1: Decimal;
        MiddleRangeStyle: Enum "Cues And KPIs Style"; Threshold2: Decimal; HighRangeStyle: Enum "Cues And KPIs Style"): Boolean
```
#### Parameters
*TableID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table where the cue is defined.

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field which the cue is based on.

*LowRangeStyle ([Enum "Cues And KPIs Style"]())* 

A Cues And KPIs Style enum representing the style that cues which have a value under threshold 1 will take.

*Threshold1 ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The lower amount which defines which style cues get based on their value

*MiddleRangeStyle ([Enum "Cues And KPIs Style"]())* 

A Cues And KPIs Style enum representing the style that cues which have a value over threshold 1 but under threshold 2 will take.

*Threshold2 ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The upper amount which defines which style cues get based on their value

*HighRangeStyle ([Enum "Cues And KPIs Style"]())* 

A Cues And KPIs Style enum representing the style that cues which have a value over threshold 2 will take.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the data was inserted successfully, false otherwise
### OnConvertStyleToStyleText (Event) <a name="OnConvertStyleToStyleText"></a> 

 Event that is called to convert from the style enum to a text value in case of extended enum values.
 Subscribe to this event if you want to introduce new cue styles.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnConvertStyleToStyleText(CueStyle: Enum "Cues And KPIs Style"; var Result: Text; var Resolved: Boolean)
```
#### Parameters
*CueStyle ([Enum "Cues And KPIs Style"]())* 

A Cues And KPIs Style enum from which the style text will be converted.

*Result ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A text vaue returned by var, which is the result of the conversion from the style enum.

*Resolved ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

A boolean value that describes whether or not the custom conversion was executed.

### OnBeforeGetCustomizedCueStyleOption (Event) <a name="OnBeforeGetCustomizedCueStyleOption"></a> 

 Event that allows definition of cue style for a cue using style enum without the usage of a cue setup table.
 Subscribe to this event if you want to define a cue style for a cue using custom prerequisites.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeGetCustomizedCueStyleOption(TableID: Integer; FieldNo: Integer; CueValue: Decimal; var CueStyle: Enum "Cues And KPIs Style"; var Resolved: Boolean)
```
#### Parameters
*TableID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table where the cue is defined.

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field which the cue is based on.

*CueValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

Cue value parameter that can be used to determine cue style.

*CueStyle ([Enum "Cues And KPIs Style"]())* 

Exit parameter that holds newly determined cue style based on custom prerequisites.

*Resolved ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

A boolean value that describes whether or not the cue style has been determined.


## Cue Setup Administrator (Page 9701)

 List page that contains settings that define the appearance of cues on all pages.
 Administrators can use this page to define a general style, which users can customize from the Cue Setup End User page.
 


## Cue Setup End User (Page 9702)

 List page that contains settings that define the appearance of cues for the current user and page.
 


## Cues And KPIs Style (Enum 9701)

 This enum has the styles for the cues and KPIs on RoleCenter pages.
 The values match the original option field on the Cue Setup table, values 1 to 6 are blank options to be extended.

The values match the original option field on the Cue Setup table, values 1 to 6 are blank options to be extended.

### None (value: 0)


 Specifies that no style will be used when rendering the cue.
 

### Favorable (value: 7)


 Specifies that the Favorable style will be used when rendering the cue.
 

### Unfavorable (value: 8)


 Specifies that the Unfavorable style will be used when rendering the cue.
 

### Ambiguous (value: 9)


 Specifies that the Ambiguous style will be used when rendering the cue.
 

### Subordinate (value: 10)


 Specifies that the Subordinate style will be used when rendering the cue.
 

