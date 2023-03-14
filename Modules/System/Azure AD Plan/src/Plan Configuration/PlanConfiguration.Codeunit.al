// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to operation with plan configurations and customized permission sets related to a plan.
/// </summary>
codeunit 9825 "Plan Configuration"
{
    Access = Public;

    /// <summary>
    /// Checks if a plan configuration was customized.
    /// </summary>
    /// <param name="PlanId">The ID of the plan for which to check.</param>
    /// <returns>True if the plan configuration was customized; false otherwise.</returns>
    procedure IsCustomized(PlanId: Guid): Boolean
    begin
        exit(PlanConfigurationImpl.IsCustomized(PlanId));
    end;

    /// <summary>
    /// Adds a permission set to a plan.
    /// </summary>
    /// <param name="PlanId">The ID of the plan.</param>
    /// <param name="RoleId">The ID of the role(permission set).</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    /// <param name="Scope">The scope of the permission set.</param>
    /// <param name="Company">The company for which to add the permission set.</param>
    [Scope('OnPrem')]
    procedure AddCustomPermissionSetToPlan(PlanId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option; Company: Text[30])
    begin
        PlanConfigurationImpl.AddCustomPermissionSetToPlan(PlanId, RoleId, AppId, Scope, Company);
    end;

    /// <summary>
    /// Removes a permissions set from a plan.
    /// </summary>
    /// <param name="PlanId">The ID of the plan.</param>
    /// <param name="RoleId">The ID of the role(permission set).</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    /// <param name="Scope">The scope of the permission set.</param>
    /// <param name="Company">The company for which to remove the permission set.</param>
    [Scope('OnPrem')]
    procedure RemoveCustomPermissionSetFromPlan(PlanId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option; Company: Text)
    begin
        PlanConfigurationImpl.RemoveCustomPermissionSetFromPlan(PlanId, RoleId, AppId, Scope, Company);
    end;

    /// <summary>
    /// Assigns all custom permission sets for a plan to a user.
    /// </summary>
    /// <param name="PlanId">The ID of the plan for which to look for custom permissions.</param>
    /// <param name="UserSecurityId">The security ID for the user to whom to assign the custom permission sets.</param>
    [Scope('OnPrem')]
    procedure AssignCustomPermissionsToUser(PlanId: Guid; UserSecurityId: Guid)
    begin
        PlanConfigurationImpl.AssignCustomPermissionsToUser(PlanId, UserSecurityId);
    end;

    /// <summary>
    /// Checks whether the current user has enough permissions to assign or de-assign a permission set from plan.
    /// </summary>
    /// <error>When the user doesn''t have neither SUPER, not SECURITY</error>
    /// <error>When the user has either SUPER or SECURITY, but does not have the permissions set assigned.</error>
    /// <param name="RoleId">The ID of the role(permission set).</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    /// <param name="Scope">The scope of the permission set.</param>
    /// <param name="Company">The company for which to check.</param>
    [Scope('OnPrem')]
    procedure VerifyUserHasRequiredPermissionSet(RoleId: Code[20]; AppId: Guid; Scope: Option; Company: Text)
    begin
        PlanConfigurationImpl.VerifyUserHasRequiredPermissionSet(RoleId, AppId, Scope, Company);
    end;

    /// <summary>
    /// Indicates whether a custom permission set assign to a plan has changed.
    /// </summary>
    /// <param name="PlanId">The ID of the plan for which a permission set has changed.</param>
    /// <param name="RoleId">The ID of the role(permission set) which changed</param>
    /// <param name="Scope">The scope of the permission set.</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    /// <param name="Company">The company for which to check.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnCustomPermissionSetChange(PlanId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option; Company: Text[30]);
    begin
    end;

    /// <summary>
    /// Event for after default permissions has been transfered to custom.
    /// </summary>
    /// <param name="PlanId">The ID of the plan.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterTransferPermissions(PlanId: Guid)
    begin
    end;

    /// <summary>
    /// Event for after custom permissions have been deleted and the corresponding plan configuration is no longer customized.
    /// </summary>
    /// <param name="PlanId">The ID of the plan.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeleteCustomPermissions(PlanId: Guid)
    begin
    end;

    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
}