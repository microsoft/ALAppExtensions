// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9018 "Azure AD Plan Impl."
{
    Access = Internal;

    Permissions = TableData Company = r,
                  TableData Plan = rimd,
                  TableData "User Plan" = rimd,
                  TableData User = r;

    var
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
        AzureADGraph: Codeunit "Azure AD Graph";
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        IsTest: Boolean;
        UserSetupCategoryTxt: Label 'User Setup', Locked = true;
        DeviceGroupNameTxt: Label 'Dynamics 365 Business Central Device Users', Locked = true;
        DevicePlanFoundMsg: Label 'Device plan %1 found for user with authentication object ID %2', Locked = true;
        NotBCUserMsg: Label 'User with authentication object ID %1 is not a Business Central user', Locked = true;
        MixedPlansNonAdminErr: Label 'All users must be assigned to the same license, either Basic, Essential, or Premium. %1 and %2 are assigned to different licenses, for example, but there may be other mismatches. Your system administrator or Microsoft partner can verify license assignments in your Microsoft 365 admin portal.\\We will sign you out when you choose the OK button.', Comment = '%1 = %2 = Authnetication email.';
        MixedPlansAdminErr: Label 'Before you can update user information, go to your Microsoft 365 admin center and make sure that all users are assigned to the same Business Central license, either Basic, Essential, or Premium. For example, we found that users %1 and %2 are assigned to different licenses, but there may be other mismatches.', Comment = '%1 = %2 = Authnetication email.';
        MixedPlansMsg: Label 'One or more users are not assigned to the same Business Central license. For example, we found that users %1 and %2 are assigned to different licenses, but there may be other mismatches. In your Microsoft 365 admin center, make sure that all users are assigned to the same Business Central license, either Basic, Essential, or Premium.  Afterward, update Business Central by opening the Users page and using the ''Update Users from Office 365'' action.', Comment = '%1 = %2 = Authnetication email.';
        UserPlanAssignedMsg: Label 'User with authentication object ID %1 is assigned plan %2', Locked = true;
        UserHasNoPlansMsg: Label 'User with authentication object ID %1 has no Business Central plans assigned', Locked = true;
        DeviceUserCannotBeFirstUserErr: Label 'The device user cannot be the first user to log into the system.';
        UserGotPlanTxt: Label 'The Graph User with the authentication object ID %1 has a plan with ID %2 named %3.', Comment = '%1 = Authentication email (email); %2 = subscription plan ID (guid); %3 = Plan name (tex1t)', Locked = true;
        PlansDifferentCheckTxt: Label 'Checking if plans different for graph user with authentication object ID %1 and BC user with security ID %2.', Comment = '%1 = Authentication email (email); %2 = user security ID (guid)', Locked = true;
        PlanCountDifferentTxt: Label 'The count of plans in BC is %1 and count of plans in Graph is %2.', Locked = true;
        UserNotInUserTableTxt: Label 'The user is not present in the User table. Security ID: %1.', Locked = true;
        AzureGraphUserNotFoundTxt: Label 'Could not retrieve an Azure Graph user for User Security ID: %1.', Locked = true;
        AzurePlanRoleCenterFoundTxt: Label 'Found role center %1 for user %2 from Azure Plan.', Locked = true;
        NoPlanHasRoleCenterTxt: Label 'There is no plan for the user with a valid Role Center ID.', Locked = true;
        GraphUserHasExtraPlanTxt: Label 'Graph user has plan with ID %1 and named %2 that BC user does not have.', Locked = true, Comment = '%1 = Plan ID (guid); %2 = Plan name';
        MixedPlansExistTxt: Label 'Check for mixed plans. Basic plan exists: %1, Essentials plan exists: %2; Premium plan exists: %3.', Locked = true;
        UserDoesNotExistTxt: Label 'User with user SID %1 does not exist or does not have an authentication object ID', Locked = true;
        UsersWithMixedPlansTxt: Label 'Check for mixed plans. Authentication object ID for the first conflicting user: [%1]; second conflicting user [%2].', Locked = true;
        CheckingForMixedPlansTxt: Label 'Checking for mixed plans...', Locked = true;
        BasicPlanNameTxt: Label 'D365 Business Central Basic Financials', Locked = true;
        EssentialsPlanNameTxt: Label 'Dynamics 365 Business Central Essential', Locked = true;
        PremiumPlanNameTxt: Label 'Dynamics 365 Business Central Premium', Locked = true;

    [NonDebuggable]
    procedure IsPlanAssigned(PlanGUID: Guid): Boolean
    var
        UsersInPlans: Query "Users in Plans";
    begin
        UsersInPlans.SetRange(User_State, UsersInPlans.User_State::Enabled);
        UsersInPlans.SetRange(Plan_ID, PlanGUID);

        if UsersInPlans.Open() then
            exit(UsersInPlans.Read());
    end;

    [NonDebuggable]
    procedure IsPlanAssignedToUser(PlanGUID: Guid): Boolean
    begin
        exit(IsPlanAssignedToUser(PlanGUID, UserSecurityId()));
    end;

    [NonDebuggable]
    procedure IsPlanAssignedToUser(PlanGUID: Guid; UserGUID: Guid): Boolean
    var
        UserPlan: Record "User Plan";
    begin
        UserPlan.SetRange("User Security ID", UserGUID);
        UserPlan.SetRange("Plan ID", PlanGUID);
        exit(not UserPlan.IsEmpty());
    end;

    [NonDebuggable]
    procedure IsGraphUserEntitledFromServicePlan(var GraphUserInfo: DotNet UserInfo): Boolean
    var
        AssignedPlan: DotNet ServicePlanInfo;
        ServicePlanIdValue: Variant;
    begin
        if not IsNull(GraphUserInfo.AssignedPlans()) then
            foreach AssignedPlan in GraphUserInfo.AssignedPlans() do
                if Format(AssignedPlan.CapabilityStatus()) = 'Enabled' then begin
                    ServicePlanIdValue := AssignedPlan.ServicePlanId();
                    if IsBCServicePlan(ServicePlanIdValue) then
                        exit(true);
                end;

        if IsDeviceRole(GraphUserInfo) then
            exit(true);

        exit(false);
    end;

    [NonDebuggable]
    procedure UpdateUserPlans(UserSecurityId: Guid; var GraphUserInfo: DotNet UserInfo; AppendPermissionsOnNewPlan: Boolean; RemoveUserGroupsOnDeletePlan: Boolean)
    var
        TempPlan: Record Plan temporary;
        UserPlan: Record "User Plan";
        HasUserBeenSetupBefore: Boolean;
    begin
        GetGraphUserPlans(TempPlan, GraphUserInfo);

        // Has the user been setup earlier?
        UserPlan.SetRange("User Security ID", UserSecurityId);
        HasUserBeenSetupBefore := not (UserPlan.IsEmpty() and UserLoginTimeTracker.IsFirstLogin(UserSecurityId));

        // Have any plans been removed from this user in O365, since last time he logged-in to NAV?
        RemoveUnassignedUserPlans(TempPlan, UserSecurityId, RemoveUserGroupsOnDeletePlan);

        // Have any plans been added to this user in O365, since last time he logged-in to NAV?
        AddNewlyAssignedUserPlans(TempPlan, UserSecurityId, HasUserBeenSetupBefore, AppendPermissionsOnNewPlan);
    end;

    [NonDebuggable]
    procedure UpdateUserPlans(UserSecurityId: Guid; AppendPermissionsOnNewPlan: Boolean; RemoveUserGroupsOnDeletePlan: Boolean; RemovePlansOnDeleteUser: Boolean)
    var
        TempDummyPlan: Record Plan temporary;
        GraphUserInfo: DotNet UserInfo;
    begin
        if AzureADGraphUser.GetGraphUser(UserSecurityID, true, GraphUserInfo) then
            UpdateUserPlans(UserSecurityId, GraphUserInfo, AppendPermissionsOnNewPlan, RemoveUserGroupsOnDeletePlan)
        else
            if RemovePlansOnDeleteUser then
                RemoveUnassignedUserPlans(TempDummyPlan, UserSecurityId, RemoveUserGroupsOnDeletePlan);
    end;

    [NonDebuggable]
    procedure UpdateUserPlans()
    var
        User: Record User;
    begin
        User.SetFilter("License Type", '<>%1', User."License Type"::"External User");
        User.SetFilter("Windows Security ID", '%1', '');

        if not User.FindSet() then
            exit;

        repeat
            UpdateUserPlans(User."User Security ID", true, true, false);
        until User.Next() = 0;
    end;

    [NonDebuggable]
    procedure RefreshUserPlanAssignments(UserSecurityID: Guid)
    var
        User: Record User;
        UsersInPlan: Query "Users in Plans";
        GraphUserInfo: DotNet UserInfo;
        UserPlanExists: Boolean;
    begin
        if not User.Get(UserSecurityID) then
            exit;

        if not AzureADGraphUser.GetGraphUser(UserSecurityID, GraphUserInfo) then
            exit;

        // Is this the first user being setup
        if UsersInPlan.Open() then
            if UsersInPlan.Read() then
                UserPlanExists := true;

        if not UserPlanExists then
            if IsDeviceRole(GraphUserInfo) then
                Error(DeviceUserCannotBeFirstUserErr);

        UpdateUserFromAzureGraph(User, GraphUserInfo);
        UpdateUserPlans(User."User Security ID", GraphUserInfo, true, true);
    end;

    [TryFunction]
    [NonDebuggable]
    procedure TryGetAzureUserPlanRoleCenterId(var RoleCenterID: Integer; UserSecurityID: Guid)
    begin
        RoleCenterID := GetAzureUserPlanRoleCenterId(UserSecurityID);
    end;

    [NonDebuggable]
    procedure DoPlansExist(): Boolean
    var
        Plan: Record Plan;
    begin
        exit(not Plan.IsEmpty());
    end;

    [NonDebuggable]
    procedure DoUserPlansExist(): Boolean
    var
        UserPlan: Record "User Plan";
    begin
        exit(not UserPlan.IsEmpty());
    end;

    [NonDebuggable]
    procedure DoesPlanExist(PlanGUID: Guid): Boolean
    var
        Plan: Record Plan;
    begin
        exit(Plan.Get(PlanGUID));
    end;

    [NonDebuggable]
    procedure DoesUserHavePlans(UserSecurityId: Guid): Boolean
    var
        UserPlan: Record "User Plan";
    begin
        UserPlan.SetRange("User Security ID", UserSecurityId);
        exit(not UserPlan.IsEmpty());
    end;

    [NonDebuggable]
    procedure GetAvailablePlansCount(): Integer
    var
        Plan: Record Plan;
    begin
        exit(Plan.Count());
    end;

    [NonDebuggable]
    procedure SetTestInProgress(EnableTestability: Boolean)
    begin
        IsTest := EnableTestability;
        AzureADGraph.SetTestInProgress(EnableTestability);
        AzureADGraphUser.SetTestInProgress(EnableTestability);
    end;

    [NonDebuggable]
    procedure CheckMixedPlans()
    var
        DummyDictionary: Dictionary of [Text, List of [Text]];
    begin
        CheckMixedPlans(DummyDictionary, false);
    end;

    [NonDebuggable]
    procedure CheckMixedPlans(PlanNamesPerUserFromGraph: Dictionary of [Text, List of [Text]]; ErrorOutForAdmin: Boolean)
    var
        Company: Record Company;
        AzureADPlan: Codeunit "Azure AD Plan";
        EnvironmentInfo: Codeunit "Environment Information";
        CanManageUsers: Boolean;
        UserAuthenticationEmailFirst: Text;
        UserAuthenticationEmailSecond: Text;
        FirstConflictingPlanName: Text;
        SecondConflictingPlanName: Text;
    begin
        if not EnvironmentInfo.IsSaaS() then
            exit;

        if not GuiAllowed() then
            exit;

        if Company.Get(CompanyName()) then
            if Company."Evaluation Company" then
                exit;

        if not DoPlansExist() then
            exit;

        if not DoUserPlansExist() then
            exit;

        Session.LogMessage('0000BPB', CheckingForMixedPlansTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
        if not MixedPlansExist(PlanNamesPerUserFromGraph, UserAuthenticationEmailFirst, UserAuthenticationEmailSecond, FirstConflictingPlanName, SecondConflictingPlanName) then
            exit;

        AzureADPlan.OnCanCurrentUserManagePlansAndGroups(CanManageUsers);
        if not CanManageUsers then
            Error(MixedPlansNonAdminErr, UserAuthenticationEmailFirst, UserAuthenticationEmailSecond);

        if ErrorOutForAdmin then
            Error(MixedPlansAdminErr, UserAuthenticationEmailFirst, UserAuthenticationEmailSecond);

        Message(MixedPlansMsg, UserAuthenticationEmailFirst, UserAuthenticationEmailSecond);
    end;

    [NonDebuggable]
    procedure MixedPlansExist(): Boolean
    var
        EmptyDictionary: Dictionary of [Text, List of [Text]];
        FirstConflictingID: Text;
        SecondConflictingID: Text;
        FirstConflictingPlanName: Text;
        SecondConflictingPlanName: Text;
    begin
        exit(MixedPlansExist(EmptyDictionary, FirstConflictingID, SecondConflictingID, FirstConflictingPlanName, SecondConflictingPlanName));
    end;

    [NonDebuggable]
    procedure MixedPlansExist(PlanNamesPerUserFromGraph: Dictionary of [Text, List of [Text]]; var UserAuthenticationEmailFirstConflicting: Text; var UserAuthenticationEmailSecondConflicting: Text; var FirstConflictingPlanName: Text; var SecondConflictingPlanName: Text): Boolean
    var
        PlanIds: Codeunit "Plan Ids";
        UsersInPlans: Query "Users in Plans";
        PlanNamesPerUser: Dictionary of [Text, List of [Text]];
        AuthenticationObjectIDs: List of [Text];
        BasicPlanExists: Boolean;
        EssentialsPlanExists: Boolean;
        PremiumPlanExists: Boolean;
        PlanNames: List of [Text];
        UserAuthenticationObjectId: Text;
        CurrentUserPlanList: List of [Text];
    begin
        // Get content of the User plan table into a new Dictionary
        UsersInPlans.SetRange(User_State, UsersInPlans.User_State::Enabled);
        if UsersInPlans.Open() then
            while UsersInPlans.Read() do
                if AzureADGraphUser.TryGetUserAuthenticationObjectId(UsersInPlans.User_Security_ID, UserAuthenticationObjectId) then begin
                    if UserAuthenticationObjectId <> '' then begin
                        Clear(CurrentUserPlanList);
                        if PlanNamesPerUser.ContainsKey(UserAuthenticationObjectId) then
                            CurrentUserPlanList := PlanNamesPerUser.Get(UserAuthenticationObjectId);
                        CurrentUserPlanList.Add(UsersInPlans.Plan_Name);
                        PlanNamesPerUser.Set(UserAuthenticationObjectId, CurrentUserPlanList);
                    end;
                end else
                    Session.LogMessage('0000CMW', StrSubstNo(UserDoesNotExistTxt, UsersInPlans.User_Security_ID), Verbosity::Verbose, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', 'UserSetupCategoryTxt');

        // update the dictionary with the values from input
        foreach UserAuthenticationObjectId in PlanNamesPerUserFromGraph.Keys do
            PlanNamesPerUser.Set(UserAuthenticationObjectId, PlanNamesPerUserFromGraph.Get(UserAuthenticationObjectId));

        BasicPlanExists := PlansExist(PlanNamesPerUser, PlanIds.GetBasicPlanId(), AuthenticationObjectIDs, PlanNames);
        EssentialsPlanExists := PlansExist(PlanNamesPerUser, PlanIds.GetEssentialPlanId(), AuthenticationObjectIDs, PlanNames);
        PremiumPlanExists := PlansExist(PlanNamesPerUser, PlanIds.GetPremiumPlanId(), AuthenticationObjectIDs, PlanNames);

        Session.LogMessage('0000BPC', StrSubstNo(MixedPlansExistTxt, BasicPlanExists, EssentialsPlanExists, PremiumPlanExists), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);

        if PlanNames.Count() > 1 then begin
            UserAuthenticationEmailFirstConflicting := GetAuthenticationEmailFromAuthenticationObjectID(AuthenticationObjectIDs.Get(1));
            UserAuthenticationEmailSecondConflicting := GetAuthenticationEmailFromAuthenticationObjectID(AuthenticationObjectIDs.Get(2));
            FirstConflictingPlanName := PlanNames.Get(1);
            SecondConflictingPlanName := PlanNames.Get(2);
            Session.LogMessage('0000BPD', StrSubstNo(UsersWithMixedPlansTxt, AuthenticationObjectIDs.Get(1), AuthenticationObjectIDs.Get(2)), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
            exit(true);
        end;
    end;

    [NonDebuggable]
    local procedure GetAuthenticationEmailFromAuthenticationObjectID(UserAuthenticationObjectID: Text): Text
    var
        User: Record User;
        GraphUserInfo: DotNet UserInfo;
    begin
        if AzureADGraphUser.GetUser(UserAuthenticationObjectID, User) then
            exit(User."Authentication Email")
        else begin
            AzureADGraph.GetUserByObjectId(UserAuthenticationObjectID, GraphUserInfo);
            exit(AzureADGraphUser.GetAuthenticationEmail(GraphUserInfo));
        end;
    end;

    [NonDebuggable]
    local procedure GetPlanName(PlanId: Guid) PlanName: Text
    var
        PlanIds: Codeunit "Plan Ids";
    begin
        case PlanId of
            PlanIds.GetBasicPlanId():
                PlanName := BasicPlanNameTxt;
            PlanIds.GetEssentialPlanId():
                PlanName := EssentialsPlanNameTxt;
            PlanIds.GetPremiumPlanId():
                PlanName := PremiumPlanNameTxt;
        end;
    end;

    [NonDebuggable]
    local procedure PlansExist(var PlanNamesPerUser: Dictionary of [Text, List of [Text]]; PlanId: Guid; var AuthenticationObjectIDs: List of [Text]; var PlanNames: List of [Text]): Boolean
    var
        Plan: Record Plan;
        CurrentAuthenticationObjectId: Text;
        PlanNameList: List of [Text];
        PlanName: Text;
    begin
        if Plan.Get(PlanId) then
            PlanName := Plan.Name
        else
            PlanName := GetPlanName(PlanId);
        foreach CurrentAuthenticationObjectId in PlanNamesPerUser.Keys() do begin
            PlanNameList := PlanNamesPerUser.Get(CurrentAuthenticationObjectId);
            if PlanNameList.Contains(PlanName) then begin
                AuthenticationObjectIDs.Add(CurrentAuthenticationObjectId);
                PlanNames.Add(PlanName);
                exit(true);
            end;
        end;
    end;

    [NonDebuggable]
    local procedure RemoveUnassignedUserPlans(var TempPlan: Record Plan temporary; UserSecurityID: Guid; RemoveUserGroupsOnDeletePlan: Boolean)
    var
        NavUserPlan: Record "User Plan";
        TempNavUserPlan: Record "User Plan" temporary;
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        // Have any plans been removed from this user in O365, since last time he logged-in to Business Central?

        // Get all plans assigned to the user, in NAV
        NavUserPlan.SetRange("User Security ID", UserSecurityID);
        if not NavUserPlan.FindSet() then
            exit;

        repeat
            TempNavUserPlan.COPY(NavUserPlan, FALSE);
            TempNavUserPlan.Insert();
        until NavUserPlan.Next() = 0;

        // Get all plans assigned to the user in Office
        if TempPlan.FindSet() then
            // And remove them from the list of plans assigned to the user
            repeat
                TempNavUserPlan.SetRange("Plan ID", TempPlan."Plan ID");
                if not TempNavUserPlan.IsEmpty() then
                    TempNavUserPlan.DeleteAll();
            until TempPlan.Next() = 0;

        // if any plans belong to the user in NAV, but not in Office, de-assign them
        TempNavUserPlan.SetRange("Plan ID");
        if TempNavUserPlan.FindSet() then
            repeat
                NavUserPlan.SetRange("Plan ID", TempNavUserPlan."Plan ID");
                if NavUserPlan.FindFirst() then begin
                    NavUserPlan.LockTable();
                    NavUserPlan.Delete();
                    if RemoveUserGroupsOnDeletePlan then
                        AzureADPlan.OnRemoveUserGroupsForUserAndPlan(NavUserPlan."Plan ID", NavUserPlan."User Security ID");
                    if not IsTest then
                        Commit(); // Finalize the transaction. Else any further error can rollback and create elevation of privilege
                end;
            until TempNavUserPlan.Next() = 0;
    end;

    [NonDebuggable]
    local procedure GetGraphUserPlans(var TempPlan: Record "Plan" temporary; var GraphUserInfo: DotNet UserInfo)
    var
        AssignedPlan: DotNet ServicePlanInfo;
        DirectoryRole: DotNet RoleInfo;
        ServicePlanIdValue: Variant;
        HaveAssignedPlans: Boolean;
        DevicesPlanId: Guid;
        DevicesPlanName: Text;
        SystemRoleAdded: Boolean;
    begin
        TempPlan.Reset();
        TempPlan.DeleteAll();

        // Loop through assigned Azure AD Plans
        if not IsNull(GraphUserInfo.AssignedPlans()) then
            foreach AssignedPlan in GraphUserInfo.AssignedPlans() do
                if Format(AssignedPlan.CapabilityStatus()) = 'Enabled' then begin
                    ServicePlanIdValue := AssignedPlan.ServicePlanId();
                    if IsBCServicePlan(ServicePlanIdValue) or IsTest then begin
                        HaveAssignedPlans := true;
                        AddToTempPlan(ServicePlanIdValue, Format(AssignedPlan.ServicePlanName()), TempPlan);
                        Session.LogMessage('00009KY', StrSubstNo(UserPlanAssignedMsg, Format(GraphUserInfo.ObjectId()), Format(ServicePlanIdValue)), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                    end;
                end;

        if not HaveAssignedPlans then
            Session.LogMessage('00009KZ', StrSubstNo(UserHasNoPlansMsg, Format(GraphUserInfo.ObjectId())), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);

        // Loop through Azure AD Roles
        if not IsNull(GraphUserInfo.Roles()) then
            foreach DirectoryRole in GraphUserInfo.Roles() do
                if IsBCServicePlan(DirectoryRole.RoleTemplateId()) then begin
                    AddToTempPlan(Format(DirectoryRole.RoleTemplateId()), Format(DirectoryRole.DisplayName()), TempPlan);
                    Session.LogMessage('00009L0', StrSubstNo(UserPlanAssignedMsg, Format(GraphUserInfo.ObjectId()), Format(DirectoryRole.RoleTemplateId())), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                    SystemRoleAdded := true;
                end;

        // If there are no Azure AD Plans and no system roles assigned, then check if its a device user
        if HaveAssignedPlans or SystemRoleAdded then
            exit;

        if IsDeviceRole(GraphUserInfo) then begin
            GetDevicesPlanInfo(DevicesPlanId, DevicesPlanName);
            Session.LogMessage('00009L6', StrSubstNo(DevicePlanFoundMsg, DevicesPlanName, Format(GraphUserInfo.ObjectId())), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
            AddToTempPlan(DevicesPlanId, DevicesPlanName, TempPlan);
        end else
            Session.LogMessage('00009L7', StrSubstNo(NotBCUserMsg, Format(GraphUserInfo.ObjectId())), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
    end;

    [NonDebuggable]
    local procedure IsDeviceRole(var GraphUserInfo: DotNet UserInfo): Boolean
    var
        GroupInfo: DotNet GroupInfo;
    begin
        if IsNull(GraphUserInfo) then
            exit(false);

        if IsNull(GraphUserInfo.Groups()) then
            exit(false);

        foreach GroupInfo in GraphUserInfo.Groups() do
            if not IsNull(GroupInfo.DisplayName()) then
                if GroupInfo.DisplayName().ToUpper() = UpperCase(DeviceGroupNameTxt) then
                    exit(true);
        exit(false);
    end;

    [NonDebuggable]
    local procedure GetDevicesPlanInfo(var PlanId: Guid; var PlanName: Text)
    var
        Plan: Record Plan;
        PlanIds: Codeunit "Plan Ids";
    begin
        PlanId := PlanIds.GetDevicePlanId();
        Plan.Get(PlanIds.GetDevicePlanId());
        PlanName := Plan.Name;
    end;

    [NonDebuggable]
    local procedure InsertFromTempPlan(TempPlan: Record Plan temporary)
    var
        Plan: Record Plan;
    begin
        if not Plan.Get(TempPlan."Plan ID") then begin
            Plan.Copy(TempPlan);
            Plan.Insert();
        end;
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
    procedure IsBCServicePlan(ServicePlanId: Guid): Boolean
    var
        Plan: Record "Plan";
    begin
        if IsNullGuid(ServicePlanId) then
            exit(false);

        exit(Plan.Get(ServicePlanId));
    end;

    [NonDebuggable]
    local procedure GetAzureUserPlanRoleCenterId(UserSecurityID: Guid): Integer
    var
        TempPlan: Record "Plan" temporary;
        User: Record User;
        GraphUserInfo: DotNet UserInfo;
    begin
        if not User.Get(UserSecurityID) then begin
            Session.LogMessage('0000DUD', StrSubstNo(UserNotInUserTableTxt, UserSecurityID()), Verbosity::Warning, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
            exit(0);
        end;

        if not AzureADGraphUser.GetGraphUser(UserSecurityID, GraphUserInfo) then begin
            Session.LogMessage('0000DUE', StrSubstNo(AzureGraphUserNotFoundTxt, UserSecurityID()), Verbosity::Warning, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
            exit(0);
        end;

        GetGraphUserPlans(TempPlan, GraphUserInfo);

        TempPlan.SetFilter("Role Center ID", '<>0');

        if not TempPlan.FindFirst() then begin
            Session.LogMessage('0000DUG', NoPlanHasRoleCenterTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
            exit(0);
        end;

        Session.LogMessage('0000DUC', StrSubstNo(AzurePlanRoleCenterFoundTxt, TempPlan."Role Center ID", UserSecurityID()), Verbosity::Normal,
            DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);

        exit(TempPlan."Role Center ID");
    end;

    [NonDebuggable]
    procedure AssignDelegatedAdminPlanAndUserGroups()
    var
        UserPlan: Record "User Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
        UserPermissions: Codeunit "User Permissions";
        UserGroupsAdded, ShouldRemoveSuper : Boolean;
    begin
        // Have any plans been added to this user in O365, since last time he logged-in to NAV?
        // For each plan assigned to the user in Office
        UserPlan.Init();
        UserPlan."Plan ID" := PlanIds.GetDelegatedAdminPlanId();
        UserPlan."User Security ID" := UserSecurityID();
        UserPlan.Insert();
        AzureADPlan.OnUpdateUserAccessForSaaS(UserPlan."User Security ID", UserGroupsAdded);

        // Remove SUPER from delegated admin only if the plan permssions have been configured and that configuration does not contain SUPER 
        ShouldRemoveSuper := PlanConfigurationImpl.IsCustomized(PlanIds.GetDelegatedAdminPlanId()) and (not PlanConfigurationImpl.ConfigurationContainsSuper(PlanIds.GetDelegatedAdminPlanId()));
        if UserGroupsAdded and ShouldRemoveSuper then begin
            UserPermissions.RemoveSuperPermissions(UserSecurityID());
            Commit();
        end;
    end;

    [NonDebuggable]
    local procedure AddNewlyAssignedUserPlans(var Plan: Record Plan; UserSecurityID: Guid; UserHadBeenSetupBefore: Boolean; AppendPermissionsOnNewPlan: Boolean)
    var
        UserPlan: Record "User Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserPermissions: Codeunit "User Permissions";
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
        UserGroupsAdded, PlanConfigurationContainsSuper, IsPlanConfigurationCustomized, ShouldRemoveSuper : Boolean;
    begin
        // Have any plans been added to this user in O365, since last time he logged-in to NAV?
        // For each plan assigned to the user in Office
        if Plan.FindSet() then
            repeat
                // Does this assignment exist in NAV? If not, add it.
                UserPlan.SetRange("Plan ID", Plan."Plan ID");
                UserPlan.SetRange("User Security ID", UserSecurityID);
                if UserPlan.IsEmpty() then begin
                    InsertFromTempPlan(Plan);
                    UserPlan.LockTable();
                    UserPlan.Init();
                    UserPlan."Plan ID" := Plan."Plan ID";
                    UserPlan."User Security ID" := UserSecurityID;
                    UserPlan.Insert();
                    // The SUPER role is replaced with O365 FULL ACCESS for new users.
                    // This happens only for users who are created from O365 (i.e. are added to plans)
                    if AppendPermissionsOnNewPlan then
                        AzureADPlan.OnUpdateUserAccessForSaaS(UserPlan."User Security ID", UserGroupsAdded);

                    PlanConfigurationContainsSuper := PlanConfigurationContainsSuper or PlanConfigurationImpl.ConfigurationContainsSuper(Plan."Plan ID");
                    IsPlanConfigurationCustomized := IsPlanConfigurationCustomized or PlanConfigurationImpl.IsCustomized(Plan."Plan ID");
                end;
            until Plan.Next() = 0;

        // Only remove SUPER if other permissions are granted (to avoid user lockout)
        if UserGroupsAdded and (not UserHadBeenSetupBefore) then begin
            if IsPlanConfigurationCustomized then
                ShouldRemoveSuper := not PlanConfigurationContainsSuper
            else
                ShouldRemoveSuper := not IsUserAdmin(UserSecurityID);

            if ShouldRemoveSuper then
                UserPermissions.RemoveSuperPermissions(UserSecurityID);
        end;

        if not IsTest then
            Commit(); // Finalize the transaction. Else any further error can rollback and create elevation of privilege
    end;

    [NonDebuggable]
    local procedure AddToTempPlan(ServicePlanId: Guid; ServicePlanName: Text; var TempPlan: Record "Plan" temporary)
    var
        Plan: Record "Plan";
    begin
        WITH TempPlan do begin
            if GET(ServicePlanId) then
                exit;

            if Plan.GET(ServicePlanId) then;

            Init();
            "Plan ID" := ServicePlanId;
            Name := CopyStr(ServicePlanName, 1, MaxStrLen(Name));
            if IsTest then
                "Role Center ID" := 9022
            else
                "Role Center ID" := Plan."Role Center ID";
            Insert();
        end;
    end;

    [NonDebuggable]
    local procedure IsUserAdmin(SecurityID: Guid): Boolean
    var
        PlanIds: Codeunit "Plan Ids";
    begin
        exit(
            IsPlanAssignedToUser(PlanIds.GetInternalAdminPlanId(), SecurityID)
            or IsPlanAssignedToUser(PlanIds.GetDelegatedAdminPlanId(), SecurityID));
    end;

    [NonDebuggable]
    procedure GetPlanIDs(GraphUserInfo: DotNet UserInfo; var PlanIDs: List of [Guid])
    var
        TempPlan: Record Plan temporary;
    begin
        Clear(PlanIDs);
        GetGraphUserPlans(TempPlan, GraphUserInfo);
        if TempPlan.FindSet() then
            repeat
                PlanIDs.Add(TempPlan."Plan ID");
            until TempPlan.Next() = 0;
    end;

    [NonDebuggable]
    procedure GetPlanNames(GraphUserInfo: DotNet UserInfo; var PlanNames: List of [Text])
    var
        TempPlan: Record Plan temporary;
        Plan: Record Plan;
    begin
        Clear(PlanNames);
        GetGraphUserPlans(TempPlan, GraphUserInfo);
        if TempPlan.FindSet() then
            repeat
                // use the Business Central plan name instead of the Office Plan name, if possible.
                if Plan.Get(TempPlan."Plan ID") then begin
                    PlanNames.Add(Plan.Name);
                    Session.LogMessage('0000BK0', StrSubstNo(UserGotPlanTxt, GraphUserInfo.ObjectId(), Plan."Plan ID", Plan.Name), Verbosity::Verbose, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                end else begin
                    PlanNames.Add(TempPlan.Name);
                    Session.LogMessage('0000BK1', StrSubstNo(UserGotPlanTxt, GraphUserInfo.ObjectId(), TempPlan."Plan ID", TempPlan.Name), Verbosity::Verbose, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                end;

            until TempPlan.Next() = 0;
    end;

    [NonDebuggable]
    procedure GetPlanNames(UserSecID: Guid; var PlanNames: List of [Text])
    var
        UserPlan: Record "User Plan";
    begin
        Clear(PlanNames);
        UserPlan.SetRange("User Security ID", UserSecID);
        if UserPlan.FindSet() then
            repeat
                UserPlan.CalcFields("Plan Name");
                PlanNames.Add(UserPlan."Plan Name");
            until UserPlan.Next() = 0;
    end;

    [NonDebuggable]
    procedure CheckIfPlansDifferent(GraphUserInfo: DotNet UserInfo; UserSecID: Guid): Boolean
    var
        TempPlan: Record Plan temporary;
        UserPlan: Record "User Plan";
        Plan: Record Plan;
        UserPlanCount: Integer;
        TempPlanCount: Integer;
    begin
        Session.LogMessage('0000BK2', StrSubstNo(PlansDifferentCheckTxt, GraphUserInfo.ObjectId(), UserSecID), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);

        GetGraphUserPlans(TempPlan, GraphUserInfo);

        UserPlan.SetRange("User Security ID", UserSecID);
        UserPlanCount := UserPlan.Count();
        TempPlanCount := TempPlan.Count();
        if UserPlanCount <> TempPlanCount then begin
            Session.LogMessage('0000BK3', StrSubstNo(PlanCountDifferentTxt, UserPlanCount, TempPlanCount), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
            exit(true);
        end;

        if TempPlan.FindSet() then
            repeat
                if not UserPlan.Get(TempPlan."Plan ID", UserSecID) then begin
                    if Plan.Get(TempPlan."Plan ID") then
                        Session.LogMessage('0000BK4', StrSubstNo(GraphUserHasExtraPlanTxt, TempPlan."Plan ID", Plan.Name), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserSetupCategoryTxt);
                    exit(true);
                end;
            until TempPlan.Next() = 0;
    end;

}

