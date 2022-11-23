This module provides functionality for retrieving user and tenant information from Azure AD.

Use this module to retrieve the following:
- User information from Azure AD
- A user's assigned plans
- A user's roles
- The list of subscriptions owned by the current tenant
- The list of directory roles 
- Information about the current tenant

This module is meant for on-premises use only.

# Public Objects
## Azure AD Graph (Codeunit 9012)

 Exposes functionality to query Azure AD.
 

### GetUser (Method) <a name="GetUser"></a> 

 Gets the user with the specified user principal name from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetUser(UserPrincipalName: Text; var UserInfo: DotNet UserInfo)
```
#### Parameters
*UserPrincipalName ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The user principal name.

*UserInfo ([DotNet UserInfo](https://go.microsoft.com/fwlink/?linkid=2210120))* 

The user to return.

### GetCurrentUser (Method) <a name="GetCurrentUser"></a> 

 Gets the current user from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetCurrentUser(var UserInfo: DotNet UserInfo)
```
#### Parameters
*UserInfo ([DotNet UserInfo](https://go.microsoft.com/fwlink/?linkid=2210120))* 

The user to return.

### GetUserByAuthorizationEmail (Method) <a name="GetUserByAuthorizationEmail"></a> 

 Gets the user with the specified authorization email from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetUserByAuthorizationEmail(AuthorizationEmail: Text; var UserInfo: DotNet UserInfo)
```
#### Parameters
*AuthorizationEmail ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The user's authorization email.

*UserInfo ([DotNet UserInfo](https://go.microsoft.com/fwlink/?linkid=2210120))* 

The user to return.

### GetUserByObjectId (Method) <a name="GetUserByObjectId"></a> 

 Gets the user with the specified object ID from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetUserByObjectId(ObjectId: Text; var UserInfo: DotNet UserInfo)
```
#### Parameters
*ObjectId ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The object ID assigned to the user.

*UserInfo ([DotNet UserInfo](https://go.microsoft.com/fwlink/?linkid=2210120))* 

The user to return.

### TryGetUserByObjectId (Method) <a name="TryGetUserByObjectId"></a> 

 Tries to return the user with the specified object ID from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure TryGetUserByObjectId(ObjectId: Text; var UserInfo: DotNet UserInfo): Boolean
```
#### Parameters
*ObjectId ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The object ID assigned to the user.

*UserInfo ([DotNet UserInfo](https://go.microsoft.com/fwlink/?linkid=2210120))* 

The user to return.

#### Return Value
*[Boolean](https://go.microsoft.com/fwlink/?linkid=2209954)*

A boolean that indicates whether the user was retrieved.
### GetUserAssignedPlans (Method) <a name="GetUserAssignedPlans"></a> 

 Gets the assigned plans for the specified user from Azure AD.
 

If the provided user is null, the output parameter holding the assigned plans remains unchanged.

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetUserAssignedPlans(UserInfo: DotNet UserInfo; var UserAssignedPlans: DotNet GenericList1)
```
#### Parameters
*UserInfo ([DotNet UserInfo](https://go.microsoft.com/fwlink/?linkid=2210120))* 

The user.

*UserAssignedPlans ([DotNet GenericList1](https://go.microsoft.com/fwlink/?linkid=2209955))* 

The assigned plans for the user.

### GetUserRoles (Method) <a name="GetUserRoles"></a> 

 Gets the roles assigned to the user from Azure AD.
 

If the provided user is null, the output parameter holding the user roles remains unchanged.

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetUserRoles(UserInfo: DotNet UserInfo; var UserRoles: DotNet GenericIEnumerable1)
```
#### Parameters
*UserInfo ([DotNet UserInfo](https://go.microsoft.com/fwlink/?linkid=2210120))* 

The user for whom to retrieve the roles.

*UserRoles ([DotNet GenericIEnumerable1](https://go.microsoft.com/fwlink/?linkid=2210121))* 

The user's roles.

### GetDirectorySubscribedSkus (Method) <a name="GetDirectorySubscribedSkus"></a> 

 Gets the list of subscriptions owned by the tenant.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetDirectorySubscribedSkus(var DirectorySubscribedSkus: DotNet GenericIEnumerable1)
```
#### Parameters
*DirectorySubscribedSkus ([DotNet GenericIEnumerable1](https://go.microsoft.com/fwlink/?linkid=2210121))* 

The list of subscriptions to return.

### GetDirectoryRoles (Method) <a name="GetDirectoryRoles"></a> 

 Gets the directory roles from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetDirectoryRoles(var DirectoryRoles: DotNet GenericIEnumerable1)
```
#### Parameters
*DirectoryRoles ([DotNet GenericIEnumerable1](https://go.microsoft.com/fwlink/?linkid=2210121))* 

The directory roles to return.

### GetTenantDetail (Method) <a name="GetTenantDetail"></a> 

 Gets details about the tenant from Azure AD.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
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
[NonDebuggable]
procedure GetUsersPage(NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
```
#### Parameters
*NumberOfUsers ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))* 

The number of users to return.

*UserInfoPage ([DotNet UserInfoPage]())* 

The list of users to return.

### OnInitialize (Event) <a name="OnInitialize"></a> 

 Publishes an event that is used to initialize the Azure AD Graph.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
[NonDebuggable]
internal procedure OnInitialize(var GraphQuery: DotNet GraphQuery)
```
#### Parameters
*GraphQuery ([DotNet GraphQuery]())* 

The graph that the Azure AD Graph will be initialized with.

