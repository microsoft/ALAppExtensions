codeunit 31021 "Vendor Ledg. Entry Handler CZZ"
{
    var
        AppliedToAdvanceLetterErr: Label 'The entry is applied to advance letter and cannot be used to applying or unapplying.';

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnApplyVendEntryFormEntryOnAfterCheckEntryOpen', '', false, false)]
    local procedure CheckAdvanceOnApplyVendEntryFormEntryOnAfterCheckEntryOpen(ApplyingVendLedgEntry: Record "Vendor Ledger Entry")
    begin
        if (ApplyingVendLedgEntry."Advance Letter No. CZZ" <> '') or
           (ApplyingVendLedgEntry."Adv. Letter Template Code CZZ" <> '')
        then
            Error(AppliedToAdvanceLetterErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnBeforeUnApplyVendor', '', false, false)]
    local procedure CheckAdvanceOnBeforeUnApplyVendor(DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.Get(DtldVendLedgEntry."Vendor Ledger Entry No.");
        if (VendorLedgerEntry."Advance Letter No. CZZ" <> '') or
           (VendorLedgerEntry."Adv. Letter Template Code CZZ" <> '')
        then
            Error(AppliedToAdvanceLetterErr);
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
