// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Reports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.AuditCodes;
using System.TestLibraries.Utilities;

codeunit 148002 "ERM FA Professional Tax"
{
    // 1. Verify Fixed Asset Professional Tax Report with No Tax option.
    // 2. Verify Fixed Asset Professional Tax Report with Fixed Asset for more than 30 years 1 option.
    // 3. Verify Fixed Asset Professional Tax Report with Fixed Asset for more than 30 years 2 option.
    // 4. Verify Fixed Asset Professional Tax Report with Fixed Asset less than 30 years option.
    // 
    //   Covers Test Cases for WI - 344854
    //   -------------------------------------------------------------------------------------------------------
    //   Test Function Name                                                                             TFS ID
    //   -------------------------------------------------------------------------------------------------------
    //   FAProfessionalTaxNoTax, FAProfessionalTaxMoreThanThirtyYearsOne                          151112,151114
    //   FAProfessionalTaxMoreThanThirtyYearsTwo, FAProfessionalTaxLessThanThirty                 151113,151115

    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        UnexpectedErr: Label 'Expected caption is not correct.';


    [Test]
    [HandlerFunctions('FixedAssetProfessionalTaxRequestPageHandler')]
    [Scope('OnPrem')]
    procedure FAProfessionalTaxNoTax()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2";
    begin
        // Verify Fixed Asset Professional Tax Report with No Tax option.
        FAProfessionalTaxReport(FixedAsset."Professional Tax"::"No Tax", 0, true, GroupTotals::"FA Subclass");  // Using 0 for Professional Tax percentage.
    end;

    [Test]
    [HandlerFunctions('FixedAssetProfessionalTaxRequestPageHandler')]
    [Scope('OnPrem')]
    procedure FAProfessionalTaxMoreThanThirtyYearsOne()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2";
    begin
        // Verify Fixed Asset Professional Tax Report with Fixed Asset for more than 30 years 1 option.
        FAProfessionalTaxReport(
          FixedAsset."Professional Tax"::"Fixed Asset for more than 30 years 1",
          LibraryRandom.RandDec(10, 2), false, GroupTotals::" "); // Using Random for Professional Tax percentage.
    end;

    [Test]
    [HandlerFunctions('FixedAssetProfessionalTaxRequestPageHandler')]
    [Scope('OnPrem')]
    procedure FAProfessionalTaxMoreThanThirtyYearsTwo()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2";
    begin
        // Verify Fixed Asset Professional Tax Report with Fixed Asset for more than 30 years 2 option.
        FAProfessionalTaxReport(
          FixedAsset."Professional Tax"::"Fixed Asset for more than 30 years 2",
          LibraryRandom.RandDec(10, 2), true, GroupTotals::"FA Subclass"); // Using Random for Professional Tax percentage.
    end;

    [Test]
    [HandlerFunctions('FixedAssetProfessionalTaxRequestPageHandler')]
    [Scope('OnPrem')]
    procedure FAProfessionalTaxLessThanThirtyYears()
    var
        FixedAsset: Record "Fixed Asset";
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2";
    begin
        // Verify Fixed Asset Professional Tax Report with Fixed Asset less than 30 years option.
        FAProfessionalTaxReport(
          FixedAsset."Professional Tax"::"Fixed Asset less than 30 years", LibraryRandom.RandDec(10, 2), true, GroupTotals::" ");  // Using Random for Professional Tax percentage.
    end;

    local procedure FAProfessionalTaxReport(ProfessionalTax: Option; ProfessionalTaxPercent: Decimal; PrintPerFixedAsset: Boolean; GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2")
    var
        FADepreciationBook: Record "FA Depreciation Book";
        FixedAsset: Record "Fixed Asset";
    begin
        // Setup: Create Fixed Asset Depreciation Book, create and post FA General Journal Line with Acquisition Cost.
        CreateFADepreciationBook(FADepreciationBook, ProfessionalTax);
        CreateAndPostFAGeneralJournal(FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code");

        // Enqueue values for FixedAssetProfessionalTaxRequestPageHandler.
        LibraryVariableStorage.Enqueue(FADepreciationBook."FA No.");
        LibraryVariableStorage.Enqueue(FADepreciationBook."Depreciation Book Code");
        LibraryVariableStorage.Enqueue(ProfessionalTaxPercent);
        LibraryVariableStorage.Enqueue(PrintPerFixedAsset);
        LibraryVariableStorage.Enqueue(GroupTotals);

        // Exercise.
        Report.Run(Report::"Fixed Asset-Professional TaxFR");

        // Verify: Verify Professional Tax Percent, Print per Fixed Asset, Amount, Group Amount on FA Professional Tax report and field existence on FA Card.
        LibraryReportDataset.LoadDataSetFile();
        FADepreciationBook.CalcFields("Book Value");
        LibraryReportDataset.AssertElementWithValueExists('PercentageTaxProfessionalTax', ProfessionalTaxPercent);
        LibraryReportDataset.AssertElementWithValueExists('PrintDetails', PrintPerFixedAsset);
        LibraryReportDataset.AssertElementWithValueExists('GroupAmts1', FADepreciationBook."Book Value");
        LibraryReportDataset.AssertElementWithValueExists(
          'GroupAmts2', Round(FADepreciationBook."Book Value" * ProfessionalTaxPercent / 100));  // Calculate percentage amount.
        VerifyProfessionalTaxFieldOnFACard(FADepreciationBook."FA No.", ProfessionalTax, CopyStr(FixedAsset.FieldCaption("Professional Tax"), 1, 20));
    end;

    local procedure CreateAndPostFAGeneralJournal(FANo: Code[20]; DepreciationBookCode: Code[10])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        SourceCode: Record "Source Code";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateSourceCode(SourceCode);
        CreateFAGeneralJournalBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::" ",
          GenJournalLine."Account Type"::"Fixed Asset", FANo, LibraryRandom.RandDec(100, 2));  // Using Random value for Amount.
        GenJournalLine.Validate("Document No.", GenJournalLine."Account No.");
        GenJournalLine.Validate("FA Posting Type", GenJournalLine."FA Posting Type"::"Acquisition Cost");
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Depreciation Book Code", DepreciationBookCode);
        GenJournalLine.Validate("Source Code", SourceCode.Code);
        GenJournalLine.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateDepreciationBook(): Code[10]
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        DepreciationBook.Validate("G/L Integration - Acq. Cost", true);
        DepreciationBook.Modify(true);
        exit(DepreciationBook.Code);
    end;

    local procedure CreateFADepreciationBook(var FADepreciationBook: Record "FA Depreciation Book"; ProfessionalTax: Option)
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        FAPostingGroup.FindFirst();
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, CreateFixedAsset(ProfessionalTax), CreateDepreciationBook());
        FADepreciationBook.Validate("FA Posting Group", FAPostingGroup.Code);
        FADepreciationBook.Validate("Depreciation Starting Date", CalcDate('<-CY>', WorkDate()));  // Calculate begining date of the year.
        FADepreciationBook.Validate("Depreciation Ending Date", CalcDate('<CY>', WorkDate()));  // Calculate closing date of the year.
        FADepreciationBook.Modify(true);
    end;

    local procedure CreateFixedAsset(ProfessionalTax: Option): Code[20]
    var
        FixedAsset: Record "Fixed Asset";
    begin
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        FixedAsset.Validate("Professional Tax", ProfessionalTax);
        FixedAsset.Modify(true);
        exit(FixedAsset."No.");
    end;

    local procedure CreateFAGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Assets);
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure VerifyProfessionalTaxFieldOnFACard(No: Code[20]; ProfessionalTax: Option; ProfessionalTaxCap: Text[20])
    var
        FixedAssetCard: TestPage "Fixed Asset Card";
    begin
        FixedAssetCard.OpenEdit();
        FixedAssetCard.FILTER.SetFilter("No.", No);
        FixedAssetCard."Professional Tax".AssertEquals(ProfessionalTax);
        Assert.AreEqual(ProfessionalTaxCap, FixedAssetCard."Professional Tax".Caption, UnexpectedErr);
        FixedAssetCard.Close();
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure FixedAssetProfessionalTaxRequestPageHandler(var FixedAssetProfessionalTax: TestRequestPage "Fixed Asset-Professional TaxFR")
    var
        DepreciationBooks: Variant;
        FAProfessionaTaxPercent: Variant;
        GroupTotals: Variant;
        No: Variant;
        PrintPerFixedAsset: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        LibraryVariableStorage.Dequeue(DepreciationBooks);
        LibraryVariableStorage.Dequeue(FAProfessionaTaxPercent);
        LibraryVariableStorage.Dequeue(PrintPerFixedAsset);
        LibraryVariableStorage.Dequeue(GroupTotals);
        FixedAssetProfessionalTax."Fixed Asset".SetFilter("No.", No);
        FixedAssetProfessionalTax.DepreciationBooks.SetValue(DepreciationBooks);
        FixedAssetProfessionalTax.StartingDate.SetValue(Format(CalcDate('<-CY>', WorkDate())));  // Calculate begining date of the year.
        FixedAssetProfessionalTax.EndDate.SetValue(Format(CalcDate('<CY>', WorkDate())));  // Calculate closing date of the year.
        FixedAssetProfessionalTax.GroupTotals.SetValue(GroupTotals);
        FixedAssetProfessionalTax.PrintPerFixedAsset.SetValue(PrintPerFixedAsset);
        FixedAssetProfessionalTax.FixedAssetMoreThan30years1.SetValue(Format(FAProfessionaTaxPercent));
        FixedAssetProfessionalTax.FixedAssetMoreThan30years2.SetValue(Format(FAProfessionaTaxPercent));
        FixedAssetProfessionalTax.FixedAssetLessThan30years.SetValue(Format(FAProfessionaTaxPercent));
        FixedAssetProfessionalTax.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}