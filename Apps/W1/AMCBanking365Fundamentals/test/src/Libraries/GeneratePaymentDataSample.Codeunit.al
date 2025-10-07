#if not CLEAN28
codeunit 135082 "Generate Payment Data Sample"
{
    Permissions = TableData "AMC Banking Setup" = r;
    TableNo = "Data Exch.";
    ObsoleteReason = 'AMC Banking 365 Fundamental extension is discontinued';
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';

    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
        AMCBankExpCTHndl: Codeunit "AMC Bank Exp. CT Hndl";
        RecordRef: RecordRef;
    begin
        AMCBankExpCTHndl.ConvertPaymentDataToFormat(TempBlob, Rec);

        Find();
        RecordRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecordRef, FieldNo("File Content"));
        RecordRef.SetTable(Rec);
        Modify();
    end;
}
#endif
