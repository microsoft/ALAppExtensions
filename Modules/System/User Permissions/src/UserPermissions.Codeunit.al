// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to check if a user has SUPER permissions set assigned as well as removing such permissions set from a user.
/// </summary>
codeunit 152 "User Permissions"
{
    Access = Public;

    /// <summary>
    /// Checks whether the user has the SUPER permissions set.
    /// </summary>
    /// <param name="UserSecurityId">The security ID assigned to the user.</param>
    /// <returns>True if the user has the SUPER permissions set. Otherwise, false.</returns>
    procedure IsSuper(UserSecurityId: Guid): Boolean
    var
        UserPermissionsImpl: Codeunit "User Permissions Impl.";
    begin
        exit(UserPermissionsImpl.IsSuper(UserSecurityId));
    end;

    /// <summary>
    /// Removes the SUPER permissions set from a user.
    /// </summary>
    /// <param name="UserSecurityId">The security ID of the user to modify.</param>
    /// <returns>True if SUPER was removed from the user; otherwise - false.</returns>
    [Scope('OnPrem')]
    procedure RemoveSuperPermissions(UserSecurityId: Guid): Boolean
    var
        UserPermissionsImpl: Codeunit "User Permissions Impl.";
    begin
        exit(UserPermissionsImpl.RemoveSuperPermissions(UserSecurityId));
    end;

    /// <summary>
    /// Checks whether the user has permission to manage users in the tenant.
    /// </summary>
    /// <param name="UserSecurityId">The security ID of the user to check for.</param>
    /// <returns>True if the user with the given user security ID can manage users on tenant; false otherwise.</returns>  
    procedure CanManageUsersOnTenant(UserSecurityId: Guid): Boolean
    var
        UserPermissionsImpl: Codeunit "User Permissions Impl.";
    begin
        exit(UserPermissionsImpl.CanManageUsersOnTenant(UserSecurityId));
    end;

    /// <summary>
    /// Checks whether a user has a specific permission set assigned.
    /// </summary>
    /// <param name="UserSecurityId">The user's security ID.</param>
    /// <param name="Company">The company for which to check</param>
    /// <param name="RoleId">The ID of the permission set.</param>
    /// <param name="Scope">The scope of the permission set. System or tenant.</param>
    /// <param name="AppId">The app ID of the permission set.</param>
    /// <returns>True if the user has permission sets assigned.</returns>
    procedure HasUserPermissionSetAssigned(UserSecurityId: Guid; Company: Text; RoleId: Code[20]; Scope: Option; AppId: Guid): Boolean
    var
        UserPermissionsImpl: Codeunit "User Permissions Impl.";
    begin
        exit(UserPermissionsImpl.HasUserPermissionSetAssigned(UserSecurityId, Company, RoleId, Scope, AppId));
    end;

    /// <summary>
    /// Checks whether custom permissions are assigned to the user.
    /// </summary>
    /// <param name="UserSecurityId">The security ID of the user to check for.</param>
    /// <returns>True if the user with the given user security ID has custom permissions; false otherwise.</returns>  
    procedure HasUserCustomPermissions(UserSecurityId: Guid): Boolean
    var
        UserPermissionsImpl: Codeunit "User Permissions Impl.";
    begin
        exit(UserPermissionsImpl.HasUserCustomPermissions(UserSecurityId));
    end;

    /// <summary>
    /// Gets the effective permissions for the current user in the current company.
    /// </summary>
    /// <param name="PermissionObjectType">The object type to check for.</param>
    /// <param name="ObjectId">The object ID to check for.</param>
    /// <returns>Returns the effective permissions in a temporary expanded permission record.</returns>
    /// <example>
    ///    local procedure VerifyIndirectDeletePermission(TableId: Integer): Boolean
    ///    var
    ///        TempDummyExpandedPermission: Record "Expanded Permission" temporary;
    ///        UserPermissions: Codeunit "User Permissions";
    ///    begin
    ///        TempDummyExpandedPermission := UserPermissions.GetEffectivePermission(TempDummyExpandedPermission."Object Type"::"Table Data", TableId);
    ///        exit(TempDummyExpandedPermission."Delete Permission" = TempDummyExpandedPermission."Delete Permission"::Indirect)
    ///    end;
    /// </example>
    procedure GetEffectivePermission(PermissionObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,,; ObjectId: Integer): Record "Expanded Permission" temporary
    var
        UserPermissionsImpl: Codeunit "User Permissions Impl.";
    begin
        exit(UserPermissionsImpl.GetEffectivePermission(PermissionObjectType, ObjectId));
    end;
}

