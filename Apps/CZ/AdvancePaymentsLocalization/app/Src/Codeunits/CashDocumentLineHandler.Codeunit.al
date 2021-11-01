codeunit 31091 "Cash Document Line Handler CZZ"
{
    [EventSubscriber(ObjectType::Table, Database::"Cash Document Line CZP", 'OnBeforeIsEETTransaction', '', false, false)]
    local procedure CashDocumentLineOnBeforeIsEETTransaction(CashDocumentLineCZP: Record "Cash Document Line CZP"; var EETTransaction: Boolean; var IsHandled: Boolean)
    var
        EETCashRegister: Record "EET Cash Register CZL";
    begin
        if CashDocumentLineCZP."Advance Letter No. CZZ" = '' then
            exit;

        EETTransaction := EETCashRegister.FindByCashRegisterNo("EET Cash Register Type CZL"::"Cash Desk", CashDocumentLineCZP."Cash Desk No.");
        IsHandled := true;
    end;
}
