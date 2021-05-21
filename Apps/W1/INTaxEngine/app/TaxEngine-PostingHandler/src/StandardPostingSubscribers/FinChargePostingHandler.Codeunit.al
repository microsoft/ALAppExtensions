codeunit 20340 "Fin Charge Posting Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FinChrgMemo-Issue", 'OnBeforeIssueFinChargeMemo', '', false, false)]
    local procedure OnBeforePostServiceDoc(var FinChargeMemoHeader: Record "Finance Charge Memo Header")
    var
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        TaxPostingBufferMgmt.ClearPostingInstance();
        TaxPostingBufferMgmt.SetDocument(FinChargeMemoHeader);
        TaxPostingBufferMgmt.CreateTaxID();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FinChrgMemo-Issue", 'OnAfterGetFinChrgMemoLine', '', false, false)]
    local procedure OnBeforePost(FinChrgMemoLine: Record "Finance Charge Memo Line"; DocNo: Code[20]; CurrencyFactor: Decimal)
    var
        TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        FinChargeMemoHeader: Record "Finance Charge Memo Header";
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        FinChargeMemoHeader.Get(FinChrgMemoLine."Finance Charge Memo No.");

        PrepareTransactionValue(FinChrgMemoLine, TempTaxTransactionValue, GetCurrencyFactor(FinChargeMemoHeader."Currency Code", CurrencyFactor));

        // Updates Posting Buffers in Tax Posting Buffer Mgmt. Codeunit
        // Creates tax ledger if the configuration is set for Line / Component on Use Case
        TaxDocumentGLPosting.UpdateTaxPostingBuffer(
            TempTaxTransactionValue,
            FinChrgMemoLine.RecordId(),
            TaxPostingBufferMgmt.GetTaxID(),
            FinChargeMemoHeader."Dimension Set ID",
            FinChargeMemoHeader."Gen. Bus. Posting Group",
            FinChrgMemoLine."Gen. Prod. Posting Group",
            1,
            1,
            FinChargeMemoHeader."Currency Code",
            GetCurrencyFactor(FinChargeMemoHeader."Currency Code", CurrencyFactor),
            DocNo,
            FinChrgMemoLine."Line No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FinChrgMemo-Issue", 'OnAfterInsertIssuedFinChrgMemoLine', '', false, false)]
    local procedure OnAfterIsueFinChargeMemo(FinChrgMemoLine: Record "Finance Charge Memo Line"; var IssuedFinChrgMemoLine: Record "Issued Fin. Charge Memo Line"; CurrencyFactor: Decimal)
    var
        FinChargeMemoHeader: Record "Finance Charge Memo Header";
        TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
    begin
        FinChargeMemoHeader.Get(FinChrgMemoLine."Finance Charge Memo No.");

        PrepareTransactionValue(FinChrgMemoLine, TempTaxTransactionValue, GetCurrencyFactor(FinChargeMemoHeader."Currency Code", CurrencyFactor));

        //Copies transaction value from upposted document to posted record ID
        TaxDocumentGLPosting.TransferTransactionValue(FinChrgMemoLine.RecordId(), IssuedFinChrgMemoLine.RecordId(), TempTaxTransactionValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FinChrgMemo-Issue", 'OnBeforeGenJnlPostLineRunWithCheck', '', false, false)]
    local procedure OnBeforePostCustomerEntry(var GenJournalLine: Record "Gen. Journal Line")
    var
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer then
            GenJournalLine."Tax ID" := TaxPostingBufferMgmt.GetTaxID();
    end;

    local procedure PrepareTransactionValue(var FinanceChargeMemoLine: Record "Finance Charge Memo Line"; var TempTaxTransactionValue: Record "Tax Transaction Value" temporary; CurrencyFactor: Decimal)
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
    begin
        FinanceChargeMemoHeader.Get(FinanceChargeMemoLine."Finance Charge Memo No.");

        TaxDocumentGLPosting.PrepareTransactionValueToPost(
             FinanceChargeMemoLine.RecordId(),
             1,
             1,
             FinanceChargeMemoHeader."Currency Code",
             GetCurrencyFactor(FinanceChargeMemoHeader."Currency Code", CurrencyFactor),
             TempTaxTransactionValue);
    end;

    local procedure GetCurrencyFactor(CurrencyCode: Code[10]; CurrencyFactor: Decimal): Decimal
    var
        CurrFactor: Decimal;
    begin
        if CurrencyCode <> '' then
            CurrFactor := CurrencyFactor
        else
            CurrFactor := 0;

        exit(CurrFactor);
    end;
}