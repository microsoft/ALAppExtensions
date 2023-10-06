// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System;
using System.Telemetry;
using System.Azure.Identity;

codeunit 9871 "Security Group Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata User = rimd,
                  tabledata "User Property" = rimd,
                  tabledata "Security Group" = rimd;

    var
        AzureAdGraph: Codeunit "Azure AD Graph";
        EntraGroups: Dictionary of [Text, Text];
        AreAllEntraGroupsFetched: Boolean;
        InvalidWindowsGroupErr: Label 'The group ID %1 does not correspond to a valid Windows group.', Comment = '%1 = Windows group ID';
        InvalidEntraGroupErr: Label 'The group ID %1 does not correspond to a valid Microsoft Entra group.', Comment = '%1 = Microsoft Entra security group ID';
        InvalidGroupNameErr: Label 'The group %1 could not be found.', Comment = '%1 = group name';
        GroupAlreadyExistsErr: Label 'The group %1 already exists.', Comment = '%1 = Microsoft Entra group ID / Windows group name / group code';
        WindowsAccountNotAllowedErr: Label 'The group %1 is not allowed.', Comment = '%1 = Windows group name';
        CouldNotFindGroupErr: Label 'Could not find %1 group.', Comment = '%1 = Active Directory / Microsoft Entra';
        NoPermissionsErr: Label 'You do not have permissions to create security groups. Ask your system administrator to give you Insert, Modify and Delete permissions for the Security Group table.';
        GroupNotFoundTxt: Label 'The group %1 could not be found in %2. The permission sets assigned to it will not have any effect.', Comment = '%1 = group code; %2 = Active Directory / Microsoft Entra';
        GroupsNotFoundTxt: Label 'The groups %1 could not be found in %2. The permission sets assigned to them will not have any effect.', Comment = '%1 = comma separated list of group codes; %2 = Active Directory / Microsoft Entra';
        SecurityGroupsTok: Label 'Security Groups', Locked = true;
        AdTxt: Label 'Active Directory', Locked = true;
        EntraTxt: Label 'Microsoft Entra', Locked = true;
        SecurityGroupAddedLbl: Label 'A security group with ID %1 has been added. Automatically created user with security ID: %2.', Locked = true;
        NotificationIdLbl: Label 'e78ecb57-f560-4788-b9c7-e5a477467d65', Locked = true;

    procedure ValidateGroupId(GroupId: Text)
    begin
        if IsWindowsAuthentication() then
            ValidateWindowsGroup(GroupId)
        else
            ValidateEntraGroup(GroupId);
    end;

    procedure Create(GroupCode: Code[20]; GroupId: Text)
    var
        SecurityGroup: Record "Security Group";
        SecurityGroupUser: Record User;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NavUserAccountHelper: DotNet NavUserAccountHelper;
        Handled: Boolean;
        EntraGroupName: Text[250];
    begin
        // CreateUserFromAAdGroupObjectId will commit the changes to the User table, so we need to
        // make sure there will not be a permission error when inserting a security group record.
        if not SecurityGroup.WritePermission() then
            Error(NoPermissionsErr);

        if SecurityGroup.Get(GroupCode) then
            Error(GroupAlreadyExistsErr, GroupCode);

        if IsWindowsAuthentication() then begin
            ValidateWindowsGroup(GroupId);

            SecurityGroupUser."User Security ID" := CreateGuid();
            SecurityGroupUser."Windows Security ID" := CopyStr(GroupId, 1, MaxStrLen(SecurityGroupUser."Windows Security ID"));
            SecurityGroupUser."License Type" := SecurityGroupUser."License Type"::"Windows Group";
            SecurityGroupUser."User Name" := CopyStr(NavUserAccountHelper.UserName(GroupId), 1, MaxStrLen(SecurityGroupUser."User Name"));
            SecurityGroupUser.Insert();

            SecurityGroup."Group User SID" := SecurityGroupUser."User Security ID";
        end else begin
            ValidateEntraGroup(GroupId);
            TryGetNameById(GroupId, EntraGroupName);

            OnBeforeCreateAadGroupUserInSaaS(SecurityGroup, GroupId, EntraGroupName, Handled);
            if not Handled then
                SecurityGroup."Group User SID" := NavUserAccountHelper.CreateUserFromAAdGroupObjectId(GroupId, EntraGroupName);
        end;

        SecurityGroup.Code := GroupCode;
        SecurityGroup.Insert();

        FeatureTelemetry.LogUptake('0000JGO', SecurityGroupsTok, Enum::"Feature Uptake Status"::"Set up");
        Session.LogSecurityAudit(SecurityGroupsTok, SecurityOperationResult::Success, StrSubstNo(SecurityGroupAddedLbl, GroupId, SecurityGroupUser."User Security ID"), AuditCategory::UserManagement);
    end;

    procedure Delete(GroupCode: Code[20])
    var
        SecurityGroup: Record "Security Group";
        User: Record User;
        AccessControl: Record "Access Control";
    begin
        if SecurityGroup.Get(GroupCode) then begin
            AccessControl.SetRange("User Security ID", SecurityGroup."Group User SID");
            AccessControl.DeleteAll();
            if User.Get(SecurityGroup."Group User SID") then
                User.Delete();
            SecurityGroup.Delete(true);
        end;
    end;

    procedure Copy(SourceGroupCode: Code[20]; DestinationGroupCode: Code[20]; DestinationGroupId: Text)
    begin
        Create(DestinationGroupCode, DestinationGroupId);
        CopyPermissions(SourceGroupCode, DestinationGroupCode);
    end;

    procedure CopyPermissions(SourceGroupCode: Code[20]; DestinationGroupCode: Code[20])
    var
        AccessControlSource: Record "Access Control";
        AccessControlDest: Record "Access Control";
        DestSecurityGroupUserSecId: Guid;
    begin
        DestSecurityGroupUserSecId := GetGroupUserSecurityId(DestinationGroupCode);
        AccessControlSource.SetRange("User Security ID", GetGroupUserSecurityId(SourceGroupCode));
        if AccessControlSource.FindSet() then
            repeat
                if not AccessControlDest.Get(DestSecurityGroupUserSecId, AccessControlSource."Role ID", AccessControlSource."Company Name", AccessControlSource.Scope, AccessControlSource."App ID") then begin
                    AccessControlDest.Copy(AccessControlSource);
                    AccessControlDest."User Security ID" := DestSecurityGroupUserSecId;
                    AccessControlDest.Insert();
                end;
            until AccessControlSource.Next() = 0;
    end;

    procedure AddPermissionSet(GroupCode: Code[20]; RoleId: Code[20]; Company: Text[30]; Scope: Option System,Tenant; AppId: Guid)
    var
        SecurityGroup: Record "Security Group";
        AccessControl: Record "Access Control";
    begin
        SecurityGroup.Get(GroupCode);

        if not AccessControl.Get(SecurityGroup."Group User SID", RoleId, Company, Scope, AppId) then begin
            AccessControl."User Security ID" := SecurityGroup."Group User SID";
            AccessControl."Role ID" := RoleId;
            AccessControl."Company Name" := Company;
            AccessControl.Scope := Scope;
            AccessControl."App ID" := AppId;
            AccessControl.Insert();
        end;
    end;

    procedure RemovePermissionSet(GroupCode: Code[20]; RoleId: Code[20]; Company: Text[30]; Scope: Option System,Tenant; AppId: Guid): Boolean
    var
        SecurityGroup: Record "Security Group";
        AccessControl: Record "Access Control";
    begin
        SecurityGroup.Get(GroupCode);

        if AccessControl.Get(SecurityGroup."Group User SID", RoleId, Company, Scope, AppId) then begin
            AccessControl.Delete();
            exit(true);
        end;

        exit(false);
    end;

    procedure GetGroupUserSecurityId(GroupCode: Code[20]): Guid
    var
        SecurityGroup: Record "Security Group";
    begin
        SecurityGroup.Get(GroupCode);
        exit(SecurityGroup."Group User SID");
    end;

    procedure Export(SecurityGroupCodes: List of [Code[20]]; Destination: OutStream)
    var
        SecurityGroup: Record "Security Group";
        ExportImportSecurityGroups: XMLport "Export/Import Security Groups";
        SecurityGroupFilterTextBuilder: TextBuilder;
        GroupCode: Code[20];
    begin
        foreach GroupCode in SecurityGroupCodes do begin
            SecurityGroupFilterTextBuilder.Append(GroupCode);
            SecurityGroupFilterTextBuilder.Append('|');
        end;
        SecurityGroup.SetFilter(Code, SecurityGroupFilterTextBuilder.ToText().TrimEnd('|'));

        ExportImportSecurityGroups.SetTableView(SecurityGroup);
        ExportImportSecurityGroups.SetDestination(Destination);
        ExportImportSecurityGroups.Export();
    end;

    procedure Import(Source: InStream)
    var
        ExportImportSecurityGroups: XMLport "Export/Import Security Groups";
    begin
        ExportImportSecurityGroups.SetSource(Source);
        ExportImportSecurityGroups.Import();
    end;

    procedure GetAvailableGroups(var SecurityGroupBuffer: Record "Security Group Buffer")
    var
        User: Record User;
        UserProperty: Record "User Property";
        DummySecurityGroup: Record "Security Group";
        LocalSecurityGroupBuffer: Record "Security Group Buffer";
        EntraGroupId: Text;
        NavUserAccountHelper: DotNet NavUserAccountHelper;
        LocalWindowsGroupName: Text;
    begin
        // Prevent non-admin users from seeing the list of all available groups
        if not DummySecurityGroup.WritePermission() then
            Error(NoPermissionsErr);

        LocalSecurityGroupBuffer.Copy(SecurityGroupBuffer, true);
        LocalSecurityGroupBuffer.Reset();
        LocalSecurityGroupBuffer.DeleteAll();

        if IsWindowsAuthentication() then
            foreach LocalWindowsGroupName in NavUserAccountHelper.GetLocalWindowsGroups() do begin
                SecurityGroupBuffer."Group ID" := CopyStr(SID(LocalWindowsGroupName), 1, MaxStrLen(SecurityGroupBuffer."Group ID"));
                User.SetRange("Windows Security ID", SecurityGroupBuffer."Group ID");
                if User.IsEmpty() then
                    if not GetDisallowedWindowsGroupIds().Contains(SecurityGroupBuffer."Group ID") then begin
                        SecurityGroupBuffer.Code := CopyStr(CreateGuid(), 1, MaxStrLen(SecurityGroupBuffer.Code));
                        SecurityGroupBuffer."Group Name" := CopyStr(LocalWindowsGroupName, 1, MaxStrLen(SecurityGroupBuffer."Group Name"));
                        SecurityGroupBuffer.Insert();
                    end;
            end
        else begin
            FetchAllEntraGroups();

            foreach EntraGroupId in EntraGroups.Keys do begin
                UserProperty.SetRange("Authentication Object ID", EntraGroupId);
                if UserProperty.IsEmpty() then begin
                    SecurityGroupBuffer.Code := CopyStr(CreateGuid(), 1, MaxStrLen(SecurityGroupBuffer.Code));
                    SecurityGroupBuffer."Group ID" := CopyStr(EntraGroupId, 1, MaxStrLen(SecurityGroupBuffer."Group ID"));
                    SecurityGroupBuffer."Group Name" := CopyStr(EntraGroups.Get(EntraGroupId), 1, MaxStrLen(SecurityGroupBuffer."Group Name"));
                    SecurityGroupBuffer.Insert();
                end;
            end;
        end;

        if SecurityGroupBuffer.FindFirst() then; // reset to the first record
    end;

    procedure GetGroups(var SecurityGroupBuffer: Record "Security Group Buffer")
    var
        SecurityGroup: Record "Security Group";
        LocalSecurityGroupBuffer: Record "Security Group Buffer";
    begin
        LocalSecurityGroupBuffer.Copy(SecurityGroupBuffer, true);
        LocalSecurityGroupBuffer.Reset();
        LocalSecurityGroupBuffer.DeleteAll();

        if IsWindowsAuthentication() then
            SecurityGroup.SetAutoCalcFields("Windows Group ID")
        else
            SecurityGroup.SetAutoCalcFields("AAD Group ID");

        if SecurityGroup.FindSet() then
            repeat
                SecurityGroupBuffer.Init();
                SecurityGroupBuffer.Code := SecurityGroup.Code;
                SecurityGroupBuffer."Group User SID" := SecurityGroup."Group User SID";
                if IsWindowsAuthentication() then
                    SecurityGroupBuffer."Group ID" := SecurityGroup."Windows Group ID"
                else
                    SecurityGroupBuffer."Group ID" := SecurityGroup."AAD Group ID";
                if GetName(SecurityGroup.Code, SecurityGroupBuffer."Group Name") then
                    SecurityGroupBuffer."Retrieved Successfully" := true;
                SecurityGroupBuffer.Insert();
            until SecurityGroup.Next() = 0;

        if SecurityGroupBuffer.FindFirst() then; // reset to the first record
    end;

    procedure GetMembers(var SecurityGroupMemberBuffer: Record "Security Group Member Buffer"): List of [Code[20]]
    var
        SecurityGroup: Record "Security Group";
        LocalSecurityGroupMemberBuffer: Record "Security Group Member Buffer";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SkippedSecurityGroups: List of [Code[20]];
    begin
        LocalSecurityGroupMemberBuffer.Copy(SecurityGroupMemberBuffer, true);
        LocalSecurityGroupMemberBuffer.Reset();
        LocalSecurityGroupMemberBuffer.DeleteAll();

        if IsWindowsAuthentication() then
            SecurityGroup.SetAutoCalcFields("Windows Group ID")
        else
            SecurityGroup.SetAutoCalcFields("AAD Group ID");

        if not SecurityGroup.FindSet() then
            exit;

        repeat
            if IsWindowsAuthentication() then begin
                if not TryGetWindowsGroupMembers(SecurityGroup.Code, SecurityGroup."Windows Group ID", SecurityGroupMemberBuffer) then
                    SkippedSecurityGroups.Add(SecurityGroup.Code);
            end else
                if not TryGetEntraGroupMembers(SecurityGroup.Code, SecurityGroup."AAD Group ID", SecurityGroupMemberBuffer) then
                    SkippedSecurityGroups.Add(SecurityGroup.Code);
        until SecurityGroup.Next() = 0;

        if SecurityGroupMemberBuffer.FindFirst() then begin // reset to the first record
            // The group has members, which means that the permissions will be applied to member-users
            FeatureTelemetry.LogUptake('0000JGP', SecurityGroupsTok, Enum::"Feature Uptake Status"::Used);
            FeatureTelemetry.LogUsage('0000JGQ', SecurityGroupsTok, 'Security group members retrieved');
        end;

        exit(SkippedSecurityGroups);
    end;

    procedure GetName(GroupCode: Code[20]; var GroupName: Text[250]): Boolean
    begin
        if TryGetName(GroupCode, GroupName) then
            exit(true);
        exit(false);
    end;

    [TryFunction]
    local procedure TryGetName(GroupCode: Code[20]; var GroupName: Text[250])
    begin
        TryGetNameById(GetId(GroupCode), GroupName);
    end;

    [TryFunction]
    procedure TryGetNameById(GroupId: Text; var GroupName: Text[250])
    var
        NavUserAccountHelper: DotNet NavUserAccountHelper;
        GroupNameReturnedValue: Text;
    begin
        if IsWindowsAuthentication() then begin
            GroupNameReturnedValue := NavUserAccountHelper.UserName(GroupId);
            if GroupNameReturnedValue <> GroupId then
                GroupName := CopyStr(GroupNameReturnedValue, 1, MaxStrLen(GroupName))
            else
                Error(CouldNotFindGroupErr, AdTxt);
        end else begin
            if not EntraGroups.ContainsKey(GroupId) then begin
                GroupNameReturnedValue := AzureAdGraph.GetGroupName(GroupId);
                if GroupNameReturnedValue <> '' then
                    EntraGroups.Add(GroupId, GroupNameReturnedValue)
                else
                    Error(CouldNotFindGroupErr, EntraTxt);
            end;

            GroupName := CopyStr(EntraGroups.Get(GroupId), 1, MaxStrLen(GroupName))
        end;
    end;

    procedure GetId(GroupCode: Code[20]): Text[250]
    var
        SecurityGroup: Record "Security Group";
    begin
        if IsWindowsAuthentication() then begin
            SecurityGroup.SetAutoCalcFields("Windows Group ID");
            if SecurityGroup.Get(GroupCode) then
                exit(SecurityGroup."Windows Group ID");
        end else begin
            SecurityGroup.SetAutoCalcFields("AAD Group ID");
            if SecurityGroup.Get(GroupCode) then
                exit(SecurityGroup."AAD Group ID");
        end;
    end;

    procedure GetIdByName(GroupName: Text): Text
    var
        GroupId: Text;
    begin
        if TryGetIdByName(GroupName, GroupId) then
            exit(GroupId)
        else
            Error(InvalidGroupNameErr, GroupName);
    end;

    [TryFunction]
    procedure TryGetIdByName(GroupName: Text; var GroupId: Text)
    begin
        if IsWindowsAuthentication() then
            GroupId := SID(GroupName)
        else begin
            // Microsoft Entra security group names are not unique, return the first one
            GroupId := AzureAdGraph.GetFirstGroupIdWithName(GroupName);
            EntraGroups.Add(GroupId, GroupName);
        end;
    end;

    [TryFunction]
    local procedure TryGetEntraGroupMembers(SecurityGroupCode: Code[20]; EntraGroupId: Text; var SecurityGroupMemberBuffer: Record "Security Group Member Buffer")
    var
        UserProperty: Record "User Property";
        UserIdsPage: Dotnet UserIdsPage;
        UserEntraObjectId: Text;
    begin
        AzureADGraph.GetMemberIdsPageForGroupId(EntraGroupId, 500, UserIdsPage);

        if IsNull(UserIdsPage) then
            exit;

        repeat
            foreach UserEntraObjectId in UserIdsPage.CurrentPage() do begin
                UserProperty.SetRange("Authentication Object ID", UserEntraObjectId);
                if UserProperty.FindFirst() then begin
                    SecurityGroupMemberBuffer."Security Group Code" := SecurityGroupCode;
                    SecurityGroupMemberBuffer."User Security ID" := UserProperty."User Security ID";
                    GetName(SecurityGroupCode, SecurityGroupMemberBuffer."Security Group Name");
                    SecurityGroupMemberBuffer.Insert();
                end;
            end;
        until (not UserIdsPage.GetNextMemberIdsPageForGroupId(EntraGroupId));
    end;

    local procedure ValidateWindowsGroup(WindowsGroupId: Text)
    var
        OtherUser: Record User;
        NavUserAccountHelper: DotNet NavUserAccountHelper;
        UserName: Text;
    begin
        if WindowsGroupId = '' then
            Error(InvalidWindowsGroupErr, WindowsGroupId);

        if StrLen(WindowsGroupId) > MaxStrLen(OtherUser."Windows Security ID") then
            Error(InvalidWindowsGroupErr, WindowsGroupId);

        UserName := NavUserAccountHelper.UserName(WindowsGroupId);
        if UserName = '' then
            Error(InvalidWindowsGroupErr, WindowsGroupId);

        if GetDisallowedWindowsGroupIds().Contains(WindowsGroupId) then
            Error(WindowsAccountNotAllowedErr, UserName);

        OtherUser.SetFilter("Windows Security ID", WindowsGroupId);
        if OtherUser.FindFirst() then
            Error(GroupAlreadyExistsErr, OtherUser."User Name");
    end;

    local procedure GetDisallowedWindowsGroupIds(): List of [Text]
    var
        DisallowedGroups: List of [Text];
    begin
        DisallowedGroups.Add('S-1-1-0'); // "World" - A group that includes all users.
        DisallowedGroups.Add('S-1-5-7'); // "Anonymous Logon"
        DisallowedGroups.Add('S-1-5-32-544'); // Administrators
        exit(DisallowedGroups);
    end;

    local procedure ValidateEntraGroup(EntraGroupObjectId: Text)
    var
        OtherUserProperty: Record "User Property";
        DummyGroupName: Text[250];
    begin
        if not TryGetNameById(EntraGroupObjectId, DummyGroupName) then
            Error(InvalidEntraGroupErr, EntraGroupObjectId);

        OtherUserProperty.SetRange("Authentication Object ID", EntraGroupObjectId);
        if not OtherUserProperty.IsEmpty() then
            Error(GroupAlreadyExistsErr, EntraGroupObjectId);
    end;

    local procedure FetchAllEntraGroups()
    begin
        // Fetching the groups can take a long time, so caching the results in a dictionary
        if AreAllEntraGroupsFetched then
            exit;

        EntraGroups := AzureADGraph.GetGroups();
        AreAllEntraGroupsFetched := true;
    end;

    procedure IsWindowsAuthentication(): Boolean
    var
        NavUserAccountHelper: DotNet NavUserAccountHelper;
        IsWindowsAuth: Boolean;
        Handled: Boolean;
    begin
        OnIsWindowsAuthentication(IsWindowsAuth, Handled);
        if not Handled then
            IsWindowsAuth := NavUserAccountHelper.IsWindowsAuthentication();
        exit(IsWindowsAuth);
    end;

    [TryFunction]
    local procedure TryGetWindowsGroupMembers(SecurityGroupCode: Code[20]; WindowsGroupId: Text; var SecurityGroupMemberBuffer: Record "Security Group Member Buffer")
    var
        User: Record User;
        NavUserAccountHelper: DotNet NavUserAccountHelper;
        UserSID: Text;
        GroupName: Text;
    begin
        GroupName := NavUserAccountHelper.UserName(WindowsGroupId);
        foreach UserSID in NavUserAccountHelper.GetWindowsGroupMembersByName(GroupName) do begin
            User.SetRange("Windows Security ID", UserSID);
            if User.FindFirst() then begin
                SecurityGroupMemberBuffer."Security Group Code" := SecurityGroupCode;
                SecurityGroupMemberBuffer."User Security ID" := User."User Security ID";
                SecurityGroupMemberBuffer."Security Group Name" := CopyStr(GroupName, 1, MaxStrLen(SecurityGroupMemberBuffer."Security Group Name"));
                SecurityGroupMemberBuffer.Insert();
            end;
        end;
    end;

    procedure SendNotificationForDeletedGroups(var SecurityGroupBuffer: Record "Security Group Buffer")
    var
        LocalSecurityGroupBuffer: Record "Security Group Buffer";
        MissingGroupsNotification: Notification;
        GroupCodesTextBuilder: TextBuilder;
        MissingGroupCodes: Text;
    begin
        LocalSecurityGroupBuffer.Copy(SecurityGroupBuffer, true);
        LocalSecurityGroupBuffer.SetRange("Retrieved Successfully", false);

        if not LocalSecurityGroupBuffer.FindSet() then
            exit;

        repeat
            GroupCodesTextBuilder.Append(LocalSecurityGroupBuffer.Code);
            GroupCodesTextBuilder.Append(', ');
        until LocalSecurityGroupBuffer.Next() = 0;
        MissingGroupCodes := GroupCodesTextBuilder.ToText().TrimEnd(', ');

        if LocalSecurityGroupBuffer.Count() = 1 then begin
            if IsWindowsAuthentication() then
                MissingGroupsNotification.Message(StrSubstNo(GroupNotFoundTxt, MissingGroupCodes, AdTxt))
            else
                MissingGroupsNotification.Message(StrSubstNo(GroupNotFoundTxt, MissingGroupCodes, EntraTxt));
        end else
            if IsWindowsAuthentication() then
                MissingGroupsNotification.Message(StrSubstNo(GroupsNotFoundTxt, MissingGroupCodes, AdTxt))
            else
                MissingGroupsNotification.Message(StrSubstNo(GroupsNotFoundTxt, MissingGroupCodes, EntraTxt));

        MissingGroupsNotification.Id := NotificationIdLbl;
        MissingGroupsNotification.Scope := NotificationScope::LocalScope;
        MissingGroupsNotification.Send();
    end;

    procedure GetDesirableCode(GroupName: Text): Code[20]
    var
        GroupDomainAndNameList: List of [Text];
    begin
        if IsWindowsAuthentication() then begin
            GroupDomainAndNameList := GroupName.Split('\');
            exit(CopyStr(GroupDomainAndNameList.Get(GroupDomainAndNameList.Count()), 1, 20));
        end else
            exit(CopyStr(GroupName, 1, 20));
    end;

    [InternalEvent(false)]
    local procedure OnIsWindowsAuthentication(var IsWindowsAuthentication: Boolean; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    local procedure OnBeforeCreateAadGroupUserInSaaS(var SecurityGroup: Record "Security Group"; GroupId: Text; GroupName: Text; var Handled: Boolean)
    begin
    end;
}