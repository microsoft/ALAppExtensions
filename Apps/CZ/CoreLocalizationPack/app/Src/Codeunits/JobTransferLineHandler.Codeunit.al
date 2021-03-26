codeunit 31026 "Job Transfer Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Transfer Line", 'OnAfterFromPlanningSalesLineToJnlLine', '', false, false)]
    local procedure SetCorrectionOnAfterFromPlanningSalesLineToJnlLine(var JobJnlLine: Record "Job Journal Line"; JobPlanningLine: Record "Job Planning Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; EntryType: Enum "Job Journal Line Entry Type")
    var
        CorrectionsPostingMgtCZL: codeunit "Corrections Posting Mgt. CZL";
    begin
        JobJnlLine."Shpt. Method Code" := SalesHeader."Shipment Method Code";
        JobJnlLine."Tariff No. CZL" := SalesLine."Tariff No. CZL";
        JobJnlLine."Statistic Indication CZL" := SalesLine."Statistic Indication CZL";
        JobJnlLine."Net Weight CZL" := SalesLine."Net Weight";
        JobJnlLine."Country/Reg. of Orig. Code CZL" := SalesLine."Country/Reg. of Orig. Code CZL";
        JobJnlLine."Intrastat Transaction CZL" := SalesHeader.IsIntrastatTransactionCZL();
        JobJnlLine.CheckIntrastatCZL();
        CorrectionsPostingMgtCZL.SetCorrectionIfNegQty(JobJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Transfer Line", 'OnAfterFromPlanningLineToJnlLine', '', false, false)]
    local procedure SetCorrectionOnAfterFromPlanningLineToJnlLine(var JobJournalLine: Record "Job Journal Line"; JobPlanningLine: Record "Job Planning Line")
    var
        CorrectionsPostingMgtCZL: codeunit "Corrections Posting Mgt. CZL";
    begin
        CorrectionsPostingMgtCZL.SetCorrectionIfNegQty(JobJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Transfer Line", 'OnAfterFromGenJnlLineToJnlLine', '', false, false)]
    local procedure SetCorrectionOnAfterFromGenJnlLineToJnlLine(var JobJnlLine: Record "Job Journal Line"; GenJnlLine: Record "Gen. Journal Line")
    var
        CorrectionsPostingMgtCZL: codeunit "Corrections Posting Mgt. CZL";
    begin
        CorrectionsPostingMgtCZL.SetCorrectionIfNegQty(JobJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Transfer Line", 'OnAfterFromPurchaseLineToJnlLine', '', false, false)]
    local procedure SetCorrectionOnAfterFromPurchaseLineToJnlLine(var JobJnlLine: Record "Job Journal Line"; PurchHeader: Record "Purchase Header"; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; PurchLine: Record "Purchase Line"; SourceCode: Code[10])
    var
        CorrectionsPostingMgtCZL: codeunit "Corrections Posting Mgt. CZL";
    begin
        JobJnlLine."Transaction Type" := PurchLine."Transaction Type";
        JobJnlLine."Transport Method" := PurchLine."Transport Method";
        JobJnlLine."Entry/Exit Point" := PurchLine."Entry Point";
        JobJnlLine.Area := PurchLine.Area;
        JobJnlLine."Country/Region Code" := PurchHeader."VAT Country/Region Code";
        JobJnlLine."Transaction Specification" := PurchLine."Transaction Specification";
        JobJnlLine."Shpt. Method Code" := PurchHeader."Shipment Method Code";
        JobJnlLine."Tariff No. CZL" := PurchLine."Tariff No. CZL";
        JobJnlLine."Statistic Indication CZL" := PurchLine."Statistic Indication CZL";
        JobJnlLine."Net Weight CZL" := PurchLine."Net Weight";
        JobJnlLine."Country/Reg. of Orig. Code CZL" := PurchLine."Country/Reg. of Orig. Code CZL";
        CorrectionsPostingMgtCZL.SetCorrectionIfNegQty(JobJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Transfer Line", 'OnAfterFromJnlLineToLedgEntry', '', false, false)]
    local procedure OnAfterFromJnlLineToLedgEntry(var JobLedgerEntry: Record "Job Ledger Entry"; JobJournalLine: Record "Job Journal Line")
    begin
        JobLedgerEntry."Tariff No. CZL" := JobJournalLine."Tariff No. CZL";
        JobLedgerEntry."Statistic Indication CZL" := JobJournalLine."Statistic Indication CZL";
        JobLedgerEntry."Net Weight CZL" := JobJournalLine."Net Weight CZL";
        JobLedgerEntry."Country/Reg. of Orig. Code CZL" := JobJournalLine."Country/Reg. of Orig. Code CZL";
        JobLedgerEntry."Intrastat Transaction CZL" := JobJournalLine."Intrastat Transaction CZL";
        JobLedgerEntry."Correction CZL" := JobJournalLine."Correction CZL";
    end;
}