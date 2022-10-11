// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN21
codeunit 40026 "Upgrade BaseApp 21x"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by code that invokes the actual upgrade from each of the apps';
    ObsoleteTag = '21.0';

    trigger OnRun()
    begin
        // This code is based on standard app upgrade logic.
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnUpgradeNonCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradeNonCompanyUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 21.0 then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradePerCompanyDataUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 21.0 then
            exit;

        UpgradeCRMUnitGroupMapping();
        UpgradeCRMSDK90ToCRMSDK91();
        FillItemChargeAssignmentQtyToHandle();
        UseCustomLookupInPrices();
        UpgradeAccountSchedulesToFinancialReports();
    end;

    local procedure UpgradeCRMUnitGroupMapping()
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetCRMUnitGroupMappingUpgradeTag()) then
            exit;

        if not CRMConnectionSetup.Get() then
            exit;

        if IntegrationTableMapping.Get('UNIT GROUP') then begin
            CRMConnectionSetup."Unit Group Mapping Enabled" := true;
            CRMConnectionSetup.Modify();
        end;

        CRMIntegrationManagement.UpdateItemUnitGroup();
        CRMIntegrationManagement.UpdateResourceUnitGroup();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetCRMUnitGroupMappingUpgradeTag());
    end;

    local procedure UpgradeCRMSDK90ToCRMSDK91()
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        CRMConnectionSetup: Record "CRM Connection Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetCRMSDK90UpgradeTag()) then
            exit;

        if CRMConnectionSetup.Get() then
            if CRMConnectionSetup."Proxy Version" = 9 then begin
                CRMConnectionSetup."Proxy Version" := 91;
                CRMConnectionSetup.Modify();
            end;

        if CDSConnectionSetup.Get() then
            if CDSConnectionSetup."Proxy Version" = 9 then begin
                CDSConnectionSetup."Proxy Version" := 91;
                CDSConnectionSetup.Modify();
            end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetCRMSDK90UpgradeTag());
    end;

    local procedure FillItemChargeAssignmentQtyToHandle()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetItemChargeHandleQtyUpgradeTag()) then
            exit;

        ItemChargeAssignmentPurch.SetFilter("Qty. to Assign", '>0');
        if ItemChargeAssignmentPurch.FindSet(true) then
            repeat
                ItemChargeAssignmentPurch."Qty. to Handle" := ItemChargeAssignmentPurch."Qty. to Assign";
                ItemChargeAssignmentPurch."Amount to Handle" := ItemChargeAssignmentPurch."Amount to Assign";
                ItemChargeAssignmentPurch.Modify();
            until ItemChargeAssignmentPurch.Next() = 0;

        ItemChargeAssignmentSales.SetFilter("Qty. to Assign", '>0');
        if ItemChargeAssignmentSales.FindSet(true) then
            repeat
                ItemChargeAssignmentSales."Qty. to Handle" := ItemChargeAssignmentSales."Qty. to Assign";
                ItemChargeAssignmentSales."Amount to Handle" := ItemChargeAssignmentSales."Amount to Assign";
                ItemChargeAssignmentSales.Modify();
            until ItemChargeAssignmentSales.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetItemChargeHandleQtyUpgradeTag());
    end;

    local procedure UseCustomLookupInPrices()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetUseCustomLookupUpgradeTag()) then
            exit;

        if SalesReceivablesSetup.Get() and not SalesReceivablesSetup."Use Customized Lookup" then
            if PriceCalculationMgt.FindActiveSubscriptions() <> '' then begin
                SalesReceivablesSetup.Validate("Use Customized Lookup", true);
                SalesReceivablesSetup.Modify();
            end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetUseCustomLookupUpgradeTag());
    end;

    [Scope('OnPrem')]
    local procedure UpgradeAccountSchedulesToFinancialReports()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        FinancialReport: Record "Financial Report";
        FinancialReportMgt: Codeunit "Financial Report Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        AnythingModified: Boolean;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetAccountSchedulesToFinancialReportsUpgradeTag()) then
            exit;
        if not GeneralLedgerSetup.Get() then
            exit;
        FinancialReportMgt.Initialize();
        if not (GeneralLedgerSetup."Acc. Sched. for Balance Sheet" = '') then
            if FinancialReport.Get(GeneralLedgerSetup."Acc. Sched. for Balance Sheet") then
                if GeneralLedgerSetup."Fin. Rep. for Balance Sheet" = '' then begin
                    GeneralLedgerSetup."Fin. Rep. for Balance Sheet" := GeneralLedgerSetup."Acc. Sched. for Balance Sheet";
                    AnythingModified := true;
                end;
        if not (GeneralLedgerSetup."Acc. Sched. for Cash Flow Stmt" = '') then
            if FinancialReport.Get(GeneralLedgerSetup."Acc. Sched. for Cash Flow Stmt") then
                if GeneralLedgerSetup."Fin. Rep. for Cash Flow Stmt" = '' then begin
                    GeneralLedgerSetup."Fin. Rep. for Cash Flow Stmt" := GeneralLedgerSetup."Acc. Sched. for Cash Flow Stmt";
                    AnythingModified := true;
                end;
        if not (GeneralLedgerSetup."Acc. Sched. for Income Stmt." = '') then
            if FinancialReport.Get(GeneralLedgerSetup."Acc. Sched. for Income Stmt.") then
                if GeneralLedgerSetup."Fin. Rep. for Income Stmt." = '' then begin
                    GeneralLedgerSetup."Fin. Rep. for Income Stmt." := GeneralLedgerSetup."Acc. Sched. for Income Stmt.";
                    AnythingModified := true;
                end;
        if not (GeneralLedgerSetup."Acc. Sched. for Retained Earn." = '') then
            if FinancialReport.Get(GeneralLedgerSetup."Acc. Sched. for Retained Earn.") then
                if GeneralLedgerSetup."Fin. Rep. for Retained Earn." = '' then begin
                    GeneralLedgerSetup."Fin. Rep. for Retained Earn." := GeneralLedgerSetup."Acc. Sched. for Retained Earn.";
                    AnythingModified := true;
                end;
        if AnythingModified then
            GeneralLedgerSetup.Modify();
        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetAccountSchedulesToFinancialReportsUpgradeTag());
    end;

}
#endif