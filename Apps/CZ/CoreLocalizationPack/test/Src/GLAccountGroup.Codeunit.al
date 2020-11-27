codeunit 148056 "G/L Account Group CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount1: Record "G/L Account";
        GLAccount2: Record "G/L Account";
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
        LibraryERM.CreateGLAccount(GLAccount1);

        GLAccount1.Validate("Income/Balance", GLAccount1."Income/Balance"::"Balance Sheet");
        GLAccount1.Validate("Account Category", GLAccount1."Account Category"::Assets);
        GLAccount1."G/L Account Group CZL" := GLAccount1."G/L Account Group CZL"::" ";
        GLAccount1.Modify();

        // [GIVEN] New Gen. Journal Template created
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        // [GIVEN] New Gen. Journal Batch created
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Create and Post Gen. Journal lines
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                       DocumentType::" ", AccountType::"G/L Account",
                       GLAccount1."No.",
                       AccountType::"G/L Account", GLAccount1."No.", 100);
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
        CreateGLAccountWithEmptyGLAccGroup(GLAccount1);
        CreateGLAccountWithEmptyGLAccGroup(GLAccount2);

        // [GIVEN] New Gen. Journal Template created
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        // [GIVEN] New Gen. Journal Batch created
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Create and Post Gen. Journal lines
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                       DocumentType::" ", AccountType::"G/L Account",
                       LibraryERM.CreateGLAccountNo(),
                       AccountType::"G/L Account", GLAccount1."No.", 100);

        GenJournalLine.Validate(GenJournalLine."Posting Date", Today());
        GenJournalLine.Validate(GenJournalLine."Document No.", '2222');
        GenJnlPostLine.Run(GenJournalLine);

        // [GIVEN] Change G/L Account Group CZL Values
        GLAccount1."G/L Account Group CZL" := GLAccount2."G/L Account Group CZL"::Internal;
        GLAccount1.Modify();
        Commit();

        // [WHEN] Run the Report G/L Acc. Group Post. Check CZL. 
        XmlParameters := REPORT.RUNREQUESTPAGE(REPORT::"G/L Acc. Group Post. Check CZL");
        LibraryReportDataset.RunReportAndLoad(REPORT::"G/L Acc. Group Post. Check CZL", '', XmlParameters);

        // [THEN] Verifying Exist Dataset with Doc No. 2222
        LibraryReportDataset.AssertElementWithValueExists('DocumentNo_TempGLEntry', '2222');

        // [GIVEN] Change G/L Account Group CZL Values
        GLAccount1."G/L Account Group CZL" := GLAccount2."G/L Account Group CZL"::" ";
        GLAccount1.Modify();

        // [GIVEN] Create and Post Gen. Journal lines
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                      DocumentType::" ", AccountType::"G/L Account",
                      GLAccount1."No.",
                      AccountType::"G/L Account", GLAccount2."No.", 100);
        GenJournalLine.Validate(GenJournalLine."Posting Date", Today());
        GenJournalLine.Validate(GenJournalLine."Document No.", '3333');
        GenJnlPostLine.Run(GenJournalLine);

        // [GIVEN] Change G/L Account Groups CZL Values
        GLAccount1."G/L Account Group CZL" := GLAccount2."G/L Account Group CZL"::Internal;
        GLAccount1.Modify();
        GLAccount2."G/L Account Group CZL" := GLAccount2."G/L Account Group CZL"::"Off-Balance";
        GLAccount2.Modify();
        Commit();

        // [WHEN] Run the Report G/L Acc. Group Post. Check CZL. 
        XmlParameters := REPORT.RUNREQUESTPAGE(REPORT::"G/L Acc. Group Post. Check CZL");
        LibraryReportDataset.RunReportAndLoad(REPORT::"G/L Acc. Group Post. Check CZL", '', XmlParameters);

        // [THEN] Verifying Exist Dataset with Doc No. 3333
        LibraryReportDataset.AssertElementWithValueExists('DocumentNo_TempGLEntry', '3333');
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
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
        GLAccount."G/L Account Group CZL" := GLAccount."G/L Account Group CZL"::" ";
        GLAccount.Modify();
    end;
}