codeunit 148189 "Sust. Water/Waste Int. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySustainability: Codeunit "Library - Sustainability";
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        ValuesMustBeZeroErr: Label '%1, %2, %3 must be Zero.', Comment = '%1,%2,%3 = Field Caption';
        FieldShouldBeEditableErr: Label '%1 should be editable in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        FieldShouldNotBeEditableErr: Label '%1 should not be editable in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in purchase document.', Comment = '%1 = Sust. Account No.';
        CalculationNotSupportedErr: Label 'Calculation Foundation %1 not supported for Scope %2', Comment = '%1 = Calculation Foundation; %2 = Emission Scope Type';
        EmissionScopeNotSupportedErr: Label 'Emission Scope %1 is not supported With CO2,N2O,CH4.', Comment = '%1 = Emission Scope';
        CanBeUsedOnlyForWasteErr: Label '%1 can be only used for waste.', Comment = '%1 = Field Value';
        CanBeUsedOnlyForWaterErr: Label '%1 can be used only for water.', Comment = '%1 = Field Value';

    [Test]
    procedure TestWaterIntensityCanBeOnlyBeEnableOnSustAccountCategory()
    var
        SustAccountCategory: Record "Sustain. Account Category";
        CategoryCode: Code[20];
    begin
        // [SCENARIO 538580] Verify Water should only be enable on Sustainability Account Category.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account Category.
        CreateSustainabilityCategory(CategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update Water fields in the Sustainability Account Category.
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Modify(true);

        // [WHEN] Update "Waste Intensity" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate("Waste Intensity", true);

        // [VERIFY] Verify Water should only be enable on Sustainability Account Category.
        Assert.ExpectedTestFieldError(SustAccountCategory.FieldCaption("Water Intensity"), Format(false));

        // [WHEN] Update "CO2" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate(CO2, true);

        // [VERIFY] Verify expected error emission scope should not be supported.
        Assert.ExpectedError(StrSubstNo(EmissionScopeNotSupportedErr, SustAccountCategory."Emission Scope"));

        // [WHEN] Update "CH4" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate(CH4, true);

        // [VERIFY] Verify expected error emission scope should not be supported.
        Assert.ExpectedError(StrSubstNo(EmissionScopeNotSupportedErr, SustAccountCategory."Emission Scope"));

        // [WHEN] Update "N2O" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate(N2O, true);

        // [VERIFY] Verify expected error emission scope should not be supported.
        Assert.ExpectedError(StrSubstNo(EmissionScopeNotSupportedErr, SustAccountCategory."Emission Scope"));
    end;

    [Test]
    procedure TestWaterCanOnlyBeEnableOnSustAccountCategory()
    var
        SustAccountCategory: Record "Sustain. Account Category";
        CategoryCode: Code[20];
    begin
        // [SCENARIO 538580] Verify Water should only be enable on Sustainability Account Category.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account Category.
        CreateSustainabilityCategory(CategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update Water fields in the Sustainability Account Category.
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Modify(true);

        // [WHEN] Update "Waste Intensity" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate("Waste Intensity", true);

        // [VERIFY] Verify Water should only be enable on Sustainability Account Category.
        Assert.ExpectedTestFieldError(SustAccountCategory.FieldCaption("Discharged Into Water"), Format(false));

        // [WHEN] Update "CO2" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate(CO2, true);

        // [VERIFY] Verify expected error emission scope should not be supported.
        Assert.ExpectedError(StrSubstNo(EmissionScopeNotSupportedErr, SustAccountCategory."Emission Scope"));

        // [WHEN] Update "CH4" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate(CH4, true);

        // [VERIFY] Verify expected error emission scope should not be supported.
        Assert.ExpectedError(StrSubstNo(EmissionScopeNotSupportedErr, SustAccountCategory."Emission Scope"));

        // [WHEN] Update "N2O" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate(N2O, true);

        // [VERIFY] Verify expected error emission scope should not be supported.
        Assert.ExpectedError(StrSubstNo(EmissionScopeNotSupportedErr, SustAccountCategory."Emission Scope"));
    end;

    [Test]
    procedure TestWasteCanOnlyBeEnableOnSustAccountCategory()
    var
        SustAccountCategory: Record "Sustain. Account Category";
        CategoryCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Water Intensity" should only be enable on Sustainability Account Category.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account Category.
        CreateSustainabilityCategory(CategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update Water fields in the Sustainability Account Category.
        SustAccountCategory.Validate("Waste Intensity", true);
        SustAccountCategory.Modify(true);

        // [WHEN] Update "Water Intensity" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate("Water Intensity", true);

        // [VERIFY] Verify Waste should only be enable on Sustainability Account Category.
        Assert.ExpectedTestFieldError(SustAccountCategory.FieldCaption("Waste Intensity"), Format(false));

        // [WHEN] Update "CO2" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate(CO2, true);

        // [VERIFY] Verify expected error emission scope should not be supported.
        Assert.ExpectedError(StrSubstNo(EmissionScopeNotSupportedErr, SustAccountCategory."Emission Scope"));

        // [WHEN] Update "CH4" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate(CH4, true);

        // [VERIFY] Verify expected error emission scope should not be supported.
        Assert.ExpectedError(StrSubstNo(EmissionScopeNotSupportedErr, SustAccountCategory."Emission Scope"));

        // [WHEN] Update "N2O" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate(N2O, true);

        // [VERIFY] Verify expected error emission scope should not be supported.
        Assert.ExpectedError(StrSubstNo(EmissionScopeNotSupportedErr, SustAccountCategory."Emission Scope"));
    end;

    [Test]
    procedure TestEmissionFieldsCanOnlyBeEnableOnSustAccountCategory()
    var
        SustAccountCategory: Record "Sustain. Account Category";
        CategoryCode: Code[20];
    begin
        // [SCENARIO 538580] Verify Emission Fields should only be enable on Sustainability Account Category.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account Category.
        CreateSustainabilityCategory(CategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update Emission fields in the Sustainability Account Category.
        SustAccountCategory.Validate("Emission Scope", SustAccountCategory."Emission Scope"::"Scope 1");
        SustAccountCategory.Validate(CO2, true);
        SustAccountCategory.Validate(CH4, true);
        SustAccountCategory.Validate(N2O, true);
        SustAccountCategory.Modify(true);

        // [WHEN] Update "Water Intensity" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate("Water Intensity", true);

        // [VERIFY] Verify expected error Emission Scope must be Water/Waste".
        Assert.ExpectedTestFieldError(SustAccountCategory.FieldCaption("Emission Scope"), Format("Emission Scope"::"Water/Waste"));

        // [WHEN] Update "Discharged Into Water" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate("Discharged Into Water", true);

        // [VERIFY] Verify expected error Emission Scope must be Water/Waste".
        Assert.ExpectedTestFieldError(SustAccountCategory.FieldCaption("Emission Scope"), Format("Emission Scope"::"Water/Waste"));

        // [WHEN] Update "Waste Intensity" in the Sustainability Account Category.
        asserterror SustAccountCategory.Validate("Waste Intensity", true);

        // [VERIFY] Verify expected error Emission Scope must be Water/Waste".
        Assert.ExpectedTestFieldError(SustAccountCategory.FieldCaption("Emission Scope"), Format("Emission Scope"::"Water/Waste"));
    end;

    [Test]
    procedure TestIntensityFactorShouldThrowErrorWhenRenewableEnergyIsUpdated()
    var
        SustAccountCategory: Record "Sustain. Account Category";
        SustAccountSubcategory: Record "Sustain. Account Subcategory";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Renewable Energy" should not be updated to true When Intensity factor fields have values on Sustainability Account Subcategory.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account Subcategory.
        CreateSustainabilitySubcategory(CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Water Intensity" in the Sustainability Account Category.
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Get Sustainability Account Subcategory.
        SustAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update Intensity Factor fields in the Sustainability Account Subcategory.
        SustAccountSubcategory.Validate("Water Intensity Factor", LibraryRandom.RandInt(10));
        SustAccountSubcategory.Modify(true);

        // [WHEN] Update "Renewable Energy" in the Sustainability Account Category.
        asserterror SustAccountSubcategory.Validate("Renewable Energy", true);

        // [VERIFY] Verify "Renewable Energy" should not be updated to true When Intensity factor fields have values on Sustainability Account Subcategory.
        Assert.ExpectedTestFieldError(SustAccountSubcategory.FieldCaption("Water Intensity Factor"), Format(0));
    end;

    [Test]
    procedure TestRenewableEnergyShouldThrowErrorWhenIntensityFactorIsUpdated()
    var
        SustAccountSubcategory: Record "Sustain. Account Subcategory";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 538580] Verify Intensity factor fields should not be updated When "Renewable Energy" is true on Sustainability Account Subcategory.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account Subcategory.
        CreateSustainabilitySubcategory(CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account Subcategory.
        SustAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update Intensity Factor fields in the Sustainability Account Subcategory.
        SustAccountSubcategory.Validate("Renewable Energy", true);
        SustAccountSubcategory.Modify(true);

        // [GIVEN] Save Sustainability Account Subcategory.
        Commit();

        // [WHEN] Update "Water Intensity Factor" in the Sustainability Account Category.
        asserterror SustAccountSubcategory.Validate("Water Intensity Factor", LibraryRandom.RandInt(10));

        // [VERIFY] Verify Intensity factor fields should not be updated When "Renewable Energy" is true on Sustainability Account Subcategory.
        Assert.ExpectedTestFieldError(SustAccountSubcategory.FieldCaption("Renewable Energy"), Format(false));

        // [WHEN] Update "Waste Intensity Factor" in the Sustainability Account Category.
        asserterror SustAccountSubcategory.Validate("Waste Intensity Factor", LibraryRandom.RandInt(10));

        // [VERIFY] Verify Intensity factor fields should not be updated When "Renewable Energy" is true on Sustainability Account Subcategory.
        Assert.ExpectedTestFieldError(SustAccountSubcategory.FieldCaption("Renewable Energy"), Format(false));

        // [WHEN] Update "Discharged Into Water Factor" in the Sustainability Account Category.
        asserterror SustAccountSubcategory.Validate("Discharged Into Water Factor", LibraryRandom.RandInt(10));

        // [VERIFY] Verify Intensity factor fields should not be updated When "Renewable Energy" is true on Sustainability Account Subcategory.
        Assert.ExpectedTestFieldError(SustAccountSubcategory.FieldCaption("Renewable Energy"), Format(false));
    end;

    [Test]
    procedure VerifyWaterAndWaterWasteIntensityTypeShouldBeEditableForWaterSetup()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Water/Waste Intensity Type" , "Water Type" should be editable on Sustainability Journal when "Water Intensity" or "Discharged Into Water" is set to true.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Water Intensity" and "Discharged Into Water" on Sustain. Account Category.
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Open "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);

        // [VERIFY] Verify "Water/Waste Intensity Type" , "Water Type" should be editable on Sustainability Journal.
        Assert.AreEqual(
            true,
            SustainabilityJournal."Water/Waste Intensity Type".Editable(),
            StrSubstNo(FieldShouldBeEditableErr, SustainabilityJournal."Water/Waste Intensity Type".Caption(), SustainabilityJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityJournal."Water Type".Editable(),
            StrSubstNo(FieldShouldBeEditableErr, SustainabilityJournal."Water Type".Caption(), SustainabilityJournal.Caption()));

        SustainabilityJournal.Close();
    end;

    [Test]
    procedure VerifyWaterTypeShouldNotBeEditableForWasteSetup()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Water Type" should not be editable on Sustainability Journal when "Waste Intensity" is set to true.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Waste Intensity" on Sustain. Account Category.
        SustAccountCategory.Validate("Waste Intensity", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Open "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);

        // [VERIFY] Verify "Water Type" should not be editable on Sustainability Journal.
        Assert.AreEqual(
            true,
            SustainabilityJournal."Water/Waste Intensity Type".Editable(),
            StrSubstNo(FieldShouldBeEditableErr, SustainabilityJournal."Water/Waste Intensity Type".Caption(), SustainabilityJournal.Caption()));
        Assert.AreEqual(
            false,
            SustainabilityJournal."Water Type".Editable(),
            StrSubstNo(FieldShouldNotBeEditableErr, SustainabilityJournal."Water Type".Caption(), SustainabilityJournal.Caption()));

        SustainabilityJournal.Close();
    end;

    [Test]
    procedure VerifyWaterAndWaterWasteIntensityTypeShouldNotBeEditableForEmissionSetup()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Water Type" and "Water/Waste Intensity Type" should not be editable on Sustainability Journal when CO2,CH4,N2O is set to true.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update CO2,CH4,N2O on Sustain. Account Category.
        SustAccountCategory.Validate("Emission Scope", SustAccountCategory."Emission Scope"::"Scope 2");
        SustAccountCategory.Validate(CO2, true);
        SustAccountCategory.Validate(CH4, true);
        SustAccountCategory.Validate(N2O, true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Open "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);

        // [VERIFY] Verify "Water/Waste Intensity Type" and "Water Type" should not be editable on Sustainability Journal.
        Assert.AreEqual(
            false,
            SustainabilityJournal."Water/Waste Intensity Type".Editable(),
            StrSubstNo(FieldShouldNotBeEditableErr, SustainabilityJournal."Water/Waste Intensity Type".Caption(), SustainabilityJournal.Caption()));
        Assert.AreEqual(
            false,
            SustainabilityJournal."Water Type".Editable(),
            StrSubstNo(FieldShouldNotBeEditableErr, SustainabilityJournal."Water Type".Caption(), SustainabilityJournal.Caption()));

        SustainabilityJournal.Close();
    end;

    [Test]
    procedure VerifyWaterWasteIntensityTypeShouldNotBeUpdatedForWaterSetup()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Water/Waste Intensity Type" should not be updated on Sustainability Journal Line When option can only be used for Waste.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Water Intensity" and "Discharged Into Water" on Sustain. Account Category.
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);

        // [GIVEN] Save a transaction.
        commit();

        // [WHEN] Update "Water/Waste Intensity Type" to Generated in Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Generated);

        // [VERIFY] Verify "Water/Waste Intensity Type" should not be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Generated.
        Assert.ExpectedError(StrSubstNo(CanBeUsedOnlyForWasteErr, SustainabilityJournalLine."Water/Waste Intensity Type"::Generated));

        // [WHEN] Update "Water/Waste Intensity Type" to Disposed in Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Disposed);

        // [VERIFY] Verify "Water/Waste Intensity Type" should not be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Disposed.
        Assert.ExpectedError(StrSubstNo(CanBeUsedOnlyForWasteErr, SustainabilityJournalLine."Water/Waste Intensity Type"::Disposed));

        // [WHEN] Update "Water/Waste Intensity Type" to Recovered in Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Recovered);

        // [VERIFY] Verify "Water/Waste Intensity Type" should not be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Recovered.
        Assert.ExpectedError(StrSubstNo(CanBeUsedOnlyForWasteErr, SustainabilityJournalLine."Water/Waste Intensity Type"::Recovered));
    end;

    [Test]
    procedure VerifyWaterWasteIntensityTypeShouldBeUpdatedForWaterSetup()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Water/Waste Intensity Type" should be updated on Sustainability Journal Line When option can only be used for Water.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Water Intensity" and "Discharged Into Water" on Sustain. Account Category.
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Update "Water/Waste Intensity Type" in Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Withdrawn);
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Water/Waste Intensity Type" should be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Withdrawn.
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Withdrawn,
            SustainabilityJournalLine."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water/Waste Intensity Type"), "Water/Waste Intensity Type"::Withdrawn, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Update "Water/Waste Intensity Type" in Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Discharged);
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Water/Waste Intensity Type" should be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Discharged.
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Discharged,
            SustainabilityJournalLine."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water/Waste Intensity Type"), "Water/Waste Intensity Type"::Discharged, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Update "Water/Waste Intensity Type" in Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed);
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Water/Waste Intensity Type" should be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Consumed.
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed,
            SustainabilityJournalLine."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water/Waste Intensity Type"), "Water/Waste Intensity Type"::Consumed, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Update "Water/Waste Intensity Type" in Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Recycled);
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Water/Waste Intensity Type" should be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Recycled.
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Recycled,
            SustainabilityJournalLine."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water/Waste Intensity Type"), "Water/Waste Intensity Type"::Recycled, SustainabilityJournalLine.TableCaption()));
    end;

    [Test]
    procedure VerifyWaterWasteIntensityTypeShouldNotBeUpdatedForWasteSetup()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Water/Waste Intensity Type" should not be updated on Sustainability Journal Line When option can only be used for Water.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Waste Intensity" on Sustain. Account Category.
        SustAccountCategory.Validate("Waste Intensity", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);

        // [GIVEN] Save a transaction.
        commit();

        // [WHEN] Update "Water/Waste Intensity Type" to Withdrawn in Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Withdrawn);

        // [VERIFY] Verify "Water/Waste Intensity Type" should not be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Withdrawn.
        Assert.ExpectedError(StrSubstNo(CanBeUsedOnlyForWaterErr, SustainabilityJournalLine."Water/Waste Intensity Type"::Withdrawn));

        // [WHEN] Update "Water/Waste Intensity Type" to Discharged in Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Discharged);

        // [VERIFY] Verify "Water/Waste Intensity Type" should not be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Discharged.
        Assert.ExpectedError(StrSubstNo(CanBeUsedOnlyForWaterErr, SustainabilityJournalLine."Water/Waste Intensity Type"::Discharged));

        // [WHEN] Update "Water/Waste Intensity Type" to Consumed in Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed);

        // [VERIFY] Verify "Water/Waste Intensity Type" should not be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Consumed.
        Assert.ExpectedError(StrSubstNo(CanBeUsedOnlyForWaterErr, SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed));

        // [WHEN] Update "Water/Waste Intensity Type" to Recycled in Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Recycled);

        // [VERIFY] Verify "Water/Waste Intensity Type" should not be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Recycled.
        Assert.ExpectedError(StrSubstNo(CanBeUsedOnlyForWaterErr, SustainabilityJournalLine."Water/Waste Intensity Type"::Recycled));
    end;

    [Test]
    procedure VerifyWaterWasteIntensityTypeShouldBeUpdatedForWasteSetup()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Water/Waste Intensity Type" should be updated on Sustainability Journal Line When option can only be used for Waste.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Waste Intensity" on Sustain. Account Category.
        SustAccountCategory.Validate("Waste Intensity", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Update "Water/Waste Intensity Type" in Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Generated);
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Water/Waste Intensity Type" should be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Generated.
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Generated,
            SustainabilityJournalLine."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water/Waste Intensity Type"), "Water/Waste Intensity Type"::Generated, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Update "Water/Waste Intensity Type" in Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Disposed);
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Water/Waste Intensity Type" should be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Disposed.
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Disposed,
            SustainabilityJournalLine."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water/Waste Intensity Type"), "Water/Waste Intensity Type"::Disposed, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Update "Water/Waste Intensity Type" in Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Recovered);
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Water/Waste Intensity Type" should be updated on Sustainability Journal Line When "Water/Waste Intensity Type" is set to Recovered.
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Recovered,
            SustainabilityJournalLine."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water/Waste Intensity Type"), "Water/Waste Intensity Type"::Recovered, SustainabilityJournalLine.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure VerifySustainabilityLedgerEntryForWaterSetup()
    var
        NoSeries: Record "No. Series";
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
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
        // [SCENARIO 538580] Verify "Water Intensity" and "Discharged Into Water" should be updated on Sustainability Journal Line and Ledger Entry with Water Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update Unit Of Measure in Sustainability Setup.
        UpdateUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Water Intensity" and "Discharged Into Water" on Sustain. Account Category.
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Water Intensity Factor" and "Discharged Into Water Factor" on Sustain. Account SubCategory.
        SustAccountSubCategory.Validate("Water Intensity Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Validate("Discharged Into Water Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Modify(true);

        // [WHEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Water Type", SustainabilityJournalLine."Water Type"::"Ground water");
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed);
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Water Intensity" and "Discharged Into Water" should be updated on Sustainability Journal Line.
        Assert.AreEqual(
            SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Water Intensity Factor",
            SustainabilityJournalLine."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water Intensity"), SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Water Intensity Factor", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Discharged Into Water Factor",
            SustainabilityJournalLine."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Discharged Into Water"), SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Discharged Into Water Factor", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Waste Intensity"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CH4"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission N2O"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CO2"), 0, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify "Water Intensity" and "Discharged Into Water" should be updated on Sustainability Ledger Entry.
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Water Intensity Factor",
            SustainabilityLedgerEntry."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Intensity"), SustainabilityLedgerEntry."Custom Amount" * SustAccountSubCategory."Water Intensity Factor", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Discharged Into Water Factor",
            SustainabilityLedgerEntry."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Discharged Into Water"), SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Discharged Into Water Factor", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed,
            SustainabilityLedgerEntry."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water/Waste Intensity Type"), SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water Type"::"Ground water",
            SustainabilityLedgerEntry."Water Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Type"), SustainabilityJournalLine."Water Type"::"Ground water", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Waste Intensity"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityJournal.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifyWaterWasteIntensityTypeMustHaveAValueOnSustainabilityJournalLineForWaterSetup()
    var
        NoSeries: Record "No. Series";
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Water/Waste Intensity Type" must have a value error on Sustainability Journal Line during posting with Water Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update Unit Of Measure in Sustainability Setup.
        UpdateUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Water Intensity" and "Discharged Into Water" on Sustain. Account Category.
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Water Intensity Factor" and "Discharged Into Water Factor" on Sustain. Account SubCategory.
        SustAccountSubCategory.Validate("Water Intensity Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Validate("Discharged Into Water Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Modify(true);

        // [WHEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Water Type", SustainabilityJournalLine."Water Type"::"Ground water");
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        asserterror SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify "Water/Waste Intensity Type" must have a value error on Sustainability Journal Line during posting.
        Assert.ExpectedTestFieldError(SustainabilityJournalLine.FieldCaption("Water/Waste Intensity Type"), Format(SustainabilityJournalLine."Water/Waste Intensity Type"::" "));

        SustainabilityJournal.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure VerifySustainabilityLedgerEntryForWasteSetup()
    var
        NoSeries: Record "No. Series";
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
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
        // [SCENARIO 538580] Verify "Water Intensity" and "Discharged Into Water" should be updated on Sustainability Journal Line and Ledger Entry with Waste Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update Unit Of Measure in Sustainability Setup.
        UpdateUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Waste Intensity" on Sustain. Account Category.
        SustAccountCategory.Validate("Waste Intensity", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Water Intensity Factor" and "Discharged Into Water Factor" on Sustain. Account SubCategory.
        SustAccountSubCategory.Validate("Waste Intensity Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Modify(true);

        // [WHEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Recovered);
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Waste Intensity" should be updated on Sustainability Journal Line.
        Assert.AreEqual(
            SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Waste Intensity Factor",
            SustainabilityJournalLine."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Waste Intensity"), SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Waste Intensity Factor", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Discharged Into Water"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water Intensity"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CH4"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission N2O"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CO2"), 0, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify "Waste Intensity" should be updated on Sustainability Ledger Entry.
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Waste Intensity Factor",
            SustainabilityLedgerEntry."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Waste Intensity"), SustainabilityLedgerEntry."Custom Amount" * SustAccountSubCategory."Waste Intensity Factor", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Discharged Into Water"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Recovered,
            SustainabilityLedgerEntry."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water/Waste Intensity Type"), SustainabilityJournalLine."Water/Waste Intensity Type"::Recovered, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water Type"::" ",
            SustainabilityLedgerEntry."Water Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Type"), SustainabilityJournalLine."Water Type"::" ", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Intensity"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityJournal.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifyCalculationFoundationIsNotSupportedForIntensityExpectedCustom()
    var
        NoSeries: Record "No. Series";
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Calculation Foundation" is not supported for Intensity Except Custom.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Water Intensity","Calculation Foundation" and "Discharged Into Water" on Sustain. Account Category.
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Validate("Calculation Foundation", SustAccountCategory."Calculation Foundation"::Distance);
        SustAccountCategory.Modify(true);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Water Intensity Factor" and "Discharged Into Water Factor" on Sustain. Account SubCategory.
        SustAccountSubCategory.Validate("Water Intensity Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Validate("Discharged Into Water Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Modify(true);

        // [WHEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate("Water Type", SustainabilityJournalLine."Water Type"::"Ground water");
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Modify(true);

        Commit();

        // [WHEN] Update "Custom Amount" in Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Calculation Foundation" Distance is not supported for Intensity Except Custom.
        Assert.ExpectedMessage(StrSubstNo(CalculationNotSupportedErr, SustAccountCategory."Calculation Foundation", SustAccountCategory."Emission Scope"), GetLastErrorText());

        // [WHEN] Update "Calculation Foundation" on Sustain. Account Category.
        asserterror SustAccountCategory.Validate("Calculation Foundation", SustAccountCategory."Calculation Foundation"::" ");

        // [VERIFY] Verify "Calculation Foundation" Blank is not supported for Intensity Except Custom.
        Assert.ExpectedTestFieldError(SustAccountCategory.FieldCaption("Calculation Foundation"), Format(SustAccountCategory."Calculation Foundation"::" "));

        // [WHEN] Update "Calculation Foundation" on Sustain. Account Category.
        asserterror SustAccountCategory.Validate("Calculation Foundation", SustAccountCategory."Calculation Foundation"::"Fuel/Electricity");

        // [VERIFY] Verify "Calculation Foundation" Fuel/Electricity is not supported for Intensity Except Custom.
        Assert.ExpectedMessage(StrSubstNo(CalculationNotSupportedErr, SustAccountCategory."Calculation Foundation"::"Fuel/Electricity", SustAccountCategory."Emission Scope"), GetLastErrorText());

        // [WHEN] Update "Calculation Foundation" on Sustain. Account Category.
        asserterror SustAccountCategory.Validate("Calculation Foundation", SustAccountCategory."Calculation Foundation"::Installations);

        // [VERIFY] Verify "Calculation Foundation" Installations is not supported for Intensity Except Custom.
        Assert.ExpectedMessage(StrSubstNo(CalculationNotSupportedErr, SustAccountCategory."Calculation Foundation"::Installations, SustAccountCategory."Emission Scope"), GetLastErrorText());
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure VerifyCustomAmountAndUnitOfMeasureShouldBePopulatedFromResponsibilityCenter()
    var
        NoSeries: Record "No. Series";
        SustainabilitySetup: Record "Sustainability Setup";
        ResponsibilityCenter: Record "Responsibility Center";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
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
        // [SCENARIO 538580] Verify "Custom Amount" And "Unit Of Measure" should be populated from Responsibility Center on Sustainability Journal Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update Unit Of Measure in Sustainability Setup.
        UpdateUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Create Responsibility Center.
        LibrarySustainability.InsertSustainabilityResponsibilityCenter(ResponsibilityCenter, LibraryRandom.RandInt(10), SustainabilitySetup."Emission Unit of Measure Code", '');

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Water Intensity" and "Discharged Into Water" on Sustain. Account Category.
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Water Intensity Factor" and "Discharged Into Water Factor" on Sustain. Account SubCategory.
        SustAccountSubCategory.Validate("Water Intensity Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Validate("Discharged Into Water Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Water Type", SustainabilityJournalLine."Water Type"::"Ground water");
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed);
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Update "Responsibility Center" on Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Responsibility Center", ResponsibilityCenter.Code);
        SustainabilityJournalLine.Modify(true);

        // [VERIFY] Verify "Custom Amount" And "Unit Of Measure" should be populated from Responsibility Center on Sustainability Journal Line.
        Assert.AreEqual(
           ResponsibilityCenter."Water Capacity Quantity(Month)",
           SustainabilityJournalLine."Custom Amount",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Custom Amount"), ResponsibilityCenter."Water Capacity Quantity(Month)", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            ResponsibilityCenter."Water Capacity Unit",
            SustainabilityJournalLine."Unit of Measure",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Unit of Measure"), ResponsibilityCenter."Water Capacity Unit", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Water Intensity Factor",
            SustainabilityJournalLine."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water Intensity"), SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Water Intensity Factor", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Discharged Into Water Factor",
            SustainabilityJournalLine."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Discharged Into Water"), SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Discharged Into Water Factor", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Waste Intensity"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CH4"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission N2O"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CO2"), 0, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify "Water Intensity" and "Discharged Into Water" should be updated on Sustainability Ledger Entry.
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Water Intensity Factor",
            SustainabilityLedgerEntry."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Intensity"), SustainabilityLedgerEntry."Custom Amount" * SustAccountSubCategory."Water Intensity Factor", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Discharged Into Water Factor",
            SustainabilityLedgerEntry."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Discharged Into Water"), SustainabilityJournalLine."Custom Amount" * SustAccountSubCategory."Discharged Into Water Factor", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed,
            SustainabilityLedgerEntry."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water/Waste Intensity Type"), SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water Type"::"Ground water",
            SustainabilityLedgerEntry."Water Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Type"), SustainabilityJournalLine."Water Type"::"Ground water", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Waste Intensity"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityJournal.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure VerifyWaterIntensityFieldShouldBeAbleToUpdateWithManualForWaterSetup()
    var
        NoSeries: Record "No. Series";
        SustainabilitySetup: Record "Sustainability Setup";
        ResponsibilityCenter: Record "Responsibility Center";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        WaterIntensity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Water Intensity" should only be able to update on Sustainability Journal Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update Unit Of Measure in Sustainability Setup.
        UpdateUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Create Responsibility Center.
        LibrarySustainability.InsertSustainabilityResponsibilityCenter(ResponsibilityCenter, LibraryRandom.RandInt(10), SustainabilitySetup."Emission Unit of Measure Code", '');

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Water Intensity" and "Discharged Into Water" on Sustain. Account Category.
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Water Intensity Factor" on Sustain. Account SubCategory.
        SustAccountSubCategory.Validate("Water Intensity Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Water Type", SustainabilityJournalLine."Water Type"::"Ground water");
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed);
        SustainabilityJournalLine.Validate("Responsibility Center", ResponsibilityCenter.Code);
        SustainabilityJournalLine.Validate("Manual Input", true);
        SustainabilityJournalLine.Modify(true);

        // [GIVEN] Generate Random Water Intensity.
        WaterIntensity := LibraryRandom.RandInt(10);

        // [WHEN] Update "Water Intensity" on Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Water Intensity", WaterIntensity);
        SustainabilityJournalLine.Modify(true);

        // [GIVEN] Save a transaction.
        commit();

        // [VERIFY] Verify "Water Intensity" should only be able to update on Sustainability Journal Line.
        Assert.AreEqual(
           0,
           SustainabilityJournalLine."Custom Amount",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Custom Amount"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            ResponsibilityCenter."Water Capacity Unit",
            SustainabilityJournalLine."Unit of Measure",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Unit of Measure"), ResponsibilityCenter."Water Capacity Unit", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            WaterIntensity,
            SustainabilityJournalLine."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water Intensity"), WaterIntensity, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Discharged Into Water"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Waste Intensity"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CH4"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission N2O"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CO2"), 0, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Update "Discharged Into Water" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Discharged Into Water", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Discharged Into Water" should be zero on Sustainability Journal Line.
        Assert.ExpectedTestFieldError(SustainabilityJournalLine.FieldCaption("Discharged Into Water"), Format(0));

        // [WHEN] Update "Waste Intensity" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Waste Intensity", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Waste Intensity" should be zero on Sustainability Journal Line.
        Assert.ExpectedTestFieldError(SustainabilityJournalLine.FieldCaption("Waste Intensity"), Format(0));

        // [WHEN] Update "Emission CO2" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission CO2", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission CO2" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Update "Emission N2O" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission N2O", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission N2O" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Update "Emission CH4" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission CH4", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission CH4" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify "Water Intensity" should be updated on Sustainability Ledger Entry.
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            WaterIntensity,
            SustainabilityLedgerEntry."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Intensity"), WaterIntensity, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Discharged Into Water"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed,
            SustainabilityLedgerEntry."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water/Waste Intensity Type"), SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water Type"::"Ground water",
            SustainabilityLedgerEntry."Water Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Type"), SustainabilityJournalLine."Water Type"::"Ground water", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Waste Intensity"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityJournal.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure VerifyDischargedIntoWaterIntensityFieldShouldBeAbleToUpdateWithManualForWaterSetup()
    var
        NoSeries: Record "No. Series";
        SustainabilitySetup: Record "Sustainability Setup";
        ResponsibilityCenter: Record "Responsibility Center";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        DischargedIntoWater: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Discharged Into Water" should only be able to update on Sustainability Journal Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update Unit Of Measure in Sustainability Setup.
        UpdateUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Create Responsibility Center.
        LibrarySustainability.InsertSustainabilityResponsibilityCenter(ResponsibilityCenter, LibraryRandom.RandInt(10), SustainabilitySetup."Emission Unit of Measure Code", '');

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Discharged Into Water" on Sustain. Account Category.
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Discharged Into Water Factor" on Sustain. Account SubCategory.
        SustAccountSubCategory.Validate("Discharged Into Water Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Water Type", SustainabilityJournalLine."Water Type"::"Ground water");
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Discharged);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Manual Input", true);
        SustainabilityJournalLine.Modify(true);

        // [GIVEN] Generate Random Discharged Into Water Intensity.
        DischargedIntoWater := LibraryRandom.RandInt(10);

        // [WHEN] Update "Water Intensity" on Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Discharged Into Water", DischargedIntoWater);
        SustainabilityJournalLine.Modify(true);

        // [GIVEN] Save a transaction.
        commit();

        // [VERIFY] Verify "Discharged Into Water" should only be able to update on Sustainability Journal Line.
        Assert.AreEqual(
           0,
           SustainabilityJournalLine."Custom Amount",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Custom Amount"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            SustainabilitySetup."Emission Unit of Measure Code",
            SustainabilityJournalLine."Unit of Measure",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Unit of Measure"), SustainabilitySetup."Emission Unit of Measure Code", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water Intensity"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            DischargedIntoWater,
            SustainabilityJournalLine."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Discharged Into Water"), DischargedIntoWater, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Waste Intensity"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CH4"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission N2O"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CO2"), 0, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Update "Water Intensity" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Water Intensity", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Water Intensity" should be zero on Sustainability Journal Line.
        Assert.ExpectedTestFieldError(SustainabilityJournalLine.FieldCaption("Water Intensity"), Format(0));

        // [WHEN] Update "Waste Intensity" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Waste Intensity", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Waste Intensity" should be zero on Sustainability Journal Line.
        Assert.ExpectedTestFieldError(SustainabilityJournalLine.FieldCaption("Waste Intensity"), Format(0));

        // [WHEN] Update "Emission CO2" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission CO2", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission CO2" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Update "Emission N2O" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission N2O", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission N2O" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Update "Emission CH4" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission CH4", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission CH4" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify "Water Intensity" should be updated on Sustainability Ledger Entry.
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Intensity"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            DischargedIntoWater,
            SustainabilityLedgerEntry."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Discharged Into Water"), DischargedIntoWater, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Discharged,
            SustainabilityLedgerEntry."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water/Waste Intensity Type"), SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water Type"::"Ground water",
            SustainabilityLedgerEntry."Water Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Type"), SustainabilityJournalLine."Water Type"::"Ground water", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Waste Intensity"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityJournal.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure VerifyWasteIntensityFieldShouldBeAbleToUpdateWithManualForWasteSetup()
    var
        NoSeries: Record "No. Series";
        SustainabilitySetup: Record "Sustainability Setup";
        ResponsibilityCenter: Record "Responsibility Center";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        WasteIntensity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Waste Intensity" should only be able to update on Sustainability Journal Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update Unit Of Measure in Sustainability Setup.
        UpdateUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Create Responsibility Center.
        LibrarySustainability.InsertSustainabilityResponsibilityCenter(ResponsibilityCenter, LibraryRandom.RandInt(10), SustainabilitySetup."Emission Unit of Measure Code", '');

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Waste Intensity" on Sustain. Account Category.
        SustAccountCategory.Validate("Waste Intensity", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Waste Intensity Factor" on Sustain. Account SubCategory.
        SustAccountSubCategory.Validate("Waste Intensity Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Generated);
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Manual Input", true);
        SustainabilityJournalLine.Modify(true);

        // [GIVEN] Generate Random Discharged Into Waste Intensity.
        WasteIntensity := LibraryRandom.RandInt(10);

        // [WHEN] Update "Waste Intensity" on Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Waste Intensity", WasteIntensity);
        SustainabilityJournalLine.Modify(true);

        // [GIVEN] Save a transaction.
        commit();

        // [VERIFY] Verify "Waste intensity" should only be able to update on Sustainability Journal Line.
        Assert.AreEqual(
           0,
           SustainabilityJournalLine."Custom Amount",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Custom Amount"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            SustainabilitySetup."Emission Unit of Measure Code",
            SustainabilityJournalLine."Unit of Measure",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Unit of Measure"), SustainabilitySetup."Emission Unit of Measure Code", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water Intensity"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Discharged Into Water"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            WasteIntensity,
            SustainabilityJournalLine."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Waste Intensity"), WasteIntensity, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CH4"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission N2O"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CO2"), 0, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Update "Water Intensity" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Water Intensity", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Water Intensity" should be zero on Sustainability Journal Line.
        Assert.ExpectedTestFieldError(SustainabilityJournalLine.FieldCaption("Water Intensity"), Format(0));

        // [WHEN] Update "Discharged Into Water" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Discharged Into Water", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Discharged Into Water" should be zero on Sustainability Journal Line.
        Assert.ExpectedTestFieldError(SustainabilityJournalLine.FieldCaption("Discharged Into Water"), Format(0));

        // [WHEN] Update "Emission CO2" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission CO2", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission CO2" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Update "Emission N2O" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission N2O", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission N2O" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Update "Emission CH4" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission CH4", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission CH4" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify "Waste Intensity" should be updated on Sustainability Ledger Entry.
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Intensity"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Discharged Into Water"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Generated,
            SustainabilityLedgerEntry."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water/Waste Intensity Type"), SustainabilityJournalLine."Water/Waste Intensity Type"::Generated, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water Type"::" ",
            SustainabilityLedgerEntry."Water Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Type"), SustainabilityJournalLine."Water Type"::" ", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            WasteIntensity,
            SustainabilityLedgerEntry."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Waste Intensity"), WasteIntensity, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityJournal.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure VerifyWaterAndDischargedIntoWaterIntensityFieldShouldBeAbleToUpdateWithManualForWaterSetup()
    var
        NoSeries: Record "No. Series";
        SustainabilitySetup: Record "Sustainability Setup";
        ResponsibilityCenter: Record "Responsibility Center";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
        DischargedIntoWater: Decimal;
        WaterIntensity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify "Discharged Into Water" and "Water Intensity" should only be able to update on Sustainability Journal Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update Unit Of Measure in Sustainability Setup.
        UpdateUnitOfMeasureInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Create Responsibility Center.
        LibrarySustainability.InsertSustainabilityResponsibilityCenter(ResponsibilityCenter, LibraryRandom.RandInt(10), SustainabilitySetup."Emission Unit of Measure Code", '');

        // [GIVEN] Get Sustainability Journal Batch.
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Water Intensity" and "Discharged Into Water" on Sustain. Account Category.
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Water Intensity Factor" and "Discharged Into Water Factor" on Sustain. Account SubCategory.
        SustAccountSubCategory.Validate("Water Intensity Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Validate("Discharged Into Water Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Modify(true);

        // [GIVEN] Create a Sustainability Journal Line with "Unit of Measure" and "Custom Amount".
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine.Validate(Description, AccountCode);
        SustainabilityJournalLine.Validate("Water Type", SustainabilityJournalLine."Water Type"::"Ground water");
        SustainabilityJournalLine.Validate("Water/Waste Intensity Type", SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed);
        SustainabilityJournalLine.Validate("Responsibility Center", ResponsibilityCenter.Code);
        SustainabilityJournalLine.Validate("Manual Input", true);
        SustainabilityJournalLine.Modify(true);

        // [GIVEN] Generate Random Discharged Into Water Intensity.
        DischargedIntoWater := LibraryRandom.RandInt(10);
        WaterIntensity := LibraryRandom.RandInt(10);

        // [WHEN] Update "Water Intensity" and "Discharged Into Water" on Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Water Intensity", WaterIntensity);
        SustainabilityJournalLine.Validate("Discharged Into Water", DischargedIntoWater);
        SustainabilityJournalLine.Modify(true);

        // [GIVEN] Save a transaction.
        commit();

        // [VERIFY] Verify "Discharged Into Water" should only be able to update on Sustainability Journal Line.
        Assert.AreEqual(
           0,
           SustainabilityJournalLine."Custom Amount",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Custom Amount"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            ResponsibilityCenter."Water Capacity Unit",
            SustainabilityJournalLine."Unit of Measure",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Unit of Measure"), ResponsibilityCenter."Water Capacity Unit", SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            WaterIntensity,
            SustainabilityJournalLine."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Water Intensity"), WaterIntensity, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            DischargedIntoWater,
            SustainabilityJournalLine."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Discharged Into Water"), DischargedIntoWater, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Waste Intensity"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CH4"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission N2O"), 0, SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityJournalLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityJournalLine.FieldCaption("Emission CO2"), 0, SustainabilityJournalLine.TableCaption()));

        // [WHEN] Update "Waste Intensity" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Waste Intensity", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Waste Intensity" should be zero on Sustainability Journal Line.
        Assert.ExpectedTestFieldError(SustainabilityJournalLine.FieldCaption("Waste Intensity"), Format(0));

        // [WHEN] Update "Emission CO2" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission CO2", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission CO2" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Update "Emission N2O" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission N2O", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission N2O" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Update "Emission CH4" on Sustainability Journal Line.
        asserterror SustainabilityJournalLine.Validate("Emission CH4", LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Emission CH4" should be zero on Sustainability Journal Line.
        Assert.ExpectedMessage(
            StrSubstNo(
                ValuesMustBeZeroErr,
                SustainabilityJournalLine.FieldCaption("Emission CO2"), SustainabilityJournalLine.FieldCaption("Emission CH4"), SustainabilityJournalLine.FieldCaption("Emission N2O")),
                GetLastErrorText());

        // [WHEN] Open and Post "Sustainability Journal".
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        SustainabilityJournal.Post.Invoke();

        // [VERIFY] Verify "Water Intensity" should be updated on Sustainability Ledger Entry.
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            WaterIntensity,
            SustainabilityLedgerEntry."Water Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Intensity"), WaterIntensity, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            DischargedIntoWater,
            SustainabilityLedgerEntry."Discharged Into Water",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Discharged Into Water"), DischargedIntoWater, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed,
            SustainabilityLedgerEntry."Water/Waste Intensity Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water/Waste Intensity Type"), SustainabilityJournalLine."Water/Waste Intensity Type"::Consumed, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            SustainabilityJournalLine."Water Type"::"Ground water",
            SustainabilityLedgerEntry."Water Type",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Water Type"), SustainabilityJournalLine."Water Type"::"Ground water", SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Waste Intensity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Waste Intensity"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityJournal.Close();
    end;

    [Test]
    procedure VerifySustAccountIsNotAllowedToUseInPurchaseDocumentWithIntensitySetup()
    var
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SustAccountCategory: Record "Sustain. Account Category";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 538580] Verify Sustainability Ledger entry should not be created when the purchase document is Created with Intensity Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Account.
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Category.
        SustAccountCategory.Get(CategoryCode);

        // [GIVEN] Update "Water Intensity" and "Discharged Into Water" on Sustain. Account Category.
        SustAccountCategory.Validate("Discharged Into Water", true);
        SustAccountCategory.Validate("Water Intensity", true);
        SustAccountCategory.Modify(true);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Update "Water Intensity Factor" and "Discharged Into Water Factor" on Sustain. Account SubCategory.
        SustAccountSubCategory.Validate("Water Intensity Factor", LibraryRandom.RandInt(10));
        SustAccountSubCategory.Validate("Discharged Into Water Factor", LibraryRandom.RandInt(10));
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

        // [GIVEN] Update Sustainability Account No.,Emission CO2,Emission CH4,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));

        // [WHEN] Update "Sust. Account No." in Purchase Line.
        asserterror PurchaseLine.Validate("Sust. Account No.", AccountCode);

        // [VERIFY] Verify "Sust. Account No." should not selected in the purchase document with Intensity Setup.
        Assert.ExpectedError(StrSubstNo(NotAllowedToUseSustAccountForWaterOrWasteErr, AccountCode));
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
        LibrarySustainability.InsertAccountSubcategory(CategoryCode, SubcategoryCode, SubcategoryCode, 0, 0, 0, false);
    end;

    local procedure CreateSustainabilityCategory(var CategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        LibrarySustainability.InsertAccountCategory(
            CategoryCode, CategoryCode, Enum::"Emission Scope"::"Water/Waste", Enum::"Calculation Foundation"::Custom,
            false, false, false, CopyStr(LibraryRandom.RandText(10), 1, 100), false);
    end;

    local procedure UpdateUnitOfMeasureInSustainabilitySetup()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        SustainabilitySetup.Get();
        LibraryInventory.FindUnitOfMeasure(UnitOfMeasure);

        SustainabilitySetup.Validate("Emission Unit of Measure Code", UnitOfMeasure.Code);
        SustainabilitySetup.Modify();
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
}