This module provides functionality for managing Azure AD users.

Use this module to do the following:
- synchronize the database users with the users from Azure AD - either create new ones, or update the existing ones
- synchronize a single user with an Azure AD user
- check if the current user is the tenant admin

# Public Objects
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

### UpdateUserFromGraph (Method) <a name="UpdateUserFromGraph"></a> 

 Updates details about the user with information from Office 365.
 

#### Syntax
```
[Scope('OnPrem')]
procedure UpdateUserFromGraph(var User: Record User)
```
#### Parameters
*User ([Record User]())* 

The user whose information will be updated.

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

