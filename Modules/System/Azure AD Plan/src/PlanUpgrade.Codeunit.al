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

    trigger OnUpgradePerDatabase()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        PlanUpgradeTag: Codeunit "Plan Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(PlanUpgradeTag.GetAddDeviceISVEmbUpgradeTag()) then
            exit;

        UpdateSubscriptionPlan();

        UpgradeTag.SetUpgradeTag(PlanUpgradeTag.GetAddDeviceISVEmbUpgradeTag());
    end;

    local procedure UpdateSubscriptionPlan()
    var
        Plan: Record "Plan";
        PlanIds: Codeunit "Plan Ids";
        PlanId: Guid;
        PlanName: Text[50];
        RoleCenterId: Integer;
    begin
        PlanId := PlanIds.GetDeviceISVPlanId();
        PlanName := 'Dynamics 365 Business Central Device - Embedded';
        RoleCenterId := 9022; // PAGE::"Business Manager Role Center"

        if Plan.get(PlanId) then
            exit;

        CreatePlan(PlanId, PlanName, RoleCenterId);

        SendTraceTag('00001PS', 'AL SaaS Upgrade', VERBOSITY::Normal, StrSubstNo('Subscription Plan %1 was added', PlanId));
    end;

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