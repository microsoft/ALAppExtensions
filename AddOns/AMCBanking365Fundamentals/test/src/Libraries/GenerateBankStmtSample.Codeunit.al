codeunit 135083 "Generate Bank Stmt. Sample"
{
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
        AMCBankImpSTMTHndl: Codeunit "AMC Bank Imp.STMT. Hndl";
        ErmPeSourceTestMock: Codeunit "ERM PE Source Test Mock";
        TempBlobList: Codeunit "Temp Blob List";
    begin
        ErmPeSourceTestMock.GetTempBlobList(TempBlobList);
        TempBlobList.Get(TempBlobList.Count(), TempBlob);
        AMCBankImpSTMTHndl.ConvertBankStatementToFormat(TempBlob, Rec);
    end;
}

