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
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
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
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
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
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
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
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        PlanConfigurationImpl.AssignCustomPermissionsToUser(PlanId, UserSecurityId);
    end;

    /// <summary>
    /// Removes custom permission sets for a plan from a user.
    /// If the permission set is also associated with another plan, it is not deleted.
    /// </summary>
    /// <param name="PlanId">The ID of the plan for which to look for custom permissions.</param>
    /// <param name="UserSecurityId">The security ID for the user from whom to remove the custom permission sets.</param>
    [Scope('OnPrem')]
    procedure RemoveCustomPermissionsFromUser(PlanId: Guid; UserSecurityId: Guid)
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        PlanConfigurationImpl.RemoveCustomPermissionsFromUser(PlanId, UserSecurityId);
    end;

    /// <summary>
    /// Gets the list of all custom permission sets for a plan.
    /// </summary>
    /// <param name="PermissionSetInPlanBuffer">The resulting table containing the custom permission sets.</param>
    [Scope('OnPrem')]
    procedure GetCustomPermissions(var PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer")
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        PlanConfigurationImpl.GetCustomPermissions(PermissionSetInPlanBuffer);
    end;

    /// <summary>
    /// Adds a permission set to a plan.
    /// </summary>
    /// <param name="PlanId">The ID of the plan.</param>
    /// <param name="RoleId">The ID of the role(permission set).</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    /// <param name="Scope">The scope of the permission set.</param>
    [Scope('OnPrem')]
    procedure AddDefaultPermissionSetToPlan(PlanId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option)
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        PlanConfigurationImpl.AddDefaultPermissionSetToPlan(PlanId, RoleId, AppId, Scope);
    end;

    /// <summary>
    /// Removes a permissions set from a plan.
    /// </summary>
    /// <param name="PlanId">The ID of the plan.</param>
    /// <param name="RoleId">The ID of the role(permission set).</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    /// <param name="Scope">The scope of the permission set.</param>
    [Scope('OnPrem')]
    procedure RemoveDefaultPermissionSetFromPlan(PlanId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option)
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        PlanConfigurationImpl.RemoveDefaultPermissionSetFromPlan(PlanId, RoleId, AppId, Scope);
    end;

    /// <summary>
    /// Assigns all default permission sets for a plan to a user.
    /// </summary>
    /// <param name="PlanId">The ID of the plan for which to look for default permissions.</param>
    /// <param name="UserSecurityId">The security ID for the user to whom to assign the default permission sets.</param>
    /// <param name="Company">The company for which to assign the permission sets.</param>
    [Scope('OnPrem')]
    procedure AssignDefaultPermissionsToUser(PlanId: Guid; UserSecurityId: Guid; Company: Text[30])
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        PlanConfigurationImpl.AssignDefaultPermissionsToUser(PlanId, UserSecurityId, Company);
    end;

    /// <summary>
    /// Removes default permission sets for a plan from a user.
    /// If the permission set is also associated with another plan, it is not deleted.
    /// </summary>
    /// <param name="PlanId">The ID of the plan for which to look for default permissions.</param>
    /// <param name="UserSecurityId">The security ID for the user from whom to remove the default permission sets.</param>
    [Scope('OnPrem')]
    procedure RemoveDefaultPermissionsFromUser(PlanId: Guid; UserSecurityId: Guid)
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        PlanConfigurationImpl.RemoveDefaultPermissionsFromUser(PlanId, UserSecurityId);
    end;

    /// <summary>
    /// Gets the list of all default permission sets for a plan.
    /// </summary>
    /// <param name="PermissionSetInPlanBuffer">The resulting table containing the default permission sets.</param>
    [Scope('OnPrem')]
    procedure GetDefaultPermissions(var PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer")
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        PlanConfigurationImpl.GetDefaultPermissions(PermissionSetInPlanBuffer);
    end;

    /// <summary>
    /// Checks whether the current user has enough permissions to assign or de-assign a permission set from plan.
    /// </summary>
    /// <error>When the user doesn't have neither SUPER, not SECURITY</error>
    /// <error>When the user has either SUPER or SECURITY, but does not have the permissions set assigned.</error>
    /// <param name="RoleId">The ID of the role(permission set).</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    /// <param name="Scope">The scope of the permission set.</param>
    /// <param name="Company">The company for which to check.</param>
    [Scope('OnPrem')]
    procedure VerifyUserHasRequiredPermissionSet(RoleId: Code[20]; AppId: Guid; Scope: Option; Company: Text)
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        PlanConfigurationImpl.VerifyUserHasRequiredPermissionSet(RoleId, AppId, Scope, Company);
    end;

#if not CLEAN22
    /// <summary>
    /// Indicates whether a custom permission set assign to a plan has changed.
    /// </summary>
    /// <param name="PlanId">The ID of the plan for which a permission set has changed.</param>
    /// <param name="RoleId">The ID of the role(permission set) which changed</param>
    /// <param name="Scope">The scope of the permission set.</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    /// <param name="Company">The company for which to check.</param>
    [Obsolete('Not needed when the user groups are removed.', '22.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnCustomPermissionSetChange(PlanId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option; Company: Text[30]);
    begin
    end;

    /// <summary>
    /// Event for after default permissions has been transferred to custom.
    /// </summary>
    /// <param name="PlanId">The ID of the plan.</param>
    [Obsolete('Not needed when the user groups are removed.', '22.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterTransferPermissions(PlanId: Guid)
    begin
    end;

    /// <summary>
    /// Event for after custom permissions have been deleted and the corresponding plan configuration is no longer customized.
    /// </summary>
    /// <param name="PlanId">The ID of the plan.</param>
    [Obsolete('Not needed when the user groups are removed.', '22.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeleteCustomPermissions(PlanId: Guid)
    begin
    end;

    /// <summary>
    /// Event for checking if a permission set assigned to the user is a part of any user group assigned to the user.
    /// </summary>
    /// <param name="AccessControl">The record about to be deleted.</param>
    /// <param name="IsAssignedViaUserGroups">Out parameter specifying if the permission set about to be removed is a part of a user group assigned to the user.</param>
    [Obsolete('Not needed when the user groups are removed.', '22.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeRemoveDefaultPermissionsFromUser(AccessControl: Record "Access Control"; var IsAssignedViaUserGroups: Boolean)
    begin
    end;

    /// <summary>
    /// Event for checking if a permission set assigned to the user is a part of any user group assigned to the user.
    /// </summary>
    /// <param name="AccessControl">The record about to be deleted.</param>
    /// <param name="IsAssignedViaUserGroups">Out parameter specifying if the permission set about to be removed is a part of a user group assigned to the user.</param>
    [Obsolete('Not needed when the user groups are removed.', '22.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeRemoveCustomPermissionsFromUser(AccessControl: Record "Access Control"; var IsAssignedViaUserGroups: Boolean)
    begin
    end;
#endif
}