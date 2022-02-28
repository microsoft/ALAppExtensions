codeunit 148087 "Fixed Assets CZF"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryFixedAssetCZF: Codeunit "Library - Fixed Asset CZF";
        LibraryHumanResource: Codeunit "Library - Human Resource";
        LibraryRandom: Codeunit "Library - Random";
        isInitialized: Boolean;
        DepreciationGroupFilterErr: Label 'Depreciation Group Filter is not set.';

    local procedure Initialize()
    var
        FAJournalTemplate: Record "FA Journal Template";
        FAJournalBatch: Record "FA Journal Batch";
        FAJournalSetup: Record "FA Journal Setup";
        DepreciationBook: Record "Depreciation Book";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Fixed Assets CZF");
        LibraryVariableStorage.Clear();

        if isInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Fixed Assets CZF");

        CreateDepreciationBook(DepreciationBook);
        CreateFAJournalTemplate(FAJournalTemplate);
        CreateFAJournalBatch(FAJournalBatch, FAJournalTemplate.Name);
        CreateFAJournalSetup(
          FAJournalSetup, DepreciationBook.Code,
          FAJournalBatch."Journal Template Name", FAJournalBatch.Name);
        UpdateFASetup(DepreciationBook.Code);
        UpdateHumanResourcesSetup();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Fixed Assets CZF");
    end;

    [Test]
    [HandlerFunctions('NoConfirmHandler')]
    procedure CalculateDepreciationStraightLine()
    begin
        // [SCENARIO] Test the Posting of Calculated Depreciation with use Depreciation Group of Straight-line type
        CalculateDepreciation(Enum::"Tax Depreciation Type CZF"::"Straight-line");
    end;

    [Test]
    [HandlerFunctions('NoConfirmHandler')]
    procedure CalculateDepreciationDecliningBalance()
    begin
        // [SCENARIO] Test the Posting of Calculated Depreciation with use Depreciation Group of Declining-Balance type
        CalculateDepreciation(Enum::"Tax Depreciation Type CZF"::"Declining-Balance");
    end;

    [Test]
    [HandlerFunctions('NoConfirmHandler')]
    procedure CalculateDepreciationStraightLineIntangible()
    begin
        // [SCENARIO] Test the Posting of Calculated Depreciation with use Depreciation Group of Straight-line Intangible type
        CalculateDepreciation(Enum::"Tax Depreciation Type CZF"::"Straight-line Intangible");
    end;

    [HandlerFunctions('NoConfirmHandler')]
    local procedure CalculateDepreciation(TaxDepreciationTypeCZF: Enum "Tax Depreciation Type CZF")
    var
        FixedAsset: Record "Fixed Asset";
        FASetup: Record "FA Setup";
        FADepreciationBook: Record "FA Depreciation Book";
        TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
        FAJournalLine: Record "FA Journal Line";
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        Initialize();

        // [GIVEN] The FA Setup has been got
        FASetup.Get();

        // [GIVEN] The Fixed Asset and FA Depreciation Book have been created
        CreateFixedAsset(FixedAsset);
        CreateTaxDepreciationGroupCZF(TaxDepreciationGroupCZF, TaxDepreciationTypeCZF);
        CreateFADepreciationBook(
          FADepreciationBook, FixedAsset."No.",
          FASetup."Tax Depreciation Book CZF", TaxDepreciationGroupCZF.Code, true,
          FADepreciationBook."Depreciation Method"::"Straight-Line");

        if TaxDepreciationTypeCZF = TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line Intangible" then begin
            FADepreciationBook.Validate("No. of Depreciation Years", 3);
            FADepreciationBook.Modify(true);
        end;

        // [GIVEN] The FA Journal Line has been created
        CreateFAJournalLine(
          FAJournalLine, FASetup."Tax Depreciation Book CZF",
          FAJournalLine."FA Posting Type"::"Acquisition Cost", FixedAsset."No.");

        // [GIVEN] The FA Journal Line for Acquisition Cost has been posted
        PostFAJournalLine(FAJournalLine);

        // [GIVEN] The Calculate Depreciation has been executed
        RunCalculateDepreciation(FixedAsset, FASetup."Tax Depreciation Book CZF");

        // [WHEN] Post FA Journal Line for Depreciation
        PostDepreciationWithDocumentNo(FASetup."Tax Depreciation Book CZF");

        // [THEN] FA Ledger Entry for Depreciation will be created
        FALedgerEntry.SetCurrentKey("FA No.", "Depreciation Book Code");
        FALedgerEntry.SetRange("FA No.", FixedAsset."No.");
        FALedgerEntry.SetRange("Depreciation Book Code", FASetup."Tax Depreciation Book CZF");
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::Depreciation);
        Assert.RecordIsNotEmpty(FALedgerEntry);
    end;

    [Test]
    [HandlerFunctions('NoConfirmHandler')]
    procedure CalculateDepreciationWithInterruption()
    var
        FixedAsset: Record "Fixed Asset";
        FASetup: Record "FA Setup";
        FADepreciationBook: Record "FA Depreciation Book";
        TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
        FAJournalLine: Record "FA Journal Line";
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        // [SCENARIO] Test the Posting of Calculated Depreciation with use Depreciation Group of Straight-line type with Interruption
        Initialize();

        // [GIVEN] The FA Setup has been got
        FASetup.Get();

        // [GIVEN] The Fixed Asset and FA Depreciation Book have been created
        CreateFixedAsset(FixedAsset);
        CreateTaxDepreciationGroupCZF(TaxDepreciationGroupCZF, TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line");
        CreateFADepreciationBook(
          FADepreciationBook, FixedAsset."No.",
          FASetup."Tax Depreciation Book CZF", TaxDepreciationGroupCZF.Code, true,
          FADepreciationBook."Depreciation Method"::"Straight-Line");
        FADepreciationBook.Validate("No. of Depreciation Years", 3);
        FADepreciationBook.Modify(true);

        // [GIVEN] The FA Journal Line has been created
        CreateFAJournalLine(
          FAJournalLine, FASetup."Tax Depreciation Book CZF",
          FAJournalLine."FA Posting Type"::"Acquisition Cost", FixedAsset."No.");

        // [GIVEN] The FA Journal Line for Acquisition Cost has been posted
        PostFAJournalLine(FAJournalLine);

        // [GIVEN] The depreciation interruption has been setup
        FADepreciationBook.Find();
        FADepreciationBook.Validate("Deprec. Interrupted up to CZF", CalcDate('<-CY+1Y>', WorkDate()));
        FADepreciationBook.Modify(true);

        // [GIVEN] The Calculate Depreciation has been executed
        RunCalculateDepreciation(FixedAsset, FASetup."Tax Depreciation Book CZF");

        // [WHEN] Post FA Journal Line for Depreciation
        PostDepreciationWithDocumentNo(FASetup."Tax Depreciation Book CZF");

        // [THEN] The FA Ledger Entry for Depreciation with interruption will be created
        FALedgerEntry.SetCurrentKey("FA No.", "Depreciation Book Code");
        FALedgerEntry.SetRange("FA No.", FixedAsset."No.");
        FALedgerEntry.SetRange("Depreciation Book Code", FASetup."Tax Depreciation Book CZF");
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::Depreciation);
        FALedgerEntry.FindFirst();
        FALedgerEntry.TestField(Amount, 0);
    end;

    [Test]
    [HandlerFunctions('ModalCreateFAHistoryHandler,NoConfirmHandler')]
    procedure LoggingFixedAssetChanges()
    var
        FixedAsset: Record "Fixed Asset";
        Employee: Record Employee;
        FALocation: Record "FA Location";
        FAHistoryEntry: Record "FA History Entry CZF";
        FixedAssetCard: TestPage "Fixed Asset Card";
    begin
        // [SCENARIO] Verify that change of Responsible Employee or FA Location Code on the Fixed Asset Card will cause creation FA HIstory Entry
        Initialize();

        // [GIVEN] The FA History has been enabled in FA Setup
        UpdateFASetupWithFAHistory(true);

        // [GIVEN] The Employee has been created
        CreateEmployee(Employee);

        // [GIVEN] The FA Location has been created
        CreateFALocation(FALocation);

        // [GIVEN] The Fixed Asset has been created
        CreateFixedAsset(FixedAsset);

        // [WHEN] Validate "Responsible Employee" and "FA Location Code" fields on Fixed Asset Card
        FixedAssetCard.OpenEdit();
        FixedAssetCard.GoToRecord(FixedAsset);
        FixedAssetCard."Responsible Employee".SetValue(Employee."No.");
        FixedAssetCard."FA Location Code".SetValue(FALocation.Code);
        FixedAssetCard.OK().Invoke();

        // [THEN] The FA History Entry will be created
        FAHistoryEntry.SetCurrentKey("FA No.");
        FAHistoryEntry.SetRange("FA No.", FixedAsset."No.");
        FAHistoryEntry.SetRange(Type, FAHistoryEntry.Type::"Responsible Employee");
        FAHistoryEntry.FindFirst();
        FAHistoryEntry.TestField("New Value", Employee."No.");

        FAHistoryEntry.SetRange(Type, FAHistoryEntry.Type::"FA Location");
        FAHistoryEntry.FindFirst();
        FAHistoryEntry.TestField("New Value", FALocation.Code);

        // Teardown
        UpdateFASetupWithFAHistory(false);
    end;

    [Test]
    procedure PostingFixedAssetDisposal()
    var
        FixedAsset: Record "Fixed Asset";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
        FAPostingGroup: Record "FA Posting Group";
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
    begin
        // [SCENARIO] Test the Posting of Fixed Asset Disposal, change field "Disposed" on the FA Depreciation Book and
        // creation G/L Entry with G/L Account from FA Extended Posting Group
        Initialize();

        // [GIVEN] The Depreciation Book has been created
        CreateDepreciationBook(DepreciationBook);
        DepreciationBook.Validate("G/L Integration - Disposal", true);
        DepreciationBook.Modify(true);

        // [GIVEN] The FA Posting Group and FA Extended Posting Group have been created
        CreateFAPostingGroup(FAPostingGroup);
        CreateFAExtendedPostingGroupDisposal(FAExtendedPostingGroupCZF, FAPostingGroup.Code);

        // [GIVEN] The Fixed Asset and FA Depreciation Book have been created
        CreateFixedAsset(FixedAsset);
        CreateTaxDepreciationGroupCZF(TaxDepreciationGroupCZF, TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line");
        CreateFADepreciationBook(
          FADepreciationBook, FixedAsset."No.",
          DepreciationBook.Code, TaxDepreciationGroupCZF.Code, true,
          FADepreciationBook."Depreciation Method"::"Straight-Line");
        FADepreciationBook.Validate("FA Posting Group", FAPostingGroup.Code);
        FADepreciationBook.Validate("Acquisition Date", WorkDate());
        FADepreciationBook.Modify(true);

        // [GIVEN] The FA Journal Line has been created
        CreateGenJournalLine(
          GenJournalLine, DepreciationBook.Code,
          GenJournalLine."FA Posting Type"::Disposal, FixedAsset."No.");
        GenJournalLine.Validate("Reason Code", FAExtendedPostingGroupCZF.Code);
        GenJournalLine.Modify(true);

        // [WHEN] Post Gen. Journal Line

        PostGenJournalLine(GenJournalLine);

        // [THEN] The Fixed Asset will be Disposed
        FADepreciationBook.Get(FixedAsset."No.", DepreciationBook.Code);
        FADepreciationBook.TestField("Disposal Date");

        // [THEN] The G/L Account No. in the G/L Entry will have the same value as FAExtendedPostingGroupCZF."Sales Acc. On Disp. (Gain)"
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Document No.", GenJournalLine."Document No.");
        GLEntry.SetRange("Posting Date", GenJournalLine."Posting Date");
        GLEntry.FindFirst();
        GLEntry.TestField("G/L Account No.", FAExtendedPostingGroupCZF."Sales Acc. On Disp. (Gain)");
    end;

    local procedure CreateFixedAsset(var FixedAsset: Record "Fixed Asset")
    begin
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
    end;

    local procedure CreateFAJournalTemplate(var FAJournalTemplate: Record "FA Journal Template")
    begin
        LibraryFixedAsset.CreateJournalTemplate(FAJournalTemplate);
        FAJournalTemplate.SetRange(Recurring, false);
        FAJournalTemplate.Modify(true);
    end;

    local procedure CreateFAJournalBatch(var FAJournalBatch: Record "FA Journal Batch"; FAJournalTemplateName: Code[10])
    begin
        LibraryFixedAsset.CreateFAJournalBatch(FAJournalBatch, FAJournalTemplateName);
        FAJournalBatch.Validate("No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        FAJournalBatch.Modify(true);
    end;

    local procedure CreateFAJournalLine(var FAJournalLine: Record "FA Journal Line"; DepreciationBookCode: Code[10]; FAPostingType: Enum "FA Journal Line FA Posting Type"; FANo: Code[20])
    var
        FAJournalTemplate: Record "FA Journal Template";
        FAJournalBatch: Record "FA Journal Batch";
    begin
        CreateFAJournalTemplate(FAJournalTemplate);
        CreateFAJournalBatch(FAJournalBatch, FAJournalTemplate.Name);

        LibraryFixedAsset.CreateFAJournalLine(FAJournalLine, FAJournalBatch."Journal Template Name", FAJournalBatch.Name);
        FAJournalLine.Validate("Document No.", GetFAJournalLineDocumentNo(FAJournalBatch));
        FAJournalLine.Validate("Posting Date", WorkDate());
        FAJournalLine.Validate("FA Posting Date", WorkDate());
        FAJournalLine.Validate("FA Posting Type", FAPostingType);
        FAJournalLine.Validate("FA No.", FANo);
        FAJournalLine.Validate("Debit Amount", LibraryRandom.RandDec(1000, 2));
        FAJournalLine.Validate("Depreciation Book Code", DepreciationBookCode);
        FAJournalLine.Modify(true);
    end;

    local procedure CreateGenJournalTemplate(var GenJournalTemplate: Record "Gen. Journal Template")
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.SetRange(Recurring, false);
        GenJournalTemplate.Modify(true);
    end;

    local procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; GenJournalTemplateName: Code[10])
    begin
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplateName);
        GenJournalBatch.Validate("No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; DepreciationBookCode: Code[10]; FAPostingType: Enum "Gen. Journal Line FA Posting Type"; FANo: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalTemplate(GenJournalTemplate);
        CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::" ", GenJournalLine."Account Type"::"Fixed Asset", FANo, 0);
        GenJournalLine.Validate("Document No.", GetGenJournalLineDocumentNo(GenJournalBatch));
        GenJournalLine.Validate("Posting Date", WorkDate());
        GenJournalLine.Validate("FA Posting Date", WorkDate());
        GenJournalLine.Validate("FA Posting Type", FAPostingType);
        GenJournalLine.Validate("Depreciation Book Code", DepreciationBookCode);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateDepreciationBook(var DepreciationBook: Record "Depreciation Book")
    var
        FAPostingTypeSetup: Record "FA Posting Type Setup";
    begin
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        DepreciationBook.Validate("Disposal Calculation Method", DepreciationBook."Disposal Calculation Method"::Gross);
        DepreciationBook.Validate("Corresp. G/L Entries Disp. CZF", true);
        DepreciationBook.Validate("Corresp. FA Entries Disp. CZF", true);
        DepreciationBook.Validate("Deprec. from 1st Year Day CZF", true);
        DepreciationBook.Validate("Check Deprec. on Disposal CZF", true);
        DepreciationBook.Validate("Use FA Ledger Check", true);
        DepreciationBook.Validate("Use Rounding in Periodic Depr.", true);
        DepreciationBook.Modify(true);

        FAPostingTypeSetup.SetRange("Depreciation Book Code", DepreciationBook.Code);
        if FAPostingTypeSetup.FindSet() then
            repeat
                FAPostingTypeSetup."Include in Gain/Loss Calc." := true;
                FAPostingTypeSetup.Modify();
            until FAPostingTypeSetup.Next() = 0;
    end;

    local procedure CreateFADepreciationBook(var FADepreciationBook: Record "FA Depreciation Book"; FANo: Code[20]; DepreciationBookCode: Code[10]; DepreciationGroupCode: Code[20]; DefaultFADepreciationBook: Boolean; DepreciationMethod: Enum "FA Depreciation Method")
    var
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
    begin
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FANo, DepreciationBookCode);
        FADepreciationBook.Validate("Depreciation Starting Date", AccountingPeriodMgt.FindFiscalYear(WorkDate()));
        FADepreciationBook.Validate("Tax Deprec. Group Code CZF", DepreciationGroupCode);
        FADepreciationBook.Validate("Default FA Depreciation Book", DefaultFADepreciationBook);
        FADepreciationBook.Validate("Depreciation Method", DepreciationMethod);
        FADepreciationBook.Modify(true);
    end;

    local procedure CreateFAJournalSetup(var FAJournalSetup: Record "FA Journal Setup"; DepreciationBookCode: Code[10]; FAJournalTemplateName: Code[10]; FAJournalBatchName: Code[10])
    begin
        LibraryFixedAsset.CreateFAJournalSetup(FAJournalSetup, DepreciationBookCode, CopyStr(UserId(), 1, 50));
        FAJournalSetup.Validate("FA Jnl. Template Name", FAJournalTemplateName);
        FAJournalSetup.Validate("FA Jnl. Batch Name", FAJournalBatchName);
        FAJournalSetup.Modify(true);
    end;

    local procedure CreateTaxDepreciationGroupCZF(var TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF"; DepreciationType: Enum "Tax Depreciation Type CZF")
    begin
        LibraryFixedAssetCZF.CreateTaxDepreciationGroup(TaxDepreciationGroupCZF, CalcDate('<-CY-5Y>', WorkDate()));
        TaxDepreciationGroupCZF.Validate("Depreciation Group", LibraryFixedAssetCZF.GenerateDeprecationGroupCode());

        case DepreciationType of
            TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line":
                UpdateTaxDepreciationGroupCZFStraightLine(TaxDepreciationGroupCZF);
            TaxDepreciationGroupCZF."Depreciation Type"::"Declining-Balance":
                UpdateTaxDepreciationGroupCZFDecliningBalance(TaxDepreciationGroupCZF);
            TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line Intangible":
                UpdateTaxDepreciationGroupCZFStraightLineIntangible(TaxDepreciationGroupCZF);
        end;
    end;

    local procedure CreateFAPostingGroup(var FAPostingGroup: Record "FA Posting Group")
    begin
        LibraryFixedAsset.CreateFAPostingGroup(FAPostingGroup);
        FAPostingGroup.Validate("Custom 2 Account", GetNewGLAccountNo());
        FAPostingGroup.Modify(true);
    end;

    local procedure CreateFAExtendedPostingGroupDisposal(var FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF"; FAPostingGroupCode: Code[20])
    var
        ReasonCode: Record "Reason Code";
    begin
        CreateReasonCode(ReasonCode);
        LibraryFixedAssetCZF.CreateFAExtendedPostingGroup(
          FAExtendedPostingGroupCZF, FAPostingGroupCode, FAExtendedPostingGroupCZF."FA Posting Type"::Disposal, ReasonCode.Code);
        FAExtendedPostingGroupCZF.Validate("Book Val. Acc. on Disp. (Gain)", GetNewGLAccountNo());
        FAExtendedPostingGroupCZF.Validate("Book Val. Acc. on Disp. (Loss)", GetNewGLAccountNo());
        FAExtendedPostingGroupCZF.Validate("Sales Acc. On Disp. (Gain)", GetNewGLAccountNo());
        FAExtendedPostingGroupCZF.Validate("Sales Acc. On Disp. (Loss)", GetNewGLAccountNo());
        FAExtendedPostingGroupCZF.Modify(true);
    end;

    local procedure CreateReasonCode(var ReasonCode: Record "Reason Code")
    begin
        LibraryERM.CreateReasonCode(ReasonCode);
    end;

    local procedure CreateFALocation(var FALocation: Record "FA Location")
    begin
        LibraryFixedAssetCZF.CreateFALocation(FALocation);
    end;

    local procedure CreateEmployee(var Employee: Record Employee)
    begin
        LibraryHumanResource.CreateEmployee(Employee);
    end;

    local procedure CreateGLAccount(var GLAccount: Record "G/L Account")
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        LibraryERM.FindGeneralPostingSetup(GeneralPostingSetup);
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Gen. Posting Type", GLAccount."Gen. Posting Type"::Purchase);
        GLAccount.Validate("Gen. Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group");
        GLAccount.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        GLAccount.Modify(true);
    end;

    local procedure UpdateTaxDepreciationGroupCZFStraightLine(var TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF")
    begin
        TaxDepreciationGroupCZF.Validate("Depreciation Type", TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line");
        TaxDepreciationGroupCZF.Validate("No. of Depreciation Years", 3);
        TaxDepreciationGroupCZF.Validate("Straight First Year", 20);
        TaxDepreciationGroupCZF.Validate("Straight Next Years", 40);
        TaxDepreciationGroupCZF.Validate("Straight Appreciation", 33.3);
        TaxDepreciationGroupCZF.Modify(true);
    end;

    local procedure UpdateTaxDepreciationGroupCZFDecliningBalance(var TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF")
    begin
        TaxDepreciationGroupCZF.Validate("Depreciation Type", TaxDepreciationGroupCZF."Depreciation Type"::"Declining-Balance");
        TaxDepreciationGroupCZF.Validate("No. of Depreciation Years", 3);
        TaxDepreciationGroupCZF.Validate("Declining First Year", 3);
        TaxDepreciationGroupCZF.Validate("Declining Next Years", 4);
        TaxDepreciationGroupCZF.Validate("Declining Appreciation", 3);
        TaxDepreciationGroupCZF.Modify(true);
    end;

    local procedure UpdateTaxDepreciationGroupCZFStraightLineIntangible(var TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF")
    begin
        TaxDepreciationGroupCZF.Validate("Depreciation Type", TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line Intangible");
        TaxDepreciationGroupCZF.Validate("No. of Depreciation Years", 3);
        TaxDepreciationGroupCZF.Validate("Min. Months After Appreciation", 18);
        TaxDepreciationGroupCZF.Modify(true);
    end;

    local procedure UpdateFASetup(TaxDeprBookCode: Code[10])
    var
        FASetup: Record "FA Setup";
    begin
        FASetup.Get();
        FASetup.Validate("Tax Depreciation Book CZF", TaxDeprBookCode);
        FASetup.Validate("Fixed Asset Nos.", LibraryERM.CreateNoSeriesCode());
        FASetup.Modify(true);
    end;

    local procedure UpdateFASetupWithFAHistory(FixedAssetHistory: Boolean)
    var
        FASetup: Record "FA Setup";
    begin
        LibraryVariableStorage.Enqueue(WorkDate());
        FASetup.Get();
        FASetup.Validate("Fixed Asset History CZF", FixedAssetHistory);
        FASetup.Validate("Fixed Asset History Nos. CZF", LibraryERM.CreateNoSeriesCode());
        FASetup.Modify(true);
    end;

    local procedure UpdateHumanResourcesSetup()
    var
        HumanResourcesSetup: Record "Human Resources Setup";
    begin
        HumanResourcesSetup.Get();
        HumanResourcesSetup.Validate("Employee Nos.", LibraryERM.CreateNoSeriesCode());
        HumanResourcesSetup.Modify(true);
    end;

    local procedure GetFAJournalLineDocumentNo(FAJournalBatch: Record "FA Journal Batch"): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        NoSeries.Get(FAJournalBatch."No. Series");
        exit(NoSeriesManagement.GetNextNo(FAJournalBatch."No. Series", WorkDate(), false));
    end;

    local procedure GetGenJournalLineDocumentNo(GenJournalBatch: Record "Gen. Journal Batch"): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        NoSeries.Get(GenJournalBatch."No. Series");
        exit(NoSeriesManagement.GetNextNo(GenJournalBatch."No. Series", WorkDate(), false));
    end;

    local procedure GetNewGLAccountNo(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        CreateGLAccount(GLAccount);
        exit(GLAccount."No.");
    end;

    local procedure PostDepreciationWithDocumentNo(DepreciationBookCode: Code[10])
    var
        FAJournalLine: Record "FA Journal Line";
        FAJournalSetup: Record "FA Journal Setup";
        FAJournalBatch: Record "FA Journal Batch";
    begin
        FAJournalSetup.Get(DepreciationBookCode, UserId);
        FAJournalLine.SetRange("Journal Template Name", FAJournalSetup."FA Jnl. Template Name");
        FAJournalLine.SetRange("Journal Batch Name", FAJournalSetup."FA Jnl. Batch Name");
        FAJournalLine.FindFirst();

        FAJournalBatch.Get(FAJournalLine."Journal Template Name", FAJournalLine."Journal Batch Name");
        FAJournalBatch.Validate("No. Series", '');
        FAJournalBatch.Modify(true);

        PostFAJournalLine(FAJournalLine);
    end;

    local procedure PostFAJournalLine(var FAJournalLine: Record "FA Journal Line")
    begin
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);
    end;

    local procedure PostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure RunCalculateDepreciation(var FixedAsset: Record "Fixed Asset"; DepreciationBookCode: Code[10])
    begin
        FixedAsset.SetRecFilter();
        LibraryFixedAssetCZF.RunCalculateDepreciation(
          FixedAsset, DepreciationBookCode, CalcDate('<CY>', WorkDate()), FixedAsset."No.", FixedAsset.Description);
    end;

    [ModalPageHandler]
    procedure ModalTaxDepreciationGroupCZFsHandler(var TaxDepreciationGroupsCZF: TestPage "Tax Depreciation Groups CZF")
    begin
        Assert.IsTrue(
          TaxDepreciationGroupsCZF.Filter.GetFilter("Depreciation Group") = Format(LibraryVariableStorage.DequeueText()), DepreciationGroupFilterErr);
    end;

    [ModalPageHandler]
    procedure ModalCreateFAHistoryHandler(var CreateFAHistoryCZF: TestPage "Create FA History CZF")
    begin
        CreateFAHistoryCZF.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text)
    begin
        // Dummy Message Handler
    end;

    [ConfirmHandler]
    procedure NoConfirmHandler(Message: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;
}

