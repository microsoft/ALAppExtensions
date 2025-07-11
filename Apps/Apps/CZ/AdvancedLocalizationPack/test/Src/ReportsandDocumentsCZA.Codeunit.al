codeunit 148097 "Reports and Documents CZA"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        RowNotFoundErr: Label 'There is no dataset row corresponding to Element Name %1 with value %2.', Comment = '%1=Field Caption,%2=Field Value;';

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Reports and Documents CZA");

        LibraryRandom.SetSeed(1);  // Use Random Number Generator to generate the seed for RANDOM function.
        LibraryVariableStorage.Clear();
        LibraryReportDataset.Reset();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Reports and Documents CZA");

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Reports and Documents CZA");
    end;

    [Test]
    [HandlerFunctions('RequestPageInventoryAccountToDateHandler')]
    procedure PrintingInventoryAccountToDate()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        ErrorMessage: Text;
    begin
        Initialize();

        // [GIVEN] The g/l account has been created.
        LibraryERM.CreateGLAccount(GLAccount);

        // [GIVEN] The general journal line with g/l account has been created.
        CreateAndPostGenJnlLineWithGLAccount(GenJournalLine, GLAccount."No.");

        // [WHEN] Print inventory account to date report.
        PrintInventoryAccountToDate(GLAccount."No.", GenJournalLine."Posting Date");

        // [THEN] The report will be correctly printed.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('No_GLAcc', GLAccount."No.");
        if not LibraryReportDataset.GetNextRow() then begin
            ErrorMessage := StrSubstNo(RowNotFoundErr, 'No_GLAcc', GLAccount."No.");
            Error(ErrorMessage);
        end;
        LibraryReportDataset.AssertCurrentRowValueEquals('Amount_GLE', GenJournalLine.Amount);
    end;

    local procedure CreateAndPostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20])
    begin
        CreateGenJnlLine(GenJournalLine, AccountType, AccountNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostGenJnlLineWithGLAccount(var GenJournalLine: Record "Gen. Journal Line"; GLAccountNo: Code[20])
    begin
        CreateAndPostGenJnlLine(GenJournalLine, GenJournalLine."Account Type"::"G/L Account", GLAccountNo);
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

    local procedure PrintInventoryAccountToDate(GLAccountNo: Code[20]; PostingDate: Date)
    begin
        LibraryVariableStorage.Enqueue(GLAccountNo);
        LibraryVariableStorage.Enqueue(PostingDate);

        Report.Run(Report::"Inventory Account To Date CZA", true, false);
    end;

    [RequestPageHandler]
    procedure RequestPageInventoryAccountToDateHandler(var InventoryAccountToDateCZA: TestRequestPage "Inventory Account To Date CZA")
    begin
        InventoryAccountToDateCZA."G/L Account".SetFilter("No.", LibraryVariableStorage.DequeueText());
        InventoryAccountToDateCZA."G/L Account".SetFilter("Date Filter", LibraryVariableStorage.DequeueText());
        InventoryAccountToDateCZA.SaveAsXml(
          LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}
