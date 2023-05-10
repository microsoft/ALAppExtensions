// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9029 "Azure AD User Sync Impl."
{
    Access = Internal;

    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = TableData User = rm,
                  tabledata "User Personalization" = r;

    var
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        AzureADGraph: Codeunit "Azure AD Graph";
        AzureADPlan: Codeunit "Azure AD Plan";
        ProcessedUsers: List of [Text];
        UserSetupCategoryTxt: Label 'User Setup', Locked = true;
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
        DelimiterTxt: Label '|', Locked = true;
        DeviceGroupNameTxt: Label 'Dynamics 365 Business Central Device Users', Locked = true;

    #region FetchUpdates

    [NonDebuggable]
    procedure FetchUpdatesFromAzureGraph(var AzureADUserUpdate: Record "Azure AD User Update Buffer")
    var
        OfficeUsersInBC: List of [Guid];
    begin
        Clear(AzureADUserUpdate);
        AzureADUserUpdate.DeleteAll();
        Clear(ProcessedUsers);

        if AzureADGraph.IsEnvironmentSecurityGroupDefined() then
            FetchUpdatesFromEnvironmentDirectoryGroup(AzureADUserUpdate, OfficeUsersInBC)
        else begin
            FetchUpdatesForLicensedUsers(AzureADUserUpdate, OfficeUsersInBC);
            FetchUpdatesForDeviceUsers(AzureADUserUpdate, OfficeUsersInBC);
        end;

        FetchUpdatesForSkippedUsers(AzureADUserUpdate, OfficeUsersInBC);
        HandleRemovedUsers(AzureADUserUpdate, OfficeUsersInBC);
    end;

    [NonDebuggable]
    local procedure FetchUpdatesForLicensedUsers(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; OfficeUsersInBC: List of [Guid])
    var
        PlanIds: Codeunit "Plan Ids";
        GraphUserInfo: DotNet UserInfo;
        GraphUserInfoPage: Dotnet UserInfoPage;
        AssignedPlansList: DotNet StringArray;
        AllPlanIds: List of [Guid];
        UsersPerPage: Integer;
    begin
        UsersPerPage := 50;

        AllPlanIds := AzureADPlan.GetAllPlanIds();
        AllPlanIds.Remove(PlanIds.GetMicrosoft365PlanId());
        AllPlanIds.Remove(PlanIds.GetInternalAdminPlanId());
        ConvertList(AllPlanIds, AssignedPlansList);

        AzureADGraph.GetLicensedUsersPage(AssignedPlansList, UsersPerPage, GraphUserInfoPage);

        if IsNull(GraphUserInfoPage) then
            exit;

        repeat
            foreach GraphUserInfo in GraphUserInfoPage.CurrentPage() do
                GetUpdatesFromGraphUserInfo(GraphUserInfo, AzureADUserUpdate, OfficeUsersInBC);
        until (not GraphUserInfoPage.GetNextLicensedUsersPage(AssignedPlansList));
    end;

    [NonDebuggable]
    local procedure FetchUpdatesForDeviceUsers(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; OfficeUsersInBC: List of [Guid])
    var
        DeviceGroupMembers: DotNet IEnumerable;
        GraphUserInfo: DotNet UserInfo;
    begin
        AzureADGraph.GetGroupMembers(DeviceGroupNameTxt, DeviceGroupMembers);

        if IsNull(DeviceGroupMembers) then
            exit;

        foreach GraphUserInfo in DeviceGroupMembers do
            GetUpdatesFromGraphUserInfo(GraphUserInfo, AzureADUserUpdate, OfficeUsersInBC);
    end;

    [NonDebuggable]
    local procedure FetchUpdatesFromEnvironmentDirectoryGroup(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; OfficeUsersInBC: List of [Guid])
    var
        GroupMembers: DotNet IEnumerable;
        GraphUserInfo: DotNet UserInfo;
        CurrUserPlanIDs: List of [Guid];
    begin
        // Get all the group members of the environment group and fetch updates for those that have a BC plan
        AzureADGraph.GetMembersForGroupId(AzureADGraph.GetEnvironmentSecurityGroupId(), GroupMembers);

        if IsNull(GroupMembers) then
            exit;

        foreach GraphUserInfo in GroupMembers do begin
            AzureADPlan.GetPlanIDs(GraphUserInfo, CurrUserPlanIDs);
            if CurrUserPlanIDs.Count() > 0 then
                GetUpdatesFromGraphUserInfo(GraphUserInfo, AzureADUserUpdate, OfficeUsersInBC)
        end;
    end;

    [NonDebuggable]
    local procedure FetchUpdatesForSkippedUsers(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; OfficeUsersInBC: List of [Guid])
    var
        User: Record User;
        PlanIds: Codeunit "Plan Ids";
        UserPlanIds: List of [Guid];
        GraphUserInfo: DotNet UserInfo;
    begin
        // If the environment is not defined, update internal admins and Teams users, as they are not pulled in automatically
        // If the environment is defined, only update the internal admins, as they are still allowed to access the environment

        if not User.FindSet() then
            exit;

        repeat
            // Only iterate over the users who have not been scanned yet.
            // These should only include Internal Admins and Teams users (handled here)
            // and the users who have been deleted in Azure AD / had their BC plans unassigned (handled in HandleRemovedUsers)
            if not OfficeUsersInBC.Contains(User."User Security ID") then
                if TryGetUserByAuthorizationEmail(User."Authentication Email", GraphUserInfo) then
                    if not IsNull(GraphUserInfo) then begin
                        AzureADPlan.GetPlanIDs(GraphUserInfo, UserPlanIds);
                        if UserPlanIds.Contains(PlanIds.GetInternalAdminPlanId()) or // internal admins are not affected by the environment security group
                           ((not AzureADGraph.IsEnvironmentSecurityGroupDefined()) and UserPlanIds.Contains(PlanIds.GetMicrosoft365PlanId()))
                        then
                            GetUpdatesFromGraphUserInfo(GraphUserInfo, AzureADUserUpdate, OfficeUsersInBC);
                    end;
        until User.Next() = 0;
    end;

    [NonDebuggable]
    local procedure HandleRemovedUsers(var AzureADUserUpdate: Record "Azure AD User Update Buffer"; OfficeUsersInBC: List of [Guid])
    var
        User: Record User;
        UserSelection: Codeunit "User Selection";
        AzureADUserMgmtImpl: Codeunit "Azure AD User Mgmt. Impl.";
    begin
        // If the environment is not defined, only the users that were unassigned the BC "plans" in office or were deleted are handled here
        // If the environment is defined, then additionally the existing BC users that are not members of the environment group will be handled

        UserSelection.FilterSystemUserAndAADGroupUsers(User); // do not sync the daemon user and AAD groups
        if not User.FindSet() then
            exit;

        repeat
            // if user has no plans, skip
            if AzureADPlan.DoesUserHavePlans(User."User Security ID") then
                // if user has delegated plans, skip
                if not AzureADUserMgmtImpl.IsUserDelegated(User."User Security ID") then
                    if not OfficeUsersInBC.Contains(User."User Security ID") then begin
                        Session.LogMessage('0000BNE', StrSubstNo(AddingInformationForARemovedUserTxt, User."User Security ID"), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                        AddChangesForRemovedUser(AzureADUserUpdate, User);
                    end;
        until User.Next() = 0;
    end;

    [NonDebuggable]
    local procedure GetUpdatesFromGraphUserInfo(GraphUserInfo: DotNet UserInfo; var AzureADUserUpdate: Record "Azure AD User Update Buffer"; OfficeUsersInBC: List of [Guid])
    var
        User: Record User;
        CurrUserPlanIDs: List of [Guid];
    begin
        if ProcessedUsers.Contains(GraphUserInfo.ObjectId()) then
            exit;

        ProcessedUsers.Add(GraphUserInfo.ObjectId());
        if AzureADGraphUser.GetUser(GraphUserInfo.ObjectId(), User) then begin
            Session.LogMessage('0000BJS', StrSubstNo(AddingInformationForAnExistingUserTxt, User."User Security ID"), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
            AddChangesForExistingUser(AzureADUserUpdate, GraphUserInfo, User);
            OfficeUsersInBC.Add(User."User Security ID");
        end else begin
            AzureADPlan.GetPlanIDs(GraphUserInfo, CurrUserPlanIDs);
            if not SkipCreatingUserDuringSync(CurrUserPlanIDs) then begin
                Session.LogMessage('0000BJR', StrSubstNo(AddingInformationForANewUserTxt, GraphUserInfo.ObjectId()), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                AddChangesForNewUser(AzureADUserUpdate, GraphUserInfo);
            end;
        end;
    end;

    // If the AAD user's plans are any of the following:
    // - Internal Administrator
    // - Microsoft 365
    // - Internal Administrator + Microsoft 365
    // and there is no environemnt security group defined,
    // then we don't want to create a BC user during user sync.
    local procedure SkipCreatingUserDuringSync(UserPlanIDs: List of [Guid]): Boolean
    var
        PlanIDs: Codeunit "Plan Ids";
        PlanID: Guid;
    begin
        if AzureADGraph.IsEnvironmentSecurityGroupDefined() then
            exit(false);

        foreach PlanID in UserPlanIDs do
            if not (PlanID in [PlanIDs.GetInternalAdminPlanId(), PlanIDs.GetMicrosoft365PlanId()]) then
                exit(false);

        exit(true);
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

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetUserByAuthorizationEmail(AuthorizationEmail: Text; var GraphUserInfo: DotNet UserInfo)
    begin
        AzureADGraph.GetUserByAuthorizationEmail(AuthorizationEmail, GraphUserInfo);
    end;

    local procedure ConvertList(AssingedPlans: List of [Guid]; var AssignedPlansList: DotNet StringArray)
    var
        TempString: DotNet String;
        AssignedPlan: Guid;
        FormattedAssignedPlan: Text;
        Index: Integer;
    begin
        // Convert List of [Guid] to StringArray to be compatible with IList<String>
        TempString := '';
        AssignedPlansList := AssignedPlansList.CreateInstance(TempString.GetType(), AssingedPlans.Count());
        Index := 0;
        foreach AssignedPlan in AssingedPlans do begin
            // format is: ea48a3e0-48e0-4ab7-b1a1-e3ea85bf1b75
            FormattedAssignedPlan := Format(AssignedPlan, 0, 4).ToLower();
            AssignedPlansList.SetValue(FormattedAssignedPlan, Index);
            Index += 1;
        end;
    end;

    #endregion

    #region ApplyUpdates

    [NonDebuggable]
    procedure ApplyUpdatesFromAzureGraph(var AzureADUserUpdate: Record "Azure AD User Update Buffer") NumberOfSuccessfulUpdates: Integer
    var
        PlanNamesPerUserFromGraph: Dictionary of [Text, List of [Text]];
    begin
        ConsolidatePlansNamesFromGraph(AzureADUserUpdate, PlanNamesPerUserFromGraph);
        AzureADPlan.CheckMixedPlans(PlanNamesPerUserFromGraph, true);

        // The updates are stored in the table as [all the changes for the first user], [all the changes for the next user] etc.
        AzureADUserUpdate.SetCurrentKey("Authentication Object ID", "Update Entity");
        if AzureADUserUpdate.FindSet() then
            repeat
                AzureADUserUpdate.SetRange("Authentication Object ID", AzureADUserUpdate."Authentication Object ID");
                NumberOfSuccessfulUpdates += ProcessAllUpdatesForUser(AzureADUserUpdate);

                AzureADUserUpdate.SetFilter("Authentication Object ID", '>%1', AzureADUserUpdate."Authentication Object ID");
            until AzureADUserUpdate.Next() = 0;

        // undo the filters applied in this procedure
        AzureADUserUpdate.SetRange("Authentication Object ID");
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
        UpdatedSuccessfully: Boolean;
    begin
        Session.LogMessage('0000BHN', StrSubstNo(ApplyingUserUpdateTxt, AzureADUserUpdate."User Security ID", AzureADUserUpdate."Authentication Object ID"), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);

        repeat
            UpdatedSuccessfully := false;
            OnApplyUpdateFromAzureGraph(AzureADUserUpdate, User, UpdatedSuccessfully);
            if UpdatedSuccessfully then
                NumberOfSuccessfulUpdates += 1
            else
                Session.LogMessage('0000BPA', GetLastErrorCallStack, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt); // to be taken out;
        until AzureADUserUpdate.Next() = 0;
        Commit();
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD User Sync Impl.", OnApplyUpdateFromAzureGraph, '', false, false)]
    local procedure ApplyUpdateFromAzureGraph(AzureADUserUpdate: Record "Azure AD User Update Buffer"; var User: Record User; var UpdatedSuccessfully: Boolean)
    var
        Language: Codeunit Language;
        NavUserAuthenticationHelper: DotNet NavUserAccountHelper;
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
                    User.Modify();
                    NavUserAuthenticationHelper.SetAuthenticationObjectId(User."User Security ID", AzureADUserUpdate."Authentication Object ID");
                end;
            Enum::"Azure AD User Update Entity"::"Contact Email":
                begin
                    User."Contact Email" := CopyStr(AzureADUserUpdate."New Value", 1, MaxStrLen(User."Contact Email"));
                    User.Modify();
                end;
            Enum::"Azure AD User Update Entity"::"Full Name":
                begin
                    User."Full Name" := CopyStr(AzureADUserUpdate."New Value", 1, MaxStrLen(User."Full Name"));
                    User.Modify();
                end;
            Enum::"Azure AD User Update Entity"::"Language ID":
                begin
                    Evaluate(PreferredLanguageId, AzureADUserUpdate."New Value");
                    Language.SetPreferredLanguageID(User."User Security ID", PreferredLanguageId);
                end;
            Enum::"Azure AD User Update Entity"::Plan:
                AzureADPlan.UpdateUserPlans(User."User Security ID", AzureADUserUpdate."Permission Change Action" = AzureADUserUpdate."Permission Change Action"::Append, false, true);
        end;

        UpdatedSuccessfully := true;
    end;

    [NonDebuggable]
    local procedure CreateUser(var User: Record User; AuthenticationObjectID: Text[80]; AuthenticationEmail: Text[250])
    var
        AzureADUserMgmtImpl: Codeunit "Azure AD User Mgmt. Impl.";
        CurrentUserSecurityId: Guid;
    begin
        CurrentUserSecurityId := AzureADUserMgmtImpl.CreateNewUserInternal(AuthenticationEmail, AuthenticationObjectID);

        Session.LogMessage('0000BJU', StrSubstNo(UserCreatedTxt, AuthenticationObjectID, CurrentUserSecurityId), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);

        User.Get(CurrentUserSecurityId);

        // "Full Name" is set to DisplayName from GraphUser by default, so clearing it out
        User."Full Name" := '';
        User.Modify();
    end;

    [NonDebuggable]
    local procedure ConvertTextToList(InputText: Text; var MyList: List of [Text])
    begin
        MyList := InputText.Split(DelimiterTxt);
    end;

    [InternalEvent(false, true)]
    local procedure OnApplyUpdateFromAzureGraph(AzureADUserUpdate: Record "Azure AD User Update Buffer"; var User: Record User; var UpdatedSuccessfully: Boolean)
    begin
        // use isolated event for applying updates, as we should not stop when some updates fail
        // a try function cannot be used for this, as write transactions are not allowed inside them
    end;

    #endregion
}