This module provides methods for retrieving and managing user plans in Azure Active Directory as well as configuring the permissions users will get when assigned a plan. The Plan and User Plan tables are marked as internal, so you must use the methods provided in this module to query them.

For on-premises versions, you can also use this module to do the following:
- Check which plans are assigned to the users.
- Update user plans.
- Check for mixed plans.
- Query the internal Plan and User Plan tables.

# Public Objects
## Azure AD Plan (Codeunit 9016)

 Retrieve plans in Azure AD and manage plans
 

### IsPlanAssigned (Method) <a name="IsPlanAssigned"></a> 

 Checks if the plan is assigned to any user.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
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
[NonDebuggable]
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
[NonDebuggable]
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
[NonDebuggable]
procedure IsGraphUserEntitledFromServicePlan(var GraphUser: DotNet UserInfo): Boolean
```
#### Parameters
*GraphUser ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

the user to check.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the given user is entitled from the service plan.
### AssignDelegatedAdminPlanAndUserGroups (Method) <a name="AssignDelegatedAdminPlanAndUserGroups"></a> 

 Assign the delegated admin plan and default user groups to the current user.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure AssignDelegatedAdminPlanAndUserGroups()
```
### UpdateUserPlans (Method) <a name="UpdateUserPlans"></a> 
OnRemoveUserGroupsForUserAndPlan


 Updates license plans for a user.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure UpdateUserPlans(UserSecurityId: Guid; var GraphUser: DotNet UserInfo)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user for whom to update license information.

*GraphUser ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The graph user corresponding to the user to update, and containing the information about the plans assigned to the user.

### UpdateUserPlans (Method) <a name="UpdateUserPlans"></a> 
OnRemoveUserGroupsForUserAndPlan


 Updates license plans for a user.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure UpdateUserPlans(UserSecurityId: Guid; var GraphUser: DotNet UserInfo; AppendPermissionsOnNewPlan: Boolean; RemovePermissionsOnDeletePlan: Boolean)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user for whom to update license information.

*GraphUser ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The graph user corresponding to the user to update, and containing the information about the plans assigned to the user.

*AppendPermissionsOnNewPlan ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Append permissions from the new plan to the user.

*RemovePermissionsOnDeletePlan ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Remove permissions when removing the plan for the user.

### UpdateUserPlans (Method) <a name="UpdateUserPlans"></a> 
OnRemoveUserGroupsForUserAndPlan


 Updates license plans for a user.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure UpdateUserPlans(UserSecurityId: Guid)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user for whom to update license information.

### UpdateUserPlans (Method) <a name="UpdateUserPlans"></a> 
OnRemoveUserGroupsForUserAndPlan


 Updates license plans for a user.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
[Obsolete('Replaced with an overload accepting the RemovePlansOnDeleteUser parameter', '18.0')]
procedure UpdateUserPlans(UserSecurityId: Guid; AppendPermissionsOnNewPlan: Boolean; RemovePermissionsOnDeletePlan: Boolean)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user for whom to update license information.

*AppendPermissionsOnNewPlan ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Append permissions from the new plan to the user.

*RemovePermissionsOnDeletePlan ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Remove permissions when removing the plan for the user.

### UpdateUserPlans (Method) <a name="UpdateUserPlans"></a> 
OnRemoveUserGroupsForUserAndPlan


 Updates license plans for a user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure UpdateUserPlans(UserSecurityId: Guid; AppendPermissionsOnNewPlan: Boolean; RemovePermissionsOnDeletePlan: Boolean; RemovePlansOnDeleteUser: Boolean)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user for whom to update license information.

*AppendPermissionsOnNewPlan ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Add permissions from the new license plan to the user. Existing permissions will not be affected.

*RemovePermissionsOnDeletePlan ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Remove permissions when removing a license plan for a user.

*RemovePlansOnDeleteUser ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Remove license plans when a user is deleted in Office 365.

### UpdateUserPlans (Method) <a name="UpdateUserPlans"></a> 
OnRemoveUserGroupsForUserAndPlan


 Updates plans for all users.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure UpdateUserPlans()
