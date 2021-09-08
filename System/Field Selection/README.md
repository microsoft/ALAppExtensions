Provides a page where you can look up and select one or more fields from one or more tables. For example, this is useful when you want to set up a KPI on a Role Center.

# Public Objects
## Field Selection (Codeunit 9806)

 Exposes functionality to look up fields.
 

### Open (Method) <a name="Open"></a> 

 Opens the fields lookup page and assigns the selected fields on the  parameter.
 

#### Syntax
```
procedure Open(var SelectedField: Record "Field"): Boolean
```
#### Parameters
*SelectedField ([Record "Field"]())* 

The field record variable to set the selected fields. Any filters on this record will influence the page view.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if a field was selected.

## Fields Lookup (Page 9806)

 List page that contains table fields.
 

### GetSelectedFields (Method) <a name="GetSelectedFields"></a> 

 Gets the currently selected fields.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetSelectedFields(var SelectedField: Record "Field")
```
#### Parameters
*SelectedField ([Record "Field"]())* 

A record that contains the currently selected fields

