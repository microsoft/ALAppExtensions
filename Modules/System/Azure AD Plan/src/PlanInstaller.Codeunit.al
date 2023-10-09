// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

using System.Upgrade;

/// <summary>
/// Adds plans to the Plan table.
/// </summary>
codeunit 9056 "Plan Installer"
{
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Plan" = ri;

    trigger OnInstallAppPerDatabase()
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        CreatePlans();

        PlanConfigurationImpl.CreateDefaultPlanConfigurations();
    end;

    local procedure CreatePlans()
    var
        PlanIds: Codeunit "Plan Ids";
        UpgradeTag: Codeunit "Upgrade Tag";
        PlanUpgradeTag: Codeunit "Plan Upgrade Tag";
    begin
        CreatePlan(PlanIds.GetDelegatedAdminPlanId(), 'Delegated Admin agent - Partner', 9022, '7584DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetHelpDeskPlanId(), 'Delegated Helpdesk agent - Partner', 9022, '8884DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetGlobalAdminPlanId(), 'Internal Administrator', 9022, '9B84DDCA-27B8-E911-BB26-000D3A2B005C'); // Global admin
        CreatePlan(PlanIds.GetD365AdminPlanId(), 'Dynamics 365 Administrator', 9022, 'F67B9B96-C667-4DD2-B370-FA065A895C9D');
        CreatePlan(PlanIds.GetEssentialISVPlanId(), 'Dynamics 365 Business Central Essential - Embedded', 9022, '2E84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetTeamMemberPlanId(), 'Dynamics 365 Business Central Team Member', 9028, '5784DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetMicrosoft365PlanId(), 'Microsoft 365', 8999, '57ff2da0-773e-42df-b2af-ffb7a2317929');
        CreatePlan(PlanIds.GetPremiumPlanId(), 'Dynamics 365 Business Central Premium', 9022, '3884DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetBasicFinancialsISVPlanId(), 'D365 Business Central Basic Financials', 9022, '4C84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetEssentialPlanId(), 'Dynamics 365 Business Central Essential', 9022, '2484DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetInfrastructurePlanId(), 'D365 Business Central Infrastructure', 9022, 'A684DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetAccountantHubPlanId(), 'Microsoft Dynamics 365 - Accountant Hub', 1151, '6684DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetDevicePlanId(), 'Dynamics 365 Business Central Device - Embedded', 9022, 'AC84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetTeamMemberISVPlanId(), 'D365 Business Central Team Member - Embedded', 9028, '5E84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetExternalAccountantPlanId(), 'Dynamics 365 Business Central External Accountant', 9027, '1A84DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetPremiumISVPlanId(), 'Dynamics 365 Business Central Premium - Embedded', 9022, '4284DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetDeviceISVPlanId(), 'Dynamics 365 Business Central Device - Embedded', 9022, 'B684DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetViralSignupPlanId(), 'Dynamics 365 Business Central for IWs', 9022, '0184DDCA-27B8-E911-BB26-000D3A2B005C');
        CreatePlan(PlanIds.GetPremiumPartnerSandboxPlanId(), 'Dynamics 365 BC Premium Partner Sandbox', 9022, '37B1C04B-A429-4139-A15E-067784A80A55');
        CreatePlan(PlanIds.GetEssentialAttachPlanId(), 'Dynamics 365 Business Central Essential - Attach', 9022, 'CB848855-EC98-4C23-B3A4-B2ECAE138FA2');

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
}