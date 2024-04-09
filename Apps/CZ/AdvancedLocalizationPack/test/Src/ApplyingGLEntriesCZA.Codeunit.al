codeunit 148081 "Applying G/L Entries CZA"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Applying G/L Entries]
        isInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        UnexpectedRemAmtErr: Label 'Unexpected Remaining Amount.';

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Applying G/L Entries CZA");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Applying G/L Entries CZA");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Applying G/L Entries CZA");
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandler')]
    procedure ApplyingGLEntriesFromGeneralJournal()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        DocumentNo: array[2] of Code[20];
        GLAccountNo: array[2] of Code[20];
        Amount: Decimal;
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
    begin
        // [SCENARIO] When posting General Journal Line, Applying G/L Entry
        Initialize();

        // [GIVEN] Create G/L Accounts
        GLAccountNo[1] := LibraryERM.CreateGLAccountNo();
        GLAccountNo[2] := LibraryERM.CreateGLAccountNo();
        Amount := LibraryRandom.RandDec(1000, 2);

        SelectGenJournalBatch(GenJournalBatch);

        // [GIVEN] Create G/L Entries
        LibraryERM.CreateGeneralJnlLineWithBalAcc(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[1],
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[2],
          Amount);

        DocumentNo[1] := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Applying G/L Entry
        LibraryERM.CreateGeneralJnlLineWithBalAcc(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalDocumentType::" ",
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[2],
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[1],
          Amount);

        DocumentNo[2] := GenJournalLine."Document No.";

        LibraryVariableStorage.Enqueue(DocumentNo[1]);
        LibraryVariableStorage.Enqueue(DocumentNo[2]);
        ApplyGenJournalLine(GenJournalLine);

        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify Closed G/L Entry
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo[1]);
        GLEntry.SetRange("G/L Account No.", GLAccountNo[2]);
        GLEntry.FindFirst();
        Assert.AreEqual(true, GLEntry."Closed CZA", GLEntry.FieldCaption("Closed CZA"));

        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo[2]);
        GLEntry.SetRange("G/L Account No.", GLAccountNo[2]);
        GLEntry.FindFirst();
        Assert.AreEqual(true, GLEntry."Closed CZA", GLEntry.FieldCaption("Closed CZA"));
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandler,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingGLEntriesPartially()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        DocumentNo: array[2] of Code[20];
        GLAccountNo: array[2] of Code[20];
        Amount: Decimal;
        AmountToApply: Decimal;
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
    begin
        // [SCENARIO] When posting General Journal Line, applying partially G/L Entry
        Initialize();

        // [GIVEN] Create G/L Accounts
        GLAccountNo[1] := LibraryERM.CreateGLAccountNo();
        GLAccountNo[2] := LibraryERM.CreateGLAccountNo();
        Amount := LibraryRandom.RandDec(1000, 2);
        AmountToApply := LibraryRandom.RandDec(Round(Amount, 1, '<'), 2);

        SelectGenJournalBatch(GenJournalBatch);

        // [GIVEN] Create G/L Entries
        LibraryERM.CreateGeneralJnlLineWithBalAcc(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[1],
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[2],
          Amount);

        DocumentNo[1] := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        LibraryERM.CreateGeneralJnlLineWithBalAcc(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalDocumentType::" ",
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[2],
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[1],
          Amount);

        DocumentNo[2] := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Applying G/L Entry
        GLEntry.Reset();
        GLEntry.SetRange("G/L Account No.", GLAccountNo[1]);
        GLEntry.SetRange("Document No.", DocumentNo[1]);
        GLEntry.FindFirst();

        LibraryVariableStorage.Enqueue(DocumentNo[2]);
        LibraryVariableStorage.Enqueue(-AmountToApply);
        ApplyGLEntryFromGLEntry(GLEntry);

        // [THEN] Verify G/L Entry Remaining Amount
        GLEntry.SetRange("Document No.", DocumentNo[1]);
        GLEntry.SetRange("G/L Account No.", GLAccountNo[1]);
        GLEntry.FindFirst();
        Assert.AreEqual(Amount - AmountToApply, GLEntry.RemainingAmountCZA(), UnexpectedRemAmtErr);
    end;

    [Test]
    [HandlerFunctions('RequestPageGLEntryApplyingHandler')]
    procedure ApplyingGLEntriesAutomatically()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        DocumentNo: array[2] of Code[20];
        GLAccountNo: array[2] of Code[20];
        Amount: Decimal;
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
    begin
        // [SCENARIO] After posting General Journal Line, applying G/L Entry with Report "G/L Entry Applying CZA"
        Initialize();

        // [GIVEN] Create G/L Accounts
        GLAccountNo[1] := LibraryERM.CreateGLAccountNo();
        GLAccountNo[2] := LibraryERM.CreateGLAccountNo();
        Amount := LibraryRandom.RandDec(1000, 2);

        SelectGenJournalBatch(GenJournalBatch);

        // [GIVEN] Create G/L Entries
        LibraryERM.CreateGeneralJnlLineWithBalAcc(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[1],
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[2],
          Amount);

        DocumentNo[1] := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        LibraryERM.CreateGeneralJnlLineWithBalAcc(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalDocumentType::" ",
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[2],
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo[1],
          Amount);

        DocumentNo[2] := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Applying G/L Entry with Report: "G/L Entry Applying CZA"
        LibraryVariableStorage.Enqueue(true);
        LibraryVariableStorage.Enqueue(1);
        LibraryVariableStorage.Enqueue(GLAccountNo[2]);
        ApplyGLEntries();

        // [THEN] Verify Closed G/L Entry
        GLEntry.SetRange("Document No.", DocumentNo[1]);
        GLEntry.SetRange("G/L Account No.", GLAccountNo[2]);
        GLEntry.FindFirst();
        Assert.AreEqual(true, GLEntry."Closed CZA", GLEntry.FieldCaption("Closed CZA"));

        GLEntry.SetRange("Document No.", DocumentNo[2]);
        GLEntry.SetRange("G/L Account No.", GLAccountNo[2]);
        GLEntry.FindFirst();
        Assert.AreEqual(true, GLEntry."Closed CZA", GLEntry.FieldCaption("Closed CZA"));
    end;


    local procedure ApplyGenJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        Codeunit.Run(Codeunit::"Gen. Jnl.-Apply", GenJournalLine);
    end;

    local procedure SelectGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch)
    end;

    local procedure ApplyGLEntryFromGLEntry(var GLEntry: Record "G/L Entry")
    var
        GLENtryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
    begin
        GLENtryPostApplicationCZA.ApplyGLEntry(GLEntry);
    end;

    local procedure ApplyGLEntries()
    begin
        Commit();
        Report.Run(Report::"G/L Entry Applying CZA");
    end;

    [ModalPageHandler]
    procedure ModalApplyGLEntriesHandler(var ApplyGLEntriesCZA: TestPage "Apply G/L Entries CZA")
    var
        FieldVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldVariant);
        ApplyGLEntriesCZA.Filter.SetFilter("Document No.", FieldVariant);
        ApplyGLEntriesCZA.First();
        LibraryVariableStorage.Dequeue(FieldVariant);
        if FieldVariant.IsCode then begin
            ApplyGLEntriesCZA."Set Applies-to ID".Invoke();
            ApplyGLEntriesCZA."Applies-to ID".AssertEquals(FieldVariant);
        end;
        if FieldVariant.IsDecimal then begin
            ApplyGLEntriesCZA."Amount to Apply".SetValue(FieldVariant);
            ApplyGLEntriesCZA."Post Application".Invoke();
        end;
        ApplyGLEntriesCZA.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ModalPostApplicationHandler(var PostApplication: TestPage "Post Application")
    begin
        PostApplication.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure RequestPageGLEntryApplyingHandler(var GLEntryApplyingCZA: TestRequestPage "G/L Entry Applying CZA")
    var
        FieldVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldVariant);
        GLEntryApplyingCZA.ByAmountField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        GLEntryApplyingCZA.ApplyingField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        GLEntryApplyingCZA."G/L Account".SetFilter("No.", FieldVariant);
        GLEntryApplyingCZA.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}