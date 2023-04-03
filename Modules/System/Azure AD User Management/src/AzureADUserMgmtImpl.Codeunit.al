// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9017 "Azure AD User Mgmt. Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    Permissions = TableData User = rm,
                  TableData "User Property" = r,
                  tabledata "User Personalization" = r;

    trigger OnRun()
    begin
        if ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::Background then
            exit;

        Run(UserSecurityId());
    end;

    var
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
        ClientTypeManagement: Codeunit "Client Type Management";
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        AzureADGraph: Codeunit "Azure AD Graph";
        AzureADPlan: Codeunit "Azure AD Plan";
        ProgressDlgMsg: Label 'Number of users retrieved: ''#1#################################\Current user name: ''#2#################################\', Comment = '%1 Integer number, %2 a user name';
        NoOfUsersRetrievedMsg: Label 'Number of users retrieved: %1.', Comment = '%1=integer number';
        UserCategoryTxt: Label 'AL User', Locked = true;
        CouldNotGetUserErr: Label 'Could not get a user.', Locked = true;
        UserTenantAdminMsg: Label 'User is a tenant admin.', Locked = true;
        UserNotTenantAdminMsg: Label 'User is not a tenant admin.', Locked = true;
#pragma warning disable AA0240
        CompanyAdminRoleTemplateIdTok: Label '62e90394-69f5-4237-9190-012177145e10', Locked = true;
