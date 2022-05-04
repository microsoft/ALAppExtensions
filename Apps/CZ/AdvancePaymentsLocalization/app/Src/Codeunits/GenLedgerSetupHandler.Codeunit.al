codeunit 31433 "Gen. Ledger Setup Handler CZZ"
{
    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterInitVATDateCZL', '', false, false)]
    local procedure InitAdvanceLetterVatDateOnAfterInitVATDateCZL()
    var
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
    begin
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purch. Adv. Letter Header CZZ");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purch. Adv. Letter Entry CZZ");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Adv. Letter Header CZZ");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Adv. Letter Entry CZZ");
    end;
}
