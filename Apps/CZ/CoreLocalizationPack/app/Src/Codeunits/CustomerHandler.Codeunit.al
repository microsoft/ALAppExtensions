codeunit 11752 "Customer Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', false, false)]
    local procedure InitValueOnAfterInsertEvent(var Rec: Record Customer)
    begin
        Rec."Allow Multiple Posting Groups" := true;
    end;

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
#if not CLEAN20
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeCheckAllowMultiplePostingGroups', '', false, false)]
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
#if not CLEAN22
#pragma warning disable AL0432
        if not GenJournalLine.IsReplaceVATDateEnabled() then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
        CustLedgerEntry."VAT Date CZL" := GenJournalLine."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust. Entry-Edit", 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure UpdateEntryOnBeforeCustLedgEntryModify(var CustLedgEntry: Record "Cust. Ledger Entry"; FromCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgEntry."Specific Symbol CZL" := FromCustLedgEntry."Specific Symbol CZL";
        CustLedgEntry."Variable Symbol CZL" := FromCustLedgEntry."Variable Symbol CZL";
        CustLedgEntry."Constant Symbol CZL" := FromCustLedgEntry."Constant Symbol CZL";
        CustLedgEntry."Bank Account Code CZL" := FromCustLedgEntry."Bank Account Code CZL";
        CustLedgEntry."Bank Account No. CZL" := FromCustLedgEntry."Bank Account No. CZL";
        CustLedgEntry."Transit No. CZL" := FromCustLedgEntry."Transit No. CZL";
        CustLedgEntry."IBAN CZL" := FromCustLedgEntry."IBAN CZL";
        CustLedgEntry."SWIFT Code CZL" := FromCustLedgEntry."SWIFT Code CZL";
        CustLedgEntry."VAT Date CZL" := FromCustLedgEntry."VAT Date CZL";
    end;
}
