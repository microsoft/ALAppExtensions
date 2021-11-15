#if not CLEAN20
codeunit 20104 "AMC Bank Imp.-Post-Mapping"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the new implementation in V19.1 of AMC Bank Imp.-Post-Process';
    ObsoleteTag = '20.0';

    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    var
        DataExch: Record "Data Exch.";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        AMCBankPrePostProcessXMLImport: Codeunit "AMC Bank Pre&Post Process";
        RecordRef: RecordRef;
    begin
        DataExch.Get("Data Exch. Entry No.");
        BankAccReconciliation.Get("Statement Type", "Bank Account No.", "Statement No.");

        RecordRef.GetTable(BankAccReconciliation);
        AMCBankPrePostProcessXMLImport.PostProcessStatementEndingBalance(DataExch, RecordRef,
          BankAccReconciliation.FieldNo("Statement Ending Balance"), StmtAmtPathFilterTxt);

        AMCBankPrePostProcessXMLImport.PostProcessStatementDate(DataExch, RecordRef, BankAccReconciliation.FieldNo("Statement Date"),
          StmtDatePathFilterTxt);
    end;

    var
        StmtDatePathFilterTxt: Label '/reportExportResponse/return/finsta/statement/balanceenddate', Locked = true;
        StmtAmtPathFilterTxt: Label '/reportExportResponse/return/finsta/statement/balanceend', Locked = true;
}

#endif