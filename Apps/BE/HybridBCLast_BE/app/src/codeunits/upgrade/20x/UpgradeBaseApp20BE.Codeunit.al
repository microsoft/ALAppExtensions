// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN20
codeunit 40022 "Upgrade BaseApp 20 BE"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '20.0';

    trigger OnRun()
    begin
    end;

    var
        NoOfRecordsInTableMsg: Label 'Table %1, number of records to upgrade: %2', Comment = '%1- table id, %2 - number of records';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 20.0 then
            exit;

        UpgradeCustomerVATLiable();
        UpgradeGLEntryJournalTemplateName();
        UpgradeGLRegisterJournalTemplateName();
        UpgradeVATEntryJournalTemplateName();
        UpgradeCustLedgEntryPmtDiscountPossible();
        UpgradeVendLedgEntryPmtDiscountPossible();
    end;

    local procedure UpgradeCustomerVATLiable()
    var
        Customer: Record Customer;
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetCustomerVATLiableTag()) THEN
            exit;

        Customer.ModifyAll("VAT Liable", true, false);

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetCustomerVATLiableTag());
    end;

    local procedure UpgradeGLEntryJournalTemplateName()
    var
        GLEntry: Record "G/L Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetGLEntryJournalTemplateNameUpgradeTag()) then
            exit;

        GLEntry.SetLoadFields("Journal Templ. Name", "Journal Template Name");
        GLEntry.SetFilter("Journal Template Name", '<>%1', '');
        GLEntry.SetRange("Journal Templ. Name", '');
        if EnvironmentInformation.IsSaaS() then
            if LogTelemetryForManyRecords(Database::"G/L Entry", GLEntry.Count()) then
                exit;
        if GLEntry.FindSet() then
            repeat
                GLEntry."Journal Templ. Name" := GLEntry."Journal Template Name";
                GLEntry.Modify();
            until GLEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetGLEntryJournalTemplateNameUpgradeTag());
    end;

    local procedure UpgradeGLRegisterJournalTemplateName()
    var
        GLRegister: Record "G/L Register";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetGLRegisterJournalTemplateNameUpgradeTag()) then
            exit;

        GLRegister.SetLoadFields("Journal Templ. Name", "Journal Template Name");
        GLRegister.SetFilter("Journal Template Name", '<>%1', '');
        GLRegister.SetRange("Journal Templ. Name", '');
        if EnvironmentInformation.IsSaaS() then
            if LogTelemetryForManyRecords(Database::"G/L Register", GLRegister.Count()) then
                exit;
        if GLRegister.FindSet() then
            repeat
                GLRegister."Journal Templ. Name" := GLRegister."Journal Template Name";
                GLRegister.Modify();
            until GLRegister.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetGLRegisterJournalTemplateNameUpgradeTag());
    end;

    local procedure UpgradeVATEntryJournalTemplateName()
    var
        VATEntry: Record "VAT Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetVATEntryJournalTemplateNameUpgradeTag()) then
            exit;

        VATEntry.SetLoadFields("Journal Templ. Name", "Journal Template Name");
        VATEntry.SetFilter("Journal Template Name", '<>%1', '');
        VATEntry.SetRange("Journal Templ. Name", '');
        if EnvironmentInformation.IsSaaS() then
            if LogTelemetryForManyRecords(Database::"VAT Entry", VATEntry.Count()) then
                exit;
        if VATEntry.FindSet() then
            repeat
                VATEntry."Journal Templ. Name" := VATEntry."Journal Template Name";
                VATEntry.Modify();
            until VATEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetVATEntryJournalTemplateNameUpgradeTag());
    end;

    local procedure UpgradeCustLedgEntryPmtDiscountPossible()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetCustLedgerEntryPmtDiscPossibleUpgradeTag()) then
            exit;

        CustLedgerEntry.SetLoadFields("Orig. Pmt. Disc. Possible(LCY)", "Org. Pmt. Disc. Possible (LCY)");
        CustLedgerEntry.SetFilter("Org. Pmt. Disc. Possible (LCY)", '<>%1', 0);
        CustLedgerEntry.SetRange("Orig. Pmt. Disc. Possible(LCY)", 0);
        if EnvironmentInformation.IsSaaS() then
            if LogTelemetryForManyRecords(Database::"Cust. Ledger Entry", CustLedgerEntry.Count()) then
                exit;
        if CustLedgerEntry.FindSet() then
            repeat
                CustLedgerEntry."Orig. Pmt. Disc. Possible(LCY)" := CustLedgerEntry."Org. Pmt. Disc. Possible (LCY)";
                CustLedgerEntry.Modify();
            until CustLedgerEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetCustLedgerEntryPmtDiscPossibleUpgradeTag());
    end;

    local procedure UpgradeVendLedgEntryPmtDiscountPossible()
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetVendLedgerEntryPmtDiscPossibleUpgradeTag()) then
            exit;

        VendLedgerEntry.SetLoadFields("Orig. Pmt. Disc. Possible(LCY)", "Org. Pmt. Disc. Possible (LCY)");
        VendLedgerEntry.SetFilter("Org. Pmt. Disc. Possible (LCY)", '<>%1', 0);
        VendLedgerEntry.SetRange("Orig. Pmt. Disc. Possible(LCY)", 0);
        if EnvironmentInformation.IsSaaS() then
            if LogTelemetryForManyRecords(Database::"Vendor Ledger Entry", VendLedgerEntry.Count()) then
                exit;
        if VendLedgerEntry.FindSet() then
            repeat
                VendLedgerEntry."Orig. Pmt. Disc. Possible(LCY)" := VendLedgerEntry."Org. Pmt. Disc. Possible (LCY)";
                VendLedgerEntry.Modify();
            until VendLedgerEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetVendLedgerEntryPmtDiscPossibleUpgradeTag());
    end;

    local procedure UpgradeGenJournalLinePmtDiscountPossible()
    var
        GenJournalLine: Record "Gen. Journal Line";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetGenJournalLinePmtDiscPossibleUpgradeTag()) then
            exit;

        GenJournalLine.SetLoadFields(
            "Orig. Pmt. Disc. Possible", "Orig. Pmt. Disc. Possible(LCY)",
            "Original Pmt. Disc. Possible", "Org. Pmt. Disc. Possible (LCY)");
        GenJournalLine.SetFilter("Org. Pmt. Disc. Possible (LCY)", '<>%1', 0);
        GenJournalLine.SetRange("Orig. Pmt. Disc. Possible(LCY)", 0);
        if EnvironmentInformation.IsSaaS() then
            if LogTelemetryForManyRecords(Database::"Gen. Journal Line", GenJournalLine.Count()) then
                exit;
        if GenJournalLine.FindSet() then
            repeat
                GenJournalLine."Orig. Pmt. Disc. Possible" := GenJournalLine."Original Pmt. Disc. Possible";
                GenJournalLine."Orig. Pmt. Disc. Possible(LCY)" := GenJournalLine."Org. Pmt. Disc. Possible (LCY)";
                GenJournalLine.Modify();
            until GenJournalLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetGenJournalLinePmtDiscPossibleUpgradeTag());
    end;

    local procedure LogTelemetryForManyRecords(TableNo: Integer; NoOfRecords: Integer): Boolean;
    begin
        Session.LogMessage(
            '0000G46', StrSubstNo(NoOfRecordsInTableMsg, TableNo, NoOfRecords),
            Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', 'AL SaaS Upgrade');
        exit(NoOfRecords > GetSafeRecordCountForSaaSUpgrade());
    end;

    local procedure GetSafeRecordCountForSaaSUpgrade(): Integer
    begin
        exit(300000);
    end;
}
#endif