```
### RefreshUserPlanAssignments (Method) <a name="RefreshUserPlanAssignments"></a> 
OnRemoveUserGroupsForUserAndPlan


 Refreshes the user plans assigned to the given user.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
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
[NonDebuggable]
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
[NonDebuggable]
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
[NonDebuggable]
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
[NonDebuggable]
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
[NonDebuggable]
procedure DoesUserHavePlans(UserSecurityId: Guid): Boolean
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user GUID.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if the given user has at least one plan.
### GetAvailablePlansCount (Method) <a name="GetAvailablePlansCount"></a> 

 Gets the total number of available plans.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetAvailablePlansCount(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

Returns the total number of available plans.
### CheckMixedPlans (Method) <a name="CheckMixedPlans"></a> 
The OnCanCurrentUserManagePlansAndGroups event to ensure this API is called with the proper authorization.


 Checks whether the plan configuration mixes different plans.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure CheckMixedPlans()
```
### CheckMixedPlans (Method) <a name="CheckMixedPlans"></a> 

 Checks whether the plan configuration mixes different plans.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure CheckMixedPlans(PlanNamesPerUser: Dictionary of [Text, List of [Text]]; ErrorOutForAdmin: Boolean)
```
#### Parameters
*PlanNamesPerUser ([Dictionary of [Text, List of [Text]]]())* 

A mapping of new plans for user identifiers.

*ErrorOutForAdmin ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies if an error (instead of a message) should be shown for an admin when this function is called.

### MixedPlansExist (Method) <a name="MixedPlansExist"></a> 

 Returns true if there are incompatible plans in the system.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure MixedPlansExist(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if there are incompatible plans in the system. 
### GetPlanNames (Method) <a name="GetPlanNames"></a> 

 Gets plans that are assigned to a user in Office 365.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetPlanNames(GraphUser: DotNet UserInfo; var PlanNames: List of [Text])
```
#### Parameters
*GraphUser ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The Graph user to get plans for.

*PlanNames ([List of [Text]]())* 

The names of the plans that are assigned to the user in Office 365.

### GetPlanNames (Method) <a name="GetPlanNames"></a> 

 Gets plans that are assigned to a Business Central user.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetPlanNames(UserSecID: Guid; var PlanNames: List of [Text])
```
#### Parameters
*UserSecID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The security ID of the user whose plans we are getting.

*PlanNames ([List of [Text]]())* 

The plan names of plans assigned to the Office 365 user.

### GetPlanIDs (Method) <a name="GetPlanIDs"></a> 

 Gets plans that are assigned to a user in Office 365.
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetPlanIDs(GraphUser: DotNet UserInfo; var PlanIDs: List of [Guid])
```
#### Parameters
*GraphUser ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The Graph user to get plans for.

*PlanIDs ([List of [Guid]]())* 

The IDs of the plans that are assigned to the user in Office 365.

### CheckIfPlansDifferent (Method) <a name="CheckIfPlansDifferent"></a> 

 Checks whether a user is assigned to different plans in Business Central and Graph.
 

#### Syntax
```
[NonDebuggable]
procedure CheckIfPlansDifferent(GraphUser: DotNet UserInfo; UserSecID: Guid): Boolean
```
#### Parameters
*GraphUser ([DotNet UserInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.clients.activedirectory.userinfo?view=azure-dotnet))* 

The user in Graph to check plans for.

*UserSecID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The security ID of the user to get plans for.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True, if the plans differ, false otherwise.
### IsBCServicePlan (Method) <a name="IsBCServicePlan"></a> 

 Checks whether a given service plan is a Business Central service Plan
 

#### Syntax
```
[NonDebuggable]
procedure IsBCServicePlan(ServicePlanId: Guid): Boolean
```
#### Parameters
*ServicePlanId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The plan to check.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True, if the service plan is a Business Central Plan, false otherwise.
### SetTestInProgress (Method) <a name="SetTestInProgress"></a> 

 Sets this codeunit in test mode (for running unit tests).
 

#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
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
[NonDebuggable]
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
[NonDebuggable]
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
[NonDebuggable]
internal procedure OnCanCurrentUserManagePlansAndGroups(var CanManage: Boolean)
```
#### Parameters
*CanManage ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Whether the user can manage plans and groups


## Plan Ids (Codeunit 9027)

 Exposes functionality to get plan IDs.
 

### GetBasicPlanId (Method) <a name="GetBasicPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central Basic Financials plan.
 

#### Syntax
```
procedure GetBasicPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central Basic Financials plan.
### GetTeamMemberPlanId (Method) <a name="GetTeamMemberPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central Team Member plan.
 

