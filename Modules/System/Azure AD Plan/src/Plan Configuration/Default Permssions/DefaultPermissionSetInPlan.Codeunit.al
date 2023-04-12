#if not CLEAN22
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
    ObsoleteState = Pending;
    ObsoleteReason = 'Getting the default permissions will be done only inside the Azure AD Plan module.';
    ObsoleteTag = '22.0';

    var
        DefaultPSInPlanImpl: Codeunit "Default PS in Plan Impl";

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
    /// <see cref="OnGetDefaultPermissions"/>
    /// <param name="RoleId">The ID of the role (permission set).</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    /// <param name="Scope">The scope of the permission set.</param>
    [Scope('OnPrem')]
    procedure AddPermissionSetToPlan(RoleId: Code[20]; AppId: Guid; Scope: Option)
    begin
        DefaultPSInPlanImpl.AddPermissionSetToPlan(RoleId, AppId, Scope);
    end;

    internal procedure GetPermissionSets(PlanId: Guid; var DefaultPermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer")
    begin
        DefaultPSInPlanImpl.GetPermissionSets(PlanId, DefaultPermissionSetInPlanBuffer);
    end;
}
#endif