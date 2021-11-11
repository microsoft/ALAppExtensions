#if not CLEAN20
codeunit 20101 "AMC Bank Bank Acc. Rec Lin"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Codeunit 1248 is used.';
    ObsoleteTag = '20.0';

    Permissions = TableData "Data Exch." = rimd;
    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    var
        DataExch: Record "Data Exch.";
        ProcessDataExch: Codeunit "Process Data Exch.";
        RecordRef: RecordRef;
    begin
        DataExch.Get("Data Exch. Entry No.");
        RecordRef.GetTable(Rec);
        ProcessDataExch.ProcessAllLinesColumnMapping(DataExch, RecordRef);
    end;

    var
        ProgressWindowMsg: Label 'Please wait while the operation is being completed.';

    procedure ImportBankStatement(BankAccReconciliation: Record "Bank Acc. Reconciliation"; DataExch: Record "Data Exch."): Boolean
    var
        BankAccount: Record "Bank Account";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchLineDef: Record "Data Exch. Line Def";
        TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary;
        ProgressWindowDialog: Dialog;
    begin
        BankAccount.Get(BankAccReconciliation."Bank Account No.");
        BankAccount.GetDataExchDef(DataExchDef);

        DataExch."Related Record" := BankAccount.RecordId();
        DataExch."Data Exch. Def Code" := DataExchDef.Code;

        if not DataExch.ImportToDataExch(DataExchDef) then
            exit(false);

        ProgressWindowDialog.Open(ProgressWindowMsg);

        CreateBankAccRecLineTemplate(TempBankAccReconciliationLine, BankAccReconciliation, DataExch);
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchLineDef.FindFirst();

        DataExchMapping.Get(DataExchDef.Code, DataExchLineDef.Code, DATABASE::"Bank Acc. Reconciliation Line");

        if DataExchMapping."Pre-Mapping Codeunit" <> 0 then
            CODEUNIT.Run(DataExchMapping."Pre-Mapping Codeunit", TempBankAccReconciliationLine);

        DataExchMapping.TestField("Mapping Codeunit");
        CODEUNIT.Run(DataExchMapping."Mapping Codeunit", TempBankAccReconciliationLine);

        if DataExchMapping."Post-Mapping Codeunit" <> 0 then
            CODEUNIT.Run(DataExchMapping."Post-Mapping Codeunit", TempBankAccReconciliationLine);

        InsertNonReconciledNonImportedLines(TempBankAccReconciliationLine, GetStatementLineNoOffset(BankAccReconciliation));

        ProgressWindowDialog.Close();
        exit(true);
    end;

    procedure CreateBankAccRecLineTemplate(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; BankAccReconciliation: Record "Bank Acc. Reconciliation"; DataExch: Record "Data Exch.")
    begin
        BankAccReconciliationLine.Init();
        BankAccReconciliationLine."Statement Type" := BankAccReconciliation."Statement Type";
        BankAccReconciliationLine."Statement No." := BankAccReconciliation."Statement No.";
        BankAccReconciliationLine."Bank Account No." := BankAccReconciliation."Bank Account No.";
        BankAccReconciliationLine."Data Exch. Entry No." := DataExch."Entry No.";
    end;

    local procedure InsertNonReconciledNonImportedLines(var TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary; StatementLineNoOffset: Integer)
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        if TempBankAccReconciliationLine.FindSet() then
            repeat
                if TempBankAccReconciliationLine.CanImport() then begin
                    BankAccReconciliationLine := TempBankAccReconciliationLine;
                    BankAccReconciliationLine."Statement Line No." += StatementLineNoOffset;
                    BankAccReconciliationLine.Insert();
                end;
            until TempBankAccReconciliationLine.Next() = 0;
    end;

    local procedure GetStatementLineNoOffset(BankAccReconciliation: Record "Bank Acc. Reconciliation"): Integer
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        if BankAccReconciliationLine.FindLast() then
            exit(BankAccReconciliationLine."Statement Line No.");
        exit(0)
    end;
}

#endif