// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Test.ExciseTaxes;

using Microsoft.ExciseTaxes;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Posting;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Sustainability.ExciseTax;
using System.TestLibraries.Utilities;

codeunit 148351 "Excise Tax Calculation Tests"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryExciseTax: Codeunit "Library - Excise Tax";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        TotalTaxAmtMismatchTransLogPurchaseLbl: Label 'Total tax amount mismatch in transaction log for purchase';
        UnexpectedJournalLineCntLbl: Label 'Unexpected number of excise journal lines';
        UnexpectedTransLogCntLbl: Label 'Unexpected number of excise tax transaction log entries';
        ExciseRecordNotCreatedLbl: Label '%1 was not created successfully', Comment = '%1= TableCaption';
        ExciseTaxBasisMismatchLbl: Label 'Excise Tax Basis mismatch';
        QtyForExciseTaxMissingLbl: Label 'Qty for Excise Tax was not populated';

    [Test]
    procedure ExciseTaxTypeCreationForWeightBasis()
    var
        ExciseTaxBasis: Enum "Excise Tax Basis";
        TaxTypeCode: Code[20];
    begin
        // [SCENARIO 453721]Verify Excise Tax Type and Rate creation for By weight basis tax.
        Initialize();

        // [WHEN] Create Excise tax of By weight basis with hierarchical rate
        TaxTypeCode := LibraryExciseTax.SetupTaxType(ExciseTaxBasis::Weight);

        // [THEN] Excise Tax Type created with Weight basis
        VerifyTaxTypeCreated(TaxTypeCode, ExciseTaxBasis::Weight);

        // [THEN] Excise Tax Rate created for Item source type
        VerifyTaxRateCreated(TaxTypeCode, Enum::"Excise Source Type"::Item);
    end;

    [Test]
    procedure ExciseTaxTypeCreationForSugarContentBasis()
    var
        ExciseTaxBasis: Enum "Excise Tax Basis";
        TaxTypeCode: Code[20];
    begin
        // [SCENARIO 453721] Verify Excise Tax Type and Rate creation for By sugar content basis tax.
        Initialize();

        // [WHEN] Create Excise tax of By sugar content basis with hierarchical rate
        TaxTypeCode := LibraryExciseTax.SetupTaxType(ExciseTaxBasis::"Sugar Content");

        // [THEN] Excise Tax Type created with Sugar Content basis
        VerifyTaxTypeCreated(TaxTypeCode, ExciseTaxBasis::"Sugar Content");

        // [THEN] Excise Tax Rate created for Item source type
        VerifyTaxRateCreated(TaxTypeCode, Enum::"Excise Source Type"::Item);
    end;

    [Test]
    procedure ExciseTaxTypeCreationForTHCContentBasis()
    var
        ExciseTaxBasis: Enum "Excise Tax Basis";
        TaxTypeCode: Code[20];
    begin
        // [SCENARIO 453721] Verify Excise Tax Type and Rate creation for By THC content basis tax.
        Initialize();

        // [WHEN] Create Excise tax of By THC content basis with hierarchical rate
        TaxTypeCode := LibraryExciseTax.SetupTaxType(ExciseTaxBasis::"THC Content");

        // [THEN] Excise Tax Type created with THC Content basis
        VerifyTaxTypeCreated(TaxTypeCode, ExciseTaxBasis::"THC Content");

        // [THEN] Excise Tax Rate created for Item source type
        VerifyTaxRateCreated(TaxTypeCode, Enum::"Excise Source Type"::Item);
    end;

    [Test]
    procedure ExciseTaxTypeCreationForVolumeBasis()
    var
        ExciseTaxBasis: Enum "Excise Tax Basis";
        TaxTypeCode: Code[20];
    begin
        // [SCENARIO 453721] Verify Excise Tax Type and Rate creation for By volume basis tax.
        Initialize();

        // [WHEN] Create Excise tax of By volume basis with hierarchical rate
        TaxTypeCode := LibraryExciseTax.SetupTaxType(ExciseTaxBasis::Volume);

        // [THEN] Excise Tax Type created with Volume basis
        VerifyTaxTypeCreated(TaxTypeCode, ExciseTaxBasis::Volume);

        // [THEN] Excise Tax Rate created for Item source type
        VerifyTaxRateCreated(TaxTypeCode, Enum::"Excise Source Type"::Item);
    end;

    [Test]
    procedure ExciseTaxTypeCreationForSpiritVolumeBasis()
    var
        ExciseTaxBasis: Enum "Excise Tax Basis";
        TaxTypeCode: Code[20];
    begin
        // [SCENARIO 453721] Verify Excise Tax Type and Rate creation for By spirit volume basis tax.
        Initialize();

        // [WHEN] Create Excise tax of By spirit volume basis with hierarchical rate
        TaxTypeCode := LibraryExciseTax.SetupTaxType(ExciseTaxBasis::"Spirit Volume");

        // [THEN] Excise Tax Type created with Spirit Volume basis
        VerifyTaxTypeCreated(TaxTypeCode, ExciseTaxBasis::"Spirit Volume");

        // [THEN] Excise Tax Rate created for Item source type
        VerifyTaxRateCreated(TaxTypeCode, Enum::"Excise Source Type"::Item);
    end;

    [Test]
    procedure ItemExciseDetail()
    var
        Item: Record Item;
        ExciseTaxBasis: Enum "Excise Tax Basis";
        TaxTypeCode: Code[20];
    begin
        // [SCENARIO 453721] Verify Item excise tax detail populated.
        Initialize();

        // [GIVEN] Create Excise tax of By weight basis with hierarchical rate
        TaxTypeCode := LibraryExciseTax.SetupTaxType(ExciseTaxBasis::Weight);

        // [WHEN] Create item with excise tax
        LibraryExciseTax.CreateItemWithExciseTax(Item, TaxTypeCode);

        // [THEN] Verify item excise tax detail populated
        VerifyItemExciseTaxDetail(Item."No.", TaxTypeCode);
    end;

    [Test]
    procedure FAExciseDetail()
    var
        FixedAsset: Record "Fixed Asset";
        ExciseTaxBasis: Enum "Excise Tax Basis";
        TaxTypeCode: Code[20];
    begin
        // [SCENARIO 453721] Verify Fixed Asset excise tax detail populated.
        Initialize();

        // [GIVEN] Create Excise tax of By weight basis with hierarchical rate
        TaxTypeCode := LibraryExciseTax.SetupTaxType(ExciseTaxBasis::Weight);

        // [WHEN] Create fixed asset with excise tax
        LibraryExciseTax.CreateFixedAssetWithExciseTax(FixedAsset, TaxTypeCode);

        // [THEN] Verify FA excise tax detail populated
        VerifyFAExciseDetail(FixedAsset."No.", TaxTypeCode);
    end;

    [Test]
    [HandlerFunctions('ExciseTaxReportRequestPageHandler,MessageHandler')]
    procedure ExciseTaxJournalLineGenerationFromPurchase()
    var
        Item: Record Item;
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustExciseJnlLine: Record "Sust. Excise Jnl. Line";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        ExciseTaxBasis: Enum "Excise Tax Basis";
        TaxTypeCode: Code[20];
        Quantity: Decimal;
        TaxPercentage: Decimal;
    begin
        // [SCENARIO 453721] Calculate Excise by weight from Purchase ILEs and verify journal lines and transaction log.
        Initialize();

        //[GIVEN] Random tax percentage between 1 and 10; random quantities for 3 purchase ILEs.
        Quantity := LibraryRandom.RandInt(2000);
        TaxPercentage := LibraryRandom.RandInt(10);

        // [GIVEN] Create Excise tax of By weight basis with hierarchical rate; create item with excise tax; create 3 purchase ILEs for the item.
        TaxTypeCode := LibraryExciseTax.SetupTaxType(ExciseTaxBasis::Weight);

        // [GIVEN] Create item with excise tax
        LibraryExciseTax.CreateItemWithExciseTax(Item, TaxTypeCode);

        // [GIVEN] Create hierarchical rate for item source type
        LibraryExciseTax.CreateExciseTaxItemFARate(TaxTypeCode, Enum::"Excise Source Type"::Item, Item."No.", TaxPercentage, CalcDate('<-CY>', WorkDate()), LibraryRandom.RandText(10));

        // [GIVEN] Configure excise journal batch for excise journal line generation
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();
        SustExciseJournalBatch.Validate(Type, SustExciseJournalBatch.Type::Excises);
        SustExciseJournalBatch.Validate("Excise Tax Type Filter", TaxTypeCode);
        SustExciseJournalBatch.Modify(true);

        // [GIVEN] Create and post purchase documents to generate ILEs
        CreateAndPostPurchase(Item."No.", Quantity);

        // [WHEN] Generate excise journal lines from ILEs within date range; hierarchical rate applied; one journal line per ILE.
        GenerateExciseJournalLines(SustExciseJournalBatch);

        // [THEN] Verify journal line count for tax type
        SustExciseJnlLine.SetRange("Journal Template Name", SustExciseJournalBatch."Journal Template Name");
        SustExciseJnlLine.SetRange("Journal Batch Name", SustExciseJournalBatch.Name);
        SustExciseJnlLine.SetRange("Excise Tax Type", TaxTypeCode);
        SustExciseJnlLine.FindSet();
        Assert.AreEqual(1, SustExciseJnlLine.Count(), UnexpectedJournalLineCntLbl);
    end;

    [Test]
    [HandlerFunctions('ExciseTaxReportRequestPageHandler,MessageHandler')]
    procedure NoJournalLinesGeneratedWhenEntryTypeNotAllowed()
    var
        Item: Record Item;
        ExciseTaxType: Record "Excise Tax Type";
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustExciseJnlLine: Record "Sust. Excise Jnl. Line";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        ExciseTaxBasis: Enum "Excise Tax Basis";
        Quantity: Decimal;
        TaxPercentage: Decimal;
    begin
        // [SCENARIO 453721] No excise journal lines generated when purchase entry type not allowed.
        Initialize();

        //[GIVEN] Random tax percentage between 1 and 10; random quantities for 3 purchase ILEs.
        Quantity := LibraryRandom.RandInt(2000);
        TaxPercentage := LibraryRandom.RandInt(10);

        // [GIVEN] Create Excise tax of By weight basis with hierarchical rate; create item with excise tax; create 3 purchase ILEs for the item.
        ExciseTaxType := LibraryExciseTax.CreateExciseTaxType('', ExciseTaxBasis::Weight, true);

        LibraryExciseTax.CreateExciseTaxEntryPermission(ExciseTaxType.Code, "Excise Entry Type"::Purchase, false);

        // [GIVEN] Create item with excise tax
        LibraryExciseTax.CreateItemWithExciseTax(Item, ExciseTaxType.Code);

        // [GIVEN] Create hierarchical rate for item source type
        LibraryExciseTax.CreateExciseTaxItemFARate(ExciseTaxType.Code, Enum::"Excise Source Type"::Item, Item."No.", TaxPercentage, CalcDate('<-CY>', WorkDate()), LibraryRandom.RandText(10));

        // [GIVEN] Configure excise journal batch for excise journal line generation
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();
        SustExciseJournalBatch.Validate(Type, SustExciseJournalBatch.Type::Excises);
        SustExciseJournalBatch.Validate("Excise Tax Type Filter", ExciseTaxType.Code);
        SustExciseJournalBatch.Modify(true);

        // [GIVEN] Create and post purchase documents to generate ILEs
        CreateAndPostPurchase(Item."No.", Quantity);

        // [WHEN] Generate excise journal lines from ILEs within date range; hierarchical rate applied; one journal line per ILE.
        GenerateExciseJournalLines(SustExciseJournalBatch);

        // [THEN] Verify journal line count for tax type
        SustExciseJnlLine.SetRange("Journal Template Name", SustExciseJournalBatch."Journal Template Name");
        SustExciseJnlLine.SetRange("Journal Batch Name", SustExciseJournalBatch.Name);
        SustExciseJnlLine.SetRange("Excise Tax Type", ExciseTaxType.Code);
        Assert.AreEqual(0, SustExciseJnlLine.Count(), UnexpectedJournalLineCntLbl);
    end;

    [Test]
    [HandlerFunctions('ExciseTaxReportRequestPageHandler,MessageHandler')]
    procedure OneExciseJournalLineGeneratedWhenTwoILEPosted()
    var
        Item: Record Item;
        ExciseTaxType: Record "Excise Tax Type";
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustExciseJnlLine: Record "Sust. Excise Jnl. Line";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        ExciseTaxBasis: Enum "Excise Tax Basis";
        Quantity: Decimal;
        TaxPercentage: Decimal;
    begin
        // [SCENARIO 453721] One excise journal line generated when two ILEs posted for same item on same date.
        Initialize();

        //[GIVEN] Random tax percentage between 1 and 10; random quantities for 3 purchase ILEs.
        Quantity := LibraryRandom.RandInt(2000);
        TaxPercentage := LibraryRandom.RandInt(10);

        // [GIVEN] Create Excise tax of By weight basis with hierarchical rate; create item with excise tax; create 3 purchase ILEs for the item.
        ExciseTaxType := LibraryExciseTax.CreateExciseTaxType('', ExciseTaxBasis::Weight, true);

        LibraryExciseTax.CreateExciseTaxEntryPermission(ExciseTaxType.Code, "Excise Entry Type"::Sale, true);

        // [GIVEN] Create item with excise tax
        LibraryExciseTax.CreateItemWithExciseTax(Item, ExciseTaxType.Code);

        // [GIVEN] Create hierarchical rate for item source type
        LibraryExciseTax.CreateExciseTaxItemFARate(ExciseTaxType.Code, Enum::"Excise Source Type"::Item, Item."No.", TaxPercentage, CalcDate('<-CY>', WorkDate()), LibraryRandom.RandText(10));

        // [GIVEN] Configure excise journal batch for excise journal line generation
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();
        SustExciseJournalBatch.Validate(Type, SustExciseJournalBatch.Type::Excises);
        SustExciseJournalBatch.Validate("Excise Tax Type Filter", ExciseTaxType.Code);
        SustExciseJournalBatch.Modify(true);

        // [GIVEN] Create and post purchase and sales documents to generate ILEs
        CreateAndPostPurchase(Item."No.", Quantity);
        CreateAndPostSales(Item."No.", Quantity);

        // [WHEN] Generate excise journal lines from ILEs within date range; hierarchical rate applied; one journal line per ILE.
        GenerateExciseJournalLines(SustExciseJournalBatch);

        // [THEN] Verify journal line count for tax type
        SustExciseJnlLine.SetRange("Journal Template Name", SustExciseJournalBatch."Journal Template Name");
        SustExciseJnlLine.SetRange("Journal Batch Name", SustExciseJournalBatch.Name);
        SustExciseJnlLine.SetRange("Excise Tax Type", ExciseTaxType.Code);
        Assert.AreEqual(1, SustExciseJnlLine.Count(), UnexpectedJournalLineCntLbl);
    end;

    [Test]
    [HandlerFunctions('ExciseTaxReportRequestPageHandler,MessageHandler,UIConfirmHandler')]
    procedure VerifyJournalLinesForPurchaseEntries()
    var
        Item: Record Item;
        ExciseJournalLine: Record "Sust. Excise Jnl. Line";
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        ExciseTaxBasis: Enum "Excise Tax Basis";
        TaxTypeCode: Code[20];
        Quantity: array[3] of Decimal;
        ExpectedTotal: Decimal;
        TaxPercentage: Decimal;
    begin
        // [SCENARIO 453721] Calculate Excise by weight from Purchase ILEs and verify journal lines and transaction log.
        Initialize();

        //[GIVEN] Random tax percentage between 1 and 10; random quantities for 3 purchase ILEs.
        Quantity[1] := LibraryRandom.RandInt(2000);
        Quantity[2] := LibraryRandom.RandInt(3000);
        Quantity[3] := LibraryRandom.RandInt(4000);
        TaxPercentage := LibraryRandom.RandInt(10);

        // [GIVEN] Create Excise tax of By weight basis with hierarchical rate; create item with excise tax; create 3 purchase ILEs for the item.
        TaxTypeCode := LibraryExciseTax.SetupTaxType(ExciseTaxBasis::Weight);

        // [GIVEN] Create item with excise tax
        LibraryExciseTax.CreateItemWithExciseTax(Item, TaxTypeCode);

        // [GIVEN] Create hierarchical rate for item source type
        LibraryExciseTax.CreateExciseTaxItemFARate(TaxTypeCode, Enum::"Excise Source Type"::Item, Item."No.", TaxPercentage, CalcDate('<-CY>', WorkDate()), LibraryRandom.RandText(10));

        // [GIVEN] Configure excise journal batch for excise journal line generation
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();
        SustExciseJournalBatch.Validate(Type, SustExciseJournalBatch.Type::Excises);
        SustExciseJournalBatch.Validate("Excise Tax Type Filter", TaxTypeCode);
        SustExciseJournalBatch.Modify(true);

        // [GIVEN] Create and post purchase documents to generate ILEs
        CreateAndPostPurchase(Item."No.", Quantity[1]);
        CreateAndPostPurchase(Item."No.", Quantity[2]);
        CreateAndPostPurchase(Item."No.", Quantity[3]);

        // [WHEN] Generate excise journal lines from ILEs within date range; hierarchical rate applied; one journal line per ILE.
        GenerateExciseJournalLines(SustExciseJournalBatch);

        // [THEN] Verify journal line count for tax type
        VerifyJournalLineCountForTaxType(TaxTypeCode, 3);

        // [GIVEN] Sum journal amounts for tax type
        ExpectedTotal := SumJournalTaxAmountForTaxType(TaxTypeCode);

        // [GIVEN] Update Description in Excise Journal Line.
        ExciseJournalLine.SetRange("Journal Template Name", SustExciseJournalBatch."Journal Template Name");
        ExciseJournalLine.SetRange("Journal Batch Name", SustExciseJournalBatch.Name);
        ExciseJournalLine.ModifyAll(Description, LibraryRandom.RandText(100));

        // [WHEN] Register excise journal
        RegisterExciseJournal(SustExciseJournalBatch."Journal Template Name", SustExciseJournalBatch.Name);

        // [THEN] "Sust. Excise Jnl. Line" contains 3 lines with tax amounts 150, 90, 60; total 300. "Sust. Excise Taxes Trans. Log" has 3 entries mirroring journal lines.
        VerifyTransactionLogCountForTaxType(TaxTypeCode, 3);
        Assert.AreEqual(ExpectedTotal, SumTransactionLogTaxAmountForTaxType(TaxTypeCode), TotalTaxAmtMismatchTransLogPurchaseLbl);
    end;

    [Test]
    [HandlerFunctions('ExciseTaxReportRequestPageHandler,MessageHandler,UIConfirmHandler')]
    procedure VerifyFAJournalLinesForAcquisitionCost()
    var
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        ExciseJournalLine: Record "Sust. Excise Jnl. Line";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        ExciseTaxBasis: Enum "Excise Tax Basis";
        TaxTypeCode: Code[20];
        ExpectedTotal: Decimal;
        TaxPercentage: Decimal;
    begin
        // [SCENARIO 453721] Calculate Excise by weight from FA Acquisition Cost and verify journal lines and transaction log.
        Initialize();

        //[GIVEN] Random tax percentage between 1 and 10.
        TaxPercentage := LibraryRandom.RandInt(10);

        // [GIVEN] Create Excise tax of By weight basis with hierarchical rate; create fixed asset with excise tax; post acquisition cost.
        TaxTypeCode := LibraryExciseTax.SetupTaxType(ExciseTaxBasis::Weight);

        LibraryExciseTax.CreateFixedAssetWithExciseTax(FixedAsset, TaxTypeCode);
        // [GIVEN] Create hierarchical rate for fixed asset source type
        LibraryExciseTax.CreateExciseTaxItemFARate(TaxTypeCode, Enum::"Excise Source Type"::"Fixed Asset", FixedAsset."No.", TaxPercentage, CalcDate('<-CY>', WorkDate()), LibraryRandom.RandText(10));

        // [GIVEN] Setup fixed asset depreciation and post acquisition cost
        CreateFixedAssetWithSetup(FixedAsset, DepreciationBook);
        CreateAndPostAcqCost(FixedAsset."No.", DepreciationBook.Code);

        // [GIVEN] Configure excise journal batch for excise journal line generation
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();
        SustExciseJournalBatch.Validate(Type, SustExciseJournalBatch.Type::Excises);
        SustExciseJournalBatch.Validate("Excise Tax Type Filter", TaxTypeCode);
        SustExciseJournalBatch.Modify(true);

        // [WHEN] Generate excise journal lines from ILEs within date range; hierarchical rate applied; one journal line per ILE.
        GenerateExciseJournalLines(SustExciseJournalBatch);

        // [THEN] Verify journal line count for tax type
        VerifyJournalLineCountForTaxType(TaxTypeCode, 1);

        // [GIVEN] Sum journal amounts for tax type
        ExpectedTotal := SumJournalTaxAmountForTaxType(TaxTypeCode);

        // [GIVEN] Update Description in Excise Journal Line.
        ExciseJournalLine.SetRange("Journal Template Name", SustExciseJournalBatch."Journal Template Name");
        ExciseJournalLine.SetRange("Journal Batch Name", SustExciseJournalBatch.Name);
        ExciseJournalLine.SetRange("Excise Tax Type", TaxTypeCode);
        ExciseJournalLine.ModifyAll(Description, LibraryRandom.RandText(100));

        // [WHEN] Register excise journal
        RegisterExciseJournal(SustExciseJournalBatch."Journal Template Name", SustExciseJournalBatch.Name);

        // [THEN] "Sust. Excise Jnl. Line" contains 1 line for FA acquisition cost. "Sust. Excise Taxes Trans. Log" has 1 entry mirroring the journal line.
        VerifyTransactionLogCountForTaxType(TaxTypeCode, 1);
        Assert.AreEqual(ExpectedTotal, SumTransactionLogTaxAmountForTaxType(TaxTypeCode), TotalTaxAmtMismatchTransLogPurchaseLbl);
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryExciseTax.CleanupExciseTaxData();

        if IsInitialized then
            exit;

        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);

        IsInitialized := true;
    end;

    local procedure VerifyFAExciseDetail(FANo: Code[20]; TaxTypeCode: Code[20])
    var
        FixedAsset: Record "Fixed Asset";
    begin
        FixedAsset.Get(FANo);
        Assert.AreEqual(TaxTypeCode, FixedAsset."Excise Tax Type", ExciseTaxBasisMismatchLbl);
        Assert.IsTrue(FixedAsset."Quantity for Excise Tax" <> 0, QtyForExciseTaxMissingLbl);
        Assert.IsTrue(FixedAsset."Excise Unit of Measure Code" <> '', QtyForExciseTaxMissingLbl);
    end;

    local procedure VerifyItemExciseTaxDetail(ItemNo: Code[20]; TaxTypeCode: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Assert.AreEqual(TaxTypeCode, Item."Excise Tax Type", ExciseTaxBasisMismatchLbl);
        Assert.IsTrue(Item."Quantity for Excise Tax" <> 0, QtyForExciseTaxMissingLbl);
        Assert.IsTrue(Item."Excise Unit of Measure Code" <> '', QtyForExciseTaxMissingLbl);
    end;

    local procedure VerifyTaxTypeCreated(TaxTypeCode: Code[20]; TaxBasis: Enum "Excise Tax Basis")
    var
        ExciseTaxType: Record "Excise Tax Type";
    begin
        ExciseTaxType.Get(TaxTypeCode);
        Assert.IsTrue(ExciseTaxType."Code" = TaxTypeCode, StrSubstNo(ExciseRecordNotCreatedLbl, ExciseTaxType.TableCaption()));
        Assert.IsTrue(ExciseTaxType."Tax Basis" = TaxBasis, ExciseTaxBasisMismatchLbl);
    end;

    local procedure VerifyTaxRateCreated(TaxTypeCode: Code[20]; SourceType: Enum "Excise Source Type")
    var
        ExciseTaxItemFARate: Record "Excise Tax Item/FA Rate";
    begin
        ExciseTaxItemFARate.SetRange("Excise Tax Type Code", TaxTypeCode);
        ExciseTaxItemFARate.SetRange("Source Type", SourceType);
        ExciseTaxItemFARate.FindFirst();
        Assert.IsTrue(ExciseTaxItemFARate."Excise Tax Type Code" = TaxTypeCode, StrSubstNo(ExciseRecordNotCreatedLbl, ExciseTaxItemFARate.TableCaption()));
    end;

    local procedure CreateFixedAssetWithSetup(FixedAsset: Record "Fixed Asset"; var DepreciationBook: Record "Depreciation Book")
    begin
        CreateFixedAssetSetup(DepreciationBook);
        CreateFADepreciationBook(FixedAsset."No.", DepreciationBook.Code, FixedAsset."FA Posting Group");
        UpdateIntegrationInBook(DepreciationBook, false, false, false);
    end;

    local procedure CreateFADepreciationBook(FANo: Code[20]; DepreciationBookCode: Code[10]; FAPostingGroup: Code[20])
    var
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FANo, DepreciationBookCode);
        FADepreciationBook.Validate("Depreciation Book Code", DepreciationBookCode);
        FADepreciationBook.Validate("Depreciation Starting Date", WorkDate());

        // Random Number Generator for Ending date.
        FADepreciationBook.Validate("Depreciation Ending Date", CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate()));
        FADepreciationBook.Validate("FA Posting Group", FAPostingGroup);
        FADepreciationBook.Modify(true);
    end;

    local procedure UpdateIntegrationInBook(var DepreciationBook: Record "Depreciation Book"; Depreciation: Boolean; Disposal: Boolean; VATOnNetDisposalEntries: Boolean)
    begin
        DepreciationBook.Validate("G/L Integration - Acq. Cost", false);
        DepreciationBook.Validate("G/L Integration - Depreciation", Depreciation);
        DepreciationBook.Validate("G/L Integration - Write-Down", false);
        DepreciationBook.Validate("G/L Integration - Appreciation", false);
        DepreciationBook.Validate("G/L Integration - Disposal", Disposal);
        DepreciationBook.Validate("G/L Integration - Custom 1", false);
        DepreciationBook.Validate("G/L Integration - Custom 2", false);
        DepreciationBook.Validate("G/L Integration - Maintenance", false);
        DepreciationBook.Validate("VAT on Net Disposal Entries", VATOnNetDisposalEntries);
        DepreciationBook.Modify(true);
    end;

    local procedure CreateFixedAssetSetup(var DepreciationBook: Record "Depreciation Book")
    var
        FAJournalSetup: Record "FA Journal Setup";
    begin
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        LibraryFixedAsset.CreateFAJournalSetup(FAJournalSetup, DepreciationBook.Code, '');
        UpdateFAJournalSetup(FAJournalSetup);
        UpdateFAPostingTypeSetup(DepreciationBook.Code);
    end;

    local procedure UpdateFAPostingTypeSetup(DepreciationBookCode: Code[10])
    var
        FAPostingTypeSetup: Record "FA Posting Type Setup";
    begin
        FAPostingTypeSetup.SetRange("Depreciation Book Code", DepreciationBookCode);
        FAPostingTypeSetup.ModifyAll("Include in Gain/Loss Calc.", true);
    end;

    local procedure CreateAndPostAcqCost(FANo: Code[20]; DeprBookCode: Code[10])
    var
        FAJournalLine: Record "FA Journal Line";
        FAJournalBatch: Record "FA Journal Batch";
    begin
        CreateFAJournalBatch(FAJournalBatch);

        CreateFAJournalLine(
          FAJournalLine, FAJournalBatch, FAJournalLine."FA Posting Type"::"Acquisition Cost", FANo,
          DeprBookCode, LibraryRandom.RandDec(1000, 2));

        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);
    end;

    local procedure CreateFAJournalBatch(var FAJournalBatch: Record "FA Journal Batch")
    var
        FAJournalTemplate: Record "FA Journal Template";
    begin
        FAJournalTemplate.SetRange(Recurring, false);
        LibraryFixedAsset.FindFAJournalTemplate(FAJournalTemplate);
        LibraryFixedAsset.CreateFAJournalBatch(FAJournalBatch, FAJournalTemplate.Name);
        FAJournalBatch.Validate("No. Series", '');
        FAJournalBatch.Modify(true);
    end;

    local procedure UpdateFAJournalSetup(var FAJournalSetup: Record "FA Journal Setup")
    var
        FAJournalSetup2: Record "FA Journal Setup";
    begin
        FAJournalSetup2.SetRange("Depreciation Book Code", LibraryFixedAsset.GetDefaultDeprBook());
        FAJournalSetup2.FindFirst();
        FAJournalSetup.TransferFields(FAJournalSetup2, false);
        FAJournalSetup.Modify(true);
    end;

    local procedure CreateFAJournalLine(var FAJournalLine: Record "FA Journal Line"; FAJournalBatch: Record "FA Journal Batch";
            FAPostingType: Enum "FA Journal Line FA Posting Type"; FANo: Code[20]; DepreciationBookCode: Code[10]; Amount: Decimal)
    begin
        LibraryFixedAsset.CreateFAJournalLine(FAJournalLine, FAJournalBatch."Journal Template Name", FAJournalBatch.Name);
        FAJournalLine.Validate("Document Type", FAJournalLine."Document Type"::" ");
        FAJournalLine.Validate("Document No.", FAJournalLine."Journal Batch Name" + Format(FAJournalLine."Line No."));
        FAJournalLine.Validate("Posting Date", WorkDate());
        FAJournalLine.Validate("FA Posting Date", WorkDate());
        FAJournalLine.Validate("FA Posting Type", FAPostingType);
        FAJournalLine.Validate("FA No.", FANo);
        FAJournalLine.Validate(Amount, Amount);
        FAJournalLine.Validate("Depreciation Book Code", DepreciationBookCode);
        FAJournalLine.Modify(true);
    end;

    local procedure CreateAndPostPurchase(ItemNo: Code[20]; Quantity: Decimal)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, Enum::"Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Modify();

        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            Enum::"Purchase Line Type"::Item,
            ItemNo,
            Quantity);

        PurchaseLine.Validate("Direct Unit Cost", 1);
        PurchaseLine.Modify(true);

        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure CreateAndPostSales(ItemNo: Code[20]; Quantity: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::Order, LibrarySales.CreateCustomerNo());
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Modify();

        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            Enum::"Sales Line Type"::Item,
            ItemNo,
            Quantity);

        SalesLine.Validate("Unit Price", 1);
        SalesLine.Modify(true);

        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure GenerateExciseJournalLines(SustExciseJournalBatch: Record "Sust. Excise Journal Batch")
    var
        ExciseJournalLine: Record "Sust. Excise Jnl. Line";
        CreateExciseTaxJnlEntries: Report "Create Excise Tax Jnl. Entries";
    begin
        Commit();

        ExciseJournalLine."Journal Template Name" := SustExciseJournalBatch."Journal Template Name";
        ExciseJournalLine."Journal Batch Name" := SustExciseJournalBatch.Name;

        LibraryVariableStorage.Enqueue(WorkDate());
        LibraryVariableStorage.Enqueue(CalcDate('<-1M>', WorkDate()));
        LibraryVariableStorage.Enqueue(CalcDate('<1M>', WorkDate()));
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('');

        CreateExciseTaxJnlEntries.SetExciseJournalLine(ExciseJournalLine);
        CreateExciseTaxJnlEntries.RunModal();
    end;

    local procedure RegisterExciseJournal(TemplateName: Code[10]; BatchName: Code[10])
    var
        ExciseJnlLine: Record "Sust. Excise Jnl. Line";
    begin
        ExciseJnlLine.SetRange("Journal Template Name", TemplateName);
        ExciseJnlLine.SetRange("Journal Batch Name", BatchName);
        if ExciseJnlLine.FindSet() then
            Codeunit.Run(Codeunit::"Sust. Excise Jnl.-Post", ExciseJnlLine);
    end;

    local procedure SumJournalTaxAmountForTaxType(TaxTypeCode: Code[20]) TotalAmount: Decimal
    var
        ExciseJnlLine: Record "Sust. Excise Jnl. Line";
    begin
        ExciseJnlLine.SetRange("Excise Tax Type", TaxTypeCode);
        if ExciseJnlLine.FindSet() then
            repeat
                TotalAmount += ExciseJnlLine."Tax Amount";
            until ExciseJnlLine.Next() = 0;
    end;

    local procedure VerifyJournalLineCountForTaxType(TaxTypeCode: Code[20]; ExpectedCount: Integer)
    var
        ExciseJnlLine: Record "Sust. Excise Jnl. Line";
    begin
        ExciseJnlLine.SetRange("Excise Tax Type", TaxTypeCode);
        Assert.AreEqual(ExpectedCount, ExciseJnlLine.Count(), UnexpectedJournalLineCntLbl);
    end;

    local procedure SumTransactionLogTaxAmountForTaxType(TaxTypeCode: Code[20]) TotalAmount: Decimal
    var
        ExciseTaxTransLog: Record "Sust. Excise Taxes Trans. Log";
    begin
        ExciseTaxTransLog.SetRange("Excise Tax Type", TaxTypeCode);
        if ExciseTaxTransLog.FindSet() then
            repeat
                TotalAmount += ExciseTaxTransLog."Tax Amount";
            until ExciseTaxTransLog.Next() = 0;
    end;

    local procedure VerifyTransactionLogCountForTaxType(TaxTypeCode: Code[20]; ExpectedCount: Integer)
    var
        ExciseTaxTransLog: Record "Sust. Excise Taxes Trans. Log";
    begin
        ExciseTaxTransLog.SetRange("Excise Tax Type", TaxTypeCode);
        Assert.AreEqual(ExpectedCount, ExciseTaxTransLog.Count(), UnexpectedTransLogCntLbl);
    end;

    [RequestPageHandler]
    procedure ExciseTaxReportRequestPageHandler(var CreateExciseTaxJnlEntries: TestRequestPage "Create Excise Tax Jnl. Entries")
    begin
        CreateExciseTaxJnlEntries."Posting Date".SetValue(LibraryVariableStorage.DequeueDate());
        CreateExciseTaxJnlEntries."Starting Date".SetValue(LibraryVariableStorage.DequeueDate());
        CreateExciseTaxJnlEntries."Ending Date".SetValue(LibraryVariableStorage.DequeueDate());
        CreateExciseTaxJnlEntries."Item Filter".SetValue(LibraryVariableStorage.DequeueText());
        CreateExciseTaxJnlEntries."Fixed Asset Filter".SetValue(LibraryVariableStorage.DequeueText());
        CreateExciseTaxJnlEntries.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin
    end;

    [ConfirmHandler]
    procedure UIConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}