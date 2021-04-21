codeunit 20338 "Transfer Shpt Posting Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterInsertTransShptLine', '', false, false)]
    procedure OnAfterInsertTransShptLine(
        TransLine: Record "Transfer Line";
        var TransShptLine: Record "Transfer Shipment Line")
    var
        TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
    begin
        // Prepares Transaction value based on Quantity and and Qty to Invoice
        TaxDocumentGLPosting.PrepareTransactionValueToPost(
            TransLine.RecordId(),
            TransLine.Quantity,
            TransShptLine.Quantity,
            '',
            0,
            TempTaxTransactionValue);

        TaxDocumentGLPosting.TransferTransactionValue(
            TransLine.RecordId(),
            TransShptLine.RecordId(),
            TempTaxTransactionValue);
    end;

}