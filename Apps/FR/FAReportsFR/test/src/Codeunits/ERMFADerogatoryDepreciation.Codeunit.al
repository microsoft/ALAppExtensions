// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Reports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.AuditCodes;

codeunit 148000 "ERM FA Derogatory Depreciation"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryFiscalYear: Codeunit "Library - Fiscal Year";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryReportDataset: Codeunit "Library - Report Dataset";

    [Test]
    [HandlerFunctions('FAProjValueDerogRPH,ConfirmHandler')]
    [Scope('OnPrem')]
    procedure FAProjectedValueReportWithNoDetails()
    var
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
    begin
        // [SCENARIO] Report "Fixed Asset - Projected Value (Derogatory)" shows correct depreciation amounts when run with empty GroupTotals
        // [GIVEN] Fixed Asset. Post Acquisition Cost with amount = "A"
        // [WHEN] Run report "Fixed Asset - Projected Value (Derogatory)" with empty Group Totals option
        // [THEN] Report shows Depreciation Amount = "A"
        FAProjectedValueReport(GroupTotals::" ", false);  // FA Posting Group blank, Print Details FALSE.
    end;

    [Test]
    [HandlerFunctions('FAProjValueDerogRPH,ConfirmHandler')]
    [Scope('OnPrem')]
    procedure FAProjectedValueReportWithDetails()
    begin
        // [SCENARIO] Report "Fixed Asset - Projected Value (Derogatory)" shows correct depreciation amounts when run with non-empty GroupTotals and Print Details=TRUE
        // [GIVEN] Fixed Asset. Post Acquisition Cost with amount = "A"
        // [WHEN] Run report "Fixed Asset - Projected Value (Derogatory)" with non-empty Group Totals and Print Details = TRUE
        // [THEN] Report shows Depreciation Amount = "A"
        FAProjectedValueReport(LibraryRandom.RandIntInRange(1, 7), true);  // Using Random value in range for GroupTotals and TRUE for Print Details.
    end;

    local procedure FAProjectedValueReport(GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group"; PrintDetails: Boolean)
    var
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        // Setup: Create Fixed Asset Depreciation Book, create and post FA General Journal Line with Acquisition Cost and Derogatory.
        LibraryFiscalYear.CloseFiscalYear();
        LibraryFiscalYear.CreateFiscalYear();
        CreateFADepreciationBookAndPostFAGLJournal(FADepreciationBook);

        // Exercise.
        RunReportFAProjValueDerogatory(FADepreciationBook, GroupTotals, PrintDetails);

        // Verify: Verify values on Report "Fixed Asset - Projected Value (Derogatory)"
        VerifyFAProjectedValueReport(FADepreciationBook."FA No.");
    end;

    local procedure CreateAndPostFAGLJournal(FANo: Code[20]; DepreciationBookCode: Code[10]; FAPostingType: Enum "Gen. Journal Line FA Posting Type")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
        SourceCode: Record "Source Code";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateSourceCode(SourceCode);
        CreateGeneralJournalBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::" ",
          GenJournalLine."Account Type"::"Fixed Asset", FANo, LibraryRandom.RandDec(100, 2));  // Using Random value for Amount.
        GenJournalLine.Validate("Document No.", GenJournalLine."Account No.");
        GenJournalLine.Validate("FA Posting Type", FAPostingType);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Depreciation Book Code", DepreciationBookCode);
        GenJournalLine.Validate("Source Code", SourceCode.Code);
        GenJournalLine.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateFADepreciationBookAndPostFAGLJournal(var FADepreciationBook: Record "FA Depreciation Book")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // Create Fixed Asset Depreciation Book, create and post FA General Journal Line with Acquisition Cost and Derogatory.
        CreateFADepreciationBook(FADepreciationBook);
        CreateAndPostFAGLJournal(
          FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code", GenJournalLine."FA Posting Type"::"Acquisition Cost");
        CreateAndPostFAGLJournal(
          FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code", GenJournalLine."FA Posting Type"::Derogatory);
    end;

    local procedure CreateDepreciationBook(): Code[10]
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        DepreciationBook.Validate("G/L Integration - Acq. Cost", true);
        DepreciationBook.Validate("G/L Integration - Depreciation", true);
        DepreciationBook.Validate("G/L Integration - Derogatory", true);
        DepreciationBook.Modify(true);
        exit(DepreciationBook.Code);
    end;

    local procedure CreateFADepreciationBook(var FADepreciationBook: Record "FA Depreciation Book")
    var
        FAPostingGroup: Record "FA Posting Group";
        FixedAsset: Record "Fixed Asset";
    begin
        FAPostingGroup.FindFirst();
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FixedAsset."No.", CreateDepreciationBook());
        FADepreciationBook.Validate("FA Posting Group", FAPostingGroup.Code);
        FADepreciationBook.Validate("Depreciation Starting Date", WorkDate());
        FADepreciationBook.Validate("Depreciation Ending Date", WorkDate());
        FADepreciationBook.Modify(true);
    end;

    local procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Assets);
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure FALedgerEntryAmount(FANo: Code[20]; FAPostingType: Enum "FA Ledger Entry FA Posting Type"): Decimal
    var
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        FALedgerEntry.SetRange("FA No.", FANo);
        FALedgerEntry.SetRange("FA Posting Type", FAPostingType);
        FALedgerEntry.FindFirst();
        exit(FALedgerEntry.Amount);
    end;

    local procedure RunReportFAProjValueDerogatory(FADepreciationBook: Record "FA Depreciation Book"; GroupTotals: Option; PrintDetails: Boolean)
    var
        FixedAsset: Record "Fixed Asset";
        FAProjValueDerogatory: Report "FA-Proj. Value (Derogatory) FR";
    begin
        Clear(FAProjValueDerogatory);
        FixedAsset.SetRange("No.", FADepreciationBook."FA No.");
        FAProjValueDerogatory.SetTableView(FixedAsset);
        FAProjValueDerogatory.SetMandatoryFields(FADepreciationBook."Depreciation Book Code", WorkDate(), WorkDate());
        FAProjValueDerogatory.SetTotalFields(GroupTotals, PrintDetails);
        FAProjValueDerogatory.Run();
    end;

    local procedure VerifyFAProjectedValueReport(FANo: Code[20])
    var
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(
          'FixedAssetProjectedValueCaption', 'Fixed Asset - Projected Value (Derogatory)');
        LibraryReportDataset.AssertElementWithValueExists(
          'DeprAmount', -FALedgerEntryAmount(FANo, FALedgerEntry."FA Posting Type"::"Acquisition Cost"));
        LibraryReportDataset.AssertElementWithValueExists(
          'AssetAmounts1', -FALedgerEntryAmount(FANo, FALedgerEntry."FA Posting Type"::"Acquisition Cost"));
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure FAProjValueDerogRPH(var FAProjValueDerogatory: TestRequestPage "FA-Proj. Value (Derogatory) FR")
    begin
        FAProjValueDerogatory.UseAccountingPeriod.SetValue(true);
        FAProjValueDerogatory.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;
}