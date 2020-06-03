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
        ProgressDlgWithBCUsersMsg: Label 'Number of users retrieved: ''#1#################################\Number of Business Central users processed: ''#2#################################\Last processed Business Central user name: ''#3#################################\', Comment = '%1 Total number of users, %2 Number of BC users, %3 User name';
        ProgressDlgApplyUpdatesMsg: Label 'Applying changes for user: ''#1#################################\', Comment = '%1 User name';
        NoOfUsersRetrievedMsg: Label 'Number of users retrieved: %1.', Comment = '%1=integer number';
        UserCategoryTxt: Label 'AL User', Locked = true;
        CouldNotGetUserErr: Label 'Could not get a user.', Locked = true;
        UserTenantAdminMsg: Label 'User is a tenant admin.', Locked = true;
        UserNotTenantAdminMsg: Label 'User is not a tenant admin.', Locked = true;
        CompanyAdminRoleTemplateIdTok: Label '62e90394-69f5-4237-9190-012177145e10', Locked = true;
        UserSetupCategoryTxt: Label 'User Setup', Locked = true;
        UserCreatedMsg: Label 'User %1 has been created', Locked = true;
        AuthenticationEmailUpdateShouldBeTheFirstForANewUserErr: Label 'Authentication email should be the first entity to update.';
        ApplyingUserUpdateTxt: Label 'Applying update for user security ID [%1] with authentication object ID [%2]. Blank Guids indicate users not present in BC.', Comment = '%1 = user security ID (guid) and %2 = authentication object ID (guid)', Locked = true;
        UserNotFoundWhenApplyingTxt: Label 'User not found. Creating a new user from authentication object ID [%1] and authentication email [%2].', Comment = '%1 = authentication object ID (guid), %2 = authentication email (email)', Locked = true;
        UserCreatedTxt: Label 'A new user with security ID [%1] has been created.', Comment = '%1 = user security ID (guid)', Locked = true;
        ApplyingEntityUpdateTxt: Label 'Updating %1 from [%2] to [%3] for user [%4]', Comment = '%1 = the update entity e.g. Full name, Plan etc.; %2 = current value of entity; %3 = new value of entity; %4 = user security ID (guid)', Locked = true;
        NewUserChangesTxt: Label 'A new user [%1] has property [%2] set to [%3]. The original value from Graph is [%4].', Comment = '%1 = user security ID (guid); %2 = the update entity e.g. Full name, Plan etc.; %3 = new value of entity; %4 = original value of entity from Graph', Locked = true;
        ExistingUserChangesTxt: Label 'Existing user [%1] has [%2] changed from [%3] to [%4]. The original value from Graph is [%5].', Comment = '%1 = user security ID (guid); %2 = the update entity e.g. Full name, Plan etc.; %3 = current value of entity; %4 = new value of entity; %5 = original value of entity from Graph', Locked = true;
        ExistingUserRemovedTxt: Label 'Existing user [%1] with authentication object ID [%2] does not have a BC plan in the office portal anymore. Current plan: [%3].', Comment = '%1 = user security ID (guid); %2 = authentication object ID (guid); %3 = plan name (text).', Locked = true;
        AddingInformationForANewUserTxt: Label 'Adding changes for a new user [%1].', Comment = '%1 = user display name (text)', Locked = true;
        AddingInformationForAnExistingUserTxt: Label 'Adding changes for an existing user [%1].', Comment = '%1 = user display name (text)', Locked = true;
        AddingInformationForARemovedUserTxt: Label 'Adding changes for a user removed / de-licensed in Office with user name [%1].', Comment = '%1 = User name', Locked = true;
        PlanNamesPerUserFromGraphTxt: Label 'User with AAD Object ID [%1] has plans [%2].', Comment = '%1 = authentication object ID (guid); %2 = list of plans for the user (text)', Locked = true;
        ProcessingUserTxt: Label 'Procesing the user %1.', Comment = '%1 - Display name', Locked = true;
        DelimiterTxt: Label '|', Locked = true;

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

        // Licenses are assigned to users in Office 365 and synchronized to Business Central from the Users page.
        // Permissions in licenses enable features for users, and not all tasks are available to all users.
        // RefreshUserPlans is used only when a user signs in while new user information in Office 365 has not been synchronized in Business Central.
        if AzureADPlan.DoesUserHavePlans(ForUserSecurityId) then
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

        i := 0;
        repeat
            foreach GraphUser in GraphUserPage.CurrentPage() do
                if not AzureADGraphUser.GetUser(GraphUser.ObjectId(), User) then begin
                    if GuiAllowed() then begin
                        Window.Update(1, i);
                        Window.Update(2, Format(GraphUser.DisplayName()));
                    end;

                    SendTraceTag('00009L4', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(ProcessingUserTxt, Format(GraphUser.DisplayName())),
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
        NewUserSecurityId: Guid;
    begin
        if AzureADPlan.IsGraphUserEntitledFromServicePlan(GraphUser) then begin
            NewUserSecurityId := CreateNewUserInternal(GraphUser.UserPrincipalName(), GraphUser.ObjectId());

            SendTraceTag('00009L3', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(UserCreatedMsg, Format(NewUserSecurityId)),
                DataClassification::CustomerContent);
            if not IsNullGuid(NewUserSecurityId) then begin
                InitializeAsNewUser(NewUserSecurityId, GraphUser);
                exit(true);
            end;
        end;
        exit(false);
    end;

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
                    SendTraceTag('000071T', UserCategoryTxt, VERBOSITY::Normal, UserTenantAdminMsg, DATACLASSIFICATION::SystemMetadata);
                    exit(true);
                end;

        SendTraceTag('000071Y', UserCategoryTxt, VERBOSITY::Normal, UserNotTenantAdminMsg, DATACLASSIFICATION::SystemMetadata);

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
        AzureADGraphUserToFetch: Codeunit "Azure AD Graph User";
        GraphUser: DotNet UserInfo;
    begin
        if AzureADGraphUserToFetch.GetGraphUser(User."User Security ID", GraphUser) then
            AzureADGraphUserToFetch.UpdateUserFromAzureGraph(User, GraphUser);
    end;

    local procedure IsUserDelegated(UserSecID: Guid): Boolean
    var
        PlanIds: Codeunit "Plan Ids";
    begin
        exit(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetDelegatedAdminPlanId(), UserSecID) or
                    AzureADPlan.IsPlanAssignedToUser(PlanIds.GetHelpDeskPlanId(), UserSecID));
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

        if AzureADGraphUser.GetUser(GraphUser.ObjectId(), User) then begin
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

    procedure FetchUpdatesFromAzureGraph(var AzureADUserUpdate: Record "Azure AD User Update Buffer")
    var
        User: Record User;
        PlanIDs: Codeunit "Plan Ids";
        GraphUser: DotNet UserInfo;
        GraphUserPage: Dotnet UserInfoPage;
        Window: Dialog;
        OfficeUsersInBC: List of [Guid];
        CurrUserPlanIDs: List of [Guid];
        UsersPerPage: Integer;
        BCUserCounter: Integer;
        TotalUserCounter: Integer;
        LastBCUserName: Text;
        IsUserInternalAdminOnly: Boolean;
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
        AzureADGraph.GetUsersPage(UsersPerPage, GraphUserPage);

        if IsNull(GraphUserPage) then
            exit;

        repeat
            foreach GraphUser in GraphUserPage.CurrentPage() do begin
                TotalUserCounter += 1;
                AzureADPlan.GetPlanIDs(GraphUser, CurrUserPlanIDs);
                if CurrUserPlanIDs.Count() > 0 then begin
                    BCUserCounter += 1;
                    IsUserInternalAdminOnly := (CurrUserPlanIDs.Count() = 1) and CurrUserPlanIDs.Contains(PlanIDs.GetInternalAdminPlanId());

                    if AzureADGraphUser.GetUser(GraphUser.ObjectId(), User) then begin
                        SendTraceTag('0000BJS', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(AddingInformationForAnExistingUserTxt, Format(GraphUser.DisplayName())),
                            DataClassification::EndUserIdentifiableInformation);
                        AddChangesForExistingUser(AzureADUserUpdate, GraphUser, User);
                        OfficeUsersInBC.Add(User."User Security ID");
                    end else
                        if not IsUserInternalAdminOnly then begin
                            SendTraceTag('0000BJR', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(AddingInformationForANewUserTxt, Format(GraphUser.DisplayName())),
                                DataClassification::EndUserIdentifiableInformation);
                            AddChangesForNewUser(AzureADUserUpdate, GraphUser);
                        end;

                    LastBCUserName := AzureADGraphUser.GetDisplayName(GraphUser);
                end;

                if GuiAllowed() then begin
                    Window.Update(1, Format(TotalUserCounter));
                    Window.Update(2, Format(BCUserCounter));
                    Window.Update(3, LastBCUserName);
                end;
            end;
        until (not GraphUserPage.GetNextPage());

        User.Reset();
        User.SetFilter("License Type", '<>%1', User."License Type"::"External User"); // do not sync the deamon user
        if User.FindSet() then
            repeat
                // if user has no plans, skip
                if AzureADPlan.DoesUserHavePlans(User."User Security ID") then
                    // if user has delegated plans, skip
                    if not IsUserDelegated(User."User Security ID") then
                        if not OfficeUsersInBC.Contains(User."User Security ID") then begin
                            SendTraceTag('0000BNE', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(AddingInformationForARemovedUserTxt, User."User Name"),
                                DataClassification::EndUserIdentifiableInformation);
                            AddChangesForRemovedUser(AzureADUserUpdate, User);
                        end;
            until User.Next() = 0;

        if GuiAllowed() then
            Window.Close();
    end;

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

    local procedure ConsolidatePlansNamesFromGraph(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; var PlanNamesPerUserFromGraph: Dictionary of [Text, List of [Text]])
    var
        PlanNameList: List of [Text];
    begin
        AzureADUserUpdate.SetRange("Update Entity", AzureADUserUpdate."Update Entity"::Plan);
        if AzureADUserUpdate.FindSet() then
            repeat
                ConvertTextToList(AzureADUserUpdate."New Value", PlanNameList);
                PlanNamesPerUserFromGraph.Set(AzureADUserUpdate."Authentication Object ID", PlanNameList);
                SendTraceTag('0000BPM', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(PlanNamesPerUserFromGraphTxt, AzureADUserUpdate."Authentication Object ID", AzureADUserUpdate."New Value"), DataClassification::EndUserIdentifiableInformation);
            until AzureADUserUpdate.Next() = 0;
        AzureADUserUpdate.SetRange("Update Entity");
    end;

    local procedure ProcessAllUpdatesForUser(var AzureADUserUpdate: Record "Azure AD User Update Buffer") NumberOfSuccessfulUpdates: Integer
    var
        User: Record User;
        ModifyUser: Boolean;
        SetAuthenticationObjectID: Boolean;
        NavUserAuthenticationHelper: DotNet NavUserAccountHelper;
    begin
        SendTraceTag('0000BHN', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(ApplyingUserUpdateTxt, AzureADUserUpdate."User Security ID", AzureADUserUpdate."Authentication Object ID"), DataClassification::EndUserIdentifiableInformation);

        repeat
            if ApplyUpdateFromAzureGraph(AzureADUserUpdate, User, ModifyUser, SetAuthenticationObjectID) then
                NumberOfSuccessfulUpdates += 1
            else
                SendTraceTag('0000BPA', UserSetupCategoryTxt, Verbosity::Normal, GetLastErrorCallStack, DataClassification::SystemMetadata); // to be taken out;
        until AzureADUserUpdate.Next() = 0;

        if ModifyUser then
            User.Modify();
        if SetAuthenticationObjectID then
            NavUserAuthenticationHelper.SetAuthenticationObjectId(User."User Security ID", AzureADUserUpdate."Authentication Object ID");

        Commit();
    end;

    [TryFunction]
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

        SendTraceTag('0000BHO', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(ApplyingEntityUpdateTxt, AzureADUserUpdate."Update Entity", AzureADUserUpdate."Current Value", AzureADUserUpdate."New Value", User."User Security ID"), DataClassification::EndUserIdentifiableInformation);
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
                AzureADPlan.UpdateUserPlans(User."User Security ID", AzureADUserUpdate."Permission Change Action" = AzureADUserUpdate."Permission Change Action"::Append, false);
        end;
    end;

    local procedure CreateUser(var User: Record User; AuthenticationObjectID: Text[80]; AuthenticationEmail: Text[250])
    var
        CurrentUserSecurityId: Guid;
    begin
        SendTraceTag('0000BJT', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(UserNotFoundWhenApplyingTxt, AuthenticationObjectID, AuthenticationEmail), DataClassification::EndUserIdentifiableInformation);

        CurrentUserSecurityId := CreateNewUserInternal(AuthenticationEmail, AuthenticationObjectID);

        // update all AzureADUSerUpdate records to the new user security id created, as it is blank
        SendTraceTag('0000BJU', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(UserCreatedTxt, CurrentUserSecurityId), DataClassification::EndUserIdentifiableInformation);

        User.Get(CurrentUserSecurityId);

        // "Full Name" is set to DisplayName from GraphUser by default, so clearing it out
        User."Full Name" := '';
        User.Modify();
    end;

    local procedure AddChangesForNewUser(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; GraphUser: DotNet UserInfo)
    var
        UserUpdateEntities: List of [Integer];
        CurrentUpdateEntity: Enum "Azure AD User Update Entity";
        ValueFromGraph: Text;
        Counter: Integer;
    begin
        UserUpdateEntities := Enum::"Azure AD User Update Entity".Ordinals();

        for Counter := 1 to UserUpdateEntities.Count() do begin
            CurrentUpdateEntity := Enum::"Azure AD User Update Entity".FromInteger(UserUpdateEntities.Get(Counter));
            ValueFromGraph := GetUpdateEntityFromGraph(CurrentUpdateEntity, GraphUser);

            if ValueFromGraph <> '' then begin
                AzureADUserUpdate.Init();
                AzureADUserUpdate."Authentication Object ID" := GraphUser.ObjectId();
                AzureADUserUpdate."Update Type" := Enum::"Azure AD Update Type"::New;
                AzureADUserUpdate.Validate("Update Entity", CurrentUpdateEntity);
                AzureADUserUpdate."New Value" := CopyStr(ValueFromGraph, 1, MaxStrLen(AzureADUserUpdate."New Value"));
                AzureADUserUpdate."Display Name" := AzureADGraphUser.GetDisplayName(GraphUser);

                SendTraceTag('0000BHP', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(NewUserChangesTxt, AzureADUserUpdate."Authentication Object ID", CurrentUpdateEntity, AzureADUserUpdate."New Value", ValueFromGraph), DataClassification::EndUserIdentifiableInformation);
                AzureADUserUpdate.Insert();
            end;
        end;
    end;

    local procedure AddChangesForExistingUser(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; GraphUser: DotNet UserInfo; User: Record User)
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
            ValueFromGraph := GetUpdateEntityFromGraph(CurrentUpdateEntity, GraphUser);
            ValueFromUserTable := GetUpdateEntityFromUser(CurrentUpdateEntity, User);
            if CurrentUpdateEntity = CurrentUpdateEntity::Plan then
                ChangesDetected := AzureADPlan.CheckIfPlansDifferent(GraphUser, User."User Security ID")
            else
                ChangesDetected := LowerCase(ValueFromGraph) <> LowerCase(ValueFromUserTable);

            if ChangesDetected then begin
                AzureADUserUpdate.Init();
                AzureADUserUpdate."Update Type" := Enum::"Azure AD Update Type"::Change;
                AzureADUserUpdate."Authentication Object ID" := GraphUser.ObjectId();
                AzureADUserUpdate."User Security ID" := User."User Security ID";
                AzureADUserUpdate.Validate("Update Entity", CurrentUpdateEntity);
                AzureADUserUpdate."Current Value" := CopyStr(ValueFromUserTable, 1, MaxStrLen(AzureADUserUpdate."Current Value"));
                AzureADUserUpdate."New Value" := CopyStr(ValueFromGraph, 1, MaxStrLen(AzureADUserUpdate."New Value"));
                AzureADUserUpdate."Display Name" := AzureADGraphUser.GetDisplayName(GraphUser);

                SendTraceTag('0000BHQ', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(ExistingUserChangesTxt, User."User Security ID", CurrentUpdateEntity, AzureADUserUpdate."Current Value", AzureADUserUpdate."New Value", ValueFromGraph), DataClassification::EndUserIdentifiableInformation);
                AzureADUserUpdate.Insert();
            end;
        end;
    end;

    local procedure AddChangesForRemovedUser(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; User: Record User)
    begin
        AzureADUserUpdate.Init();
        AzureADUserUpdate."Update Type" := Enum::"Azure AD Update Type"::Remove;

        AzureADUserUpdate."Authentication Object ID" := CopyStr(AzureADGraphUser.GetUserAuthenticationObjectId(User."User Security ID"), 1, MaxStrLen(AzureADUserUpdate."Authentication Object ID"));
        AzureADUserUpdate."User Security ID" := User."User Security ID";
        AzureADUserUpdate.Validate("Update Entity", Enum::"Azure AD User Update Entity"::Plan);
        AzureADUserUpdate."Current Value" := CopyStr(GetUpdateEntityFromUser(Enum::"Azure AD User Update Entity"::Plan, User), 1, MaxStrLen(AzureADUserUpdate."Current Value"));
        AzureADUserUpdate."Display Name" := User."User Name";

        SendTraceTag('0000BNF', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(ExistingUserRemovedTxt, User."User Security ID", AzureADUserUpdate."Authentication Object ID", AzureADUserUpdate."Current Value"), DataClassification::EndUserIdentifiableInformation);
        AzureADUserUpdate.Insert();
    end;

    local procedure GetUpdateEntityFromUser(UpdateEntity: Enum "Azure AD User Update Entity"; User: Record User): Text
    var
        UserPersonalization: Record "User Personalization";
        Language: Codeunit Language;
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
                        exit(Format(UserPersonalization."Language ID"));
                    // Fallback in case "User Personalization" was not created while updating the plan for the current user.
                    exit(Format(Language.GetDefaultApplicationLanguageId()));
                end;
            Enum::"Azure AD User Update Entity"::Plan:
                begin
                    AzureADPlan.GetPlanNames(User."User Security ID", PlanNames);
                    exit(ConvertListToText(PlanNames));
                end;
        end;
    end;

    local procedure GetUpdateEntityFromGraph(UpdateEntity: Enum "Azure AD User Update Entity"; GraphUser: DotNet UserInfo): Text
    var
        PlanNames: List of [Text];
        LanguageId: Integer;
    begin
        case UpdateEntity of
            Enum::"Azure AD User Update Entity"::"Authentication Email":
                exit(AzureADGraphUser.GetAuthenticationEmail(GraphUser));
            Enum::"Azure AD User Update Entity"::"Contact Email":
                exit(AzureADGraphUser.GetContactEmail(GraphUser));
            Enum::"Azure AD User Update Entity"::"Full Name":
                exit(AzureADGraphUser.GetFullName(GraphUser));
            Enum::"Azure AD User Update Entity"::"Language ID":
                begin
                    LanguageId := AzureADGraphUser.GetPreferredLanguageID(GraphUser);

                    if LanguageId = 0 then
                        exit('');

                    exit(Format(LanguageId));
                end;
            Enum::"Azure AD User Update Entity"::Plan:
                begin
                    AzureADPlan.GetPlanNames(GraphUser, PlanNames);
                    exit(ConvertListToText(PlanNames));
                end;
        end;
    end;

    local procedure ConvertListToText(MyList: List of [Text]) Result: Text
    var
        Element: Text;
    begin
        foreach Element in MyList do
            Result += Element + DelimiterTxt;
        // TrimStart in case the plan name for the first plan is empty.
        Result := Result.TrimEnd(DelimiterTxt).TrimStart(DelimiterTxt);
    end;

    local procedure ConvertTextToList(InputText: Text; var MyList: List of [Text])
    begin
        MyList := InputText.Split(DelimiterTxt);
    end;

}