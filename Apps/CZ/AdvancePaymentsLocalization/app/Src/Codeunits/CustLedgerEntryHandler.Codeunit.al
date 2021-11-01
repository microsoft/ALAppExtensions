codeunit 31004 "Cust. Ledger Entry Handler CZZ"
{
    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure CustLedgerEntryOnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        CustLedgerEntry."Advance Letter No. CZZ" := GenJournalLine."Adv. Letter No. (Entry) CZZ";
        if CustLedgerEntry."Advance Letter No. CZZ" <> '' then begin
            SalesAdvLetterHeaderCZZ.Get(CustLedgerEntry."Advance Letter No. CZZ");
            CustLedgerEntry."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Journal Line Handler CZL", 'OnBeforeGetReceivablesAccountNo', '', false, false)]
    local procedure GetReceivablesAccountNo(CustLedgerEntry: Record "Cust. Ledger Entry"; var GLAccountNo: Code[20]; var IsHandled: Boolean)
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        if CustLedgerEntry."Advance Letter No. CZZ" = '' then
            exit;
        if not AdvancePaymentsMgtCZZ.IsEnabled() then
            exit;

        SalesAdvLetterHeaderCZZ.Get(CustLedgerEntry."Advance Letter No. CZZ");
        SalesAdvLetterHeaderCZZ.TestField("Advance Letter Code");
        AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Sales);
        AdvanceLetterTemplateCZZ.TestField("Advance Letter G/L Account");
        GLAccountNo := AdvanceLetterTemplateCZZ."Advance Letter G/L Account";
        IsHandled := true;
    end;
#if not CLEAN19
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnBeforeCalcLinkAdvAmount', '', false, false)]
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
