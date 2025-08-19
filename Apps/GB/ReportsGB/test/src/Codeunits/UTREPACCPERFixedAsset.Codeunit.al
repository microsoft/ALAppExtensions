codeunit 144021 "UT REP ACCPER - Fixed Asset"
{
    //  1. Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals FA Posting Group.
    //  2. Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals FA Class.
    //  3. Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals FA Subclass.
    //  4. Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals FA Location.
    //  5. Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals Global Dimension 1.
    //  6. Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals Global Dimension 2.
    //  7. Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals Main Asset.
    //  8. Purpose of the test is to validate Insert Bal Account - OnValidate  Trigger of Report 10560 (FA - Projected Value) for G/L Budget Name Error.
    //  9. Purpose of the test is to validate No. Of Days - OnValidate Trigger of Report 10560 (FA - Projected Value).
    // 10. Purpose of the test is to validate OnPreReport Trigger of Report 10560 (FA - Projected Value) with Print Per Fixed Asset as True.
    // 11. Purpose of the test is to validate OnPreReport Trigger of Report 10560 (FA - Projected Value) with Use Custom 1 Depreciation as False.
    // 12. Purpose of the test is to validate OnPreReport Trigger of Report 10560 (FA - Projected Value) with Use Custom 1 Depreciation as True.
    // 13. Purpose of the test is to validate OnPreReport Trigger of Report 10560 (FA - Projected Value) with No. of days.
    // 14. Purpose of the test is to validate FA Ledger Entry - OnAfterGetRecord Trigger of Report 10560 (FA - Projected Value).
    // 15. Purpose of the test is to validate Fixed Asset - OnAfterGetRecord Trigger of Report 10560 (FA - Projected Value) with Projected Disposal as True.
    // 16. Purpose of the test is to validate Fixed Asset - OnAfterGetRecord Trigger of Report 10560 (FA - Projected Value) with Projected Disposal as False.
    // 
    // Covers Test Cases for WI - 340397
    // ----------------------------------------------------------------------------------------------------------------------------
    // Test Function Name                                                                                                   TFS ID
    // ----------------------------------------------------------------------------------------------------------------------------
    // OnPreDataItemFixedAssetFAPostingFAProjectedValue, OnPreDataItemFixedAssetFAClassFAProjectedValue
    // OnPreDataItemFixedAssetFASubClassFAProjectedValue, OnPreDataItemFixedAssetFALocationFAProjectedValue
    // OnPreDataItemFixedAssetGlobalDim1FAProjectedValue, OnPreDataItemFixedAssetGlobalDim2FAProjectedValue
    // OnPreDataItemFixedAssetMainAsssetFAProjectedValue, OnValidateFAProjectedValueInsertBalAccountError
    // OnValidateNumberOfDaysFAProjectedValue, OnPreReportTruePrintPerFixedAssetFAProjectedValue
    // OnPreReportFalseUseCustom1DeprFAProjectedValue, OnPreReportTrueUseCustom1DeprFAProjectedValue
    // OnPreReportFAProjectedValueNoOfDaysError, OnAfterGetRecordFALedgerEntryFAProjectedValue
    // OnAfterGetRecFATrueProjectedDisposalFAProjectedVal, OnAfterGetRecFAFalseProjectedDisposalFAProjectedVal              159704,159705,159792

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        GroupCodeNameCapLbl: Label 'GroupCodeName';
        GroupHeadLineCapLbl: Label 'GroupHeadLine';
        GroupTotalsCapLbl: Label 'Group Totals';
        MainAssetCapLbl: Label 'Main Asset';
        DepreciationCapLbl: Label 'Depreciation';
        Custom1TextCapLbl: Label 'Custom1Text';
        DeprCustom1TextCapLbl: Label 'DeprCustom1Text';

    [Test]
    [HandlerFunctions('FAProjectedValueWithGroupTotalReqPageHandler')]

    procedure OnPreDataItemFixedAssetFAPostingFAProjectedValue()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals FA Posting Group.
        Initialize();
        RunFAProjectedValueAfterPostFAGLJournals(FixedAsset, GroupTotals::"FA Posting Group");

        // Verify.
        VerifyXMLData(FixedAsset.FieldCaption("FA Posting Group"), FixedAsset."FA Posting Group");
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithGroupTotalReqPageHandler')]

    procedure OnPreDataItemFixedAssetFAClassFAProjectedValue()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals FA Class.
        Initialize();
        RunFAProjectedValueAfterPostFAGLJournals(FixedAsset, GroupTotals::"FA Class");

        // Verify.
        VerifyXMLData(FixedAsset.FieldCaption("FA Class Code"), FixedAsset."FA Class Code");
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithGroupTotalReqPageHandler')]

    procedure OnPreDataItemFixedAssetFASubClassFAProjectedValue()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals FA Subclass.
        Initialize();
        RunFAProjectedValueAfterPostFAGLJournals(FixedAsset, GroupTotals::"FA Subclass");

        // Verify.
        VerifyXMLData(FixedAsset.FieldCaption("FA Subclass Code"), FixedAsset."FA Subclass Code");
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithGroupTotalReqPageHandler')]

    procedure OnPreDataItemFixedAssetFALocationFAProjectedValue()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals FA Location.
        Initialize();
        RunFAProjectedValueAfterPostFAGLJournals(FixedAsset, GroupTotals::"FA Location");

        // Verify.
        VerifyXMLData(FixedAsset.FieldCaption("FA Location Code"), StrSubstNo('%1%2', FixedAsset."FA Location Code", '*****'));
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithGroupTotalReqPageHandler')]

    procedure OnPreDataItemFixedAssetGlobalDim1FAProjectedValue()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals Global Dimension 1.
        Initialize();
        RunFAProjectedValueAfterPostFAGLJournals(FixedAsset, GroupTotals::"Global Dimension 1");

        // Verify.
        VerifyXMLData(
          FixedAsset.FieldCaption("Global Dimension 1 Code"), StrSubstNo('%1%2', FixedAsset."Global Dimension 1 Code", '*****'));
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithGroupTotalReqPageHandler')]

    procedure OnPreDataItemFixedAssetGlobalDim2FAProjectedValue()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals Global Dimension 2.
        Initialize();
        RunFAProjectedValueAfterPostFAGLJournals(FixedAsset, GroupTotals::"Global Dimension 2");

        // Verify.
        VerifyXMLData(
          FixedAsset.FieldCaption("Global Dimension 2 Code"), StrSubstNo('%1%2', FixedAsset."Global Dimension 2 Code", '*****'));
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithGroupTotalReqPageHandler')]

    procedure OnPreDataItemFixedAssetMainAsssetFAProjectedValue()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // Purpose of the test is to validate Fixed Asset - OnPreDataItem Trigger of Report 10560 (FA - Projected Value) with Group Totals Main Asset.
        Initialize();
        RunFAProjectedValueAfterPostFAGLJournals(FixedAsset, GroupTotals::"Main Asset");

        // Verify.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(GroupCodeNameCapLbl, StrSubstNo('%1%2 %3', GroupTotalsCapLbl, ':', MainAssetCapLbl));
        LibraryReportDataset.AssertElementWithValueExists(GroupHeadLineCapLbl, MainAssetCapLbl + ' *****');
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithInsertBalAccReqPageHandler')]

    procedure OnValidateFAProjectedValueInsertBalAccountError()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // Purpose of the test is to validate Insert Bal Account - OnValidate Trigger of Report 10560 (FA - Projected Value) for G/L Budget Name Error.
        Initialize();
        asserterror RunFAProjectedValueAfterPostFAGLJournals(FixedAsset, GroupTotals);

        // Verify: Verify Actual Error - "You must specify G/L Budget Name."
        Assert.ExpectedErrorCode('TestValidation');
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithPrintperFAReqPageHandler')]

    procedure OnValidateNumberOfDaysFAProjectedValue()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // Purpose of the test is to validate No. Of Days - OnValidate Trigger of Report 10560 (FA - Projected Value).
        Initialize();
        RunFAProjectedValueAfterPostFAGLJournals(FixedAsset, GroupTotals);

        // Verify.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists('Fixed_Asset__No__', FixedAsset."No.");
        LibraryReportDataset.AssertElementWithValueExists('Fixed_Asset_FA_Posting_Group', FixedAsset."FA Posting Group");
        LibraryReportDataset.AssertElementWithValueExists('PrintDetails', true);
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithPrintperFAReqPageHandler')]

    procedure OnPreReportTruePrintPerFixedAssetFAProjectedValue()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // Purpose of the test is to validate OnPreReport Trigger of Report 10560 (FA - Projected Value) with Print Per Fixed Asset as True.
        Initialize();
        RunFAProjectedValueAfterPostFAGLJournals(FixedAsset, GroupTotals);

        // Verify.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists('FANo', FixedAsset.FieldCaption("No."));
        LibraryReportDataset.AssertElementWithValueExists('FADescription', FixedAsset.FieldCaption(Description));
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithGroupTotalReqPageHandler')]

    procedure OnPreReportFalseUseCustom1DeprFAProjectedValue()
    begin
        // Purpose of the test is to validate OnPreReport Trigger of Report 10560 (FA - Projected Value) with Use Custom 1 Depreciation as False.
        Initialize();
        RunFAProjectedValAfterPostFAGLJnlWithDiffDeprBook(false, 0, false, LibraryRandom.RandDec(10, 2));  // UseCustom1Depreciation as False. Take Random Amount.

        // Verify.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(Custom1TextCapLbl, '');
        LibraryReportDataset.AssertElementWithValueExists(DeprCustom1TextCapLbl, '');
        LibraryReportDataset.AssertElementWithValueExists('DeprText', 'Depreciation');
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithGroupTotalReqPageHandler')]

    procedure OnPreReportTrueUseCustom1DeprFAProjectedValue()
    var
        FAPostingTypeSetup: Record "FA Posting Type Setup";
    begin
        // Purpose of he test is to validate OnPreReport Trigger of Report 10560 (FA - Projected Value) with Use Custom 1 Depreciation as True.
        Initialize();
        RunFAProjectedValAfterPostFAGLJnlWithDiffDeprBook(true, 0, false, LibraryRandom.RandDec(10, 2));  // UseCustom1Depreciation as True, UseAccountingPeriods as False, Take Random Amount.

        // Verify.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(Custom1TextCapLbl, Format(FAPostingTypeSetup."FA Posting Type"::"Custom 1"));
        LibraryReportDataset.AssertElementWithValueExists(
          DeprCustom1TextCapLbl, DepreciationCapLbl + ' + ' + Format(FAPostingTypeSetup."FA Posting Type"::"Custom 1"));
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithGroupTotalReqPageHandler')]

    procedure OnPreReportFAProjectedValueNoOfDaysError()
    begin
        // Purpose of the test is to validate OnPreReport Trigger of Report 10560 (FA - Projected Value) with No. Of Days.
        Initialize();
        asserterror
          RunFAProjectedValAfterPostFAGLJnlWithDiffDeprBook(
            false, LibraryRandom.RandInt(5), false, LibraryRandom.RandDec(10, 2));  // UseCustom1Depreciation and UseAccountingPeriods as False. Take Random Amount and No Of Days.

        // Verify: Verify Actual Error - "Actual error message: Number of Days must not be greater."
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    [HandlerFunctions('FAProjectedValueWithNumberOfDaysReqPageHandler')]

    procedure OnAfterGetRecordFALedgerEntryFAProjectedValue()
    var
        Amount: Decimal;
    begin
        // Purpose of the test is to validate FA Ledger Entry - OnAfterGetRecord Trigger of Report 10560 (FA - Projected Value).
        Initialize();
        Amount := LibraryRandom.RandDec(10, 2);
        RunFAProjectedValAfterPostFAGLJnlWithDiffDeprBook(false, 0, true, Amount); // UseCustom1Depreciation as False, UseAccountingPeriods as True, Take Random Amount.

        // Verify.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists('TotalBookValue_1_', Amount);
    end;

    [Test]
    [HandlerFunctions('FAProjectedValWithProjectedDisposalReqPageHandler')]

    procedure OnAfterGetRecFATrueProjectedDisposalFAProjectedVal()
    begin
        // Purpose of the test is to validate Fixed Asset - OnAfterGetRecord Trigger of Report 10560 (FA - Projected Value) with Projected Disposal as True.
        Initialize();
        RunFAProjectedValAfterPostFAGLJnlWithProjectedDisposal(true);  // Projected Disposal as True.
    end;

#if not CLEAN27
    [Test]
    [HandlerFunctions('FAProjectedValWithProjectedDisposalReqPageHandler')]

    procedure OnAfterGetRecFAFalseProjectedDisposalFAProjectedVal()
    begin
        // Purpose of the test is to validate Fixed Asset - OnAfterGetRecord Trigger of Report 10560 (FA - Projected Value) with Projected Disposal as False.
        Initialize();
        RunFAProjectedValAfterPostFAGLJnlWithProjectedDisposal(false);  // Projected Disposal as False.
    end;

    local procedure RunFAProjectedValAfterPostFAGLJnlWithProjectedDisposal(ProjectedDisposal: Boolean)
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // Setup: Post FA G/L Journals With FA Depreciation Book. Transaction Model is Autocommit because explicit commit used in Code unit ID: 13, Gen. Jnl.-Post Batch.
        PostFAGLJournalsWithFADepreciationBook(FixedAsset, GroupTotals, LibraryRandom.RandDec(10, 2));  // Take Random Amount.
        LibraryVariableStorage.Enqueue(ProjectedDisposal);  // Enqueue for FAProjectedValWithProjectedDisposalReqPageHandler.

        // Exercise.
        REPORT.Run(REPORT::"FA - Projected Value GB");

        // Verify.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists('DoProjectedDisposal', ProjectedDisposal);
    end;
#endif    

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
    end;

    local procedure CreateAndPostFAGLJournals(var GenJournalLine: Record "Gen. Journal Line"; FixedAssetNo: Code[20]; DepreciationBookCode: Code[10]; BalAccountNo: Code[20]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalBatchAndTemplate(GenJournalBatch);
        GenJournalLine."Journal Template Name" := GenJournalBatch."Journal Template Name";
        GenJournalLine."Journal Batch Name" := GenJournalBatch.Name;
        GenJournalLine."Posting Date" := WorkDate();
        GenJournalLine."Document No." := LibraryUTUtility.GetNewCode();
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Fixed Asset";
        GenJournalLine."Account No." := FixedAssetNo;
        GenJournalLine."Depreciation Book Code" := DepreciationBookCode;
        GenJournalLine."FA Posting Type" := GenJournalLine."FA Posting Type"::"Acquisition Cost";
        GenJournalLine.Amount := Amount;
        GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
        GenJournalLine."Bal. Account No." := BalAccountNo;
        GenJournalLine.Insert();
        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJournalLine);  // It is required for post FA G/L Journals.
    end;

    local procedure CreateDepreciationBook(): Code[10]
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        DepreciationBook.Code := LibraryUTUtility.GetNewCode10();
        DepreciationBook."G/L Integration - Acq. Cost" := true;
        DepreciationBook.Insert();
        exit(DepreciationBook.Code);
    end;

    local procedure CreateFAClass(): Code[10]
    var
        FAClass: Record "FA Class";
    begin
        FAClass.Code := LibraryUTUtility.GetNewCode10();
        FAClass.Insert();
        exit(FAClass.Code);
    end;

    local procedure CreateFADepreciationBook(FixedAsset: Record "Fixed Asset"): Code[10]
    var
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        FADepreciationBook."FA No." := FixedAsset."No.";
        FADepreciationBook."Depreciation Book Code" := CreateDepreciationBook();
        FADepreciationBook."FA Posting Group" := FixedAsset."FA Posting Group";
        FADepreciationBook."Acquisition Cost" := LibraryRandom.RandDec(10, 2);
        FADepreciationBook."Depreciation Starting Date" := CalcDate('<-' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        FADepreciationBook."Depreciation Ending Date" := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        FADepreciationBook."Projected Disposal Date" := CalcDate('<-' + Format(LibraryRandom.RandInt(5)) + 'M>', WorkDate());
        FADepreciationBook.Insert();
        exit(FADepreciationBook."Depreciation Book Code");
    end;

    local procedure CreateFAPostingGroup(var FAPostingGroup: Record "FA Posting Group")
    begin
        FAPostingGroup.Code := LibraryUTUtility.GetNewCode10();
        FAPostingGroup."Acquisition Cost Account" := CreateGLAccount();
        FAPostingGroup.Insert();
    end;

    local procedure CreateFAPostingTypeSetup(DepreciationBookCode: Code[10]; FAPostingType: Enum "FA Posting Type Setup Type")
    var
        FAPostingTypeSetup: Record "FA Posting Type Setup";
    begin
        FAPostingTypeSetup."Depreciation Book Code" := DepreciationBookCode;
        FAPostingTypeSetup."FA Posting Type" := FAPostingType;
        FAPostingTypeSetup.Insert();
    end;

    local procedure CreateFASubClass(): Code[10]
    var
        FASubclass: Record "FA Subclass";
    begin
        FASubclass.Code := LibraryUTUtility.GetNewCode10();
        FASubclass.Insert();
        exit(FASubclass.Code);
    end;

    local procedure CreateFixedAsset(var FixedAsset: Record "Fixed Asset"): Code[20]
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        CreateFAPostingGroup(FAPostingGroup);
        FixedAsset."No." := LibraryUTUtility.GetNewCode();
        FixedAsset.Description := LibraryUTUtility.GetNewCode();
        FixedAsset."FA Class Code" := CreateFAClass();
        FixedAsset."FA Subclass Code" := CreateFASubClass();
        FixedAsset."FA Posting Group" := FAPostingGroup.Code;
        FixedAsset.Insert();
        LibraryVariableStorage.Enqueue(FixedAsset."No.");  // Enqueue for FAProjectedValueRequestPageHandler.
        exit(FAPostingGroup."Acquisition Cost Account");
    end;

    local procedure CreateGenJournalBatchAndTemplate(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.Name := LibraryUTUtility.GetNewCode10();
        GenJournalTemplate.Type := GenJournalTemplate.Type::Assets;
        GenJournalTemplate.Insert();
        GenJournalBatch."Journal Template Name" := GenJournalTemplate.Name;
        GenJournalBatch.Name := LibraryUTUtility.GetNewCode10();
        GenJournalBatch.Insert();
    end;

    local procedure CreateGLAccount(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount."No." := LibraryUTUtility.GetNewCode();
        GLAccount.Insert();
        exit(GLAccount."No.");
    end;

    local procedure CreateMultipleFAPostingTypeSetup(DepreciationBookCode: Code[10])
    var
        FAPostingTypeSetup: Record "FA Posting Type Setup";
    begin
        CreateFAPostingTypeSetup(DepreciationBookCode, FAPostingTypeSetup."FA Posting Type"::"Write-Down");
        CreateFAPostingTypeSetup(DepreciationBookCode, FAPostingTypeSetup."FA Posting Type"::"Custom 1");
        CreateFAPostingTypeSetup(DepreciationBookCode, FAPostingTypeSetup."FA Posting Type"::"Custom 2");
        CreateFAPostingTypeSetup(DepreciationBookCode, FAPostingTypeSetup."FA Posting Type"::Appreciation);
    end;

    local procedure ModifyDepreciationBook(DepreciationBookCode: Code[10]; UseCustom1Depreciation: Boolean; NoOfDaysInFiscalYear: Integer; UseAccountingPeriod: Boolean)
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        DepreciationBook.Get(DepreciationBookCode);
        DepreciationBook."Use Custom 1 Depreciation" := UseCustom1Depreciation;
        DepreciationBook."No. of Days in Fiscal Year" := NoOfDaysInFiscalYear;
        DepreciationBook."Use Accounting Period" := UseAccountingPeriod;
        DepreciationBook.Modify();
    end;

    local procedure RunFAProjectedValueAfterPostFAGLJournals(var FixedAsset: Record "Fixed Asset"; GroupTotals: Option)
    begin
        // Setup:  Post FA G/L Journals With FA Depreciation Book. Transaction Model is Autocommit because explicit commit used in Code unit ID: 13, Gen. Jnl.-Post Batch.
        PostFAGLJournalsWithFADepreciationBook(FixedAsset, GroupTotals, LibraryRandom.RandDec(10, 2));  // Take Random Amount.

        // Exercise.
        REPORT.Run(REPORT::"FA - Projected Value GB");
    end;

    local procedure RunFAProjectedValAfterPostFAGLJnlWithDiffDeprBook(UseCustom1Depreciation: Boolean; NoOfDaysInFiscalYear: Integer; UseAccountingPeriods: Boolean; Amount: Decimal)
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
        DepreciationBookCode: Code[10];
    begin
        // Setup.
        DepreciationBookCode := PostFAGLJournalsWithFADepreciationBook(FixedAsset, GroupTotals, Amount);
        ModifyDepreciationBook(DepreciationBookCode, UseCustom1Depreciation, NoOfDaysInFiscalYear, UseAccountingPeriods);
        Commit();  // Explicit Commit Required, because explicit commit used in Code unit ID: 13, Gen. Jnl.-Post Batch.

        // Exercise.
        REPORT.Run(REPORT::"FA - Projected Value GB");
    end;

    local procedure PostFAGLJournalsWithFADepreciationBook(var FixedAsset: Record "Fixed Asset"; GroupTotals: Option; Amount: Decimal): Code[10]
    var
        GenJournalLine: Record "Gen. Journal Line";
        AcquisitionCostAccount: Code[20];
        DepreciationBookCode: Code[10];
    begin
        AcquisitionCostAccount := CreateFixedAsset(FixedAsset);
        DepreciationBookCode := CreateFADepreciationBook(FixedAsset);
        CreateMultipleFAPostingTypeSetup(DepreciationBookCode);
        CreateAndPostFAGLJournals(
          GenJournalLine, FixedAsset."No.", DepreciationBookCode, AcquisitionCostAccount, Amount);
        LibraryVariableStorage.Enqueue(DepreciationBookCode);  // Enqueue for FAProjectedValueWithGroupTotalReqPageHandler.
        LibraryVariableStorage.Enqueue(GroupTotals);  // Enqueue for FAProjectedValueWithGroupTotalReqPageHandler.
        exit(DepreciationBookCode);
    end;

    local procedure SetValuesOnFAProjectedValueRequestPage(var FAProjectedValue: TestRequestPage "FA - Projected Value GB")
    var
        No: Variant;
        DepreciationBook: Variant;
        GroupTotals: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        LibraryVariableStorage.Dequeue(DepreciationBook);
        LibraryVariableStorage.Dequeue(GroupTotals);
        FAProjectedValue."Fixed Asset".SetFilter("No.", No);
        FAProjectedValue.DepreciationBook.SetValue(DepreciationBook);
        FAProjectedValue.FirstDepreciationDate.SetValue(WorkDate());
        FAProjectedValue.LastDepreciationDate.SetValue(CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate()));
        FAProjectedValue.GroupTotals.SetValue(GroupTotals);
    end;

    local procedure VerifyXMLData(GroupTotalsValue: Text; GroupHeadLineValue: Code[20])
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(
          GroupCodeNameCapLbl, StrSubstNo('%1%2 %3', GroupTotalsCapLbl, ':', GroupTotalsValue));
        LibraryReportDataset.AssertElementWithValueExists(GroupHeadLineCapLbl, GroupHeadLineValue);
    end;

    [RequestPageHandler]

    procedure FAProjectedValueWithGroupTotalReqPageHandler(var FAProjectedValue: TestRequestPage "FA - Projected Value GB")
    begin
        SetValuesOnFAProjectedValueRequestPage(FAProjectedValue);
        FAProjectedValue.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]

    procedure FAProjectedValueWithInsertBalAccReqPageHandler(var FAProjectedValue: TestRequestPage "FA - Projected Value GB")
    begin
        SetValuesOnFAProjectedValueRequestPage(FAProjectedValue);
        FAProjectedValue.InsertBalAccount.SetValue(true);
        FAProjectedValue.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]

    procedure FAProjectedValueWithPrintperFAReqPageHandler(var FAProjectedValue: TestRequestPage "FA - Projected Value GB")
    begin
        SetValuesOnFAProjectedValueRequestPage(FAProjectedValue);
        FAProjectedValue.CopyToGLBudgetName.SetValue('');
        FAProjectedValue.PrintPerFixedAsset.SetValue(true);
        FAProjectedValue.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]

    procedure FAProjectedValWithProjectedDisposalReqPageHandler(var FAProjectedValue: TestRequestPage "FA - Projected Value GB")
    var
        ProjectedDisposal: Variant;
    begin
        SetValuesOnFAProjectedValueRequestPage(FAProjectedValue);
        LibraryVariableStorage.Dequeue(ProjectedDisposal);
        FAProjectedValue.ProjectedDisposal.SetValue(ProjectedDisposal);
        FAProjectedValue.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]

    procedure FAProjectedValueWithNumberOfDaysReqPageHandler(var FAProjectedValue: TestRequestPage "FA - Projected Value GB")
    begin
        SetValuesOnFAProjectedValueRequestPage(FAProjectedValue);
        FAProjectedValue."Number of Days".SetValue(LibraryRandom.RandInt(10));
        FAProjectedValue.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}

