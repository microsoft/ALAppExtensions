codeunit 31008 "Sales-Post Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure SalesPostOnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
    begin
        if (not SalesHeader.Invoice) or (not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice])) then
            exit;

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            SalesAdvLetterManagement.CheckAdvancePayement("Adv. Letter Usage Doc.Type CZZ"::"Sales Order", SalesHeader."No.")
        else
            SalesAdvLetterManagement.CheckAdvancePayement("Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure SalesPostOnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
        AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ";
    begin
        if (not SalesHeader.Invoice) or (not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice])) then
            exit;

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            AdvLetterUsageDocTypeCZZ := AdvLetterUsageDocTypeCZZ::"Sales Order"
        else
            AdvLetterUsageDocTypeCZZ := AdvLetterUsageDocTypeCZZ::"Sales Invoice";

        CustLedgerEntry.Get(SalesInvoiceHeader."Cust. Ledger Entry No.");
        SalesAdvLetterManagement.PostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ, SalesHeader."No.", SalesInvoiceHeader, CustLedgerEntry, GenJnlPostLine, false);
        SalesAdvLetterManagement.CorrectDocumentAfterPaymentUsage(SalesInvoiceHeader."No.", CustLedgerEntry, GenJnlPostLine);

        if not SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then begin
            AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales);
            AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
            AdvanceLetterApplicationCZZ.SetRange("Document No.", SalesHeader."No.");
            AdvanceLetterApplicationCZZ.DeleteAll(true);
        end;
    end;
}