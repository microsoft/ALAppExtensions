# System Application

The System Application is the interface to the Business Central platform and cloud ecosystem. Currently, the collection of system application modules looks as follows:

<img src="https://cloudblogs.microsoft.com/uploads/prod/sites/4/2019/08/image025.png">

# Public Objects

## Data Privacy Entities (Table 1180)

 Displays a list of data privacy entities.
 


## Language (Table 8)

 Table that contains the available application languages.
 

### GetLanguageId (Method) <a name="GetLanguageId"></a> 

 [OBSOLETE] Gets the language ID based on its code.
 

#### Syntax
```
[Obsolete('Please use function with the same name from this modules facade codeunit 43 - "Language".')]
procedure GetLanguageId(LanguageCode: Code[10]): Integer
```
#### Parameters
*LanguageCode ([Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

The code of the language

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The ID for the language code that was provided for this function. If no ID is found for the language code, then it returns 0.

## Tenant Web Service Columns (Table 6711)

 Contains tenant web service column entities.
 


## Tenant Web Service Filter (Table 6712)

 Contains tenant web service filter entities.
 


## Tenant Web Service OData (Table 6710)

 Contains tenant web service OData clause entities.
 


## Web Service Aggregate (Table 9900)

 Contains web services aggregated from Web Services and Tenant Web Services.
 


## Assisted Setup (Codeunit 3725)
Manage setup wizards by allowing adding to the list and updating the status of each.

### Add (Method) <a name="Add"></a> 
Adds an assisted setup record from a given extension so that it can be shown in the list.

#### Syntax
```
procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group")
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*AssistantName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name as shown for the setup.

*GroupName ([Enum "Assisted Setup Group"]())* 

The assisted setup group enum that this belongs to.

### Add (Method) <a name="Add"></a> 
Adds an assisted setup record from a given extension so that it can be shown in the list.

#### Syntax
```
procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; HelpLink: Text[250])
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*AssistantName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name as shown for the setup.

*GroupName ([Enum "Assisted Setup Group"]())* 

The assisted setup group enum that this belongs to.

*VideoLink ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL of the video that explains the purpose and use of this setup.

*HelpLink ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The help url that explains the purpose and usage of this setup.

### Add (Method) <a name="Add"></a> 
Adds an assisted setup record from a given extension so that it can be shown in the list.

#### Syntax
```
procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; VideoCategory: Enum "Video Category"; HelpLink: Text[250])
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*AssistantName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name as shown for the setup.

*GroupName ([Enum "Assisted Setup Group"]())* 

The assisted setup group enum that this belongs to.

*VideoLink ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL of the video that explains the purpose and use of this setup.

*VideoCategory ([Enum "Video Category"]())* 

The category of the video for this setup.

*HelpLink ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The help url that explains the purpose and usage of this setup.

### AddTranslation (Method) <a name="AddTranslation"></a> 
Adds the translation for the name of the setup.

#### Syntax
```
procedure AddTranslation(ExtensionID: Guid; PageID: Integer; LanguageID: Integer; TranslatedName: Text)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*LanguageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The language ID for which the translation is made.

*TranslatedName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The translated text of the name.

### IsComplete (Method) <a name="IsComplete"></a> 
Checks whether a user has already completed the setup.

#### Syntax
```
procedure IsComplete(ExtensionID: Guid; PageID: Integer): Boolean
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if the given setup guide has been completed by the user, otherwise false.
### Exists (Method) <a name="Exists"></a> 
Checks whether an assisted setup guide exists.

#### Syntax
```
procedure Exists(ExtensionID: Guid; PageID: Integer): Boolean
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if an assisted setup guide for provided extension and page IDs exists; false otherwise.
### ExistsAndIsNotComplete (Method) <a name="ExistsAndIsNotComplete"></a> 
Checks whether as assisted setup guide exists but has not been completed.

#### Syntax
```
procedure ExistsAndIsNotComplete(ExtensionID: Guid; PageID: Integer): Boolean
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if it exists and is incomplete, false otherwise.
### Complete (Method) <a name="Complete"></a> 
Sets the status of the assisted setup to Complete.

This is typically called from inside the assisted setup guide when the setup is finished.

#### Syntax
```
procedure Complete(ExtensionID: Guid; PageID: Integer)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

### Run (Method) <a name="Run"></a> 
Issues the call to execute the setup.

#### Syntax
```
procedure Run(ExtensionID: Guid; PageID: Integer)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

### Open (Method) <a name="Open"></a> 
Opens the Assisted Setup page with the setup guides in it.

#### Syntax
```
procedure Open()
```
### Open (Method) <a name="Open"></a> 
Opens the Assisted Setup page with the setup guides filtered on a selected group of guides.

#### Syntax
```
procedure Open(AssistedSetupGroup: Enum "Assisted Setup Group")
```
#### Parameters
*AssistedSetupGroup ([Enum "Assisted Setup Group"]())* 

The group of guides to display on the Assisted Setup page.

### OnRegister (Event) <a name="OnRegister"></a> 
Notifies the user that the list of assisted setup guides is being gathered, and that new guides might be added.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnRegister()
```
### OnReRunOfCompletedSetup (Event) <a name="OnReRunOfCompletedSetup"></a> 
Notifies the user that a setup that was previously completed is being run again.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnReRunOfCompletedSetup(ExtensionID: Guid; PageID: Integer; var Handled: Boolean)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the run of the assisted setup guide.

### OnAfterRun (Event) <a name="OnAfterRun"></a> 
Notifies that the run of the assisted setup has finished.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterRun(ExtensionID: Guid; PageID: Integer)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.


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


## Azure AD Graph (Codeunit 9012)

 Exposes functionality to query Azure AD.
 

### GetUser (Method) <a name="GetUser"></a> 

 Gets the user with the specified user principal name from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetUser(UserPrincipalName: Text; var UserInfo: DotNet UserInfo)
```
#### Parameters
*UserPrincipalName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user principal name.

*UserInfo ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The user to return.

### GetCurrentUser (Method) <a name="GetCurrentUser"></a> 

 Gets the current user from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetCurrentUser(var UserInfo: DotNet UserInfo)
```
#### Parameters
*UserInfo ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The user to return.

### GetUserByAuthorizationEmail (Method) <a name="GetUserByAuthorizationEmail"></a> 

 Gets the user with the specified authorization email from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetUserByAuthorizationEmail(AuthorizationEmail: Text; var UserInfo: DotNet UserInfo)
```
#### Parameters
*AuthorizationEmail ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user's authorization email.

*UserInfo ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The user to return.

### GetUserByObjectId (Method) <a name="GetUserByObjectId"></a> 

 Gets the user with the specified object ID from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetUserByObjectId(ObjectId: Text; var UserInfo: DotNet UserInfo)
```
#### Parameters
*ObjectId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The object ID assigned to the user.

*UserInfo ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The user to return.

### TryGetUserByObjectId (Method) <a name="TryGetUserByObjectId"></a> 

 Tries to return the user with the specified object ID from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure TryGetUserByObjectId(ObjectId: Text; var UserInfo: DotNet UserInfo): Boolean
```
#### Parameters
*ObjectId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The object ID assigned to the user.

*UserInfo ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The user to return.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

A boolean that indicates whether the user was retrieved.
### GetUserAssignedPlans (Method) <a name="GetUserAssignedPlans"></a> 

 Gets the assigned plans for the specified user from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetUserAssignedPlans(UserInfo: DotNet UserInfo; var UserAssignedPlans: DotNet GenericList1)
```
#### Parameters
*UserInfo ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The user.

*UserAssignedPlans ([DotNet GenericList1](https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1?view=netframework-4.8))* 

The assigned plans for the user.

### GetUserRoles (Method) <a name="GetUserRoles"></a> 

 Gets the roles assigned to the user from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetUserRoles(UserInfo: DotNet UserInfo; var UserRoles: DotNet GenericIEnumerable1)
```
#### Parameters
*UserInfo ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The user for whom to retrieve the roles.

*UserRoles ([DotNet GenericIEnumerable1](https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.ienumerable-1?view=netframework-4.8))* 

The user's roles.

### GetDirectorySubscribedSkus (Method) <a name="GetDirectorySubscribedSkus"></a> 

 Gets the list of subscriptions owned by the tenant.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetDirectorySubscribedSkus(var DirectorySubscribedSkus: DotNet GenericIEnumerable1)
```
#### Parameters
*DirectorySubscribedSkus ([DotNet GenericIEnumerable1](https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.ienumerable-1?view=netframework-4.8))* 

The list of subscriptions to return.

### GetDirectoryRoles (Method) <a name="GetDirectoryRoles"></a> 

 Gets the directory roles from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetDirectoryRoles(var DirectoryRoles: DotNet GenericIEnumerable1)
```
#### Parameters
*DirectoryRoles ([DotNet GenericIEnumerable1](https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.ienumerable-1?view=netframework-4.8))* 

The directory roles to return.

### GetTenantDetail (Method) <a name="GetTenantDetail"></a> 

 Gets details about the tenant from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetTenantDetail(var TenantInfo: DotNet TenantInfo)
```
#### Parameters
*TenantInfo ([DotNet TenantInfo]())* 

The tenant details to return.

### GetUsersPage (Method) <a name="GetUsersPage"></a> 

 Gets a list of users.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetUsersPage(NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
```
#### Parameters
*NumberOfUsers ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of users to return.

*UserInfoPage ([DotNet UserInfoPage]())* 

The list of users to return.

### SetTestInProgress (Method) <a name="SetTestInProgress"></a> 

 Sets a flag that is used to determine whether a test is in progress or not.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetTestInProgress(TestInProgress: Boolean)
```
#### Parameters
*TestInProgress ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The value to be set to the flag.

### OnInitialize (Event) <a name="OnInitialize"></a> 

 Publishes an event that is used to initialize the Azure AD Graph.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnInitialize(var GraphQuery: DotNet GraphQuery)
```
#### Parameters
*GraphQuery ([DotNet GraphQuery]())* 

The graph that the Azure AD Graph will be initialized with.


## Azure AD Licensing (Codeunit 458)

 Access information about the subscribed SKUs and the corresponding service plans.
 You can retrieve information such as the SKU Object ID, SKU ID, number of licenses assigned, the license state (enabled, suspended, or warning), and the SKU part number.
 For the corresponding service plans, you can retrieve the ID, the capability status, or the name.
 

### ResetSubscribedSKU (Method) <a name="ResetSubscribedSKU"></a> 

 Sets the enumerator for the subscribed SKUs to its initial position, which is before the first subscribed SKU in the collection.
 

#### Syntax
```
procedure ResetSubscribedSKU()
```
### NextSubscribedSKU (Method) <a name="NextSubscribedSKU"></a> 

 Advances the enumerator to the next subscribed SKU in the collection. If only known service plans should be included, it advances to the next SKU known in Business Central.
 

#### Syntax
```
procedure NextSubscribedSKU(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

 True if the enumerator was successfully advanced to the next SKU; false if the enumerator has passed the end of the collection.
### SubscribedSKUCapabilityStatus (Method) <a name="SubscribedSKUCapabilityStatus"></a> 

 Gets the capability status of the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
procedure SubscribedSKUCapabilityStatus(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The capability status of the subscribed SKU, or an empty string if the subscribed SKUs enumerator was not initialized.
### SubscribedSKUConsumedUnits (Method) <a name="SubscribedSKUConsumedUnits"></a> 

 Gets the number of licenses assigned to the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
procedure SubscribedSKUConsumedUnits(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

 The number of licenses that are assigned to the subscribed SKU, or 0 if the subscribed SKUs enumerator was not initialized.
### SubscribedSKUObjectId (Method) <a name="SubscribedSKUObjectId"></a> 

 Gets the object ID of the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
procedure SubscribedSKUObjectId(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The object ID of the current SKU. If the subscribed SKUs enumerator was not initialized, it will return an empty string.
### SubscribedSKUPrepaidUnitsInEnabledState (Method) <a name="SubscribedSKUPrepaidUnitsInEnabledState"></a> 

 Gets the number of prepaid licenses that are enabled for the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
procedure SubscribedSKUPrepaidUnitsInEnabledState(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

 The number of prepaid licenses that are enabled for the subscribed SKU. If the subscribed SKUs enumerator was not initialized it will return 0.
### SubscribedSKUPrepaidUnitsInSuspendedState (Method) <a name="SubscribedSKUPrepaidUnitsInSuspendedState"></a> 

 Gets the number of prepaid licenses that are suspended for the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
procedure SubscribedSKUPrepaidUnitsInSuspendedState(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of prepaid licenses that are suspended for the subscribed SKU. If the subscribed SKUs enumerator was not initialized it will return 0.
### SubscribedSKUPrepaidUnitsInWarningState (Method) <a name="SubscribedSKUPrepaidUnitsInWarningState"></a> 

 Gets the number of prepaid licenses that are in warning status for the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
procedure SubscribedSKUPrepaidUnitsInWarningState(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

 The number of prepaid licenses that are in warning status for the subscribed SKU. If the subscribed SKUs enumerator was not initialized it will return 0.
### SubscribedSKUId (Method) <a name="SubscribedSKUId"></a> 

 Gets the unique identifier (GUID) for the subscribed SKU that the enumerator is currently pointing to in the collection.
 

#### Syntax
```
procedure SubscribedSKUId(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The unique identifier (GUID) of the subscribed SKU; empty string if the subscribed SKUs enumerator was not initialized.
### SubscribedSKUPartNumber (Method) <a name="SubscribedSKUPartNumber"></a> 

 Gets the part number of the subscribed SKU that the enumerator is currently pointing to in the collection. For example, "AAD_PREMIUM" OR "RMSBASIC."
 

#### Syntax
```
procedure SubscribedSKUPartNumber(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The part number of the subscribed SKU or an empty string if the subscribed SKUs enumerator was not initialized.
### ResetServicePlans (Method) <a name="ResetServicePlans"></a> 

 Sets the enumerator for service plans to its initial position, which is before the first service plan in the collection.
 

#### Syntax
```
procedure ResetServicePlans()
```
### NextServicePlan (Method) <a name="NextServicePlan"></a> 

 Advances the enumerator to the next service plan in the collection.
 

#### Syntax
```
procedure NextServicePlan(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

 True if the enumerator was successfully advanced to the next service plan; false if the enumerator has passed the end of the collection or it was not initialized.
### ServicePlanCapabilityStatus (Method) <a name="ServicePlanCapabilityStatus"></a> 

 Gets the service plan capability status.
 

#### Syntax
```
procedure ServicePlanCapabilityStatus(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The capability status of the service plan, or an empty string if the service plan enumerator was not initialized.
### ServicePlanId (Method) <a name="ServicePlanId"></a> 

 Gets the service plan ID.
 

#### Syntax
```
procedure ServicePlanId(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The ID of the service plan, or an empty string if the service plan enumerator was not initialized.
### ServicePlanName (Method) <a name="ServicePlanName"></a> 

 Gets the service plan name.
 

#### Syntax
```
procedure ServicePlanName(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

 The name of the service plan, or an empty string if the service plan enumerator was not initialized.
### IncludeUnknownPlans (Method) <a name="IncludeUnknownPlans"></a> 

 Checks whether to include unknown plans when moving to the next subscribed SKU in the subscribed SKUs collection.
 

#### Syntax
```
procedure IncludeUnknownPlans(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

 True if the unknown service plans should be included. Otherwise, false.
### SetIncludeUnknownPlans (Method) <a name="SetIncludeUnknownPlans"></a> 

 Sets whether to include unknown plans when moving to the next subscribed SKU in subscribed SKUs collection.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetIncludeUnknownPlans(IncludeUnknownPlans: Boolean)
```
#### Parameters
*IncludeUnknownPlans ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The value to be set to the flag.

### SetTestInProgress (Method) <a name="SetTestInProgress"></a> 

 Sets a flag that is used to determine whether a test is in progress or not.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetTestInProgress(TestInProgress: Boolean)
```
#### Parameters
*TestInProgress ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The value to be set to the flag.


## Azure AD Plan (Codeunit 9016)

 Retrieve plans in Azure AD and manage plans
 

### IsPlanAssigned (Method) <a name="IsPlanAssigned"></a> 

 Checks if the plan is assigned to any user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure IsPlanAssigned(PlanGUID: Guid): Boolean
```
#### Parameters
*PlanGUID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

the plan GUID.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

true if the given plan has users assigned to it.
### IsPlanAssignedToUser (Method) <a name="IsPlanAssignedToUser"></a> 

 Checks if the plan is assigned to the current user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure IsPlanAssignedToUser(PlanGUID: Guid): Boolean
```
#### Parameters
*PlanGUID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

the plan GUID.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

true if the given plan is assigned to the current user.
### IsPlanAssignedToUser (Method) <a name="IsPlanAssignedToUser"></a> 

 Checks if the plan is assigned to a specific user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure IsPlanAssignedToUser(PlanGUID: Guid; UserGUID: Guid): Boolean
```
#### Parameters
*PlanGUID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

the plan GUID.

*UserGUID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

the user GUID.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

true if the given plan is assigned to the given user.
### IsGraphUserEntitledFromServicePlan (Method) <a name="IsGraphUserEntitledFromServicePlan"></a> 

 Returns true if the given user is entitled from the service plan.
 

#### Syntax
```
[Scope('OnPrem')]
procedure IsGraphUserEntitledFromServicePlan(var GraphUser: DotNet UserInfo): Boolean
```
#### Parameters
*GraphUser ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

the user to check.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the given user is entitled from the service plan.
### UpdateUserPlans (Method) <a name="UpdateUserPlans"></a> 
OnRemoveUserGroupsForUserAndPlan


 Updates plans for user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure UpdateUserPlans(UserSecurityId: Guid; var GraphUser: DotNet UserInfo)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user to update.

*GraphUser ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The graph user corresponding to the user to update, and containing the information about the plans assigned to the user.

### UpdateUserPlans (Method) <a name="UpdateUserPlans"></a> 
OnRemoveUserGroupsForUserAndPlan


 Updates plans for user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure UpdateUserPlans(UserSecurityId: Guid)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user to update.

### UpdateUserPlans (Method) <a name="UpdateUserPlans"></a> 
OnRemoveUserGroupsForUserAndPlan


 Updates plans for all users.
 

#### Syntax
```
[Scope('OnPrem')]
procedure UpdateUserPlans()
```
### RefreshUserPlanAssignments (Method) <a name="RefreshUserPlanAssignments"></a> 
OnRemoveUserGroupsForUserAndPlan


 Refreshes the user plans assigned to the given user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure RefreshUserPlanAssignments(UserSecurityId: Guid)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user to update.

### TryGetAzureUserPlanRoleCenterId (Method) <a name="TryGetAzureUserPlanRoleCenterId"></a> 

 Returns the plan roleCenterID for the given user.
 

#### Syntax
```
[Scope('OnPrem')]
[TryFunction]
procedure TryGetAzureUserPlanRoleCenterId(var RoleCenterID: Integer; UserSecurityId: Guid)
```
#### Parameters
*RoleCenterID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The roleCenterID to return.

*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user GUID.

### DoPlansExist (Method) <a name="DoPlansExist"></a> 

 Returns true if at least one plan exists.
 

#### Syntax
```
[Scope('OnPrem')]
procedure DoPlansExist(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if at least one plan exist.
### DoUserPlansExist (Method) <a name="DoUserPlansExist"></a> 

 Returns true if at least one user is assigned to a plan.
 

#### Syntax
```
[Scope('OnPrem')]
procedure DoUserPlansExist(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if at least one user is assigned to a plan.
### DoesPlanExist (Method) <a name="DoesPlanExist"></a> 

 Returns true if the given plan exists.
 

#### Syntax
```
[Scope('OnPrem')]
procedure DoesPlanExist(PlanGUID: Guid): Boolean
```
#### Parameters
*PlanGUID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The plan GUID.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if the given plan exists.
### DoesUserHavePlans (Method) <a name="DoesUserHavePlans"></a> 

 Returns true if the given user has at least one plan.
 

#### Syntax
```
[Scope('OnPrem')]
procedure DoesUserHavePlans(UserSecurityId: Guid): Boolean
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user GUID.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if the given user has at least one plan.
### GetAvailablePlansCount (Method) <a name="GetAvailablePlansCount"></a> 

 Returns the total number of available plans.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetAvailablePlansCount(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

Returns the total number of available plans.
### CheckMixedPlans (Method) <a name="CheckMixedPlans"></a> 
OnCanCurrentUserManagePlansAndGroups


 Checks if mixed plans are correctly set.
 

#### Syntax
```
[Scope('OnPrem')]
procedure CheckMixedPlans()
```
### MixedPlansExist (Method) <a name="MixedPlansExist"></a> 

 Returns true if a mixed plan exists. 
 

#### Syntax
```
[Scope('OnPrem')]
procedure MixedPlansExist(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if a mixed plan exists.
### SetTestInProgress (Method) <a name="SetTestInProgress"></a> 

 Sets this codeunit in test mode (for running unit tests).
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetTestInProgress(EnableTestability: Boolean)
```
#### Parameters
*EnableTestability ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True to enable the test mode.

### OnRemoveUserGroupsForUserAndPlan (Event) <a name="OnRemoveUserGroupsForUserAndPlan"></a> 

 Integration event, raised from [UpdateUserPlans](#UpdateUserPlans).
 Subscribe to this event to remove related user groups from the user.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnRemoveUserGroupsForUserAndPlan(PlanID: Guid; UserSecurityID: Guid)
```
#### Parameters
*PlanID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The plan to remove.

*UserSecurityID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user to remove.

### OnUpdateUserAccessForSaaS (Event) <a name="OnUpdateUserAccessForSaaS"></a> 

 Integration event, raised from [UpdateUserPlans](#UpdateUserPlans).
 Subscribe to this event to update the user groups
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnUpdateUserAccessForSaaS(UserSecurityID: Guid; var UserGroupsAdded: Boolean)
```
#### Parameters
*UserSecurityID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user to update.

*UserGroupsAdded ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Whether the user groups were updated

### OnCanCurrentUserManagePlansAndGroups (Event) <a name="OnCanCurrentUserManagePlansAndGroups"></a> 

 Integration event, raised from [CheckMixedPlans](#CheckMixedPlans).
 Subscribe to this event to check whether the user can manage plans and groups
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnCanCurrentUserManagePlansAndGroups(var CanManage: Boolean)
```
#### Parameters
*CanManage ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Whether the user can manage plans and groups


## Plan Ids (Codeunit 9027)

 Exposes functionality to get plan IDs.
 

### GetBasicPlanId (Method) <a name="GetBasicPlanId"></a> 

 Returns the ID for the Basic plan.
 

#### Syntax
```
procedure GetBasicPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Basic plan.
### GetTeamMemberPlanId (Method) <a name="GetTeamMemberPlanId"></a> 

 Returns the ID for the Finance and Operations, Team Member plan.
 

#### Syntax
```
procedure GetTeamMemberPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Finance and Operations, Team Member plan.
### GetEssentialPlanId (Method) <a name="GetEssentialPlanId"></a> 

 Returns the ID for the Finance and Operations plan.
 

#### Syntax
```
procedure GetEssentialPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Finance and Operations plan.
### GetPremiumPlanId (Method) <a name="GetPremiumPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central, Premium User plan.
 

#### Syntax
```
procedure GetPremiumPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central, Premium User plan.
### GetInvoicingPlanId (Method) <a name="GetInvoicingPlanId"></a> 

 Returns the ID for the Microsoft Invoicing plan.
 

#### Syntax
```
procedure GetInvoicingPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Microsoft Invoicing plan.
### GetViralSignupPlanId (Method) <a name="GetViralSignupPlanId"></a> 

 Returns the ID for the Finance and Operations for IWs plan.
 

#### Syntax
```
procedure GetViralSignupPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Finance and Operations for IWs plan.
### GetExternalAccountantPlanId (Method) <a name="GetExternalAccountantPlanId"></a> 

 Returns the ID for the Finance and Operations, External Accountant plan.
 

#### Syntax
```
procedure GetExternalAccountantPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Finance and Operations, External Accountant plan.
### GetDelegatedAdminPlanId (Method) <a name="GetDelegatedAdminPlanId"></a> 

 Returns the ID for the Administrator plan.
 

#### Syntax
```
procedure GetDelegatedAdminPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Administrator plan.
### GetInternalAdminPlanId (Method) <a name="GetInternalAdminPlanId"></a> 

 Returns the ID for the Internal Administrator plan.
 

#### Syntax
```
procedure GetInternalAdminPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Internal Administrator plan.
### GetTeamMemberISVPlanId (Method) <a name="GetTeamMemberISVPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central, Team Member ISV plan.
 

#### Syntax
```
procedure GetTeamMemberISVPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central, Team Member ISV plan.
### GetEssentialISVPlanId (Method) <a name="GetEssentialISVPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central, Essential ISV User plan.
 

#### Syntax
```
procedure GetEssentialISVPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central, Essential ISV User plan.
### GetPremiumISVPlanId (Method) <a name="GetPremiumISVPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central, Premium ISV User plan.
 

#### Syntax
```
procedure GetPremiumISVPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central, Premium ISV User plan.
### GetDeviceISVPlanId (Method) <a name="GetDeviceISVPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central Device - Embedded plan.
 

#### Syntax
```
procedure GetDeviceISVPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central Device - Embedded plan.
### GetDevicePlanId (Method) <a name="GetDevicePlanId"></a> 

 Returns the ID for the Finance and Operations, Device plan.
 

#### Syntax
```
procedure GetDevicePlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Finance and Operations, Device plan.

## Plan Upgrade Tag (Codeunit 9058)

 Exposes functionality to retrieve the device upgrade tag.
 

### GetAddDeviceISVEmbUpgradeTag (Method) <a name="GetAddDeviceISVEmbUpgradeTag"></a> 

 Returns the device upgrade tag.
 

#### Syntax
```
procedure GetAddDeviceISVEmbUpgradeTag(): Code[250]
```
#### Return Value
*[Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type)*

The device upgrade tag.

## Azure AD Tenant (Codeunit 433)

 Exposes functionality to fetch attributes concerning the current tenant.
 

### GetAadTenantId (Method) <a name="GetAadTenantId"></a> 

 Gets the tenant AAD ID.
 

#### Syntax
```
procedure GetAadTenantId(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

If it cannot be found, an empty string is returned.
### GetAadTenantDomainName (Method) <a name="GetAadTenantDomainName"></a> 
Cannot retrieve the Azure Active Directory tenant domain name.


 Gets the Azure Active Directory tenant domain name.
 If the Microsoft Graph API cannot be reached, the error is displayed.
 

#### Syntax
```
procedure GetAadTenantDomainName(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The AAD Tenant Domain Name.

## Azure AD Graph User (Codeunit 9024)

 Exposes functionality to retrieve and update Azure AD users.
 

### GetGraphUser (Method) <a name="GetGraphUser"></a> 
    
 Gets the Azure AD user with the given security ID.
 

#### Syntax
```
[Scope('OnPrem')]
[TryFunction]
procedure GetGraphUser(UserSecurityId: Guid; var User: DotNet UserInfo)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user's security ID.

*User ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The Azure AD user.

### GetObjectId (Method) <a name="GetObjectId"></a> 

 Retrieves the user’s unique identifier, which is its object ID, from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetObjectId(UserSecurityId: Guid): Text
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user's security ID.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


 The object ID of the Azure AD user, or an empty string if the user cannot be found.
 
### GetUserAuthenticationObjectId (Method) <a name="GetUserAuthenticationObjectId"></a> 
    
 Gets the user's authentication object ID.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetUserAuthenticationObjectId(UserSecurityId: Guid): Text
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user's security ID.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The user's authentication object ID.
### UpdateUserFromAzureGraph (Method) <a name="UpdateUserFromAzureGraph"></a> 
    
 Updates the user record with information from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure UpdateUserFromAzureGraph(var User: Record User; var AzureADUser: DotNet UserInfo): Boolean
```
#### Parameters
*User ([Record User]())* 

The user record to update.

*AzureADUser ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The Azure AD user.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the user record has been updated. Otherwise, false.
### EnsureAuthenticationEmailIsNotInUse (Method) <a name="EnsureAuthenticationEmailIsNotInUse"></a> 
    
 Ensures that an email address specified for authorization is not already in use by another database user.
 If it is, all the database users with this authentication email address are updated and their email 
 addresses are updated the ones that are specified in Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
procedure EnsureAuthenticationEmailIsNotInUse(AuthenticationEmail: Text)
```
#### Parameters
*AuthenticationEmail ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The authentication email address.

### SetTestInProgress (Method) <a name="SetTestInProgress"></a> 

 Sets a flag that is used to determine whether a test is in progress or not.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetTestInProgress(TestInProgress: Boolean)
```
#### Parameters
*TestInProgress ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 




## Azure AD User Management (Codeunit 9010)

 Exposes functionality to manage Azure AD users.
 

### CreateNewUsersFromAzureAD (Method) <a name="CreateNewUsersFromAzureAD"></a> 
    
 Retrieves all the users from Azure AD. If the users already exist in the database, 
 they are updated to match the ones from Azure AD; otherwise new users are inserted in the database.
 

#### Syntax
```
[Scope('OnPrem')]
procedure CreateNewUsersFromAzureAD()
```
### CreateNewUserFromGraphUser (Method) <a name="CreateNewUserFromGraphUser"></a> 
    
 Creates a new user from an Azure AD user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure CreateNewUserFromGraphUser(GraphUser: DotNet UserInfo)
```
#### Parameters
*GraphUser ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The Azure AD user.

### SynchronizeLicensedUserFromDirectory (Method) <a name="SynchronizeLicensedUserFromDirectory"></a> 
    
 Synchronizes a user with the Azure AD user corresponding to the authentication 
 email that is passed as a parameter. If the user record does not exist, it gets created.
 

#### Syntax
```
procedure SynchronizeLicensedUserFromDirectory(AuthenticationEmail: Text): Boolean
```
#### Parameters
*AuthenticationEmail ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user's authentication email.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there is a user in Azure AD corresponding to the authentication email; otherwise false.
### SynchronizeAllLicensedUsersFromDirectory (Method) <a name="SynchronizeAllLicensedUsersFromDirectory"></a> 
    
 Synchronizes all the users from the database with the ones from Azure AD. If 
 the users do not exist in the database, they get created.
 

#### Syntax
```
procedure SynchronizeAllLicensedUsersFromDirectory()
```
### IsUserTenantAdmin (Method) <a name="IsUserTenantAdmin"></a> 
    
 Checks if the user is a tenant admin.
 

#### Syntax
```
procedure IsUserTenantAdmin(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the user is a tenant admin; otherwise false.
### SetTestInProgress (Method) <a name="SetTestInProgress"></a> 

 Sets a flag that is used to determine whether a test is in progress or not.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetTestInProgress(TestInProgress: Boolean)
```
#### Parameters
*TestInProgress ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The value to be set to the flag.


## Azure Key Vault (Codeunit 2200)

 Exposes functionality to handle the retrieval of azure key vault secrets, along with setting the provider and clear the secrets cache used.
 

### GetAzureKeyVaultSecret (Method) <a name="GetAzureKeyVaultSecret"></a> 

 Retrieves a secret from the key vault.
 

This is a try function.

#### Syntax
```
[TryFunction]
[Scope('OnPrem')]
procedure GetAzureKeyVaultSecret(SecretName: Text; var Secret: Text)
```
#### Parameters
*SecretName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the secret to retrieve.

*Secret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Out parameter that holds the secret that was retrieved from the key vault.


## Base64 Convert (Codeunit 4110)

 Converts text to and from its base-64 representation.
 

### ToBase64 (Method) <a name="ToBase64"></a> 

 Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
 

#### Syntax
```
procedure ToBase64(String: Text): Text
```
#### Parameters
*String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The string representation, in base-64, of the input string.
### ToBase64 (Method) <a name="ToBase64"></a> 

 Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
 

#### Syntax
```
procedure ToBase64(String: Text; InsertLineBreaks: Boolean): Text
```
#### Parameters
*String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

*InsertLineBreaks ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Whether insert line breaks in the output or not.
 If true, inserts line breaks after every 76 characters.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The string representation, in base-64, of the input string.
### ToBase64 (Method) <a name="ToBase64"></a> 

 Converts the value of the input stream to its equivalent string representation that is encoded with base-64 digits.
 

#### Syntax
```
procedure ToBase64(InStream: InStream): Text
```
#### Parameters
*InStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream to read the input from.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The string representation, in base-64, of the input string.
### ToBase64 (Method) <a name="ToBase64"></a> 

 Converts the value of the input stream to its equivalent string representation that is encoded with base-64 digits.
 

#### Syntax
```
procedure ToBase64(InStream: InStream; InsertLineBreaks: Boolean): Text
```
#### Parameters
*InStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream to read the input from.

*InsertLineBreaks ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Whether insert line breaks in the output or not.
 If true, inserts line breaks after every 76 characters.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The string representation, in base-64, of the input string.
### FromBase64 (Method) <a name="FromBase64"></a> 
The length of Base64String, ignoring white-space characters, is not zero or a multiple of 4.


 Converts the specified string, which encodes binary data as base-64 digits, to an equivalent regular string.
 

#### Syntax
```
procedure FromBase64(Base64String: Text): Text
```
#### Parameters
*Base64String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Regular string that is equivalent to the input base-64 string.
### FromBase64 (Method) <a name="FromBase64"></a> 
The length of Base64String, ignoring white-space characters, is not zero or a multiple of 4.


 Converts the specified string, which encodes binary data as base-64 digits, to an equivalent regular string.
 

#### Syntax
```
procedure FromBase64(Base64String: Text; OutStream: OutStream)
```
#### Parameters
*Base64String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to convert.

*OutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The stream to write the output to.


## Persistent Blob (Codeunit 4101)

 The interface for storing BLOB data between sessions.
 

### Create (Method) <a name="Create"></a> 

 Create a new empty PersistentBlob.
 

#### Syntax
```
procedure Create(): BigInteger
```
#### Return Value
*[BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type)*

The key of the new BLOB.
### Exists (Method) <a name="Exists"></a> 

 Check whether a BLOB with the Key exists.
 

#### Syntax
```
procedure Exists("Key": BigInteger): Boolean
```
#### Parameters
*Key ([BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type))* 

The key of the BLOB.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the BLOB with the given key exists.
### Delete (Method) <a name="Delete"></a> 

 Delete the BLOB with the Key.
 

#### Syntax
```
procedure Delete("Key": BigInteger): Boolean
```
#### Parameters
*Key ([BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type))* 

The key of the BLOB.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the BLOB with the given key was deleted.
### CopyFromInStream (Method) <a name="CopyFromInStream"></a> 

 Save the content of the stream to the PersistentBlob.
 

#### Syntax
```
procedure CopyFromInStream("Key": BigInteger; Source: InStream): Boolean
```
#### Parameters
*Key ([BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type))* 

The key of the BLOB.

*Source ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream from which content will be copied to the PersistentBlob.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the BLOB with the given key was updated with the contents of the source.
### CopyToOutStream (Method) <a name="CopyToOutStream"></a> 

 Write the content of the PersistentBlob to the Destination OutStream.
 

#### Syntax
```
procedure CopyToOutStream("Key": BigInteger; Destination: OutStream): Boolean
```
#### Parameters
*Key ([BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type))* 

The key of the BLOB.

*Destination ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream to which the contents of the PersistentBlob will be copied.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the BLOB with the given Key was copied to the Destination.

## Temp Blob (Codeunit 4100)

 The container to store BLOB data in-memory.
 

### CreateInStream (Method) <a name="CreateInStream"></a> 

 Creates an InStream object with default encoding for the TempBlob. This enables you to read data from the TempBlob.
 

#### Syntax
```
procedure CreateInStream(var InStream: InStream)
```
#### Parameters
*InStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream variable passed as a VAR to which the BLOB content will be attached.

### CreateInStream (Method) <a name="CreateInStream"></a> 

 Creates an InStream object with the specified encoding for the TempBlob. This enables you to read data from the TempBlob.
 

#### Syntax
```
procedure CreateInStream(var InStream: InStream; Encoding: TextEncoding)
```
#### Parameters
*InStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream variable passed as a VAR to which the BLOB content will be attached.

*Encoding ([TextEncoding](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-file-handling-and-text-encoding))* 

The text encoding to use.

### CreateOutStream (Method) <a name="CreateOutStream"></a> 

 Creates an OutStream object with default encoding for the TempBlob. This enables you to write data to the TempBlob.
 

#### Syntax
```
procedure CreateOutStream(var OutStream: OutStream)
```
#### Parameters
*OutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream variable passed as a VAR to which the BLOB content will be attached.

### CreateOutStream (Method) <a name="CreateOutStream"></a> 

 Creates an OutStream object with the specified encoding for the TempBlob. This enables you to write data to the TempBlob.
 

#### Syntax
```
procedure CreateOutStream(var OutStream: OutStream; Encoding: TextEncoding)
```
#### Parameters
*OutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream variable passed as a VAR to which the BLOB content will be attached.

*Encoding ([TextEncoding](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-file-handling-and-text-encoding))* 

The text encoding to use.

### HasValue (Method) <a name="HasValue"></a> 

 Determines whether the TempBlob has a value.
 

#### Syntax
```
procedure HasValue(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the TempBlob has a value.
### Length (Method) <a name="Length"></a> 

 Determines the length of the data stored in the TempBlob.
 

#### Syntax
```
procedure Length(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of bytes stored in the BLOB.
### FromRecord (Method) <a name="FromRecord"></a> 

 Copies the value of the BLOB field on the RecordVariant in the specified field to the TempBlob.
 

#### Syntax
```
procedure FromRecord(RecordVariant: Variant; FieldNo: Integer)
```
#### Parameters
*RecordVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

Any Record variable.

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field number of the BLOB field to be read.

### FromRecordRef (Method) <a name="FromRecordRef"></a> 

 Copies the value of the BLOB field on the RecordRef in the specified field to the TempBlob.
 

#### Syntax
```
procedure FromRecordRef(RecordRef: RecordRef; FieldNo: Integer)
```
#### Parameters
*RecordRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

A RecordRef variable attached to a Record.

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field number of the BLOB field to be read.

### ToRecordRef (Method) <a name="ToRecordRef"></a> 

 Copies the value of the TempBlob to the specified field on the RecordRef.
 

#### Syntax
```
procedure ToRecordRef(var RecordRef: RecordRef; FieldNo: Integer)
```
#### Parameters
*RecordRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

A RecordRef variable attached to a Record.

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field number of the Blob field to be written.


## Temp Blob List (Codeunit 4102)

 The interface for storing sequences of variables, each of which stores BLOB data.
 

### Exists (Method) <a name="Exists"></a> 

 Check if an element with the given index exists.
 

#### Syntax
```
procedure Exists(Index: Integer): Boolean
```
#### Parameters
*Index ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index of the TempBlob in the list.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if an element at the given index exists.
### Count (Method) <a name="Count"></a> 

 Returns the number of elements in the list.
 

#### Syntax
```
procedure Count(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of elements in the list.
### Get (Method) <a name="Get"></a> 
The index is larger than the number of elements in the list or less than one.


 Get an element from the list at any given position.
 

#### Syntax
```
procedure Get(Index: Integer; var TempBlob: Codeunit "Temp Blob")
```
#### Parameters
*Index ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index of the TempBlob in the list.

*TempBlob ([Codeunit "Temp Blob"]())* 

The TempBlob to return.

### Set (Method) <a name="Set"></a> 
The index is larger than the number of elements in the list or less than one.


 Set an element at the given index from the parameter TempBlob.
 

#### Syntax
```
procedure Set(Index: Integer; TempBlob: Codeunit "Temp Blob"): Boolean
```
#### Parameters
*Index ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index of the TempBlob in the list.

*TempBlob ([Codeunit "Temp Blob"]())* 

The TempBlob to set.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if successful.
### RemoveAt (Method) <a name="RemoveAt"></a> 
The index is larger than the number of elements in the list or less than one.


 Remove the element at a specified location from a non-empty list.
 

#### Syntax
```
procedure RemoveAt(Index: Integer): Boolean
```
#### Parameters
*Index ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index of the TempBlob in the list.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if successful.
### IsEmpty (Method) <a name="IsEmpty"></a> 

 Return true if the list is empty, otherwise return false.
 

#### Syntax
```
procedure IsEmpty(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the list is empty.
### Add (Method) <a name="Add"></a> 

 Adds a TempBlob to the end of the list.
 

#### Syntax
```
procedure Add(TempBlob: Codeunit "Temp Blob"): Boolean
```
#### Parameters
*TempBlob ([Codeunit "Temp Blob"]())* 

The TempBlob to add.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if successful.
### AddRange (Method) <a name="AddRange"></a> 

 Adds the elements of the specified TempBlobList to the end of the current TempBlobList object.
 

#### Syntax
```
procedure AddRange(TempBlobList: Codeunit "Temp Blob List"): Boolean
```
#### Parameters
*TempBlobList ([Codeunit "Temp Blob List"]())* 

The TempBlob list to add.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if successful.
### GetRange (Method) <a name="GetRange"></a> 
The index is larger than the number of elements in the list or less than one.


 Get a copy of a range of elements in the list starting from index,
 

#### Syntax
```
procedure GetRange(Index: Integer; ElemCount: Integer; var TempBlobListOut: Codeunit "Temp Blob List")
```
#### Parameters
*Index ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index of the first object.

*ElemCount ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of objects to be returned.

*TempBlobListOut ([Codeunit "Temp Blob List"]())* 

The TempBlobList to be returned passed as a VAR.


## Caption Class (Codeunit 42)

 Exposes events that can be used to resolve custom CaptionClass properties.
 

### OnResolveCaptionClass (Event) <a name="OnResolveCaptionClass"></a> 

 Integration event for resolving CaptionClass expression, split into CaptionArea and CaptionExpr.
 Note there should be a single subscriber per caption area.
 The event implements the "resolved" pattern - if a subscriber resolves the caption, it should set Resolved to TRUE.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
```
#### Parameters
*CaptionArea ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The caption area used in the CaptionClass expression. Should be unique for every subscriber.

*CaptionExpr ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The caption expression used for resolving the CaptionClass expression.

*Language ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The current language ID that can be used for resolving the CaptionClass expression.

*Caption ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter - the resolved caption

*Resolved ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Boolean for marking whether the CaptionClass expression was resolved.

### OnAfterCaptionClassResolve (Event) <a name="OnAfterCaptionClassResolve"></a> 

 Integration event for after resolving CaptionClass expression.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterCaptionClassResolve(Language: Integer; CaptionExpression: Text; var Caption: Text[1024])
```
#### Parameters
*Language ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The current language ID.

*CaptionExpression ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The original CaptionClass expression.

*Caption ([Text[1024]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The resolved caption expression.


## Client Type Management (Codeunit 4030)

 Exposes functionality to fetch the client type that the user is currently using.
 

### GetCurrentClientType (Method) <a name="GetCurrentClientType"></a> 
Example 
 `
 IF ClientTypeManagement.GetCurrentClientType IN [CLIENTTYPE::xxx, CLIENTTYPE::yyy] THEN
 `

Gets the current type of the client being used by the caller, e.g. Phone, Web, Tablet etc.

 Use the GetCurrentClientType wrapper method when you want to test a flow on a different type of client.

#### Syntax
```
procedure GetCurrentClientType(): ClientType
```
#### Return Value
*[ClientType](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/clienttype/clienttype-option)*



## Confirm Management (Codeunit 27)

 Exposes functionality to raise a confirm dialog with a question that is to be asked to the user.
 

### GetResponseOrDefault (Method) <a name="GetResponseOrDefault"></a> 

 Raises a confirm dialog with a question and the default response on which the cursor is shown.
 If UI is not allowed, the default response is returned.
 

#### Syntax
```
procedure GetResponseOrDefault(ConfirmQuestion: Text; DefaultButton: Boolean): Boolean
```
#### Parameters
*ConfirmQuestion ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The question to be asked to the user.

*DefaultButton ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The default response expected.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The response of the user or the default response passed if no UI is allowed.
### GetResponse (Method) <a name="GetResponse"></a> 

 Raises a confirm dialog with a question and the default response on which the cursor is shown.
 If UI is not allowed, the function returns FALSE.
 

#### Syntax
```
procedure GetResponse(ConfirmQuestion: Text; DefaultButton: Boolean): Boolean
```
#### Parameters
*ConfirmQuestion ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The question to be asked to the user.

*DefaultButton ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The default response expected.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The response of the user or FALSE if no UI is allowed.

## Cryptography Management (Codeunit 1266)

 Provides helper functions for encryption and hashing.
 For encryption in an on-premises versions, use it to turn encryption on or off, and import and export the encryption key.
 Encryption is always turned on for online versions.
 

### Encrypt (Method) <a name="Encrypt"></a> 

 Returns plain text as an encrypted value.
 

#### Syntax
```
procedure Encrypt(InputString: Text): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value to encrypt.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Encrypted value.
### Decrypt (Method) <a name="Decrypt"></a> 

 Returns encrypted text as plain text.
 

#### Syntax
```
procedure Decrypt(EncryptedString: Text): Text
```
#### Parameters
*EncryptedString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value to decrypt.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Plain text.
### IsEncryptionEnabled (Method) <a name="IsEncryptionEnabled"></a> 

 Checks if Encryption is enabled.
 

#### Syntax
```
procedure IsEncryptionEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if encryption is enabled, false otherwise.
### IsEncryptionPossible (Method) <a name="IsEncryptionPossible"></a> 

 Checks whether the encryption key is present, which only works if encryption is enabled.
 

#### Syntax
```
procedure IsEncryptionPossible(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the encryption key exists, false otherwise.
### GetEncryptionIsNotActivatedQst (Method) <a name="GetEncryptionIsNotActivatedQst"></a> 

 Gets the recommended question to activate encryption.
 

#### Syntax
```
procedure GetEncryptionIsNotActivatedQst(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

String of a recommended question to activate encryption.
### EnableEncryption (Method) <a name="EnableEncryption"></a> 

 Enables encryption.
 

#### Syntax
```
[Scope('OnPrem')]
procedure EnableEncryption(Silent: Boolean)
```
#### Parameters
*Silent ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Enables encryption silently if true, otherwise will prompt the user.

### DisableEncryption (Method) <a name="DisableEncryption"></a> 

 Disables encryption.
 

#### Syntax
```
[Scope('OnPrem')]
procedure DisableEncryption(Silent: Boolean)
```
#### Parameters
*Silent ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Turns off encryption silently if true, otherwise will prompt the user.

### OnBeforeEnableEncryptionOnPrem (Event) <a name="OnBeforeEnableEncryptionOnPrem"></a> 

 Publishes an event that allows subscription when enabling encryption.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnBeforeEnableEncryptionOnPrem()
```
### OnBeforeDisableEncryptionOnPrem (Event) <a name="OnBeforeDisableEncryptionOnPrem"></a> 

 Publishes an event that allows subscription when disabling encryption.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnBeforeDisableEncryptionOnPrem()
```
### GenerateHash (Method) <a name="GenerateHash"></a> 

 Generates a hash from a string based on the provided hash algorithm.
 

#### Syntax
```
procedure GenerateHash(InputString: Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*HashAlgorithmType ([Option MD5,SHA1,SHA256,SHA384,SHA512]())* 

The available hash algorithms include MD5, SHA1, SHA256, SHA384, and SHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Hashed value.
### GenerateHash (Method) <a name="GenerateHash"></a> 

 Generates a keyed hash from a string based on provided hash algorithm and key.
 

#### Syntax
```
procedure GenerateHash(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*Key ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Key to use in the hash algorithm.

*HashAlgorithmType ([Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512]())* 

The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Hashed value.
### GenerateHash (Method) <a name="GenerateHash"></a> 

 Generates a hash from a stream based on the provided hash algorithm.
 

#### Syntax
```
procedure GenerateHash(InputString: InStream; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
```
#### Parameters
*InputString ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

Input string.

*HashAlgorithmType ([Option MD5,SHA1,SHA256,SHA384,SHA512]())* 

The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Base64 hashed value.
### GenerateHashAsBase64String (Method) <a name="GenerateHashAsBase64String"></a> 

 Generates a base64 encoded hash from a string based on provided hash algorithm.
 

#### Syntax
```
procedure GenerateHashAsBase64String(InputString: Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*HashAlgorithmType ([Option MD5,SHA1,SHA256,SHA384,SHA512]())* 

The available hash algorithms include MD5, SHA1, SHA256, SHA384, and SHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Base64 hashed value.
### GenerateHashAsBase64String (Method) <a name="GenerateHashAsBase64String"></a> 

 Generates a keyed base64 encoded hash from a string based on provided hash algorithm and key.
 

#### Syntax
```
procedure GenerateHashAsBase64String(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*Key ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Key to use in the hash algorithm.

*HashAlgorithmType ([Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512]())* 

The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Base64 hashed value.
### GenerateBase64KeyedHashAsBase64String (Method) <a name="GenerateBase64KeyedHashAsBase64String"></a> 

 Generates keyed base64 encoded hash from provided string based on provided hash algorithm and base64 key.
 

#### Syntax
```
procedure GenerateBase64KeyedHashAsBase64String(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*Key ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Key to use in the hash algorithm.

*HashAlgorithmType ([Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512]())* 

The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Base64 hashed value.

## Rijndael Cryptography (Codeunit 1258)

 Provides helper functions for the Advanced Encryption Standard.
 

### InitRijndaelProvider (Method) <a name="InitRijndaelProvider"></a> 

 Initializes a new instance of the RijndaelManaged class with default values.
 

#### Syntax
```
procedure InitRijndaelProvider()
```
### InitRijndaelProvider (Method) <a name="InitRijndaelProvider"></a> 

 Initializes a new instance of the RijndaelManaged class providing the encryption key.
 

#### Syntax
```
procedure InitRijndaelProvider(EncryptionKey: Text)
```
#### Parameters
*EncryptionKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm.

### InitRijndaelProvider (Method) <a name="InitRijndaelProvider"></a> 

 Initializes a new instance of the RijndaelManaged class providing the encryption key and block size.
 

#### Syntax
```
procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer)
```
#### Parameters
*EncryptionKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm.

*BlockSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Represents the block size, in bits, of the cryptographic operation.

### InitRijndaelProvider (Method) <a name="InitRijndaelProvider"></a> 

 Initializes a new instance of the RijndaelManaged class providing the encryption key, block size and cipher mode.
 

#### Syntax
```
procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; CipherMode: Text)
```
#### Parameters
*EncryptionKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm.

*BlockSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Represents the block size, in bits, of the cryptographic operation.

*CipherMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB

### InitRijndaelProvider (Method) <a name="InitRijndaelProvider"></a> 

 Initializes a new instance of the RijndaelManaged class providing the encryption key, block size, cipher mode and padding mode.
 

#### Syntax
```
procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; CipherMode: Text; PaddingMode: Text)
```
#### Parameters
*EncryptionKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm.

*BlockSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Represents the block size, in bits, of the cryptographic operation.

*CipherMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB

*PaddingMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the padding mode used in the symmetric algorithm.. Valid values: None,ANSIX923,ISO10126,PKCS7,Zeros

### SetBlockSize (Method) <a name="SetBlockSize"></a> 

 Sets a new block size value for the RijnadaelManaged class.
 

#### Syntax
```
procedure SetBlockSize(BlockSize: Integer)
```
#### Parameters
*BlockSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Represents the block size, in bits, of the cryptographic operation.

### SetCipherMode (Method) <a name="SetCipherMode"></a> 

 Sets a new cipher mode value for the RijnadaelManaged class.
 

#### Syntax
```
procedure SetCipherMode(CipherMode: Text)
```
#### Parameters
*CipherMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB

### SetPaddingMode (Method) <a name="SetPaddingMode"></a> 

 Sets a new padding mode value for the RijnadaelManaged class.
 

#### Syntax
```
procedure SetPaddingMode(PaddingMode: Text)
```
#### Parameters
*PaddingMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the padding mode used in the symmetric algorithm.. Valid values: None,ANSIX923,ISO10126,PKCS7,Zeros

### SetEncryptionData (Method) <a name="SetEncryptionData"></a> 

 Sets the key and vector for the RijnadaelManaged class.
 

#### Syntax
```
procedure SetEncryptionData(KeyAsBase64: Text; VectorAsBase64: Text)
```
#### Parameters
*KeyAsBase64 ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm encoded as Base64 Text

*VectorAsBase64 ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



### IsValidKeySize (Method) <a name="IsValidKeySize"></a> 

 Determines whether the specified key size is valid for the current algorithm.
 

#### Syntax
```
procedure IsValidKeySize(KeySize: Integer): Boolean
```
#### Parameters
*KeySize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Key Size.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### GetLegalKeySizeValues (Method) <a name="GetLegalKeySizeValues"></a> 

 Specifies the key sizes, in bits, that are supported by the symmetric algorithm.
 

#### Syntax
```
procedure GetLegalKeySizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
```
#### Parameters
*MinSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Minimum Size in bits

*MaxSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Maximum Size in bits

*SkipSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Skip Size in bits

### GetLegalBlockSizeValues (Method) <a name="GetLegalBlockSizeValues"></a> 

 Specifies the block sizes, in bits, that are supported by the symmetric algorithm.
 

#### Syntax
```
procedure GetLegalBlockSizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
```
#### Parameters
*MinSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Minimum Size in bits

*MaxSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Maximum Size in bits

*SkipSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Skip Size in bits

### GetEncryptionData (Method) <a name="GetEncryptionData"></a> 

 Gets the key and vector from the RijnadaelManaged class
 

#### Syntax
```
procedure GetEncryptionData(var KeyAsBase64: Text; var VectorAsBase64: Text)
```
#### Parameters
*KeyAsBase64 ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm encoded as Base64 Text

*VectorAsBase64 ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



### Encrypt (Method) <a name="Encrypt"></a> 

 Returns plain text as an encrypted value.
 

#### Syntax
```
procedure Encrypt(PlainText: Text)CryptedText: Text
```
#### Parameters
*PlainText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value to encrypt.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Encrypted value.
### Decrypt (Method) <a name="Decrypt"></a> 

 Returns encrypted text as plain text.
 

#### Syntax
```
procedure Decrypt(CryptedText: Text)PlainText: Text
```
#### Parameters
*CryptedText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value to decrypt.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Plain text.

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
 OnConvertStyleToStyleTextA Cues And KPIs Style enum from which the style text will be converted.

#### Syntax
```
procedure ConvertStyleToStyleText(CueStyle: enum "Cues And KPIs Style"): Text
```
#### Parameters
*CueStyle ([enum "Cues And KPIs Style"]())* 

A Cues And KPIs Style enum from which the style text will be converted.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


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


## Data Classification Mgt. (Codeunit 1750)

 Exposes functionality to handle data classification tasks.
 

### PopulateDataSensitivityTable (Method) <a name="PopulateDataSensitivityTable"></a> 

 Creates an entry in the Data Sensitivity table for every field in the database that is classified as Customer Content,
 End User Identifiable Information (EUII), or End User Pseudonymous Identifiers (EUPI).
 

#### Syntax
```
procedure PopulateDataSensitivityTable()
```
### SetDefaultDataSensitivity (Method) <a name="SetDefaultDataSensitivity"></a> 

 Updates the Data Sensitivity table with the default data sensitivities for all the fields of all the tables
 in the DataPrivacyEntities record.
 

#### Syntax
```
procedure SetDefaultDataSensitivity(var DataPrivacyEntities: Record "Data Privacy Entities")
```
#### Parameters
*DataPrivacyEntities ([Record "Data Privacy Entities"]())* 

The variable that is used to update the Data Sensitivity table.

### SetSensitivities (Method) <a name="SetSensitivities"></a> 

 For each Data Sensitivity entry, it sets the value of the "Data Sensitivity" field to the Sensitivity option.
 

#### Syntax
```
procedure SetSensitivities(var DataSensitivity: Record "Data Sensitivity"; Sensitivity: Option)
```
#### Parameters
*DataSensitivity ([Record "Data Sensitivity"]())* 

The record that gets updated

*Sensitivity ([Option](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/option/option-data-type))* 

The option that the "Data Sensitivity" field gets updated to.

### SyncAllFields (Method) <a name="SyncAllFields"></a> 

 Synchronizes the Data Sensitivity table with the Field table. It inserts new values in the Data Sensitivity table for the
 fields that the Field table contains and the Data Sensitivity table does not and it deletes the unclassified fields from
 the Data Sensitivity table that the Field table does not contain.
 

#### Syntax
```
procedure SyncAllFields()
```
### GetDataSensitivityOptionString (Method) <a name="GetDataSensitivityOptionString"></a> 

 Gets the values that the "Data Sensitivity" field of the Data Sensitivity table can contain.
 

#### Syntax
```
procedure GetDataSensitivityOptionString(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


 A Text value representing the values that the "Data Sensitivity" field of the Data Sensitivity table can contain.
 
### SetTableFieldsToNormal (Method) <a name="SetTableFieldsToNormal"></a> 

 Sets the data sensitivity to normal for all fields in the table with the ID TableNumber.
 

#### Syntax
```
procedure SetTableFieldsToNormal(TableNumber: Integer)
```
#### Parameters
*TableNumber ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table in which the field sensitivities will be set to normal.

### SetFieldToPersonal (Method) <a name="SetFieldToPersonal"></a> 

 Sets the data sensitivity to personal for the field with the ID FieldNo from the table with the ID TableNo.
 

#### Syntax
```
procedure SetFieldToPersonal(TableNo: Integer; FieldNo: Integer)
```
#### Parameters
*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field ID

### SetFieldToSensitive (Method) <a name="SetFieldToSensitive"></a> 

 Sets the data sensitivity to sensitive for the field with the ID FieldNo from the table with the ID TableNo.
 

#### Syntax
```
procedure SetFieldToSensitive(TableNo: Integer; FieldNo: Integer)
```
#### Parameters
*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field ID

### SetFieldToCompanyConfidential (Method) <a name="SetFieldToCompanyConfidential"></a> 

 Sets the data sensitivity to company confidential for the field with the ID FieldNo from the table
 with the ID TableNo.
 

#### Syntax
```
procedure SetFieldToCompanyConfidential(TableNo: Integer; FieldNo: Integer)
```
#### Parameters
*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field ID

### SetFieldToNormal (Method) <a name="SetFieldToNormal"></a> 

 Sets the data sensitivity to normal for the field with the ID FieldNo from the table with the ID TableNo.
 

#### Syntax
```
procedure SetFieldToNormal(TableNo: Integer; FieldNo: Integer)
```
#### Parameters
*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field ID

### DataPrivacyEntitiesExist (Method) <a name="DataPrivacyEntitiesExist"></a> 

 Checks whether any of the data privacy entity tables (Customer, Vendor, Employee, and so on) contain entries.
 

#### Syntax
```
procedure DataPrivacyEntitiesExist(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there are any entries and false otherwise.
### AreAllFieldsClassified (Method) <a name="AreAllFieldsClassified"></a> 

 Checks whether the Data Sensitivity table contains any unclassified entries.
 

#### Syntax
```
procedure AreAllFieldsClassified(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there are any unclassified entries and false otherwise.
### IsDataSensitivityEmptyForCurrentCompany (Method) <a name="IsDataSensitivityEmptyForCurrentCompany"></a> 

 Checks whether the Data Sensitivity table contains any entries for the current company.
 

#### Syntax
```
procedure IsDataSensitivityEmptyForCurrentCompany(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there are any entries and false otherwise.
### InsertDataSensitivityForField (Method) <a name="InsertDataSensitivityForField"></a> 

 Inserts a new entry in the Data Sensitivity table for the specified table ID, field ID and with the given
 data sensitivity option (some of the values that the option can have are normal, sensitive and personal).
 

#### Syntax
```
procedure InsertDataSensitivityForField(TableNo: Integer; FieldNo: Integer; DataSensitivityOption: Option)
```
#### Parameters
*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field ID

*DataSensitivityOption ([Option](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/option/option-data-type))* 

The data sensitivity option

### InsertDataPrivacyEntity (Method) <a name="InsertDataPrivacyEntity"></a> 

 Inserts a new Data Privacy Entity entry in a record.
 

#### Syntax
```
procedure InsertDataPrivacyEntity(var DataPrivacyEntities: Record "Data Privacy Entities"; TableNo: Integer; PageNo: Integer; KeyFieldNo: Integer; EntityFilter: Text; PrivacyBlockedFieldNo: Integer)
```
#### Parameters
*DataPrivacyEntities ([Record "Data Privacy Entities"]())* 

The record that the entry gets inserted into.

*TableNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The entity's table ID.

*PageNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The entity's page ID.

*KeyFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The entity's primary key ID.

*EntityFilter ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The entity's ID.

*PrivacyBlockedFieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

If the entity has a Privacy Blocked field, then the field's ID; otherwise 0.

### GetLastSyncStatusDate (Method) <a name="GetLastSyncStatusDate"></a> 

 Gets the last date when the Data Sensitivity and Field tables where synchronized.
 

#### Syntax
```
procedure GetLastSyncStatusDate(): DateTime
```
#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

The last date when the Data Sensitivity and Field tables where synchronized.
### RaiseOnGetDataPrivacyEntities (Method) <a name="RaiseOnGetDataPrivacyEntities"></a> 

 Raises an event that allows subscribers to insert Data Privacy Entities in the DataPrivacyEntities record.
 Throws an error when it is not called with a temporary record.
 

#### Syntax
```
procedure RaiseOnGetDataPrivacyEntities(var DataPrivacyEntities: Record "Data Privacy Entities")
```
#### Parameters
*DataPrivacyEntities ([Record "Data Privacy Entities"]())* 


 The record that in the end will contain all the Data Privacy Entities that the subscribers have inserted.
 

### OnGetDataPrivacyEntities (Event) <a name="OnGetDataPrivacyEntities"></a> 

 Publishes an event that allows subscribers to insert Data Privacy Entities in the DataPrivacyEntities record.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetDataPrivacyEntities(var DataPrivacyEntities: Record "Data Privacy Entities")
```
#### Parameters
*DataPrivacyEntities ([Record "Data Privacy Entities"]())* 


 The record that in the end will contain all the Data Privacy Entities that the subscribers have inserted.
 

### OnCreateEvaluationData (Event) <a name="OnCreateEvaluationData"></a> 

 Publishes an event that allows subscribers to create evaluation data.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnCreateEvaluationData()
```
### OnShowSyncFieldsNotification (Event) <a name="OnShowSyncFieldsNotification"></a> 

 Publishes an event that allows subscribers to show a notification that calls for users to synchronize their
 Data Sensitivity and Field tables.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnShowSyncFieldsNotification()
```

## Data Compression (Codeunit 425)

 Exposes functionality to provide ability to create, update, read and dispose a binary data compression archive.
 

### CreateZipArchive (Method) <a name="CreateZipArchive"></a> 

 Creates a new ZipArchive instance.
 

#### Syntax
```
procedure CreateZipArchive()
```
### OpenZipArchive (Method) <a name="OpenZipArchive"></a> 

 Creates a ZipArchive instance from the given InStream.
 

#### Syntax
```
procedure OpenZipArchive(InputStream: InStream; OpenForUpdate: Boolean)
```
#### Parameters
*InputStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream that contains the content of the compressed archive.

*OpenForUpdate ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the archive should be opened in Update mode. The default (false) indicated the archive will be opened in Read mode.

### OpenZipArchive (Method) <a name="OpenZipArchive"></a> 

 Creates a ZipArchive instance from the given InStream.
 

#### Syntax
```
procedure OpenZipArchive(InputStream: InStream; OpenForUpdate: Boolean; EncodingCodePageNumber: Integer)
```
#### Parameters
*InputStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream that contains the content of the compressed archive.

*OpenForUpdate ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the archive should be opened in Update mode. The default (false) indicated the archive will be opened in Read mode.

*EncodingCodePageNumber ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Specifies the code page number of the text encoding which is used for the compressed archive entry names in the input stream.

### OpenZipArchive (Method) <a name="OpenZipArchive"></a> 

 Creates a ZipArchive instance from the given instance of Temp Blob codeunit.
 

#### Syntax
```
procedure OpenZipArchive(TempBlob: Codeunit "Temp Blob"; OpenForUpdate: Boolean)
```
#### Parameters
*TempBlob ([Codeunit "Temp Blob"]())* 

The instance of Temp Blob codeunit that contains the content of the compressed archive.

*OpenForUpdate ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the archive should be opened in Update mode. The default (false) indicated the archive will be opened in Read mode.

### SaveZipArchive (Method) <a name="SaveZipArchive"></a> 

 Saves the ZipArchive to the given OutStream.
 

#### Syntax
```
procedure SaveZipArchive(OutputStream: OutStream)
```
#### Parameters
*OutputStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream to which the ZipArchive is saved.

### SaveZipArchive (Method) <a name="SaveZipArchive"></a> 

 Saves the ZipArchive to the given instance of Temp Blob codeunit.
 

#### Syntax
```
procedure SaveZipArchive(var TempBlob: Codeunit "Temp Blob")
```
#### Parameters
*TempBlob ([Codeunit "Temp Blob"]())* 



### CloseZipArchive (Method) <a name="CloseZipArchive"></a> 

 Disposes the ZipArchive.
 

#### Syntax
```
procedure CloseZipArchive()
```
### IsGZip (Method) <a name="IsGZip"></a> 

 Returns true if and only if the given InStream contains a GZip archive.
 

#### Syntax
```
[Scope('OnPrem')]
procedure IsGZip(InStream: InStream): Boolean
```
#### Parameters
*InStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream that contains binary content.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### GetEntryList (Method) <a name="GetEntryList"></a> 

 Returns the list of entries for the ZipArchive.
 

#### Syntax
```
procedure GetEntryList(var EntryList: List of [Text])
```
#### Parameters
*EntryList ([List of [Text]]())* 

The list that is populated with the list of entries of the ZipArchive instance.

### ExtractEntry (Method) <a name="ExtractEntry"></a> 

 Extracts an entry from the ZipArchive.
 

#### Syntax
```
procedure ExtractEntry(EntryName: Text; OutputStream: OutStream; var EntryLength: Integer)
```
#### Parameters
*EntryName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the ZipArchive entry to be extracted.

*OutputStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream to which binary content of the extracted entry is saved.

*EntryLength ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The length of the extracted entry.

### AddEntry (Method) <a name="AddEntry"></a> 

 Adds an entry to the ZipArchive.
 

#### Syntax
```
procedure AddEntry(StreamToAdd: InStream; PathInArchive: Text)
```
#### Parameters
*StreamToAdd ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream that contains the binary content that should be added as an entry in the ZipArchive.

*PathInArchive ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The path that the added entry should have within the ZipArchive.


## Default Role Center (Codeunit 9172)

 The codeunit that emits the event that sets the default Role Center.
 To use another Role Center by default, you must have a profile for it.
 

### OnBeforeGetDefaultRoleCenter (Event) <a name="OnBeforeGetDefaultRoleCenter"></a> 

 Integration event for setting the default Role Center ID.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeGetDefaultRoleCenter(var RoleCenterId: Integer; var Handled: Boolean)
```
#### Parameters
*RoleCenterId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Out parameter holding the Role Center ID.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Handled pattern


## Environment Information (Codeunit 457)

 Exposes functionality to fetch attributes concerning the environment of the service on which the tenant is hosted.
 

### IsProduction (Method) <a name="IsProduction"></a> 

 Checks if environment type of tenant is Production.
 

#### Syntax
```
procedure IsProduction(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the environment type is Production, False otherwise.
### GetEnvironmentName (Method) <a name="GetEnvironmentName"></a> 

 Gets the name of the environment.
 

#### Syntax
```
procedure GetEnvironmentName(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The name of the environment.
### IsSandbox (Method) <a name="IsSandbox"></a> 

 Checks if environment type of tenant is Sandbox.
 

#### Syntax
```
procedure IsSandbox(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the environment type is a Sandbox, False otherwise.
### IsSaaS (Method) <a name="IsSaaS"></a> 

 Checks if the deployment type is SaaS (Software as a Service).
 

#### Syntax
```
procedure IsSaaS(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the deployment type is a SaaS, false otherwise.
### IsOnPrem (Method) <a name="IsOnPrem"></a> 

 Checks the deployment type is OnPremises.
 

#### Syntax
```
procedure IsOnPrem(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the deployment type is OnPremises, false otherwise.
### IsFinancials (Method) <a name="IsFinancials"></a> 

 Checks the application family is Financials.
 

#### Syntax
```
procedure IsFinancials(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the application family is Financials, false otherwise.
### GetApplicationFamily (Method) <a name="GetApplicationFamily"></a> 

 Gets the application family.
 

#### Syntax
```
procedure GetApplicationFamily(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*



## Tenant Information (Codeunit 417)

 Exposes functionality to fetch attributes concerning the current tenant.
 

### GetTenantId (Method) <a name="GetTenantId"></a> 

 Gets the tenant ID.
 

#### Syntax
```
procedure GetTenantId(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

If it cannot be found, an empty string is returned.
### GetTenantDisplayName (Method) <a name="GetTenantDisplayName"></a> 

 Gets the tenant name.
 

#### Syntax
```
procedure GetTenantDisplayName(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

If it cannot be found, an empty string is returned.

## Extension Management (Codeunit 2504)

 Provides features for installing and uninstalling, downloading and uploading, configuring and publishing extensions and their dependencies.
 

### InstallExtension (Method) <a name="InstallExtension"></a> 

 Installs an extension, based on its PackageId and Locale Identifier.
 

#### Syntax
```
procedure InstallExtension(PackageId: Guid; lcid: Integer; IsUIEnabled: Boolean): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the extension package.

*lcid ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Locale Identifier.

*IsUIEnabled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the install operation is invoked through the UI.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### UninstallExtension (Method) <a name="UninstallExtension"></a> 

 Uninstalls an extension, based on its PackageId.
 

#### Syntax
```
procedure UninstallExtension(PackageId: Guid; IsUIEnabled: Boolean): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the extension package.

*IsUIEnabled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates if the uninstall operation is invoked through the UI.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### UploadExtension (Method) <a name="UploadExtension"></a> 

 Uploads an extension, using a File Stream and based on the Locale Identifier.
 This method is only applicable in SaaS environment.
 

#### Syntax
```
procedure UploadExtension(FileStream: InStream; lcid: Integer)
```
#### Parameters
*FileStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The File Stream containing the extension to be uploaded.

*lcid ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Locale Identifier.

### DeployExtension (Method) <a name="DeployExtension"></a> 

 Deploys an extension, based on its PackageId and Locale Identifier.
 This method is only applicable in SaaS environment.
 

#### Syntax
```
procedure DeployExtension(AppId: Guid; lcid: Integer; IsUIEnabled: Boolean)
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The AppId of the extension.

*lcid ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Locale Identifier.

*IsUIEnabled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the install operation is invoked through the UI.

### UnpublishExtension (Method) <a name="UnpublishExtension"></a> 

 Unpublishes an extension, based on its PackageId. 
 An extension can only be unpublished, if it is a per-tenant one and it has been uninstalled first.
 

#### Syntax
```
procedure UnpublishExtension(PackageId: Guid): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The PackageId of the extension.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### DownloadExtensionSource (Method) <a name="DownloadExtensionSource"></a> 

 Downloads the source of an extension, based on its PackageId.
 

#### Syntax
```
procedure DownloadExtensionSource(PackageId: Guid): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The PackageId of the extension.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### IsInstalledByPackageId (Method) <a name="IsInstalledByPackageId"></a> 

 Checks whether an extension is installed, based on its PackageId.
 

#### Syntax
```
procedure IsInstalledByPackageId(PackageId: Guid): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the extension package.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The result of checking whether an extension is installed.
### IsInstalledByAppId (Method) <a name="IsInstalledByAppId"></a> 

 Checks whether an extension is installed, based on its AppId.
 

#### Syntax
```
procedure IsInstalledByAppId(AppId: Guid): Boolean
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The AppId of the extension.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The result of checking whether an extension is installed.
### GetAllExtensionDeploymentStatusEntries (Method) <a name="GetAllExtensionDeploymentStatusEntries"></a> 

 Retrieves a list of all the Deployment Status Entries
 

#### Syntax
```
procedure GetAllExtensionDeploymentStatusEntries(var NavAppTenantOperation: Record "NAV App Tenant Operation")
```
#### Parameters
*NavAppTenantOperation ([Record "NAV App Tenant Operation"]())* 

Gets the list of all the Deployment Status Entries.

### GetDeployOperationInfo (Method) <a name="GetDeployOperationInfo"></a> 

 Retrieves the AppName,Version,Schedule,Publisher by the NAVApp Tenant OperationId.
 

#### Syntax
```
procedure GetDeployOperationInfo(OperationId: Guid; var Version: Text; var Schedule: Text; var Publisher: Text; var AppName: Text; Description: Text)
```
#### Parameters
*OperationId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The OperationId of the NAVApp Tenant.

*Version ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Gets the Version of the NavApp.

*Schedule ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Gets the Schedule of the NavApp.

*Publisher ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Gets the Publisher of the NavApp.

*AppName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Gets the AppName of the NavApp.

*Description ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Description of the NavApp; in case no name is provided, the description will replace the AppName.

### RefreshStatus (Method) <a name="RefreshStatus"></a> 

 Refreshes the status of the Operation.
 

#### Syntax
```
procedure RefreshStatus(OperationId: Guid)
```
#### Parameters
*OperationId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The Id of the operation to be refreshed.

### ConfigureExtensionHttpClientRequestsAllowance (Method) <a name="ConfigureExtensionHttpClientRequestsAllowance"></a> 

 Allows or disallows Http Client requests against the specified extension.
 

#### Syntax
```
procedure ConfigureExtensionHttpClientRequestsAllowance(PackageId: Text; AreHttpClientRqstsAllowed: Boolean): Boolean
```
#### Parameters
*PackageId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Id of the extension to configure.

*AreHttpClientRqstsAllowed ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 



#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### GetLatestVersionPackageIdByAppId (Method) <a name="GetLatestVersionPackageIdByAppId"></a> 

 Returns the PackageId of the latest Extension Version by the Extension AppId.
 

#### Syntax
```
procedure GetLatestVersionPackageIdByAppId(AppId: Guid): Guid
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The AppId of the extension.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*


### GetCurrentlyInstalledVersionPackageIdByAppId (Method) <a name="GetCurrentlyInstalledVersionPackageIdByAppId"></a> 

 Returns the PackageId of the latest version of the extension by the extension's AppId.
 

#### Syntax
```
procedure GetCurrentlyInstalledVersionPackageIdByAppId(AppId: Guid): Guid
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The AppId of the installed extension.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*


### GetSpecificVersionPackageIdByAppId (Method) <a name="GetSpecificVersionPackageIdByAppId"></a> 

 Returns the PackageId of the version of the extension by the extension's AppId, Name, Version Major, Version Minor, Version Build, Version Revision.
 

#### Syntax
```
procedure GetSpecificVersionPackageIdByAppId(AppId: Guid; Name: Text; VersionMajor: Integer; VersionMinor: Integer; VersionBuild: Integer; VersionRevision: Integer): Guid
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The AppId of the extension.

*Name ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The input/output Name parameter of the extension. If there is no need to filter by this parameter, the default value is ''.

*VersionMajor ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The input/output Version Major parameter of the extension. If there is no need to filter by this parameter, the default value is "0".

*VersionMinor ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The input/output Version Minor parameter  of the extension. If there is no need to filter by this parameter, the default value is "0"..

*VersionBuild ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The input/output Version Build parameter  of the extension. If there is no need to filter by this parameter, the default value is "0".

*VersionRevision ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The input/output Version Revision parameter  of the extension. If there is no need to filter by this parameter, the default value is "0".

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*


### GetExtensionLogo (Method) <a name="GetExtensionLogo"></a> 

 Gets the logo of an extension.
 

#### Syntax
```
procedure GetExtensionLogo(AppId: Guid; var Logo: Codeunit "Temp Blob")
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The App ID of the extension.

*Logo ([Codeunit "Temp Blob"]())* 

Out parameter holding the logo of the extension.


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


## Headlines (Codeunit 1439)

 Various functions related to headlines functionality.

 Payload - the main text of the headline.
 Qualifier - smaller text, hint to the payload.
 Expression property - value for the field on the page with type HeadlinePart.
 

### Truncate (Method) <a name="Truncate"></a> 

 Truncate the text from the end for its length to be no more than MaxLength.
 If the text has to be shortened, "..." is be added at the end.
 

#### Syntax
```
procedure Truncate(TextToTruncate: Text; MaxLength: Integer): Text
```
#### Parameters
*TextToTruncate ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text that be shortened in order to fit on the headline.

*MaxLength ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximal length of the string. Usually obtained through
 [GetMaxQualifierLength](#GetMaxQualifierLength) or [GetMaxPayloadLength](#GetMaxPayloadLength) function.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The truncated text
### Emphasize (Method) <a name="Emphasize"></a> 

 Emphasize a string of text in the headline. Applies the style to the text.
 

#### Syntax
```
procedure Emphasize(TextToEmphasize: Text): Text
```
#### Parameters
*TextToEmphasize ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text that the style will be applied on.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Emphasized text (special tags are added to the input).
### GetHeadlineText (Method) <a name="GetHeadlineText"></a> 

 Combine the text from Qualifier and Payload in order to get a single string with headline
 text. This text is usually assigned to Expression property on the HeadlinePart page.
 

#### Syntax
```
procedure GetHeadlineText(Qualifier: Text; Payload: Text; var ResultText: Text): Boolean
```
#### Parameters
*Qualifier ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to be displayed on the qualifier (smaller text above the main one)
 of the headline (parts of it can be emphasized, see [Emphasize](#Emphasize)).

*Payload ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to be displayed on the payload (the main text of the headline)
 of the headline (parts of it can be emphasized, see [Emphasize](#Emphasize)).

*ResultText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Output parameter. Contains the combined text, ready to be assigned to
 the Expression property, if the function returns 'true', the unchanged value otherwise.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

'false' if payload is empty, or payload is too long, or qualifier is too long,
 'true' otherwise.
### GetUserGreetingText (Method) <a name="GetUserGreetingText"></a> 

 Get a greeting text for the current user relevant to the time of the day.
 Timespans and correspondant greetings:
 00:00-10:59     Good morning, John Doe!
 11:00-13:59     Hi, John Doe!
 14:00-18:59     Good afternoon, John Doe!
 19:00-23:59     Good evening, John Doe!
 if the user name is blank for the current user, simplified version 
 is used (for example, "Good afternoon!").
 

#### Syntax
```
procedure GetUserGreetingText(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The greeting text.
### ShouldUserGreetingBeVisible (Method) <a name="ShouldUserGreetingBeVisible"></a> 

 Determines if a greeting text should be visible.
 

#### Syntax
```
procedure ShouldUserGreetingBeVisible(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the user logged in less than 10 minutes ago, false otherwise.
### GetMaxQualifierLength (Method) <a name="GetMaxQualifierLength"></a> 

 The accepted maximum length of a qualifier.
 

#### Syntax
```
procedure GetMaxQualifierLength(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of characters, 50.
### GetMaxPayloadLength (Method) <a name="GetMaxPayloadLength"></a> 

 The accepted maximum length of a payload.
 

#### Syntax
```
procedure GetMaxPayloadLength(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of characters, 75.

## Language (Codeunit 43)

 Management codeunit that exposes various functions to work with languages.
 

### GetUserLanguageCode (Method) <a name="GetUserLanguageCode"></a> 

 Gets the current user's language code.
 The function emits the [OnGetUserLanguageCode](#OnGetUserLanguageCode) event.
 To change the language code returned from this function, subscribe for this event and change the passed language code.
 

#### Syntax
```
procedure GetUserLanguageCode(): Code[10]
```
#### Return Value
*[Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type)*

The language code of the user's language
### GetLanguageIdOrDefault (Method) <a name="GetLanguageIdOrDefault"></a> 

 Gets the language ID based on its code. Or defaults to the current user language.
 

#### Syntax
```
procedure GetLanguageIdOrDefault(LanguageCode: Code[10]): Integer
```
#### Parameters
*LanguageCode ([Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

The code of the language

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The ID for the language code that was provided for this function. If no ID is found for the language code, then it returns the ID of the current user's language.
### GetLanguageId (Method) <a name="GetLanguageId"></a> 

 Gets the language ID based on its code.
 

#### Syntax
```
procedure GetLanguageId(LanguageCode: Code[10]): Integer
```
#### Parameters
*LanguageCode ([Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

The code of the language

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The ID for the language code that was provided for this function. If no ID is found for the language code, then it returns 0.
### GetLanguageCode (Method) <a name="GetLanguageCode"></a> 

 Gets the code for a language based on its ID.
 

#### Syntax
```
procedure GetLanguageCode(LanguageId: Integer): Code[10]
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the language.

#### Return Value
*[Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type)*

The code of the language that corresponds to the ID, or an empty code if the language with the specified ID does not exist.
### GetWindowsLanguageName (Method) <a name="GetWindowsLanguageName"></a> 

 Gets the name of a language based on the language code.
 

#### Syntax
```
procedure GetWindowsLanguageName(LanguageCode: Code[10]): Text
```
#### Parameters
*LanguageCode ([Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

The code of the language.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The name of the language corresponding to the code or empty string, if language with the specified code does not exist
### GetWindowsLanguageName (Method) <a name="GetWindowsLanguageName"></a> 

 Gets the name of a windows language based on its ID.
 

#### Syntax
```
procedure GetWindowsLanguageName(LanguageId: Integer): Text
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the language.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The name of the language that corresponds to the ID, or an empty string if a language with the specified ID does not exist.
### GetApplicationLanguages (Method) <a name="GetApplicationLanguages"></a> 

 Gets all available languages in the application.
 

#### Syntax
```
procedure GetApplicationLanguages(var TempLanguage: Record "Windows Language" temporary)
```
#### Parameters
*TempLanguage ([Record "Windows Language" temporary]())* 

A temporary record to place the result in

### GetDefaultApplicationLanguageId (Method) <a name="GetDefaultApplicationLanguageId"></a> 

 Gets the default application language ID.
 

#### Syntax
```
procedure GetDefaultApplicationLanguageId(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The ID of the default language for the application.
### ValidateApplicationLanguageId (Method) <a name="ValidateApplicationLanguageId"></a> 

 Checks whether the provided language is a valid application language.
 If it isn't, the function displays an error.
 

#### Syntax
```
procedure ValidateApplicationLanguageId(LanguageId: Integer)
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the language to validate.

### ValidateWindowsLanguageId (Method) <a name="ValidateWindowsLanguageId"></a> 

 Checks whether the provided language exists. If it doesn't, the function displays an error.
 

#### Syntax
```
procedure ValidateWindowsLanguageId(LanguageId: Integer)
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the language to validate.

### LookupApplicationLanguageId (Method) <a name="LookupApplicationLanguageId"></a> 

 Opens a list of the languages that are available for the application so that the user can choose a language.
 

#### Syntax
```
procedure LookupApplicationLanguageId(var LanguageId: Integer)
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Exit parameter that holds the chosen language ID.

### LookupWindowsLanguageId (Method) <a name="LookupWindowsLanguageId"></a> 

 Opens a list of languages that are available for the Windows version.
 

#### Syntax
```
procedure LookupWindowsLanguageId(var LanguageId: Integer)
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Exit parameter that holds the chosen language ID.

### OnGetUserLanguageCode (Event) <a name="OnGetUserLanguageCode"></a> 

 Integration event, emitted from [GetUserLanguageCode](#GetUserLanguageCode).
 Subscribe to this event to change the default behavior by changing the provided parameter(s).
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetUserLanguageCode(var UserLanguageCode: Code[10]; var Handled: Boolean)
```
#### Parameters
*UserLanguageCode ([Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Exit parameter that holds the user language code.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

To change the default behavior of the function that emits the event, set this parameter to true.


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

## Math (Codeunit 710)

 Provides constants and static methods for trigonometric, logarithmic, and other common mathematical functions.
 

### Pi (Method) <a name="Pi"></a> 

 Returns the value of pi.
 

#### Syntax
```
procedure Pi(): Decimal
```
#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

Value of pi.
### E (Method) <a name="E"></a> 

 Returns the value of E.
 

#### Syntax
```
procedure E(): Decimal
```
#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

Value of E.
### Abs (Method) <a name="Abs"></a> 

 Returns the absolute value of a Decimal number.
 

#### Syntax
```
procedure Abs(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A decimal.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

A decimal number, x, such that 0 ≤ x ≤MaxValue
### Acos (Method) <a name="Acos"></a> 

 Returns the angle whose cosine is the specified number.
 

#### Syntax
```
procedure Acos(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number representing a cosine.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

An angle, θ, measured in radians, such that 0 ≤θ≤π
### Asin (Method) <a name="Asin"></a> 

 Returns the angle whose sine is the specified number.
 

#### Syntax
```
procedure Asin(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number representing a sine, where decimalValue must be greater than or equal to -1, but less than or equal to 1.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

An angle, θ, measured in radians, such that -π/2 ≤θ≤π/2
### Atan (Method) <a name="Atan"></a> 

 Returns the angle whose tangent is the specified number.
 

#### Syntax
```
procedure Atan(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number representing a tangent.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

An angle, θ, measured in radians, such that -π/2 ≤θ≤π/2.
### Atan2 (Method) <a name="Atan2"></a> 

 Returns the angle whose tangent is the quotient of two specified numbers.
 

#### Syntax
```
procedure Atan2(y: Decimal; x: Decimal): Decimal
```
#### Parameters
*y ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The y coordinate of a point.

*x ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The x coordinate of a point.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

An angle, θ, measured in radians, such that -π≤θ≤π, and tan(θ) = y / x, where (x, y) is a point in the Cartesian plane. 
### BigMul (Method) <a name="BigMul"></a> 

 Produces the full product of two 32-bit numbers.
 

#### Syntax
```
procedure BigMul(a: Integer; b: Integer): BigInteger
```
#### Parameters
*a ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The first number to multiply.

*b ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The second number to multiply.

#### Return Value
*[BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type)*

The number containing the product of the specified numbers.
### Ceiling (Method) <a name="Ceiling"></a> 

 Returns the smallest integral value that is greater than or equal to the specified decimal number.
 

#### Syntax
```
procedure Ceiling(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A decimal number.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The smallest integral value that is greater than or equal to decimalValue.
### Cos (Method) <a name="Cos"></a> 

 Returns the cosine of the specified angle.
 

#### Syntax
```
procedure Cos(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The cosine of decimalValue. 
### Cosh (Method) <a name="Cosh"></a> 

 Returns the hyperbolic cosine of the specified angle.
 

#### Syntax
```
procedure Cosh(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The hyperbolic cosine of value.
### Exp (Method) <a name="Exp"></a> 

 Returns e raised to the specified power.
 

#### Syntax
```
procedure Exp(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number specifying a power.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The number e raised to the power decimalValue.
### Floor (Method) <a name="Floor"></a> 

 Returns the largest integral value less than or equal to the specified decimal number.
 

#### Syntax
```
procedure Floor(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A decimal number.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The largest integral value less than or equal to decimalValue.
### IEEERemainder (Method) <a name="IEEERemainder"></a> 

 Returns the remainder resulting from the division of a specified number by another specified number.
 

#### Syntax
```
procedure IEEERemainder(x: Decimal; y: Decimal): Decimal
```
#### Parameters
*x ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A dividend.

*y ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A divisor.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

A number equal to x - (y Q), where Q is the quotient of x / y rounded to the nearest integer (if x / y falls halfway between two integers, the even integer is returned).
### Log (Method) <a name="Log"></a> 

 Returns the natural (base e) logarithm of a specified number.
 

#### Syntax
```
procedure Log(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The number whose logarithm is to be found.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The natural logarithm of decimalValue; that is, ln decimalValue, or log e decimalValue
### Log (Method) <a name="Log"></a> 

 Returns the logarithm of a specified number in a specified base.
 

#### Syntax
```
procedure Log(a: Decimal; newBase: Decimal): Decimal
```
#### Parameters
*a ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The number whose logarithm is to be found.

*newBase ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The base of the logarithm.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The logarithm of a specified number in a specified base.
### Log10 (Method) <a name="Log10"></a> 

 Returns the base 10 logarithm of a specified number.
 

#### Syntax
```
procedure Log10(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number whose logarithm is to be found.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The base 10 logarithm of the specified number
### Max (Method) <a name="Max"></a> 

 Returns the larger of two decimal numbers.
 

#### Syntax
```
procedure Max(decimalValue1: Decimal; decimalValue2: Decimal): Decimal
```
#### Parameters
*decimalValue1 ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The first of two decimal numbers to compare.

*decimalValue2 ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The second of two decimal numbers to compare.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

Parameter decimalValue1 or decimalValue2, whichever is larger.
### Min (Method) <a name="Min"></a> 

 Returns the smaller of two decimal numbers.
 

#### Syntax
```
procedure Min(decimalValue1: Decimal; decimalValue2: Decimal): Decimal
```
#### Parameters
*decimalValue1 ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The first of two decimal numbers to compare.

*decimalValue2 ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The second of two decimal numbers to compare.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

Parameter decimalValue1 or decimalValue2, whichever is smaller.
### Pow (Method) <a name="Pow"></a> 

 Returns a specified number raised to the specified power.
 

#### Syntax
```
procedure Pow(x: Decimal; y: Decimal): Decimal
```
#### Parameters
*x ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A double-precision floating-point number to be raised to a power.

*y ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A double-precision floating-point number that specifies a power.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The number x raised to the power y.
### Sign (Method) <a name="Sign"></a> 

 Returns an integer that indicates the sign of a decimal number.
 

#### Syntax
```
procedure Sign(decimalValue: Decimal): Integer
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A signed decimal number.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

A number that indicates the sign of value.
### Sinh (Method) <a name="Sinh"></a> 

 Returns the hyperbolic sine of the specified angle.
 

#### Syntax
```
procedure Sinh(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The hyperbolic sine of value.
### Sin (Method) <a name="Sin"></a> 

 Returns the sine of the specified angle.
 

#### Syntax
```
procedure Sin(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The sine of a.
### Sqrt (Method) <a name="Sqrt"></a> 

 Returns the square root of a specified number.
 

#### Syntax
```
procedure Sqrt(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The number whose square root is to be found.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The positive square root of decimalValue.
### Tan (Method) <a name="Tan"></a> 

 Returns the tangent of the specified angle.
 

#### Syntax
```
procedure Tan(a: Decimal): Decimal
```
#### Parameters
*a ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The tangent of a.
### Tanh (Method) <a name="Tanh"></a> 

 Returns the hyperbolic tangent of the specified angle.
 

#### Syntax
```
procedure Tanh(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The hyperbolic tangent of value.
### Truncate (Method) <a name="Truncate"></a> 

 Calculates the integral part of a specified decimal number.
 

#### Syntax
```
procedure Truncate(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number to truncate.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The integral part of decimalValue.

## Password Dialog Management (Codeunit 9810)

 Exposes functionality to open dialogs for entering passwords with different settings.
 

### OpenPasswordDialog (Method) <a name="OpenPasswordDialog"></a> 

 Opens a dialog for the user to enter a password and returns the typed password if there is no validation error,
 otherwise an empty text is returned.
 

#### Syntax
```
procedure OpenPasswordDialog(DisablePasswordValidation: Boolean; DisablePasswordConfirmation: Boolean): Text
```
#### Parameters
*DisablePasswordValidation ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Disables the checks for the password validity. Default value is false.

*DisablePasswordConfirmation ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

If set to true the new password is only needed once. Default value is false.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The typed password, or empty text if the password validations fail.
### OpenPasswordDialog (Method) <a name="OpenPasswordDialog"></a> 

 Opens a dialog for the user to enter a password and returns the typed password if there is no validation error,
 otherwise an empty text is returned.
 

#### Syntax
```
procedure OpenPasswordDialog(DisablePasswordValidation: Boolean): Text
```
#### Parameters
*DisablePasswordValidation ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Disables the checks for the password validity. Default value is false.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The typed password, or empty text if the password validations fail.
### OpenPasswordDialog (Method) <a name="OpenPasswordDialog"></a> 

 Opens a dialog for the user to enter a password and returns the typed password if there is no validation error,
 otherwise an empty text is returned.
 

#### Syntax
```
procedure OpenPasswordDialog(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The typed password, or empty text if the password validations fail.
### OpenChangePasswordDialog (Method) <a name="OpenChangePasswordDialog"></a> 

 Opens a dialog for the user to change a password and returns the old and new typed passwords if there is no validation error,
 otherwise an empty text are returned.
 

#### Syntax
```
procedure OpenChangePasswordDialog(var OldPassword: Text; var Password: Text)
```
#### Parameters
*OldPassword ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Out parameter, the old password user typed on the dialog.

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Out parameter, the new password user typed on the dialog.

### OnSetMinPasswordLength (Event) <a name="OnSetMinPasswordLength"></a> 

 Event to override the Minimum number of characters in the password.
 The Minimum length can only be increased not decreased. Default value is 8 characters long.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnSetMinPasswordLength(var MinPasswordLength: Integer)
```
#### Parameters
*MinPasswordLength ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of characters to be set as minimum requirement.


## Record Link Management (Codeunit 447)

 Exposes functionality to administer record links related to table records.
 

### CopyLinks (Method) <a name="CopyLinks"></a> 

 Copies all the links from one record to the other and sets Notify to FALSE for them.
 

#### Syntax
```
procedure CopyLinks(FromRecord: Variant; ToRecord: Variant)
```
#### Parameters
*FromRecord ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The source record from which links are copied.

*ToRecord ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The destination record to which links are copied.

### WriteNote (Method) <a name="WriteNote"></a> 

 Writes the Note BLOB into the format the client code expects.
 

#### Syntax
```
procedure WriteNote(var RecordLink: Record "Record Link"; Note: Text)
```
#### Parameters
*RecordLink ([Record "Record Link"]())* 

The record link passed as a VAR to which the note is added.

*Note ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The note to be added.

### ReadNote (Method) <a name="ReadNote"></a> 

 Read the Note BLOB
 

#### Syntax
```
procedure ReadNote(RecordLink: Record "Record Link"): Text
```
#### Parameters
*RecordLink ([Record "Record Link"]())* 

The record link from which the note is read.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The note as a text.
### RemoveOrphanedLinks (Method) <a name="RemoveOrphanedLinks"></a> 

 Iterates over the record link table and removes those with obsolete record ids.
 

#### Syntax
```
procedure RemoveOrphanedLinks()
```

## Remove Orphaned Record Links (Codeunit 459)

 This codeunit is created so that record links that have obsolete record ids can be deleted in a scheduled task.
 


## Recurrence Schedule (Codeunit 4690)

 Calculates when the next event will occur. Events can recur daily, weekly, monthly or yearly.
 

### SetMinDateTime (Method) <a name="SetMinDateTime"></a> 

 To start calculating recurrence from January 1st, 2000,
 call SetMinDateTime(CREATEDATETIME(DMY2DATE(1, 1, 2000), 0T)).
 


 Sets the earliest date to be returned from CalculateNextOccurrence.
 The default MinDateTime is today at the start time set in recurrence.
 

#### Syntax
```
procedure SetMinDateTime(DateTime: DateTime)
```
#### Parameters
*DateTime ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The minimum datetime.

### CalculateNextOccurrence (Method) <a name="CalculateNextOccurrence"></a> 

 To calculate the first occurrence (this is using the datatime provided in SetMinDateTime as a minimum datetime to return),
 call CalculateNextOccurrence(RecurrenceID, 0DT)), the RecurrenceID is the ID returned from one of the create functions.
 


 Calculates the time and date for the next occurrence.
 

#### Syntax
```
procedure CalculateNextOccurrence(RecurrenceID: Guid; LastOccurrence: DateTime): DateTime
```
#### Parameters
*RecurrenceID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The recurrence ID.

*LastOccurrence ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The time of the last scheduled occurrence.

#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

Returns the DateTime value for the next occurrence. If there is no next occurrence, it returns the default value 0DT.
### CreateDaily (Method) <a name="CreateDaily"></a> 

 To create a recurrence that starts today, repeats every third day, and does not have an end date,
 call RecurrenceID := CreateDaily(now, today, 0D , 3).
 


 Creates a daily recurrence.
 

#### Syntax
```
procedure CreateDaily(StartTime: Time; StartDate: Date; EndDate: Date; DaysBetween: Integer): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*DaysBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of days between each occurrence, starting with 1.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### CreateWeekly (Method) <a name="CreateWeekly"></a> 

 To create a weekly recurrence that starts today, repeats every Monday and Wednesday, and does not have an end date,
 call RecurrenceID := CreateWeekly(now, today, 0D , 1, true, false, true, false, false, false, false).
 


 Creates a weekly recurrence.
 

#### Syntax
```
procedure CreateWeekly(StartTime: Time; StartDate: Date; EndDate: Date; WeeksBetween: Integer; Monday: Boolean; Tuesday: Boolean; Wednesday: Boolean; Thursday: Boolean; Friday: Boolean; Saturday: Boolean; Sunday: Boolean): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*WeeksBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of weeks between each occurrence, starting with 1.

*Monday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Mondays.

*Tuesday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Tuesdays.

*Wednesday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Wednesdays.

*Thursday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Thursdays.

*Friday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Fridays.

*Saturday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Saturdays.

*Sunday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Sundays.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### CreateMonthlyByDay (Method) <a name="CreateMonthlyByDay"></a> 

 To create a monthly recurrence that repeats on the fourth day of every month,
 call RecurrenceID := CreateMonthlyByDay(now, today, 0D , 1, 4).
 


 Creates a monthly recurrence by day.
 

#### Syntax
```
procedure CreateMonthlyByDay(StartTime: Time; StartDate: Date; EndDate: Date; MonthsBetween: Integer; DayOfMonth: Integer): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*MonthsBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of months between each occurrence, starting with 1.

*DayOfMonth ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The day of the month.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### CreateMonthlyByDayOfWeek (Method) <a name="CreateMonthlyByDayOfWeek"></a> 

 To create a monthly recurrence that calculates every last Friday of every month,
 call RecurrenceID := CreateMonthlyByDayOfWeek(now, today, 0D , 1, RecurrenceOrdinalNo::Last, RecurrenceDayofWeek::Friday).
 


 Creates a monthly recurrence by the day of the week.
 

#### Syntax
```
procedure CreateMonthlyByDayOfWeek(StartTime: Time; StartDate: Date; EndDate: Date; MonthsBetween: Integer; InWeek: Enum "Recurrence - Ordinal No."; DayOfWeek: Enum "Recurrence - Day of Week"): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*MonthsBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of months between each occurrence, starting with 1.

*InWeek ([Enum "Recurrence - Ordinal No."]())* 

The week of the month.

*DayOfWeek ([Enum "Recurrence - Day of Week"]())* 

The day of the week.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### CreateYearlyByDay (Method) <a name="CreateYearlyByDay"></a> 

 To create a yearly recurrence that repeats on the first day of December,
 call RecurrenceID := CreateYearlyByDay(now, today, 0D , 1, 1, RecurrenceMonth::December).
 


 Creates a yearly recurrence by day.
 

#### Syntax
```
procedure CreateYearlyByDay(StartTime: Time; StartDate: Date; EndDate: Date; YearsBetween: Integer; DayOfMonth: Integer; Month: Enum "Recurrence - Month"): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*YearsBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of years between each occurrence, starting with 1.

*DayOfMonth ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The day of the month.

*Month ([Enum "Recurrence - Month"]())* 

The month of the year.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### CreateYearlyByDayOfWeek (Method) <a name="CreateYearlyByDayOfWeek"></a> 

 To create a yearly recurrence that repeats on the last Friday of every month,
 call RecurrenceID := CreateYearlyByDayOfWeek(now, today, 0D , 1, RecurrenceOrdinalNo::Last, RecurrenceDayofWeek::Weekday, RecurrenceMonth::December).
 


 Creates a yearly recurrence by day of week of a given month.
 

#### Syntax
```
procedure CreateYearlyByDayOfWeek(StartTime: Time; StartDate: Date; EndDate: Date; YearsBetween: Integer; InWeek: Enum "Recurrence - Ordinal No."; DayOfWeek: Enum "Recurrence - Day of Week"; Month: Enum "Recurrence - Month"): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*YearsBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of years between each occurrence, starting with 1.

*InWeek ([Enum "Recurrence - Ordinal No."]())* 

The week of the month.

*DayOfWeek ([Enum "Recurrence - Day of Week"]())* 

The day of the week.

*Month ([Enum "Recurrence - Month"]())* 

The month of the year.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### OpenRecurrenceSchedule (Method) <a name="OpenRecurrenceSchedule"></a> 

 Opens the card for the recurrence.
 

#### Syntax
```
procedure OpenRecurrenceSchedule(var RecurrenceID: Guid)
```
#### Parameters
*RecurrenceID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The recurrence ID.

### RecurrenceDisplayText (Method) <a name="RecurrenceDisplayText"></a> 

 Returns a short text description of the recurrence.
 

#### Syntax
```
procedure RecurrenceDisplayText(RecurrenceID: Guid): Text
```
#### Parameters
*RecurrenceID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The recurrence ID.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The short text to display.

## Satisfaction Survey Mgt. (Codeunit 1433)

 Management codeunit that exposes various functions to work with Satisfaction Survey.
 

### TryShowSurvey (Method) <a name="TryShowSurvey"></a> 

 Tries to show the satisfaction survey dialog to the current user.
 The survey is only shown if the user is chosen for the survey. 
 The method sends the request to the server and checks the response to check if the user is chosen for the survey.
 

#### Syntax
```
[Scope('OnPrem')]
procedure TryShowSurvey(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the survey is shown, false otherwise.
### TryShowSurvey (Method) <a name="TryShowSurvey"></a> 

 Tries to show the satisfaction survey dialog to the current user.
 Decision to show the survey or not is based on the response from the server on the check request.
 

#### Syntax
```
[Scope('OnPrem')]
procedure TryShowSurvey(Status: Integer; Response: Text): Boolean
```
#### Parameters
*Status ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Response status code

*Response ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Response body

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the survey is shown, false otherwise.
### TryGetCheckUrl (Method) <a name="TryGetCheckUrl"></a> 

 Gets the URL of the request to the server for checking if the dialog has to be presented to the current user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure TryGetCheckUrl(var CheckUrl: Text): Boolean
```
#### Parameters
*CheckUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the check URL is valid, false otherwise.
### GetRequestTimeoutAsync (Method) <a name="GetRequestTimeoutAsync"></a> 

 Gets the asynchronous request timeout.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetRequestTimeoutAsync(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The asynchronous request timeout in milliseconds.
### ResetState (Method) <a name="ResetState"></a> 

 Deletes the survey state and deactivates the survey for all users.
 

#### Syntax
```
[Scope('OnPrem')]
procedure ResetState(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the survey is deactivated for all users, false otherwise.
### ResetCache (Method) <a name="ResetCache"></a> 

 Resets the the cached survey parameters.
 

#### Syntax
```
[Scope('OnPrem')]
procedure ResetCache(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the cached survey parameters are reset, false otherwise.
### ActivateSurvey (Method) <a name="ActivateSurvey"></a> 

 Activates a try to show the survey for the current user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure ActivateSurvey(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the survey state has been changed from inactive to active, false otherwise.
### DeactivateSurvey (Method) <a name="DeactivateSurvey"></a> 

 Deactivates a try to show the survey for the current user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure DeactivateSurvey(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the survey state has been changed from active to inactive, false otherwise.

## Server Setting (Codeunit 6723)

 Exposes functionality to fetch some application server settings for the server which hosts the current tenant.
 

### GetEnableSaaSExtensionInstallSetting (Method) <a name="GetEnableSaaSExtensionInstallSetting"></a> 
Checks whether online extensions can be installed on the server.

Gets the value of the server setting EnableSaasExtensionInstallConfigSetting.

#### Syntax
```
[Scope('OnPrem')]
procedure GetEnableSaaSExtensionInstallSetting(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True, if they can be installed; otherwise, false.
### GetIsSaasExcelAddinEnabled (Method) <a name="GetIsSaasExcelAddinEnabled"></a> 
Checks whether Excel add-in is enabled on the server.

Gets the value of the server setting IsSaasExcelAddinEnabled.

#### Syntax
```
procedure GetIsSaasExcelAddinEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if enabled; otherwise, false.
### GetApiServicesEnabled (Method) <a name="GetApiServicesEnabled"></a> 
Checks whether the API Services are enabled.

Gets the value of the server setting ApiServicesEnabled.

#### Syntax
```
[Scope('OnPrem')]
procedure GetApiServicesEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if enabled; otherwise, false.
### GetApiSubscriptionsEnabled (Method) <a name="GetApiSubscriptionsEnabled"></a> 
Checks whether the API subscriptions are enabled.

Gets the value of the server setting ApiSubscriptionsEnabled.

#### Syntax
```
[Scope('OnPrem')]
procedure GetApiSubscriptionsEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if enabled; otherwise, false.
### GetApiSubscriptionSendingNotificationTimeout (Method) <a name="GetApiSubscriptionSendingNotificationTimeout"></a> 
Gets the timeout for the notifications sent by API subscriptions.

Gets the value of the server setting ApiSubscriptionSendingNotificationTimeout.

#### Syntax
```
[Scope('OnPrem')]
procedure GetApiSubscriptionSendingNotificationTimeout(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The timeout value in milliseconds.
### GetApiSubscriptionMaxNumberOfNotifications (Method) <a name="GetApiSubscriptionMaxNumberOfNotifications"></a> 
Gets the maximum number of notifications that API subscriptions can send.

Gets the value of the server setting ApiSubscriptionMaxNumberOfNotifications.

#### Syntax
```
[Scope('OnPrem')]
procedure GetApiSubscriptionMaxNumberOfNotifications(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The maximum number of notifications that can be sent.
### GetApiSubscriptionDelayTime (Method) <a name="GetApiSubscriptionDelayTime"></a> 
Gets the delay when starting to process API subscriptions.

Gets the value of the server setting ApiSubscriptionDelayTime.

#### Syntax
```
[Scope('OnPrem')]
procedure GetApiSubscriptionDelayTime(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The time value in milliseconds.

## System Initialization (Codeunit 150)

 Exposes functionality to check whether the system is initializing as well as an event to subscribed to in order to execute logic right after the system has initialized.
 

### IsInProgress (Method) <a name="IsInProgress"></a> 

 Checks whether the system initialization is currently in progress.
 

#### Syntax
```
procedure IsInProgress(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True, if the system initialization is in progress; false, otherwise
### OnAfterInitialization (Event) <a name="OnAfterInitialization"></a> 

 Integration event for after the system initialization.
 Subscribe to this event in order to execute additional initialization steps.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterInitialization()
```

## Tenant License State (Codeunit 2300)

 Exposes functionality to retrieve the current state of the tenant license.
 

### GetPeriod (Method) <a name="GetPeriod"></a> 

 Returns the default number of days that the tenant license can be in the current state, passed as a parameter.
 

#### Syntax
```
procedure GetPeriod(TenantLicenseState: Enum "Tenant License State"): Integer
```
#### Parameters
*TenantLicenseState ([Enum "Tenant License State"]())* 

The tenant license state.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The default number of days that the tenant license can be in the current state, passed as a parameter or -1 if a default period is not defined for the state.
### GetStartDate (Method) <a name="GetStartDate"></a> 

 Gets the start date for the current license state.
 

#### Syntax
```
procedure GetStartDate(): DateTime
```
#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

The start date for the current license state or a blank date if no license state is found.
### GetEndDate (Method) <a name="GetEndDate"></a> 

 Gets the end date for the current license state.
 

#### Syntax
```
procedure GetEndDate(): DateTime
```
#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

The end date for the current license state or a blank date if no license state is found.
### IsEvaluationMode (Method) <a name="IsEvaluationMode"></a> 

 Checks whether the current license state is evaluation.
 

#### Syntax
```
procedure IsEvaluationMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is evaluation, otherwise false.
### IsTrialMode (Method) <a name="IsTrialMode"></a> 

 Checks whether the current license state is trial.
 

#### Syntax
```
procedure IsTrialMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is trial, otherwise false.
### IsTrialSuspendedMode (Method) <a name="IsTrialSuspendedMode"></a> 

 Checks whether the trial license is suspended.
 

#### Syntax
```
procedure IsTrialSuspendedMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is suspended and the previous license state is trial, otherwise false.
### IsTrialExtendedMode (Method) <a name="IsTrialExtendedMode"></a> 

 Checks whether the trial license has been extended.
 

#### Syntax
```
procedure IsTrialExtendedMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is trial and the tenant has had at least one trial license state before, otherwise false.
### IsTrialExtendedSuspendedMode (Method) <a name="IsTrialExtendedSuspendedMode"></a> 

 Checks whether the trial license has been extended and is currently suspended.
 

#### Syntax
```
procedure IsTrialExtendedSuspendedMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is suspended and the tenant has had at least two trial license states before, otherwise false.
### IsPaidMode (Method) <a name="IsPaidMode"></a> 

 Checks whether the current license state is paid.
 

#### Syntax
```
procedure IsPaidMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is paid, otherwise false.
### IsPaidWarningMode (Method) <a name="IsPaidWarningMode"></a> 

 Checks whether the paid license is in warning mode.
 

#### Syntax
```
procedure IsPaidWarningMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is warning and the previous license state is paid, otherwise false.
### IsPaidSuspendedMode (Method) <a name="IsPaidSuspendedMode"></a> 

 Checks whether the paid license is suspended.
 

#### Syntax
```
procedure IsPaidSuspendedMode(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current license state is suspended and the previous license state is paid, otherwise false.
### GetLicenseState (Method) <a name="GetLicenseState"></a> 

 Gets the the current license state.
 

#### Syntax
```
procedure GetLicenseState(): Enum "Tenant License State"
```
#### Return Value
*[Enum "Tenant License State"]()*

The the current license state.
### ExtendTrialLicense (Method) <a name="ExtendTrialLicense"></a> 

 Extends the trial license.
 

#### Syntax
```
[Scope('OnPrem')]
procedure ExtendTrialLicense()
```

## Translation (Codeunit 3711)

 Exposes function\alitys to add and retrieve translated texts for table fields.
 

### Any (Method) <a name="Any"></a> 

 Checks if there any translations present at all.
 

#### Syntax
```
procedure Any(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there is at least one translation; false, otherwise.
### Get (Method) <a name="Get"></a> 

 To get the value of the description field for an item record, call GetValue(Item, Item.FIELDNO(Description)).
 


 Gets the value of a field in the global language for the record.
 


 If a translated record for the global language cannot be found it finds the Windows language translation.
 If a Windows language translation cannot be found, return an empty string.
 

#### Syntax
```
procedure Get(RecVariant: Variant; FieldId: Integer): Text
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to get the translated value for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field for which the translation is stored.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The translated value.
### Get (Method) <a name="Get"></a> 

 To get the value of the Description field for an item record in Danish, call GetValue(Item, Item.FIELDNO(Description), 1030).
 


 Gets the value of a field in the language that is specified for the record.
 

#### Syntax
```
procedure Get(RecVariant: Variant; FieldId: Integer; LanguageId: Integer): Text
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to get the translated value for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field to store the translation for.

*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the language in which to get the field value.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The translated value.
### Set (Method) <a name="Set"></a> 

 Sets the value of a field to the global language for the record.
 

#### Syntax
```
procedure Set(RecVariant: Variant; FieldId: Integer; Value: Text[2048])
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to store the translated value for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field to store the translation for.

*Value ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The translated value to set.

### Set (Method) <a name="Set"></a> 

 Sets the value of a field to the language specified for the record.
 

#### Syntax
```
procedure Set(RecVariant: Variant; FieldId: Integer; LanguageId: Integer; Value: Text[2048])
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to store the translated value for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field to store the translation for.

*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The language id to set the value for.

*Value ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The translated value to set.

### Delete (Method) <a name="Delete"></a> 

 Deletes all translations for a persisted (non temporary) record.
 

#### Syntax
```
procedure Delete(RecVariant: Variant)
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record for which the translations will be deleted.

### Delete (Method) <a name="Delete"></a> 

 Deletes the translation for a field on a persisted (non temporary) record.
 

#### Syntax
```
procedure Delete(RecVariant: Variant; FieldId: Integer)
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record with a field for which the translation will be deleted.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Id of the field for which the translation will be deleted.

### Show (Method) <a name="Show"></a> 

 Shows all language translations that are available for a field in a new page.
 

#### Syntax
```
procedure Show(RecVariant: Variant; FieldId: Integer)
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to get the translated value for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field to get translations for.

### ShowForAllRecords (Method) <a name="ShowForAllRecords"></a> 

 Shows all language translations available for a given field for all the records in that table in a new page.
 

#### Syntax
```
procedure ShowForAllRecords(TableId: Integer; FieldId: Integer)
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID to get translations for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field to get translations for.


## Upgrade Tag (Codeunit 9999)

 The interface for registering upgrade tags.
 Format of the upgrade tag is:
 [CompanyPrefix]-[TFSID]-[Description]-[YYYYMMDD]
 Example:
 MS-29901-UpdateGLEntriesIntegrationRecordIDs-20161206
 

### HasUpgradeTag (Method) <a name="HasUpgradeTag"></a> 

 Verifies if the upgrade tag exists.
 

#### Syntax
```
procedure HasUpgradeTag(Tag: Code[250]): Boolean
```
#### Parameters
*Tag ([Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Tag code to check

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the Tag with given code exist.
### HasUpgradeTag (Method) <a name="HasUpgradeTag"></a> 

 Verifies if the upgrade tag exists.
 

#### Syntax
```
procedure HasUpgradeTag(Tag: Code[250]; TagCompanyName: Code[30]): Boolean
```
#### Parameters
*Tag ([Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Tag code to check

*TagCompanyName ([Code[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Name of the company to check existance of tag

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the Tag with given code exist.
### SetUpgradeTag (Method) <a name="SetUpgradeTag"></a> 

 Sets the upgrade tag.
 

#### Syntax
```
procedure SetUpgradeTag(NewTag: Code[250])
```
#### Parameters
*NewTag ([Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Tag code to save

### SetAllUpgradeTags (Method) <a name="SetAllUpgradeTags"></a> 

 This method should be used to set all upgrade tags in a new company. 
 The method is called from codeunit 2 - Company Initialize.
 

#### Syntax
```
procedure SetAllUpgradeTags()
```
### SetAllUpgradeTags (Method) <a name="SetAllUpgradeTags"></a> 

 This method should be used to set all upgrade tags in a new company. 
 The method is called from Copy Company Report
 

#### Syntax
```
procedure SetAllUpgradeTags(NewCompanyName: Code[30])
```
#### Parameters
*NewCompanyName ([Code[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Name of the company set the upgrade tags

### OnGetPerCompanyUpgradeTags (Event) <a name="OnGetPerCompanyUpgradeTags"></a> 

 Use this event if you want to add upgrade tag for PerCompany upgrade method for a new company.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
```
#### Parameters
*PerCompanyUpgradeTags ([List of [Code[250]]]())* 


 List of upgrade tags that should be inserted if they do not exist.
 

### OnGetPerDatabaseUpgradeTags (Event) <a name="OnGetPerDatabaseUpgradeTags"></a> 

 Use this event if you want to add upgrade tag for PerDatabase upgrade method for a new company.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
```
#### Parameters
*PerDatabaseUpgradeTags ([List of [Code[250]]]())* 


 List of upgrade tags that should be inserted if they do not exist.
 


## User Login Time Tracker (Codeunit 9026)

 Exposes functionality to retrieve information about the user's first, penultimate and last login times.
 

### IsFirstLogin (Method) <a name="IsFirstLogin"></a> 

 Returns true if this is the first time the user logs in.
 

#### Syntax
```
procedure IsFirstLogin(UserSecurityID: Guid): Boolean
```
#### Parameters
*UserSecurityID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The User Security ID.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if this is the first time the user logs in and false otherwise.
### AnyUserLoggedInSinceDate (Method) <a name="AnyUserLoggedInSinceDate"></a> 

 Returns true if any user logged in on or after the specified date.
 

#### Syntax
```
procedure AnyUserLoggedInSinceDate(FromDate: Date): Boolean
```
#### Parameters
*FromDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The date to start searching from.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if any user logged in on or after the specified date and false otherwise.
### UserLoggedInSinceDateTime (Method) <a name="UserLoggedInSinceDateTime"></a> 

 Returns true if the current user logged in at or after the specified DateTime.
 

#### Syntax
```
procedure UserLoggedInSinceDateTime(FromDateTime: DateTime): Boolean
```
#### Parameters
*FromDateTime ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The DateTime to start searching from.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current user logged in at or after the specified DateTime and false otherwise.
### GetPenultimateLoginDateTime (Method) <a name="GetPenultimateLoginDateTime"></a> 

 Returns the penultimate login DateTime of the current user.
 

#### Syntax
```
procedure GetPenultimateLoginDateTime(): DateTime
```
#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

The penultimate login DateTime of the current user, or 0DT if the user login cannot be found.
### CreateOrUpdateLoginInfo (Method) <a name="CreateOrUpdateLoginInfo"></a> 

 Updates or creates the last login information of the current user (first, last and penultimate login date).
 

#### Syntax
```
[Scope('OnPrem')]
procedure CreateOrUpdateLoginInfo()
```
### OnAfterCreateorUpdateLoginInfo (Event) <a name="OnAfterCreateorUpdateLoginInfo"></a> 

 Publishes an event that is fired whenever a user's login information is created or updated.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterCreateorUpdateLoginInfo(UserSecurityId: Guid)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 




## User Permissions (Codeunit 152)

 Exposes functionality to check if a user has SUPER permissions set assigned as well as removing such permissions set from a user.
 

### IsSuper (Method) <a name="IsSuper"></a> 

 Checks whether the user has the SUPER permissions set.
 

#### Syntax
```
[Scope('OnPrem')]
procedure IsSuper(UserSecurityId: Guid): Boolean
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The security ID assigned to the user.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the user has the SUPER permissions set. Otherwise, false.
### RemoveSuperPermissions (Method) <a name="RemoveSuperPermissions"></a> 

 Removes the SUPER permissions set from a user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure RemoveSuperPermissions(UserSecurityId: Guid)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The security ID of the user to modify.


## User Selection (Codeunit 9843)

 Provides basic functionality to open a search page and validate user information. 
 

### Open (Method) <a name="Open"></a> 

 Opens the user lookup page and assigns the selected users on the  parameter.
 

#### Syntax
```
procedure Open(var SelectedUser: Record User): Boolean
```
#### Parameters
*SelectedUser ([Record User]())* 

The variable to return the selected users. Any filters on this record will influence the page view.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if a user was selected.
### ValidateUserName (Method) <a name="ValidateUserName"></a> 

 Displays an error if there is no user with the given username and the user table is not empty.
 

#### Syntax
```
procedure ValidateUserName(UserName: Code[50])
```
#### Parameters
*UserName ([Code[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

The username to validate.


## Video (Codeunit 3710)
 Lists and enables playing of available videos.

### Play (Method) <a name="Play"></a> 
 Use a link to display a video in a new page. 

#### Syntax
```
procedure Play(Url: Text)
```
#### Parameters
*Url ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The link to the video.

### Register (Method) <a name="Register"></a> 
 Adds a link to a video to the Product Videos page. 
 

#### Syntax
```
procedure Register(AppID: Guid; Title: Text[250]; VideoUrl: Text[2048])
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The ID of the extension that registers this video.

*Title ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The title of the video.

*VideoUrl ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The link to the video.

### Register (Method) <a name="Register"></a> 
 Adds a link to a video to the Product Videos page. 
 

#### Syntax
```
procedure Register(AppID: Guid; Title: Text[250]; VideoUrl: Text[2048]; Category: Enum "Video Category")
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The ID of the extension that registers this video.

*Title ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The title of the video.

*VideoUrl ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The link to the video.

*Category ([Enum "Video Category"]())* 

 The video category.

### Register (Method) <a name="Register"></a> 
 Adds a link to a video to the Product Videos page. 
 

#### Syntax
```
procedure Register(AppID: Guid; Title: Text[250]; VideoUrl: Text[2048]; TableNum: Integer; SystemId: Guid)
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The ID of the extension that registers this video.

*Title ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The title of the video.

*VideoUrl ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The link to the video.

*TableNum ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

 The table number of the record that is the source of this video.

*SystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The system id of the record related to this video. This is 
 used to raise the OnVideoPlayed event with that record once the video is 
 played.

### Register (Method) <a name="Register"></a> 
 Adds a link to a video to the Product Videos page. 
 

#### Syntax
```
procedure Register(AppID: Guid; Title: Text[250]; VideoUrl: Text[2048]; Category: Enum "Video Category"; TableNum: Integer; SystemId: Guid)
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The ID of the extension that registers this video.

*Title ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The title of the video.

*VideoUrl ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The link to the video.

*Category ([Enum "Video Category"]())* 

 The video category.

*TableNum ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

 The table number of the record that is the source of this video.

*SystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The system id of the record related to this video. This is 
 used to raise the OnVideoPlayed event with that record once the video is 
 played.

### Show (Method) <a name="Show"></a> 

 Show all videos that belong to a given category.
 

#### Syntax
```
procedure Show(Category: Enum "Video Category")
```
#### Parameters
*Category ([Enum "Video Category"]())* 

The category to filter the videos by.

### OnRegisterVideo (Event) <a name="OnRegisterVideo"></a> 
 Notifies the subscribers that they can add links to videos to the Product Videos page.

#### Syntax
```
[IntegrationEvent(true, false)]
internal procedure OnRegisterVideo()
```
### OnVideoPlayed (Event) <a name="OnVideoPlayed"></a> 
 Notifies the subscribers that they can act on the source record when a related video is played.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnVideoPlayed(TableNum: Integer; SystemID: Guid)
```
#### Parameters
*TableNum ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table number of the source record.

*SystemID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The surrogate key of the source record.


## Web Service Management (Codeunit 9750)

 Provides methods for creating and modifying web services, accessing web service URLs, and getting and setting web service filters and clauses.
 

### CreateWebService (Method) <a name="CreateWebService"></a> 

 Creates a web service for a given object. If the web service already exists, it modifies the web service accordingly.
 

#### Syntax
```
procedure CreateWebService(ObjectType: Option; ObjectId: Integer; ObjectName: Text; Published: Boolean)
```
#### Parameters
*ObjectType ([Option](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/option/option-data-type))* 

The type of the object.

*ObjectId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the object.

*ObjectName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the object.

*Published ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the web service is published or not.

### CreateTenantWebService (Method) <a name="CreateTenantWebService"></a> 

 Creates a tenant web service for a given object. If the tenant web service already exists, it modifies the tenant web service accordingly.
 

#### Syntax
```
procedure CreateTenantWebService(ObjectType: Option; ObjectId: Integer; ObjectName: Text; Published: Boolean)
```
#### Parameters
*ObjectType ([Option](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/option/option-data-type))* 

The type of the object.

*ObjectId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the object.

*ObjectName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the object.

*Published ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the web service is published or not.

### GetWebServiceUrl (Method) <a name="GetWebServiceUrl"></a> 

 Gets the web service URL for a given Web Service Aggregate record and client type.
 

#### Syntax
```
procedure GetWebServiceUrl(WebServiceAggregate: Record "Web Service Aggregate"; ClientType: Enum "Client Type"): Text
```
#### Parameters
*WebServiceAggregate ([Record "Web Service Aggregate"]())* 

The record for getting web service URL.

*ClientType ([Enum "Client Type"]())* 

The client type of the URL. Clients are SOAP, ODataV3 and ODataV4.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Web service URL for the given record.
### CreateTenantWebServiceColumnsFromTemp (Method) <a name="CreateTenantWebServiceColumnsFromTemp"></a> 

 Creates tenant web service columns from temporary records.
 

#### Syntax
```
procedure CreateTenantWebServiceColumnsFromTemp(var TenantWebServiceColumns: Record "Tenant Web Service Columns"; var TempTenantWebServiceColumns: Record "Tenant Web Service Columns" temporary; TenantWebServiceRecordId: RecordID)
```
#### Parameters
*TenantWebServiceColumns ([Record "Tenant Web Service Columns"]())* 

Record that the columns from temporary records are inserted to.

*TempTenantWebServiceColumns ([Record "Tenant Web Service Columns" temporary]())* 

Temporary record that the columns are inserted from.

*TenantWebServiceRecordId ([RecordID](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))* 

The ID of the Tenant Web Service corresponding to columns.

### CreateTenantWebServiceFilterFromRecordRef (Method) <a name="CreateTenantWebServiceFilterFromRecordRef"></a> 

 Creates a tenant web service filter from a record reference.
 

#### Syntax
```
procedure CreateTenantWebServiceFilterFromRecordRef(var TenantWebServiceFilter: Record "Tenant Web Service Filter"; var RecRef: RecordRef; TenantWebServiceRecordId: RecordID)
```
#### Parameters
*TenantWebServiceFilter ([Record "Tenant Web Service Filter"]())* 

Record that the filter from record reference is inserted to.

*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

Record reference that the filter is inserted from.

*TenantWebServiceRecordId ([RecordID](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))* 

The ID of the Tenant Web Service corresponding to the filter.

### GetTenantWebServiceFilter (Method) <a name="GetTenantWebServiceFilter"></a> 

 Returns the tenant web service filter for a given record.
 

#### Syntax
```
procedure GetTenantWebServiceFilter(TenantWebServiceFilter: Record "Tenant Web Service Filter"): Text
```
#### Parameters
*TenantWebServiceFilter ([Record "Tenant Web Service Filter"]())* 

The record for getting filter.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Tenant web service filter for the given record.
### SetTenantWebServiceFilter (Method) <a name="SetTenantWebServiceFilter"></a> 

 Sets the tenant web service filter for a given record.
 

#### Syntax
```
procedure SetTenantWebServiceFilter(var TenantWebServiceFilter: Record "Tenant Web Service Filter"; FilterText: Text)
```
#### Parameters
*TenantWebServiceFilter ([Record "Tenant Web Service Filter"]())* 

The record for setting tenant web service filter.

*FilterText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The tenant web service filter that is set.

### GetODataSelectClause (Method) <a name="GetODataSelectClause"></a> 

 Returns the OData select clause for a given record.
 

#### Syntax
```
procedure GetODataSelectClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for getting OData select clause.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

OData select clause for the given record.
### SetODataSelectClause (Method) <a name="SetODataSelectClause"></a> 

 Sets the OData select clause for a given record.
 

#### Syntax
```
procedure SetODataSelectClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for setting OData select clause.

*ODataText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OData select clause that is set.

### GetODataFilterClause (Method) <a name="GetODataFilterClause"></a> 

 Returns the OData filter clause for a given record.
 

#### Syntax
```
procedure GetODataFilterClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for getting OData filter clause.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

OData filter clause for the given record.
### SetODataFilterClause (Method) <a name="SetODataFilterClause"></a> 

 Sets the OData filter clause for a given record.
 

#### Syntax
```
procedure SetODataFilterClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for setting OData filter clause.

*ODataText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OData filter clause that is set.

### GetODataV4FilterClause (Method) <a name="GetODataV4FilterClause"></a> 

 Returns the OData V4 filter clause for a given record.
 

#### Syntax
```
procedure GetODataV4FilterClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for getting OData V4 filter clause.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

OData V4 filter clause for the given record.
### SetODataV4FilterClause (Method) <a name="SetODataV4FilterClause"></a> 

 Sets the OData V4 filter clause for a given record.
 

#### Syntax
```
procedure SetODataV4FilterClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
```
#### Parameters
*TenantWebServiceOData ([Record "Tenant Web Service OData"]())* 

The record for setting OData V4 filter clause.

*ODataText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OData V4 filter clause that is set.

### GetObjectCaption (Method) <a name="GetObjectCaption"></a> 

 Gets the name of the object that will be exposed to the web service for a given record.
 

#### Syntax
```
procedure GetObjectCaption(WebServiceAggregate: Record "Web Service Aggregate"): Text[80]
```
#### Parameters
*WebServiceAggregate ([Record "Web Service Aggregate"]())* 

The record for getting the name of the object.

#### Return Value
*[Text[80]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Name of the object.
### LoadRecords (Method) <a name="LoadRecords"></a> 

 Loads records from Web Service and Tenant Web Service table into given Web Service Aggregate record.
 

#### Syntax
```
procedure LoadRecords(var WebServiceAggregate: Record "Web Service Aggregate")
```
#### Parameters
*WebServiceAggregate ([Record "Web Service Aggregate"]())* 

The variable that the records are loaded into.

### LoadRecordsFromTenantWebServiceColumns (Method) <a name="LoadRecordsFromTenantWebServiceColumns"></a> 

 Loads records from Tenant Web Service table if there is a corresponding Tenant Web Service Column.
 

#### Syntax
```
procedure LoadRecordsFromTenantWebServiceColumns(var TenantWebService: Record "Tenant Web Service")
```
#### Parameters
*TenantWebService ([Record "Tenant Web Service"]())* 

The variable that the records are loaded into.

### CreateTenantWebServiceColumnForPage (Method) <a name="CreateTenantWebServiceColumnForPage"></a> 

 Creates a tenant web service for a given page.
 

#### Syntax
```
[Scope('OnPrem')]
procedure CreateTenantWebServiceColumnForPage(TenantWebServiceRecordId: RecordID; FieldNumber: Integer; DataItem: Integer)
```
#### Parameters
*TenantWebServiceRecordId ([RecordID](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))* 

The ID of the given page.

*FieldNumber ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field number of the tenant web service column.

*DataItem ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The data item of the tenant web service column.

### CreateTenantWebServiceColumnForQuery (Method) <a name="CreateTenantWebServiceColumnForQuery"></a> 

 Creates a tenant web service for a given query.
 

#### Syntax
```
[Scope('OnPrem')]
procedure CreateTenantWebServiceColumnForQuery(TenantWebServiceRecordId: RecordID; FieldNumber: Integer; DataItem: Integer; MetaData: DotNet QueryMetadataReader)
```
#### Parameters
*TenantWebServiceRecordId ([RecordID](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))* 

The ID of the given query.

*FieldNumber ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field number of the tenant web service column.

*DataItem ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The data item of the tenant web service column.

*MetaData ([DotNet QueryMetadataReader]())* 

Metadata used to convert field name.

### InsertSelectedColumns (Method) <a name="InsertSelectedColumns"></a> 

 Inserts selected columns in a given dictionary to the tenant web service columns table.
 

#### Syntax
```
procedure InsertSelectedColumns(var TenantWebService: Record "Tenant Web Service"; var ColumnDictionary: DotNet GenericDictionary2; var TargetTenantWebServiceColumns: Record "Tenant Web Service Columns"; DataItem: Integer)
```
#### Parameters
*TenantWebService ([Record "Tenant Web Service"]())* 

The tenant web service corresponding to columns.

*ColumnDictionary ([DotNet GenericDictionary2]())* 

Dictionary that contains selected columns to be inserted to the tenant web service columns table.

*TargetTenantWebServiceColumns ([Record "Tenant Web Service Columns"]())* 

Tenant web service columns table record that selected columns are inserted to.

*DataItem ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The data item of the tenant web service column.

### RemoveUnselectedColumnsFromFilter (Method) <a name="RemoveUnselectedColumnsFromFilter"></a> 
 
 Removes filters that are not in the selected columns for the given service.
 

#### Syntax
```
procedure RemoveUnselectedColumnsFromFilter(var TenantWebService: Record "Tenant Web Service"; DataItem: Integer; DataItemView: Text): Text
```
#### Parameters
*TenantWebService ([Record "Tenant Web Service"]())* 

The tenant web service corresponding to columns.

*DataItem ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The data item of the tenant web service column.

*DataItemView ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The field name of the data item.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Filter text for unselected columns.
### IsServiceNameValid (Method) <a name="IsServiceNameValid"></a> 
 
 Checks if given service name is valid.
 

#### Syntax
```
procedure IsServiceNameValid(Value: Text): Boolean
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The service name to be checked.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

If given service name valid or not.

## Assisted Setup (Page 1801)
This page shows all registered assisted setup guides.


## Plans (Page 9824)

 List page that contains all plans that can be assigned to users.
 


## Plans FactBox (Page 9825)

 ListPart page that contains all the plans.
 


## User Plan Members (Page 9822)

 List page that contains all users and the plans that they are assigned to.
 


## User Plan Members FactBox (Page 9823)

 ListPart page that contains all the user plan members.
 


## Data Encryption Management (Page 9905)

 Exposes functionality that allows super users for on-premises versions to enable or disable encryption, import, export or change the encryption key.
 


## Cue Setup Administrator (Page 9701)

 List page that contains settings that define the appearance of cues on all pages.
 Administrators can use this page to define a general style, which users can customize from the Cue Setup End User page.
 


## Cue Setup End User (Page 9702)

 List page that contains settings that define the appearance of cues for the current user and page.
 


## Data Classification Wizard (Page 1752)

 Exposes functionality that allows users to classify their data.
 

### ResetControls (Method) <a name="ResetControls"></a> 

 Resets the buttons on the page, enabling and disabling them according to the current step.
 

#### Syntax
```
procedure ResetControls()
```
### ShouldEnableNext (Method) <a name="ShouldEnableNext"></a> 

 Queries on whether or not the Next button should be enabled.
 

#### Syntax
```
procedure ShouldEnableNext(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the Next button should be enabled and false otherwise.
### NextStep (Method) <a name="NextStep"></a> 

 Selects the next step.
 

#### Syntax
```
procedure NextStep(Backward: Boolean)
```
#### Parameters
*Backward ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

A boolean value that specifies if the next step should be to go back.

### CheckMandatoryActions (Method) <a name="CheckMandatoryActions"></a> 

 Displays errors if the preconditions for an action are not met.
 

#### Syntax
```
procedure CheckMandatoryActions()
```
### IsNextEnabled (Method) <a name="IsNextEnabled"></a> 

 Queries on whether the Next button is enabled.
 

#### Syntax
```
procedure IsNextEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the Next button is enabled and false otherwise.
### GetStep (Method) <a name="GetStep"></a> 

 Gets the current step.
 

#### Syntax
```
procedure GetStep(): Option

```
#### Return Value
*[Option
]()*

The current step.
### SetStep (Method) <a name="SetStep"></a> 

 Sets the current step.
 

#### Syntax
```
procedure SetStep(StepValue: Option)
```
#### Parameters
*StepValue ([Option](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/option/option-data-type))* 

The new value of the current step.

### IsImportModeSelected (Method) <a name="IsImportModeSelected"></a> 

 Queries on whether import mode is selected.
 

#### Syntax
```
procedure IsImportModeSelected(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if import mode is selected and false otherwise.
### IsExportModeSelected (Method) <a name="IsExportModeSelected"></a> 

 Queries on whether export mode is selected.
 

#### Syntax
```
procedure IsExportModeSelected(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if export mode is selected and false otherwise.
### IsExpertModeSelected (Method) <a name="IsExpertModeSelected"></a> 

 Queries on whether expert mode is selected.
 

#### Syntax
```
procedure IsExpertModeSelected(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if expert mode is selected and false otherwise.
### GetLedgerEntriesDefaultClassification (Method) <a name="GetLedgerEntriesDefaultClassification"></a> 

 Gets the default classification for ledger entries.
 

#### Syntax
```
procedure GetLedgerEntriesDefaultClassification(): Option

```
#### Return Value
*[Option
]()*

The default classification for ledger entries.
### GetTemplatesDefaultClassification (Method) <a name="GetTemplatesDefaultClassification"></a> 

 Gets the default classification for templates.
 

#### Syntax
```
procedure GetTemplatesDefaultClassification(): Option

```
#### Return Value
*[Option
]()*

The default classification for templates.
### GetSetupTablesDefaultClassification (Method) <a name="GetSetupTablesDefaultClassification"></a> 

 Gets the default classification for setup tables.
 

#### Syntax
```
procedure GetSetupTablesDefaultClassification(): Option

```
#### Return Value
*[Option
]()*

The default classification for setup tables.

## Data Classification Worksheet (Page 1751)

 Exposes functionality that allows users to classify their data.
 


## Field Content Buffer (Page 1753)

 Displays a list of field content buffers.
 


## Field Data Classification (Page 1750)

 Displays a list of fields and their corresponding data classifications.
 


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

## Blank Role Center (Page 8999)

 Empty role center to use in case no other role center is present when system is initializing.
 


## Extension Deployment Status (Page 2508)

 Displays the deployment status for extensions that are deployed or are scheduled for deployment.
 


## Extension Details (Page 2501)

 Displays details about the selected extension, and offers features for installing and uninstalling it.
 


## Extension Details Part (Page 2504)

 Displays information about the extension.
 


## Extension Installation (Page 2503)

 Installs the selected extension.
 


## Extension Logo Part (Page 2506)

 Displays the extension logo.
 


## Extension Management (Page 2500)

 Lists the available extensions, and provides features for managing them.
 


## Extension Settings (Page 2511)

 Displays settings for the selected extension, and allows users to edit them.
 


## Extn Deployment Status Detail (Page 2509)

 Displays details about the deployment status of the selected extension.
 


## Marketplace Extn Deployment (Page 2510)

 Provides an interface for installing extensions from AppSource.
 


## Upload And Deploy Extension (Page 2507)

 Allows users to upload an extension and schedule its deployment.
 


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


## Languages (Page 9)

 Page for displaying application languages.
 


## Windows Languages (Page 535)

 Page for displaying available windows languages.
 


## Manual Setup (Page 1875)
This page shows all registered manual setups.


## Objects (Page 358)

 List page that contains all of the application objects.
 


## Password Dialog (Page 9810)

 A Page that allows the user to enter a password.
 

### GetPasswordValue (Method) <a name="GetPasswordValue"></a> 

 Gets the password value typed on the page.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetPasswordValue(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The password value typed on the page.
### GetOldPasswordValue (Method) <a name="GetOldPasswordValue"></a> 

 Gets the old password value typed on the page.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetOldPasswordValue(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The old password typed on the page.
### EnableChangePassword (Method) <a name="EnableChangePassword"></a> 

 Enables the Change password mode, it makes the old password field on the page visible.
 

#### Syntax
```
[Scope('OnPrem')]
procedure EnableChangePassword()
```
### DisablePasswordValidation (Method) <a name="DisablePasswordValidation"></a> 

 Disables any password validation.
 

#### Syntax
```
[Scope('OnPrem')]
procedure DisablePasswordValidation()
```
### DisablePasswordConfirmation (Method) <a name="DisablePasswordConfirmation"></a> 

 Disables any password confirmation, it makes the Confirm Password field on the page hidden.
 

#### Syntax
```
[Scope('OnPrem')]
procedure DisablePasswordConfirmation()
```

## Recurrence Schedule Card (Page 4690)

 Allows users to view and edit existing recurrence schedules.
 


## Satisfaction Survey (Page 1433)

 Displays the satisfaction survey dialog box.
 


## Translation (Page 3712)
This page shows the target language and the translation for data in a table field.

### SetCaption (Method) <a name="SetCaption"></a> 

 Sets the page's caption.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetCaption(CaptionText: Text)
```
#### Parameters
*CaptionText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The caption to set.


## User Lookup (Page 9843)

 Lookup page for users.
 

### GetSelectedUsers (Method) <a name="GetSelectedUsers"></a> 

 Gets the currently selected users.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetSelectedUsers(var SelectedUser: Record User)
```
#### Parameters
*SelectedUser ([Record User]())* 

A record that contains the currently selected users


## Product Videos (Page 1470)
This page shows all registered videos.


## Video Link (Page 1821)
This page shows the video playing in Business Central.


## Change Password (Report 9810)

 Report to change the current user's login password for OnPrem scenarios.
 


## BLANK (Profile )

 Empty profile to use in case no other profile is present when system is initializing.
 


## Plan (Query 775)

 Displays a list of plans.
 


## Users in Plans (Query 774)

 Displays a list of the plans assigned to users.
 


## Assisted Setup Group (Enum 1815)
The group to which the setup belongs. Please extend this enum to add your own group to classify the setups being added by your extension.

### Uncategorized (value: 0)


## Auto Format (Enum 59)

 Formats the appearance of decimal data types.
 

### DefaultFormat (value: 0)


 Ignore the value that AutoFormatExpr passes and use the standard format for decimals instead.
 

### CustomFormatExpr (value: 11)


 Apply a specific format in AutoFormatExpr without additional transformation.
 


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
 


## Manual Setup Category (Enum 1875)
The category enum is used to navigate the setup page, which can have many records. It is encouraged to extend this enum and use the newly defined options.

### Uncategorized (value: 0)


## Recurrence - Day of Week (Enum 4690)

 This enum has the day of the week for which the recurrence will occur.
 

### Monday (value: 1)


 Specifies that the recurrence to occur on Monday.
 

### Tuesday (value: 2)


 Specifies that the recurrence to occur on Tuesday.
 

### Wednesday (value: 3)


 Specifies that the recurrence to occur on Wednesday.
 

### Thursday (value: 4)


 Specifies that the recurrence to occur on Thursday.
 

### Friday (value: 5)


 Specifies that the recurrence to occur on Friday.
 

### Saturday (value: 6)


 Specifies that the recurrence to occur on Saturday.
 

### Sunday (value: 7)


 Specifies that the recurrence to occur on Sunday.
 

### Day (value: 8)


 Specifies that the recurrence to occur every day.
 

### Weekday (value: 9)


 Specifies that the recurrence to occur on all days from Monday to Friday.
 

### Weekend Day (value: 10)


 Specifies that the recurrence to occur on Saturday and Sunday.
 


## Recurrence - Month (Enum 4691)

 This enum has the months during which the recurrence will occur.
 

### January (value: 1)


 Specifies that the recurrence will occur in Janurary.
 

### February (value: 2)


 Specifies that the recurrence will occur in February.
 

### March (value: 3)


 Specifies that the recurrence will occur in March.
 

### April (value: 4)


 Specifies that the recurrence will occur in April.
 

### May (value: 5)


 Specifies that the recurrence will occur in May.
 

### June (value: 6)


 Specifies that the recurrence will occur in June.
 

### July (value: 7)


 Specifies that the recurrence will occur in July.
 

### August (value: 8)


 Specifies that the recurrence will occur in August.
 

### September (value: 9)


 Specifies that the recurrence will occur in September.
 

### October (value: 10)


 Specifies that the recurrence will occur in October.
 

### November (value: 11)


 Specifies that the recurrence will occur in Novemeber.
 

### December (value: 12)


 Specifies that the recurrence will occur in December.
 


## Recurrence - Monthly Pattern (Enum 4694)

 This enum has the monthly occurrence patterns for the recurrence.
 

### Specific Day (value: 0)


 Specifies that the recurrence will occur on a specific day.
 

### By Weekday (value: 1)


 Specifies that the recurrence will occur on a weekday. This is used in conjuction with the "Recurrence - Day Of Week" enums.
 


## Recurrence - Ordinal No. (Enum 4693)

 This enum has the ordinal numbers for which the recurrence will occur.
 

### First (value: 0)


 Specifies that the recurrence will occur in the first week of the month.
 

### Second (value: 1)


 Specifies that the recurrence will occur in the second week of the month.
 

### Third (value: 2)


 Specifies that the recurrence will occur in the third week of the month.
 

### Fourth (value: 3)


 Specifies that the recurrence will occur in the fourth week of the month.
 

### Last (value: 4)


 Specifies that the recurrence will occur in the last week of the month.
 In months with four weeks, the "Last" enum is the same as "Fourth" enum.
 


## Recurrence - Pattern (Enum 4692)

 This enum has the occurrence patterns for the recurrence.
 

### Daily (value: 0)


 Specifies that the recurrence will occur daily.
 

### Weekly (value: 1)


 Specifies that the recurrence will occur weekly.
 

### Monthly (value: 2)


 Specifies that the recurrence will occur monthly.
 

### Yearly (value: 3)


 Specifies that the recurrence will occur yearly.
 


## Tenant License State (Enum 2301)

 This enum has the tenant license state types.
 

### Evaluation (value: 0)


 Specifies that the tenant license is in the evaluation state.
 

### Trial (value: 1)


 Specifies that the tenant license is in the trial state.
 

### Paid (value: 2)


 Specifies that the tenant license is in the paid state.
 

### Warning (value: 3)


 Specifies that the tenant license is in the warning state.
 This period starts after the trial period or when the tenant's subscription expires.
 

### Suspended (value: 4)


 Specifies that the tenant license is in the suspended state.
 

### Deleted (value: 5)


 Specifies that the tenant license is in the deleted state.
 

### LockedOut (value: 6)


 Specifies that the tenant license is in the locked state.
 The tenant is locked, and no one can access it.
 


## Video Category (Enum 3710)
This enum is the category under which videos can be classified.

Extensions can extend this enum to add custom categories.

### Uncategorized (value: 0)


## Client Type (Enum 9751)

 This enum has the web service client types.
 

### SOAP (value: 0)


 Specifies that the client type is SOAP.
 

### ODataV3 (value: 1)


 Specifies that the client type is OData V3.
 

### ODataV4 (value: 2)


 Specifies that the client type is OData V4.
 


## OData Protocol Version (Enum 9750)

 This enum has the OData protocol versions.
 

### V3 (value: 0)


 Specifies that the OData protocol version is V3.
 

### V4 (value: 1)


 Specifies that the OData protocol version is V4.
 

