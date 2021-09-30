codeunit 19010 "Call Tax Engine"
{
    procedure CalculateTax()
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ServiceLine: Record "Service Line";
        GenJournalLine: Record "Gen. Journal Line";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        TransferLine: Record "Transfer Line";
        CalculateTax: Codeunit "Calculate Tax";
        UseCaseExecution: Codeunit "Use Case Execution";
    begin
        InitTaxTypeProgressWindow();

        SalesLine.SetHideValidationDialog(true);
        if SalesLine.FindSet() then
            repeat
                UpdateTaxTypeProgressWindow(SalesLine.TableName, SalesLine.RecordId);
                if (SalesLine."HSN/SAC Code" <> '') or (SalesLine."TCS Nature of Collection" <> '') then
                    CalculateTax.CallTaxEngineOnSalesLine(SalesLine, SalesLine);
            until SalesLine.Next() = 0;

        if PurchaseLine.FindSet() then
            repeat
                UpdateTaxTypeProgressWindow(PurchaseLine.TableName, PurchaseLine.RecordId);
                if (PurchaseLine."HSN/SAC Code" <> '') or (PurchaseLine."TDS Section Code" <> '') then
                    CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
            until PurchaseLine.Next() = 0;

        ServiceLine.SetHideReplacementDialog(true);
        ServiceLine.SetHideCostWarning(true);
        ServiceLine.SetHideWarrantyWarning(true);
        if ServiceLine.FindSet() then
            repeat
                UpdateTaxTypeProgressWindow(ServiceLine.TableName, ServiceLine.RecordId);
                if ServiceLine."HSN/SAC Code" <> '' then
                    CalculateTax.CallTaxEngineOnServiceLine(ServiceLine, ServiceLine);
            until ServiceLine.Next() = 0;

        GenJournalLine.SetHideValidation(true);
        if GenJournalLine.FindSet() then
            repeat
                UpdateTaxTypeProgressWindow(GenJournalLine.TableName, GenJournalLine.RecordId);
                if (GenJournalLine."HSN/SAC Code" <> '') or (GenJournalLine."TDS Section Code" <> '') or (GenJournalLine."TCS Nature of Collection" <> '') then
                    CalculateTax.CallTaxEngineOnGenJnlLine(GenJournalLine, GenJournalLine);
            until GenJournalLine.Next() = 0;

        FinanceChargeMemoLine.SetFilter("HSN/SAC Code", '<>%1', '');
        if FinanceChargeMemoLine.FindSet() then
            repeat
                UpdateTaxTypeProgressWindow(FinanceChargeMemoLine.TableName, FinanceChargeMemoLine.RecordId);
                CalculateTax.CallTaxEngineOnFinanceChargeMemoLine(FinanceChargeMemoLine, FinanceChargeMemoLine);
            until FinanceChargeMemoLine.Next() = 0;

        TransferLine.SetFilter("HSN/SAC Code", '<>%1', '');
        if TransferLine.FindSet() then
            repeat
                UpdateTaxTypeProgressWindow(TransferLine.TableName, TransferLine.RecordId);
                UseCaseExecution.HandleEvent('OnAfterTransferPrirce', TransferLine, '', 1);
            until TransferLine.Next() = 0;

        CloseTaxTypeProgressWindow();
        FinishAction();
    end;

    local procedure FinishAction()
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        AssistedSetup.Complete(Page::"Finalize India Migration");
    end;

    procedure InitTaxTypeProgressWindow()
    begin
        if not GuiAllowed() then
            exit;
        TaxTypeDialog.Open(
             CalculatingTaxLbl +
             RecIDTxt);
    end;

    local procedure UpdateTaxTypeProgressWindow(TableCaption: Text; RecID: RecordId)
    var
        RecordIDTxt: Text;
    begin
        if not GuiAllowed() then
            exit;

        RecordIDTxt := Format(RecID, 0, 1);
        TaxTypeDialog.Update(1, TableCaption);
        TaxTypeDialog.Update(2, RecordIDTxt);
    end;

    local procedure CloseTaxTypeProgressWindow()
    begin
        if not GuiAllowed() then
            exit;
        TaxTypeDialog.close();
    end;

    var
        TaxTypeDialog: Dialog;
        CalculatingTaxLbl: Label 'Calculating Tax :               #1######\', Comment = 'Calculating Tax';
        RecIDTxt: Label 'Record ID :      #2######\', Comment = 'Record ID';
}