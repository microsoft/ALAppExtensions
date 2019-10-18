codeunit 20104
 "AMC Bank Imp.-Post-Mapping"
{
    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    var
        DataExch: Record "Data Exch.";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        AMCBankPrePostProcessXMLImport: Codeunit "AMC Bank Pre&Post Process";
        RecRef: RecordRef;
    begin
        DataExch.Get("Data Exch. Entry No.");
        BankAccReconciliation.Get("Statement Type", "Bank Account No.", "Statement No.");

        RecRef.GetTable(BankAccReconciliation);
        AMCBankPrePostProcessXMLImport.PostProcessStatementEndingBalance(DataExch, RecRef,
          BankAccReconciliation.FieldNo("Statement Ending Balance"), StmtAmtPathFilterTxt);

        AMCBankPrePostProcessXMLImport.PostProcessStatementDate(DataExch, RecRef, BankAccReconciliation.FieldNo("Statement Date"),
          StmtDatePathFilterTxt);
    end;

    var
        StmtDatePathFilterTxt: Label '/reportExportResponse/return/finsta/statement/balanceenddate', Locked = true;
        StmtAmtPathFilterTxt: Label '/reportExportResponse/return/finsta/statement/balanceend', Locked = true;
}

