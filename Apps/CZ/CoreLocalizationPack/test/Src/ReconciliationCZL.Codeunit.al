#pragma warning disable AL0432
codeunit 148106 "Reconciliation CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [General Journal] [Reconciliation]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryUtility: Codeunit "Library - Utility";
        isInitialized: Boolean;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Reconciliation CZL");
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Reconciliation CZL");

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Reconciliation CZL");
    end;

    [Test]
    [HandlerFunctions('PageReconciliationHandler')]
    procedure ReconciliationGeneralJournals()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLAccountNo: Code[20];
    begin
        // [SCENARIO] Run Reconcilation window from general journal and check account no. and balance account no.
        Initialize();

        // [GIVEN] New general journal line has been created
        GLAccountNo := LibraryERM.CreateGLAccountNo();
        CreateGenJnlLine(GenJournalLine, GenJournalLine."Account Type"::"G/L Account", GLAccountNo);

        // [WHEN] Run action Reconciliation
        LibraryVariableStorage.Enqueue(GenJournalLine."Account No.");
        LibraryVariableStorage.Enqueue(GenJournalLine."Bal. Account No.");
        LibraryVariableStorage.Enqueue(GenJournalLine.Amount);
        RunReconciliation(GenJournalLine);

        // [THEN] Verify in PageReconciliationHandler
    end;

    [Test]
    procedure BankAccountReconcile()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        TempGLAccountNetChange: Record "G/L Account Net Change" temporary;
        Reconciliation: Page Reconciliation;
        GLAccountNo: Code[20];
    begin
        // [SCENARIO] Check reconciliation amount of bank account
        Initialize();

        // [GIVEN] Bank Account, G/L Account and General Journal has been created
        Initialize();
        LibraryERM.CreateBankAccount(BankAccount);
        GLAccountNo := LibraryERM.CreateGLAccountNo();
        CreateGenJnlLineWithBank(GenJournalLine, BankAccount."No.", GenJournalLine."Account Type"::"G/L Account", GLAccountNo, LibraryRandom.RandDec(1000, 2));

        // [WHEN] Reconciliation is processed
        Reconciliation.SetGenJnlLine(GenJournalLine);
        Reconciliation.ReturnGLAccountNetChange(TempGLAccountNetChange);

        // [THEN] G/L account will be reconciliated
        TempGLAccountNetChange.SetRange("Account Type CZL", Enum::"Gen. Journal Account Type"::"G/L Account");
        TempGLAccountNetChange.SetRange("Account No. CZL", GLAccountNo);
        TempGLAccountNetChange.FindFirst();

        // [THEN] verify Amount must be same as "Net Change in Jnl.".
        GenJournalLine.TestField(Amount, TempGLAccountNetChange."Net Change in Jnl.");

        // [THEN] bank account will be reconciliated
        TempGLAccountNetChange.SetRange("Account Type CZL", Enum::"Gen. Journal Account Type"::"Bank Account");
        TempGLAccountNetChange.SetRange("Account No. CZL", BankAccount."No.");
        TempGLAccountNetChange.FindFirst();

        // [THEN] verify Amount must be negative as "Net Change in Jnl.".
        GenJournalLine.TestField(Amount, -TempGLAccountNetChange."Net Change in Jnl.");
    end;

    local procedure CreateGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, Enum::"Gen. Journal Document Type"::" ",
          AccountType, AccountNo, LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreateGenJnlLineWithBank(var GenJournalLine: Record "Gen. Journal Line"; BankAccountNo: Code[20]; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJnlBatchForBank(GenJournalBatch, BankAccountNo);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          AccountType, AccountNo, Amount);
    end;

    local procedure CreateGenJnlBatchForBank(var GenJournalBatch: Record "Gen. Journal Batch"; BalAccountNo: Code[20])
    begin
        LibraryJournals.CreateGenJournalBatch(GenJournalBatch);
        GenJournalBatch.Validate("No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BalAccountNo);
        GenJournalBatch.Modify(true);
    end;

    local procedure RunReconciliation(GenJournalLine: Record "Gen. Journal Line")
    var
        Reconciliation: Page Reconciliation;
    begin
        GenJournalLine.SetRecFilter();
        Reconciliation.SetGenJnlLine(GenJournalLine);
        Reconciliation.Run();
    end;

    [PageHandler]
    procedure PageReconciliationHandler(var Reconciliation: TestPage Reconciliation)
    var
        Amount: Decimal;
        GLAccountNo: Code[20];
        BalGlAccountNo: Code[20];
    begin
        GLAccountNo := CopyStr(LibraryVariableStorage.DequeueText(), 1, 20);
        BalGlAccountNo := CopyStr(LibraryVariableStorage.DequeueText(), 1, 20);
        Amount := LibraryVariableStorage.DequeueDecimal();
        Reconciliation.First();
        Reconciliation."Account No. CZL".AssertEquals(GLAccountNo);
        Reconciliation."Net Change in Jnl.".AssertEquals(Amount);
        Reconciliation."Balance after Posting".AssertEquals(Amount);
        Reconciliation.Next();
        Reconciliation."Account No. CZL".AssertEquals(BalGlAccountNo);
        Reconciliation."Net Change in Jnl.".AssertEquals(-Amount);
        Reconciliation."Balance after Posting".AssertEquals(-Amount);
        Reconciliation.OK().Invoke();
    end;
}
