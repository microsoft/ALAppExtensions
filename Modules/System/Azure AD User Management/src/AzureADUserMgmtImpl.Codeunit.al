// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9017 "Azure AD User Mgmt. Impl."
{
    Access = Internal;

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
        IsTestInProgress: Boolean;
        ProgressDlgMsg: Label 'Number of users retrieved: ''#1#################################\Current user name: ''#2#################################\', Comment = '%1 Integer number, %2 a user name';
        ProgressDlgWithBCUsersMsg: Label 'Number of users retrieved: ''#1#################################\Number of Business Central users processed: ''#2#################################\Last processed Business Central user name: ''#3#################################\', Comment = '%1 Total number of users, %2 Number of BC users, %3 User name';
        ProgressDlgApplyUpdatesMsg: Label 'Applying changes for user: ''#1#################################\', Comment = '%1 User name';
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
        AuthenticationEmailUpdateShouldBeTheFirstForANewUserErr: Label 'Authentication email should be the first entity to update.';
        ApplyingUserUpdateTxt: Label 'Applying update for user security ID [%1] with authentication object ID [%2]. Blank Guids indicate users not present in BC.', Comment = '%1 = user security ID (guid) and %2 = authentication object ID (guid)', Locked = true;
        UserCreatedTxt: Label 'A new user with authentication object ID [%1] and security ID [%2] has been created.', Comment = '%1 = authentication object ID (guid); %2 = user security ID (guid)', Locked = true;
        ApplyingEntityUpdateTxt: Label 'Updating %1 for user [%2]', Comment = '%1 = the update entity e.g. Full name, Plan etc.; %2 = user security ID (guid)', Locked = true;
        NewUserChangesTxt: Label 'A new user with authentication object ID [%1] received property [%2] from Graph.', Comment = '%1 = authentication object ID (guid); %2 = the update entity e.g. Full name, Plan etc.; %3 = new value of entity; %4 = original value of entity from Graph', Locked = true;
        ExistingUserChangesTxt: Label 'Existing user [%1] has the property [%2] changed.', Comment = '%1 = user security ID (guid); %2 = the update entity e.g. Full name, Plan etc.', Locked = true;
        ExistingUserRemovedTxt: Label 'Existing user [%1] with authentication object ID [%2] does not have a BC plan in the office portal anymore. Current plan: [%3].', Comment = '%1 = user security ID (guid); %2 = authentication object ID (guid); %3 = plan name (text).', Locked = true;
        AddingInformationForANewUserTxt: Label 'Adding changes for a new user. Authentication object ID: [%1].', Comment = '%1 = authentication object ID', Locked = true;
        AddingInformationForAnExistingUserTxt: Label 'Adding changes for an existing user [%1].', Comment = '%1 = user security ID', Locked = true;
        AddingInformationForARemovedUserTxt: Label 'Adding changes for a user removed / de-licensed in Office with user security ID [%1].', Comment = '%1 = User security ID', Locked = true;
        PlanNamesPerUserFromGraphTxt: Label 'User with AAD Object ID [%1] has plans [%2].', Comment = '%1 = authentication object ID (guid); %2 = list of plans for the user (text)', Locked = true;
        ProcessingUserTxt: Label 'Processing the user %1.', Comment = '%1 - Display name', Locked = true;
        UserCannotBeDeletedAlreadyLoggedInErr: Label 'The user "%1" cannot be deleted because the user has been logged on to the system. To deactivate a user, set the user''s state to Disabled.', Comment = 'Shown when trying to delete a user that has been logged onto the system. %1 = UserName.';
        DelimiterTxt: Label '|', Locked = true;

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

        if not UserLoginTimeTracker.IsFirstLogin(ForUserSecurityId) then
            exit;

        // Licenses are assigned to users in Office 365 and synchronized to Business Central from the Users page.
        // Permissions in licenses enable features for users, and not all tasks are available to all users.
        // RefreshUserPlans is used only when a user signs in while new user information in Office 365 has not been synchronized in Business Central.
        if AzureADPlan.DoesUserHavePlans(ForUserSecurityId) then
            exit;

        if AzureADGraphUser.GetUserAuthenticationObjectId(ForUserSecurityId) = '' then
            if AzureADGraphUser.IsUserDelegatedAdmin() then begin
                AzureADPlan.AssignDelegatedAdminPlanAndUserGroups();
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
        Window: Dialog;
        i: Integer;
        UsersPerPage: Integer;
    begin
        UsersPerPage := 100;
        AzureADGraph.GetUsersPage(UsersPerPage, GraphUserInfoPage);

        if IsNull(GraphUserInfoPage) then
            exit;

        if GuiAllowed() then
            Window.Open(ProgressDlgMsg);

        i := 0;
        repeat
            foreach GraphUserInfo in GraphUserInfoPage.CurrentPage() do
                if not AzureADGraphUser.GetUser(GraphUserInfo.ObjectId(), User) then begin
                    if GuiAllowed() then begin
                        Window.Update(1, i);
                        Window.Update(2, Format(GraphUserInfo.DisplayName()));
                    end;

                    Session.LogMessage('00009L4', StrSubstNo(ProcessingUserTxt, Format(GraphUserInfo.DisplayName())), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);

                    if CreateNewUserFromGraphUser(GraphUserInfo) then
                        i += 1
                end;
        until (not GraphUserInfoPage.GetNextPage());

        if GuiAllowed() then begin
            Window.Close();
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
    local procedure CreateNewUserInternal(AuthenticationEmail: Text; AADObjectID: Text): Guid
    var
        NewUserSecurityId: Guid;
        UserAccountHelper: DotNet NavUserAccountHelper;
    begin
        AzureADGraphUser.EnsureAuthenticationEmailIsNotInUse(AuthenticationEmail);

        if not IsTestInProgress then
            Commit();

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
    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        IsTestInProgress := TestInProgress;
        AzureADGraph.SetTestInProgress(TestInProgress);
        AzureADGraphUser.SetTestInProgress(TestInProgress);
        AzureADPlan.SetTestInProgress(TestInProgress);
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

    [NonDebuggable]
    procedure FetchUpdatesFromAzureGraph(var AzureADUserUpdate: Record "Azure AD User Update Buffer")
    var
        User: Record User;
        GraphUserInfo: DotNet UserInfo;
        GraphUserInfoPage: Dotnet UserInfoPage;
        Window: Dialog;
        OfficeUsersInBC: List of [Guid];
        CurrUserPlanIDs: List of [Guid];
        UsersPerPage: Integer;
        BCUserCounter: Integer;
        TotalUserCounter: Integer;
        LastBCUserName: Text;
    begin
        Clear(AzureADUserUpdate);
        AzureADUserUpdate.DeleteAll();

        TotalUserCounter := 0;
        BCUserCounter := 0;
        LastBCUserName := '';
        if GuiAllowed() then begin
            Window.Open(ProgressDlgWithBCUsersMsg);
            Window.Update();
        end;

        UsersPerPage := 100;
        AzureADGraph.GetUsersPage(UsersPerPage, GraphUserInfoPage);

        if IsNull(GraphUserInfoPage) then
            exit;

        repeat
            foreach GraphUserInfo in GraphUserInfoPage.CurrentPage() do begin
                TotalUserCounter += 1;
                AzureADPlan.GetPlanIDs(GraphUserInfo, CurrUserPlanIDs);
                if CurrUserPlanIDs.Count() > 0 then begin
                    BCUserCounter += 1;

                    if AzureADGraphUser.GetUser(GraphUserInfo.ObjectId(), User) then begin
                        Session.LogMessage('0000BJS', StrSubstNo(AddingInformationForAnExistingUserTxt, User."User Security ID"), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                        AddChangesForExistingUser(AzureADUserUpdate, GraphUserInfo, User);
                        OfficeUsersInBC.Add(User."User Security ID");
                    end else
                        if not SkipCreatingUserDuringSync(CurrUserPlanIDs) then begin
                            Session.LogMessage('0000BJR', StrSubstNo(AddingInformationForANewUserTxt, GraphUserInfo.ObjectId()), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                            AddChangesForNewUser(AzureADUserUpdate, GraphUserInfo);
                        end;

                    LastBCUserName := AzureADGraphUser.GetDisplayName(GraphUserInfo);
                end;

                if GuiAllowed() then begin
                    Window.Update(1, Format(TotalUserCounter));
                    Window.Update(2, Format(BCUserCounter));
                    Window.Update(3, LastBCUserName);
                end;
            end;
        until (not GraphUserInfoPage.GetNextPage());

        User.Reset();
        User.SetFilter("License Type", '<>%1', User."License Type"::"External User"); // do not sync the deamon user
        if User.FindSet() then
            repeat
                // if user has no plans, skip
                if AzureADPlan.DoesUserHavePlans(User."User Security ID") then
                    // if user has delegated plans, skip
                    if not IsUserDelegated(User."User Security ID") then
                        if not OfficeUsersInBC.Contains(User."User Security ID") then begin
                            Session.LogMessage('0000BNE', StrSubstNo(AddingInformationForARemovedUserTxt, User."User Security ID"), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                            AddChangesForRemovedUser(AzureADUserUpdate, User);
                        end;
            until User.Next() = 0;

        if GuiAllowed() then
            Window.Close();
    end;

    [NonDebuggable]
    procedure ApplyUpdatesFromAzureGraph(var AzureADUserUpdate: Record "Azure AD User Update Buffer") NumberOfSuccessfulUpdates: Integer
    var
        Window: Dialog;
        PlanNamesPerUserFromGraph: Dictionary of [Text, List of [Text]];
    begin
        ConsolidatePlansNamesFromGraph(AzureADUserUpdate, PlanNamesPerUserFromGraph);
        AzureADPlan.CheckMixedPlans(PlanNamesPerUserFromGraph, true);

        if GuiAllowed() then begin
            Window.Open(ProgressDlgApplyUpdatesMsg);
            Window.Update();
        end;
        // The updates are stored in the table as [all the changes for the first user], [all the changes for the next user] etc.
        AzureADUserUpdate.SetCurrentKey("Authentication Object ID", "Update Entity");
        if AzureADUserUpdate.FindSet() then
            repeat
                AzureADUserUpdate.SetRange("Authentication Object ID", AzureADUserUpdate."Authentication Object ID");
                if GuiAllowed() then
                    Window.Update(1, AzureADUserUpdate."Display Name");
                NumberOfSuccessfulUpdates += ProcessAllUpdatesForUser(AzureADUserUpdate);

                AzureADUserUpdate.SetFilter("Authentication Object ID", '>%1', AzureADUserUpdate."Authentication Object ID");
            until AzureADUserUpdate.Next() = 0;

        // undo the filters applied in this procedure
        AzureADUserUpdate.SetRange("Authentication Object ID");
        if GuiAllowed() then
            Window.Close();
    end;

    [NonDebuggable]
    local procedure ConsolidatePlansNamesFromGraph(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; var PlanNamesPerUserFromGraph: Dictionary of [Text, List of [Text]])
    var
        PlanNameList: List of [Text];
    begin
        AzureADUserUpdate.SetRange("Update Entity", AzureADUserUpdate."Update Entity"::Plan);
        if AzureADUserUpdate.FindSet() then
            repeat
                ConvertTextToList(AzureADUserUpdate."New Value", PlanNameList);
                PlanNamesPerUserFromGraph.Set(AzureADUserUpdate."Authentication Object ID", PlanNameList);
                Session.LogMessage('0000BPM', StrSubstNo(PlanNamesPerUserFromGraphTxt, AzureADUserUpdate."Authentication Object ID", AzureADUserUpdate."New Value"), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
            until AzureADUserUpdate.Next() = 0;
        AzureADUserUpdate.SetRange("Update Entity");
    end;

    [NonDebuggable]
    local procedure ProcessAllUpdatesForUser(var AzureADUserUpdate: Record "Azure AD User Update Buffer") NumberOfSuccessfulUpdates: Integer
    var
        User: Record User;
        ModifyUser: Boolean;
        SetAuthenticationObjectID: Boolean;
        NavUserAuthenticationHelper: DotNet NavUserAccountHelper;
    begin
        Session.LogMessage('0000BHN', StrSubstNo(ApplyingUserUpdateTxt, AzureADUserUpdate."User Security ID", AzureADUserUpdate."Authentication Object ID"), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);

        repeat
            if ApplyUpdateFromAzureGraph(AzureADUserUpdate, User, ModifyUser, SetAuthenticationObjectID) then
                NumberOfSuccessfulUpdates += 1
            else
                Session.LogMessage('0000BPA', GetLastErrorCallStack, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt); // to be taken out;
        until AzureADUserUpdate.Next() = 0;

        if ModifyUser then
            User.Modify();
        if SetAuthenticationObjectID then
            NavUserAuthenticationHelper.SetAuthenticationObjectId(User."User Security ID", AzureADUserUpdate."Authentication Object ID");

        Commit();
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure ApplyUpdateFromAzureGraph(AzureADUserUpdate: Record "Azure AD User Update Buffer"; var User: Record User; var ModifyUser: Boolean; var SetAuthenticationObjectID: Boolean)
    var
        Language: Codeunit Language;
        PreferredLanguageId: Integer;
        AuthenticationEmail: Text[250];
    begin
        if IsNullGuid(User."User Security ID") then
            case AzureADUserUpdate."Update Type" of
                AzureADUserUpdate."Update Type"::New:
                    begin
                        // AzureADUserUpdate must be sorted per the primary key so that the first record for a new user must update the authentication email.
                        if AzureADUserUpdate."Update Entity" <> Enum::"Azure AD User Update Entity"::"Authentication Email" then
                            Error(AuthenticationEmailUpdateShouldBeTheFirstForANewUserErr);
                        AuthenticationEmail := CopyStr(AzureADUserUpdate."New Value", 1, MaxStrLen(User."Authentication Email"));
                        if not AzureADGraphUser.GetUser(AzureADUserUpdate."Authentication Object ID", User) then
                            CreateUser(User, AzureADUserUpdate."Authentication Object ID", AuthenticationEmail);
                    end;
                AzureADUserUpdate."Update Type"::Change,
                AzureADUserUpdate."Update Type"::Remove:
                    User.Get(AzureADUserUpdate."User Security ID");
            end;

        Session.LogMessage('0000BHO', StrSubstNo(ApplyingEntityUpdateTxt, AzureADUserUpdate."Update Entity", User."User Security ID"), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
        case AzureADUserUpdate."Update Entity" of
            Enum::"Azure AD User Update Entity"::"Authentication Email":
                begin
                    User."Authentication Email" := '';
                    User.Modify(); // need to call this Modify to ensure that the authentication email is not in use, as checked for below.
                    AuthenticationEmail := CopyStr(AzureADUserUpdate."New Value", 1, MaxStrLen(User."Authentication Email"));
                    AzureADGraphUser.EnsureAuthenticationEmailIsNotInUse(AuthenticationEmail);
                    User."Authentication Email" := AuthenticationEmail;
                    ModifyUser := true;
                    SetAuthenticationObjectID := true;
                end;
            Enum::"Azure AD User Update Entity"::"Contact Email":
                begin
                    User."Contact Email" := CopyStr(AzureADUserUpdate."New Value", 1, MaxStrLen(User."Contact Email"));
                    ModifyUser := true;
                end;
            Enum::"Azure AD User Update Entity"::"Full Name":
                begin
                    User."Full Name" := CopyStr(AzureADUserUpdate."New Value", 1, MaxStrLen(User."Full Name"));
                    ModifyUser := true;
                end;
            Enum::"Azure AD User Update Entity"::"Language ID":
                begin
                    Evaluate(PreferredLanguageId, AzureADUserUpdate."New Value");
                    Language.SetPreferredLanguageID(User."User Security ID", PreferredLanguageId);
                end;
            Enum::"Azure AD User Update Entity"::Plan:
                AzureADPlan.UpdateUserPlans(User."User Security ID", AzureADUserUpdate."Permission Change Action" = AzureADUserUpdate."Permission Change Action"::Append, false, true);
        end;
    end;

    [NonDebuggable]
    local procedure CreateUser(var User: Record User; AuthenticationObjectID: Text[80]; AuthenticationEmail: Text[250])
    var
        CurrentUserSecurityId: Guid;
    begin
        CurrentUserSecurityId := CreateNewUserInternal(AuthenticationEmail, AuthenticationObjectID);

        Session.LogMessage('0000BJU', StrSubstNo(UserCreatedTxt, AuthenticationObjectID, CurrentUserSecurityId), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);

        User.Get(CurrentUserSecurityId);

        // "Full Name" is set to DisplayName from GraphUser by default, so clearing it out
        User."Full Name" := '';
        User.Modify();
    end;

    [NonDebuggable]
    local procedure AddChangesForNewUser(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; GraphUserInfo: DotNet UserInfo)
    var
        UserUpdateEntities: List of [Integer];
        CurrentUpdateEntity: Enum "Azure AD User Update Entity";
        ValueFromGraph: Text;
        Counter: Integer;
    begin
        UserUpdateEntities := Enum::"Azure AD User Update Entity".Ordinals();

        for Counter := 1 to UserUpdateEntities.Count() do begin
            CurrentUpdateEntity := Enum::"Azure AD User Update Entity".FromInteger(UserUpdateEntities.Get(Counter));
            ValueFromGraph := GetUpdateEntityFromGraph(CurrentUpdateEntity, GraphUserInfo);

            if ValueFromGraph <> '' then begin
                AzureADUserUpdate.Init();
                AzureADUserUpdate."Authentication Object ID" := GraphUserInfo.ObjectId();
                AzureADUserUpdate."Update Type" := Enum::"Azure AD Update Type"::New;
                AzureADUserUpdate.Validate("Update Entity", CurrentUpdateEntity);
                AzureADUserUpdate."New Value" := CopyStr(ValueFromGraph, 1, MaxStrLen(AzureADUserUpdate."New Value"));
                AzureADUserUpdate."Display Name" := AzureADGraphUser.GetDisplayName(GraphUserInfo);

                Session.LogMessage('0000BHP', StrSubstNo(NewUserChangesTxt, AzureADUserUpdate."Authentication Object ID", CurrentUpdateEntity), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                AzureADUserUpdate.Insert();
            end;
        end;
    end;

    [NonDebuggable]
    local procedure AddChangesForExistingUser(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; GraphUserInfo: DotNet UserInfo; User: Record User)
    var
        UserUpdateEntities: List of [Integer];
        CurrentUpdateEntity: Enum "Azure AD User Update Entity";
        ValueFromGraph: Text;
        ValueFromUserTable: Text;
        Counter: Integer;
        ChangesDetected: Boolean;
    begin
        UserUpdateEntities := Enum::"Azure AD User Update Entity".Ordinals();

        for Counter := 1 to UserUpdateEntities.Count() do begin
            CurrentUpdateEntity := Enum::"Azure AD User Update Entity".FromInteger(UserUpdateEntities.Get(Counter));
            ValueFromGraph := GetUpdateEntityFromGraph(CurrentUpdateEntity, GraphUserInfo);
            ValueFromUserTable := GetUpdateEntityFromUser(CurrentUpdateEntity, User);

            case CurrentUpdateEntity of
                CurrentUpdateEntity::Plan:
                    ChangesDetected := AzureADPlan.CheckIfPlansDifferent(GraphUserInfo, User."User Security ID");
                CurrentUpdateEntity::"Language ID":
                    // Do not override BC language with blank value if it's not defined in Office
                    ChangesDetected := (ValueFromGraph <> '') and (LowerCase(ValueFromGraph) <> LowerCase(ValueFromUserTable));
                else
                    ChangesDetected := LowerCase(ValueFromGraph) <> LowerCase(ValueFromUserTable);
            end;

            if ChangesDetected then begin
                AzureADUserUpdate.Init();
                AzureADUserUpdate."Update Type" := Enum::"Azure AD Update Type"::Change;
                AzureADUserUpdate."Authentication Object ID" := GraphUserInfo.ObjectId();
                AzureADUserUpdate."User Security ID" := User."User Security ID";
                AzureADUserUpdate.Validate("Update Entity", CurrentUpdateEntity);
                AzureADUserUpdate."Current Value" := CopyStr(ValueFromUserTable, 1, MaxStrLen(AzureADUserUpdate."Current Value"));
                AzureADUserUpdate."New Value" := CopyStr(ValueFromGraph, 1, MaxStrLen(AzureADUserUpdate."New Value"));
                AzureADUserUpdate."Display Name" := AzureADGraphUser.GetDisplayName(GraphUserInfo);

                Session.LogMessage('0000BHQ', StrSubstNo(ExistingUserChangesTxt, User."User Security ID", CurrentUpdateEntity), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                AzureADUserUpdate.Insert();
            end;
        end;
    end;

    [NonDebuggable]
    local procedure AddChangesForRemovedUser(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; User: Record User)
    begin
        AzureADUserUpdate.Init();
        AzureADUserUpdate."Update Type" := Enum::"Azure AD Update Type"::Remove;

        AzureADUserUpdate."Authentication Object ID" := CopyStr(AzureADGraphUser.GetUserAuthenticationObjectId(User."User Security ID"), 1, MaxStrLen(AzureADUserUpdate."Authentication Object ID"));
        // If for the user doesn't have an authentication object ID (imported user, application, cleared directly in the database), assign a random one to avoid duplicate key exception.
        if AzureADUserUpdate."Authentication Object ID" = '' then
            AzureADUserUpdate."Authentication Object ID" := Format(CreateGuid()) + '-GENERATED';

        AzureADUserUpdate."User Security ID" := User."User Security ID";
        AzureADUserUpdate.Validate("Update Entity", Enum::"Azure AD User Update Entity"::Plan);
        AzureADUserUpdate."Current Value" := CopyStr(GetUpdateEntityFromUser(Enum::"Azure AD User Update Entity"::Plan, User), 1, MaxStrLen(AzureADUserUpdate."Current Value"));
        AzureADUserUpdate."Display Name" := User."User Name";

        Session.LogMessage('0000BNF', StrSubstNo(ExistingUserRemovedTxt, User."User Security ID", AzureADUserUpdate."Authentication Object ID", AzureADUserUpdate."Current Value"), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
        AzureADUserUpdate.Insert();
    end;

    [NonDebuggable]
    local procedure GetUpdateEntityFromUser(UpdateEntity: Enum "Azure AD User Update Entity"; User: Record User): Text
    var
        UserPersonalization: Record "User Personalization";
        LanguageId: Integer;
        PlanNames: List of [Text];
    begin
        case UpdateEntity of
            Enum::"Azure AD User Update Entity"::"Authentication Email":
                exit(Format(User."Authentication Email"));
            Enum::"Azure AD User Update Entity"::"Contact Email":
                exit(Format(User."Contact Email"));
            Enum::"Azure AD User Update Entity"::"Full Name":
                exit(Format(User."Full Name"));
            Enum::"Azure AD User Update Entity"::"Language ID":
                begin
                    if UserPersonalization.Get(User."User Security ID") then
                        LanguageId := UserPersonalization."Language ID";

                    if LanguageId <> 0 then
                        exit(Format(LanguageId));

                    exit('');
                end;
            Enum::"Azure AD User Update Entity"::Plan:
                begin
                    AzureADPlan.GetPlanNames(User."User Security ID", PlanNames);
                    exit(ConvertListToText(PlanNames));
                end;
        end;
    end;

    [NonDebuggable]
    local procedure GetUpdateEntityFromGraph(UpdateEntity: Enum "Azure AD User Update Entity"; GraphUserInfo: DotNet UserInfo): Text
    var
        PlanNames: List of [Text];
        LanguageId: Integer;
    begin
        case UpdateEntity of
            Enum::"Azure AD User Update Entity"::"Authentication Email":
                exit(AzureADGraphUser.GetAuthenticationEmail(GraphUserInfo));
            Enum::"Azure AD User Update Entity"::"Contact Email":
                exit(AzureADGraphUser.GetContactEmail(GraphUserInfo));
            Enum::"Azure AD User Update Entity"::"Full Name":
                exit(AzureADGraphUser.GetFullName(GraphUserInfo));
            Enum::"Azure AD User Update Entity"::"Language ID":
                begin
                    LanguageId := AzureADGraphUser.GetPreferredLanguageID(GraphUserInfo);

                    if LanguageId = 0 then
                        exit('');

                    exit(Format(LanguageId));
                end;
            Enum::"Azure AD User Update Entity"::Plan:
                begin
                    AzureADPlan.GetPlanNames(GraphUserInfo, PlanNames);
                    exit(ConvertListToText(PlanNames));
                end;
        end;
    end;

    [NonDebuggable]
    local procedure ConvertListToText(MyList: List of [Text]) Result: Text
    var
        Element: Text;
    begin
        foreach Element in MyList do
            Result += Element + DelimiterTxt;
        // TrimStart in case the plan name for the first plan is empty.
        Result := Result.TrimEnd(DelimiterTxt).TrimStart(DelimiterTxt);
    end;

    [NonDebuggable]
    local procedure ConvertTextToList(InputText: Text; var MyList: List of [Text])
    begin
        MyList := InputText.Split(DelimiterTxt);
    end;

    // If the AAD user's plans are any of the following:
    // - Internal Administrator
    // - M365 Collaboration
    // - Internal Administrator + M365 Collaboration
    // then we don't want to create a BC user during user sync.
    local procedure SkipCreatingUserDuringSync(UserPlanIDs: List of [Guid]): Boolean
    var
        PlanIDs: Codeunit "Plan Ids";
        PlanID: Guid;
    begin
        foreach PlanID in UserPlanIDs do
            if not (PlanID in [PlanIDs.GetInternalAdminPlanId(), PlanIDs.GetM365CollaborationPlanId()]) then
                exit(false);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::User, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteUser(var Rec: Record User; RunTrigger: Boolean)
    var
        UserPersonalization: Record "User Personalization";
    begin
        if Rec.IsTemporary() then
            exit;

        // Allow deletion of users only if they have never logged in.
        if not UserLoginTimeTracker.IsFirstLogin(Rec."User Security ID") then
            Error(UserCannotBeDeletedAlreadyLoggedInErr, Rec."User Name");

        // Access control and user property are cleaned-up in the platform.
        // Clean-up user personalization.
        if UserPersonalization.Get(Rec."User Security ID") then
            UserPersonalization.Delete();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Custom Dimensions", 'OnAddCommonCustomDimensions', '', true, true)]
    local procedure OnAddCommonCustomDimensions(var Sender: Codeunit "Telemetry Custom Dimensions")
    var
        PlanIds: Codeunit "Plan Ids";
        IsAdmin: Boolean;
    begin
        IsAdmin := AzureADGraphUser.IsUserDelegatedAdmin() or AzureADPlan.IsPlanAssigned(PlanIds.GetInternalAdminPlanId());
        Sender.AddCommonCustomDimension('IsAdmin', Format(IsAdmin));
    end;

    [InternalEvent(false)]
    local procedure OnIsUserTenantAdmin(var IsUserTenantAdmin: Boolean; var Handled: Boolean)
    begin
    end;
}