// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Reports;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Setup;
using System.TestLibraries.Utilities;

codeunit 148001 "ERM Fixed Assets - Local"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryRandom: Codeunit "Library - Random";
        CompletionStatsTok: Label 'The depreciation has been calculated.';

    [Test]
    [HandlerFunctions('FAProjValueDerogRPH,DepreciationCalcConfirmHandler')]
    [Scope('OnPrem')]
    procedure CheckDerogAmountReportProjectedValue()
    var
        FAJournalLine: Record "FA Journal Line";
        FANo: Code[20];
        NormalDeprBookCode: Code[10];
        TaxDeprBookCode: Code[10];
        Amount: Decimal;
    begin
        // Check Depreciation and Derogatory amounts in Projected Value report.
        FANo := CreateFAWithNormalAndTaxFADeprBooks(NormalDeprBookCode, TaxDeprBookCode);

        UpdateIntegrationInBook(NormalDeprBookCode, false);

        Amount := LibraryRandom.RandDec(1000000, 1);

        // 2.Exercise: create FA Journal Line and post it, calculate depreciation
        CreateFAJournalLine(
          FAJournalLine, FANo, NormalDeprBookCode, FAJournalLine."FA Posting Type"::"Acquisition Cost", Amount);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);
        RunCalculateDepreciationReport(FANo, NormalDeprBookCode, CalcDate('<CY>', WorkDate()), false);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        RunCalculateDepreciationReport(FANo, NormalDeprBookCode, CalcDate('<CY+3M>', WorkDate()), false);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // Projected Value
        RunFAProjValueDerogReport(NormalDeprBookCode, CalcDate('<CY>', WorkDate()), CalcDate('<CY+365D>', WorkDate()), 0D, false);

        // 3.Verify derogatory value.
        LibraryReportDataset.LoadDataSetFile();
        VerifyValues(FANo, CountExpectedAmount(FANo, TaxDeprBookCode, Amount));
    end;

    [Test]
    [HandlerFunctions('FAProjValueDerogRPH,DepreciationCalcConfirmHandler')]
    [Scope('OnPrem')]
    procedure FAProjectionBothBooksAreClosed()
    var
        NormalDeprBookCode: Code[10];
        TaxDeprBookCode: Code[10];
        NoOfYearsNormal: Decimal;
        NoOfYearsTax: Decimal;
        AcqCostAmount: Decimal;
    begin
        // [SCENARIO 135585] REP10886 "Fixed Asset - Projected Value (Derogatory)": both "Normal" (10 years) and "Tax" (8 years) books are closed at the end of projected "Normal" period (10 years).
        AcqCostAmount := 100000;
        NoOfYearsNormal := 10; // 10000 per year
        NoOfYearsTax := 8; // 12500 per year

        // [GIVEN] Setup both books: "Normal" - 10 years and "Tax"(Derogatory) - 8 years
        // [GIVEN] Post Acquisition Cost Amount = 100000
        // [GIVEN] Post first Depreciation = 360 Days
        // [GIVEN] Post second Depreciation = 90 Days
        PrepareBothFABooksWithCustomPeriodAndAcqCostAmount(
          NormalDeprBookCode, TaxDeprBookCode, NoOfYearsNormal, NoOfYearsTax, AcqCostAmount);

        // [WHEN] Run "Fixed Asset - Projected Value (Derogatory)" report on "Normal" book with 10 years period.
        RunFAProjValueDerogReport(
          NormalDeprBookCode, CalcDate('<CY>', WorkDate()), CalcDate('<CY+' + Format(NoOfYearsNormal) + 'Y>', WorkDate()), WorkDate(), true);

        // [THEN] Both books are projected to closed (Book Value = 0) at the end of projected period (10 years).
        VerifyFAProjectionBothBooksAreClosed();
    end;

    [Test]
    [HandlerFunctions('FAProjValueDerogRPH,DepreciationCalcConfirmHandler')]
    [Scope('OnPrem')]
    procedure FAProjectionBothBooksOneClosed()
    var
        NormalDeprBookCode: Code[10];
        TaxDeprBookCode: Code[10];
        NoOfYearsNormal: Decimal;
        NoOfYearsTax: Decimal;
        AcqCostAmount: Decimal;
    begin
        // [SCENARIO 135585] REP10886 "Fixed Asset - Projected Value (Derogatory)": "Normal" (10 years) book is open and "Tax" (8 years) book is closed at the end of projected Tax period (8 years).
        AcqCostAmount := 100000;
        NoOfYearsNormal := 10; // 10000 per year
        NoOfYearsTax := 8; // 12500 per year

        // [GIVEN] Setup both books: "Normal" - 10 years and "Tax"(Derogatory) - 8 years
        // [GIVEN] Post Acquisition Cost Amount = 100000
        // [GIVEN] Post first Depreciation = 360 Days
        // [GIVEN] Post second Depreciation = 90 Days
        PrepareBothFABooksWithCustomPeriodAndAcqCostAmount(
          NormalDeprBookCode, TaxDeprBookCode, NoOfYearsNormal, NoOfYearsTax, AcqCostAmount);

        // [WHEN] Run "Fixed Asset - Projected Value (Derogatory)" report on "Normal" book with 8 years.
        RunFAProjValueDerogReport(
          NormalDeprBookCode, CalcDate('<CY>', WorkDate()), CalcDate('<CY+' + Format(NoOfYearsTax) + 'Y>', WorkDate()), WorkDate(), true);

        // [THEN] "Tax" book is projected to closed (Book Value = 0), "Normal" book is open (Book Value <> 0) at the end of projected period (8 years).
        VerifyFAProjectionBothBooksOneClosed();
    end;

    [Test]
    [HandlerFunctions('FAProjValueDerogRPH,DepreciationCalcConfirmHandler')]
    [Scope('OnPrem')]
    procedure FAProjectionBothBooksInTheMidOfPeriod()
    var
        NormalDeprBookCode: Code[10];
        TaxDeprBookCode: Code[10];
        NoOfYearsNormal: Decimal;
        NoOfYearsTax: Decimal;
        AcqCostAmount: Decimal;
    begin
        // [SCENARIO 135585] REP10886 "Fixed Asset - Projected Value (Derogatory)": both "Normal" (10 years) and "Tax" (8 years) books are open in the middle of projected "Normal" period (5 years).
        AcqCostAmount := 100000;
        NoOfYearsNormal := 10; // 10000 per year
        NoOfYearsTax := 8; // 12500 per year

        // [GIVEN] Setup both books: "Normal" - 10 years and "Tax"(Derogatory) - 8 years
        // [GIVEN] Post Acquisition Cost Amount = 100000
        // [GIVEN] Post first Depreciation = 360 Days
        // [GIVEN] Post second Depreciation = 90 Days
        PrepareBothFABooksWithCustomPeriodAndAcqCostAmount(
          NormalDeprBookCode, TaxDeprBookCode, NoOfYearsNormal, NoOfYearsTax, AcqCostAmount);

        // [WHEN] Run "Fixed Asset - Projected Value (Derogatory)" report on "Normal" book with 5 years period.
        RunFAProjValueDerogReport(
          NormalDeprBookCode, CalcDate('<CY>', WorkDate()), CalcDate('<CY+' + Format(NoOfYearsTax - 3) + 'Y>', WorkDate()), WorkDate(), true);

        // [THEN] Both books are projected to open (Book Value <> 0) at the end of projected period (5 years).
        VerifyFAProjectionBothBooksInTheMidOfPeriod();
    end;

    [Test]
    [HandlerFunctions('FAProjValueDerogRPH,DepreciationCalcConfirmHandler')]
    [Scope('OnPrem')]
    procedure FAProjectionTaxBookIsClosed()
    var
        NormalDeprBookCode: Code[10];
        TaxDeprBookCode: Code[10];
        NoOfYearsNormal: Decimal;
        NoOfYearsTax: Decimal;
        AcqCostAmount: Decimal;
    begin
        // [SCENARIO 135585] REP10886 "Fixed Asset - Projected Value (Derogatory)": "Tax" (8 years) book is closed at the end of projected "Tax" period (8 years).
        AcqCostAmount := 100000;
        NoOfYearsNormal := 10; // 10000 per year
        NoOfYearsTax := 8; // 12500 per year

        // [GIVEN] Setup both books: "Normal" - 10 years and "Tax"(Derogatory) - 8 years
        // [GIVEN] Post Acquisition Cost Amount = 100000
        // [GIVEN] Post first Depreciation = 360 Days
        // [GIVEN] Post second Depreciation = 90 Days
        PrepareBothFABooksWithCustomPeriodAndAcqCostAmount(
          NormalDeprBookCode, TaxDeprBookCode, NoOfYearsNormal, NoOfYearsTax, AcqCostAmount);

        // [WHEN] Run "Fixed Asset - Projected Value (Derogatory)" report on "Tax" book with 8 years period.
        RunFAProjValueDerogReport(
          TaxDeprBookCode, CalcDate('<CY>', WorkDate()), CalcDate('<CY+' + Format(NoOfYearsTax) + 'Y>', WorkDate()), WorkDate(), true);

        // [THEN] "Tax" book is projected to closed (Book Value = 0) at the end of projected period (8 years).
        VerifyFAProjectionTaxBookIsClosed();
    end;

    [Test]
    [HandlerFunctions('FAProjValueDerogRPH,DepreciationCalcConfirmHandler')]
    [Scope('OnPrem')]
    procedure FAProjectionTaxBookInTheMidOfPeriod()
    var
        NormalDeprBookCode: Code[10];
        TaxDeprBookCode: Code[10];
        NoOfYearsNormal: Decimal;
        NoOfYearsTax: Decimal;
        AcqCostAmount: Decimal;
    begin
        // [SCENARIO 135585] REP10886 "Fixed Asset - Projected Value (Derogatory)": "Tax" (8 years) book is open in the middle of projected "Tax" period (5 years).
        AcqCostAmount := 100000;
        NoOfYearsNormal := 10; // 10000 per year
        NoOfYearsTax := 8; // 12500 per year

        // [GIVEN] Setup both books: "Normal" - 10 years and "Tax"(Derogatory) - 8 years
        // [GIVEN] Post Acquisition Cost Amount = 100000
        // [GIVEN] Post first Depreciation = 360 Days
        // [GIVEN] Post second Depreciation = 90 Days
        PrepareBothFABooksWithCustomPeriodAndAcqCostAmount(
          NormalDeprBookCode, TaxDeprBookCode, NoOfYearsNormal, NoOfYearsTax, AcqCostAmount);

        // [WHEN] Run "Fixed Asset - Projected Value (Derogatory)" report on "Tax" book with 5 years period.
        RunFAProjValueDerogReport(
          TaxDeprBookCode, CalcDate('<CY>', WorkDate()), CalcDate('<CY+' + Format(NoOfYearsTax - 3) + 'Y>', WorkDate()), WorkDate(), true);

        // [THEN] "Tax" book is projected to open (Book Value <> 0) at the end of projected period (5 years).
        VerifyFAProjectionTaxBookInTheMidOfPeriod();
    end;

    local procedure PrepareBothFABooksWithCustomPeriodAndAcqCostAmount(var NormalDeprBookCode: Code[10]; var TaxDeprBookCode: Code[10]; NoOfYearsNormal: Decimal; NoOfYearsTax: Decimal; AcqCostAmount: Decimal)
    var
        FAJournalLine: Record "FA Journal Line";
        FixedAsset: Record "Fixed Asset";
    begin
        // Create two FA Depreciation Books with Period = [01-01-SS..31-12-EE], where SS - starting year, EE - ending year
        CreateNormalAndTaxDeprBooks(NormalDeprBookCode, TaxDeprBookCode);
        CreateFAPostingGroup(FixedAsset);
        CreateFADeprBookWithDates(
            FixedAsset."No.", NormalDeprBookCode, FixedAsset."FA Posting Group",
            CalcDate('<-CY>', WorkDate()),
            CalcDate('<' + Format(NoOfYearsNormal - 1) + 'Y+CY>', WorkDate()));
        CreateFADeprBookWithDates(
          FixedAsset."No.", TaxDeprBookCode, FixedAsset."FA Posting Group",
          CalcDate('<-CY>', WorkDate()),
          CalcDate('<' + Format(NoOfYearsTax - 1) + 'Y+CY>', WorkDate()));
        UpdateIntegrationInBook(NormalDeprBookCode, false);

        CreateFAJournalLine(
          FAJournalLine, FixedAsset."No.", NormalDeprBookCode, FAJournalLine."FA Posting Type"::"Acquisition Cost", AcqCostAmount);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // Post first Depreciation = 360 Days
        RunCalculateDepreciationReport(FixedAsset."No.", NormalDeprBookCode, CalcDate('<CY>', WorkDate()), false);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // Post second Depreciation = 90 Days
        RunCalculateDepreciationReport(FixedAsset."No.", NormalDeprBookCode, CalcDate('<CY+3M>', WorkDate()), false);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);
    end;

    local procedure CreateFADeprBookWithDates(FANo: Code[20]; DeprBookCode: Code[10]; FAPostingGroup: Code[20]; StartingDate: Date; EndingDate: Date)
    var
        FADeprBook: Record "FA Depreciation Book";
    begin
        LibraryFixedAsset.CreateFADepreciationBook(FADeprBook, FANo, DeprBookCode);
        FADeprBook.Validate("Depreciation Book Code", DeprBookCode);
        FADeprBook.Validate("Depreciation Starting Date", StartingDate);
        FADeprBook.Validate("Depreciation Ending Date", EndingDate);
        FADeprBook.Validate("FA Posting Group", FAPostingGroup);
        FADeprBook.Modify(true);
    end;

    local procedure CreateFAPostingGroup(var FixedAsset: Record "Fixed Asset")
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        CreateFixedAsset(FixedAsset);
        FAPostingGroup.Get(FixedAsset."FA Posting Group");
        UpdateFAPostingGroup(FAPostingGroup);
    end;

    local procedure UpdateFAPostingGroup(var FAPostingGroup: Record "FA Posting Group")
    var
        FAPostingGroup2: Record "FA Posting Group";
        RecRef: RecordRef;
    begin
        FAPostingGroup2.Init();
        FAPostingGroup2.SetFilter("Acquisition Cost Account", '<>''''');
        RecRef.GetTable(FAPostingGroup2);
        LibraryUtility.FindRecord(RecRef);
        RecRef.SetTable(FAPostingGroup2);

        FAPostingGroup.TransferFields(FAPostingGroup2, false);
        FAPostingGroup.Modify(true);
    end;

    local procedure CreateFixedAsset(var FixedAsset: Record "Fixed Asset")
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        LibraryFixedAsset.CreateFAPostingGroup(FAPostingGroup);
        FixedAsset.Validate("FA Posting Group", FAPostingGroup.Code);
        FixedAsset.Modify(true);
    end;

    local procedure CreateNormalAndTaxDeprBooks(var NormalDeprBookCode: Code[10]; var TaxDeprBookCode: Code[10])
    begin
        NormalDeprBookCode := CreateDeprBookModifyDerogCalc('');
        UpdateIntegrationInBook(NormalDeprBookCode, true);
        TaxDeprBookCode := CreateDeprBookModifyDerogCalc(NormalDeprBookCode);
    end;

    local procedure CreateDeprBookModifyDerogCalc(DerogDeprBookCode: Code[10]): Code[10]
    var
        DeprBook: Record "Depreciation Book";
    begin
        CreateAndSetupDeprBook(DeprBook);
        DeprBook.Validate("Use Same FA+G/L Posting Dates", false);
        DeprBook.Validate("Derogatory Calculation", DerogDeprBookCode);
        DeprBook.Modify(true);
        exit(DeprBook.Code);
    end;

    local procedure CreateAndSetupDeprBook(var DepreciationBook: Record "Depreciation Book")
    var
        FAJournalSetup: Record "FA Journal Setup";
    begin
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        LibraryFixedAsset.CreateFAJournalSetup(FAJournalSetup, DepreciationBook.Code, '');
        UpdateFAJournalSetup(FAJournalSetup);
    end;

    local procedure UpdateFAJournalSetup(var FAJournalSetup: Record "FA Journal Setup")
    var
        FAJournalSetup2: Record "FA Journal Setup";
        FASetup: Record "FA Setup";
    begin
        FASetup.Get();
        FAJournalSetup2.SetRange("Depreciation Book Code", FASetup."Default Depr. Book");
        FAJournalSetup2.FindFirst();
        FAJournalSetup.TransferFields(FAJournalSetup2, false);
        FAJournalSetup.Modify(true);
    end;

    local procedure RunCalculateDepreciationReport(FixedAssetNo: Code[20]; DepreciationBookCode: Code[10]; PostingDate: Date; BalanceAccount: Boolean)
    var
        FixedAsset: Record "Fixed Asset";
        CalculateDepreciation: Report "Calculate Depreciation";
    begin
        Clear(CalculateDepreciation);
        FixedAsset.SetRange("No.", FixedAssetNo);

        CalculateDepreciation.SetTableView(FixedAsset);
        CalculateDepreciation.InitializeRequest(
          DepreciationBookCode, PostingDate, false, 0, PostingDate, '', FixedAsset.Description, BalanceAccount);
        CalculateDepreciation.UseRequestPage(false);
        CalculateDepreciation.Run();
    end;

    local procedure CreateFAWithNormalAndTaxFADeprBooks(var NormalDeprBookCode: Code[10]; var TaxDeprBookCode: Code[10]): Code[20]
    var
        FixedAsset: Record "Fixed Asset";
    begin
        CreateNormalAndTaxDeprBooks(NormalDeprBookCode, TaxDeprBookCode);
        CreateFAPostingGroup(FixedAsset);
        CreateFADeprBook(FixedAsset."No.", NormalDeprBookCode, FixedAsset."FA Posting Group");
        CreateFADeprBook(FixedAsset."No.", TaxDeprBookCode, FixedAsset."FA Posting Group");
        exit(FixedAsset."No.");
    end;

    local procedure CreateFADeprBook(FANo: Code[20]; DeprBookCode: Code[10]; FAPostingGroup: Code[20])
    begin
        CreateFADeprBookWithDates(
          FANo, DeprBookCode, FAPostingGroup, WorkDate(), CalcDate('<' + Format(LibraryRandom.RandIntInRange(2, 5)) + 'Y>', WorkDate()));
    end;

    local procedure UpdateIntegrationInBook(DeprBookCode: Code[10]; Value: Boolean)
    var
        DeprBook: Record "Depreciation Book";
    begin
        DeprBook.Get(DeprBookCode);
        DeprBook.Validate("G/L Integration - Acq. Cost", Value);
        DeprBook.Validate("G/L Integration - Depreciation", Value);
        DeprBook.Validate("G/L Integration - Derogatory", Value);
        DeprBook.Modify(true);
    end;

    local procedure CountExpectedAmount(FANo: Code[20]; TaxDeprBook: Code[20]; Amt: Decimal): Decimal
    var
        FATaxDeprBook: Record "FA Depreciation Book";
    begin
        FATaxDeprBook.Get(FANo, TaxDeprBook);
        exit(Round(Amt * 270 / 360 / FATaxDeprBook."No. of Depreciation Years"));
    end;

    local procedure RunFAProjValueDerogReport(DeprBookCode: Code[10]; StartingDate: Date; EndingDate: Date; PostedFrom: Date; PrintDetails: Boolean)
    begin
        LibraryVariableStorage.Enqueue(DeprBookCode);
        LibraryVariableStorage.Enqueue(StartingDate);
        LibraryVariableStorage.Enqueue(EndingDate);
        LibraryVariableStorage.Enqueue(PostedFrom);
        LibraryVariableStorage.Enqueue(PrintDetails);
        Commit();
        Report.Run(Report::"FA-Proj. Value (Derogatory) FR");
    end;

    local procedure VerifyValues(FANo: Code[20]; ExpectedAmount: Decimal)
    begin
        LibraryReportDataset.SetRange('FixedAssetNo', FANo);
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.AssertCurrentRowValueEquals('DerogAmount', -ExpectedAmount);
    end;

    local procedure VerifyFAProjValueRepPostedEntryAmounts(Amount: Decimal; BookValue: Decimal; DerogAmount: Decimal; DerogBookValue: Decimal; DerogDiffBokkValue: Decimal; MoveNextRow: Boolean)
    begin
        LibraryReportDataset.AssertCurrentRowValueEquals('Amount_FALedgerEntry', Amount);
        LibraryReportDataset.AssertCurrentRowValueEquals('BookValue', BookValue);
        LibraryReportDataset.AssertCurrentRowValueEquals('FALedgerEntryDerogAmount', DerogAmount);
        LibraryReportDataset.AssertCurrentRowValueEquals('FALedgerEntryDerogBookValue', DerogBookValue);
        LibraryReportDataset.AssertCurrentRowValueEquals('FALedgerEntryDerogDiffBookValue', DerogDiffBokkValue);
        if MoveNextRow then
            LibraryReportDataset.GetNextRow();
    end;

    local procedure VerifyFAProjValueRepProjectedAmounts(Amount: Decimal; BookValue: Decimal; DerogAmount: Decimal; DerogBookValue: Decimal; DerogDiffBokkValue: Decimal; MoveNextRow: Boolean)
    begin
        LibraryReportDataset.AssertCurrentRowValueEquals('DeprAmount', Amount);
        LibraryReportDataset.AssertCurrentRowValueEquals('EntryAmt1Custom1Amt', BookValue);
        LibraryReportDataset.AssertCurrentRowValueEquals('DerogAmount', DerogAmount);
        LibraryReportDataset.AssertCurrentRowValueEquals('DerogBookValue', DerogBookValue);
        LibraryReportDataset.AssertCurrentRowValueEquals('DerogDiffBookValue', DerogDiffBokkValue);
        if MoveNextRow then
            LibraryReportDataset.GetNextRow();
    end;

    local procedure VerifyFAProjValueRepAssetAmounts(Amount: Decimal; BookValue: Decimal; DerogAmount: Decimal; DerogBookValue: Decimal; DerogDiffBokkValue: Decimal; MoveNextRow: Boolean)
    begin
        LibraryReportDataset.AssertCurrentRowValueEquals('GroupAmounts_1', Amount);
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalBookValue_1', BookValue);
        LibraryReportDataset.AssertCurrentRowValueEquals('AssetDerogAmount', DerogAmount);
        LibraryReportDataset.AssertCurrentRowValueEquals('AssetDerogBookValue', DerogBookValue);
        LibraryReportDataset.AssertCurrentRowValueEquals('AssetDerogDiffBookValue', DerogDiffBokkValue);
        if MoveNextRow then
            LibraryReportDataset.GetNextRow();
    end;

    local procedure VerifyFAProjValueRepTotalAmounts(Amount: Decimal; BookValue: Decimal; DerogAmount: Decimal; DerogBookValue: Decimal; DerogDiffBokkValue: Decimal; MoveNextRow: Boolean)
    begin
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalAmounts1', Amount);
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalBookValue2', BookValue);
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalDerogAmount', DerogAmount);
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalDerogBookValue', DerogBookValue);
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalDerogDiffBookValue', DerogDiffBokkValue);
        if MoveNextRow then
            LibraryReportDataset.GetNextRow();
    end;

    local procedure CreateFAJournalLine(var FAJournalLine: Record "FA Journal Line"; FANo: Code[20]; DepreciationBookCode: Code[10]; FAPostingType: Enum "FA Journal Line FA Posting Type"; Amount: Decimal)
    var
        FAJournalTemplate: Record "FA Journal Template";
        FAJournalBatch: Record "FA Journal Batch";
    begin
        FAJournalTemplate.SetRange(Recurring, false);
        LibraryFixedAsset.FindFAJournalTemplate(FAJournalTemplate);
        LibraryFixedAsset.FindFAJournalBatch(FAJournalBatch, FAJournalTemplate.Name);
        LibraryERM.CreateFAJournalLine(
          FAJournalLine, FAJournalBatch."Journal Template Name", FAJournalBatch.Name,
          FAJournalLine."Document Type"::" ", FAPostingType,
          FANo, Amount);
        FAJournalLine.Validate("Depreciation Book Code", DepreciationBookCode);
        FAJournalLine.Modify(true);
    end;

    local procedure VerifyFAProjectionBothBooksAreClosed()
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.MoveToRow(1);

        // Initial Acqusition Cost Amount = 100000
        VerifyFAProjValueRepPostedEntryAmounts(100000, 100000, 100000, 100000, 0, true);
        // First posted Depreciation = 360 Days
        VerifyFAProjValueRepPostedEntryAmounts(-10000, 90000, -12500, 87500, -2500, true);
        // Second posted Depreciation = 90 Days
        VerifyFAProjValueRepPostedEntryAmounts(-2500, 87500, -3125, 84375, -3125, true);

        // Projection1: 270 Days. All others = 360 Days
        VerifyFAProjValueRepProjectedAmounts(-7500, 80000, -9375, 75000, -5000, false);
        VerifyFAProjValueRepAssetAmounts(-7500, 80000, -9375, 75000, -5000, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 70000, -12500, 62500, -7500, false);
        VerifyFAProjValueRepAssetAmounts(-17500, 70000, -21875, 62500, -7500, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 60000, -12500, 50000, -10000, false);
        VerifyFAProjValueRepAssetAmounts(-27500, 60000, -34375, 50000, -10000, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 50000, -12500, 37500, -12500, false);
        VerifyFAProjValueRepAssetAmounts(-37500, 50000, -46875, 37500, -12500, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 40000, -12500, 25000, -15000, false);
        VerifyFAProjValueRepAssetAmounts(-47500, 40000, -59375, 25000, -15000, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 30000, -12500, 12500, -17500, false);
        VerifyFAProjValueRepAssetAmounts(-57500, 30000, -71875, 12500, -17500, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 20000, -12500, 0, -20000, false);
        VerifyFAProjValueRepAssetAmounts(-67500, 20000, -84375, 0, -20000, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 10000, 0, 0, -10000, false);
        VerifyFAProjValueRepAssetAmounts(-77500, 10000, -84375, 0, -10000, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 0, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-87500, 0, -84375, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(0, 0, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-87500, 0, -84375, 0, 0, true);

        VerifyFAProjValueRepTotalAmounts(-87500, 0, -84375, 0, 0, true);
    end;

    local procedure VerifyFAProjectionBothBooksOneClosed()
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.MoveToRow(1);

        // Initial Acqusition Cost Amount = 100000
        VerifyFAProjValueRepPostedEntryAmounts(100000, 100000, 100000, 100000, 0, true);
        // First posted Depreciation = 360 Days
        VerifyFAProjValueRepPostedEntryAmounts(-10000, 90000, -12500, 87500, -2500, true);
        // Second posted Depreciation = 90 Days
        VerifyFAProjValueRepPostedEntryAmounts(-2500, 87500, -3125, 84375, -3125, true);

        // Projection1: 270 Days. All others = 360 Days
        VerifyFAProjValueRepProjectedAmounts(-7500, 80000, -9375, 75000, -5000, false);
        VerifyFAProjValueRepAssetAmounts(-7500, 80000, -9375, 75000, -5000, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 70000, -12500, 62500, -7500, false);
        VerifyFAProjValueRepAssetAmounts(-17500, 70000, -21875, 62500, -7500, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 60000, -12500, 50000, -10000, false);
        VerifyFAProjValueRepAssetAmounts(-27500, 60000, -34375, 50000, -10000, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 50000, -12500, 37500, -12500, false);
        VerifyFAProjValueRepAssetAmounts(-37500, 50000, -46875, 37500, -12500, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 40000, -12500, 25000, -15000, false);
        VerifyFAProjValueRepAssetAmounts(-47500, 40000, -59375, 25000, -15000, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 30000, -12500, 12500, -17500, false);
        VerifyFAProjValueRepAssetAmounts(-57500, 30000, -71875, 12500, -17500, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 20000, -12500, 0, -20000, false);
        VerifyFAProjValueRepAssetAmounts(-67500, 20000, -84375, 0, -20000, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 10000, 0, 0, -10000, false);
        VerifyFAProjValueRepAssetAmounts(-77500, 10000, -84375, 0, -10000, true);

        VerifyFAProjValueRepTotalAmounts(-77500, 10000, -84375, 0, -10000, true);
    end;

    local procedure VerifyFAProjectionBothBooksInTheMidOfPeriod()
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.MoveToRow(1);

        // Initial Acqusition Cost Amount = 100000
        VerifyFAProjValueRepPostedEntryAmounts(100000, 100000, 100000, 100000, 0, true);
        // First posted Depreciation = 360 Days
        VerifyFAProjValueRepPostedEntryAmounts(-10000, 90000, -12500, 87500, -2500, true);
        // Second posted Depreciation = 90 Days
        VerifyFAProjValueRepPostedEntryAmounts(-2500, 87500, -3125, 84375, -3125, true);

        // Projection1: 270 Days. All others = 360 Days
        VerifyFAProjValueRepProjectedAmounts(-7500, 80000, -9375, 75000, -5000, false);
        VerifyFAProjValueRepAssetAmounts(-7500, 80000, -9375, 75000, -5000, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 70000, -12500, 62500, -7500, false);
        VerifyFAProjValueRepAssetAmounts(-17500, 70000, -21875, 62500, -7500, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 60000, -12500, 50000, -10000, false);
        VerifyFAProjValueRepAssetAmounts(-27500, 60000, -34375, 50000, -10000, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 50000, -12500, 37500, -12500, false);
        VerifyFAProjValueRepAssetAmounts(-37500, 50000, -46875, 37500, -12500, true);

        VerifyFAProjValueRepProjectedAmounts(-10000, 40000, -12500, 25000, -15000, false);
        VerifyFAProjValueRepAssetAmounts(-47500, 40000, -59375, 25000, -15000, true);

        VerifyFAProjValueRepTotalAmounts(-47500, 40000, -59375, 25000, -15000, true);
    end;

    local procedure VerifyFAProjectionTaxBookIsClosed()
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.MoveToRow(1);

        // Initial Acqusition Cost Amount = 100000
        VerifyFAProjValueRepPostedEntryAmounts(100000, 100000, 0, 0, 0, true);
        // First posted Depreciation = 360 Days
        VerifyFAProjValueRepPostedEntryAmounts(-10000, 90000, 0, 0, 0, true);
        // First posted Derogatory = 360 Days
        VerifyFAProjValueRepPostedEntryAmounts(-2500, 87500, 0, 0, 0, true);
        // Second posted Depreciation = 90 Days
        VerifyFAProjValueRepPostedEntryAmounts(-2500, 85000, 0, 0, 0, true);
        // Second posted Derogatory = 90 Days
        VerifyFAProjValueRepPostedEntryAmounts(-625, 84375, 0, 0, 0, true);

        // Projection1: 270 Days. All others = 360 Days
        VerifyFAProjValueRepProjectedAmounts(-9375, 75000, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-9375, 75000, 0, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(-12500, 62500, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-21875, 62500, 0, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(-12500, 50000, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-34375, 50000, 0, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(-12500, 37500, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-46875, 37500, 0, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(-12500, 25000, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-59375, 25000, 0, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(-12500, 12500, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-71875, 12500, 0, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(-12500, 0, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-84375, 0, 0, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(0, 0, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-84375, 0, 0, 0, 0, true);

        VerifyFAProjValueRepTotalAmounts(-84375, 0, 0, 0, 0, true);
    end;

    local procedure VerifyFAProjectionTaxBookInTheMidOfPeriod()
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.MoveToRow(1);

        // Initial Acqusition Cost Amount = 100000
        VerifyFAProjValueRepPostedEntryAmounts(100000, 100000, 0, 0, 0, true);
        // First posted Depreciation = 360 Days
        VerifyFAProjValueRepPostedEntryAmounts(-10000, 90000, 0, 0, 0, true);
        // First posted Derogatory = 360 Days
        VerifyFAProjValueRepPostedEntryAmounts(-2500, 87500, 0, 0, 0, true);
        // Second posted Depreciation = 90 Days
        VerifyFAProjValueRepPostedEntryAmounts(-2500, 85000, 0, 0, 0, true);
        // Second posted Derogatory = 90 Days
        VerifyFAProjValueRepPostedEntryAmounts(-625, 84375, 0, 0, 0, true);

        // Projection1: 270 Days. All others = 360 Days
        VerifyFAProjValueRepProjectedAmounts(-9375, 75000, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-9375, 75000, 0, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(-12500, 62500, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-21875, 62500, 0, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(-12500, 50000, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-34375, 50000, 0, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(-12500, 37500, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-46875, 37500, 0, 0, 0, true);

        VerifyFAProjValueRepProjectedAmounts(-12500, 25000, 0, 0, 0, false);
        VerifyFAProjValueRepAssetAmounts(-59375, 25000, 0, 0, 0, true);

        VerifyFAProjValueRepTotalAmounts(-59375, 25000, 0, 0, 0, true);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure FAProjValueDerogRPH(var FAProjValueDerogatory: TestRequestPage "FA-Proj. Value (Derogatory) FR")
    begin
        FAProjValueDerogatory.DepreciationBook.SetValue(LibraryVariableStorage.DequeueText());
        FAProjValueDerogatory.FirstDeprDate.SetValue(LibraryVariableStorage.DequeueDate());
        FAProjValueDerogatory.LastDeprDate.SetValue(LibraryVariableStorage.DequeueDate());
        FAProjValueDerogatory.IncludePostedFrom.SetValue(LibraryVariableStorage.DequeueDate());
        FAProjValueDerogatory.PrintPerFixedAsset.SetValue(LibraryVariableStorage.DequeueBoolean());
        FAProjValueDerogatory.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure DepreciationCalcConfirmHandler(Message: Text[1024]; var Reply: Boolean)
    begin
        if 0 <> StrPos(Message, CompletionStatsTok) then
            Reply := false
        else
            Reply := true;
    end;
}