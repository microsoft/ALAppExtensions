// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9014 "Azure AD Graph Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EnvironmentInformation: Codeunit "Environment Information";
        [NonDebuggable]
        GraphQuery: DotNet GraphQuery;
        IsGraphInitialized: Boolean;

    [NonDebuggable]
    procedure GetUser(UserPrincipalName: Text; var UserInfo: DotNet UserInfo)
    begin
        if CanQueryGraph() then
            UserInfo := GraphQuery.GetUser(UserPrincipalName);
    end;

    [NonDebuggable]
    procedure GetCurrentUser(var UserInfo: DotNet UserInfo)
    begin
        if CanQueryGraph() then
            UserInfo := GraphQuery.GetCurrentUser();
    end;

    [NonDebuggable]
    procedure GetUserByAuthorizationEmail(AuthorizationEmail: Text; var UserInfo: DotNet UserInfo)
    begin
        if CanQueryGraph() then
            UserInfo := GraphQuery.GetUserByAuthorizationEmail(AuthorizationEmail);
    end;

    [NonDebuggable]
    procedure GetUserByObjectId(ObjectId: Text; var UserInfo: DotNet UserInfo)
    begin
        if CanQueryGraph() then
            UserInfo := GraphQuery.GetUserByObjectId(ObjectId);
    end;

    [NonDebuggable]
    procedure TryGetUserByObjectId(ObjectId: Text; var UserInfo: DotNet UserInfo): Boolean
    begin
        if CanQueryGraph() then
            exit(GraphQuery.TryGetUserByObjectId(ObjectId, UserInfo));
    end;

    [NonDebuggable]
    procedure GetUserAssignedPlans(UserInfo: DotNet UserInfo; var UserAssignedPlans: DotNet GenericList1)
    begin
        if IsNull(UserInfo) then
            exit;

        if CanQueryGraph() then
            UserAssignedPlans := GraphQuery.GetUserAssignedPlans(UserInfo);
    end;

    [NonDebuggable]
    procedure GetUserRoles(UserInfo: DotNet UserInfo; var UserRoles: DotNet GenericIEnumerable1)
    begin
        if IsNull(UserInfo) then
            exit;

        if CanQueryGraph() then
            UserRoles := UserInfo.Roles();
    end;

    [NonDebuggable]
    procedure GetDirectorySubscribedSkus(var DirectorySubscribedSkus: DotNet GenericIEnumerable1)
    begin
        if CanQueryGraph() then
            DirectorySubscribedSkus := GraphQuery.GetDirectorySubscribedSkus();
    end;

    [NonDebuggable]
    procedure GetDirectoryRoles(var DirectoryRoles: DotNet GenericIEnumerable1)
    begin
        if CanQueryGraph() then
            DirectoryRoles := GraphQuery.GetDirectoryRoles();
    end;

    [NonDebuggable]
    procedure GetTenantDetail(var TenantInfo: DotNet TenantInfo)
    begin
        if CanQueryGraph() then
            TenantInfo := GraphQuery.GetTenantDetail();
    end;

    [NonDebuggable]
    procedure IsM365CollaborationEnabled(): Boolean
    begin
        if CanQueryGraph() then
            exit(GraphQuery.IsM365CollaborationEnabled());
        exit(false);
    end;

    [NonDebuggable]
    procedure GetEnvironmentSecurityGroupId(): Text
    begin
        if CanQueryGraph() then
            exit(GraphQuery.GetEnvironmentDirectoryGroup());
    end;

    [NonDebuggable]
    procedure GetUsersPage(NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
    begin
        if CanQueryGraph() then
            UserInfoPage := GraphQuery.GetUsersPage(NumberOfUsers);
    end;

    [NonDebuggable]
    procedure GetLicensedUsersPage(AssignedPlans: DotNet StringArray; NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
    begin
        if CanQueryGraph() then
            UserInfoPage := GraphQuery.GetLicensedUsersPage(AssignedPlans, NumberOfUsers);
    end;

    [NonDebuggable]
    procedure GetGroupMembers(GroupDisplayName: Text; var GroupMembers: DotNet IEnumerable)
    begin
        // AzureAdGraphQuery will throw an exception if the group does not exist.
        // Ignoring this exception, and letting the caller to only check for IsNull(GroupMembers)
        if TryGetGroupMembers(GroupDisplayName, GroupMembers) then;
    end;

    [NonDebuggable]
    procedure GetMembersPageForGroupId(GroupId: Text; NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
    begin
        // AzureAdGraphQuery will throw an exception if the group does not exist.
        // Ignoring this exception, and letting the caller to only check for IsNull(GroupMembers)
        if TryGetMembersPageForGroupId(GroupId, NumberOfUsers, UserInfoPage) then;
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure TryGetGroupMembers(GroupDisplayName: Text; var GroupMembers: DotNet IEnumerable)
    begin
        if CanQueryGraph() then
            GroupMembers := GraphQuery.GetGroupMembers(GroupDisplayName);
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure TryGetMembersPageForGroupId(GroupId: Text; NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
    begin
        if CanQueryGraph() then
            UserInfoPage := GraphQuery.GetMembersPageForGroupId(GroupId, NumberOfUsers);
    end;

    [NonDebuggable]
    procedure IsGroupMember(GroupDisplayName: Text; GraphUserInfo: DotNet UserInfo): Boolean
    var
        GroupInfo: DotNet GroupInfo;
    begin
        if IsNull(GraphUserInfo) then
            exit(false);

        if IsNull(GraphUserInfo.Groups()) then
            exit(false);

        foreach GroupInfo in GraphUserInfo.Groups() do
            if not IsNull(GroupInfo.DisplayName()) then
                if GroupInfo.DisplayName().ToUpper() = UpperCase(GroupDisplayName) then
                    exit(true);
        exit(false);
    end;

    [NonDebuggable]
    procedure IsMemberOfGroupWithId(GroupId: Text; GraphUserInfo: DotNet UserInfo): Boolean
    begin
        if IsNull(GraphUserInfo) then
            exit(false);

        if CanQueryGraph() then
            exit(GraphQuery.IsGroupMember(GraphUserInfo.ObjectId, GroupId));
    end;

    [NonDebuggable]
    procedure GetGroups(): Dictionary of [Text, Text];
    var
        GroupInfoPage: DotNet GroupInfoPage;
        GroupInfo: DotNet GroupInfo;
        Groups: Dictionary of [Text, Text];
        NumberOfGroupsPerPage: Integer;
    begin
        if not CanQueryGraph() then
            exit;

        NumberOfGroupsPerPage := 50;
        GroupInfoPage := GraphQuery.GetGroupPage(NumberOfGroupsPerPage);

        if IsNull(GroupInfoPage) then
            exit;

        repeat
            foreach GroupInfo in GroupInfoPage.CurrentPage() do
                Groups.Add(GroupInfo.ObjectId, GroupInfo.DisplayName);
        until (not GroupInfoPage.GetNextPage());

        exit(Groups);
    end;

    [NonDebuggable]
    [TryFunction]
    procedure IsGraphUserAccountEnabled(UserPrincipalName: Text; var IsEnabled: Boolean)
    var
        UserInfo: DotNet UserInfo;
    begin
        GetUser(UserPrincipalName, UserInfo);
        IsEnabled := UserInfo.AccountEnabled();
    end;

    [NonDebuggable]
    local procedure CanQueryGraph(): Boolean
    begin
        if not IsGraphInitialized then
            Initialize();

        exit(IsGraphInitialized);
    end;

    [NonDebuggable]
    local procedure Initialize(): Boolean
    var
        Handled: Boolean;
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit(false);

        if IsGraphInitialized then
            exit(true);

        OnInitialize(GraphQuery, Handled);
        if not Handled then
            GraphQuery := GraphQuery.GraphQuery();

        IsGraphInitialized := not IsNull(GraphQuery);
        exit(IsGraphInitialized);
    end;

    [InternalEvent(false)]
    [NonDebuggable]
    local procedure OnInitialize(var GraphQuery: DotNet GraphQuery; var Handled: Boolean)
    begin
    end;
}

