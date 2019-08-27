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
        AzureAdPlanImpl: Codeunit "Azure AD Plan Impl.";

    /// <summary>
    /// Checks if the plan is assigned to any user.
    /// </summary>
    /// <param name="PlanGUID">the plan GUID.</param>
    /// <returns>true if the given plan has users assigned to it.</returns>
    [Scope('OnPrem')]
    procedure IsPlanAssigned(PlanGUID: Guid): Boolean
    begin
        EXIT(AzureAdPlanImpl.IsPlanAssigned(PlanGUID));
    end;

    /// <summary>
    /// Checks if the plan is assigned to the current user.
    /// </summary>
    /// <param name="PlanGUID">the plan GUID.</param>
    /// <returns>true if the given plan is assigned to the current user.</returns>
    [Scope('OnPrem')]
    procedure IsPlanAssignedToUser(PlanGUID: Guid): Boolean
    begin
        EXIT(AzureAdPlanImpl.IsPlanAssignedToUser(PlanGUID));
    end;

    /// <summary>
    /// Checks if the plan is assigned to a specific user.
    /// </summary>
    /// <param name="PlanGUID">the plan GUID.</param>
    /// <param name="UserGUID">the user GUID.</param>
    /// <returns>true if the given plan is assigned to the given user.</returns>
    [Scope('OnPrem')]
    procedure IsPlanAssignedToUser(PlanGUID: Guid; UserGUID: Guid): Boolean
    begin
        EXIT(AzureAdPlanImpl.IsPlanAssignedToUser(PlanGUID, UserGUID));
    end;

    /// <summary>
    /// Returns true if the given user is entitled from the service plan.
    /// </summary>
    /// <param name="GraphUser">the user to check.</param>
    /// <returns>True if the given user is entitled from the service plan.</returns>
    [Scope('OnPrem')]
    procedure IsGraphUserEntitledFromServicePlan(var GraphUser: DotNet UserInfo): Boolean
    begin
        EXIT(AzureAdPlanImpl.IsGraphUserEntitledFromServicePlan(GraphUser));
    end;

    /// <summary>
    /// Updates plans for user.
    /// </summary>
    /// <raises>OnRemoveUserGroupsForUserAndPlan</raises>
    /// <raises>OnUpdateUserAccessForSaaS</raises>
    /// <param name="UserSecurityId">The user to update.</param>
    /// <param name="GraphUser">The graph user corresponding to the user to update, and containing the information about the plans assigned to the user.</param>
    [Scope('OnPrem')]
    procedure UpdateUserPlans(UserSecurityId: Guid; var GraphUser: DotNet UserInfo)
    begin
        AzureAdPlanImpl.UpdateUserPlans(UserSecurityId, GraphUser);
    end;

    /// <summary>
    /// Updates plans for user.
    /// </summary>
    /// <raises>OnRemoveUserGroupsForUserAndPlan</raises>
    /// <raises>OnUpdateUserAccessForSaaS</raises>
    /// <param name="UserSecurityId">The user to update.</param>
    [Scope('OnPrem')]
    procedure UpdateUserPlans(UserSecurityId: Guid)
    begin
        AzureAdPlanImpl.UpdateUserPlans(UserSecurityId);
    end;

    /// <summary>
    /// Updates plans for all users.
    /// </summary>
    /// <raises>OnRemoveUserGroupsForUserAndPlan</raises>
    /// <raises>OnUpdateUserAccessForSaaS</raises>
    [Scope('OnPrem')]
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
    procedure TryGetAzureUserPlanRoleCenterId(var RoleCenterID: Integer; UserSecurityId: Guid)
    begin
        AzureAdPlanImpl.TryGetAzureUserPlanRoleCenterId(RoleCenterID, UserSecurityId);
    end;

    /// <summary>
    /// Returns true if at least one plan exists.
    /// </summary>
    /// <returns>Returns true if at least one plan exist.</returns>
    [Scope('OnPrem')]
    procedure DoPlansExist(): Boolean
    begin
        exit(AzureAdPlanImpl.DoPlansExist());
    end;

    /// <summary>
    /// Returns true if at least one user is assigned to a plan.
    /// </summary>
    /// <returns>Returns true if at least one user is assigned to a plan.</returns>
    [Scope('OnPrem')]
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
    procedure DoesUserHavePlans(UserSecurityId: Guid): Boolean
    begin
        exit(AzureAdPlanImpl.DoesUserHavePlans(UserSecurityId));
    end;

    /// <summary>
    /// Returns the total number of available plans.
    /// </summary>
    /// <returns>Returns the total number of available plans.</returns>
    [Scope('OnPrem')]
    procedure GetAvailablePlansCount(): Integer
    begin
        exit(AzureAdPlanImpl.GetAvailablePlansCount());
    end;

    /// <summary>
    /// Checks if mixed plans are correctly set.
    /// </summary>
    /// <raises>OnCanCurrentUserManagePlansAndGroups</raises>
    [Scope('OnPrem')]
    procedure CheckMixedPlans()
    begin
        AzureAdPlanImpl.CheckMixedPlans();
    end;

    /// <summary>
    /// Returns true if a mixed plan exists. 
    /// </summary>
    /// <returns>Returns true if a mixed plan exists.</returns>
    [Scope('OnPrem')]
    procedure MixedPlansExist(): Boolean
    begin
        exit(AzureAdPlanImpl.MixedPlansExist());
    end;

    /// <summary>
    /// Sets this codeunit in test mode (for running unit tests).
    /// </summary>
    /// <param name="EnableTestability">True to enable the test mode.</param>
    [Scope('OnPrem')]
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
    internal procedure OnCanCurrentUserManagePlansAndGroups(var CanManage: Boolean);
    begin
    end;
}