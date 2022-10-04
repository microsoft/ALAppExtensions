codeunit 31004 "Cust. Ledger Entry Handler CZZ"
{
    var
        AppliedToAdvanceLetterErr: Label 'The entry is applied to advance letter and cannot be used to applying or unapplying.';

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure CustLedgerEntryOnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."Advance Letter No. CZZ" := GenJournalLine."Adv. Letter No. (Entry) CZZ";
        CustLedgerEntry."Adv. Letter Template Code CZZ" := GenJournalLine."Adv. Letter Template Code CZZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnIsRelatedToAdvanceLetterCZL', '', false, false)]
    local procedure GetOnIsRelatedToAdvanceLetterCZL(CustLedgerEntry: Record "Cust. Ledger Entry"; var IsRelatedToAdvanceLetter: Boolean)
    begin
        IsRelatedToAdvanceLetter := IsRelatedToAdvanceLetter or (CustLedgerEntry."Advance Letter No. CZZ" <> '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Journal Line Handler CZL", 'OnBeforeGetReceivablesAccountNo', '', false, false)]
    local procedure GetReceivablesAccountNo(CustLedgerEntry: Record "Cust. Ledger Entry"; var GLAccountNo: Code[20]; var IsHandled: Boolean)
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
    begin
        if CustLedgerEntry."Advance Letter No. CZZ" = '' then
            exit;

        SalesAdvLetterHeaderCZZ.Get(CustLedgerEntry."Advance Letter No. CZZ");
        SalesAdvLetterHeaderCZZ.TestField("Advance Letter Code");
        AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Sales);
        AdvanceLetterTemplateCZZ.TestField("Advance Letter G/L Account");
        GLAccountNo := AdvanceLetterTemplateCZZ."Advance Letter G/L Account";
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnApplyCustEntryFormEntryOnAfterCheckEntryOpen', '', false, false)]
    local procedure CheckAdvanceOnApplyCustEntryFormEntryOnAfterCheckEntryOpen(ApplyingCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        if (ApplyingCustLedgEntry."Advance Letter No. CZZ" <> '') or
           (ApplyingCustLedgEntry."Adv. Letter Template Code CZZ" <> '')
        then
            Error(AppliedToAdvanceLetterErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnPostUnApplyCustomerCommitOnAfterGetCustLedgEntry', '', false, false)]
    local procedure CheckAdvanceOnPostUnApplyCustomerCommitOnAfterGetCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        if (CustLedgerEntry."Advance Letter No. CZZ" <> '') or
           (CustLedgerEntry."Adv. Letter Template Code CZZ" <> '')
        then
            Error(AppliedToAdvanceLetterErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnBeforeUnApplyCustomer', '', false, false)]
    local procedure CheckAdvanceOnBeforeUnApplyCustomer(DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.Get(DtldCustLedgEntry."Cust. Ledger Entry No.");
        if (CustLedgerEntry."Advance Letter No. CZZ" <> '') or
           (CustLedgerEntry."Adv. Letter Template Code CZZ" <> '')
        then
            Error(AppliedToAdvanceLetterErr);
    end;
#if not CLEAN19
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnBeforeCalcLinkAdvAmount', '', false, false)]
#pragma warning restore AL0432
    local procedure ResetAmountOnBeforeCalcLinkAdvAmount(var Amount: Decimal; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        Amount := 0;
        IsHandled := true;
    end;
#endif
}
