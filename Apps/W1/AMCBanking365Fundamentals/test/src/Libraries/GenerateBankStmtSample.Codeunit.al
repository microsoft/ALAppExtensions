#if not CLEAN28
codeunit 135083 "Generate Bank Stmt. Sample"
{
    TableNo = "Data Exch.";
    ObsoleteReason = 'AMC Banking 365 Fundamental extension is discontinued';
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';
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
#endif
