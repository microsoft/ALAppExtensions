codeunit 11752 "Customer Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteRegistrationLogCZLOnAfterDelete(var Rec: Record Customer)
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        RegistrationLogMgtCZL.DeleteCustomerLog(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Customer Posting Group', false, false)]
    local procedure CheckChangeCustomerPostingGroupOnAfterCustomerPostingGroupValidate(var Rec: Record Customer)
    begin
        Rec.CheckOpenCustomerLedgerEntriesCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeIsContactUpdateNeeded', '', false, false)]
    local procedure CheckChangeOnBeforeIsContactUpdateNeeded(Customer: Record Customer; xCustomer: Record Customer; var UpdateNeeded: Boolean)
    begin
        UpdateNeeded := UpdateNeeded or
            (Customer."Registration No. CZL" <> xCustomer."Registration No. CZL") or
            (Customer."Tax Registration No. CZL" <> xCustomer."Tax Registration No. CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateEntryOnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."Specific Symbol CZL" := GenJournalLine."Specific Symbol CZL";
        CustLedgerEntry."Variable Symbol CZL" := GenJournalLine."Variable Symbol CZL";
        CustLedgerEntry."Constant Symbol CZL" := GenJournalLine."Constant Symbol CZL";
        CustLedgerEntry."Bank Account Code CZL" := GenJournalLine."Bank Account Code CZL";
        CustLedgerEntry."Bank Account No. CZL" := GenJournalLine."Bank Account No. CZL";
        CustLedgerEntry."Transit No. CZL" := GenJournalLine."Transit No. CZL";
        CustLedgerEntry."IBAN CZL" := GenJournalLine."IBAN CZL";
        CustLedgerEntry."SWIFT Code CZL" := GenJournalLine."SWIFT Code CZL";
        CustLedgerEntry."VAT Date CZL" := GenJournalLine."VAT Date CZL";
    end;
}