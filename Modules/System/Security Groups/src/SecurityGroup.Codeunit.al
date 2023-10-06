// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// Exposes functionality for working with security groups.
/// Security groups correspond to either Windows groups or Microsoft Entra security groups depending on the authentication type.
/// </summary>
codeunit 9031 "Security Group"
{
    Access = Public;

    var
        SecurityGroupImpl: Codeunit "Security Group Impl.";

    /// <summary>
    /// Creates a new security group.
    /// </summary>
    /// <param name="GroupCode">The code of the newly created group.</param>
    /// <param name="GroupId">The SID of a Windows group or object ID of the Microsoft Entra security group.</param>
    procedure Create(GroupCode: Code[20]; GroupId: Text)
    begin
        SecurityGroupImpl.Create(GroupCode, GroupId);
    end;

    /// <summary>
    /// Deletes a security group.
    /// </summary>
    /// <param name="GroupCode">The code of the group to delete.</param>
    procedure Delete(GroupCode: Code[20])
    begin
        SecurityGroupImpl.Delete(GroupCode);
    end;

    /// <summary>
    /// Copies a security group.
    /// </summary>
    /// <param name="SourceGroupCode">The code of the security group to copy.</param>
    /// <param name="DestinationGroupCode">The code of the copied security group.</param>
    /// <param name="DestinationGroupId">The ID of the copied security group.</param>
    procedure Copy(SourceGroupCode: Code[20]; DestinationGroupCode: Code[20]; DestinationGroupId: Text)
    begin
        SecurityGroupImpl.Copy(SourceGroupCode, DestinationGroupCode, DestinationGroupId);
    end;

    /// <summary>
    /// Copies permission sets from the source security group to the destination security group.
    /// </summary>
    /// <param name="SourceGroupCode">The code of the security group to fetch the permissions from.</param>
    /// <param name="DestinationGroupCode">The code of the security group to add the the permissions to.</param>
    procedure CopyPermissions(SourceGroupCode: Code[20]; DestinationGroupCode: Code[20])
    begin
        SecurityGroupImpl.CopyPermissions(SourceGroupCode, DestinationGroupCode);
    end;

    /// <summary>
    /// Adds a permission set to a security group. 
    /// </summary>
    /// <param name="GroupCode">The code of the security group to add a permission set to.</param>
    /// <param name="RoleId">The ID of the role (permission set).</param>
    /// <param name="Company">The company for which to add the permission set.</param>
    /// <param name="Scope">The scope of the permission set.</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    procedure AddPermissionSet(GroupCode: Code[20]; RoleId: Code[20]; Company: Text[30]; Scope: Option System,Tenant; AppId: Guid)
    begin
        SecurityGroupImpl.AddPermissionSet(GroupCode, RoleId, Company, Scope, AppId);
    end;

    /// <summary>
    /// Removes a permission set from a security group.
    /// </summary>
    /// <param name="GroupCode">The code of the security group to remove a permission set from.</param>
    /// <param name="RoleId">The ID of the role (permission set).</param>
    /// <param name="Company">The company for which to remove the permission set.</param>
    /// <param name="Scope">The scope of the permission set.</param>
    /// <param name="AppId">The ID of the app from which the permission set originates.</param>
    /// <returns>True, if the permission set was removed, false otherwise.</returns>
    procedure RemovePermissionSet(GroupCode: Code[20]; RoleId: Code[20]; Company: Text[30]; Scope: Option System,Tenant; AppId: Guid): Boolean
    begin
        exit(SecurityGroupImpl.RemovePermissionSet(GroupCode, RoleId, Company, Scope, AppId));
    end;

    /// <summary>
    /// Gets all the defined security groups.
    /// </summary>
    /// <param name="SecurityGroupBuffer">The resulting list of security groups.</param>
    procedure GetGroups(var SecurityGroupBuffer: Record "Security Group Buffer")
    begin
        SecurityGroupImpl.GetGroups(SecurityGroupBuffer);
    end;

    /// <summary>
    /// Gets all the security group memberships.
    /// </summary>
    /// <param name="SecurityGroupMemberBuffer">The resulting list of users and security groups they are a part of.</param>
    /// <returns>The list of security groups that could not be retrieved successfully from Graph / Windows Active Directory.</returns>
    procedure GetMembers(var SecurityGroupMemberBuffer: Record "Security Group Member Buffer"): List of [Code[20]]
    begin
        exit(SecurityGroupImpl.GetMembers(SecurityGroupMemberBuffer));
    end;

    /// <summary>
    /// Validates the group ID that can be used for a security group.
    /// </summary>
    /// <param name="GroupId">The SID of a Windows group or object ID of the Microsoft Entra security group.</param>
    procedure ValidateGroupId(GroupId: Text)
    begin
        SecurityGroupImpl.ValidateGroupId(GroupId);
    end;

    /// <summary>
    /// Gets the user security ID of a special user record that corresponds to a Microsoft Entra security group or Windows group.
    /// </summary>
    /// <param name="GroupCode">The code of the security group for which to get the group user security ID.</param>
    /// <returns>The user security ID of a special user record that corresponds to a Microsoft Entra security group or Windows group.</returns>
    procedure GetGroupUserSecurityId(GroupCode: Code[20]): Guid
    begin
        exit(SecurityGroupImpl.GetGroupUserSecurityId(GroupCode));
    end;

    /// <summary>
    /// Gets the name of the security group.
    /// </summary>
    /// <param name="GroupCode">The code of the security group.</param>
    /// <param name="GroupName">The name of the security group.</param>
    /// <returns>True, if the operation succeeds, false otherwise.</returns>
    procedure GetName(GroupCode: Code[20]; var GroupName: Text[250]): Boolean
    begin
        exit(SecurityGroupImpl.GetName(GroupCode, GroupName));
    end;

    /// <summary>
    /// Gets the SID of a Windows group or an object ID of a Microsoft Entra security group by group code.
    /// </summary>
    /// <param name="GroupCode">The code of the security group.</param>
    /// <returns>The ID of the security group.</returns>
    procedure GetId(GroupCode: Code[20]): Text[250]
    begin
        exit(SecurityGroupImpl.GetId(GroupCode));
    end;

    /// <summary>
    /// Gets the SID of a Windows group or an object ID of a Microsoft Entra security group by group name.
    /// </summary>
    /// <param name="GroupName">The name of a Windows group or Microsoft Entra security group.</param>
    /// <returns>The ID of the security group.</returns>
    internal procedure GetIdByName(GroupName: Text): Text
    begin
        exit(SecurityGroupImpl.GetIdByName(GroupName));
    end;

    /// <summary>
    /// Shows the notification listing groups deleted Windows / Microsoft Entra groups.
    /// </summary>
    /// <param name="SecurityGroupBuffer">The table containing all security group records.</param>
    internal procedure SendNotificationForDeletedGroups(var SecurityGroupBuffer: Record "Security Group Buffer")
    begin
        SecurityGroupImpl.SendNotificationForDeletedGroups(SecurityGroupBuffer)
    end;

    /// <summary>
    /// Checks whether the current authentication type is Windows, meaning that Windows groups will be used for defining security groups.
    /// </summary>
    /// <returns>True, if the current authentication type is Windows, false otherwise.</returns>
    procedure IsWindowsAuthentication(): Boolean
    begin
        exit(SecurityGroupImpl.IsWindowsAuthentication());
    end;

    /// <summary>
    /// Exports the provided list of security groups.
    /// </summary>
    /// <param name="SecurityGroupCodes">The codes of security groups to export.</param>
    /// <param name="Destination">The OutStream that the resulting XML content will be written to.</param>
    procedure Export(SecurityGroupCodes: List of [Code[20]]; Destination: OutStream)
    begin
        SecurityGroupImpl.Export(SecurityGroupCodes, Destination);
    end;

    /// <summary>
    /// Imports a list of security groups.
    /// </summary>
    /// <param name="Source">The InStream containing the XML content to import.</param>
    procedure Import(Source: InStream)
    begin
        SecurityGroupImpl.Import(Source);
    end;
}