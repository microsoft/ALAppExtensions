// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9014 "Azure AD Graph Impl."
{
    Access = Internal;

    var
        EnvironmentInformation: Codeunit "Environment Information";
        [NonDebuggable]
        GraphQuery: DotNet GraphQuery;
        IsTestInProgress: Boolean;
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
    procedure GetUsersPage(NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
    begin
        if CanQueryGraph() then
            UserInfoPage := GraphQuery.GetUsersPage(NumberOfUsers);
    end;

    [NonDebuggable]
    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        IsTestInProgress := TestInProgress;
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
        AzureADGraph: codeunit "Azure AD Graph";
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit(false);

        if IsGraphInitialized then
            exit(true);

        if IsTestInProgress then
            AzureADGraph.OnInitialize(GraphQuery)
        else
            GraphQuery := GraphQuery.GraphQuery();

        IsGraphInitialized := not IsNull(GraphQuery);
        exit(IsGraphInitialized);
    end;
}

