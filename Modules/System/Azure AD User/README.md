This module provides functionality for retrieving and updating user information from Azure AD.

Use this module to do the following:
- retrieve a user with a specified security ID from Azure AD
- retrieve a user's object ID from Azure AD
- retrieve a user's authentication object ID from Azure AD
- update a User record with information from Azure AD
- ensure an authentication email is not in use

This module is meant for on-premises use only.

# Public Objects
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



