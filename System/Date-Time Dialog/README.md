The modules consists of a page to enter a date-time value.

Usage example:

```
procedure LookupDateTime(InitialValue: DateTime): DateTime
var
    DateTimeDialog: Page "Date-Time Dialog";
    NewValue: DateTime;
begin
    DateTimeDialog.SetDateTime(InitialValue);

    if DateTimeDialog.RunModal() = Action::OK then
        NewValue := DateTimeDialog.GetDateTime;

    exit(NewValue);
end;
```


# Public Objects
## Date-Time Dialog (Page 684)

 Dialog for entering DataTime values.
 

### SetDateTime (Method) <a name="SetDateTime"></a> 

 Setter method to initialize the Date and Time fields on the page.
 

#### Syntax
```
procedure SetDateTime(DateTime: DateTime)
```
#### Parameters
*DateTime ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The value to set.

### GetDateTime (Method) <a name="GetDateTime"></a> 

 Getter method for the entered datatime value.
 

#### Syntax
```
procedure GetDateTime(): DateTime
```
#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

The value that is set on the page.
