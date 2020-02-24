This module aggregates all cases where the functionality is set up manually. Lists, describes, and opens pages that are used to manually set up business processes and general entities. 

Use this module to do the following:
- Insert a manual setup page for an extension.
- Open the Manual Setup page.

For example, setups for business processes include posting groups and general ledger setup. General entities include currency setup, language setup, and so on.


# Public Objects
## Manual Setup (Codeunit 1875)

 The manual setup aggregates all cases where the functionality is setup manually. Typically this is accomplished 
 by registering the setup page ID of the extension that contains the functionality.
 

### Insert (Method) <a name="Insert"></a> 
Insert a manual setup page for an extension.

#### Syntax
```
procedure Insert(Name: Text[50]; Description: Text[250]; Keywords: Text[250]; RunPage: Integer; ExtensionId: Guid; Category: Enum "Manual Setup Category")
```
#### Parameters
*Name ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the setup.

*Description ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The description of the setup.

*Keywords ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The keywords related to the setup.

*RunPage ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The page ID of the setup page to be run.

*ExtensionId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the extension that the caller is in. This is used to fetch the icon for the setup.

*Category ([Enum "Manual Setup Category"]())* 

The category that this manual setup belongs to.

### Open (Method) <a name="Open"></a> 
Opens the Manual Setup page with the setup guides in it.

#### Syntax
```
procedure Open()
```
### Open (Method) <a name="Open"></a> 
Opens the Manual Setup page with the setup guides filtered on a selected group of guides.

#### Syntax
```
procedure Open(ManualSetupCategory: Enum "Manual Setup Category")
```
#### Parameters
*ManualSetupCategory ([Enum "Manual Setup Category"]())* 

The group which the view should be filtered to.

### GetPageIDs (Method) <a name="GetPageIDs"></a> 
Register the manual setups and get the list of page IDs that have been registered.

#### Syntax
```
procedure GetPageIDs(var PageIDs: List of [Integer])
```
#### Parameters
*PageIDs ([List of [Integer]]())* 

The reference to the list of page IDs for manual setups.

### OnRegisterManualSetup (Event) <a name="OnRegisterManualSetup"></a> 

 The event that is raised so that subscribers can add the new manual setups that can be displayed in the Manual Setup page.
 


 The subscriber should call [Insert](#Insert) on the Sender object.
 

#### Syntax
```
[IntegrationEvent(true, false)]
internal procedure OnRegisterManualSetup()
```

## Manual Setup (Page 1875)
This page shows all registered manual setups.


## Manual Setup Category (Enum 1875)
The category enum is used to navigate the setup page, which can have many records. It is encouraged to extend this enum and use the newly defined options.

### Uncategorized (value: 0)


 A default category, specifying that the manual setup is not categorized.
 

