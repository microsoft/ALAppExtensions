namespace Microsoft.Test.Sustainability;

using System.TestLibraries.Utilities;
using Microsoft.Foundation.NoSeries;
using Microsoft.Sustainability.Energy;
using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Foundation.UOM;
using Microsoft.Foundation.AuditCodes;

codeunit 148208 "Sust. Energy Tracking Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        AllEmissionsZeroErr: Label 'At least one emission must be specified.';
        EmissionMustNotBeZeroErr: Label 'The Emission fields must have a value that is not 0.';

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure VerifySustainabilityLedgerEntryWithEnergyTracking()
    var
        NoSeries: Record "No. Series";
        EnergySource: Record "Sustainability Energy Source";
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify "Energy Source Code", "Energy Consumption" and "Renewable Energy" should be updated in Sustainability Journal Line and Ledger Entry.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Energy Unit Of Measure" in Sustainability Setup.
        UpdateEnergyUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Update Factors to Zero in Sustainability Account SubCategory.
        UpdateFactorInSustAccountSubCategory(CategoryCode, SubcategoryCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [WHEN] Create a Sustainability Journal Line.
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);

        // [VERIFY] Verify "Energy Source Code" and "Renewable Energy" should be updated in Sustainability Journal Line.
        Assert.AreEqual(
            SustAccountSubCategory."Energy Source Code",
            SustainabilityJournalLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Energy Source Code"), SustAccountSubCategory."Energy Source Code", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            SustAccountSubCategory."Renewable Energy",
            SustainabilityJournalLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Renewable Energy"), SustAccountSubCategory."Renewable Energy", SustainabilityJournalLine.TableCaption()));

        // [GIVEN] Update Description, "Unit of Measure", "Energy Consumption", "Renewable Energy" in the Sustainability Journal Line.
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Energy Unit of Measure Code");
        SustainabilityJournalLine.Validate("Energy Consumption", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Validate("Renewable Energy", false);
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify "Energy Source Code", "Energy Consumption" and "Renewable Energy" should be updated in Sustainability Ledger Entry.
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            SustainabilityJournalLine."Energy Source Code",
            SustainabilityLedgerEntry."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Energy Source Code"), SustainabilityJournalLine."Energy Source Code", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Energy Consumption",
            SustainabilityLedgerEntry."Energy Consumption",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Energy Consumption"), SustainabilityJournalLine."Energy Consumption", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Renewable Energy",
            SustainabilityLedgerEntry."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Renewable Energy"), SustainabilityJournalLine."Renewable Energy", SustainabilityLedgerEntry.TableCaption()));
        SustainabilityJournal.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifySustainabilityLedgerEntryMustNotBeCreatedIfAllEmissionsAndEnergyConsumptionAreZero()
    var
        NoSeries: Record "No. Series";
        EnergySource: Record "Sustainability Energy Source";
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify system should throw an error If Emissions and Energy Consumption are Zero.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Energy Unit Of Measure" in Sustainability Setup.
        UpdateEnergyUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Update Factors to Zero in Sustainability Account SubCategory.
        UpdateFactorInSustAccountSubCategory(CategoryCode, SubcategoryCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [WHEN] Create a Sustainability Journal Line.
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);

        // [VERIFY] Verify "Energy Source Code" and "Renewable Energy" should be updated in Sustainability Journal Line.
        Assert.AreEqual(
            SustAccountSubCategory."Energy Source Code",
            SustainabilityJournalLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Energy Source Code"), SustAccountSubCategory."Energy Source Code", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            SustAccountSubCategory."Renewable Energy",
            SustainabilityJournalLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Renewable Energy"), SustAccountSubCategory."Renewable Energy", SustainabilityJournalLine.TableCaption()));

        // [GIVEN] Update Description, "Unit of Measure", "Renewable Energy" in the Sustainability Journal Line.
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Energy Unit of Measure Code");
        SustainabilityJournalLine.Validate("Renewable Energy", false);
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        asserterror SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify system should throw an error If Emissions and Energy Consumption are Zero.
        Assert.ExpectedError(AllEmissionsZeroErr);
        SustainabilityJournal.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure VerifySustainabilityLedgerEntryMustBeCreatedIfAllEmissionsAndEnergyConsumptionAreZero()
    var
        NoSeries: Record "No. Series";
        EnergySource: Record "Sustainability Energy Source";
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify Sustainability Ledger Entry must be created If Emissions, Energy Consumption are Zero and Renewable Energy is true.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Energy Unit Of Measure" in Sustainability Setup.
        UpdateEnergyUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Update Factors to Zero in Sustainability Account SubCategory.
        UpdateFactorInSustAccountSubCategory(CategoryCode, SubcategoryCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [WHEN] Create a Sustainability Journal Line.
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);

        // [VERIFY] Verify "Energy Source Code" and "Renewable Energy" should be updated in Sustainability Journal Line.
        Assert.AreEqual(
            SustAccountSubCategory."Energy Source Code",
            SustainabilityJournalLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Energy Source Code"), SustAccountSubCategory."Energy Source Code", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            SustAccountSubCategory."Renewable Energy",
            SustainabilityJournalLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Renewable Energy"), SustAccountSubCategory."Renewable Energy", SustainabilityJournalLine.TableCaption()));

        // [GIVEN] Update Description, "Unit of Measure", "Renewable Energy" in the Sustainability Journal Line.
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Energy Unit of Measure Code");
        SustainabilityJournalLine.Validate("Renewable Energy", true);
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify Sustainability Ledger Entry must be created If Emissions, Energy Consumption are Zero and Renewable Energy is true.
        SustainabilityLedgerEntry.FindFirst();
        Assert.RecordCount(SustainabilityLedgerEntry, 1);
        SustainabilityJournal.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifyEnergyConsumptionMustHaveValueIfEnergyValueRequiredIsEnabledInAccountSubCategory()
    var
        NoSeries: Record "No. Series";
        EnergySource: Record "Sustainability Energy Source";
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify system should throw an error If Energy Consumption is Zero in Sustainability Journal Line.
        // When "Energy Value Required" is true in Sustainability Account SubCategory.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Energy Unit Of Measure" in Sustainability Setup.
        UpdateEnergyUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Update Factors to Zero in Sustainability Account SubCategory.
        UpdateFactorInSustAccountSubCategory(CategoryCode, SubcategoryCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Energy Value Required" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Energy Value Required", true);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line.
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);

        // [GIVEN] Update Description, "Unit of Measure", "Renewable Energy" in the Sustainability Journal Line.
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Energy Unit of Measure Code");
        SustainabilityJournalLine.Validate("Renewable Energy", false);
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        asserterror SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify system should throw an error If Energy Consumption is Zero in Sustainability Journal Line.
        Assert.ExpectedTestFieldError(SustainabilityJournalLine.FieldCaption("Energy Consumption"), '');
        SustainabilityJournal.Close();
    end;

    [Test]
    procedure VerifyEnergySourceCodeAndRenewableEnergyFieldMustBeUpdatedFromSustAccountSubCategory()
    var
        NoSeries: Record "No. Series";
        EnergySource: Record "Sustainability Energy Source";
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify "Energy Source Code" and "Renewable Energy" must be updated in Sustainability Journal Line from "Sustain. Account Subcategory".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Energy Unit Of Measure" in Sustainability Setup.
        UpdateEnergyUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Update Factors to Zero in Sustainability Account SubCategory.
        UpdateFactorInSustAccountSubCategory(CategoryCode, SubcategoryCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [WHEN] Create a Sustainability Journal Line.
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);

        // [VERIFY] Verify "Energy Source Code" and "Renewable Energy" should be updated in Sustainability Journal Line.
        Assert.AreEqual(
            SustAccountSubCategory."Energy Source Code",
            SustainabilityJournalLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Energy Source Code"), SustAccountSubCategory."Energy Source Code", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            SustAccountSubCategory."Renewable Energy",
            SustainabilityJournalLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Renewable Energy"), SustAccountSubCategory."Renewable Energy", SustainabilityJournalLine.TableCaption()));

        // [WHEN] Update "Account Subcategory" in the Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Account Subcategory", '');
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Energy Source Code" and "Renewable Energy" should be updated in Sustainability Journal Line.
        Assert.AreEqual(
            '',
            SustainabilityJournalLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Energy Source Code"), '', SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            false,
            SustainabilityJournalLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Renewable Energy"), false, SustainabilityJournalLine.TableCaption()));
    end;

    [Test]
    procedure VerifyEnergySourceCodeMustBeRequiredInSustJnlLineWhenEnergyConsumptionIsUpdated()
    var
        NoSeries: Record "No. Series";
        EnergySource: Record "Sustainability Energy Source";
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify system should throw an error when Energy Consumption is updating.
        // If "Energy Source Code" is blank.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Energy Unit Of Measure" in Sustainability Setup.
        UpdateEnergyUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Update Factors to Zero in Sustainability Account SubCategory.
        UpdateFactorInSustAccountSubCategory(CategoryCode, SubcategoryCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create a Sustainability Journal Line.
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);

        // [WHEN] Update "Energy Consumption" in Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Energy Consumption", LibraryRandom.RandInt(10));

        // [VERIFY] Verify system should throw an error when Energy Consumption is updating If "Energy Source Code" is blank.
        Assert.ExpectedTestFieldError(SustainabilityJournalLine.FieldCaption("Energy Source Code"), '');
    end;

    [Test]
    procedure VerifyEnergyConsumptionMustBeZeroIfEnergySourceCodeIsBlankInSustJnlLine()
    var
        NoSeries: Record "No. Series";
        EnergySource: Record "Sustainability Energy Source";
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify "Energy Consumption" is zero in Sustainability Jnl Line If "Energy Source Code" is blank.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Energy Unit Of Measure" in Sustainability Setup.
        UpdateEnergyUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Update Factors to Zero in Sustainability Account SubCategory.
        UpdateFactorInSustAccountSubCategory(CategoryCode, SubcategoryCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [WHEN] Create a Sustainability Journal Line with "Energy Consumption".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Energy Consumption", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Energy Source Code" and "Renewable Energy" should be updated in Sustainability Journal Line.
        Assert.AreEqual(
            SustAccountSubCategory."Energy Source Code",
            SustainabilityJournalLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Energy Source Code"), SustAccountSubCategory."Energy Source Code", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            SustAccountSubCategory."Renewable Energy",
            SustainabilityJournalLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Renewable Energy"), SustAccountSubCategory."Renewable Energy", SustainabilityJournalLine.TableCaption()));

        // [WHEN] Update "Energy Source Code" in the Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Energy Source Code", '');
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Energy Consumption" is zero in Sustainability Jnl Line If "Energy Source Code" is blank.
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Energy Consumption",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Energy Consumption"), '', SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            true,
            SustainabilityJournalLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Renewable Energy"), true, SustainabilityJournalLine.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeCreatedWhenPurchDocumentIsPostedWithEnergyTracking()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EnergySource: Record "Sustainability Energy Source";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        EnergyConsumption: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify Sustainability Ledger entry should be created when the purchase document is posted with Energy Tracking.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Energy Unit Of Measure" in Sustainability Setup.
        UpdateEnergyUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", false);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Generate Emission, Energy Consumption.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);
        EnergyConsumption := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update "Sustainability Account No.", "Emission CO2", "Emission CH4", "Emission N2O", "Energy Consumption", "Renewable Energy" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Validate("Energy Consumption", EnergyConsumption);
        PurchaseLine.Validate("Renewable Energy", true);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger entry should be created when the purchase document is posted with Energy Tracking.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EnergyConsumption,
            SustainabilityLedgerEntry."Energy Consumption",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Energy Consumption"), EnergyConsumption, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EnergySource."No.",
            SustainabilityLedgerEntry."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Energy Source Code"), EnergySource."No.", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            true,
            SustainabilityLedgerEntry."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Renewable Energy"), true, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeCreatedWhenPurchDocumentIsPartiallyPostedWithEnergyTracking()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        EnergyConsumption: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify Sustainability Ledger entry should be created when the purchase document is partially posted with Energy Tracking.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Energy Unit Of Measure" in Sustainability Setup.
        UpdateEnergyUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", false);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Sustainability Account No.", "Emission CO2", "Emission CH4" , "Emission N2O", "Energy Consumption" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", LibraryRandom.RandInt(20));
        PurchaseLine.Validate("Emission CH4", LibraryRandom.RandInt(5));
        PurchaseLine.Validate("Emission N2O", LibraryRandom.RandInt(5));
        PurchaseLine.Validate("Energy Consumption", LibraryRandom.RandInt(5));
        PurchaseLine.Modify();

        // [GIVEN] Save Expected Emission.
        EmissionCO2 := PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionCH4 := PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionN2O := PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EnergyConsumption := PurchaseLine."Energy Consumption Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [WHEN] Post a Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger entry should be created when the purchase document is partially posted with Energy Tracking.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EnergyConsumption,
            SustainabilityLedgerEntry."Energy Consumption",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Energy Consumption"), EnergyConsumption, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EnergySource."No.",
            SustainabilityLedgerEntry."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Energy Source Code"), EnergySource."No.", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            false,
            SustainabilityLedgerEntry."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Renewable Energy"), false, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeKnockedOffWhenCancelCreditMemoIsPostedWithEnergyTracking()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EnergyConsumption: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify Sustainability Ledger entry should be Knocked Off when the Cancel Credit Memo is posted with Energy Tracking.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", false);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Generate Emission.
        EnergyConsumption := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Energy Consumption" in the Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Energy Consumption", EnergyConsumption);
        PurchaseLine.Modify();

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Post a Purchase Document.
        PostAndVerifyCancelCreditMemo(PurchaseHeader);

        // [VERIFY] Verify Sustainability Ledger entry should be Knocked Off when the Cancel Credit Memo is posted with Energy Consumption.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Energy Consumption");
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Energy Consumption",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Energy Consumption"), 0, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifySustainabilityLedgerEntryShouldBeKnockedOffWhenCorrectiveCreditMemoIsPostedWithEnergyTracking()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EnergyConsumption: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify Sustainability Ledger entry should be Knocked Off when the Corrective Credit Memo is posted with Energy Tracking.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", false);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Generate "Energy Consumption".
        EnergyConsumption := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Energy Consumption" in the Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Energy Consumption", EnergyConsumption);
        PurchaseLine.Modify();

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Post a Purchase Document.
        PostAndVerifyCorrectiveCreditMemo(PurchaseHeader);

        // [VERIFY] Verify Sustainability Ledger entry should be Knocked Off when the Corrective Credit Memo is posted with Energy Tracking.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Energy Consumption");
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Energy Consumption",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Energy Consumption"), 0, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityEnergyTrackingFieldsInPurchReceiptLineAndPurchInvoiceLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PostedPurchInvoiceSubform: TestPage "Posted Purch. Invoice Subform";
        EnergyConsumption: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 554943] Verify Sustainability Energy Tracking Fields In Purchase Receipt Line and Purchase Invoice Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Generate "Energy Consumption".
        EnergyConsumption := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update "Sustainability Account No.", "Energy Consumption" in the Purchase line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Energy Consumption", EnergyConsumption);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Energy Tracking Fields In Purchase Receipt Line and Purchase Invoice Line.
        PostedPurchInvoiceSubform.OpenEdit();
        PostedPurchInvoiceSubform.FILTER.SetFilter("Document No.", PostedInvoiceNo);
        PostedPurchInvoiceSubform."Energy Source Code".AssertEquals(SustAccountSubCategory."Energy Source Code");
        PostedPurchInvoiceSubform."Renewable Energy".AssertEquals(SustAccountSubCategory."Renewable Energy");
        PostedPurchInvoiceSubform."Energy Consumption".AssertEquals(EnergyConsumption);
        PostedPurchInvoiceSubform."Sust. Account No.".AssertEquals(AccountCode);

        PurchRcptLine.SetRange("Buy-from Vendor No.", PurchaseLine."Buy-from Vendor No.");
        PurchRcptLine.FindFirst();
        Assert.AreEqual(
            AccountCode,
            PurchRcptLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Sust. Account No."), AccountCode, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            SustAccountSubCategory."Energy Source Code",
            PurchRcptLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Energy Source Code"), SustAccountSubCategory."Energy Source Code", PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            SustAccountSubCategory."Renewable Energy",
            PurchRcptLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Renewable Energy"), SustAccountSubCategory."Renewable Energy", PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            EnergyConsumption,
            PurchRcptLine."Energy Consumption",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Energy Consumption"), EnergyConsumption, PurchRcptLine.TableCaption()));
    end;

    [Test]
    procedure VerifyPostedEnergyTrackingFieldsInPurchaseLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EnergyConsumption: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify "Posted Energy Consumption" field in Purchase Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Sustainability Account No.", "Energy Consumption" in the Purchase line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Energy Consumption", LibraryRandom.RandInt(20));
        PurchaseLine.Modify();

        // [GIVEN] Save Expected "Energy Consumption".
        EnergyConsumption := PurchaseLine."Energy Consumption Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [WHEN] Post a Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify "Posted Energy Consumption" in Purchase Line.
        PurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.");
        Assert.AreEqual(
            EnergyConsumption,
            PurchaseLine."Posted Energy Consumption",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Energy Consumption"), EnergyConsumption, PurchaseLine.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('PurchOrderStatisticsPageHandler')]
    procedure VerifySustainabilityEnergyTrackingFieldsInPurchOrderStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EnergyConsumption: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify Sustainability Energy Tracking Fields in Purchase Order Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Generate "Energy Consumption".
        EnergyConsumption := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Sustainability Account No.", "Energy Consumption" in the Purchase line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Energy Consumption", EnergyConsumption);
        PurchaseLine.Modify();

        // [WHEN] Save "Energy Consumption".
        LibraryVariableStorage.Enqueue(EnergyConsumption);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability "Energy Consumption" field in Page "Purchase Order Statistics" before posting of Purchase order.
        OpenPurchOrderStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();

        // [GIVEN] Post a Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Save Sustainability Energy Tracking fields.
        LibraryVariableStorage.Enqueue(EnergyConsumption);
        LibraryVariableStorage.Enqueue(PurchaseLine."Energy Consumption Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));

        // [VERIFY] Verify Sustainability Energy Tracking fields in Page "Purchase Order Statistics" after partially posting of Purchase order.
        OpenPurchOrderStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('PurchInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityEnergyTrackingFieldsInPurchInvoiceStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EnergyConsumption: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify Sustainability Energy Tracking Fields in Purchase Invoice Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", false);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Generate "Energy Consumption".
        EnergyConsumption := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Invoice, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Sustainability Account No.", "Energy Consumption" in the Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Energy Consumption", EnergyConsumption);
        PurchaseLine.Modify();

        // [WHEN] Save Sustainability Energy Tracking fields.
        LibraryVariableStorage.Enqueue(EnergyConsumption);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability Energy Tracking fields in Page "Purchase Invoice Statistics" before posting of Purchase Invoice.
        OpenPurchInvoiceStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();
    end;

    [Test]
    procedure VerifySustainabilityEnergyTrackingFieldsInPostedPurchaseInvoiceStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EnergyConsumption: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 554943] Verify Sustainability Fields in Posted Purchase Invoice Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", false);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Generate "Energy Consumption".
        EnergyConsumption := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Sustainability Account No.", "Energy Consumption" in the Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Energy Consumption", EnergyConsumption);
        PurchaseLine.Modify();

        // [GIVEN] Save Sustainability "Energy Consumption" fields.
        LibraryVariableStorage.Enqueue(EnergyConsumption);

        // [WHEN] Post Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Energy Tracking fields in Page "Posted Purchase Invoice Statistics".
        VerifyPostedPurchaseInvoiceStatistics(PostedInvoiceNo);
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('PurchInvoiceStatisticsPageHandler,ConfirmHandler')]
    procedure VerifySustainabilityEnergyTrackingFieldsInPurchCrMemoStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EnergyConsumption: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        CrMemoNo: Code[20];
        PostedCrMemoNo: Code[20];
    begin
        // [SCENARIO 554943] Verify Sustainability Energy Tracking fields in Posted Purchase Cr Memo Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", false);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Sustainability Account No.", "Energy Consumption" in the Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Energy Consumption", LibraryRandom.RandInt(20));
        PurchaseLine.Modify();

        // [GIVEN] Save Expected "Energy Consumption".
        EnergyConsumption := PurchaseLine."Energy Consumption Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [WHEN] Save Sustainability "Energy Consumption" fields.
        LibraryVariableStorage.Enqueue(EnergyConsumption);
        LibraryVariableStorage.Enqueue(0);

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [VERIFY] Verify Sustainability Energy Tracking fields in Page "Purchase Cr Memo Statistics" before posting of Purchase Cr Memo.
        CrMemoNo := CreateCorrectiveCreditMemoAndOpenPurchCrMemoStatistics(PurchaseHeader);

        // [GIVEN] Post Corrective Credit Memo.
        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", CrMemoNo);
        PostedCrMemoNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Clear Variable Storage.
        LibraryVariableStorage.Clear();

        // [WHEN] Save Sustainability "Energy Consumption" field.
        LibraryVariableStorage.Enqueue(-EnergyConsumption);

        // [VERIFY] Verify Sustainability Energy Tracking fields in Page "Posted Purchase Cr Memo Statistics" after posting of Purchase Cr Memo.
        VerifyPostedPurchaseCrMemoStatistics(PostedCrMemoNo);
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('PurchInvoiceStatisticsPageHandler,ConfirmHandler')]
    procedure VerifySustainabilityEnergyTrackingFieldsInPurchCrMemoSubFormPage()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCrMemoSubformPage: TestPage "Purch. Cr. Memo Subform";
        PostedPurchCrMemoSubformPage: TestPage "Posted Purch. Cr. Memo Subform";
        EnergyConsumption: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        CrMemoNo: Code[20];
        PostedCrMemoNo: Code[20];
    begin
        // [SCENARIO 554943] Verify Sustainability Energy Tracking fields in Purchase Cr Memo SubForm Page.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Sustainability Account No.", "Energy Consumption" in the Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Energy Consumption", LibraryRandom.RandInt(20));
        PurchaseLine.Modify();

        // [GIVEN] Save Expected "Energy Consumption".
        EnergyConsumption := PurchaseLine."Energy Consumption Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [WHEN] Save Sustainability "Energy Consumption" fields.
        LibraryVariableStorage.Enqueue(EnergyConsumption);
        LibraryVariableStorage.Enqueue(0);

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Create Corrective Credit Memo.
        CrMemoNo := CreateCorrectiveCreditMemoAndOpenPurchCrMemoStatistics(PurchaseHeader);

        // [VERIFY] Verify Sustainability Energy Tracking fields before posting of Corrective Credit Memo.
        PurchCrMemoSubformPage.OpenEdit();
        PurchCrMemoSubformPage.Filter.SetFilter("Document No.", CrMemoNo);
        PurchCrMemoSubformPage.Filter.SetFilter("No.", PurchaseLine."No.");
        PurchCrMemoSubformPage."Sust. Account No.".AssertEquals(AccountCode);
        PurchCrMemoSubformPage."Energy Source Code".AssertEquals(SustAccountSubCategory."Energy Source Code");
        PurchCrMemoSubformPage."Energy Consumption".AssertEquals(EnergyConsumption);
        PurchCrMemoSubformPage."Renewable Energy".AssertEquals(SustAccountSubCategory."Renewable Energy");

        // [GIVEN] Post Corrective Credit Memo.
        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", CrMemoNo);
        PostedCrMemoNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Clear Variable Storage.
        LibraryVariableStorage.Clear();

        // [VERIFY] Verify Sustainability Energy Tracking fields After posting of Corrective Credit Memo.
        PostedPurchCrMemoSubformPage.OpenEdit();
        PostedPurchCrMemoSubformPage.Filter.SetFilter("Document No.", PostedCrMemoNo);
        PostedPurchCrMemoSubformPage.Filter.SetFilter("No.", PurchaseLine."No.");
        PostedPurchCrMemoSubformPage."Sust. Account No.".AssertEquals(AccountCode);
        PostedPurchCrMemoSubformPage."Energy Source Code".AssertEquals(SustAccountSubCategory."Energy Source Code");
        PostedPurchCrMemoSubformPage."Energy Consumption".AssertEquals(EnergyConsumption);
        PostedPurchCrMemoSubformPage."Renewable Energy".AssertEquals(SustAccountSubCategory."Renewable Energy");
    end;

    [Test]
    procedure VerifySustLedgerEntryMustNotBeCreatedIfAllEmissionsAndEnergyConsumptionAreZeroInPurchaseOrder()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify system should throw an error If Emissions and Energy Consumption are Zero.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", false);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [WHEN] Update "Sustainability Account No." in the Purchase line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Modify();

        // [VERIFY] Verify "Energy Source Code" and "Renewable Energy" should be updated in Purchase Line.
        Assert.AreEqual(
            SustAccountSubCategory."Energy Source Code",
            PurchaseLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Energy Source Code"), SustAccountSubCategory."Energy Source Code", PurchaseLine.TableCaption()));
        Assert.AreEqual(
            SustAccountSubCategory."Renewable Energy",
            PurchaseLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Renewable Energy"), SustAccountSubCategory."Renewable Energy", PurchaseLine.TableCaption()));

        // [WHEN] Post a Purchase Document.
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify system should throw an error If Emissions and Energy Consumption are Zero.
        Assert.ExpectedError(EmissionMustNotBeZeroErr);
    end;

    [Test]
    procedure VerifyEnergyConsumptionMustHaveValueIfEnergyValueRequiredIsEnabledInAccountSubCategoryForPurchDocument()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify system should throw an error If Energy Consumption is Zero in Purchase Line.
        // When "Energy Value Required" is true in Sustainability Account SubCategory.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy", "Energy Value Required" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Validate("Energy Value Required", true);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [WHEN] Update "Sustainability Account No." in the Purchase line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Modify();

        // [VERIFY] Verify "Energy Source Code" and "Renewable Energy" should be updated in Purchase Line.
        Assert.AreEqual(
            SustAccountSubCategory."Energy Source Code",
            PurchaseLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Energy Source Code"), SustAccountSubCategory."Energy Source Code", PurchaseLine.TableCaption()));
        Assert.AreEqual(
            SustAccountSubCategory."Renewable Energy",
            PurchaseLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Renewable Energy"), SustAccountSubCategory."Renewable Energy", PurchaseLine.TableCaption()));

        // [WHEN] Post a Purchase Document.
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify system should throw an error If Energy Consumption is Zero in Purchase Line.
        Assert.ExpectedTestFieldError(PurchaseLine.FieldCaption("Energy Consumption"), '');
    end;

    [Test]
    procedure VerifyEnergySourceCodeAndRenewableEnergyFieldMustBeUpdatedFromSustAccountSubCategoryForPurchDocument()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify "Energy Source Code" and "Renewable Energy" must be updated in Purchase Line from "Sustain. Account Subcategory".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy", "Energy Value Required" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [WHEN] Update "Sustainability Account No." in the Purchase line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Modify();

        // [VERIFY] Verify "Energy Source Code" and "Renewable Energy" should be updated in Purchase Line.
        Assert.AreEqual(
            SustAccountSubCategory."Energy Source Code",
            PurchaseLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Energy Source Code"), SustAccountSubCategory."Energy Source Code", PurchaseLine.TableCaption()));
        Assert.AreEqual(
            SustAccountSubCategory."Renewable Energy",
            PurchaseLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Renewable Energy"), SustAccountSubCategory."Renewable Energy", PurchaseLine.TableCaption()));

        // [WHEN] Update "Account Subcategory" in the Purchase Line.
        PurchaseLine.Validate("Sust. Account Subcategory", '');
        PurchaseLine.Modify(true);

        // [VERIFY] Verify "Energy Source Code" and "Renewable Energy" should be updated in Purchase Line.
        Assert.AreEqual(
            '',
            PurchaseLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Energy Source Code"), '', PurchaseLine.TableCaption()));
        Assert.AreEqual(
            false,
            PurchaseLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Renewable Energy"), false, PurchaseLine.TableCaption()));
    end;

    [Test]
    procedure VerifyEnergySourceCodeMustBeRequiredInPurchaseLineWhenEnergyConsumptionIsUpdated()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify system should throw an error when Energy Consumption is updating.
        // If "Energy Source Code" is blank.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy", "Energy Value Required" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [THEN] Update "Sustainability Account No." in the Purchase line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Modify();

        // [WHEN] Update "Energy Consumption" in Purchase Line.
        asserterror PurchaseLine.Validate("Energy Consumption", LibraryRandom.RandInt(10));

        // [VERIFY] Verify system should throw an error when Energy Consumption is updating If "Energy Source Code" is blank.
        Assert.ExpectedTestFieldError(PurchaseLine.FieldCaption("Energy Source Code"), '');
    end;

    [Test]
    procedure VerifyEnergyConsumptionMustBeZeroIfEnergySourceCodeIsBlankInPurchaseLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        EnergySource: Record "Sustainability Energy Source";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 554943] Verify "Energy Consumption" is zero in Purchase Line If "Energy Source Code" is blank.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Energy Sources.
        LibrarySustainability.InsertSustainabilityEnergySource(EnergySource);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Energy Source Code", "Renewable Energy", "Energy Value Required" in Sustainability Account SubCategory.
        SustAccountSubCategory.Validate("Energy Source Code", EnergySource."No.");
        SustAccountSubCategory.Validate("Renewable Energy", true);
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [WHEN] Update "Sustainability Account No.", "Energy Consumption" in the Purchase line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Energy Consumption", LibraryRandom.RandInt(10));
        PurchaseLine.Modify();

        // [VERIFY] Verify "Energy Source Code" and "Renewable Energy" should be updated in Purchase Line.
        Assert.AreEqual(
            SustAccountSubCategory."Energy Source Code",
            PurchaseLine."Energy Source Code",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Energy Source Code"), SustAccountSubCategory."Energy Source Code", PurchaseLine.TableCaption()));
        Assert.AreEqual(
            SustAccountSubCategory."Renewable Energy",
            PurchaseLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Renewable Energy"), SustAccountSubCategory."Renewable Energy", PurchaseLine.TableCaption()));

        // [WHEN] Update "Energy Source Code" in the Purchase Line.
        PurchaseLine.Validate("Energy Source Code", '');
        PurchaseLine.Modify(true);

        // [VERIFY] Verify "Energy Consumption" is zero in Purchase Line If "Energy Source Code" is blank.
        Assert.AreEqual(
            0,
            PurchaseLine."Energy Consumption",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Energy Consumption"), '', PurchaseLine.TableCaption()));
        Assert.AreEqual(
            true,
            PurchaseLine."Renewable Energy",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Renewable Energy"), true, PurchaseLine.TableCaption()));
    end;

    local procedure CreateSustainabilityAccount(var AccountCode: Code[20]; var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer): Record "Sustainability Account"
    begin
        CreateSustainabilitySubcategory(CategoryCode, SubcategoryCode, i);
        AccountCode := StrSubstNo(AccountCodeLbl, i);
        exit(LibrarySustainability.InsertSustainabilityAccount(
            AccountCode, '', CategoryCode, SubcategoryCode, Enum::"Sustainability Account Type"::Posting, '', true));
    end;

    local procedure CreateSustainabilitySubcategory(var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        CreateSustainabilityCategory(CategoryCode, i);

        SubcategoryCode := StrSubstNo(SubcategoryCodeLbl, i);
        LibrarySustainability.InsertAccountSubcategory(CategoryCode, SubcategoryCode, SubcategoryCode, 1, 2, 3, false);
    end;

    local procedure CreateSustainabilityCategory(var CategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        LibrarySustainability.InsertAccountCategory(
            CategoryCode, CategoryCode, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::"Fuel/Electricity",
            true, true, true, '', false);
    end;

    local procedure UpdateEnergyUnitOfMeasureInSustainabilitySetup()
    var
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        LibraryInventory.FindUnitOfMeasure(UnitOfMeasure);

        SustainabilitySetup.Get();
        SustainabilitySetup.Validate("Energy Unit of Measure Code", UnitOfMeasure.Code);
        SustainabilitySetup.Modify();
    end;

    local procedure UpdateFactorInSustAccountSubCategory(CategoryCode: Code[20]; SubcategoryCode: Code[20])
    var
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
    begin
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        SustAccountSubCategory.Validate("Emission Factor CO2", 0);
        SustAccountSubCategory.Validate("Emission Factor CH4", 0);
        SustAccountSubCategory.Validate("Emission Factor N2O", 0);
        SustAccountSubCategory.Validate("Water Intensity Factor", 0);
        SustAccountSubCategory.Validate("Discharged Into Water Factor", 0);
        SustAccountSubCategory.Validate("Waste Intensity Factor", 0);
        SustAccountSubCategory.Modify();
    end;

    local procedure UpdateReasonCodeinPurchaseHeader(var PurchaseHeader: Record "Purchase Header")
    var
        ReasonCode: Record "Reason Code";
    begin
        LibraryERM.CreateReasonCode(ReasonCode);

        PurchaseHeader.Validate("Reason Code", ReasonCode.Code);
        PurchaseHeader.Modify();
    end;

    local procedure PostAndVerifyCancelCreditMemo(PurchaseHeader: Record "Purchase Header")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchInvHeader.Get(PostedDocNumber);
        CorrectPostedPurchInvoice.CancelPostedInvoice(PurchInvHeader);
    end;

    local procedure PostAndVerifyCorrectiveCreditMemo(PurchaseHeader: Record "Purchase Header")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchInvHeader.Get(PostedDocNumber);

        // Create Corrective Credit Memo.
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvHeader, PurchaseHeader);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryRandom.RandText(10));
        PurchaseHeader.Modify();

        // Post Corrective Credit Memo.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure OpenPurchOrderStatistics(No: Code[20])
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseOrder.OpenEdit();
        PurchaseOrder.FILTER.SetFilter("No.", No);
        PurchaseOrder.PurchaseOrderStatistics.Invoke();
    end;

    local procedure OpenPurchInvoiceStatistics(No: Code[20])
    var
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        PurchaseInvoice.OpenEdit();
        PurchaseInvoice.FILTER.SetFilter("No.", No);
        PurchaseInvoice.PurchaseStatistics.Invoke();
    end;

    local procedure VerifyPostedPurchaseInvoiceStatistics(No: Code[20])
    var
        PostedPurchaseInvoiceStatisticsPage: TestPage "Purchase Invoice Statistics";
        PostedEnergyConsumption: Variant;
    begin
        LibraryVariableStorage.Dequeue(PostedEnergyConsumption);

        PostedPurchaseInvoiceStatisticsPage.OpenEdit();
        PostedPurchaseInvoiceStatisticsPage.FILTER.SetFilter("No.", No);
        PostedPurchaseInvoiceStatisticsPage."Energy Consumption".AssertEquals(PostedEnergyConsumption);
    end;

    local procedure CreateCorrectiveCreditMemoAndOpenPurchCrMemoStatistics(PurchaseHeader: Record "Purchase Header"): Code[20]
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchInvHeader.Get(PostedDocNumber);

        // Create Corrective Credit Memo.
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvHeader, PurchaseHeader);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryRandom.RandText(10));
        PurchaseHeader.Modify();

        // Open Purchase Cr Memo Statistics.
        OpenPurchCrMemoStatistics(PurchaseHeader."No.");

        exit(PurchaseHeader."No.");
    end;

    local procedure OpenPurchCrMemoStatistics(No: Code[20])
    var
        PurchaseCreditMemo: TestPage "Purchase Credit Memo";
    begin
        PurchaseCreditMemo.OpenEdit();
        PurchaseCreditMemo.FILTER.SetFilter("No.", No);
        PurchaseCreditMemo.PurchaseStatistics.Invoke();
    end;

    local procedure VerifyPostedPurchaseCrMemoStatistics(No: Code[20])
    var
        PostedPurchaseCreditMemoStatisticsPage: TestPage "Purch. Credit Memo Statistics";
        PostedEnergyConsumption: Variant;
    begin
        LibraryVariableStorage.Dequeue(PostedEnergyConsumption);

        PostedPurchaseCreditMemoStatisticsPage.OpenEdit();
        PostedPurchaseCreditMemoStatisticsPage.FILTER.SetFilter("No.", No);
        PostedPurchaseCreditMemoStatisticsPage."Energy Consumption".AssertEquals(PostedEnergyConsumption);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin
    end;

    [PageHandler]
    procedure PurchOrderStatisticsPageHandler(var PurchaseOrderStatisticsPage: TestPage "Purchase Order Statistics")
    var
        EnergyConsumption: Variant;
        PostedEnergyConsumption: Variant;
    begin
        LibraryVariableStorage.Dequeue(EnergyConsumption);
        LibraryVariableStorage.Dequeue(PostedEnergyConsumption);

        PurchaseOrderStatisticsPage."Energy Consumption".AssertEquals(EnergyConsumption);
        PurchaseOrderStatisticsPage."Posted Energy Consumption".AssertEquals(PostedEnergyConsumption);
    end;

    [PageHandler]
    procedure PurchInvoiceStatisticsPageHandler(var PurchaseStatisticsPage: TestPage "Purchase Statistics")
    var
        EnergyConsumption: Variant;
        PostedEnergyConsumption: Variant;
    begin
        LibraryVariableStorage.Dequeue(EnergyConsumption);
        LibraryVariableStorage.Dequeue(PostedEnergyConsumption);

        PurchaseStatisticsPage."Energy Consumption".AssertEquals(EnergyConsumption);
        PurchaseStatisticsPage."Posted Energy Consumption".AssertEquals(PostedEnergyConsumption);
    end;
}