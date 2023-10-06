codeunit 31126 "VAT Rep. Date Mgt. Handler CZP"
{
    Access = Internal;
    Permissions = tabledata "Posted Cash Document Hdr. CZP" = m;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Reporting Date Mgt", 'OnAfterUpdateLinkedEntries', '', false, false)]
    local procedure UpdatePostedCashDocumentOnAfterUpdateLinkedEntries(VATEntry: Record "VAT Entry")
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        PostedCashDocumentHdr: Record "Posted Cash Document Hdr. CZP";
    begin
        if not FindBankAccountLedgerEntry(VATEntry, BankAccountLedgerEntry) then
            exit;
        if not PostedCashDocumentHdr.Get(BankAccountLedgerEntry."Bank Account No.", BankAccountLedgerEntry."Document No.") then
            exit;
        if PostedCashDocumentHdr."VAT Date" <> VATEntry."VAT Reporting Date" then begin
            PostedCashDocumentHdr."VAT Date" := VATEntry."VAT Reporting Date";
            PostedCashDocumentHdr.Modify();
        end;
    end;

    local procedure FindBankAccountLedgerEntry(VATEntry: Record "VAT Entry"; var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"): Boolean
    begin
        BankAccountLedgerEntry.SetLoadFields("Bank Account No.", "Document No.");
        BankAccountLedgerEntry.SetCurrentKey("Document No.", "Posting Date");
        BankAccountLedgerEntry.SetRange("Document No.", VATEntry."Document No.");
        BankAccountLedgerEntry.SetRange("Posting Date", VATEntry."Posting Date");
        BankAccountLedgerEntry.SetRange("Transaction No.", VATEntry."Transaction No.");
        exit(BankAccountLedgerEntry.FindFirst());
    end;
}