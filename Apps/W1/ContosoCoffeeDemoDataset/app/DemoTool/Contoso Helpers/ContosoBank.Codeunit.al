codeunit 5697 "Contoso Bank"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
            tabledata "Bank Account" = rim,
            tabledata "Bank Export/Import Setup" = rim,
            tabledata "Bank Pmt. Appl. Rule" = rim,
            tabledata "Payment Registration Setup" = rim,
            tabledata "Bank Acc. Reconciliation" = rim,
            tabledata "Bank Acc. Reconciliation Line" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertBankAccount(No: Code[20]; Name: Text[100]; Address: Text[100]; City: Text[30]; Contact: Text[100]; BankAccountNo: Text[30]; MinBalance: Decimal; BankAccPostingGroup: Code[20]; OurContactCode: Code[20]; CountryRegionCode: Code[10]; LastStatementNo: Code[20]; PmtRecNoSeries: Code[20]; PostCode: Code[20]; LastCheckNo: Code[20]; BankBranchNo: Text[20]; BankStatementImportFormat: Code[20])
    var
        BankAccount: Record "Bank Account";
        Exists: Boolean;
    begin
        if BankAccount.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BankAccount.Validate("No.", No);
        BankAccount.Validate(Name, Name);
        BankAccount.Validate(Address, Address);
        BankAccount.Validate(City, City);
        BankAccount.Validate(Contact, Contact);
        BankAccount."Bank Account No." := BankAccountNo;
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Bank Acc. Posting Group", BankAccPostingGroup);
        BankAccount.Validate("Our Contact Code", OurContactCode);
        BankAccount."Country/Region Code" := CountryRegionCode;
        BankAccount.Validate("Last Statement No.", LastStatementNo);
        BankAccount.Validate("Pmt. Rec. No. Series", PmtRecNoSeries);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate("Last Check No.", LastCheckNo);
        BankAccount.Validate("Bank Branch No.", BankBranchNo);
        BankAccount.Validate("Bank Statement Import Format", BankStatementImportFormat);

        if Exists then
            BankAccount.Modify(true)
        else
            BankAccount.Insert(true);
    end;

    procedure ContosoBankExportImportSetup(Code: Code[20]; Name: Text[100]; Direction: Integer; ProcessingCodeunitID: Integer; ProcessingXMLportID: Integer; DataExchDefCode: Code[20]; PreserveNonLatinCharacters: Boolean; CheckExportCodeunit: Integer)
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        Exists: Boolean;
    begin
        if BankExportImportSetup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BankExportImportSetup.Validate(Code, Code);
        BankExportImportSetup.Validate(Name, Name);
        BankExportImportSetup.Validate(Direction, Direction);
        BankExportImportSetup.Validate("Processing Codeunit ID", ProcessingCodeunitID);
        BankExportImportSetup.Validate("Processing XMLport ID", ProcessingXMLportID);
        BankExportImportSetup.Validate("Data Exch. Def. Code", DataExchDefCode);
        BankExportImportSetup.Validate("Preserve Non-Latin Characters", PreserveNonLatinCharacters);
        BankExportImportSetup.Validate("Check Export Codeunit", CheckExportCodeunit);

        if Exists then
            BankExportImportSetup.Modify(true)
        else
            BankExportImportSetup.Insert(true);
    end;

    procedure InserteBankPmtApplRule(MatchConfidence: Integer; Priority: Integer; RelatedPartyMatched: Integer; DocNoExtDocNoMatched: Integer; AmountInclToleranceMatched: Integer; DirectDebitCollectMatched: Integer; Score: Integer; ReviewRequired: Boolean; ApplyImmediatelly: Boolean)
    var
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        Exists: Boolean;
    begin
        if BankPmtApplRule.Get(MatchConfidence, Priority) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BankPmtApplRule.Validate("Match Confidence", MatchConfidence);
        BankPmtApplRule.Validate(Priority, Priority);
        BankPmtApplRule.Validate("Related Party Matched", RelatedPartyMatched);
        BankPmtApplRule.Validate("Doc. No./Ext. Doc. No. Matched", DocNoExtDocNoMatched);
        BankPmtApplRule.Validate("Amount Incl. Tolerance Matched", AmountInclToleranceMatched);
        BankPmtApplRule.Validate("Direct Debit Collect. Matched", DirectDebitCollectMatched);
        BankPmtApplRule.Validate(Score, Score);
        BankPmtApplRule.Validate("Review Required", ReviewRequired);
        BankPmtApplRule.Validate("Apply Immediatelly", ApplyImmediatelly);

        if Exists then
            BankPmtApplRule.Modify(true)
        else
            BankPmtApplRule.Insert(true);
    end;

    procedure InsertPaymentRegistrationSetup("User ID": Code[50]; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; BalAccountType: Option " ","G/L Account","Bank Account"; BalAccountNo: Code[20]; UsethisAccountasDef: Boolean; AutoFillDateReceived: Boolean)
    var
        PaymentRegistrationSetup: Record "Payment Registration Setup";
        Exists: Boolean;
    begin
        if PaymentRegistrationSetup.Get("User ID") then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        PaymentRegistrationSetup.Validate("User ID", "User ID");
        PaymentRegistrationSetup.Validate("Journal Template Name", JournalTemplateName);
        PaymentRegistrationSetup.Validate("Journal Batch Name", JournalBatchName);
        PaymentRegistrationSetup.Validate("Bal. Account Type", BalAccountType);
        PaymentRegistrationSetup.Validate("Bal. Account No.", BalAccountNo);
        PaymentRegistrationSetup.Validate("Use this Account as Def.", UsethisAccountasDef);
        PaymentRegistrationSetup.Validate("Auto Fill Date Received", AutoFillDateReceived);

        if Exists then
            PaymentRegistrationSetup.Modify(true)
        else
            PaymentRegistrationSetup.Insert(true);
    end;

    procedure InsertBankAccountReconciliation(StatementType: Enum "Bank Acc. Rec. Stmt. Type"; BankAccountNo: Code[20]; StatementDate: Date): Record "Bank Acc. Reconciliation"
    var
        BankAccount: Record "Bank Account";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        BankAccReconciliation.Validate("Statement Type", StatementType);
        BankAccReconciliation.Validate("Bank Account No.", BankAccountNo);
        if BankAccReconciliation.Insert(true) then;

        BankAccReconciliation.Validate("Statement Date", StatementDate);
        BankAccReconciliation.Modify(true);

        if StatementType = Enum::"Bank Acc. Rec. Stmt. Type"::"Payment Application" then begin
            BankAccount.Get(BankAccountNo);
            BankAccount."Last Payment Statement No." := BankAccReconciliation."Statement No.";
            BankAccount.Modify(true);
        end;

        exit(BankAccReconciliation);
    end;

    procedure InsertBankAccRecLine(BankAccReconciliation: Record "Bank Acc. Reconciliation"; DocumentNo: Code[20]; TransactionDate: Date; Description: Text[100]; StatementAmount: Decimal; AppliedAmount: Decimal; AppliedEntries: Integer; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20])
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine.Validate("Statement Type", BankAccReconciliation."Statement Type");
        BankAccReconciliationLine.Validate("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.Validate("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine."Statement Line No." := GetNextBankAccReconciliationLineNo(BankAccReconciliation);
        if DocumentNo <> '' then
            BankAccReconciliationLine.Validate("Document No.", DocumentNo);
        BankAccReconciliationLine.Validate("Transaction Date", TransactionDate);
        BankAccReconciliationLine.Validate("Statement Amount", StatementAmount);
        BankAccReconciliationLine.Validate("Account Type", AccountType);
        BankAccReconciliationLine.Validate("Account No.", AccountNo);
        if Description <> '' then
            BankAccReconciliationLine.Validate("Transaction Text", Description);
        BankAccReconciliationLine.Validate("Applied Amount", AppliedAmount);
        // BankAccReconciliationLine.Validate("Applied Entries", AppliedEntries);
        BankAccReconciliationLine.Insert(true);
    end;

    local procedure GetNextBankAccReconciliationLineNo(BankAccReconciliation: Record "Bank Acc. Reconciliation"): Integer
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine.SetCurrentKey("Statement Line No.");

        if BankAccReconciliationLine.FindLast() then
            exit(BankAccReconciliationLine."Statement Line No." + 10000)
        else
            exit(10000);
    end;
}
