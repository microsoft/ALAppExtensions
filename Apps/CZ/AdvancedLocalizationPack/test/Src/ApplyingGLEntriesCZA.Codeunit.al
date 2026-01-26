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
        FromGLEntryNo: Integer;
        isInitialized: Boolean;
        UnexpectedRemAmtErr: Label 'Unexpected Remaining Amount.';

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Applying G/L Entries CZA");
        LibraryRandom.Init();

        InitFromGLEntryNo();

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

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerSingle,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingGLEntriesWithSamePostingDateToZero()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: Record "G/L Entry";
    begin
        // [SCENARIO] Applying G/L Entries with the same posting date to zero
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the positive amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '>%1', 0);
        ApplyingGLEntry.FindFirst();

        // [GIVEN] The G/L entry with work date and the negative amount has been found
        AppliedGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry.SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry.SetRange(Amount, -ApplyingGLEntry.Amount);
        AppliedGLEntry.FindFirst();

        // [WHEN] Run the applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, AppliedGLEntry);

        // [THEN] The applied G/L entry will be fully applied
        AppliedGLEntry.Find('=');
        VerifyGLEntry(AppliedGLEntry);

        // [THEN] The applying G/L entry will be fully applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry);
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerSingle,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingGLEntriesWithDifferentPostingDateToZero()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: Record "G/L Entry";
    begin
        // [SCENARIO] Applying G/L Entries with the different posting date to zero
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the positive amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '>%1', 0);
        ApplyingGLEntry.FindFirst();

        // [GIVEN] The G/L entry with work date +1D and the negative amount has been found
        AppliedGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry.SetRange("Posting Date", CalcDate('<CD+1D>', ApplyingGLEntry."Posting Date"));
        AppliedGLEntry.SetRange(Amount, -ApplyingGLEntry.Amount);
        AppliedGLEntry.FindFirst();

        // [WHEN] Run the applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, AppliedGLEntry);

        // [THEN] The applied G/L entry will be fully applied
        AppliedGLEntry.Find('=');
        VerifyGLEntry(AppliedGLEntry, AppliedGLEntry."Posting Date");

        // [THEN] The applying G/L entry will be fully applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry, AppliedGLEntry."Posting Date");
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerSingle,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingGLEntriesWithPositiveBalance()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: Record "G/L Entry";
    begin
        // [SCENARIO] Applying G/L Entries with positive balance
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the highest positive amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '>%1', 0);
        ApplyingGLEntry.FindLast();

        // [GIVEN] The G/L entry with work date and the abs value of amount less than applying amount has been found
        AppliedGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry.SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry.SetFilter(Amount, '>%1&<%2', -ApplyingGLEntry.Amount, 0);
        AppliedGLEntry.FindLast();

        // [WHEN] Start the applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, AppliedGLEntry);

        // [THEN] The applied G/L entry will be fully applied
        AppliedGLEntry.Find('=');
        VerifyGLEntry(AppliedGLEntry);

        // [THEN] The applying G/L entry will be partly applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry,
            Abs(ApplyingGLEntry.Amount) - Abs(AppliedGLEntry.Amount),
            -AppliedGLEntry.Amount, ApplyingGLEntry."Posting Date");
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerSingle,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingGLEntriesWithNegativeBalance()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: Record "G/L Entry";
    begin
        // [SCENARIO] Applying G/L Entries with negative balance
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the lowest negative amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '<%1', 0);
        ApplyingGLEntry.FindLast();

        // [GIVEN] The G/L entry with work date and the abs value of amount less than applying amount has been found
        AppliedGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry.SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry.SetFilter(Amount, '<%1&>%2', -ApplyingGLEntry.Amount, 0);
        AppliedGLEntry.FindLast();

        // [WHEN] Start the applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, AppliedGLEntry);

        // [THEN] The applied G/L entry will be fully applied
        AppliedGLEntry.Find('=');
        VerifyGLEntry(AppliedGLEntry);

        // [THEN] The applying G/L entry will be partly applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry,
            -(Abs(ApplyingGLEntry.Amount) - Abs(AppliedGLEntry.Amount)),
            -AppliedGLEntry.Amount, ApplyingGLEntry."Posting Date");
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerMultiple,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingPositiveGLEntryToMultipleNegativeGLEntriesWithPositiveBalance()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: array[2] of Record "G/L Entry";
        ListOfGLEntryNo: List of [Integer];
    begin
        // [SCENARIO] Applying positive G/L entry to multiple negative G/L entries with positive balance
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the highest positive amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '>%1', 0);
        ApplyingGLEntry.FindLast();

        // [GIVEN] The G/L entry with work date and the lowest negative amount has been found
        AppliedGLEntry[1].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[1].SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry[1].SetFilter(Amount, '<%1', 0);
        AppliedGLEntry[1].FindFirst();
        ListOfGLEntryNo.Add(AppliedGLEntry[1]."Entry No.");

        // [GIVEN] The G/L entry with work date and the second owest negative amount has been found
        AppliedGLEntry[2].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[2].SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry[2].SetFilter(Amount, '<%1&<%2', 0, AppliedGLEntry[1].Amount);
        AppliedGLEntry[2].FindFirst();
        ListOfGLEntryNo.Add(AppliedGLEntry[2]."Entry No.");

        // [WHEN] Start the applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, ListOfGLEntryNo);

        // [THEN] The applying G/L entry will be partly applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry,
            Abs(ApplyingGLEntry.Amount) - Abs(AppliedGLEntry[1].Amount) - Abs(AppliedGLEntry[2].Amount),
            Abs(AppliedGLEntry[1].Amount) + Abs(AppliedGLEntry[2].Amount), ApplyingGLEntry."Posting Date");
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerMultiple,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingPositiveGLEntryToMultipleNegativeGLEntriesAndDiffPostingDateWithPositiveBalance()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: array[2] of Record "G/L Entry";
        ListOfGLEntryNo: List of [Integer];
    begin
        // [SCENARIO] Applying positive G/L entry to multiple negative G/L entries and different posting date with positive balance
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the highest positive amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '>%1', 0);
        ApplyingGLEntry.FindLast();

        // [GIVEN] The G/L entry with work date + 1D and the lowest negative amount has been found
        AppliedGLEntry[1].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[1].SetRange("Posting Date", CalcDate('<CD+1D>', ApplyingGLEntry."Posting Date"));
        AppliedGLEntry[1].SetFilter(Amount, '<%1', 0);
        AppliedGLEntry[1].FindFirst();
        ListOfGLEntryNo.Add(AppliedGLEntry[1]."Entry No.");

        // [GIVEN] The G/L entry with work date + 1D and the second owest negative amount has been found
        AppliedGLEntry[2].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[2].SetRange("Posting Date", CalcDate('<CD+1D>', ApplyingGLEntry."Posting Date"));
        AppliedGLEntry[2].SetFilter(Amount, '<%1&<%2', 0, AppliedGLEntry[1].Amount);
        AppliedGLEntry[2].FindFirst();
        ListOfGLEntryNo.Add(AppliedGLEntry[2]."Entry No.");

        // [WHEN] Start the applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, ListOfGLEntryNo);

        // [THEN] The applying G/L entry will be fully applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry,
            Abs(ApplyingGLEntry.Amount) - Abs(AppliedGLEntry[1].Amount) - Abs(AppliedGLEntry[2].Amount),
            Abs(AppliedGLEntry[1].Amount) + Abs(AppliedGLEntry[2].Amount), AppliedGLEntry[1]."Posting Date");
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerMultiple,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingNegativeGLEntryToMultiplePositiveGLEntriesWithNegativeBalance()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: array[2] of Record "G/L Entry";
        ListOfGLEntryNo: List of [Integer];
    begin
        // [SCENARIO] Applying negative G/L entry to multiple positive G/L entries with negative balance
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the highest positive amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '<%1', 0);
        ApplyingGLEntry.FindLast();

        // [GIVEN] The G/L entry with work date and the lowest negative amount has been found
        AppliedGLEntry[1].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[1].SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry[1].SetFilter(Amount, '>%1', 0);
        AppliedGLEntry[1].FindFirst();
        ListOfGLEntryNo.Add(AppliedGLEntry[1]."Entry No.");

        // [GIVEN] The G/L entry with work date and the second owest negative amount has been found
        AppliedGLEntry[2].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[2].SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry[2].SetFilter(Amount, '>%1&>%2', 0, AppliedGLEntry[1].Amount);
        AppliedGLEntry[2].FindFirst();
        ListOfGLEntryNo.Add(AppliedGLEntry[2]."Entry No.");

        // [WHEN] Start the applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, ListOfGLEntryNo);

        // [THEN] The applying G/L entry will be partly applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry,
            -(Abs(ApplyingGLEntry.Amount) - Abs(AppliedGLEntry[1].Amount) - Abs(AppliedGLEntry[2].Amount)),
            -(Abs(AppliedGLEntry[1].Amount) + Abs(AppliedGLEntry[2].Amount)), ApplyingGLEntry."Posting Date");
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerSingle,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingPositiveGLEntryToGLEntryWithHigherAmount()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: Record "G/L Entry";
    begin
        // [SCENARIO] Applying positive G/L entry to G/L entry with higher amount
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the lowest positive amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '>%1', 0);
        ApplyingGLEntry.FindFirst();

        // [GIVEN] The G/L entry with work date has been found
        AppliedGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry.SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry.SetFilter(Amount, '<%1', 0);
        AppliedGLEntry.FindLast();

        // [WHEN] Start the applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, AppliedGLEntry);

        // [THEN] The applied G/L entry will be partly applied
        AppliedGLEntry.Find('=');
        VerifyGLEntry(AppliedGLEntry, -(Abs(AppliedGLEntry.Amount) - Abs(ApplyingGLEntry.Amount)), -ApplyingGLEntry.Amount, ApplyingGLEntry."Posting Date");

        // [THEN] The applying G/L entry will be fully applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry);
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerSingle,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingNegativeGLEntryToGLEntryWithHigherAmount()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: Record "G/L Entry";
    begin
        // [SCENARIO] Applying negative G/L entry to G/L entry with higher amount
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the lowest negative amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '<%1', 0);
        ApplyingGLEntry.FindFirst();

        // [GIVEN] The G/L entry with work date has been found
        AppliedGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry.SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry.SetFilter(Amount, '>%1', 0);
        AppliedGLEntry.FindLast();

        // [WHEN] Start the applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, AppliedGLEntry);

        // [THEN] The applied G/L entry will be partly applied
        AppliedGLEntry.Find('=');
        VerifyGLEntry(AppliedGLEntry, Abs(AppliedGLEntry.Amount) - Abs(ApplyingGLEntry.Amount), -ApplyingGLEntry.Amount, ApplyingGLEntry."Posting Date");

        // [THEN] The applying G/L entry will be fully applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry);
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerMultiple,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingPositiveGLEntryToMultipleNegativeGLEntries()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: array[2] of Record "G/L Entry";
        ListOfGLEntryNo: List of [Integer];
    begin
        // [SCENARIO] Applying positive G/L entry to multiple negative G/L entries
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the lowest positive amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '>%1', 0);
        ApplyingGLEntry.FindFirst();

        // [GIVEN] The G/L entry with work date and the lowest negative amount has been found
        AppliedGLEntry[1].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[1].SetRange("Posting Date", CalcDate('<CD+1D>', ApplyingGLEntry."Posting Date"));
        AppliedGLEntry[1].SetFilter(Amount, '<%1', 0);
        AppliedGLEntry[1].FindLast();
        ListOfGLEntryNo.Add(AppliedGLEntry[1]."Entry No.");

        // [GIVEN] The G/L entry with work date and the second lowest negative amount has been found
        AppliedGLEntry[2].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[2].SetRange("Posting Date", CalcDate('<CD+1D>', ApplyingGLEntry."Posting Date"));
        AppliedGLEntry[2].SetFilter(Amount, '<%1&>%2', 0, AppliedGLEntry[1].Amount);
        AppliedGLEntry[2].FindLast();
        ListOfGLEntryNo.Add(AppliedGLEntry[2]."Entry No.");

        // [WHEN] Start the applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, ListOfGLEntryNo);

        // [THEN] The applying G/L entry will be fully applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry, 0, ApplyingGLEntry.Amount, AppliedGLEntry[1]."Posting Date");
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerMultiple,ModalPostApplicationHandler,MessageHandler')]
    procedure ApplyingNegativeGLEntryToMultiplePositiveGLEntries()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: array[2] of Record "G/L Entry";
        ListOfGLEntryNo: List of [Integer];
    begin
        // [SCENARIO] Applying negative G/L entry to multiple positive G/L entries
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the lowest negative amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '<%1', 0);
        ApplyingGLEntry.FindFirst();

        // [GIVEN] The G/L entry with work date and the lowest negative amount has been found
        AppliedGLEntry[1].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[1].SetRange("Posting Date", CalcDate('<CD+1D>', ApplyingGLEntry."Posting Date"));
        AppliedGLEntry[1].SetFilter(Amount, '>%1', 0);
        AppliedGLEntry[1].FindLast();
        ListOfGLEntryNo.Add(AppliedGLEntry[1]."Entry No.");

        // [GIVEN] The G/L entry with work date and the second owest negative amount has been found
        AppliedGLEntry[2].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[2].SetRange("Posting Date", CalcDate('<CD+1D>', ApplyingGLEntry."Posting Date"));
        AppliedGLEntry[2].SetFilter(Amount, '>%1&<%2', 0, AppliedGLEntry[1].Amount);
        AppliedGLEntry[2].FindLast();
        ListOfGLEntryNo.Add(AppliedGLEntry[2]."Entry No.");

        // [WHEN] Start the applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, ListOfGLEntryNo);

        // [THEN] The applying G/L entry will be fully applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry, 0, ApplyingGLEntry.Amount, AppliedGLEntry[1]."Posting Date");
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerSingle,ModalPostApplicationHandler,MessageHandler')]
    procedure DoubleApplyingGLEntriesWithPositiveBalance()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: array[2] of Record "G/L Entry";
    begin
        // [SCENARIO] Double applying G/L Entries with positive balance
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the highest positive amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '>%1', 0);
        ApplyingGLEntry.FindLast();

        // [GIVEN] The G/L entry with work date and the abs value of amount less than applying amount has been found
        AppliedGLEntry[1].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[1].SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry[1].SetFilter(Amount, '<%1', 0);
        AppliedGLEntry[1].FindFirst();

        // [GIVEN] Applying of the G/L entries has been started
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, AppliedGLEntry[1]);

        // [GIVEN] The G/L entry with work date and the abs value of amount less than applying amount has been found
        AppliedGLEntry[2].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[2].SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry[2].SetFilter(Amount, '<%1&<%2', 0, AppliedGLEntry[1].Amount);
        AppliedGLEntry[2].FindFirst();

        // [WHEN] Start applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, AppliedGLEntry[2]);

        // [THEN] The applying G/L entry will be partly applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry,
            Abs(ApplyingGLEntry.Amount) - Abs(AppliedGLEntry[1].Amount) - Abs(AppliedGLEntry[2].Amount),
            -(AppliedGLEntry[1].Amount + AppliedGLEntry[2].Amount), ApplyingGLEntry."Posting Date");
    end;

    [Test]
    [HandlerFunctions('ModalApplyGLEntriesHandlerSingle,ModalPostApplicationHandler,MessageHandler')]
    procedure DoubleApplyingGLEntriesWithNegativeBalance()
    var
        ApplyingGLEntry: Record "G/L Entry";
        AppliedGLEntry: array[2] of Record "G/L Entry";
    begin
        // [SCENARIO] Double applying G/L Entries with negative balance
        Initialize();

        // [GIVEN] The general journal lines with more than 10 lines have been posted
        PostGenJournalLines();

        // [GIVEN] The G/L entry with work date and the lowest negative amount has been found
        ApplyingGLEntry.SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        ApplyingGLEntry.SetRange("Posting Date", WorkDate());
        ApplyingGLEntry.SetFilter(Amount, '<%1', 0);
        ApplyingGLEntry.FindLast();

        // [GIVEN] The G/L entry with work date and the abs value of amount less than applying amount has been found
        AppliedGLEntry[1].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[1].SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry[1].SetFilter(Amount, '>%1', 0);
        AppliedGLEntry[1].FindFirst();

        // [GIVEN] Applying of the G/L entries has been started
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, AppliedGLEntry[1]);

        // [GIVEN] The G/L entry with work date and the abs value of amount less than applying amount has been found
        AppliedGLEntry[2].SetFilter("Entry No.", '>%1', GetFromGLEntryNo());
        AppliedGLEntry[2].SetRange("Posting Date", ApplyingGLEntry."Posting Date");
        AppliedGLEntry[2].SetFilter(Amount, '>%1&>%2', 0, AppliedGLEntry[1].Amount);
        AppliedGLEntry[2].FindFirst();

        // [WHEN] Start applying of the G/L entries
        ApplyGLEntryFromGLEntry(ApplyingGLEntry, AppliedGLEntry[2]);

        // [THEN] The applying G/L entry will be partly applied
        ApplyingGLEntry.Find('=');
        VerifyGLEntry(ApplyingGLEntry,
            -(Abs(ApplyingGLEntry.Amount) - Abs(AppliedGLEntry[1].Amount) - Abs(AppliedGLEntry[2].Amount)),
            -(AppliedGLEntry[1].Amount + AppliedGLEntry[2].Amount), ApplyingGLEntry."Posting Date");
    end;

    local procedure PostGenJournalLines()
    begin
        PostGenJournalLines(WorkDate(), CalcDate('<CD+1D>', WorkDate()),
            LibraryRandom.RandDec(100, 2), LibraryRandom.RandIntInRange(10, 15));
    end;

    local procedure PostGenJournalLines(StartPostingDate: Date; EndPostingDate: Date; StartAmount: Decimal; LinesCount: Integer)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GLAccountNo: Code[20];
        Amount: Decimal;
        PostingDate: Date;
        i: Integer;
    begin
        SelectGenJournalBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        GLAccountNo := LibraryERM.CreateGLAccountNo();

        for PostingDate := StartPostingDate to EndPostingDate do begin
            i := 0;
            Amount := StartAmount;
            WorkDate := PostingDate;
            for i := 1 to LinesCount do begin
                LibraryERM.CreateGeneralJnlLineWithBalAcc(
                  GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::" ",
                  GenJournalLine."Account Type"::"G/L Account", GLAccountNo,
                  GenJournalLine."Account Type"::"G/L Account", GLAccountNo,
                  Amount);
                Amount += StartAmount;
            end;
        end;

        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        WorkDate := StartPostingDate;
    end;

    local procedure InitFromGLEntryNo()
    begin
        FromGLEntryNo := 0;
        FromGLEntryNo := GetFromGLEntryNo();
    end;

    local procedure GetFromGLEntryNo(): Integer
    begin
        if FromGLEntryNo = 0 then
            FromGLEntryNo := GetLastGLEntryNo() + 1;
        exit(FromGLEntryNo);
    end;

    local procedure GetLastGLEntryNo(): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.FindLast();
        exit(GLEntry."Entry No.");
    end;

    local procedure VerifyGLEntry(GLEntry: Record "G/L Entry")
    begin
        VerifyGLEntry(GLEntry, WorkDate());
    end;

    local procedure VerifyGLEntry(GLEntry: Record "G/L Entry"; PostingDate: Date)
    begin
        VerifyGLEntry(GLEntry, 0, GLEntry.Amount, PostingDate);
    end;

    local procedure VerifyGLEntry(GLEntry: Record "G/L Entry"; ExpectedRemainingAmount: Decimal; ExpectedAppliedAmount: Decimal; PostingDate: Date)
    var
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
    begin
        GLEntry.CalcFields("Applied Amount CZA");
        Assert.AreEqual(ExpectedRemainingAmount, GLEntry.RemainingAmountCZA(), 'Unexpected Remaining Amount.');
        Assert.AreEqual(ExpectedAppliedAmount, GLEntry."Applied Amount CZA", 'Unexpected Applied Amount.');
        DetailedGLEntryCZA.SetRange("G/L Entry No.", GLEntry."Entry No.");
        DetailedGLEntryCZA.FindFirst();
        Assert.AreEqual(PostingDate, DetailedGLEntryCZA."Posting Date", 'Unexpected Posting Date.');
    end;

    local procedure ApplyGenJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        Codeunit.Run(Codeunit::"Gen. Jnl.-Apply", GenJournalLine);
    end;

    local procedure SelectGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
    end;

    local procedure ApplyGLEntryFromGLEntry(var AppplyingGLEntry: Record "G/L Entry")
    var
        GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
    begin
        GLEntryPostApplicationCZA.ApplyGLEntry(AppplyingGLEntry);
    end;

    local procedure ApplyGLEntryFromGLEntry(var AppplyingGLEntry: Record "G/L Entry"; var AppliedGLEntry: Record "G/L Entry")
    var
        GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
    begin
        LibraryVariableStorage.Enqueue(AppliedGLEntry);
        GLEntryPostApplicationCZA.ApplyGLEntry(AppplyingGLEntry);
    end;

    local procedure ApplyGLEntryFromGLEntry(var AppplyingGLEntry: Record "G/L Entry"; AppliedGLEntryNoList: List of [Integer])
    var
        GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
    begin
        LibraryVariableStorage.Enqueue(AppliedGLEntryNoList);
        GLEntryPostApplicationCZA.ApplyGLEntry(AppplyingGLEntry);
    end;

    local procedure ApplyGLEntries()
    begin
        Commit();
        Report.Run(Report::"G/L Entry Applying CZA");
    end;

    [ModalPageHandler]
    procedure ModalApplyGLEntriesHandler(var ApplyGenLedgerEntriesCZA: TestPage "Apply Gen. Ledger Entries CZA")
    var
        FieldVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldVariant);
        ApplyGenLedgerEntriesCZA.Filter.SetFilter("Document No.", FieldVariant);
        ApplyGenLedgerEntriesCZA.First();
        LibraryVariableStorage.Dequeue(FieldVariant);
        if FieldVariant.IsCode then begin
            ApplyGenLedgerEntriesCZA."Set Applies-to ID".Invoke();
            ApplyGenLedgerEntriesCZA."Applies-to ID".AssertEquals(FieldVariant);
        end;
        if FieldVariant.IsDecimal then begin
            ApplyGenLedgerEntriesCZA."Amount to Apply".SetValue(FieldVariant);
            ApplyGenLedgerEntriesCZA."Post Application".Invoke();
        end;
        ApplyGenLedgerEntriesCZA.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ModalApplyGLEntriesHandlerSingle(var ApplyGenLedgerEntriesCZA: TestPage "Apply Gen. Ledger Entries CZA")
    var
        GLEntry: Record "G/L Entry";
        FieldVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldVariant);
        GLEntry := FieldVariant;
        ApplyGenLedgerEntriesCZA.Filter.SetFilter("Entry No.", Format(GLEntry."Entry No."));
        ApplyGenLedgerEntriesCZA.First();
        ApplyGenLedgerEntriesCZA."Set Applies-to ID".Invoke();
        ApplyGenLedgerEntriesCZA."Post Application".Invoke();
        ApplyGenLedgerEntriesCZA.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ModalApplyGLEntriesHandlerMultiple(var ApplyGenLedgerEntriesCZA: TestPage "Apply Gen. Ledger Entries CZA")
    var
        ListOfGLEntryNo: List of [Integer];
        GLEntryNo: Integer;
        FieldVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldVariant);
        ListOfGLEntryNo := FieldVariant;
        foreach GLEntryNo in ListOfGLEntryNo do begin
            ApplyGenLedgerEntriesCZA.Filter.SetFilter("Entry No.", Format(GLEntryNo));
            ApplyGenLedgerEntriesCZA.First();
            ApplyGenLedgerEntriesCZA."Set Applies-to ID".Invoke();
        end;
        ApplyGenLedgerEntriesCZA."Post Application".Invoke();
        ApplyGenLedgerEntriesCZA.OK().Invoke();
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