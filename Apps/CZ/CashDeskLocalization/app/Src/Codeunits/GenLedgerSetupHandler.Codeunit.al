codeunit 11794 "Gen. Ledger Setup Handler CZP"
{
    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterInitVATDateCZL', '', false, false)]
    local procedure InitCashDocumentVatDateOnAfterInitVATDateCZL()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.InitVATDateFromRecordCZL(Database::"Cash Document Header CZP");
        GeneralLedgerSetup.InitVATDateFromRecordCZL(Database::"Posted Cash Document Hdr. CZP");
    end;
}
