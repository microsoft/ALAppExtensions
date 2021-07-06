codeunit 11794 "Gen. Ledger Setup Handler CZP"
{
    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterInitVATDateCZL', '', false, false)]
    local procedure InitCashDocumentVatDateOnAfterInitVATDateCZL()
    var
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
    begin
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Cash Document Header CZP");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Posted Cash Document Hdr. CZP");
    end;
}
