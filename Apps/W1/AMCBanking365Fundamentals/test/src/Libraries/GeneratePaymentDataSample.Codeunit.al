codeunit 135082 "Generate Payment Data Sample"
{
    Permissions = TableData "AMC Banking Setup" = r;
    TableNo = "Data Exch.";

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

