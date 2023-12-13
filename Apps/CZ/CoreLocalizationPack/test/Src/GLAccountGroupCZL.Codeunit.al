codeunit 148056 "G/L Account Group CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [G/L Account Group]
        isInitialized := false;
    end;

    var
        GenJournalLine: Record "Gen. Journal Line";
        Group1GLAccount: Record "G/L Account";
        Group2GLAccount: Record "G/L Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryERM: Codeunit "Library - ERM";
        LibraryTaxCZL: Codeunit "Library - Tax CZL";
        XmlParameters: Text;
        DocumentType: Enum "Gen. Journal Document Type";
        AccountType: Enum "Gen. Journal Account Type";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"G/L Account Group CZL");
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"G/L Account Group CZL");

        LibraryTaxCZL.SetUseVATDate(true);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"G/L Account Group CZL");
    end;

    [Test]
    [HandlerFunctions('GLAccountGroupPostCheckRequestPageHandler')]
    procedure GLAccountGroupPostingCheckReportSameGroups()
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        // [SCENARIO] G/L Account Group Posting Check Report for the same G/L Account Group
        Initialize();

        // [GIVEN] New G/L Acounts have been created
        CreateGLAccountWithEmptyGLAccGroup(Group1GLAccount);
        CreateGLAccountWithEmptyGLAccGroup(Group2GLAccount);

        // [GIVEN] New Gen. Journal Batch has been created
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Gen. Journal Line has been created and posted
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                       DocumentType::" ", AccountType::"G/L Account", Group1GLAccount."No.",
                       AccountType::"G/L Account", Group2GLAccount."No.", 100);
        GenJournalLine.Validate(GenJournalLine."Posting Date", WorkDate());
        GenJournalLine.Validate(GenJournalLine."Document No.", '1111');
        GenJnlPostLine.Run(GenJournalLine);

        // [WHEN] Run the Report G/L Acc. Group Post. Check CZL.
        Commit();
        XmlParameters := Report.RunRequestPage(Report::"G/L Acc. Group Post. Check CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"G/L Acc. Group Post. Check CZL", '', XmlParameters);

        // [THEN] Dataset will be verified
        LibraryReportDataset.AssertElementWithValueNotExist('DocumentNo_TempGLEntry', '1111');
    end;

    [Test]
    [HandlerFunctions('GLAccountGroupPostCheckRequestPageHandler')]
    procedure GLAccountGroupPostingCheckReportDifferentGroups()
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        // [FEATURE] G/L Account Group Posting Check Report for different G/L Account Groups
        Initialize();

        // [GIVEN] New G/L Acounts have been created
        CreateGLAccountWithEmptyGLAccGroup(Group1GLAccount);
        CreateGLAccountWithEmptyGLAccGroup(Group2GLAccount);

        // [GIVEN] New Gen. Journal Batch has been created
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Gen. Journal Line has been created and posted
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                       DocumentType::" ", AccountType::"G/L Account", Group1GLAccount."No.",
                       AccountType::"G/L Account", Group2GLAccount."No.", 100);
        GenJournalLine.Validate(GenJournalLine."Posting Date", WorkDate());
        GenJournalLine.Validate(GenJournalLine."Document No.", '2222');
        GenJnlPostLine.Run(GenJournalLine);

        // [GIVEN] G/L Account Group has been changed
        Group1GLAccount."G/L Account Group CZL" := Group1GLAccount."G/L Account Group CZL"::"Internal Accounting";
        Group1GLAccount.Modify();

        // [WHEN] Run the Report G/L Acc. Group Post. Check CZL 
        Commit();
        XmlParameters := Report.RunRequestPage(Report::"G/L Acc. Group Post. Check CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"G/L Acc. Group Post. Check CZL", '', XmlParameters);

        // [THEN] Dataset will be verified
        LibraryReportDataset.AssertElementWithValueExists('DocumentNo_TempGLEntry', '2222');
    end;

    [RequestPageHandler]
    procedure GLAccountGroupPostCheckRequestPageHandler(var GLAccGroupPostCheckCZL: TestRequestPage "G/L Acc. Group Post. Check CZL")
    begin
        GLAccGroupPostCheckCZL.FromDateField.SetValue(WorkDate());
        GLAccGroupPostCheckCZL.ToDateField.SetValue(WorkDate());
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
