The modules exposes functionality to check and alter User Permission sets.

User this module to do the following:
- Check if a user has SUPER permission set assigned to them.<br />
  Note that SUPER permission set does not grant more permissions than the ones defined in the user entitlement.<br />
  Read more about [entitlements in Business Central](https://cloudblogs.microsoft.com/dynamics365/it/2019/07/18/business-central-entitlements/).
- Remove the SUPER permission set from a user.<br />
  Note that at any tome there must at least one user who has SUPER permission set assigned.

# Public Objects
## User Permissions (Codeunit 152)

 Exposes functionality to check if a user has SUPER permissions set assigned as well as removing such permissions set from a user.
 

### IsSuper (Method) <a name="IsSuper"></a> 

 Checks whether the user has the SUPER permissions set.
 

#### Syntax
```
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

### CanManageUsersOnTenant (Method) <a name="CanManageUsersOnTenant"></a> 

 Checks whether the user has permission to manage users in the tenant.
 

#### Syntax
```
procedure CanManageUsersOnTenant(UserSecurityId: Guid): Boolean
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The security ID of the user to check for.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the user with the given user security ID can manage users on tenant; false otherwise.
### HasUserCustomPermissions (Method) <a name="HasUserCustomPermissions"></a> 

 Checks whether custom permissions are assigned to the user.
 

#### Syntax
```
procedure HasUserCustomPermissions(UserSecurityId: Guid): Boolean
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The security ID of the user to check for.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the user with the given user security ID has custom permissions; false otherwise.
