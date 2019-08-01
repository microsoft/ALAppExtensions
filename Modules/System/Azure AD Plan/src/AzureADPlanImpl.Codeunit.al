// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9018 "Azure AD Plan Impl."
{
    Access = Internal;

    Permissions = TableData Plan = rimd,
                  TableData "User Plan" = rimd,
                  TableData User = rimd,
                  TableData "Membership Entitlement" = rimd;

    var
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
        GraphDotNet: DotNet GraphQuery;
        AzureADGraph: Codeunit "Azure AD Graph";
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        IsTest: Boolean;
        UserSetupCategoryTxt: Label 'User Setup', Locked = true;
        DevicePlanFoundMsg: Label 'Device plan %1 found for user %2', Locked = true;
        NotBCUserMsg: Label 'User %1 is not a Business Central user', Locked = true;
        MixedSKUsWithBasicErr: Label 'You cannot mix plans of type Basic, Essential, and Premium. Contact your system administrator or Microsoft partner for assistance.\\You will be logged out when you choose the OK button.';
        MixedSKUsWithoutBasicErr: Label 'You cannot mix plans of type Essential and Premium. Contact your system administrator or Microsoft partner for assistance.\\You will be logged out when you choose the OK button.';
        ChangesInPlansDetectedMsg: Label 'Changes in users plans were detected. Choose the Refresh all User Groups action in the Users window.';
        UserPlanAssignedMsg: Label 'User %1 is assigned plan %2', Locked = true;
        UserHasNoPlansMsg: Label 'User %1 has no Business Central plans assigned', Locked = true;
        NoMixPlans: array[3] of Guid;

    [Scope('OnPrem')]
    procedure IsPlanAssigned(PlanGUID: Guid): Boolean
    var
        UsersInPlans: Query "Users in Plans";
    begin
        UsersInPlans.SetRange(User_State, UsersInPlans.User_State::Enabled);
        UsersInPlans.SetRange(Plan_ID, PlanGUID);

        if UsersInPlans.Open() then
            exit(UsersInPlans.Read());
    end;

    [Scope('OnPrem')]
    procedure IsPlanAssignedToUser(PlanGUID: Guid): Boolean
    var
        UserPlan: Record "User Plan";
    begin
        exit(IsPlanAssignedToUser(PlanGUID, UserSecurityId()));
    end;

    [Scope('OnPrem')]
    procedure IsPlanAssignedToUser(PlanGUID: Guid; UserGUID: Guid): Boolean
    var
        UserPlan: Record "User Plan";
    begin
        UserPlan.SetRange("User Security ID", UserGUID);
        UserPlan.SetRange("Plan ID", PlanGUID);
        exit(not UserPlan.IsEmpty());
    end;

    [Scope('OnPrem')]
    procedure IsGraphUserEntitledFromServicePlan(var GraphUser: DotNet UserInfo): Boolean
    var
        AssignedPlan: DotNet ServicePlanInfo;
        ServicePlanIdValue: Variant;
    begin
        foreach AssignedPlan IN GraphUser.AssignedPlans() do begin
            ServicePlanIdValue := AssignedPlan.ServicePlanId();
            if IsBCServicePlan(ServicePlanIdValue) then
                exit(TRUE);
        end;

        exit(FALSE);
    end;

    [Scope('OnPrem')]
    procedure UpdateUserPlans(UserSecurityId: Guid; var GraphUser: DotNet UserInfo)
    var
        TempO365Plan: Record Plan temporary;
        UserPlan: Record "User Plan";
        HasUserBeenSetupBefore: Boolean;
    begin
        GetGraphUserPlans(TempO365Plan, GraphUser, false);

        // Has the user been setup earlier?
        UserPlan.SetRange("User Security ID", UserSecurityId);
        HasUserBeenSetupBefore := not (UserPlan.IsEmpty() and UserLoginTimeTracker.IsFirstLogin(UserSecurityId));

        // Have any plans been removed from this user in O365, since last time he logged-in to NAV?
        RemoveUnassignedUserPlans(TempO365Plan, UserSecurityId);

        // Have any plans been added to this user in O365, since last time he logged-in to NAV?
        AddNewlyAssignedUserPlans(TempO365Plan, UserSecurityId, HasUserBeenSetupBefore);
    end;

    [Scope('OnPrem')]
    procedure UpdateUserPlans()
    var
        User: Record User;
        GraphUser: DotNet UserInfo;
    begin
        User.SetFilter("License Type", '<>%1', User."License Type"::"External User");
        User.SetFilter("Windows Security ID", '%1', '');

        if not User.FindSet() then
            exit;

        repeat
            if GetGraphUserByObjectId(User."User Security ID", GraphUser) then
                UpdateUserPlans(User."User Security ID", GraphUser);
        until User.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure RefreshUserPlanAssignments(UserSecurityID: Guid)
    var
        User: Record User;
        GraphUser: DotNet UserInfo;
    begin
        if not User.GET(UserSecurityID) then
            exit;

        if not GetGraphUserByObjectId(UserSecurityID, GraphUser) then
            exit;

        UpdateUserFromAzureGraph(User, GraphUser);
        UpdateUserPlans(User."User Security ID", GraphUser);
    end;

    [TryFunction]
    [Scope('OnPrem')]
    procedure TryGetAzureUserPlanRoleCenterId(var RoleCenterID: Integer; UserSecurityID: Guid)
    begin
        RoleCenterID := GetAzureUserPlanRoleCenterId(UserSecurityID);
    end;

    [Scope('OnPrem')]
    procedure DoPlansExist(): Boolean
    var
        Plan: Record Plan;
    begin
        exit(Plan.IsEmpty());
    end;

    [Scope('OnPrem')]
    procedure DoUserPlansExist(): Boolean
    var
        UserPlan: Record "User Plan";
    begin
        exit(UserPlan.IsEmpty());
    end;

    [Scope('OnPrem')]
    procedure DoesPlanExist(PlanGUID: Guid): Boolean
    var
        Plan: Record Plan;
    begin
        exit(Plan.Get(PlanGUID));
    end;

    [Scope('OnPrem')]
    procedure DoesUserHavePlans(UserSecurityId: Guid): Boolean
    var
        UserPlan: Record "User Plan";
    begin
        UserPlan.SetRange("User Security ID", UserSecurityId);
        exit(not UserPlan.IsEmpty());
    end;

    [Scope('OnPrem')]
    procedure GetAvailablePlansCount(): Integer
    var
        Plan: Record Plan;
    begin
        exit(Plan.Count());
    end;

    [Scope('OnPrem')]
    procedure SetTestInProgress(EnableTestability: Boolean)
    begin
        IsTest := EnableTestability;
        AzureADGraph.SetTestInProgress(EnableTestability);
        AzureADGraphUser.SetTestInProgress(EnableTestability);
    end;

    procedure CheckMixedPlans()
    var
        PlanIds: Codeunit "Plan Ids";
        Company: Record Company;
        AzureADPlan: Codeunit "Azure AD Plan";
        EnvironmentInfo: Codeunit "Environment Information";
        CanManage: Boolean;
    begin
        if not EnvironmentInfo.IsSaaS() then
            exit;

        if not GuiAllowed() then
            exit;

        if Company.Get(CompanyName()) then
            if Company."Evaluation Company" then
                exit;

        if DoPlansExist() then
            exit;

        if DoUserPlansExist() then
            exit;

        if not MixedPlansExist() then
            exit;

        AzureADPlan.OnCanCurrentUserManagePlansAndGroups(CanManage);
        if not CanManage then begin
            if PlansExist(PlanIds.GetBasicPlanId()) then
                Error(MixedSKUsWithBasicErr);
            Error(MixedSKUsWithoutBasicErr);
        end;

        Message(ChangesInPlansDetectedMsg);
    end;

    procedure MixedPlansExist(): Boolean
    var
        i: Integer;
    begin
        if IsNullGuid(NoMixPlans[1]) then
            FillNoMixPlans();

        for i := 1 to ArrayLen(NoMixPlans) do begin
            if IsMixedPlan(NoMixPlans[i]) then
                exit(true);
        end;
    end;

    local procedure PlansExist(PlanId: Guid): Boolean
    var
        UsersInPlans: Query "Users in Plans";
    begin
        UsersInPlans.SetRange(User_State, UsersInPlans.User_State::Enabled);
        UsersInPlans.SetRange(Plan_ID, PlanId);

        if UsersInPlans.Open() then
            exit(UsersInPlans.Read());
    end;

    local procedure FillNoMixPlans()
    var
        PlanIds: Codeunit "Plan Ids";
    begin
        NoMixPlans[1] := PlanIds.GetBasicPlanId();
        NoMixPlans[2] := PlanIds.GetEssentialPlanId();
        NoMixPlans[3] := PlanIds.GetPremiumPlanId();
    end;

    local procedure IsMixedPlan(PlanId: Guid): Boolean
    begin
        exit(PlansExist(PlanId) and PlansApartFromExist(PlanId));
    end;

    procedure PlansApartFromExist(PlanId: Guid): Boolean
    var
        i: Integer;
    begin
        if IsNullGuid(NoMixPlans[1]) then
            FillNoMixPlans();

        for i := 1 to ArrayLen(NoMixPlans) do begin
            if (NoMixPlans[i] <> PlanId) and PlansExist(NoMixPlans[i]) then
                exit(true);
        end;
    end;

    local procedure RemoveUnassignedUserPlans(var TempPlan: Record "Plan" temporary; UserSecurityID: Guid)
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
                    AzureADPlan.OnRemoveUserGroupsForUserAndPlan(NavUserPlan."Plan ID", NavUserPlan."User Security ID");
                    if not IsTest then
                        Commit(); // Finalize the transaction. Else any further error can rollback and create elevation of privilege
                end;
            until TempNavUserPlan.Next() = 0;
    end;

    [Scope('OnPrem')]
    local procedure GetGraphUserPlans(var TempPlan: Record "Plan" temporary; var GraphUser: DotNet UserInfo; IncludePlansWithoutEntitlement: Boolean)
    var
        AssignedPlan: DotNet ServicePlanInfo;
        DirectoryRole: DotNet RoleInfo;
        UserRoles: DotNet GenericList1;
        ServicePlanIdValue: Variant;
        IsSystemRole: Boolean;
        HaveAssignedPlans: Boolean;
        DevicesPlanId: Guid;
        DevicesPlanName: Text;
        SystemRoleAdded: Boolean;

    begin
        TempPlan.Reset();
        TempPlan.DeleteAll();

        // Loop through assigned Azure AD Plans
        foreach AssignedPlan in GraphUser.AssignedPlans() do begin
            if AssignedPlan.CapabilityStatus() = 'Enabled' then begin
                ServicePlanIdValue := AssignedPlan.ServicePlanId();
                if IncludePlansWithoutEntitlement or IsBCServicePlan(ServicePlanIdValue) or IsTest then begin
                    HaveAssignedPlans := true;
                    AddToTempPlan(ServicePlanIdValue, AssignedPlan.ServicePlanName(), TempPlan);
                    SendTraceTag('00009KY', UserSetupCategoryTxt, Verbosity::Normal,
                      StrSubstNo(UserPlanAssignedMsg, GraphUser.DisplayName(), ServicePlanIdValue), DataClassification::CustomerContent);
                end;
            end;
        end;

        // If there are no Azure AD Plans, loop through Azure AD Roles
        if not HaveAssignedPlans then
            SendTraceTag('00009KZ', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(UserHasNoPlansMsg, GraphUser.DisplayName()),
                DataClassification::CustomerContent);
            if not IsNull(GraphUser.Roles()) then
                foreach DirectoryRole in GraphUser.Roles() do begin
                    if IncludePlansWithoutEntitlement or IsBCServicePlan(ServicePlanIdValue) then begin
                        AddToTempPlan(DirectoryRole.RoleTemplateId(), DirectoryRole.DisplayName(), TempPlan);
                        SendTraceTag('00009L0', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(UserPlanAssignedMsg, GraphUser.DisplayName(), DirectoryRole.RoleTemplateId()),
                          DataClassification::CustomerContent);
                        SystemRoleAdded := true;
                    end;
                end;

        // If there are no Azure AD Plans and no system roles assigned, then check if its a device user
        if HaveAssignedPlans or SystemRoleAdded then
            exit;

        if IsDeviceRole(GraphUser) then begin
            GetDevicesPlanInfo(DevicesPlanId, DevicesPlanName);
            SendTraceTag('00009L6', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(DevicePlanFoundMsg, DevicesPlanName, GraphUser.DisplayName()), DataClassification::CustomerContent);
            AddToTempPlan(DevicesPlanId, DevicesPlanName, TempPlan);
        end else
            SendTraceTag('00009L7', UserSetupCategoryTxt, Verbosity::Normal, StrSubstNo(NotBCUserMsg, GraphUser.DisplayName()), DataClassification::CustomerContent);
    end;

    local procedure IsDeviceRole(var GraphUser: DotNet UserInfo): Boolean
    var
        GroupInfo: DotNet GroupInfo;
    begin
        if IsNull(GraphUser) then
            exit(false);

        if IsNull(GraphUser.Groups()) then
            exit(false);

        foreach GroupInfo in GraphUser.Groups() do
            if GroupInfo.DisplayName().ToUpper() = 'DYNAMICS 365 BUSINESS CENTRAL DEVICE USERS' then
                exit(true);
        exit(false);
    end;

    local procedure GetDevicesPlanInfo(var PlanId: Guid; var PlanName: Text)
    var
        MembershipEntitlement: Record "Membership Entitlement";
    begin
        MembershipEntitlement.SetRange(Type, MembershipEntitlement.Type::"Azure AD Device Plan");
        if MembershipEntitlement.FindFirst() then begin
            Evaluate(PlanId, MembershipEntitlement.Id);
            PlanName := MembershipEntitlement.Name;
        end;
    end;

    [TryFunction]
    local procedure GetGraphUserByObjectId(UserSecurityID: Guid; var GraphUser: DotNet UserInfo)
    begin
        AzureADGraphUser.SetGraphUser(UserSecurityID);
        AzureADGraphUser.GetGraphUser(GraphUser);
    end;

    local procedure InsertFromTempPlan(var TempPlan: Record Plan temporary)
    var
        Plan: Record Plan;
    begin
        if not Plan.Get(TempPlan."Plan ID") then begin
            Plan.Init();
            Plan.Copy(TempPlan);
            Plan.Insert();
        end;
    end;

    local procedure UpdateUserFromAzureGraph(var User: Record User; var GraphUser: DotNet UserInfo): Boolean
    var
        IsUserModified: Boolean;
    begin
        AzureADGraphUser.SetGraphUser(User."User Security ID");
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User);
        AzureADGraphUser.GetGraphUser(GraphUser);

        exit(IsUserModified);
    end;

    local procedure IsBCServicePlan(ServicePlanId: Guid): Boolean
    var
        Plan: Record "Plan";
        PlanIds: Codeunit "Plan Ids";
        EnvironmentInformation: codeunit "Environment Information";
    //MembershipEntitlement: Record "Membership Entitlement";
    begin
        if ServicePlanId = PlanIds.GetInvoicingPlanId() then
            exit(EnvironmentInformation.IsInvoicing());

        //if IsTest then
        exit(Plan.GET(ServicePlanId));
        //exit(MembershipEntitlement.GET(ServicePlanId.ToString('D')));
    end;

    [Scope('OnPrem')]
    local procedure GetAzureUserPlanRoleCenterId(UserSecurityID: Guid): Integer
    var
        TempPlan: Record "Plan" temporary;
        User: Record User;
        GraphUser: DotNet UserInfo;
    begin
        if not User.GET(UserSecurityID) then
            exit(0);

        if not GetGraphUserByObjectId(UserSecurityID, GraphUser) then
            exit(0);

        GetGraphUserPlans(TempPlan, GraphUser, FALSE);

        TempPlan.SetFilter("Role Center ID", '<>0');

        if not TempPlan.FindFirst() then
            exit(0);

        exit(TempPlan."Role Center ID");
    end;

    local procedure AddNewlyAssignedUserPlans(var TempO365Plan: Record Plan temporary; UserSecurityID: Guid; UserHadBeenSetupBefore: Boolean)
    var
        UserPlan: Record "User Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserPermissions: Codeunit "User Permissions";
        UserGroupsAdded: Boolean;
    begin
        // Have any plans been added to this user in O365, since last time he logged-in to NAV?
        // For each plan assigned to the user in Office
        if TempO365Plan.FindSet() then
            repeat
                // Does this assignment exist in NAV? If not, add it.
                UserPlan.SetRange("Plan ID", TempO365Plan."Plan ID");
                UserPlan.SetRange("User Security ID", UserSecurityID);
                if UserPlan.IsEmpty() then begin
                    InsertFromTempPlan(TempO365Plan);
                    UserPlan.LockTable();
                    UserPlan.Init();
                    UserPlan."Plan ID" := TempO365Plan."Plan ID";
                    UserPlan."User Security ID" := UserSecurityID;
                    UserPlan.Insert();
                    // The SUPER role is replaced with O365 FULL ACCESS for new users.
                    // This happens only for users who are created from O365 (i.e. are added to plans)
                    AzureADPlan.OnUpdateUserAccessForSaaS(UserPlan."User Security ID", UserGroupsAdded);
                end;
            until TempO365Plan.Next() = 0;

        // Only remove SUPER if other permissions are granted (to avoid user lockout)
        if UserGroupsAdded then begin
            if not UserHadBeenSetupBefore then
                if not IsUserAdmin(UserSecurityID) then
                    UserPermissions.RemoveSuperPermissions(UserSecurityID);
            if not IsTest then
                Commit(); // Finalize the transaction. Else any further error can rollback and create elevation of priviledge
        end;
    end;

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

    local procedure IsUserAdmin(SecurityID: Guid): Boolean
    var
        PlanIds: Codeunit "Plan Ids";
    begin
        exit(
            IsPlanAssignedToUser(PlanIds.GetInternalAdminPlanId(), SecurityID)
            or IsPlanAssignedToUser(PlanIds.GetDelegatedAdminPlanId(), SecurityID));
    end;
}