#pragma warning restore AA0240
        UserSetupCategoryTxt: Label 'User Setup', Locked = true;
        UserCreatedMsg: Label 'User %1 has been created', Locked = true;
        ProcessingUserTxt: Label 'Processing the user %1.', Comment = '%1 - Display name', Locked = true;
        UserCannotBeDeletedAlreadyLoggedInErr: Label 'The user "%1" cannot be deleted because the user has been logged on to the system. To deactivate a user, set the user''s state to Disabled.', Comment = 'Shown when trying to delete a user that has been logged onto the system. %1 = UserName.';

    [NonDebuggable]
    procedure Run(ForUserSecurityId: Guid)
    var
        UserProperty: Record "User Property";
    begin
        // This function exists for testability
        if not EnvironmentInformation.IsSaaS() then
            exit;

        if not UserProperty.Get(ForUserSecurityId) then
            exit;

        if UserLoginTimeTracker.UserLoggedInEnvironment(ForUserSecurityId) then
            exit;

        // Licenses are assigned to users in Office 365 and synchronized to Business Central from the Users page.
        // Permissions in licenses enable features for users, and not all tasks are available to all users.
        // RefreshUserPlans is used only when a user signs in while new user information in Office 365 has not been synchronized in Business Central.
        if AzureADPlan.DoesUserHavePlans(ForUserSecurityId) then
            exit;

        if AzureADGraphUser.IsUserDelegatedAdmin() or AzureADGraphUser.IsUserDelegatedHelpdesk() then begin
            AzureADPlan.AssignPlanToUserWithDelegatedRole(ForUserSecurityId);
            exit;
        end;

        AzureADPlan.RefreshUserPlanAssignments(ForUserSecurityId);
    end;

    [NonDebuggable]
    procedure CreateNewUsersFromAzureAD()
    var
        User: Record User;
        GraphUserInfo: DotNet UserInfo;
        GraphUserInfoPage: Dotnet UserInfoPage;
        WindowDialog: Dialog;
        i: Integer;
        UsersPerPage: Integer;
    begin
        UsersPerPage := 50;
        AzureADGraph.GetUsersPage(UsersPerPage, GraphUserInfoPage);

        if IsNull(GraphUserInfoPage) then
            exit;

        if GuiAllowed() then
            WindowDialog.Open(ProgressDlgMsg);

        i := 0;
        repeat
            foreach GraphUserInfo in GraphUserInfoPage.CurrentPage() do
                if not AzureADGraphUser.GetUser(GraphUserInfo.ObjectId(), User) then begin
                    if GuiAllowed() then begin
                        WindowDialog.Update(1, i);
                        WindowDialog.Update(2, Format(GraphUserInfo.DisplayName()));
                    end;

                    Session.LogMessage('00009L4', StrSubstNo(ProcessingUserTxt, Format(GraphUserInfo.DisplayName())), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);

                    if CreateNewUserFromGraphUser(GraphUserInfo) then
                        i += 1
                end;
        until (not GraphUserInfoPage.GetNextPage());

        if GuiAllowed() then begin
            WindowDialog.Close();
            Message(NoOfUsersRetrievedMsg, i);
        end;
    end;

    [NonDebuggable]
    procedure CreateNewUserFromGraphUser(GraphUserInfo: DotNet UserInfo): Boolean
    var
        NewUserSecurityId: Guid;
    begin
        if AzureADPlan.IsGraphUserEntitledFromServicePlan(GraphUserInfo) then begin
            NewUserSecurityId := CreateNewUserInternal(GraphUserInfo.UserPrincipalName(), GraphUserInfo.ObjectId());

            Session.LogMessage('00009L3', StrSubstNo(UserCreatedMsg, Format(NewUserSecurityId)), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
            if not IsNullGuid(NewUserSecurityId) then begin
                InitializeAsNewUser(NewUserSecurityId, GraphUserInfo);
                exit(true);
            end;
        end;
        exit(false);
    end;

    [NonDebuggable]
    procedure CreateNewUserInternal(AuthenticationEmail: Text; AADObjectID: Text): Guid
    var
        NewUserSecurityId: Guid;
        UserAccountHelper: DotNet NavUserAccountHelper;
        Handled: Boolean;
    begin
        AzureADGraphUser.EnsureAuthenticationEmailIsNotInUse(AuthenticationEmail);
        Commit();

        OnBeforeCreateUserFromAzureADObjectId(AADObjectID, NewUserSecurityId, Handled);
        if not Handled then
            NewUserSecurityId := UserAccountHelper.CreateUserFromAzureADObjectId(AADObjectID);

        exit(NewUserSecurityId);
    end;

    [NonDebuggable]
    procedure IsUserTenantAdmin(): Boolean
    var
        GraphUserInfo: DotNet UserInfo;
        GraphRoleInfo: DotNet RoleInfo;
        IsUserTenantAdministrator, Handled : Boolean;
    begin
        OnIsUserTenantAdmin(IsUserTenantAdministrator, Handled);

        if Handled then
            exit(IsUserTenantAdministrator);

        if not AzureADGraphUser.GetGraphUser(UserSecurityId(), GraphUserInfo) then begin
            Session.LogMessage('0000728', CouldNotGetUserErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserCategoryTxt);
            exit(false);
        end;

        if IsNull(GraphUserInfo) then begin
            Session.LogMessage('000071V', CouldNotGetUserErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserCategoryTxt);
            exit(false);
        end;

        if not IsNull(GraphUserInfo.Roles()) then
            foreach GraphRoleInfo in GraphUserInfo.Roles() do
                if GraphRoleInfo.RoleTemplateId() = CompanyAdminRoleTemplateIdTok then begin
                    Session.LogMessage('000071T', UserTenantAdminMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserCategoryTxt);
                    exit(true);
                end;

        Session.LogMessage('000071Y', UserNotTenantAdminMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserCategoryTxt);

        exit(false);
    end;

    [NonDebuggable]
    local procedure UpdateUserFromAzureGraph(var User: Record User; var GraphUserInfo: DotNet UserInfo): Boolean
    var
        IsUserModified: Boolean;
    begin
        AzureADGraphUser.GetGraphUser(User."User Security ID", GraphUserInfo);
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User, GraphUserInfo);
        exit(IsUserModified);
    end;

    [NonDebuggable]
    procedure IsUserDelegated(UserSecID: Guid): Boolean
    var
        PlanIds: Codeunit "Plan Ids";
    begin
        exit(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetDelegatedAdminPlanId(), UserSecID) or
            AzureADPlan.IsPlanAssignedToUser(PlanIds.GetHelpDeskPlanId(), UserSecID) or
            AzureADPlan.IsPlanAssignedToUser(PlanIds.GetD365AdminPartnerPlanId(), UserSecID))
    end;

    [NonDebuggable]
    local procedure InitializeAsNewUser(NewUserSecurityId: Guid; var GraphUserInfo: DotNet UserInfo)
    var
        User: Record User;
    begin
        User.Get(NewUserSecurityId);

        UpdateUserFromAzureGraph(User, GraphUserInfo);
        AzureADPlan.UpdateUserPlans(User."User Security ID", GraphUserInfo);
    end;

    [NonDebuggable]
    procedure SynchronizeLicensedUserFromDirectory(AuthenticationEmail: Text): Boolean
    var
        User: Record User;
        GraphUserInfo: DotNet UserInfo;
    begin
        AzureADGraph.GetUser(AuthenticationEmail, GraphUserInfo);
        if IsNull(GraphUserInfo) then
            exit(false);

        if AzureADGraphUser.GetUser(GraphUserInfo.ObjectId(), User) then begin
            UpdateUserFromAzureGraph(User, GraphUserInfo);
            AzureADPlan.UpdateUserPlans(User."User Security ID", GraphUserInfo);
        end else
            CreateNewUserFromGraphUser(GraphUserInfo);

        exit(true);
    end;

    [NonDebuggable]
    procedure SynchronizeAllLicensedUsersFromDirectory()
    begin
        CreateNewUsersFromAzureAD();
    end;

    [EventSubscriber(ObjectType::Table, Database::User, OnBeforeDeleteEvent, '', true, true)]
    local procedure OnBeforeDeleteUser(var Rec: Record User; RunTrigger: Boolean)
    var
        UserPersonalization: Record "User Personalization";
    begin
        if Rec.IsTemporary() then
            exit;

        // Allow deletion of users only if they have never logged in.
        if UserLoginTimeTracker.UserLoggedInEnvironment(Rec."User Security ID") then
            Error(UserCannotBeDeletedAlreadyLoggedInErr, Rec."User Name");

        // Access control and user property are cleaned-up in the platform.
        // Clean-up user personalization.
        if UserPersonalization.Get(Rec."User Security ID") then
            UserPersonalization.Delete();
    end;

    procedure ArePermissionsCustomized(UserSecId: Guid): Boolean
    var
        AccessControl: Record "Access Control";
        TempAccessControlWithDefaultPermissions: Record "Access Control" temporary;
        PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer";
        PlanConfiguration: Codeunit "Plan Configuration";
        UsersInPlans: Query "Users in Plans";
    begin
        // Check if the user is assigned any custom permission sets
        // by comparing the plan configuration for all assigned plans.
        UsersInPlans.SetFilter(User_Security_ID, UserSecId);
        if not UsersInPlans.Open() then
            exit(false);

        while UsersInPlans.Read() do begin
            if PlanConfiguration.IsCustomized(UsersInPlans.Plan_ID) then
                PlanConfiguration.GetCustomPermissions(PermissionSetInPlanBuffer)
            else
                PlanConfiguration.GetDefaultPermissions(PermissionSetInPlanBuffer);

            PermissionSetInPlanBuffer.SetRange("Plan ID", UsersInPlans.Plan_ID);
            if PermissionSetInPlanBuffer.FindSet() then
                repeat
                    AccessControl.SetRange("User Security ID", UserSecId);
                    AccessControl.SetRange("Role ID", PermissionSetInPlanBuffer."Role ID");
                    AccessControl.SetRange(Scope, PermissionSetInPlanBuffer.Scope);
                    AccessControl.SetRange("App ID", PermissionSetInPlanBuffer."App ID");
                    if PlanConfiguration.IsCustomized(UsersInPlans.Plan_ID) then
                        AccessControl.SetRange("Company Name", PermissionSetInPlanBuffer."Company Name");

                    if not AccessControl.FindSet() then
                        exit(true); // one of the permission sets for a plan configuration was deleted

                    repeat
                        TempAccessControlWithDefaultPermissions.Copy(AccessControl);
                        TempAccessControlWithDefaultPermissions.Insert();
                    until AccessControl.Next() = 0;
                until PermissionSetInPlanBuffer.Next() = 0;
        end;

        AccessControl.Reset();
        AccessControl.SetRange("User Security ID", UserSecId);
        // if the user has more permissions than specified by the plan configuration, then the permissions are customized
        exit(AccessControl.Count() > TempAccessControlWithDefaultPermissions.Count());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Custom Dimensions", OnAddCommonCustomDimensions, '', true, true)]
    local procedure OnAddCommonCustomDimensions(var Sender: Codeunit "Telemetry Custom Dimensions")
    var
        PlanIds: Codeunit "Plan Ids";
        UserAccountHelper: DotNet NavUserAccountHelper;
        TenantInfo: DotNet TenantInfo;
        IsAdmin: Boolean;
    begin
        if not UserAccountHelper.IsAzure() then
            exit;

        // Add IsAdmin
        IsAdmin := AzureADGraphUser.IsUserDelegatedAdmin() or AzureADPlan.IsPlanAssignedToUser(PlanIds.GetInternalAdminPlanId());
        Sender.AddCommonCustomDimension('IsAdmin', Format(IsAdmin));

        // Add CountryCode
        AzureADGraph.GetTenantDetail(TenantInfo);
        if not IsNull(TenantInfo) then
            Sender.AddCommonCustomDimension('CountryCode', TenantInfo.CountryLetterCode());
    end;

    [InternalEvent(false)]
    local procedure OnIsUserTenantAdmin(var IsUserTenantAdmin: Boolean; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    local procedure OnBeforeCreateUserFromAzureADObjectId(AADObjectID: Text; var NewUserSecurityId: Guid; var Handled: Boolean);
    begin
    end;
}