#### Syntax
```
procedure GetTeamMemberPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central Team Member plan.
### GetEssentialPlanId (Method) <a name="GetEssentialPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central Essentials plan.
 

#### Syntax
```
procedure GetEssentialPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central Essentials plan.
### GetPremiumPlanId (Method) <a name="GetPremiumPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central Premium plan.
 

#### Syntax
```
procedure GetPremiumPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central Premium plan.
### GetViralSignupPlanId (Method) <a name="GetViralSignupPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central for IWs plan.
 

#### Syntax
```
procedure GetViralSignupPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central for IWs plan.
### GetExternalAccountantPlanId (Method) <a name="GetExternalAccountantPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central External Accountant plan.
 

#### Syntax
```
procedure GetExternalAccountantPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central External Accountant plan.
### GetDelegatedAdminPlanId (Method) <a name="GetDelegatedAdminPlanId"></a> 

 Returns the ID for the Delegated Admin agent - Partner plan.
 

#### Syntax
```
procedure GetDelegatedAdminPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Delegated Admin agent - Partner plan.
### GetD365AdminPartnerPlanId (Method) <a name="GetD365AdminPartnerPlanId"></a> 

 Returns the ID for the Dynamics 365 Admin - Partner plan.
 

#### Syntax
```
procedure GetD365AdminPartnerPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Admin - Partner plan.
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

 Returns the ID for the D365 Business Central Team Member - Embedded plan.
 

#### Syntax
```
procedure GetTeamMemberISVPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the D365 Business Central Team Member - Embedded plan.
### GetEssentialISVPlanId (Method) <a name="GetEssentialISVPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central Essential - Embedded plan.
 

#### Syntax
```
procedure GetEssentialISVPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central Essential - Embedded plan.
### GetPremiumISVPlanId (Method) <a name="GetPremiumISVPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central Premium - Embedded plan.
 

#### Syntax
```
procedure GetPremiumISVPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central Premium - Embedded plan.
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

 Returns the ID for the Dynamics 365 Business Central Device plan.
 

#### Syntax
```
procedure GetDevicePlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central Device plan.
### GetBasicFinancialsISVPlanId (Method) <a name="GetBasicFinancialsISVPlanId"></a> 

 Returns the ID for the Dynamics 365 Business Central Basic Financials - Embedded plan.
 

#### Syntax
```
procedure GetBasicFinancialsISVPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Dynamics 365 Business Central Basic Financials - Embedded plan.
### GetAccountantHubPlanId (Method) <a name="GetAccountantHubPlanId"></a> 

 Returns the ID for the Microsoft Dynamics 365 - Accountant Hub plan.
 

#### Syntax
```
procedure GetAccountantHubPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Microsoft Dynamics 365 - Accountant Hub plan.
### GetHelpDeskPlanId (Method) <a name="GetHelpDeskPlanId"></a> 

 Returns the ID for the Delegated Helpdesk agent - Partner plan.
 

#### Syntax
```
procedure GetHelpDeskPlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the Delegated Helpdesk agent - Partner plan.
### GetInfrastructurePlanId (Method) <a name="GetInfrastructurePlanId"></a> 

 Returns the ID for the D365 Business Central Infrastructure plan.
 

#### Syntax
```
procedure GetInfrastructurePlanId(): Guid
```
#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID for the D365 Business Central Infrastructure plan.

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

## Plans (Page 9824)

 List page that contains all plans that can be assigned to users.
 


## Plans FactBox (Page 9825)

 ListPart page that contains all the plans.
 


## User Plan Members (Page 9822)

 List page that contains all users and the plans that they are assigned to.
 


## User Plan Members FactBox (Page 9823)

 ListPart page that contains all the user plan members.
 


## User Plans FactBox (Page 9826)

 ListPart page that contains the plans assigned to users.
 


## Plan (Query 775)

 Displays a list of plans.
 


## Users in Plans (Query 774)

 Displays a list of the plans assigned to users.
 

