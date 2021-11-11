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
[NonDebuggable]
procedure CreateNewUsersFromAzureAD()
```
### CreateNewUserFromGraphUser (Method) <a name="CreateNewUserFromGraphUser"></a> 

 Creates a new user from an Azure AD user.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
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
[NonDebuggable]
procedure SynchronizeLicensedUserFromDirectory(AuthenticationEmail: Text): Boolean
```
#### Parameters
*AuthenticationEmail ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user's authentication email.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there is a user in Azure AD corresponding to the authentication email; otherwise false.
### SynchronizeAllLicensedUsersFromDirectory (Method) <a name="SynchronizeAllLicensedUsersFromDirectory"></a> 

 Synchronizes all the users from the database with the ones from Azure AD.
 Azure AD users that do not exist in the database are created.
 

#### Syntax
```
[NonDebuggable]
procedure SynchronizeAllLicensedUsersFromDirectory()
```
### IsUserTenantAdmin (Method) <a name="IsUserTenantAdmin"></a> 

 Checks if the user is a tenant admin.
 

#### Syntax
```
[NonDebuggable]
procedure IsUserTenantAdmin(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the user is a tenant admin; otherwise false.
### IsUserDelegated (Method) <a name="IsUserDelegated"></a> 

 Checks if the user is a delegated user.
 

#### Syntax
```
[NonDebuggable]
procedure IsUserDelegated(UserSecID: Guid): Boolean
```
#### Parameters
*UserSecID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 



#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the user is a delegated user; otherwise false.
### SetTestInProgress (Method) <a name="SetTestInProgress"></a> 

 Sets a flag that is used to determine whether a test is in progress.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure SetTestInProgress(TestInProgress: Boolean)
```
#### Parameters
*TestInProgress ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The value to be set to the flag.

### OnRestoreDefaultPermissions (Event) <a name="OnRestoreDefaultPermissions"></a> 

 Integration event, raised from "Azure AD User Update Wizard" page when the changes are applied.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[NonDebuggable]
internal procedure OnRestoreDefaultPermissions(UserSecurityID: Guid)
```
#### Parameters
*UserSecurityID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the user whos permission sets will be restored.


## Azure AD User Update Wizard (Page 9515)

 Administrators can use this page to synchronize information about users from Microsoft 365 to Business Central.
 


## Azure AD Permission Change Action (Enum 9017)

 The types of the action to take in response to permission conflicts arising out of changes to plans in Office users.
 

### Select (value: 0)


 Represents the case when either no action is needed or no action has been provided by the user.
 

### Keep Current (value: 1)


 Represents the case when the user wants to keep the current configuration.
 

### Append (value: 2)


 Represents the case when the user wants to append a new configuration to one that already exists.
 


## Azure AD Update Type (Enum 9010)
Types of updates from users in the Office 365.

### New (value: 0)


 Represents a value that is present in the Office 365 portal but not in Business Central.
 

### Change (value: 1)


 Represents a value that is different in the Office 365 portal compared to Business Central.
 

### Remove (value: 2)


 Represents a value that is removed in the Office 365 portal but present in Business Central.
 


## Azure AD User Update Entity (Enum 9515)

 The entities that are updated in Business Central from Office 365.
 


 The order in which the update is processed must be in the following order.
 Authentication email must be updated before Plan, and Plan must be updated before Language ID.
 

### Authentication Email (value: 0)


 Represents an update to the authentication email property of a user.
 

### Contact Email (value: 1)


 Represents an update to the contact email property of a user.
 

### Full Name (value: 2)


 Represents an update to the full name property of a user.
 

### Plan (value: 3)


 Represents an update to the assigned plans for a user.
 

### Language ID (value: 4)


 Represents an update to the language setting of a user.
 

