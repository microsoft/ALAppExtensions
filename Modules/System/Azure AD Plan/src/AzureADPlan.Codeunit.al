// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Retrieve plans in Azure AD and manage plans
/// </summary>
codeunit 9016 "Azure AD Plan"
{
    var
        [NonDebuggable]
        AzureAdPlanImpl: Codeunit "Azure AD Plan Impl.";

    /// <summary>
    /// Checks if the plan is assigned to any user.
    /// </summary>
    /// <param name="PlanGUID">the plan GUID.</param>
    /// <returns>true if the given plan has users assigned to it.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure IsPlanAssigned(PlanGUID: Guid): Boolean
    begin
        exit(AzureAdPlanImpl.IsPlanAssigned(PlanGUID));
    end;

    /// <summary>
    /// Checks if the plan is assigned to the current user.
    /// </summary>
    /// <param name="PlanGUID">the plan GUID.</param>
    /// <returns>true if the given plan is assigned to the current user.</returns>
    [NonDebuggable]
    procedure IsPlanAssignedToUser(PlanGUID: Guid): Boolean
    begin
        exit(AzureAdPlanImpl.IsPlanAssignedToUser(PlanGUID));
    end;

    /// <summary>
    /// Checks if the plan is assigned to a specific user.
    /// </summary>
    /// <param name="PlanGUID">the plan GUID.</param>
    /// <param name="UserGUID">the user GUID.</param>
    /// <returns>true if the given plan is assigned to the given user.</returns>
    [NonDebuggable]
    procedure IsPlanAssignedToUser(PlanGUID: Guid; UserGUID: Guid): Boolean
    begin
        exit(AzureAdPlanImpl.IsPlanAssignedToUser(PlanGUID, UserGUID));
    end;

    /// <summary>
    /// Returns true if the given user is entitled from the service plan.
    /// </summary>
    /// <param name="GraphUserInfo">the user to check.</param>
    /// <returns>True if the given user is entitled from the service plan.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure IsGraphUserEntitledFromServicePlan(var GraphUserInfo: DotNet UserInfo): Boolean
    begin
        exit(AzureAdPlanImpl.IsGraphUserEntitledFromServicePlan(GraphUserInfo));
    end;

    /// <summary>
    /// Assign the delegated admin plan and default user groups to the current user.
    /// </summary>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure AssignDelegatedAdminPlanAndUserGroups()
    begin
        AzureAdPlanImpl.AssignDelegatedAdminPlanAndUserGroups();
    end;

    /// <summary>
    /// Updates license plans for a user.
    /// </summary>
    /// <raises>OnRemoveUserGroupsForUserAndPlan</raises>
    /// <raises>OnUpdateUserAccessForSaaS</raises>
    /// <param name="UserSecurityId">The user for whom to update license information.</param>
    /// <param name="GraphUserInfo">The graph user corresponding to the user to update, and containing the information about the plans assigned to the user.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure UpdateUserPlans(UserSecurityId: Guid; var GraphUserInfo: DotNet UserInfo)
    begin
        AzureAdPlanImpl.UpdateUserPlans(UserSecurityId, GraphUserInfo, true, true);
    end;

    /// <summary>
    /// Updates license plans for a user.
    /// </summary>
    /// <raises>OnRemoveUserGroupsForUserAndPlan</raises>
    /// <raises>OnUpdateUserAccessForSaaS</raises>
    /// <param name="UserSecurityId">The user for whom to update license information.</param>
    /// <param name="GraphUserInfo">The graph user corresponding to the user to update, and containing the information about the plans assigned to the user.</param>
    /// <param name="AppendPermissionsOnNewPlan">Append permissions from the new plan to the user.</param>
    /// <param name="RemovePermissionsOnDeletePlan">Remove permissions when removing the plan for the user.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure UpdateUserPlans(UserSecurityId: Guid; var GraphUserInfo: DotNet UserInfo; AppendPermissionsOnNewPlan: Boolean; RemovePermissionsOnDeletePlan: Boolean)
    begin
        AzureAdPlanImpl.UpdateUserPlans(UserSecurityId, GraphUserInfo, AppendPermissionsOnNewPlan, RemovePermissionsOnDeletePlan);
    end;

    /// <summary>
    /// Updates license plans for a user.
    /// </summary>
    /// <raises>OnRemoveUserGroupsForUserAndPlan</raises>
    /// <raises>OnUpdateUserAccessForSaaS</raises>
    /// <param name="UserSecurityId">The user for whom to update license information.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure UpdateUserPlans(UserSecurityId: Guid)
    begin
        AzureAdPlanImpl.UpdateUserPlans(UserSecurityId, true, true, false);
    end;

#if not CLEAN18
    /// <summary>
    /// Updates license plans for a user.
    /// </summary>
    /// <raises>OnRemoveUserGroupsForUserAndPlan</raises>
    /// <raises>OnUpdateUserAccessForSaaS</raises>
    /// <param name="UserSecurityId">The user for whom to update license information.</param>
    /// <param name="AppendPermissionsOnNewPlan">Append permissions from the new plan to the user.</param>
    /// <param name="RemovePermissionsOnDeletePlan">Remove permissions when removing the plan for the user.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    [Obsolete('Replaced with an overload accepting the RemovePlansOnDeleteUser parameter', '18.0')]
    procedure UpdateUserPlans(UserSecurityId: Guid; AppendPermissionsOnNewPlan: Boolean; RemovePermissionsOnDeletePlan: Boolean)
    begin
        AzureAdPlanImpl.UpdateUserPlans(UserSecurityId, AppendPermissionsOnNewPlan, RemovePermissionsOnDeletePlan, false);
    end;
#endif

    /// <summary>
    /// Updates license plans for a user.
    /// </summary>
    /// <raises>OnRemoveUserGroupsForUserAndPlan</raises>
    /// <raises>OnUpdateUserAccessForSaaS</raises>
    /// <param name="UserSecurityId">The user for whom to update license information.</param>
    /// <param name="AppendPermissionsOnNewPlan">Add permissions from the new license plan to the user. Existing permissions will not be affected.</param>
    /// <param name="RemovePermissionsOnDeletePlan">Remove permissions when removing a license plan for a user.</param>
    /// <param name="RemovePlansOnDeleteUser">Remove license plans when a user is deleted in Office 365.</param>
    [Scope('OnPrem')]
    procedure UpdateUserPlans(UserSecurityId: Guid; AppendPermissionsOnNewPlan: Boolean; RemovePermissionsOnDeletePlan: Boolean; RemovePlansOnDeleteUser: Boolean)
    begin
        AzureAdPlanImpl.UpdateUserPlans(UserSecurityId, AppendPermissionsOnNewPlan, RemovePermissionsOnDeletePlan, RemovePlansOnDeleteUser);
    end;

    /// <summary>
    /// Updates plans for all users.
    /// </summary>
    /// <raises>OnRemoveUserGroupsForUserAndPlan</raises>
    /// <raises>OnUpdateUserAccessForSaaS</raises>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure UpdateUserPlans()
    begin
        AzureAdPlanImpl.UpdateUserPlans();
    end;

    /// <summary>
    /// Refreshes the user plans assigned to the given user.
    /// </summary>
    /// <raises>OnRemoveUserGroupsForUserAndPlan</raises>
    /// <raises>OnUpdateUserAccessForSaaS</raises>
    /// <param name="UserSecurityId">The user to update.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure RefreshUserPlanAssignments(UserSecurityId: Guid)
    begin
        AzureAdPlanImpl.RefreshUserPlanAssignments(UserSecurityId);
    end;

    /// <summary>
    /// Returns the plan roleCenterID for the given user.
    /// </summary>
    /// <param name="RoleCenterID">The roleCenterID to return.</param>
    /// <param name="UserSecurityId">The user GUID.</param>
    [Scope('OnPrem')]
    [TryFunction]
    [NonDebuggable]
    procedure TryGetAzureUserPlanRoleCenterId(var RoleCenterID: Integer; UserSecurityId: Guid)
    begin
        AzureAdPlanImpl.TryGetAzureUserPlanRoleCenterId(RoleCenterID, UserSecurityId);
    end;

    /// <summary>
    /// Returns true if at least one plan exists.
    /// </summary>
    /// <returns>Returns true if at least one plan exist.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure DoPlansExist(): Boolean
    begin
        exit(AzureAdPlanImpl.DoPlansExist());
    end;

    /// <summary>
    /// Returns true if at least one user is assigned to a plan.
    /// </summary>
    /// <returns>Returns true if at least one user is assigned to a plan.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure DoUserPlansExist(): Boolean
    begin
        exit(AzureAdPlanImpl.DoUserPlansExist());
    end;

    /// <summary>
    /// Returns true if the given plan exists.
    /// </summary>
    /// <param name="PlanGUID">The plan GUID.</param>
    /// <returns>Returns true if the given plan exists.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure DoesPlanExist(PlanGUID: Guid): Boolean
    begin
        exit(AzureAdPlanImpl.DoesPlanExist(PlanGUID));
    end;

    /// <summary>
    /// Returns true if the given user has at least one plan.
    /// </summary>
    /// <param name="UserSecurityId">The user GUID.</param>
    /// <returns>Returns true if the given user has at least one plan.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure DoesUserHavePlans(UserSecurityId: Guid): Boolean
    begin
        exit(AzureAdPlanImpl.DoesUserHavePlans(UserSecurityId));
    end;

    /// <summary>
    /// Gets the total number of available plans.
    /// </summary>
    /// <returns>Returns the total number of available plans.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetAvailablePlansCount(): Integer
    begin
        exit(AzureAdPlanImpl.GetAvailablePlansCount());
    end;

    /// <summary>
    /// Checks whether the plan configuration mixes different plans.
    /// </summary>
    /// <raises>The OnCanCurrentUserManagePlansAndGroups event to ensure this API is called with the proper authorization.</raises>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure CheckMixedPlans()
    begin
        AzureAdPlanImpl.CheckMixedPlans();
    end;

    /// <summary>
    /// Checks whether the plan configuration mixes different plans.
    /// </summary>
    /// <param name="PlanNamesPerUser">A mapping of new plans for user identifiers.</param>
    /// <param name="ErrorOutForAdmin">Specifies if an error (instead of a message) should be shown for an admin when this function is called.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure CheckMixedPlans(PlanNamesPerUser: Dictionary of [Text, List of [Text]]; ErrorOutForAdmin: Boolean)
    begin
        AzureAdPlanImpl.CheckMixedPlans(PlanNamesPerUser, ErrorOutForAdmin);
    end;

    /// <summary>
    /// Returns true if there are incompatible plans in the system. 
    /// </summary>
    /// <returns>Returns true if there are incompatible plans in the system. </returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure MixedPlansExist(): Boolean
    begin
        exit(AzureAdPlanImpl.MixedPlansExist());
    end;

    /// <summary>
    /// Gets plans that are assigned to a user in Office 365.
    /// </summary>
    /// <param name="GraphUserInfo">The Graph user to get plans for.</param>
    /// <param name="PlanNames">The names of the plans that are assigned to the user in Office 365.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetPlanNames(GraphUserInfo: DotNet UserInfo; var PlanNames: List of [Text])
    begin
        AzureAdPlanImpl.GetPlanNames(GraphUserInfo, PlanNames);
    end;

    /// <summary>
    /// Gets plans that are assigned to a Business Central user.
    /// </summary>
    /// <param name="UserSecID">The security ID of the user whose plans we are getting.</param>
    /// <param name="PlanNames">The plan names of plans assigned to the Office 365 user.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetPlanNames(UserSecID: Guid; var PlanNames: List of [Text])
    begin
        AzureAdPlanImpl.GetPlanNames(UserSecID, PlanNames);
    end;

    /// <summary>
    /// Gets plans that are assigned to a user in Office 365.
    /// </summary>
    /// <param name="GraphUserInfo">The Graph user to get plans for.</param>
    /// <param name="PlanIDs">The IDs of the plans that are assigned to the user in Office 365.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetPlanIDs(GraphUserInfo: DotNet UserInfo; var PlanIDs: List of [Guid])
    begin
        AzureAdPlanImpl.GetPlanIDs(GraphUserInfo, PlanIDs);
    end;

    /// <summary>
    /// Checks whether a user is assigned to different plans in Business Central and Graph.
    /// </summary>
    /// <param name="GraphUserInfo">The user in Graph to check plans for.</param>
    /// <param name="UserSecID">The security ID of the user to get plans for.</param>
    /// <returns>True, if the plans differ, false otherwise.</returns>
    [NonDebuggable]
    procedure CheckIfPlansDifferent(GraphUserInfo: DotNet UserInfo; UserSecID: Guid): Boolean
    begin
        exit(AzureAdPlanImpl.CheckIfPlansDifferent(GraphUserInfo, UserSecID));
    end;

    /// <summary>
    /// Checks whether a given service plan is a Business Central service Plan
    /// </summary>
    /// <param name="ServicePlanId">The plan to check.</param>
    /// <returns>True, if the service plan is a Business Central Plan, false otherwise.</returns>
    [NonDebuggable]
    procedure IsBCServicePlan(ServicePlanId: Guid): Boolean
    begin
        exit(AzureAdPlanImpl.IsBCServicePlan(ServicePlanId));
    end;

    /// <summary>
    /// Sets this codeunit in test mode (for running unit tests).
    /// </summary>
    /// <param name="EnableTestability">True to enable the test mode.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure SetTestInProgress(EnableTestability: Boolean)
    begin
        AzureAdPlanImpl.SetTestInProgress(EnableTestability);
    end;

    /// <summary>
    /// Integration event, raised from <see cref="UpdateUserPlans"/>.
    /// Subscribe to this event to remove related user groups from the user.
    /// </summary>
    /// <param name="PlanID">The plan to remove.</param>
    /// <param name="UserSecurityID">The user to remove.</param>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    [NonDebuggable]
    internal procedure OnRemoveUserGroupsForUserAndPlan(PlanID: Guid; UserSecurityID: Guid)
    begin
    end;

    /// <summary>
    /// Integration event, raised from <see cref="UpdateUserPlans"/>.
    /// Subscribe to this event to update the user groups
    /// </summary>
    /// <param name="UserSecurityID">The user to update.</param>
    /// <param name="UserGroupsAdded">Whether the user groups were updated</param>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    [NonDebuggable]
    internal procedure OnUpdateUserAccessForSaaS(UserSecurityID: Guid; var UserGroupsAdded: Boolean)
    begin
    end;

    /// <summary>
    /// Integration event, raised from <see cref="CheckMixedPlans"/>.
    /// Subscribe to this event to check whether the user can manage plans and groups
    /// </summary>
    /// <param name="CanManage">Whether the user can manage plans and groups</param>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    [NonDebuggable]
    internal procedure OnCanCurrentUserManagePlansAndGroups(var CanManage: Boolean);
    begin
    end;
}