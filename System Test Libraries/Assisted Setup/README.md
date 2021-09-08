# Public Objects
## Assisted Setup Test Library (Codeunit 132585)
### DeleteAll (Method) <a name="DeleteAll"></a> 
Clears the assisted setup records.

#### Syntax
```
procedure DeleteAll()
```
### Delete (Method) <a name="Delete"></a> 
Deletes the given assisted setup.

#### Syntax
```
procedure Delete(ExtensionId: Guid; PageID: Integer)
```
#### Parameters
*ExtensionId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The page ID that should be opened when the user clicks on the setup.

### SetStatusToNotCompleted (Method) <a name="SetStatusToNotCompleted"></a> 
Changes the status of an Assisted Setup to be incomplete.

#### Syntax
```
procedure SetStatusToNotCompleted(ExtensionId: Guid; PageID: Integer)
```
#### Parameters
*ExtensionId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The page ID that should be opened when the user clicks on the setup.

### CallOnRegister (Method) <a name="CallOnRegister"></a> 
 Calls the event that asks subscribers to register respective setups.

#### Syntax
```
procedure CallOnRegister()
```
### HasAny (Method) <a name="HasAny"></a> 
Has any assisted setup records.

#### Syntax
```
procedure HasAny(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### Exists (Method) <a name="Exists"></a> 
Checks if a given setup record exists in the system.

#### Syntax
```
procedure Exists(ExtensionId: Guid; PageID: Integer): Boolean
```
#### Parameters
*ExtensionId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The page ID that should be opened when the user clicks on the setup.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### FirstPageID (Method) <a name="FirstPageID"></a> 
Gets the page id of the first setup record.

#### Syntax
```
procedure FirstPageID(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*


