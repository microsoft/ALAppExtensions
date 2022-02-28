// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// </summary>
codeunit 153 "User Permissions Impl."
{
    Access = Internal;
    Permissions = TableData "Access Control" = rimd,
                  TableData User = r;

    var
        SUPERTok: Label 'SUPER', Locked = true;
        SUPERPermissionErr: Label 'There should be at least one enabled ''SUPER'' user.';
        SECURITYPermissionSetTxt: Label 'SECURITY', Locked = true;

    procedure IsSuper(UserSecurityId: Guid): Boolean
    var
        AccessControl: Record "Access Control";
        User: Record User;
    begin
        if User.IsEmpty() then
            exit(true);

        AccessControl.SetRange("User Security ID", UserSecurityId);
        SetSuperFilters(AccessControl);

        exit(not AccessControl.IsEmpty());
    end;

    procedure RemoveSuperPermissions(UserSecurityId: Guid)
    var
        AccessControl: Record "Access Control";
    begin
        if not IsAnyoneElseSuper(UserSecurityId) then
            exit;

        SetSuperFilters(AccessControl);
        AccessControl.SetRange("User Security ID", UserSecurityId);
        AccessControl.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Access Control", 'OnBeforeRenameEvent', '', false, false)]
    local procedure CheckSuperPermissionsBeforeRenameAccessControl(var Rec: Record "Access Control"; var xRec: Record "Access Control"; RunTrigger: Boolean)
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if Rec.IsTemporary() then
            exit;

        if not EnvironmentInfo.IsSaaS() then
            exit;

        if not IsSuper(xRec) then
            exit;

        if IsAnyoneElseSuper(Rec."User Security ID") then
            exit;

        Error(SUPERPermissionErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Access Control", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckSuperPermissionsBeforeDeleteAccessControl(var Rec: Record "Access Control"; RunTrigger: Boolean)
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if Rec.IsTemporary() then
            exit;

        if not EnvironmentInfo.IsSaaS() then
            exit;

        if not RunTrigger then
            exit;

        if not IsSuper(Rec) then
            exit;

        if IsAnyoneElseSuper(Rec."User Security ID") then
            exit;

        Error(SUPERPermissionErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::User, 'OnBeforeModifyEvent', '', true, true)]
    local procedure CheckSuperPermissionsBeforeModifyUser(var Rec: Record User; var xRec: Record User; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        if not IsSuper(Rec."User Security ID") then
            exit;

        if IsAnyoneElseSuper(Rec."User Security ID") then
            exit;

        // Workaround since the xRec parameter is equal to Rec, when called from code.
        xRec.Get(Rec."User Security ID");

        // if the change is not disabling the only SUPER user
        if (Rec.State <> Rec.State::Disabled) or (xRec.State <> xRec.State::Enabled) then
            exit;

        Error(SUPERPermissionErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::User, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure CheckSuperPermissionsBeforeDeleteUser(var Rec: Record User; RunTrigger: Boolean)
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if not EnvironmentInfo.IsSaaS() then
            exit;

        if Rec.IsTemporary() then
            exit;

        if not IsSuper(Rec."User Security ID") then
            exit;

        if IsAnyoneElseSuper(Rec."User Security ID") then
            exit;

        Error(SUPERPermissionErr);
    end;

    local procedure SetSuperFilters(var Rec: Record "Access Control")
    begin
        Rec.SetRange("Role ID", SUPERTok);
        Rec.SetFilter("Company Name", '='''''); // Company Name value is an empty string
    end;

    local procedure IsSuper(var Rec: Record "Access Control"): Boolean
    begin
        exit((Rec."Role ID" = SUPERTok) and (Rec."Company Name" = ''));
    end;

    local procedure IsAnyoneElseSuper(UserSecurityId: Guid): Boolean
    var
        AccessControl: Record "Access Control";
        User: Record User;
        isUserEnabled: Boolean;
    begin
        if User.IsEmpty() then
            exit(true);

        AccessControl.LockTable();
        AccessControl.SetFilter("User Security ID", '<>%1', UserSecurityId);
        SetSuperFilters(AccessControl);

        if AccessControl.IsEmpty() then // no other user is SUPER
            exit(false);

        if AccessControl.FindSet() then
            repeat
                if User.Get(AccessControl."User Security ID") then begin
                    isUserEnabled := (User.State = User.State::Enabled);
                    if isUserEnabled and (not IsSyncDeamon(User)) then
                        exit(true);
                end;
            until AccessControl.Next() = 0;

        exit(false);
    end;

    local procedure IsSyncDeamon(User: Record User): Boolean
    begin
        // Sync Deamon is the only user with license "External User"
        exit(User."License Type" = User."License Type"::"External User");
    end;

    procedure CanManageUsersOnTenant(UserSID: Guid) Result: Boolean
    var
        AccessControl: Record "Access Control";
        User: Record User;
    begin
        if User.IsEmpty() then
            exit(true);

        OnCanManageUsersOnTenant(UserSID, Result);
        if Result then
            exit;

        if IsSuper(UserSID) then
            exit(true);

        AccessControl.SetRange("Role ID", SECURITYPermissionSetTxt);
        AccessControl.SetFilter("Company Name", '%1|%2', '', CompanyName);
        AccessControl.SetRange("User Security ID", UserSID);
        exit(not AccessControl.IsEmpty());
    end;

    procedure HasUserCustomPermissions(UserSecId: Guid): Boolean
    var
        AccessControl: Record "Access Control";
        BlankGuid: Guid;
    begin
        // Check if the user is assigned any custom permission sets
        AccessControl.SetRange("User Security ID", UserSecId);
        AccessControl.SetRange(Scope, AccessControl.Scope::Tenant);
        AccessControl.SetRange("App ID", BlankGuid);
        if not AccessControl.IsEmpty() then
            exit(true);
    end;

    procedure HasUserPermissionSetAssigned(UserSecurityId: Guid; Company: Text; RoleId: Code[20]; ItemScope: Option; AppId: Guid): Boolean
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityId);
        AccessControl.SetRange("Role ID", RoleID);
        AccessControl.SetFilter("Company Name", '%1|%2', '', Company);
        AccessControl.SetRange(Scope, ItemScope);
        AccessControl.SetRange("App ID", AppId);

        exit(not AccessControl.IsEmpty());
    end;

    /// <summary>
    /// An event that indicates that subscribers should set the result that should be returned when the CanManageUsersOnTenant is called.
    /// </summary>
    /// <remarks>
    /// Subscribe to this event from tests if you need to verify a different flow.
    /// This feature is for testing and is subject to a different SLA than production features.
    /// Do not use this event in a production environment. This should be subscribed to only in tests.
    /// </remarks>
    [InternalEvent(false)]
    local procedure OnCanManageUsersOnTenant(UserSID: Guid; var Result: Boolean)
    begin
    end;
}

