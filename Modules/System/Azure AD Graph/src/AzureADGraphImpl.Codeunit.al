// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9014 "Azure AD Graph Impl."
{
    Access = Internal;

    var
        EnvironmentInfo: Codeunit "Environment Information";
        GraphQuery: DotNet GraphQuery;
        IsTestInProgress: Boolean;
        IsGraphInitialized: Boolean;

    procedure GetUser(UserPrincipalName: Text; var UserInfo: DotNet UserInfo)
    begin
        if CanQueryGraph() then
            UserInfo := GraphQuery.GetUser(UserPrincipalName);
    end;

    procedure GetCurrentUser(var UserInfo: DotNet UserInfo)
    begin
        if CanQueryGraph() then
            UserInfo := GraphQuery.GetCurrentUser();
    end;

    procedure GetUserByAuthorizationEmail(AuthorizationEmail: Text; var UserInfo: DotNet UserInfo)
    begin
        if CanQueryGraph() then
            UserInfo := GraphQuery.GetUserByAuthorizationEmail(AuthorizationEmail);
    end;

    procedure GetUserByObjectId(ObjectId: Text; var UserInfo: DotNet UserInfo)
    begin
        if CanQueryGraph() then
            UserInfo := GraphQuery.GetUserByObjectId(ObjectId);
    end;

    procedure TryGetUserByObjectId(ObjectId: Text; var UserInfo: DotNet UserInfo): Boolean
    begin
        if CanQueryGraph() then
            exit(GraphQuery.TryGetUserByObjectId(ObjectId, UserInfo));
    end;

    procedure GetUserAssignedPlans(UserInfo: DotNet UserInfo; var UserAssignedPlans: DotNet GenericList1)
    begin
        if CanQueryGraph() then
            UserAssignedPlans := GraphQuery.GetUserAssignedPlans(UserInfo);
    end;

    procedure GetUserRoles(UserInfo: DotNet UserInfo; var UserRoles: DotNet GenericIEnumerable1)
    begin
        if CanQueryGraph() then
            UserRoles := UserInfo.Roles();
    end;

    procedure GetDirectorySubscribedSkus(var DirectorySubscribedSkus: DotNet GenericIEnumerable1)
    begin
        if CanQueryGraph() then
            DirectorySubscribedSkus := GraphQuery.GetDirectorySubscribedSkus();
    end;

    procedure GetDirectoryRoles(var DirectoryRoles: DotNet GenericIEnumerable1)
    begin
        if CanQueryGraph() then
            DirectoryRoles := GraphQuery.GetDirectoryRoles();
    end;

    procedure GetTenantDetail(var TenantInfo: DotNet TenantInfo)
    begin
        if CanQueryGraph() then
            TenantInfo := GraphQuery.GetTenantDetail();
    end;

    procedure GetUsersPage(NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
    begin
        if CanQueryGraph() then
            UserInfoPage := GraphQuery.GetUsersPage(NumberOfUsers);
    end;

    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        IsTestInProgress := TestInProgress;
    end;

    local procedure CanQueryGraph(): Boolean
    begin
        if not IsGraphInitialized then
            Initialize();

        exit(IsGraphInitialized);
    end;

    local procedure Initialize(): Boolean
    var
        AzureADGraph: codeunit "Azure AD Graph";
    begin
        if not EnvironmentInfo.IsSaaS() then
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

