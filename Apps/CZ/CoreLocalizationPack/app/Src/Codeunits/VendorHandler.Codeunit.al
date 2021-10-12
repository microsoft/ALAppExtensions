codeunit 11753 "Vendor Handler CZL"
{
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
        VendorLedgerEntry."VAT Date CZL" := GenJournalLine."VAT Date CZL";
    end;
}