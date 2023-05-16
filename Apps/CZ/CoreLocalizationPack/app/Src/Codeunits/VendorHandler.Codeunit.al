codeunit 11753 "Vendor Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterInsertEvent', '', false, false)]
    local procedure InitValueOnAfterInsertEvent(var Rec: Record Vendor)
    begin
        Rec."Allow Multiple Posting Groups" := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteRegistrationLogCZLOnAfterDelete(var Rec: Record Vendor)
    var
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        UnreliablePayerEntryCZL.SetRange("Vendor No.", Rec."No.");
        UnreliablePayerEntryCZL.DeleteAll(true);
        RegistrationLogMgtCZL.DeleteVendorLog(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'Vendor Posting Group', false, false)]
    local procedure CheckChangeVendorPostingGroupOnAfterVendorPostingGroupValidate(var Rec: Record Vendor)
    begin
        Rec.CheckVendorLedgerOpenEntriesCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeIsContactUpdateNeeded', '', false, false)]
    local procedure CheckChangeOnBeforeIsContactUpdateNeeded(Vendor: Record Vendor; xVendor: Record Vendor; var UpdateNeeded: Boolean)
    begin
        UpdateNeeded := UpdateNeeded or
            (Vendor."Registration No. CZL" <> xVendor."Registration No. CZL") or
            (Vendor."Tax Registration No. CZL" <> xVendor."Tax Registration No. CZL");
    end;
#if not CLEAN20
    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeCheckAllowMultiplePostingGroups', '', false, false)]
    local procedure SuppressCheckAllowMultiplePostingGroupsOnBeforeCheckAllowMultiplePostingGroups(var IsHandled: Boolean)
    var
#pragma warning disable AL0432
        PostingGroupManagementCZL: Codeunit "Posting Group Management CZL";
#pragma warning restore AL0432
    begin
        if IsHandled then
            exit;
        IsHandled := not PostingGroupManagementCZL.IsAllowMultipleCustVendPostingGroupsEnabled();
    end;
#endif

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateEntryOnAfterCopyVendorLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VendorLedgerEntry."Specific Symbol CZL" := GenJournalLine."Specific Symbol CZL";
        VendorLedgerEntry."Variable Symbol CZL" := GenJournalLine."Variable Symbol CZL";
        VendorLedgerEntry."Constant Symbol CZL" := GenJournalLine."Constant Symbol CZL";
        VendorLedgerEntry."Bank Account Code CZL" := GenJournalLine."Bank Account Code CZL";
        VendorLedgerEntry."Bank Account No. CZL" := GenJournalLine."Bank Account No. CZL";
        VendorLedgerEntry."Transit No. CZL" := GenJournalLine."Transit No. CZL";
        VendorLedgerEntry."IBAN CZL" := GenJournalLine."IBAN CZL";
        VendorLedgerEntry."SWIFT Code CZL" := GenJournalLine."SWIFT Code CZL";
#if not CLEAN22
#pragma warning disable AL0432
        if not GenJournalLine.IsReplaceVATDateEnabled() then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
        VendorLedgerEntry."VAT Date CZL" := GenJournalLine."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure UpdateEntryOnBeforeVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry"; FromVendLedgEntry: Record "Vendor Ledger Entry")
    begin
        VendLedgEntry."Specific Symbol CZL" := FromVendLedgEntry."Specific Symbol CZL";
        VendLedgEntry."Variable Symbol CZL" := FromVendLedgEntry."Variable Symbol CZL";
        VendLedgEntry."Constant Symbol CZL" := FromVendLedgEntry."Constant Symbol CZL";
        VendLedgEntry."Bank Account Code CZL" := FromVendLedgEntry."Bank Account Code CZL";
        VendLedgEntry."Bank Account No. CZL" := FromVendLedgEntry."Bank Account No. CZL";
        VendLedgEntry."Transit No. CZL" := FromVendLedgEntry."Transit No. CZL";
        VendLedgEntry."IBAN CZL" := FromVendLedgEntry."IBAN CZL";
        VendLedgEntry."SWIFT Code CZL" := FromVendLedgEntry."SWIFT Code CZL";
        VendLedgEntry."VAT Date CZL" := FromVendLedgEntry."VAT Date CZL";
    end;
}
