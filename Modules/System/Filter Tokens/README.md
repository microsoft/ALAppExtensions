This module enhances filtering by enabling users to enter additional filter tokens. 
The Code or Text filters accept the %me, %user, and %company filter tokens. 

The Date, Time, and DateTime filters accept the %today, %workdate, %yesterday, %tomorrow, %week, %month, %quarter filter tokens. 

In addition, the Date filters support date formulas. 
You can add more filter tokens by subscribing to the following events:
- `OnResolveDateFilterToken`
- `OnResolveTextFilterToken`
- `OnResolveTimeFilterToken`
- `OnResolveDateTokenFromDateTimeFilter`
- `OnResolveTimeTokenFromDateTimeFilter`


# Public Objects
## Filter Tokens (Codeunit 41)

 Exposes functionality that allow users to specify pre-defined filter tokens that get converted to the correct values for various data types when filtering records.
 

### MakeDateFilter (Method) <a name="MakeDateFilter"></a> 

 Turns text that represents date formats into a valid date filter expression with respect to filter tokens and date formulas.
 Call this function from onValidate trigger of page field that should behave similar to system filters.
 The text from which the date filter should be extracted passed as VAR. For example: "YESTERDAY", or " 01-01-2012 ".

#### Syntax
```
procedure MakeDateFilter(var DateFilterText: Text)
```
#### Parameters
*DateFilterText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text from which the date filter should be extracted passed as VAR. For example: "YESTERDAY", or " 01-01-2012 ".

### MakeTimeFilter (Method) <a name="MakeTimeFilter"></a> 

 Turns text that represents a time into a valid time filter with respect to filter tokens.
 Call this function from onValidate trigger of page field that should behave similar to system filters.
 

#### Syntax
```
procedure MakeTimeFilter(var TimeFilterText: Text)
```
#### Parameters
*TimeFilterText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text from which the time filter should be extracted, passed as VAR. For example: "NOW".

### MakeTextFilter (Method) <a name="MakeTextFilter"></a> 

 Turns text into a valid text filter with respect to filter tokens.
 Call this function from onValidate trigger of page field that should behave similar to system filters.
 

#### Syntax
```
procedure MakeTextFilter(var TextFilter: Text)
```
#### Parameters
*TextFilter ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The expression from which the text filter should be extracted, passed as VAR. For example: "ME".

### MakeDateTimeFilter (Method) <a name="MakeDateTimeFilter"></a> 

 Turns text that represents a DateTime into a valid date and time filter with respect to filter tokens.
 Call this function from onValidate trigger of page field that should behave similar to system filters.
 

#### Syntax
```
procedure MakeDateTimeFilter(var DateTimeFilterText: Text)
```
#### Parameters
*DateTimeFilterText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text from which the date and time should be extracted, passed as VAR. For example: "NOW" or "01-01-2012 11:11:11..NOW".

### OnResolveDateFilterToken (Event) <a name="OnResolveDateFilterToken"></a> 

 Use this event if you want to add support for additional tokens that user will be able to use when working with date filters, for example "Christmas" or "StoneAge".
 Ensure that in your subscriber you check that what user entered contains your keyword, then return proper date range for your filter token.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnResolveDateFilterToken(DateToken: Text; var FromDate: Date; var ToDate: Date; var Handled: Boolean)
```
#### Parameters
*DateToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The date token to resolve, for example: "Summer".

*FromDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date to resolve from DateToken that the filter will use, for example: "01/06/2019". Passed by reference by using VAR keywords.

*ToDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date to resolve from DateToken that the filter will use, for example: "31/08/2019". Passed by reference by using VAR keywords.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Stores whether the operation was successful.

### OnResolveTextFilterToken (Event) <a name="OnResolveTextFilterToken"></a> 

 Use this event if you want to add support for additional filter tokens that user will be able to use when working with text or code filters, for example "MyFilter".
 Ensure that in your subscriber you check that what user entered contains your token, then return properly formatted text for your filter token.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnResolveTextFilterToken(TextToken: Text; var TextFilter: Text; var Handled: Boolean)
```
#### Parameters
*TextToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text token to resolve.

*TextFilter ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to translate into a properly formatted text filter.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Stores whether the operation was successful.

### OnResolveTimeFilterToken (Event) <a name="OnResolveTimeFilterToken"></a> 

 Use this event if you want to add support for additional filter tokens that user will be able to use when working with time filters, for example "Lunch".
 Ensure that in your subscriber you check that what user entered contains your token, then return properly formatted time for your filter token.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnResolveTimeFilterToken(TimeToken: Text; var TimeFilter: Time; var Handled: Boolean)
```
#### Parameters
*TimeToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The time token to resolve, for example: "Lunch".

*TimeFilter ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The text to translate into a properly formatted time filter, for example: "12:00:00".

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Stores whether the operation was successful.

### OnResolveDateTokenFromDateTimeFilter (Event) <a name="OnResolveDateTokenFromDateTimeFilter"></a> 

 Use this event if you want to add support for additional filter tokens that user will be able to use as date in DateTime filters.
 Parses and translates a date token into a date filter.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnResolveDateTokenFromDateTimeFilter(DateToken: Text; var DateFilter: Date; var Handled: Boolean)
```
#### Parameters
*DateToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The date token to resolve, for example: "Christmas".

*DateFilter ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The text to translate into a properly formatted date filter, for example: "25/12/2019".

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Stores whether the operation was successful.

### OnResolveTimeTokenFromDateTimeFilter (Event) <a name="OnResolveTimeTokenFromDateTimeFilter"></a> 

 Use this event if you want to add support for additional filter tokens that user will be able to use as time in DateTime filters.
 Parses and translates a time token into a time filter.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnResolveTimeTokenFromDateTimeFilter(TimeToken: Text; var TimeFilter: Time; var Handled: Boolean)
```
#### Parameters
*TimeToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The time token to resolve, for example: "Lunch".

*TimeFilter ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The text to translate into a properly formatted time filter, for example:"12:00:00".

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Stores whether the operation was successful.

