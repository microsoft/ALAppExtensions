// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9017 "Azure AD User Mgmt. Impl."
{
    Access = Internal;

    Permissions = TableData "Access Control" = rimd,
                  TableData User = rimd,
                  TableData "User Property" = rimd,
                  TableData "Membership Entitlement" = rimd;

    trigger OnRun()
    begin
        if ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::Background then
            exit;

        Run(UserSecurityId());
    end;

    var
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
        ClientTypeManagement: Codeunit "Client Type Management";
        EnvironmentInfo: Codeunit "Environment Information";
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        AzureADGraph: Codeunit "Azure AD Graph";
        AzureADPlan: Codeunit "Azure AD Plan";
        IsTestInProgress: Boolean;
        ProgressDlgMsg: Label 'Number of users retrieved: ''#1#################################\Current user name: ''#2#################################\', Comment = '%1 Integer number, %2 a user name';
        NoOfUsersRetrievedMsg: Label 'Number of users retrieved: %1.', Comment = '%1=integer number';
        UserCategoryTxt: Label 'AL User', Locked = true;
        CouldNotGetUserErr: Label 'Could not get a user.', Locked = true;
        UserTenantAdminMsg: Label 'User is a tenant admin.', Locked = true;
        UserNotTenantAdminMsg: Label 'User is not a tenant admin.', Locked = true;
        CompanyAdminRoleTemplateIdTok: Label '62e90394-69f5-4237-9190-012177145e10', Locked = true;
        UserSetupCategoryTxt: Label 'User Setup', Locked = true;
        UserCreatedMsg: Label 'User %1 has been created', Locked = true;
        UserNotFoundMsg: Label 'User %1 was not found in Office 365. We will turn off the user account.', Comment = '%1=user name';

    procedure Run(ForUserSecurityId: Guid)
    var
        UserProperty: Record "User Property";
    begin
        // This function exists for testability
        if not EnvironmentInfo.IsSaaS() then
            exit;

        if not UserProperty.Get(ForUserSecurityId) then
            exit;

        if not UserLoginTimeTracker.IsFirstLogin(ForUserSecurityId) then
            exit;

        if AzureADGraphUser.GetUserAuthenticationObjectId(ForUserSecurityId) = '' then
            exit;

        AzureADPlan.RefreshUserPlanAssignments(ForUserSecurityId);
    end;

    procedure CreateNewUsersFromAzureAD()
    var
        User: Record User;
        GraphUser: DotNet UserInfo;
        GraphUserPage: Dotnet UserInfoPage;
        Window: Dialog;
        i: Integer;
        UsersPerPage: Integer;
    begin
        UsersPerPage := 100;
        AzureADGraph.GetUsersPage(UsersPerPage, GraphUserPage);

        if IsNull(GraphUserPage) then
            exit;

        if GuiAllowed() then
            Window.Open(ProgressDlgMsg);

        repeat
            foreach GraphUser in GraphUserPage.CurrentPage() do
                if not GetUserFromAuthenticationObjectId(GraphUser.ObjectId(), User) then begin
                    if GuiAllowed() then begin
                        Window.Update(1, i);
                        Window.Update(2, Format(GraphUser.DisplayName()));
                    end;

                    SendTraceTag('00009L4', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo('Procesing User %1', Format(GraphUser.DisplayName())),
                        DataClassification::CustomerContent);

                    if CreateNewUserFromGraphUser(GraphUser) then
                        i += 1
                end;
        until (not GraphUserPage.GetNextPage());

        if GuiAllowed() then begin
            Window.Close();
            Message(NoOfUsersRetrievedMsg, i);
        end;
    end;

    procedure CreateNewUserFromGraphUser(GraphUser: DotNet UserInfo): Boolean
    var
        UserAccountHelper: DotNet NavUserAccountHelper;
        NewUserSecurityId: Guid;
    begin
        if AzureADPlan.IsGraphUserEntitledFromServicePlan(GraphUser) then begin
            AzureADGraphUser.EnsureAuthenticationEmailIsNotInUse(GraphUser.UserPrincipalName());

            Commit();

            NewUserSecurityId := UserAccountHelper.CreateUserFromAzureADObjectId(GraphUser.ObjectId());
            SendTraceTag('00009L3', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(UserCreatedMsg, Format(NewUserSecurityId)),
                DataClassification::CustomerContent);
            if not IsNullGuid(NewUserSecurityId) then begin
                InitializeAsNewUser(NewUserSecurityId, GraphUser);
                exit(true);
            end;
        end;
        exit(false);
    end;

    local procedure GetUserFromAuthenticationObjectId(AuthenticationObjectId: Text; var FoundUser: Record User): Boolean
    var
        UserProperty: Record "User Property";
    begin
        UserProperty.SetRange("Authentication Object ID", AuthenticationObjectId);
        if UserProperty.FindFirst() then
            exit(FoundUser.Get(UserProperty."User Security ID"));
        exit(false)
    end;

    procedure IsUserTenantAdmin(): Boolean
    var
        GraphUser: DotNet UserInfo;
        GraphRoleInfo: DotNet RoleInfo;
    begin
        if not AzureADGraphUser.GetGraphUser(UserSecurityId(), GraphUser) then begin
            SendTraceTag('0000728', UserCategoryTxt, VERBOSITY::Error, CouldNotGetUserErr, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if IsNull(GraphUser) then begin
            SendTraceTag('000071V', UserCategoryTxt, VERBOSITY::Error, CouldNotGetUserErr, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not IsNull(GraphUser.Roles()) then
            foreach GraphRoleInfo in GraphUser.Roles() do
                if GraphRoleInfo.RoleTemplateId() = CompanyAdminRoleTemplateIdTok then begin
                    SendTraceTag('000071T', UserCategoryTxt, VERBOSITY::Normal, UserTenantAdminMsg, DATACLASSIFICATION::CustomerContent);
                    exit(true);
                end;

        SendTraceTag('000071Y', UserCategoryTxt, VERBOSITY::Normal, UserNotTenantAdminMsg, DATACLASSIFICATION::CustomerContent);

        exit(false);
    end;

    local procedure UpdateUserFromAzureGraph(var User: Record User; var GraphUser: DotNet UserInfo): Boolean
    var
        IsUserModified: Boolean;
    begin
        AzureADGraphUser.GetGraphUser(User."User Security ID", GraphUser);
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User, GraphUser);
        exit(IsUserModified);
    end;

    procedure UpdateUserFromGraph(var User: Record User)
    var
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
        GraphUser: DotNet UserInfo;
    begin
        if AzureADGraphUser.GetGraphUser(User."User Security ID", GraphUser) then
            AzureADGraphUser.UpdateUserFromAzureGraph(User, GraphUser)
        else
            if not (AzureADPlan.IsPlanAssignedToUser(PlanIds.GetDelegatedAdminPlanId(), User."User Security ID") or
                    AzureADPlan.IsPlanAssignedToUser(PlanIds.GetHelpDeskPlanId(), User."User Security ID")) then begin
                Message(UserNotFoundMsg, User."User Name");
                User.State := User.State::Disabled;
                User.Modify();
            end;
    end;

    local procedure InitializeAsNewUser(NewUserSecurityId: Guid; var GraphUser: DotNet UserInfo)
    var
        User: Record User;
    begin
        User.Get(NewUserSecurityId);

        UpdateUserFromAzureGraph(User, GraphUser);
        AzureADPlan.UpdateUserPlans(User."User Security ID", GraphUser);
    end;

    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        IsTestInProgress := TestInProgress;
        AzureADGraph.SetTestInProgress(TestInProgress);
        AzureADGraphUser.SetTestInProgress(TestInProgress);
        AzureADPlan.SetTestInProgress(TestInProgress);
    end;

    procedure SynchronizeLicensedUserFromDirectory(AuthenticationEmail: Text): Boolean
    var
        User: Record User;
        GraphUser: DotNet UserInfo;
    begin
        AzureADGraph.GetUser(AuthenticationEmail, GraphUser);
        if IsNull(GraphUser) then
            exit(false);

        if GetUserFromAuthenticationObjectId(GraphUser.ObjectId(), User) then begin
            UpdateUserFromAzureGraph(User, GraphUser);
            AzureADPlan.UpdateUserPlans(User."User Security ID", GraphUser);
        end else
            CreateNewUserFromGraphUser(GraphUser);

        exit(true);
    end;

    procedure SynchronizeAllLicensedUsersFromDirectory()
    begin
        CreateNewUsersFromAzureAD();
    end;
}



