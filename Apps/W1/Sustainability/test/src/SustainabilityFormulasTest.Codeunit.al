namespace Microsoft.Test.Sustainability;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.UOM;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.Ledger;

codeunit 148216 "Sustainability Formulas Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        CalculationNotSupportedErr: Label 'Calculation Foundation %1 not supported for Scope %2', Comment = '%1 = Calculation Foundation; %2 = Emission Scope Type';

    [Test]
    procedure TestEmissionIsCalculatedForScope1AndCalculationFoundationFuelElectricityInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        // when "Emission Scope" is "Scope 1" and Calculation Foundation is "Fuel/Electricity".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 1 and Calculation Foundation "Fuel/Electricity".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 1",
            "Calculation Foundation"::"Fuel/Electricity", true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(1));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, UnitOfMeasure.Code, FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [WHEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := FuelElectricity * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := FuelElectricity * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := FuelElectricity * SustainAccountSubcategory."Emission Factor N2O";
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, ExpectedEmissionCO2, ExpectedEmissionCH4, ExpectedEmissionN20, ExpectedCO2eEmission, ExpectedCarbonFee,
            UnitOfMeasure.Code, FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, ExpectedCO2eEmission);
    end;

    [Test]
    procedure TestEmissionIsCalculatedForScope1AndCalculationFoundationDistanceInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        // when "Emission Scope" is "Scope 1" and Calculation Foundation is "Distance".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 1 and Calculation Foundation "Distance".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 1",
            "Calculation Foundation"::Distance, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [WHEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := Distance * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := Distance * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := Distance * SustainAccountSubcategory."Emission Factor N2O";
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, ExpectedEmissionCO2, ExpectedEmissionCH4, ExpectedEmissionN20, ExpectedCO2eEmission, ExpectedCarbonFee,
            PurchaseLine."Unit of Measure Code", FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, ExpectedCO2eEmission);
    end;

    [Test]
    procedure TestEmissionIsCalculatedForScope1AndCalculationFoundationInstallationsInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        // when "Emission Scope" is "Scope 1" and Calculation Foundation is "Installations".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 1 and Calculation Foundation "Installations".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 1",
            "Calculation Foundation"::Installations, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [WHEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := CalculateInstallationEmission(InstallationMultiplier, CustomAmount, TimeFactor) * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := CalculateInstallationEmission(InstallationMultiplier, CustomAmount, TimeFactor) * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := CalculateInstallationEmission(InstallationMultiplier, CustomAmount, TimeFactor) * SustainAccountSubcategory."Emission Factor N2O";
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, ExpectedEmissionCO2, ExpectedEmissionCH4, ExpectedEmissionN20, ExpectedCO2eEmission, ExpectedCarbonFee,
            PurchaseLine."Unit of Measure Code", FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, ExpectedCO2eEmission);
    end;

    [Test]
    procedure TestSystemMustThrowAnErrorForScope1AndCalculationFoundationCustomInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
    begin
        // [SCENARIO 580123] Verify that system must throw an error for unsupported calculation which is not supported.
        // when "Emission Scope" is "Scope 1" and Calculation Foundation is "Custom".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 1 and Calculation Foundation "Custom".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 1",
            "Calculation Foundation"::Custom, true, true, true, LibraryRandom.RandText(100), false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [WHEN] Update Sustainability Formula fields in Purchase Line.
        asserterror UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify that system must throw an error for unsupported calculation which is not supported.
        Assert.ExpectedError(StrSubstNo(CalculationNotSupportedErr, "Calculation Foundation"::Custom, "Emission Scope"::"Scope 1"));
    end;

    [Test]
    procedure TestEmissionIsCalculatedForScope2AndCalculationFoundationFuelElectricityInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        // when "Emission Scope" is "Scope 2" and Calculation Foundation is "Fuel/Electricity".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 2 and Calculation Foundation "Fuel/Electricity".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 2",
            "Calculation Foundation"::"Fuel/Electricity", true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, UnitOfMeasure.Code, FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [WHEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := FuelElectricity * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := FuelElectricity * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := FuelElectricity * SustainAccountSubcategory."Emission Factor N2O";
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, ExpectedEmissionCO2, ExpectedEmissionCH4, ExpectedEmissionN20, ExpectedCO2eEmission, ExpectedCarbonFee,
            UnitOfMeasure.Code, FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, ExpectedCO2eEmission);
    end;

    [Test]
    procedure TestEmissionIsCalculatedForScope2AndCalculationFoundationCustomInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        // when "Emission Scope" is "Scope 2" and Calculation Foundation is "Custom".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 2 and Calculation Foundation "Custom".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 2",
            "Calculation Foundation"::Custom, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [WHEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := CustomAmount * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := CustomAmount * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := CustomAmount * SustainAccountSubcategory."Emission Factor N2O";
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, ExpectedEmissionCO2, ExpectedEmissionCH4, ExpectedEmissionN20, ExpectedCO2eEmission, ExpectedCarbonFee,
            PurchaseLine."Unit of Measure Code", FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, ExpectedCO2eEmission);
    end;

    [Test]
    procedure TestSystemMustThrowAnErrorForScope2AndCalculationFoundationDistanceInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
    begin
        // [SCENARIO 580123] Verify that system must throw an error for unsupported calculation which is not supported.
        // when "Emission Scope" is "Scope 2" and Calculation Foundation is "Distance".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 2 and Calculation Foundation "Distance".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 2",
            "Calculation Foundation"::Distance, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [WHEN] Update Sustainability Formula fields in Purchase Line.
        asserterror UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify that system must throw an error for unsupported calculation which is not supported.
        Assert.ExpectedError(StrSubstNo(CalculationNotSupportedErr, "Calculation Foundation"::Distance, "Emission Scope"::"Scope 2"));
    end;

    [Test]
    procedure TestSystemMustThrowAnErrorForScope2AndCalculationFoundationInstallationsInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
    begin
        // [SCENARIO 580123] Verify that system must throw an error for unsupported calculation which is not supported.
        // when "Emission Scope" is "Scope 2" and Calculation Foundation is "Installations".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 2 and Calculation Foundation "Installations".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 2",
            "Calculation Foundation"::Installations, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [WHEN] Update Sustainability Formula fields in Purchase Line.
        asserterror UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify that system must throw an error for unsupported calculation which is not supported.
        Assert.ExpectedError(StrSubstNo(CalculationNotSupportedErr, "Calculation Foundation"::Installations, "Emission Scope"::"Scope 2"));
    end;

    [Test]
    procedure TestEmissionIsCalculatedForScope3AndCalculationFoundationFuelElectricityInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        // when "Emission Scope" is "Scope 3" and Calculation Foundation is "Fuel/Electricity".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Fuel/Electricity".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::"Fuel/Electricity", true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, UnitOfMeasure.Code, FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [WHEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := FuelElectricity * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := FuelElectricity * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := FuelElectricity * SustainAccountSubcategory."Emission Factor N2O";
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, ExpectedEmissionCO2, ExpectedEmissionCH4, ExpectedEmissionN20, ExpectedCO2eEmission, ExpectedCarbonFee,
            UnitOfMeasure.Code, FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, ExpectedCO2eEmission);
    end;

    [Test]
    procedure TestEmissionIsCalculatedForScope3AndCalculationFoundationCustomInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        // when "Emission Scope" is "Scope 3" and Calculation Foundation is "Custom".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Custom".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::Custom, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [WHEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := CustomAmount * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := CustomAmount * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := CustomAmount * SustainAccountSubcategory."Emission Factor N2O";
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, ExpectedEmissionCO2, ExpectedEmissionCH4, ExpectedEmissionN20, ExpectedCO2eEmission, ExpectedCarbonFee,
            PurchaseLine."Unit of Measure Code", FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, ExpectedCO2eEmission);
    end;

    [Test]
    procedure TestEmissionIsCalculatedForScope3AndCalculationFoundationDistanceInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        // when "Emission Scope" is "Scope 3" and Calculation Foundation is "Distance".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Distance".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::Distance, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Invoice, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [WHEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor N2O";
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, ExpectedEmissionCO2, ExpectedEmissionCH4, ExpectedEmissionN20, ExpectedCO2eEmission, ExpectedCarbonFee,
            PurchaseLine."Unit of Measure Code", FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, ExpectedCO2eEmission);
    end;

    [Test]
    procedure TestSystemMustThrowAnErrorForScope3AndCalculationFoundationInstallationsInPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
    begin
        // [SCENARIO 580123] Verify that system must throw an error for unsupported calculation which is not supported.
        // when "Emission Scope" is "Scope 3" and Calculation Foundation is "Installations".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Installations".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::Installations, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [WHEN] Update Sustainability Formula fields in Purchase Line.
        asserterror UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify that system must throw an error for unsupported calculation which is not supported.
        Assert.ExpectedError(StrSubstNo(CalculationNotSupportedErr, "Calculation Foundation"::Installations, "Emission Scope"::"Scope 3"));
    end;

    [Test]
    procedure TestEmissionIsCalculatedForScope3AndCalculationFoundationDistanceInPurchaseCrMemoLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Cr Memo Line.
        // when "Emission Scope" is "Scope 3" and Calculation Foundation is "Distance".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Distance".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::Distance, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::"Credit Memo", LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [WHEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor N2O";
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, -ExpectedEmissionCO2, -ExpectedEmissionCH4, -ExpectedEmissionN20, -ExpectedCO2eEmission, -ExpectedCarbonFee,
            PurchaseLine."Unit of Measure Code", FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, -ExpectedCO2eEmission);
    end;

    [Test]
    procedure TestEmissionIsCalculatedForScope3AndCalculationFoundationDistanceInPurchaseReturnLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Return Order Line.
        // when "Emission Scope" is "Scope 3" and Calculation Foundation is "Distance".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Distance".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::Distance, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::"Return Order", LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Return Order Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [WHEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor N2O";
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Return Order Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, -ExpectedEmissionCO2, -ExpectedEmissionCH4, -ExpectedEmissionN20, -ExpectedCO2eEmission, -ExpectedCarbonFee,
            PurchaseLine."Unit of Measure Code", FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, -ExpectedCO2eEmission);
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeKnockedOffWhenCancelCreditMemoIsPosted()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are knocked off When Corrective Credit Memo is Posted.
        // when "Emission Scope" is "Scope 3" and Calculation Foundation is "Distance".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(100);
        Distance := LibraryRandom.RandInt(100);
        CustomAmount := LibraryRandom.RandInt(100);
        InstallationMultiplier := LibraryRandom.RandInt(100);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Distance".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::Distance, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [WHEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor N2O";

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Post a Purchase Document.
        PostAndVerifyCorrectiveCreditMemo(PurchaseHeader);

        // [THEN] Verify Sustainability Value Entry and Sustainability ledger Entry should be Knocked Off when the Corrective Credit Memo is posted.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission", "Carbon Fee");
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));
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
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityValueEntry.SetRange("Item No.", PurchaseLine."No.");
        SustainabilityValueEntry.CalcSums("CO2e Amount (Actual)", "CO2e Amount (Expected)");
        Assert.RecordCount(SustainabilityValueEntry, 2);
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));
    end;

    [Test]
    procedure TestSystemMustThrowAnErrorWhenEmissionAreUpdatedInPurchaseDocWhenSustFormulaFieldsIsNotBlank()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PurchaseOrder: TestPage "Purchase Order";
    begin
        // [SCENARIO 580123] Verify that the system must throw an error when Emissions are updated in Purchase Document.
        // When Sustainability Formula Fields are not blank and "Use Formulas In Purch. Docs" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Distance".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::Distance, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Create Purchase Order.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Modify(true);

        // [GIVEN] Create Purchase Order with one line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Modify(true);

        // [GIVEN] Open Purchase Order line.
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GotoRecord(PurchaseHeader);
        PurchaseOrder.PurchLines.GotoRecord(PurchaseLine);

        // [GIVEN] Update values in Sustainability Formula Fields on Purchase Order line.
        PurchaseOrder.PurchLines."Fuel/Electricity".SetValue(Format(LibraryRandom.RandIntInRange(10, 50)));
        PurchaseOrder.PurchLines."Distance".SetValue(Format(LibraryRandom.RandIntInRange(10, 50)));
        PurchaseOrder.PurchLines."Custom Amount".SetValue(Format(LibraryRandom.RandIntInRange(10, 50)));
        PurchaseOrder.PurchLines."Installation Multiplier".SetValue(Format(LibraryRandom.RandIntInRange(1, 3)));
        PurchaseOrder.PurchLines."Time Factor".SetValue(Format(LibraryRandom.RandIntInRange(1, 1)));

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Update "Emission CO2" on Purchase Order line.
        asserterror PurchaseOrder.PurchLines."Emission CO2".SetValue(Format(LibraryRandom.RandIntInRange(1, 5)));

        // [THEN] Verify that the system must throw an error when "Emission CO2" are updated in Purchase Document.
        Assert.ExpectedTestFieldError(PurchaseLine.FieldCaption("Fuel/Electricity"), Format(0));

        // [WHEN] Update "Emission CH4" on Purchase Order line.
        asserterror PurchaseOrder.PurchLines."Emission CH4".SetValue(Format(LibraryRandom.RandIntInRange(1, 5)));

        // [THEN] Verify that the system must throw an error when "Emission CH4" are updated in Purchase Document.
        Assert.ExpectedTestFieldError(PurchaseLine.FieldCaption("Fuel/Electricity"), Format(0));

        // [WHEN] Update "Emission N2O" on Purchase Order line.
        asserterror PurchaseOrder.PurchLines."Emission N2O".SetValue(Format(LibraryRandom.RandIntInRange(1, 5)));

        // [THEN] Verify that the system must throw an error when "Emission N2O" are updated in Purchase Document.
        Assert.ExpectedTestFieldError(PurchaseLine.FieldCaption("Fuel/Electricity"), Format(0));
    end;

    [Test]
    procedure TestSystemMustThrowAnErrorWhenSustFormulaFieldsAreUpdatedInPurchaseDocWhenEmissionIsNotBlank()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PurchaseOrder: TestPage "Purchase Order";
    begin
        // [SCENARIO 580123] Verify that the system must throw an error when Sustainability Formula fields are updated in Purchase Document.
        // When Emissions are not blank and "Use Formulas In Purch. Docs" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Distance".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::Distance, true, true, true, '', false,
            LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), LibraryRandom.RandInt(100), false);

        // [GIVEN] Create Purchase Order.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Modify(true);

        // [GIVEN] Create Purchase Order with one line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Modify(true);

        // [GIVEN] Open Purchase Order line.
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GotoRecord(PurchaseHeader);
        PurchaseOrder.PurchLines.GotoRecord(PurchaseLine);

        // [GIVEN] Update values in Sustainability Formula Fields on Purchase Order line.
        PurchaseOrder.PurchLines."Emission CO2".SetValue(Format(LibraryRandom.RandIntInRange(10, 50)));
        PurchaseOrder.PurchLines."Emission CH4".SetValue(Format(LibraryRandom.RandIntInRange(10, 50)));
        PurchaseOrder.PurchLines."Emission N2O".SetValue(Format(LibraryRandom.RandIntInRange(10, 50)));

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Update "Time Factor" on Purchase Order line.
        asserterror PurchaseOrder.PurchLines."Time Factor".SetValue(Format(LibraryRandom.RandIntInRange(1, 1)));

        // [THEN] Verify that the system must throw an error when "Time Factor" are updated in Purchase Document.
        Assert.ExpectedTestFieldError(PurchaseLine.FieldCaption("Emission CO2"), Format(0));

        // [WHEN] Update "Installation Multiplier" on Purchase Order line.
        asserterror PurchaseOrder.PurchLines."Installation Multiplier".SetValue(Format(LibraryRandom.RandIntInRange(1, 3)));

        // [THEN] Verify that the system must throw an error when "Installation Multiplier" are updated in Purchase Document.
        Assert.ExpectedTestFieldError(PurchaseLine.FieldCaption("Emission CO2"), Format(0));

        // [WHEN] Update "Fuel/Electricity" on Purchase Order line.
        asserterror PurchaseOrder.PurchLines."Fuel/Electricity".SetValue(Format(LibraryRandom.RandIntInRange(1, 3)));

        // [THEN] Verify that the system must throw an error when "Fuel/Electricity" are updated in Purchase Document.
        Assert.ExpectedTestFieldError(PurchaseLine.FieldCaption("Emission CO2"), Format(0));

        // [WHEN] Update "Distance" on Purchase Order line.
        asserterror PurchaseOrder.PurchLines."Distance".SetValue(Format(LibraryRandom.RandIntInRange(1, 3)));

        // [THEN] Verify that the system must throw an error when "Distance" are updated in Purchase Document.
        Assert.ExpectedTestFieldError(PurchaseLine.FieldCaption("Emission CO2"), Format(0));

        // [WHEN] Update "Custom Amount" on Purchase Order line.
        asserterror PurchaseOrder.PurchLines."Custom Amount".SetValue(Format(LibraryRandom.RandIntInRange(1, 3)));

        // [THEN] Verify that the system must throw an error when "Custom Amount" are updated in Purchase Document.
        Assert.ExpectedTestFieldError(PurchaseLine.FieldCaption("Emission CO2"), Format(0));

        // [WHEN] Update "Unit for Sust. Formulas" on Purchase Order line.
        asserterror PurchaseOrder.PurchLines."Unit for Sust. Formulas".SetValue(PurchaseLine."Unit of Measure Code");

        // [THEN] Verify that the system must throw an error when "Unit for Sust. Formulas" are updated in Purchase Document.
        Assert.ExpectedTestFieldError(PurchaseLine.FieldCaption("Emission CO2"), Format(0));
    end;

    [Test]
    procedure TestEmissionIsCalculatedForScope3AndCalculationFoundationDistanceInPurchaseLineWhenQuantityIsChanged()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line and Quantity is changed.
        // when "Emission Scope" is "Scope 3" and Calculation Foundation is "Distance".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(10);
        Distance := LibraryRandom.RandInt(10);
        CustomAmount := LibraryRandom.RandInt(10);
        InstallationMultiplier := LibraryRandom.RandInt(10);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Distance".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::Distance, true, true, true, '', false,
            LibraryRandom.RandInt(10), LibraryRandom.RandInt(10), LibraryRandom.RandInt(10), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Invoice, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandIntInRange(10, 20));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [GIVEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CO2";
        ExpectedEmissionCH4 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CH4";
        ExpectedEmissionN20 := Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor N2O";
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [WHEN] Update Quantity in Purchase Line.
        PurchaseLine.Validate(Quantity, LibraryRandom.RandIntInRange(1, 5));
        PurchaseLine.Modify(true);

        // [THEN] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated in Purchase Line.
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchaseLine.TableCaption()));

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, ExpectedEmissionCO2, ExpectedEmissionCH4, ExpectedEmissionN20, ExpectedCO2eEmission, ExpectedCarbonFee,
            PurchaseLine."Unit of Measure Code", FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, ExpectedCO2eEmission);
    end;

    [Test]
    procedure TestEmissionIsCalculatedForScope3AndCalculationFoundationDistanceWhenPurchaseOrderIsPartiallyPosted()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 580123] Verify that "Emission CO2", "Emission CH4" and "Emission N2O" are calculated When Purchase Order is partially posted.
        // If "Emission Scope" is "Scope 3" and Calculation Foundation is "Distance".
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(10);
        Distance := LibraryRandom.RandInt(10);
        CustomAmount := LibraryRandom.RandInt(10);
        InstallationMultiplier := LibraryRandom.RandInt(10);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Distance".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::Distance, true, true, true, '', false,
            LibraryRandom.RandInt(10), LibraryRandom.RandInt(10), LibraryRandom.RandInt(10), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, '', FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [GIVEN] Save Expected "Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission" and "Carbon Fee".
        ExpectedEmissionCO2 := (Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CO2") / 2;
        ExpectedEmissionCH4 := (Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CH4") / 2;
        ExpectedEmissionN20 := (Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor N2O") / 2;
        ExpectedCO2eEmission := ExpectedEmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + ExpectedEmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + ExpectedEmissionN20 * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [GIVEN] Update "Qty. to Receive" in Purchase Line.
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Modify(true);

        // [WHEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry is created.
        VerifySustainabilityLedgerEntry(
            AccountCode, ExpectedEmissionCO2, ExpectedEmissionCH4, ExpectedEmissionN20, ExpectedCO2eEmission, ExpectedCarbonFee,
            PurchaseLine."Unit of Measure Code", FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [THEN] Verify Sustainability Value Entry is created.
        VerifySustainabilityValueEntry(PurchaseLine."No.", 0, ExpectedCO2eEmission);
    end;

    [Test]
    procedure TestSustainabilityFieldsInPurchReceiptLineAndPurchInvoiceLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        EmissionFee: array[3] of Record "Emission Fee";
        PostedPurchInvoiceSubform: TestPage "Posted Purch. Invoice Subform";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
        FuelElectricity: Decimal;
        Distance: Decimal;
        CustomAmount: Decimal;
        InstallationMultiplier: Decimal;
        TimeFactor: Decimal;
        ExpectedEmissionCO2: Decimal;
        ExpectedEmissionN20: Decimal;
        ExpectedEmissionCH4: Decimal;
    begin
        // [SCENARIO 580123] Verify Sustainability Fields In Purchase Receipt Line and Purchase Invoice Line.
        Initialize();

        // [GIVEN] Enable "Use Formulas In Purch. Docs" in Sustainability Setup.
        LibrarySustainability.EnableFormulaInPurchDocsInSustainabilitySetup();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Random Sustainability Formula fields values.
        FuelElectricity := LibraryRandom.RandInt(10);
        Distance := LibraryRandom.RandInt(10);
        CustomAmount := LibraryRandom.RandInt(10);
        InstallationMultiplier := LibraryRandom.RandInt(10);
        TimeFactor := LibraryRandom.RandInt(1);

        // [GIVEN] Create a Sustainability Account with Scope 3 and Calculation Foundation "Distance".
        CreateSustainabilityAccount(
            AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10), "Emission Scope"::"Scope 3",
            "Calculation Foundation"::Distance, true, true, true, '', false,
            LibraryRandom.RandInt(10), LibraryRandom.RandInt(10), LibraryRandom.RandInt(10), false);

        // [GIVEN] Get "Sustainability Account" and "Sustain. Account Subcategory".
        SustainabilityAccount.Get(AccountCode);
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update Sustainability Formula fields in Purchase Line.
        UpdateSustainabilityFormulasInPurchaseLine(PurchaseLine, AccountCode, UnitOfMeasure.Code, FuelElectricity, Distance, CustomAmount, InstallationMultiplier, TimeFactor);

        // [GIVEN] Save Expected "Emission CO2", "Emission CH4" and "Emission N2O".
        ExpectedEmissionCO2 := (Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CO2") / 2;
        ExpectedEmissionCH4 := (Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor CH4") / 2;
        ExpectedEmissionN20 := (Distance * InstallationMultiplier * SustainAccountSubcategory."Emission Factor N2O") / 2;

        // [GIVEN] Update "Qty. to Receive" in Purchase Line.
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Modify(true);

        // [WHEN] Post Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Fields In Purchase Receipt Line and Purchase Invoice Line.
        PostedPurchInvoiceSubform.OpenEdit();
        PostedPurchInvoiceSubform.FILTER.SetFilter("Document No.", PostedInvoiceNo);
        PostedPurchInvoiceSubform."Sust. Account No.".AssertEquals(AccountCode);
        PostedPurchInvoiceSubform."Emission CH4".AssertEquals(ExpectedEmissionCH4);
        PostedPurchInvoiceSubform."Emission CO2".AssertEquals(ExpectedEmissionCO2);
        PostedPurchInvoiceSubform."Emission N2O".AssertEquals(ExpectedEmissionN20);
        PostedPurchInvoiceSubform."Unit for Sust. Formulas".AssertEquals(UnitOfMeasure.Code);
        PostedPurchInvoiceSubform."Fuel/Electricity".AssertEquals(FuelElectricity);
        PostedPurchInvoiceSubform."Time Factor".AssertEquals(TimeFactor);
        PostedPurchInvoiceSubform."Custom Amount".AssertEquals(CustomAmount);
        PostedPurchInvoiceSubform."Installation Multiplier".AssertEquals(InstallationMultiplier);
        PostedPurchInvoiceSubform.Distance.AssertEquals(Distance);

        PurchRcptLine.SetRange("Buy-from Vendor No.", PurchaseLine."Buy-from Vendor No.");
        PurchRcptLine.FindFirst();
        Assert.AreEqual(
            AccountCode,
            PurchRcptLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Sust. Account No."), AccountCode, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCH4,
            PurchRcptLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Emission CH4"), ExpectedEmissionCH4, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionCO2,
            PurchRcptLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Emission CO2"), ExpectedEmissionCO2, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            ExpectedEmissionN20,
            PurchRcptLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Emission N2O"), ExpectedEmissionN20, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            UnitOfMeasure.Code,
            PurchRcptLine."Unit for Sust. Formulas",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Unit for Sust. Formulas"), UnitOfMeasure.Code, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            FuelElectricity,
            PurchRcptLine."Fuel/Electricity",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Fuel/Electricity"), FuelElectricity, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            TimeFactor,
            PurchRcptLine."Time Factor",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Time Factor"), TimeFactor, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            CustomAmount,
            PurchRcptLine."Custom Amount",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Custom Amount"), CustomAmount, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            InstallationMultiplier,
            PurchRcptLine."Installation Multiplier",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Installation Multiplier"), InstallationMultiplier, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            Distance,
            PurchRcptLine.Distance,
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption(Distance), Distance, PurchRcptLine.TableCaption()));
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sustainability Formulas Test");
        LibrarySustainability.CleanUpBeforeTesting();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sustainability Formulas Test");

        LibrarySales.SetCreditWarningsToNoWarnings();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateLocalData();
        LibrarySales.SetExtDocNo(false);
        IsInitialized := true;

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sustainability Formulas Test");
    end;

    local procedure CreateSustainabilityAccount(var AccountCode: Code[20]; var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer; Scope: Enum "Emission Scope"; CalcFoundation: Enum "Calculation Foundation"; CO2: Boolean; CH4: Boolean; N2O: Boolean; CustomValue: Text; CalcFromGL: Boolean; EFCO2: Decimal; EFCH4: Decimal; EFN2O: Decimal; RenewableEnergy: Boolean): Record "Sustainability Account"
    begin
        CreateSustainabilitySubcategory(CategoryCode, SubcategoryCode, i, Scope, CalcFoundation, CO2, CH4, N2O, CustomValue, CalcFromGL, EFCO2, EFCH4, EFN2O, RenewableEnergy);
        AccountCode := StrSubstNo(AccountCodeLbl, i);

        exit(LibrarySustainability.InsertSustainabilityAccount(AccountCode, '', CategoryCode, SubcategoryCode, Enum::"Sustainability Account Type"::Posting, '', true));
    end;

    local procedure CreateSustainabilitySubcategory(var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer; Scope: Enum "Emission Scope"; CalcFoundation: Enum "Calculation Foundation"; CO2: Boolean; CH4: Boolean; N2O: Boolean; CustomValue: Text; CalcFromGL: Boolean; EFCO2: Decimal; EFCH4: Decimal; EFN2O: Decimal; RenewableEnergy: Boolean)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        CreateSustainabilityCategory(CategoryCode, i, Scope, CalcFoundation, CO2, CH4, N2O, CustomValue, CalcFromGL);

        SubcategoryCode := StrSubstNo(SubcategoryCodeLbl, i);
        LibrarySustainability.InsertAccountSubcategory(CategoryCode, SubcategoryCode, SubcategoryCode, EFCO2, EFCH4, EFN2O, RenewableEnergy);
    end;

    local procedure CreateSustainabilityCategory(var CategoryCode: Code[20]; i: Integer; Scope: Enum "Emission Scope"; CalcFoundation: Enum "Calculation Foundation"; CO2: Boolean; CH4: Boolean; N2O: Boolean; CustomValue: Text; CalcFromGL: Boolean)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        LibrarySustainability.InsertAccountCategory(CategoryCode, CategoryCode, Scope, CalcFoundation, CO2, CH4, N2O, CopyStr(CustomValue, 1, 100), CalcFromGL);
    end;

    local procedure UpdateSustainabilityFormulasInPurchaseLine(var PurchaseLine: Record "Purchase Line"; AccountCode: Code[20]; UnitForSustFormula: Code[20]; FuelElectricity: Decimal; Distance: Decimal; CustomAmount: Decimal; InstallationMultiplier: Decimal; TimeFactor: Decimal)
    begin
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Unit for Sust. Formulas", UnitForSustFormula);
        PurchaseLine.Validate("Fuel/Electricity", FuelElectricity);
        PurchaseLine.Validate(Distance, Distance);
        PurchaseLine.Validate("Custom amount", CustomAmount);
        PurchaseLine.Validate("Installation multiplier", InstallationMultiplier);
        PurchaseLine.Validate("Time Factor", TimeFactor);
        PurchaseLine.Modify(true);
    end;

    local procedure CreateEmissionFeeWithEmissionScope(var EmissionFee: array[3] of Record "Emission Fee"; EmissionScope: Enum "Emission Scope"; CountryRegionCode: Code[10])
    begin
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[1],
            "Emission Type"::CH4,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));

        LibrarySustainability.InsertEmissionFee(
            EmissionFee[2],
            "Emission Type"::CO2,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
        EmissionFee[2].Validate("Carbon Fee", LibraryRandom.RandDecInDecimalRange(0.5, 2, 1));
        EmissionFee[2].Modify();

        LibrarySustainability.InsertEmissionFee(
            EmissionFee[3],
            "Emission Type"::N2O,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
    end;

    local procedure CalculateInstallationEmission(InstallationMultiplier: Decimal; CustomAmount: Decimal; TimeFactor: Decimal): Decimal
    begin
        exit(InstallationMultiplier * CustomAmount * TimeFactor / 100);
    end;

    local procedure UpdateReasonCodeinPurchaseHeader(var PurchaseHeader: Record "Purchase Header")
    var
        ReasonCode: Record "Reason Code";
    begin
        LibraryERM.CreateReasonCode(ReasonCode);

        PurchaseHeader.Validate("Reason Code", ReasonCode.Code);
        PurchaseHeader.Modify();
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

    local procedure VerifySustainabilityValueEntry(ItemNo: Code[20]; CO2eEmissionExpected: Decimal; CO2eEmissionActual: Decimal)
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
    begin
        SustainabilityValueEntry.SetRange("Item No.", ItemNo);
        SustainabilityValueEntry.FindFirst();

        Assert.AreEqual(
            CO2eEmissionExpected,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), CO2eEmissionExpected, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            CO2eEmissionActual,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), CO2eEmissionActual, SustainabilityValueEntry.TableCaption()));
    end;

    local procedure VerifySustainabilityLedgerEntry(AccountCode: Code[20]; ExpectedEmissionCO2: Decimal; ExpectedEmissionCH4: Decimal; ExpectedEmissionN20: Decimal; ExpectedCO2eEmission: Decimal; ExpectedCarbonFee: Decimal; UnitForSustFormula: Code[20]; FuelElectricity: Decimal; Distance: Decimal; CustomAmount: Decimal; InstallationMultiplier: Decimal; TimeFactor: Decimal)
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.FindFirst();

        Assert.AreEqual(
            ExpectedEmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), ExpectedEmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
           ExpectedEmissionCH4,
           SustainabilityLedgerEntry."Emission CH4",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), ExpectedEmissionCH4, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
           ExpectedEmissionN20,
           SustainabilityLedgerEntry."Emission N2O",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), ExpectedEmissionN20, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
           ExpectedCO2eEmission,
           SustainabilityLedgerEntry."CO2e Emission",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), ExpectedCO2eEmission, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
           ExpectedCarbonFee,
           SustainabilityLedgerEntry."Carbon Fee",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), ExpectedCarbonFee, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
           UnitForSustFormula,
           SustainabilityLedgerEntry."Unit of Measure",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Unit of Measure"), UnitForSustFormula, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
           FuelElectricity,
           SustainabilityLedgerEntry."Fuel/Electricity",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Fuel/Electricity"), FuelElectricity, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
           Distance,
           SustainabilityLedgerEntry.Distance,
           StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption(Distance), Distance, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
           InstallationMultiplier,
           SustainabilityLedgerEntry."Installation Multiplier",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Installation Multiplier"), InstallationMultiplier, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
           CustomAmount,
           SustainabilityLedgerEntry."Custom Amount",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Custom Amount"), CustomAmount, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
           TimeFactor,
           SustainabilityLedgerEntry."Time Factor",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Time Factor"), TimeFactor, SustainabilityLedgerEntry.TableCaption()));
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