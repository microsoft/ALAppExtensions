codeunit 31021 "Vendor Ledg. Entry Handler CZZ"
{
    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure VendorLedgerEntryOnAfterCopyVendLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        VendorLedgerEntry."Advance Letter No. CZZ" := GenJournalLine."Adv. Letter No. (Entry) CZZ";
        if VendorLedgerEntry."Advance Letter No. CZZ" <> '' then begin
            PurchAdvLetterHeaderCZZ.Get(VendorLedgerEntry."Advance Letter No. CZZ");
            VendorLedgerEntry."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Journal Line Handler CZL", 'OnBeforeGetPayablesAccountNo', '', false, false)]
    local procedure GetPayablesAccountNo(VendorLedgerEntry: Record "Vendor Ledger Entry"; var GLAccountNo: Code[20]; var IsHandled: Boolean)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        if VendorLedgerEntry."Advance Letter No. CZZ" = '' then
            exit;
        if not AdvancePaymentsMgtCZZ.IsEnabled() then
            exit;

        PurchAdvLetterHeaderCZZ.Get(VendorLedgerEntry."Advance Letter No. CZZ");
        PurchAdvLetterHeaderCZZ.TestField("Advance Letter Code");
        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Purchase);
        AdvanceLetterTemplateCZZ.TestField("Advance Letter G/L Account");
        GLAccountNo := AdvanceLetterTemplateCZZ."Advance Letter G/L Account";
        IsHandled := true;
    end;
#if not CLEAN19
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnBeforeCalcLinkAdvAmount', '', false, false)]
#pragma warning restore AL0432
    local procedure ResetAmountOnBeforeCalcLinkAdvAmount(var Amount: Decimal; var IsHandled: Boolean)
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        if IsHandled then
            exit;
        if not AdvancePaymentsMgtCZZ.IsEnabled() then
            exit;

        Amount := 0;
        IsHandled := true;
    end;
#endif
}
