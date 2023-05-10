// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Codeunit that provides functions for permission set relations, such as including and exlcuding permission sets.
/// </summary>
codeunit 9855 "Permission Set Relation"
{
    Access = Public;

    /// <summary>
    /// Adds a new permission set relation.
    /// </summary>
    /// <param name="AppId">The app ID of the permission set.</param>
    /// <param name="RoleId">The role ID of the permission set.</param>
    /// <param name="Scope">The scope of the permission set.</param>
    /// <param name="RelatedAppId">The app ID of the related permission set.</param>
    /// <param name="RelatedRoleId">The role ID of the related permission set.</param>
    /// <param name="RelatedScope">The scope of the related permission set.</param>
    /// <param name="PermissionType">The type of the new permission set relation.</param>
    /// <returns>true if creating the permission set relation was successful</returns>
    procedure AddNewPermissionSetRelation(AppId: Guid; RoleId: Code[30]; Scope: Option System,Tenant; RelatedAppId: Guid; RelatedRoleId: Code[30]; RelatedScope: Option System,Tenant; PermissionType: Option Include,Exclude) Success: Boolean
    var
        PermissionSetRelationImpl: Codeunit "Permission Set Relation Impl.";
    begin
        exit(PermissionSetRelationImpl.AddNewPermissionSetRelation(AppId, RoleId, Scope, RelatedAppId, RelatedRoleId, RelatedScope, PermissionType));
    end;

    /// <summary>
    /// Opens the permission set page for the specified role ID.
    /// </summary>
    /// <param name="Name">The name of the permission set to open.</param> 
    /// <param name="RoleId">The role ID of the permission set to open.</param>
    /// <param name="AppId">The app ID of the permission set to open.</param>
    /// <param name="Scope">The scope of the permission set to open.</param>
    procedure OpenPermissionSetPage(Name: Text; RoleId: Code[30]; AppId: Guid; Scope: Option System,Tenant)
    var
        PermissionSetRelationImpl: Codeunit "Permission Set Relation Impl.";
    begin
        PermissionSetRelationImpl.OpenPermissionSetPage(Name, RoleId, AppId, Scope);
    end;

    /// <summary>
    /// Verify that the user can edit permission sets, with the specified app ID. 
    /// Throws an error if not.
    /// </summary>
    /// <error>When the app ID is not null</error>
    /// <error>When the user doesn''t have neither SUPER, nor SECURITY</error>///  
    /// <param name="AppId">The app ID of the permission set to verify.</param>
    procedure VerifyUserCanEditPermissionSet(AppId: Text)
    var
        PermissionSetRelationImpl: Codeunit "Permission Set Relation Impl.";
    begin
        PermissionSetRelationImpl.VerifyUserCanEditPermissionSet(AppId);
    end;

    /// <summary>
    /// CopyPermissionSet will copy the source permission set using the specified copy type. 
    /// </summary>
    /// <param name="NewRoleId">The role ID of the new permission set that permissions are copied to.</param>
    /// <param name="NewName">The name of the new permission set that permissions are copied to.</param> 
    /// <param name="SourceRoleId">The role ID of the source permission set that permissions are copied from.</param>
    /// <param name="SourceAppId">The app ID of the source permission set that permissions are copied from.</param>
    /// <param name="SourceScope">The scope of the source permission set that permissions are copied from.</param>
    /// <param name="CopyType">The type of copy operation to use.
    /// If the value is set to reference it will copy by creating a new permission set that includes the source set.
    /// If the value is set to flat it will copy by flattening all the permissions in the source set and adding them to the new set.
    /// If the value is set to clone it will copy by adding the same permissions and including the same permission sets as the source set.
    /// </param>
    [Scope('OnPrem')]
    procedure CopyPermissionSet(NewRoleId: Code[30]; NewName: Text; SourceRoleId: Code[30]; SourceAppId: Guid; SourceScope: Option System,Tenant; CopyType: Enum "Permission Set Copy Type")
    var
        PermissionSetCopyImpl: Codeunit "Permission Set Copy Impl.";
    begin
        PermissionSetCopyImpl.CopyPermissionSet(NewRoleId, NewName, SourceRoleId, SourceAppId, SourceScope, CopyType);
    end;

    /// <summary>
    /// Opens the permission set page in lookup mode and assigns the selected record to specified Permission Set record.
    /// </summary>
    /// <param name="AllowMultiselect">Allow for selecting multiple Permission Sets.</param>
    /// <param name="AggregatePermissionSet">The target Permission Set.</param>
    /// <returns>true if lookup was successful</returns>
    procedure LookupPermissionSet(AllowMultiselect: Boolean; var AggregatePermissionSet: Record "Aggregate Permission Set"): Boolean
    var
        PermissionSetRelationImpl: Codeunit "Permission Set Relation Impl.";
    begin
        exit(PermissionSetRelationImpl.LookupPermissionSet(AllowMultiselect, AggregatePermissionSet));
    end;

    /// <summary>
    /// Event that is raised to show security filter for a tenant permission.
    /// </summary>
    /// <param name="TenantPermission">The tenant permission to show security filter for.</param>
    /// <param name="OutputSecurityFilter">The output security filter.</param>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    internal procedure OnShowSecurityFilterForTenantPermission(var TenantPermission: Record "Tenant Permission"; var OutputSecurityFilter: Text)
    begin
    end;
}