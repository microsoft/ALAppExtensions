// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Adds plans to the Plan table.
/// </summary>
codeunit 9056 "Plan Installer"
{
    Subtype = Install;
    Permissions = tabledata "Plan" = ri,
                  tabledata "Plan Configuration" = ri;

    trigger OnInstallAppPerDatabase()
    begin
        CreatePlans();

        CreateDefaultPlanConfigurations();
    end;

    local procedure CreatePlans()
    var
        PlanIds: Codeunit "Plan Ids";
        UpgradeTag: Codeunit "Upgrade Tag";
        PlanUpgradeTag: Codeunit "Plan Upgrade Tag";
    begin
        CreatePlan(PlanIds.GetDelegatedAdminPlanId(), 'Delegated Admin agent - Partner', 9022, '7584DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetHelpDeskPlanId(), 'Delegated Helpdesk agent - Partner', 9022, '8884DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('62E90394-69F5-4237-9190-012177145E10', 'Internal Administrator', 9022, '9B84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetEssentialISVPlanId(), 'Dynamics 365 Business Central Essential - Embedded', 9022, '2E84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetTeamMemberPlanId(), 'Dynamics 365 Business Central Team Member', 9028, '5784DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetPremiumPlanId(), 'Dynamics 365 Business Central Premium', 9022, '3884DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetBasicFinancialsISVPlanId(), 'D365 Business Central Basic Financials', 9022, '4C84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetEssentialPlanId(), 'Dynamics 365 Business Central Essential', 9022, '2484DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan('996DEF3D-B36C-4153-8607-A6FD3C01B89F', 'D365 Business Central Infrastructure', 9022, 'A684DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetAccountantHubPlanId(), 'Microsoft Dynamics 365 - Accountant Hub', 1151, '6684DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetDevicePlanId(), 'Dynamics 365 Business Central Device - Embedded', 9022, 'AC84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetTeamMemberISVPlanId(), 'D365 Business Central Team Member - Embedded', 9028, '5E84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetExternalAccountantPlanId(), 'Dynamics 365 Business Central External Accountant', 9027, '1A84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetPremiumISVPlanId(), 'Dynamics 365 Business Central Premium - Embedded', 9022, '4284DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetDeviceISVPlanId(), 'Dynamics 365 Business Central Device - Embedded', 9022, 'B684DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetViralSignupPlanId(), 'Dynamics 365 Business Central for IWs', 9022, '0184DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetPremiumPartnerSandboxPlanId(), 'Dynamics 365 BC Premium Partner Sandbox', 9022, '37B1C04B-A429-4139-A15E-067784A80A55');

        if not UpgradeTag.HasUpgradeTag(PlanUpgradeTag.GetAddDeviceISVEmbUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(PlanUpgradeTag.GetAddDeviceISVEmbUpgradeTag());
    end;

    local procedure CreatePlan(PlanGuid: Guid; PlanName: Text[50]; RoleCenterId: Integer; SystemId: Guid)
    var
        Plan: Record Plan;
    begin
        if Plan.Get(PlanGuid) then
            exit;

        Plan.Init();
        Plan."Plan ID" := PlanGuid;
        Plan.Name := PlanName;
        Plan."Role Center ID" := RoleCenterId;
        Plan.SystemId := SystemId;
        Plan.Insert(true);
    end;

    local procedure CreateDefaultPlanConfigurations()
    var
        PlanConfiguration: Record "Plan Configuration";
        Plan: Query Plan;
    begin
        if Plan.Open() then
            while Plan.Read() do begin
                PlanConfiguration.SetRange("Plan ID", Plan.Plan_ID);
                if not PlanConfiguration.FindFirst() then begin
                    PlanConfiguration.Init();
                    PlanConfiguration."Plan ID" := Plan.Plan_ID;
                    PlanConfiguration."Plan Name" := Plan.Plan_Name;
                    PlanConfiguration.Insert();
                end;

                Clear(PlanConfiguration);
            end;
    end;
}