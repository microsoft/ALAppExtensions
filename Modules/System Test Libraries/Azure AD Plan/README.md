# Public Objects
## Azure AD Plan Test Library (Codeunit 132916)
### AssignUserToPlan (Method) <a name="AssignUserToPlan"></a> 

 Assigns a plan to a user. 
 

#### Syntax
```
procedure AssignUserToPlan(UserID: Guid; PlanID: Guid)
```
#### Parameters
*UserID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user ID.

*PlanID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The plan to assign to the user.

### AssignUserToPlan (Method) <a name="AssignUserToPlan"></a> 

 Assigns a plan to a user.
 

#### Syntax
```
procedure AssignUserToPlan(UserID: Guid; PlanID: Guid; Validate: Boolean)
```
#### Parameters
*UserID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user ID.

*PlanID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The plan to assign to the user.

*Validate ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Flag to indicate whether to run the validate trigger.

### ReassignPlanToUser (Method) <a name="ReassignPlanToUser"></a> 

 Reassign a plan to a user. 
 

#### Syntax
```
procedure ReassignPlanToUser(UserID: Guid; PlanID: Guid)
```
#### Parameters
*UserID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user ID.

*PlanID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The plan to reassign to the user.

### CreatePlan (Method) <a name="CreatePlan"></a> 

 Insert a new plan in the Plan table.
 

#### Syntax
```
procedure CreatePlan(PlanName: Text[50])PlanID: Guid
```
#### Parameters
*PlanName ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the new plan.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The new plan ID.
### CreatePlan (Method) <a name="CreatePlan"></a> 

 Insert a new plan in the Plan table.
 

#### Syntax
```
procedure CreatePlan(PlanGuid: Guid; PlanName: Text[50]; RoleCenterID: Integer; SystemId: Guid)
```
#### Parameters
*PlanGuid ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 



*PlanName ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the new plan.

*RoleCenterID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The RoleCenterID of the new plan.

*SystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The SystemId of the new plan.

### ChangePlanRoleCenterID (Method) <a name="ChangePlanRoleCenterID"></a> 

 Change the RoleCenterID for a specific plan.
 

#### Syntax
```
procedure ChangePlanRoleCenterID(PlanID: Guid; RoleCenterID: Integer)
```
#### Parameters
*PlanID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The plan ID.

*RoleCenterID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The new RoleCenterID.

### DeletePlan (Method) <a name="DeletePlan"></a> 

 Delete a specific plan.
 

#### Syntax
```
procedure DeletePlan(PlanName: Text[50])
```
#### Parameters
*PlanName ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



### DeleteAllPlans (Method) <a name="DeleteAllPlans"></a> 

 Delete everything from the table Plan.
 

#### Syntax
```
procedure DeleteAllPlans()
```
### DeleteAllUserPlan (Method) <a name="DeleteAllUserPlan"></a> 

 Delete everything from the table User Plan.
 

#### Syntax
```
procedure DeleteAllUserPlan()
```
### RemoveUserFromPlan (Method) <a name="RemoveUserFromPlan"></a> 

 Delete a user with a specific plan assigned.
 

#### Syntax
```
procedure RemoveUserFromPlan(UserID: Guid; PlanID: Guid)
```
#### Parameters
*UserID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user to delete.

*PlanID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The plan to delete.

