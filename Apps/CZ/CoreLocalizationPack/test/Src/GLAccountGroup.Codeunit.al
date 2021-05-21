codeunit 148056 "G/L Account Group CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Group1GLAccount: Record "G/L Account";
        Group2GLAccount: Record "G/L Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryERM: Codeunit "Library - ERM";
        XmlParameters: Text;
        DocumentType: Enum "Gen. Journal Document Type";
        AccountType: Enum "Gen. Journal Account Type";
        isInitialized: Boolean;

    local procedure Initialize()
    begin
        Clear(LibraryReportDataset);
        if isInitialized then
            exit;
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Use VAT Date CZL" := false;
        GeneralLedgerSetup.Modify();

        isInitialized := true;
        Commit();
    end;

    [Test]
    [HandlerFunctions('GLAccountGroupPostCheckRequestPageHandler')]
    procedure GLAccountGroupPostingCheckReportSameGroups()
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        // [FEATURE] G/L Account Group Posting Check Report
        Initialize();

        // [GIVEN] New G/L Acount created
        LibraryERM.CreateGLAccount(Group1GLAccount);

        Group1GLAccount.Validate("Income/Balance", Group1GLAccount."Income/Balance"::"Balance Sheet");
        Group1GLAccount.Validate("Account Category", Group1GLAccount."Account Category"::Assets);
        Group1GLAccount."G/L Account Group CZL" := Group1GLAccount."G/L Account Group CZL"::"Financial Accounting";
        Group1GLAccount.Modify();

        // [GIVEN] New Gen. Journal Template created
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        // [GIVEN] New Gen. Journal Batch created
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Create and Post Gen. Journal lines
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                       DocumentType::" ", AccountType::"G/L Account",
                       Group1GLAccount."No.",
                       AccountType::"G/L Account", Group1GLAccount."No.", 100);
        GenJournalLine.Validate(GenJournalLine."Posting Date", Today());
        GenJournalLine.Validate(GenJournalLine."Document No.", '1111');
        GenJnlPostLine.Run(GenJournalLine);
        Commit();

        // [WHEN] Run the Report G/L Acc. Group Post. Check CZL. 
        XmlParameters := REPORT.RUNREQUESTPAGE(REPORT::"G/L Acc. Group Post. Check CZL");
        LibraryReportDataset.RunReportAndLoad(REPORT::"G/L Acc. Group Post. Check CZL", '', XmlParameters);

        // [THEN] Verifying Not Exist Dataset with Doc No. 1111
        LibraryReportDataset.AssertElementWithValueNotExist('DocumentNo_TempGLEntry', '1111');
    end;

    [Test]
    [HandlerFunctions('GLAccountGroupPostCheckRequestPageHandler')]
    procedure GLAccountGroupPostingCheckReportDifferentGroups()
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        // [FEATURE] G/L Account Group Posting Check Report
        Initialize();

        // [GIVEN] New G/L Acounts created
        CreateGLAccountWithEmptyGLAccGroup(Group1GLAccount);
        CreateGLAccountWithEmptyGLAccGroup(Group2GLAccount);

        // [GIVEN] New Gen. Journal Template created
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        // [GIVEN] New Gen. Journal Batch created
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Create and Post Gen. Journal lines
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                       DocumentType::" ", AccountType::"G/L Account",
                       LibraryERM.CreateGLAccountNo(),
                       AccountType::"G/L Account", Group1GLAccount."No.", 100);

        GenJournalLine.Validate(GenJournalLine."Posting Date", Today());
        GenJournalLine.Validate(GenJournalLine."Document No.", '2222');
        GenJnlPostLine.Run(GenJournalLine);

        // [GIVEN] Change G/L Account Group CZL Values
        Group1GLAccount."G/L Account Group CZL" := Group2GLAccount."G/L Account Group CZL"::"Internal Accounting";
        Group1GLAccount.Modify();
        Commit();

        // [WHEN] Run the Report G/L Acc. Group Post. Check CZL. 
        XmlParameters := REPORT.RUNREQUESTPAGE(REPORT::"G/L Acc. Group Post. Check CZL");
        LibraryReportDataset.RunReportAndLoad(REPORT::"G/L Acc. Group Post. Check CZL", '', XmlParameters);

        // [THEN] Verifying Exist Dataset with Doc No. 2222
        LibraryReportDataset.AssertElementWithValueExists('DocumentNo_TempGLEntry', '2222');

        // [GIVEN] Change G/L Account Group CZL Values
        Group1GLAccount."G/L Account Group CZL" := Group2GLAccount."G/L Account Group CZL"::"Financial Accounting";
        Group1GLAccount.Modify();

        // [GIVEN] Create and Post Gen. Journal lines
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                      DocumentType::" ", AccountType::"G/L Account",
                      Group1GLAccount."No.",
                      AccountType::"G/L Account", Group2GLAccount."No.", 100);
        GenJournalLine.Validate(GenJournalLine."Posting Date", Today());
        GenJournalLine.Validate(GenJournalLine."Document No.", '3333');
        GenJnlPostLine.Run(GenJournalLine);

        // [GIVEN] Change G/L Account Groups CZL Values
        Group1GLAccount."G/L Account Group CZL" := Group2GLAccount."G/L Account Group CZL"::"Internal Accounting";
        Group1GLAccount.Modify();
        Group2GLAccount."G/L Account Group CZL" := Group2GLAccount."G/L Account Group CZL"::"Off-Balance Accounting";
        Group2GLAccount.Modify();
        Commit();

        // [WHEN] Run the Report G/L Acc. Group Post. Check CZL. 
        XmlParameters := REPORT.RUNREQUESTPAGE(REPORT::"G/L Acc. Group Post. Check CZL");
        LibraryReportDataset.RunReportAndLoad(REPORT::"G/L Acc. Group Post. Check CZL", '', XmlParameters);

        // [THEN] Verifying Exist Dataset with Doc No. 3333
        LibraryReportDataset.AssertElementWithValueExists('DocumentNo_TempGLEntry', '3333');
    end;

    [RequestPageHandler]
    procedure GLAccountGroupPostCheckRequestPageHandler(var GLAccGroupPostCheckCZL: TestRequestPage "G/L Acc. Group Post. Check CZL")
    begin
        GLAccGroupPostCheckCZL.FromDateField.SetValue(Today());
        GLAccGroupPostCheckCZL.ToDateField.SetValue(Today());
        GLAccGroupPostCheckCZL.OK().Invoke();
    end;

    local procedure CreateGLAccountWithEmptyGLAccGroup(var GLAccount: Record "G/L Account")
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.Validate("Account Category", GLAccount."Account Category"::Assets);
        GLAccount."G/L Account Group CZL" := GLAccount."G/L Account Group CZL"::"Financial Accounting";
        GLAccount.Modify();
    end;
}