Exposes ability for selecting and displaying time zones.

# Public Objects
## Time Zone Selection (Codeunit 9198)

 Provides basic functionality to lookup page for Time zones.
 

### LookupTimeZone (Method) <a name="LookupTimeZone"></a> 

 Opens a window for viewing and selecting a Time Zone.
 

#### Syntax
```
procedure LookupTimeZone(var TimeZoneText: Text[180]): Boolean
```
#### Parameters
*TimeZoneText ([Text[180]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Out parameter with the Time Zone id of the selected Time Zone.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if a timezone was selected.
### ValidateTimeZone (Method) <a name="ValidateTimeZone"></a> 

 Validate a time zone text given as input and converts it into a Time Zone ID.
 

#### Syntax
```
procedure ValidateTimeZone(var TimeZoneText: Text[180])
```
#### Parameters
*TimeZoneText ([Text[180]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Time Zone text to validate.

### GetTimeZoneDisplayName (Method) <a name="GetTimeZoneDisplayName"></a> 

 Finds the Time Zone that matches the given text and returns its display name.
 

#### Syntax
```
procedure GetTimeZoneDisplayName(TimeZoneText: Text[180]): Text[250]
```
#### Parameters
*TimeZoneText ([Text[180]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The search query for the Time Zone.

#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The Display Name of the Time Zone.

## Time Zones Lookup (Page 9216)

 List page that contains all Time zones.
 

