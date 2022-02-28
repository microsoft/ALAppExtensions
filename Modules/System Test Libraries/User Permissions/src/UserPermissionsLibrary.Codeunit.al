// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Library to operate with user permissions.
/// </summary>
codeunit 130017 "User Permissions Library"
{
    Access = Public;

    /// <summary>
    /// Creates a user with the provided user name and assigns them SUPER.
    /// </summary>
    /// <param name="UserName">The user name for the user.</param>
    procedure CreateSuperUser(UserName: Code[50])
    var
        User: Record User;
    begin
        User.SetRange("User Name", UserName);
        if not User.FindFirst() then
            CreateUser(UserName, User);

        AssignPermissionSetToUser(User."User Security ID", 'SUPER');
    end;

    /// <summary>
    /// Assigns a permission set to a user.
    /// </summary>
    /// <param name="UserSecurityId">The user security ID</param>
    /// <param name="PermissionSetId">The ID of the permission set to assign</param>
    procedure AssignPermissionSetToUser(UserSecurityId: Guid; PermissionSetId: Code[20])
    begin
        AssignPermissionSetToUser(UserSecurityId, PermissionSetId, '');
    end;

    /// <summary>
    /// Assigns a permission set to a user.
    /// </summary>
    /// <param name="UserSecurityId">The user security ID</param>
    /// <param name="PermissionSetId">The ID of the permission set to assign</param>
    /// <param name="Company">The company for which to assign the permission set</param>
    procedure AssignPermissionSetToUser(UserSecurityId: Guid; PermissionSetId: Code[20]; Company: Text)
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityId);
        AccessControl.SetRange("Role ID", PermissionSetId);
        if Company <> '' then
            AccessControl.SetRange("Company Name", Company);

        if not AccessControl.IsEmpty() then
            exit;

        AccessControl."User Security ID" := UserSecurityId;
        AccessControl."Role ID" := PermissionSetId;
        AccessControl."Company Name" := CopyStr(Company, 1, MaxStrLen(AccessControl."Company Name"));
        AccessControl.Insert(true);
    end;

    local procedure CreateUser(UserName: Code[50]; var User: Record User)
    begin
        User.Init();

        User."User Security ID" := CreateGuid();
        User."User Name" := UserName;
        User."Windows Security ID" := CopyStr(SID(), 1, MaxStrLen(User."Windows Security ID"));

        User.Insert(true);
    end;
}