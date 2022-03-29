// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to fetch the default permission sets for a plan.
/// </summary>
codeunit 9823 "Default Permission Set In Plan"
{
    Access = Public;

    #region Public

    /// <summary>
    /// Event to fetch the default permission sets for a plan.
    /// After subscribing to the event, call <see cref="AddPermissionSetToPlan"/> to add default permission set for the plan.
    /// </summary>
    /// <param name="PlanId">The ID of the plan</param>
    [IntegrationEvent(true, false)]
    internal procedure OnGetDefaultPermissions(PlanId: Guid)
    begin
    end;

    /// <summary>
    /// Add a default permission set for a plan.
    /// </summary>
    /// <see cref="OnGetDefautPermissions"/>
    /// <param name="RoleId">The ID of the role (permission set).</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    /// <param name="Scope">The scope of the permission set.</param>
    [Scope('OnPrem')]
    procedure AddPermissionSetToPlan(RoleId: Code[20]; AppId: Guid; Scope: Option)
    begin
        LocalDefaultPermissionSetInPlan.Init();
        LocalDefaultPermissionSetInPlan."Plan ID" := SelectedPlanId;
        LocalDefaultPermissionSetInPlan."Role ID" := RoleId;
        LocalDefaultPermissionSetInPlan.Scope := Scope;
        LocalDefaultPermissionSetInPlan."App ID" := AppId;

        if LocalDefaultPermissionSetInPlan.Insert() then;
    end;

    #endregion

    #region Internal
    internal procedure GetPermissionSets(PlanId: Guid; var DefaultPermissionSetInPlan: Record "Default Permission Set In Plan")
    begin
        SelectedPlanId := PlanId;
        DefaultPermissionSetInPlan.DeleteAll();
        LocalDefaultPermissionSetInPlan.DeleteAll();

        OnGetDefaultPermissions(SelectedPlanId);

        if LocalDefaultPermissionSetInPlan.FindSet() then
            repeat
                DefaultPermissionSetInPlan.TransferFields(LocalDefaultPermissionSetInPlan);
                DefaultPermissionSetInPlan.Insert();
            until LocalDefaultPermissionSetInPlan.Next() = 0;
    end;

    var
        LocalDefaultPermissionSetInPlan: Record "Default Permission Set In Plan";
        SelectedPlanId: Guid;
    #endregion
}