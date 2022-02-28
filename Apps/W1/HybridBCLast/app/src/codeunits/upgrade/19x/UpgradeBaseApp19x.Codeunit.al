// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN19
codeunit 4058 "Upgrade BaseApp 19x"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '19.0';

    trigger OnRun()
    begin
        // This code is based on standard app upgrade logic.
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnUpgradeNonCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradeNonCompanyUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 19.0 then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradePerCompanyDataUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 19.0 then
            exit;

        UpgradeIntegrationTableMapping();
        AddPowerBIWorkspaces();
        UpgradeRemoveSmartListGuidedExperience();
        UpgradeCRMIntegrationRecord();
        UpdatePriceSourceGroupInPriceListLines();
        UpdatePriceListLineStatus();
        UpgradeDimensionSetEntry();
        UpgradeAPIs();
    end;

    local procedure UpgradeAPIs()
    begin
        UpgradeSalesCreditMemoReasonCode();
        UpgradeSalesOrderShortcutDimension();
        UpgradeSalesQuoteShortcutDimension();
        UpgradeSalesInvoiceShortcutDimension();
        UpgradeSalesCrMemoShortcutDimension();
        UpgradePurchaseOrderShortcutDimension();
        UpgradePurchInvoiceShortcutDimension();
    end;

    local procedure UpdatePriceSourceGroupInPriceListLines()
    var
        PriceListLine: Record "Price List Line";
        EnvironmentInformation: Codeunit "Environment Information";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetPriceSourceGroupUpgradeTag()) then
            exit;
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetPriceSourceGroupFixedUpgradeTag()) then
            exit;

        PriceListLine.SetRange("Source Group", "Price Source Group"::All);
        if EnvironmentInformation.IsSaaS() then
            if PriceListLine.Count() > GetSafeRecordCountForSaaSUpgrade() then
                exit;
        if PriceListLine.FindSet(true) then
            repeat
                if PriceListLine."Source Type" in
                    ["Price Source Type"::"All Jobs",
                    "Price Source Type"::Job,
                    "Price Source Type"::"Job Task"]
                then
                    PriceListLine."Source Group" := "Price Source Group"::Job
                else
                    case PriceListLine."Price Type" of
                        "Price Type"::Purchase:
                            PriceListLine."Source Group" := "Price Source Group"::Vendor;
                        "Price Type"::Sale:
                            PriceListLine."Source Group" := "Price Source Group"::Customer;
                    end;
                if PriceListLine."Source Group" <> "Price Source Group"::All then
                    if PriceListLine.Status = "Price Status"::Active then begin
                        PriceListLine.Status := "Price Status"::Draft;
                        PriceListLine.Modify();
                        PriceListLine.Status := "Price Status"::Active;
                        PriceListLine.Modify();
                    end else
                        PriceListLine.Modify();
            until PriceListLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetPriceSourceGroupFixedUpgradeTag());
    end;

    local procedure UpdatePriceListLineStatus()
    var
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        EnvironmentInformation: Codeunit "Environment Information";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        Status: Enum "Price Status";
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetPriceSourceGroupUpgradeTag()) then
            exit;
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetSyncPriceListLineStatusUpgradeTag()) then
            exit;

        PriceListLine.SetRange(Status, "Price Status"::Draft);
        if EnvironmentInformation.IsSaaS() then
            if PriceListLine.Count() > GetSafeRecordCountForSaaSUpgrade() then
                exit;
        if PriceListLine.Findset(true) then
            repeat
                if PriceListHeader.Code <> PriceListLine."Price List Code" then
                    if PriceListHeader.Get(PriceListLine."Price List Code") then
                        Status := PriceListHeader.Status
                    else
                        Status := Status::Draft;
                if Status = Status::Active then begin
                    PriceListLine.Status := Status::Active;
                    PriceListLine.Modify();
                end;
            until PriceListLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetSyncPriceListLineStatusUpgradeTag());
    end;

    local procedure UpgradeIntegrationTableMapping()
    begin
        UpgradeIntegrationTableMappingUncoupleCodeunitId();
        UpgradeIntegrationTableMappingCouplingCodeunitId();
        UpgradeIntegrationTableMappingFilterForOpportunities();
    end;

    local procedure UpgradeIntegrationTableMappingUncoupleCodeunitId()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetIntegrationTableMappingUpgradeTag()) then
            exit;

        IntegrationTableMapping.SetRange("Uncouple Codeunit ID", 0);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetFilter(Direction, '%1|%2',
            IntegrationTableMapping.Direction::ToIntegrationTable,
            IntegrationTableMapping.Direction::Bidirectional);
        IntegrationTableMapping.SetFilter("Integration Table ID", '%1|%2|%3|%4|%5|%6|%7|%8',
            Database::"CRM Account",
            Database::"CRM Contact",
            Database::"CRM Invoice",
            Database::"CRM Quote",
            Database::"CRM Salesorder",
            Database::"CRM Opportunity",
            Database::"CRM Product",
            Database::"CRM Productpricelevel");
        IntegrationTableMapping.ModifyAll("Uncouple Codeunit ID", Codeunit::"CDS Int. Table Uncouple");

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetIntegrationTableMappingUpgradeTag());
    end;

    local procedure UpgradeIntegrationTableMappingCouplingCodeunitId()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetIntegrationTableMappingCouplingCodeunitIdUpgradeTag()) then
            exit;

        IntegrationTableMapping.SetRange("Coupling Codeunit ID", 0);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetFilter("Integration Table ID", '%1|%2|%3|%4|%5|%6',
            Database::"CRM Account",
            Database::"CRM Contact",
            Database::"CRM Opportunity",
            Database::"CRM Product",
            Database::"CRM Uomschedule",
            Database::"CRM Transactioncurrency");
        IntegrationTableMapping.ModifyAll("Coupling Codeunit ID", Codeunit::"CDS Int. Table Couple");

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetIntegrationTableMappingCouplingCodeunitIdUpgradeTag());
    end;

    local procedure UpgradeIntegrationTableMappingFilterForOpportunities()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        Opportunity: Record Opportunity;
        CRMSetupDefaults: Codeunit "CRM Setup Defaults";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        OldTableFilter: Text;
        NewTableFilter: Text;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetIntegrationTableMappingFilterForOpportunitiesUpgradeTag()) then
            exit;

        IntegrationTableMapping.SetRange(Name, 'OPPORTUNITY');
        IntegrationTableMapping.SetRange("Table ID", Database::Opportunity);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::"CRM Opportunity");
        if IntegrationTableMapping.FindFirst() then begin
            OldTableFilter := IntegrationTableMapping.GetTableFilter();
            if OldTableFilter = '' then begin
                Opportunity.SetFilter(Status, '%1|%2', Opportunity.Status::"Not Started", Opportunity.Status::"In Progress");
                NewTableFilter := CRMSetupDefaults.GetTableFilterFromView(Database::Opportunity, Opportunity.TableCaption(), Opportunity.GetView());
                IntegrationTableMapping.SetTableFilter(NewTableFilter);
                IntegrationTableMapping.Modify();
            end;
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetIntegrationTableMappingFilterForOpportunitiesUpgradeTag());
    end;

    local procedure UpgradeCRMIntegrationRecord()
    begin
        SetCoupledFlags();
    end;

    local procedure SetCoupledFlags()
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        EnvironmentInformation: Codeunit "Environment Information";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetSetCoupledFlagsUpgradeTag()) then
            exit;

        if EnvironmentInformation.IsSaaS() then
            if CRMIntegrationRecord.Count() > GetSafeRecordCountForSaaSUpgrade() then
                exit;

        if CRMIntegrationRecord.FindSet() then
            repeat
                CRMIntegrationManagement.SetCoupledFlag(CRMIntegrationRecord, true)
            until CRMIntegrationRecord.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetSetCoupledFlagsUpgradeTag());
    end;

    local procedure AddPowerBIWorkspaces()
    var
        PowerBIReportConfiguration: Record "Power BI Report Configuration";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        PowerBIWorkspaceMgt: Codeunit "Power BI Workspace Mgt.";
        EmptyGuid: Guid;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetPowerBIWorkspacesUpgradeTag()) then
            exit;

        PowerBIReportConfiguration.SetRange("Workspace Name", '');
        PowerBIReportConfiguration.SetRange("Workspace ID", EmptyGuid);

        if PowerBIReportConfiguration.FindSet() then
            PowerBIReportConfiguration.ModifyAll("Workspace Name", PowerBIWorkspaceMgt.GetMyWorkspaceLabel());

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetPowerBIWorkspacesUpgradeTag());
    end;

    local procedure UpgradeDimensionSetEntry()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionSetEntry: Record "Dimension Set Entry";
        EnvironmentInformation: Codeunit "Environment Information";
        UpdateDimSetGlblDimNo: Codeunit "Update Dim. Set Glbl. Dim. No.";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetDimSetEntryGlobalDimNoUpgradeTag()) THEN
            exit;

        if GeneralLedgerSetup.Get() then begin
            if EnvironmentInformation.IsSaaS() then
                if DimensionSetEntry.Count() > GetSafeRecordCountForSaaSUpgrade() then
                    exit;

            if UpgradeDimensionSetEntryIsHandled() then
                exit;
            UpdateDimSetGlblDimNo.BlankGlobalDimensionNo();
            UpdateDimSetGlblDimNo.SetGlobalDimensionNos(GeneralLedgerSetup);
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetDimSetEntryGlobalDimNoUpgradeTag());
    end;

    local procedure UpgradeDimensionSetEntryIsHandled() IsHandled: Boolean;
    begin
        // If you have extended the table "Dimension Set Entry", ModifyAll calls in Codeunit "Update Dim. Set Glbl. Dim. No." 
        // can lead to the whole upgrade failed by time out. 
        // Subscribe to OnUpgradeDimensionSetEntry and return IsHandled as true to skip the "Dimension Set Entry" update. 
        // After upgrade is done you can run the same update by report 482 "Update Dim. Set Glbl. Dim. No.".
        OnUpgradeDimensionSetEntry(IsHandled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpgradeDimensionSetEntry(var IsHandled: Boolean)
    begin
    end;

    procedure UpgradeSalesCreditMemoReasonCode()
    var
        APIDataUpgrade: Codeunit "API Data Upgrade";
    begin
        APIDataUpgrade.UpgradeSalesCreditMemoReasonCode(true);
    end;

    local procedure UpgradeSalesInvoiceShortcutDimension()
    var
        APIDataUpgrade: Codeunit "API Data Upgrade";
    begin
        APIDataUpgrade.UpgradeSalesInvoiceShortcutDimension(true);
    end;

    local procedure UpgradePurchInvoiceShortcutDimension()
    var
        APIDataUpgrade: Codeunit "API Data Upgrade";
    begin
        APIDataUpgrade.UpgradePurchInvoiceShortcutDimension(true)
    end;

    local procedure UpgradePurchaseOrderShortcutDimension()
    var
        APIDataUpgrade: Codeunit "API Data Upgrade";
    begin
        APIDataUpgrade.UpgradePurchaseOrderShortcutDimension(true);
    end;

    local procedure UpgradeSalesOrderShortcutDimension()
    var
        APIDataUpgrade: Codeunit "API Data Upgrade";
    begin
        APIDataUpgrade.UpgradeSalesOrderShortcutDimension(true);
    end;

    local procedure UpgradeSalesQuoteShortcutDimension()
    var
        APIDataUpgrade: Codeunit "API Data Upgrade";
    begin
        APIDataUpgrade.UpgradeSalesQuoteShortcutDimension(true);
    end;

    local procedure UpgradeSalesCrMemoShortcutDimension()
    var
        APIDataUpgrade: Codeunit "API Data Upgrade";
    begin
        APIDataUpgrade.UpgradeSalesCrMemoShortcutDimension(true);
    end;

    local procedure UpdateSalesDocumentShortcutDimensionFields(var SourceRecordRef: RecordRef; var TargetRecordRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
        ShortcutDim1SourceFieldRef: FieldRef;
        ShortcutDim2SourceFieldRef: FieldRef;
        ShortcutDimension1: Code[20];
        ShortcutDimension2: Code[20];
        Modified: Boolean;
    begin
        ShortcutDim1SourceFieldRef := SourceRecordRef.Field(SalesHeader.FieldNo("Shortcut Dimension 1 Code"));
        ShortcutDim2SourceFieldRef := SourceRecordRef.Field(SalesHeader.FieldNo("Shortcut Dimension 2 Code"));
        ShortcutDimension1 := ShortcutDim1SourceFieldRef.Value();
        ShortcutDimension2 := ShortcutDim2SourceFieldRef.Value();
        if ShortcutDimension1 <> '' then
            if CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FieldNo("Shortcut Dimension 1 Code")) then
                Modified := true;
        if ShortcutDimension2 <> '' then
            if CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FieldNo("Shortcut Dimension 2 Code")) then
                Modified := true;
        if Modified then
            TargetRecordRef.Modify();
    end;

    local procedure UpdatePurchaseDocumentShortcutDimensionFields(var SourceRecordRef: RecordRef; var TargetRecordRef: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
        ShortcutDim1SourceFieldRef: FieldRef;
        ShortcutDim2SourceFieldRef: FieldRef;
        ShortcutDimension1: Code[20];
        ShortcutDimension2: Code[20];
        Modified: Boolean;
    begin
        ShortcutDim1SourceFieldRef := SourceRecordRef.Field(PurchaseHeader.FieldNo("Shortcut Dimension 1 Code"));
        ShortcutDim2SourceFieldRef := SourceRecordRef.Field(PurchaseHeader.FieldNo("Shortcut Dimension 2 Code"));
        ShortcutDimension1 := ShortcutDim1SourceFieldRef.Value();
        ShortcutDimension2 := ShortcutDim2SourceFieldRef.Value();
        if ShortcutDimension1 <> '' then
            if CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FieldNo("Shortcut Dimension 1 Code")) then
                Modified := true;
        if ShortcutDimension2 <> '' then
            if CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FieldNo("Shortcut Dimension 2 Code")) then
                Modified := true;
        if Modified then
            TargetRecordRef.Modify();
    end;

    local procedure UpgradeRemoveSmartListGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetRemoveSmartListManualSetupEntryUpgradeTag()) THEN
            exit;

        // Page 889 is Page::"SmartList Designer Setup"
        if GuidedExperience.Exists(Enum::"Guided Experience Type"::"Manual Setup", ObjectType::Page, 889) then
            GuidedExperience.Remove(Enum::"Guided Experience Type"::"Manual Setup", ObjectType::Page, 889);

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetRemoveSmartListManualSetupEntryUpgradeTag());
    end;

    local procedure CopyFieldValue(var SourceRecordRef: RecordRef; var TargetRecordRef: RecordRef; FieldNo: Integer): Boolean
    var
        SourceFieldRef: FieldRef;
        TargetFieldRef: FieldRef;
    begin
        SourceFieldRef := SourceRecordRef.FIELD(FieldNo);
        TargetFieldRef := TargetRecordRef.FIELD(FieldNo);
        IF TargetFieldRef.VALUE <> SourceFieldRef.VALUE THEN BEGIN
            TargetFieldRef.VALUE := SourceFieldRef.VALUE;
            exit(true);
        END;
        exit(false);
    end;

    local procedure GetSafeRecordCountForSaaSUpgrade(): Integer
    begin
        exit(300000);
    end;
}
#endif