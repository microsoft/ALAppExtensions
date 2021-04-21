codeunit 20334 "Gen. Jnl.-Post Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var GenJnlLine: Record "Gen. Journal Line")
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
        RecRef: RecordRef;
    begin
        OnBeforeGenJnlLinePostFromTaxEngine(GenJnlLine);
        TaxTransactionValue.SetRange("Tax Record ID", GenJnlLine.RecordId());
        if TaxTransactionValue.IsEmpty() then
            exit;

        GenJnlLine."Tax ID" := CreateGuid();
        TaxPostingBufferMgmt.ClearPostingInstance();
        RecRef.GetTable(GenJnlLine);
        TaxPostingBufferMgmt.SetDocument(RecRef);

        // Prepares Transaction value based on Quantity and and Qty to Invoice
        TaxDocumentGLPosting.PrepareTransactionValueToPost(
            GenJnlLine.RecordId(),
            1,
            1,
            GenJnlLine."Currency Code",
            GenJnlLine."Currency Factor",
            TempTaxTransactionValue);

        TaxDocumentGLPosting.UpdateTaxPostingBuffer(
            TempTaxTransactionValue,
            GenJnlLine.RecordId(),
            GenJnlLine."Tax ID",
            GenJnlLine."Dimension Set ID",
            GenJnlLine."Gen. Bus. Posting Group",
            GenJnlLine."Gen. Prod. Posting Group",
            1,
            1,
            GenJnlLine."Currency Code",
            GenJnlLine."Currency Factor",
            GenJnlLine."Document No.",
            GenJnlLine."Line No.");

        OnAfterGenJnlLinePostFromTaxEngine(GenJnlLine);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGenJnlLinePostFromTaxEngine(var GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterGenJnlLinePostFromTaxEngine(var GenJnlLine: Record "Gen. Journal Line")
    begin
    end;
}