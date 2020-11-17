codeunit 135082 "Generate Payment Data Sample"
{
    Permissions = TableData "AMC Banking Setup" = r;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
        ExpBankConvExtDataHndl: Codeunit "AMC Bank Exp. CT Hndl";
    begin
        ExpBankConvExtDataHndl.ConvertPaymentDataToFormat(TempBlob, Rec);

        Find();
        TempBlob.ToRecord(Rec, FieldNo("File Content"));
        Modify();
    end;
}

