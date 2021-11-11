codeunit 20128 "AMC Bank Imp.-Post-Process"
{
    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    var
        DataExch: Record "Data Exch.";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        XMLImportAMCBankPrePostProc: Codeunit "AMC Bank PrePost Proc";
        RecordRef: RecordRef;
    begin
        DataExch.Get(Rec."Data Exch. Entry No.");
        BankAccReconciliation.Get(Rec."Statement Type", Rec."Bank Account No.", Rec."Statement No.");

        RecordRef.GetTable(BankAccReconciliation);

        XMLImportAMCBankPrePostProc.PostProcessStatementEndingBalance(DataExch, RecordRef, BankAccReconciliation.FieldNo("Statement Ending Balance"));

        XMLImportAMCBankPrePostProc.PostProcessStatementDate(DataExch, RecordRef, BankAccReconciliation.FieldNo("Statement Date"));

    end;

    var
}

