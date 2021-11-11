codeunit 31091 "Cash Document Line Handler CZZ"
{
    [EventSubscriber(ObjectType::Table, Database::"Cash Document Line CZP", 'OnAfterIsEETTransaction', '', false, false)]
    local procedure CashDocumentLineOnBeforeIsEETTransaction(CashDocumentLineCZP: Record "Cash Document Line CZP"; var EETTransaction: Boolean)
    begin
        if CashDocumentLineCZP."Cash Desk Event" <> '' then
            exit;

        EETTransaction := EETTransaction or CashDocumentLineCZP.IsAdvancePaymentCZZ() or CashDocumentLineCZP.IsAdvanceRefundCZZ();
    end;
}
