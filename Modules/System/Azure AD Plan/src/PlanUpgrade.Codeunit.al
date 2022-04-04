// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Codeunit to upgrade the Plan table.
/// </summary>
codeunit 9057 "Plan Upgrade"
{
    Subtype = Upgrade;
    Permissions = tabledata Plan = rimd;

    var
        SubscriptionPlanMsg: Label 'Subscription Plan %1 was added', Comment = '%1 - Plan Id', Locked = true;

    trigger OnUpgradePerDatabase()
    begin
        UpdateSubscriptionPlan();
        RenamePlansAndDeleteOldPlans();
        RenameTeamMemberPlan();
        RenameDevicePlan();
        AddPremiumPartnerSandbox();
    end;

    [NonDebuggable]
    local procedure UpdateSubscriptionPlan()
    var
        Plan: Record "Plan";
        UpgradeTag: Codeunit "Upgrade Tag";
        PlanUpgradeTag: Codeunit "Plan Upgrade Tag";
        PlanIds: Codeunit "Plan Ids";
        PlanId: Guid;
        PlanName: Text[50];
        RoleCenterId: Integer;
    begin
        if UpgradeTag.HasUpgradeTag(PlanUpgradeTag.GetAddDeviceISVEmbUpgradeTag()) then
            exit;

        PlanId := PlanIds.GetDeviceISVPlanId();
        PlanName := 'Dynamics 365 Business Central Device - Embedded';
        RoleCenterId := 9022; // PAGE::"Business Manager Role Center"

        if Plan.get(PlanId) then
            exit;

        CreatePlan(PlanId, PlanName, RoleCenterId);

        Session.LogMessage('00001PS', StrSubstNo(SubscriptionPlanMsg, PlanId), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', 'AL SaaS Upgrade');

        UpgradeTag.SetUpgradeTag(PlanUpgradeTag.GetAddDeviceISVEmbUpgradeTag());
    end;

    [NonDebuggable]
    local procedure RenamePlansAndDeleteOldPlans()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        PlanUpgradeTag: Codeunit "Plan Upgrade Tag";
        PlanIds: Codeunit "Plan Ids";
    begin
        if UpgradeTag.HasUpgradeTag(PlanUpgradeTag.GetRenamePlansUpgradeTag()) then
            exit;

        RenameOrCreatePlan(PlanIds.GetEssentialISVPlanId(), 'Dynamics 365 Business Central Essential - Embedded');
        RenameOrCreatePlan(PlanIds.GetTeamMemberPlanId(), 'Dynamics 365 Business Central Team Member');
        RenameOrCreatePlan(PlanIds.GetPremiumPlanId(), 'Dynamics 365 Business Central Premium');
        RenameOrCreatePlan(PlanIds.GetBasicFinancialsISVPlanId(), 'Dynamics 365 Business Central Basic Financials');
        RenameOrCreatePlan(PlanIds.GetEssentialPlanId(), 'Dynamics 365 Business Central Essential');
        RenameOrCreatePlan(PlanIds.GetAccountantHubPlanId(), 'Microsoft Dynamics 365 - Accountant Hub');
        RenameOrCreatePlan(PlanIds.GetDevicePlanId(), 'Dynamics 365 Business Central Device');
        RenameOrCreatePlan(PlanIds.GetTeamMemberISVPlanId(), 'D365 Business Central Team Member - Embedded');
        RenameOrCreatePlan(PlanIds.GetExternalAccountantPlanId(), 'Dynamics 365 Business Central External Accountant');
        RenameOrCreatePlan(PlanIds.GetPremiumISVPlanId(), 'Dynamics 365 Business Central Premium - Embedded');
        RenameOrCreatePlan(PlanIds.GetViralSignupPlanId(), 'Dynamics 365 Business Central for IWs');
        RenameOrCreatePlan(PlanIds.GetDelegatedAdminPlanId(), 'Delegated Admin agent - Partner');
        RenameOrCreatePlan(PlanIds.GetHelpDeskPlanId(), 'Delegated Helpdesk agent - Partner');
        RenameOrCreatePlan('996DEF3D-B36C-4153-8607-A6FD3C01B89F', 'D365 Business Central Infrastructure');


        DeletePlan('07EB0DC4-7DA7-4E7B-BB42-2D44C5E08B08');
        DeletePlan('39B5C996-467E-4E60-BD62-46066F572726');
        DeletePlan('9695F925-27A8-4127-98C7-3CAAC1809758');
        DeletePlan('46764787-E039-4AB0-8F00-820FC2D89BF9');
        DeletePlan('312BDEEE-8FBD-496E-B529-EB985F305FCF');

        Session.LogMessage('0000AHN', 'Subscription Plans were renamed and old plans werer deleted.', Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', 'AL SaaS Upgrade');

        UpgradeTag.SetUpgradeTag(PlanUpgradeTag.GetRenamePlansUpgradeTag());
    end;

    [NonDebuggable]
    local procedure RenameTeamMemberPlan()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        PlanUpgradeTag: Codeunit "Plan Upgrade Tag";
        PlanIds: Codeunit "Plan Ids";
    begin
        if UpgradeTag.HasUpgradeTag(PlanUpgradeTag.GetRenameTeamMemberPlanUpgradeTag()) then
            exit;

        RenameOrCreatePlan(PlanIds.GetTeamMemberPlanId(), 'Dynamics 365 Business Central Team Member');

        UpgradeTag.SetUpgradeTag(PlanUpgradeTag.GetRenameTeamMemberPlanUpgradeTag());
    end;

    [NonDebuggable]
    local procedure RenameDevicePlan()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        PlanUpgradeTag: Codeunit "Plan Upgrade Tag";
        PlanIds: Codeunit "Plan Ids";
    begin
        if UpgradeTag.HasUpgradeTag(PlanUpgradeTag.GetRenameDevicePlanUpgradeTag()) then
            exit;

        RenameOrCreatePlan(PlanIds.GetDevicePlanId(), 'Dynamics 365 Business Central Device - Embedded');

        UpgradeTag.SetUpgradeTag(PlanUpgradeTag.GetRenameDevicePlanUpgradeTag());
    end;

    [NonDebuggable]
    local procedure AddPremiumPartnerSandbox()
    var
        Plan: Record "Plan";
        UpgradeTag: Codeunit "Upgrade Tag";
        PlanUpgradeTag: Codeunit "Plan Upgrade Tag";
        PlanIds: Codeunit "Plan Ids";
        PlanId: Guid;
        PlanName: Text[50];
        RoleCenterId: Integer;
    begin
        if UpgradeTag.HasUpgradeTag(PlanUpgradeTag.GetPremiumPartnerSandboxUpgradeTag()) then
            exit;

        PlanId := PlanIds.GetPremiumPartnerSandboxPlanId();
        PlanName := 'Dynamics 365 BC Premium Partner Sandbox';
        RoleCenterId := 9022; // PAGE::"Business Manager Role Center"

        if Plan.Get(PlanId) then
            exit;

        CreatePlan(PlanId, PlanName, RoleCenterId);

        UpgradeTag.SetUpgradeTag(PlanUpgradeTag.GetPremiumPartnerSandboxUpgradeTag());
    end;

    [NonDebuggable]
    local procedure DeletePlan(PlanId: guid)
    var
        Plan: Record "Plan";
    begin
        if Plan.Get(PlanId) then
            Plan.Delete();
    end;

    [NonDebuggable]
    local procedure RenameOrCreatePlan(PlanId: guid; NewName: Text)
    var
        Plan: Record "Plan";
    begin
        if Plan.Get(PlanId) then begin
            Plan.Name := CopyStr(NewName, 1, 50);
            Plan.Modify();
        end else
            CreatePlan(PlanId, CopyStr(NewName, 1, 50), 0);
    end;

    [NonDebuggable]
    local procedure CreatePlan(PlanGuid: Guid; PlanName: Text[50]; RoleCenterId: Integer)
    var
        Plan: Record Plan;
    begin
        Plan."Plan ID" := PlanGuid;
        Plan.Name := PlanName;
        Plan."Role Center ID" := RoleCenterId;
        Plan.Insert(true);
    end;
}