codeunit 18460 "Calculate Depreciation Tests"
{
    Subtype = Test;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        isInitialized: Boolean;
        CompletionStatsTok: Label 'The depreciation has been calculated.';
        AmountErr: Label '%1 must be %2 in %3.', Comment = '.';

    [Test]
    [HandlerFunctions('DepreciationCalcConfirmHandler')]
    [Scope('OnPrem')]
    procedure FAJournalWithCalcDepreciationReport()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        FAJournalLine: Record "FA Journal Line";
        FADepreciationBook: Record "FA Depreciation Book";
        FAAmount: Decimal;
        Amount: Decimal;
        NoOfMonth: Integer;
    begin
        // [SCENARIO] [458012] Check FA GL journal Line after Calculating Depreciation.
        // Create Fixed Asset with Depreciation Book Declining Balance %.
        Initialize();
        CreateFAWithDecliningBalanceFADeprBook(FADepreciationBook);
        FAAmount := LibraryRandom.RandDec(100, 2);
        CreateAndPostFAJournalLine(FADepreciationBook, FAAmount, FAJournalLine."FA Posting Type"::"Acquisition Cost");
        CreateAndPostFAJournalLine(FADepreciationBook, -FAAmount / 2, FAJournalLine."FA Posting Type"::"Salvage Value");
        CreateFAJournalSetup(FADepreciationBook."Depreciation Book Code");

        // Exercise: Calculate Depreciation. Required 12 for dividing Depreciation Value with Random Values.
        Amount := FAAmount / 2;
        NoOfMonth := LibraryRandom.RandInt(10);
        RunCalculateDepeciation(FADepreciationBook, FADepreciationBook."FA No.", NoOfMonth);
        Amount := Round((Amount * FADepreciationBook."Declining-Balance %" / 100) * NoOfMonth / 12);

        // Verify: Verify FA Journal Line with Calculated Depreciation Amount.
        GeneralLedgerSetup.Get();
        FAJournalLine.SetRange("FA No.", FADepreciationBook."FA No.");
        FAJournalLine.FindFirst();
        Assert.AreNearlyEqual(
          -Amount, FAJournalLine.Amount, GeneralLedgerSetup."Amount Rounding Precision",
          StrSubstNo(AmountErr, FAJournalLine.FieldCaption(Amount), -Amount, FAJournalLine.TableCaption()));
    end;

    local procedure RunCalculateDepeciation(FADepreciationBook: Record "FA Depreciation Book"; DocumentNo: Code[20]; NoOfMonth: Integer)
    begin
        SetRequestOption(FADepreciationBook, DocumentNo, NoOfMonth, false);
    end;

    local procedure SetRequestOption(FADepreciationBook: Record "FA Depreciation Book"; DocumentNo: Code[20]; NoOfMonth: Integer; InsertBalAccount: Boolean)
    var
        FixedAsset: Record "Fixed Asset";
        CalculateDepreciation: Report "Calculate Depreciation";
        PostingDate: Date;
    begin
        PostingDate := CalcDate('<' + Format(NoOfMonth) + 'M>', WorkDate());
        FixedAsset.SetRange("No.", FADepreciationBook."FA No.");
        Clear(CalculateDepreciation);
        CalculateDepreciation.SetTableView(FixedAsset);
        CalculateDepreciation.InitializeRequest(
          FADepreciationBook."Depreciation Book Code", PostingDate, false, 0, PostingDate, DocumentNo, '', InsertBalAccount);
        CalculateDepreciation.UseRequestPage(false);
        CalculateDepreciation.Run();
    end;

    local procedure CreateFAJournalSetup(DepreciationBookCode: Code[10])
    var
        FAJournalSetup: Record "FA Journal Setup";
        FAJournalBatch: Record "FA Journal Batch";
    begin
        SelectFAJournalBatch(FAJournalBatch);
        LibraryFixedAsset.CreateFAJournalSetup(FAJournalSetup, DepreciationBookCode, '');
        FAJournalSetup.Validate("FA Jnl. Template Name", FAJournalBatch."Journal Template Name");
        FAJournalSetup.Validate("FA Jnl. Batch Name", FAJournalBatch.Name);
        FAJournalSetup.Modify(true);
    end;

    local procedure SelectFAJournalBatch(var FAJournalBatch: Record "FA Journal Batch")
    var
        FAJournalTemplate: Record "FA Journal Template";
        FAJournalLine: Record "FA Journal Line";
    begin
        FAJournalTemplate.SetRange(Recurring, false);
        LibraryFixedAsset.FindFAJournalTemplate(FAJournalTemplate);
        LibraryFixedAsset.FindFAJournalBatch(FAJournalBatch, FAJournalTemplate.Name);
        FAJournalLine.SetRange("Journal Template Name", FAJournalBatch."Journal Template Name");
        FAJournalLine.SetRange("Journal Batch Name", FAJournalBatch.Name);
        FAJournalLine.DeleteAll(true);
    end;

    local procedure CreateAndPostFAJournalLine(FADepreciationBook: Record "FA Depreciation Book"; Amount: Decimal; FAPostingType: Enum "FA Journal Line FA Posting Type")
    var
        FAJournalLine: Record "FA Journal Line";
        FAJournalBatch: Record "FA Journal Batch";
    begin
        SelectFAJournalBatch(FAJournalBatch);
        LibraryFixedAsset.CreateFAJournalLine(FAJournalLine, FAJournalBatch."Journal Template Name", FAJournalBatch.Name);
        FAJournalLine.Validate("FA Posting Date", WorkDate());
        FAJournalLine.Validate("Document No.", GetDocumentNo(FAJournalBatch));
        FAJournalLine.Validate("FA No.", FADepreciationBook."FA No.");
        FAJournalLine.Validate("FA Posting Type", FAPostingType);
        FAJournalLine.Validate("Depreciation Book Code", FADepreciationBook."Depreciation Book Code");
        FAJournalLine.Validate(Amount, Amount);
        FAJournalLine.Modify(true);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);
    end;


    local procedure CreateFAWithDecliningBalanceFADeprBook(var FADepreciationBook: Record "FA Depreciation Book")
    var
        FixedAsset: Record "Fixed Asset";
        DepreciationBook: Record "Depreciation Book";
    begin
        // Setup: Create Fixed Asset and Depreciation Book with Random Declining Balance %.
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        DepreciationBook.Validate("Allow more than 360/365 Days", true);
        DepreciationBook.Modify(true);
        CreateFADepreciationBook(FADepreciationBook, FixedAsset."No.", FixedAsset."FA Posting Group", DepreciationBook.Code);
        FADepreciationBook.Validate("Depreciation Method", FADepreciationBook."Depreciation Method"::"Declining-Balance 1");
        FADepreciationBook.Validate("Declining-Balance %", LibraryRandom.RandDec(10, 2));
        FADepreciationBook.Modify(true);
    end;

    local procedure CreateFADepreciationBook(var FADepreciationBook: Record "FA Depreciation Book"; FANo: Code[20]; FAPostingGroupCode: Code[20]; DepreciationBookCode: Code[10])
    begin
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FANo, DepreciationBookCode);
        FADepreciationBook.Validate("FA Posting Group", FAPostingGroupCode);
        FADepreciationBook.Validate("Depreciation Starting Date", WorkDate());

        // Depreciation Ending Date greater than Depreciation Starting Date, Using the Random Number for the Year.
        FADepreciationBook.Validate("Depreciation Ending Date", CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate()));
        FADepreciationBook.Modify(true);
    end;


    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure DepreciationCalcConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        if 0 <> StrPos(Question, CompletionStatsTok) then
            Reply := false
        else
            Reply := true;
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Calculate Depreciation Tests");

        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Calculate Depreciation Tests");

        LibraryERMCountryData.CreateVATData();
        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Calculate Depreciation Tests");
    end;

    local procedure GetDocumentNo(FAJournalBatch: Record "FA Journal Batch"): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesCodeunit: Codeunit "No. Series";
    begin
        NoSeries.Get(FAJournalBatch."No. Series");
        exit(NoSeriesCodeunit.PeekNextNo(FAJournalBatch."No. Series"));
    end;

}