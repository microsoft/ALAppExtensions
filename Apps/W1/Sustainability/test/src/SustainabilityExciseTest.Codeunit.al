namespace Microsoft.Test.Sustainability;

using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.CBAM;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.ExciseTax;

codeunit 148214 "Sustainability Excise Test"
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
        CO2eMustNotBeZeroErr: Label 'The CO2e fields must have a value that is not 0.';
        EmissionMustNotBeZeroErr: Label 'The Emission fields must have a value that is not 0.';
        FieldShouldBeVisibleErr: Label '%1 should be visible in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        UnsupportedEntryErr: Label '%1 %2 is supported with %3 %4', Comment = '%1 = Field Caption, %2 = Field Value, %3 = Field Caption, %4 = Field Value';

    [Test]
    procedure TestCBAMRelatedFieldsShouldFlowInPurchaseInvoiceLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        PurchaseInvLine: Record "Purch. Inv. Line";
        SustainabilityAccount: Record "Sustainability Account";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalEmissionCost: Decimal;
    begin
        // [SCENARIO 537459] Verify that the CBAM-related fields flow to the "Purch. Inv. Line".
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        TotalEmissionCost := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,"Total Emission Cost", "CBAM Compliance", "Source of Emission Data" and "Emission Verified" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", LibraryRandom.RandInt(5));
        PurchaseLine.Validate("Emission CH4", LibraryRandom.RandInt(5));
        PurchaseLine.Validate("Emission N2O", LibraryRandom.RandInt(5));
        PurchaseLine.Validate("Total Emission Cost", TotalEmissionCost);
        PurchaseLine.Validate("CBAM Compliance", false);
        PurchaseLine.Validate("Source of Emission Data", PurchaseLine."Source of Emission Data"::Other);
        PurchaseLine.Validate("Emission Verified", true);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PurchaseInvHeader.Get(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));

        // [THEN] Verify that the CBAM-related fields flow to the "Purch. Inv. Line".
        FindPurchaseInvoiceLine(PurchaseInvHeader, PurchaseInvLine);
        Assert.AreEqual(
            TotalEmissionCost,
            PurchaseInvLine."Total Emission Cost",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("Total Emission Cost"), TotalEmissionCost, PurchaseInvLine.TableCaption()));
        Assert.AreEqual(
            false,
            PurchaseInvLine."CBAM Compliance",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("CBAM Compliance"), false, PurchaseInvLine.TableCaption()));
        Assert.AreEqual(
            PurchaseInvLine."Source of Emission Data"::Other,
            PurchaseInvLine."Source of Emission Data",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("Source of Emission Data"), PurchaseInvLine."Source of Emission Data"::Other, PurchaseInvLine.TableCaption()));
        Assert.AreEqual(
            true,
            PurchaseInvLine."Emission Verified",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("Emission Verified"), true, PurchaseInvLine.TableCaption()));
    end;

    [Test]
    procedure TestCBAMRelatedFieldsShouldFlowInPurchaseInvoiceLineFromItem()
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        PurchaseInvLine: Record "Purch. Inv. Line";
        SustainabilityAccount: Record "Sustainability Account";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalEmissionCost: Decimal;
    begin
        // [SCENARIO 537459] Verify that the CBAM-related fields flow to the "Purch. Inv. Line" from item.
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Update "CBAM Compliance", "Source of Emission Data" and "Emission Verified" in Item.
        Item.Validate("CBAM Compliance", false);
        Item.Validate("Source of Emission Data", PurchaseLine."Source of Emission Data"::Other);
        Item.Validate("Emission Verified", true);
        Item.Modify();

        // [GIVEN] Generate Emission.
        TotalEmissionCost := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            Item."No.",
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,"Total Emission Cost" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", LibraryRandom.RandInt(5));
        PurchaseLine.Validate("Emission CH4", LibraryRandom.RandInt(5));
        PurchaseLine.Validate("Emission N2O", LibraryRandom.RandInt(5));
        PurchaseLine.Validate("Total Emission Cost", TotalEmissionCost);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PurchaseInvHeader.Get(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));

        // [THEN] Verify that the CBAM-related fields flow to the "Purch. Inv. Line" from item.
        FindPurchaseInvoiceLine(PurchaseInvHeader, PurchaseInvLine);
        Assert.AreEqual(
            TotalEmissionCost,
            PurchaseInvLine."Total Emission Cost",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("Total Emission Cost"), TotalEmissionCost, PurchaseInvLine.TableCaption()));
        Assert.AreEqual(
            false,
            PurchaseInvLine."CBAM Compliance",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("CBAM Compliance"), false, PurchaseInvLine.TableCaption()));
        Assert.AreEqual(
            PurchaseInvLine."Source of Emission Data"::Other,
            PurchaseInvLine."Source of Emission Data",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("Source of Emission Data"), PurchaseInvLine."Source of Emission Data"::Other, PurchaseInvLine.TableCaption()));
        Assert.AreEqual(
            true,
            PurchaseInvLine."Emission Verified",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("Emission Verified"), true, PurchaseInvLine.TableCaption()));
    end;

    [Test]
    procedure VerifyTotalEmissionCostMustBeUpdatedFromCarbonPriceInPurchaseLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseHeader: Record "Purchase Header";
        CountryRegion: Record "Country/Region";
        PurchaseLine: Record "Purchase Line";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        PurchaseInvLine: Record "Purch. Inv. Line";
        CarbonPricing: Record "Sustainability Carbon Pricing";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537459] Verify that the "Total Emission Cost" is updated from the "Carbon Pricing" in the Purchase Line.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.Validate("Order Date", WorkDate());
        PurchaseHeader."Buy-from Country/Region Code" := CountryRegion.Code;
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Create Carbon Pricing.
        LibrarySustainability.CreateCarbonPricing(
            CarbonPricing,
            CountryRegion.Code,
            CalcDate('<-CY>', WorkDate()),
            CalcDate('<CY>', WorkDate()),
            PurchaseLine."Unit of Measure Code",
            ExpectedCO2eEmission - 1,
            LibraryRandom.RandInt(10));

        // [WHEN] Update Sustainability Account No.,Emission CO2,Emission CH4,Emission N2O in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [THEN] Verify that the "Emission Cost Per Unit", "Total Emission Cost" must be updated from Carbon Pricing in Purchase Line.
        Assert.AreEqual(
            (CarbonPricing."Carbon Price" * ExpectedCO2eEmission) / (PurchaseLine."Qty. per Unit of Measure" * PurchaseLine.Quantity),
            PurchaseLine."Emission Cost Per Unit",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission Cost Per Unit"), CarbonPricing."Carbon Price", PurchaseLine.TableCaption()));
        Assert.AreEqual(
            CarbonPricing."Carbon Price" * ExpectedCO2eEmission,
            PurchaseLine."Total Emission Cost",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Total Emission Cost"), CarbonPricing."Carbon Price" * ExpectedCO2eEmission, PurchaseLine.TableCaption()));

        // [WHEN] Post a Purchase Document.
        PurchaseInvHeader.Get(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));

        // [THEN] Verify that the "Emission Cost Per Unit", "Total Emission Cost" must be updated from Carbon Pricing in Purchase Invoice Line.
        FindPurchaseInvoiceLine(PurchaseInvHeader, PurchaseInvLine);
        Assert.AreEqual(
            PurchaseLine."Emission Cost Per Unit",
            PurchaseInvLine."Emission Cost per Unit",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("Emission Cost per Unit"), PurchaseLine."Emission Cost Per Unit", PurchaseInvLine.TableCaption()));
        Assert.AreEqual(
            CarbonPricing."Carbon Price" * ExpectedCO2eEmission,
            PurchaseInvLine."Total Emission Cost",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("Total Emission Cost"), CarbonPricing."Carbon Price" * ExpectedCO2eEmission, PurchaseInvLine.TableCaption()));
    end;

    [Test]
    procedure VerifyTotalEmissionCostMustNotBeUpdatedFromCarbonPriceInPurchaseLineWhenThresholdQuantityIsEqualToCO2eEmission()
    var
        SustainabilityAccount: Record "Sustainability Account";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseHeader: Record "Purchase Header";
        CountryRegion: Record "Country/Region";
        PurchaseLine: Record "Purchase Line";
        CarbonPricing: Record "Sustainability Carbon Pricing";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537459] Verify that the "Total Emission Cost" must not be updated from the "Carbon Pricing" in the Purchase Line When "Threshold Quantity" is equal To "CO2e Emission".
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.Validate("Order Date", WorkDate());
        PurchaseHeader."Buy-from Country/Region Code" := CountryRegion.Code;
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Create Carbon Pricing.
        LibrarySustainability.CreateCarbonPricing(
            CarbonPricing,
            CountryRegion.Code,
            CalcDate('<-CY>', WorkDate()),
            CalcDate('<CY>', WorkDate()),
            PurchaseLine."Unit of Measure Code",
            ExpectedCO2eEmission,
            LibraryRandom.RandInt(10));

        // [WHEN] Update Sustainability Account No.,Emission CO2,Emission CH4,Emission N2O in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [THEN] Verify that the "Emission Cost Per Unit", "Total Emission Cost" must not be updated from Carbon Pricing in Purchase Line.
        Assert.AreEqual(
            0,
            PurchaseLine."Emission Cost Per Unit",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission Cost Per Unit"), 0, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            0,
            PurchaseLine."Total Emission Cost",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Total Emission Cost"), 0, PurchaseLine.TableCaption()));
    end;

    [Test]
    procedure VerifyTotalEmissionCostMustNotBeUpdatedFromCarbonPriceInPurchaseLineWhenOrderDateIsNotInRange()
    var
        SustainabilityAccount: Record "Sustainability Account";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseHeader: Record "Purchase Header";
        CountryRegion: Record "Country/Region";
        PurchaseLine: Record "Purchase Line";
        CarbonPricing: Record "Sustainability Carbon Pricing";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537459] Verify that the "Total Emission Cost" must not be updated from the "Carbon Pricing" in the Purchase Line 
        // When Order Date is not in range of Starting and Ending Date.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.Validate("Order Date", CalcDate('<CY+1D>', WorkDate()));
        PurchaseHeader."Buy-from Country/Region Code" := CountryRegion.Code;
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Create Carbon Pricing.
        LibrarySustainability.CreateCarbonPricing(
            CarbonPricing,
            CountryRegion.Code,
            CalcDate('<-CY>', WorkDate()),
            CalcDate('<CY>', WorkDate()),
            PurchaseLine."Unit of Measure Code",
            ExpectedCO2eEmission - 1,
            LibraryRandom.RandInt(10));

        // [WHEN] Update Sustainability Account No.,Emission CO2,Emission CH4,Emission N2O in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [THEN] Verify that the "Emission Cost Per Unit", "Total Emission Cost" must not be updated from Carbon Pricing in Purchase Line.
        Assert.AreEqual(
            0,
            PurchaseLine."Emission Cost Per Unit",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission Cost Per Unit"), 0, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            0,
            PurchaseLine."Total Emission Cost",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Total Emission Cost"), 0, PurchaseLine.TableCaption()));
    end;

    [Test]
    procedure TestSystemShouldThrowErrorWhenSalesDocumentIsPostedWithTotalEPRFeeNonZeroAndTotalCO2eIsZero()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SustainabilityAccount: Record "Sustainability Account";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalEPRFee: Decimal;
    begin
        // [SCENARIO 537459] Verify that the system should throw an error When Sales Document is posted with Zero "Total CO2e" and "Total EPR Fee" is non-zero.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total EPR Fee".
        TotalEPRFee := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price","Sustainability Account No.", "Total EPR Fee" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", 0);
        SalesLine.Validate("Total EPR Fee", TotalEPRFee);
        SalesLine.Modify();

        // [WHEN] Post a Sales Document.
        asserterror SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        // [THEN] Verify that the system should throw an error When Sales Document is posted with Zero "Total CO2e" and "Total EPR Fee" is non-zero.
        Assert.ExpectedError(CO2eMustNotBeZeroErr);
    end;

    [Test]
    procedure TestSystemShouldThrowErrorWhenPurchaseDocumentIsPostedWithTotalEmissionCostNonZeroAndEmissionsIsZero()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        SustainabilityAccount: Record "Sustainability Account";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalEmissionCost: Decimal;
    begin
        // [SCENARIO 537459] Verify that the system should throw an error When Purchase Document is posted with Zero Emissions and "Total Emission Cost" is non-zero.
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        TotalEmissionCost := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No. and "Total Emission Cost" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Total Emission Cost", TotalEmissionCost);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        asserterror PurchaseInvHeader.Get(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));

        // [THEN] Verify that the system should throw an error When Purchase Document is posted with Zero Emissions and "Total Emission Cost" is non-zero.
        Assert.ExpectedError(EmissionMustNotBeZeroErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestPostedPurchaseDocumentIsInsertedInSustainabilityExciseJournalWhenCalculateActionIsInvoked()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        PurchaseInvLine: Record "Purch. Inv. Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustExciseJournalLine: Record "Sust. Excise Jnl. Line";
        SustExciseTransLog: Record "Sust. Excise Taxes Trans. Log";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        SustainabilityExciseJournal: TestPage "Sustainability Excise Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        TotalEmissionCost: Decimal;
    begin
        // [SCENARIO 537459] Verify that the posted purchase document is inserted When Calculate action is invoked in "Sustainability Excise Journal".
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get a Sustainability Excise Journal Batch.
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);
        TotalEmissionCost := LibraryRandom.RandInt(10);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No. and "Total Emission Cost" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Validate("Total Emission Cost", TotalEmissionCost);
        PurchaseLine.Validate("CBAM Compliance", true);
        PurchaseLine.Validate("Source of Emission Data", PurchaseLine."Source of Emission Data"::Other);
        PurchaseLine.Validate("Emission Verified", true);
        PurchaseLine.Modify();

        // [GIVEN] Post a Purchase Document.
        PurchaseInvHeader.Get(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));

        // [WHEN] Invoke "Calculate" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.OpenEdit();
        SustainabilityExciseJournal.Calculate.Invoke();

        // [THEN] Verify "Sust. Excise Jnl. Line" should be created.
        FindPurchaseInvoiceLine(PurchaseInvHeader, PurchaseInvLine);
        SustExciseJournalLine.SetRange("Journal Template Name", SustExciseJournalBatch."Journal Template Name");
        SustExciseJournalLine.SetRange("Journal Batch Name", SustExciseJournalBatch.Name);
        Assert.RecordCount(SustExciseJournalLine, 1);
        VerifyExciseJournalLineFromPurchInvoiceLine(SustExciseJournalLine, PurchaseInvLine, ExpectedCO2eEmission);

        // [GIVEN] Update Description in Excise Journal Line.
        SustExciseJournalLine.Validate(Description, SustExciseJournalLine."Source No.");
        SustExciseJournalLine.Modify();

        // [WHEN] Invoke "Register" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.Register.Invoke();

        // [THEN] Verify "Sust. Excise Taxes Trans. Log" should be created.
        FindPurchaseInvoiceLine(PurchaseInvHeader, PurchaseInvLine);
        Assert.RecordCount(SustExciseTransLog, 1);
        Assert.AreEqual(
            true,
            PurchaseInvLine."CBAM Reported",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("CBAM Reported"), true, PurchaseInvLine.TableCaption()));
        VerifyExciseTransactionLogFromExciseJournalLine(SustExciseTransLog, SustExciseJournalLine, 1);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestExciseTaxesTransactionLogIsCreatedWithDocumentTypeCreditMemo()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        PurchaseInvLine: Record "Purch. Inv. Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustExciseJournalLine: Record "Sust. Excise Jnl. Line";
        SustExciseTransLog: Record "Sust. Excise Taxes Trans. Log";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        SustainabilityExciseJournal: TestPage "Sustainability Excise Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        TotalEmissionCost: Decimal;
    begin
        // [SCENARIO 537459] Verify that the "Excise Taxes Transaction Log" is created with "Document Type" Credit Memo.
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get a Sustainability Excise Journal Batch.
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);
        TotalEmissionCost := LibraryRandom.RandInt(10);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No. and "Total Emission Cost" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Validate("Total Emission Cost", TotalEmissionCost);
        PurchaseLine.Validate("CBAM Compliance", true);
        PurchaseLine.Validate("Source of Emission Data", PurchaseLine."Source of Emission Data"::Other);
        PurchaseLine.Validate("Emission Verified", true);
        PurchaseLine.Modify();

        // [GIVEN] Post a Purchase Document.
        PurchaseInvHeader.Get(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));

        // [WHEN] Invoke "Calculate" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.OpenEdit();
        SustainabilityExciseJournal.Calculate.Invoke();

        // [THEN] Verify "Sust. Excise Jnl. Line" should be created.
        FindPurchaseInvoiceLine(PurchaseInvHeader, PurchaseInvLine);
        SustExciseJournalLine.SetRange("Journal Template Name", SustExciseJournalBatch."Journal Template Name");
        SustExciseJournalLine.SetRange("Journal Batch Name", SustExciseJournalBatch.Name);
        Assert.RecordCount(SustExciseJournalLine, 1);
        VerifyExciseJournalLineFromPurchInvoiceLine(SustExciseJournalLine, PurchaseInvLine, ExpectedCO2eEmission);

        // [GIVEN] Update "Document Type", Description in Excise Journal Line.
        SustExciseJournalLine."Document Type" := SustExciseJournalLine."Document Type"::"Credit Memo";
        SustExciseJournalLine.Validate(Description, SustExciseJournalLine."Source No.");
        SustExciseJournalLine.Modify();

        // [WHEN] Invoke "Register" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.Register.Invoke();

        // [THEN] Verify "Sust. Excise Taxes Trans. Log" should be created.
        FindPurchaseInvoiceLine(PurchaseInvHeader, PurchaseInvLine);
        Assert.RecordCount(SustExciseTransLog, 1);
        Assert.AreEqual(
            true,
            PurchaseInvLine."CBAM Reported",
            StrSubstNo(ValueMustBeEqualErr, PurchaseInvLine.FieldCaption("CBAM Reported"), true, PurchaseInvLine.TableCaption()));
        VerifyExciseTransactionLogFromExciseJournalLine(SustExciseTransLog, SustExciseJournalLine, -1);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestExciseTaxesTransactionLogMustNotBeCreatedWithDocumentTypeJournal()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        PurchaseInvLine: Record "Purch. Inv. Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustExciseJournalLine: Record "Sust. Excise Jnl. Line";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        SustainabilityExciseJournal: TestPage "Sustainability Excise Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        TotalEmissionCost: Decimal;
    begin
        // [SCENARIO 537459] Verify that the "Excise Taxes Transaction Log" must not be created with "Document Type" Journal.
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get a Sustainability Excise Journal Batch.
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);
        TotalEmissionCost := LibraryRandom.RandInt(10);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No. and "Total Emission Cost" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Validate("Total Emission Cost", TotalEmissionCost);
        PurchaseLine.Validate("CBAM Compliance", true);
        PurchaseLine.Validate("Source of Emission Data", PurchaseLine."Source of Emission Data"::Other);
        PurchaseLine.Validate("Emission Verified", true);
        PurchaseLine.Modify();

        // [GIVEN] Post a Purchase Document.
        PurchaseInvHeader.Get(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));

        // [WHEN] Invoke "Calculate" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.OpenEdit();
        SustainabilityExciseJournal.Calculate.Invoke();

        // [THEN] Verify "Sust. Excise Jnl. Line" should be created.
        FindPurchaseInvoiceLine(PurchaseInvHeader, PurchaseInvLine);
        SustExciseJournalLine.SetRange("Journal Template Name", SustExciseJournalBatch."Journal Template Name");
        SustExciseJournalLine.SetRange("Journal Batch Name", SustExciseJournalBatch.Name);
        Assert.RecordCount(SustExciseJournalLine, 1);
        VerifyExciseJournalLineFromPurchInvoiceLine(SustExciseJournalLine, PurchaseInvLine, ExpectedCO2eEmission);

        // [GIVEN] Update "Document Type", Description in Excise Journal Line.
        SustExciseJournalLine."Document Type" := SustExciseJournalLine."Document Type"::Journal;
        SustExciseJournalLine.Validate(Description, SustExciseJournalLine."Source No.");
        SustExciseJournalLine."Total Embedded CO2e Emission" := -SustExciseJournalLine."Total Embedded CO2e Emission";
        SustExciseJournalLine.Modify();

        // [WHEN] Invoke "Register" action in "Sustainability Excise Journal".
        asserterror SustainabilityExciseJournal.Register.Invoke();

        // [THEN] Verify "Sust. Excise Taxes Trans. Log" must not be created.
        Assert.ExpectedError(
            StrSubstNo(UnsupportedEntryErr,
                SustExciseJournalLine.FieldCaption("Entry Type"),
                SustExciseJournalLine."Entry Type"::" ",
                SustExciseJournalLine.FieldCaption("Document Type"),
                SustExciseJournalLine."Document Type"::Journal));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestCBAMFieldsMustBeVisibleForTypeCBAMInExciseJournal()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        SustainabilityExciseJournal: TestPage "Sustainability Excise Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537459] Verify that the CBAM fields are visible in the "Sustainability Excise Journal" for the type "CBAM".
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get a Sustainability Excise Journal Batch.
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();

        // [WHEN] Invoke "Calculate" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.OpenEdit();
        SustainabilityExciseJournal.Calculate.Invoke();

        // [VERIFY] Verify that the CBAM fields are visible in the "Sustainability Excise Journal" for the type "CBAM".
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."Emission Verified".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."Emission Verified".Caption(), SustainabilityExciseJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."CBAM Compliance".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."CBAM Compliance".Caption(), SustainabilityExciseJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."CO2e Unit of Measure".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."CO2e Unit of Measure".Caption(), SustainabilityExciseJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."Total Embedded CO2e Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."Total Embedded CO2e Emission".Caption(), SustainabilityExciseJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."CBAM Certificates Required".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."CBAM Certificates Required".Caption(), SustainabilityExciseJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."Carbon Pricing Paid".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."Carbon Pricing Paid".Caption(), SustainabilityExciseJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."Already Paid Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."Already Paid Emission".Caption(), SustainabilityExciseJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."Adjusted CBAM Cost".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."Adjusted CBAM Cost".Caption(), SustainabilityExciseJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."Certificate Amount".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."Certificate Amount".Caption(), SustainabilityExciseJournal.Caption()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestEPRFieldsMustBeVisibleForTypeEPRInExciseJournal()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        SustainabilityExciseJournal: TestPage "Sustainability Excise Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537459] Verify that the EPR fields are visible in the "Sustainability Excise Journal" for the type "EPR".
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get a Sustainability Excise Journal Batch.
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();

        // [GIVEN] Update Type in Sustainability Excise Journal Batch.
        SustExciseJournalBatch.Type := SustExciseJournalBatch.Type::EPR;
        SustExciseJournalBatch.Modify();

        // [WHEN] Invoke "Calculate" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.OpenEdit();
        SustainabilityExciseJournal.Calculate.Invoke();

        // [VERIFY] Verify that the EPR fields are visible in the "Sustainability Excise Journal" for the type "EPR".
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."Material Breakdown No.".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."Material Breakdown No.".Caption(), SustainabilityExciseJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."Material Breakdown Description".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."Material Breakdown Description".Caption(), SustainabilityExciseJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."Material Breakdown UOM".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."Material Breakdown UOM".Caption(), SustainabilityExciseJournal.Caption()));
        Assert.AreEqual(
            true,
            SustainabilityExciseJournal."Material Breakdown Weight".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, SustainabilityExciseJournal."Material Breakdown Weight".Caption(), SustainabilityExciseJournal.Caption()));
    end;


    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestPostedSalesDocumentIsInsertedInSustainabilityExciseJournalWhenCalculateActionIsInvoked()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustExciseJournalLine: Record "Sust. Excise Jnl. Line";
        SustExciseTransLog: Record "Sust. Excise Taxes Trans. Log";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        SustainabilityExciseJournal: TestPage "Sustainability Excise Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalEPRFee: Decimal;
    begin
        // [SCENARIO 537459] Verify that the posted sales document is inserted When Calculate action is invoked in "Sustainability Excise Journal".
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get a Sustainability Excise Journal Batch.
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();

        // [GIVEN] Update Type in Sustainability Excise Journal Batch.
        SustExciseJournalBatch.Type := SustExciseJournalBatch.Type::EPR;
        SustExciseJournalBatch.Modify();

        // [GIVEN] Generate "Total EPR Fee".
        TotalEPRFee := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e", "Total EPR Fee" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", LibraryRandom.RandInt(20));
        SalesLine.Validate("Total EPR Fee", TotalEPRFee);
        SalesLine.Modify();

        // [WHEN] Post a Sales Document.
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        // [WHEN] Invoke "Calculate" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.OpenEdit();
        SustainabilityExciseJournal.Calculate.Invoke();

        // [THEN] Verify "Sust. Excise Jnl. Line" should be created.
        FindSalesInvoiceLine(SalesInvoiceHeader, SalesInvoiceLine);
        SustExciseJournalLine.SetRange("Journal Template Name", SustExciseJournalBatch."Journal Template Name");
        SustExciseJournalLine.SetRange("Journal Batch Name", SustExciseJournalBatch.Name);
        Assert.RecordCount(SustExciseJournalLine, 1);
        VerifyExciseJournalLineFromSalesInvoiceLine(SustExciseJournalLine, SalesInvoiceLine);

        // [GIVEN] Update Description in Excise Journal Line.
        SustExciseJournalLine.Validate(Description, SustExciseJournalLine."Source No.");
        SustExciseJournalLine.Modify();

        // [WHEN] Invoke "Register" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.Register.Invoke();

        // [THEN] Verify "Sust. Excise Taxes Trans. Log" should be created.
        FindSalesInvoiceLine(SalesInvoiceHeader, SalesInvoiceLine);
        Assert.RecordCount(SustExciseTransLog, 1);
        Assert.AreEqual(
            true,
            SalesInvoiceLine."EPR Reported",
            StrSubstNo(ValueMustBeEqualErr, SalesInvoiceLine.FieldCaption("EPR Reported"), true, SalesInvoiceLine.TableCaption()));
        VerifyExciseTransactionLogFromExciseJournalLine(SustExciseTransLog, SustExciseJournalLine, -1);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestExciseTaxesTransactionLogIsCreatedWithDocumentTypeCreditMemoForEntryTypeSales()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustExciseJournalLine: Record "Sust. Excise Jnl. Line";
        SustExciseTransLog: Record "Sust. Excise Taxes Trans. Log";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        SustainabilityExciseJournal: TestPage "Sustainability Excise Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalEPRFee: Decimal;
    begin
        // [SCENARIO 537459] Verify that the "Excise Taxes Transaction Log" is created with "Document Type" Credit Memo.
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get a Sustainability Excise Journal Batch.
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();

        // [GIVEN] Update Type in Sustainability Excise Journal Batch.
        SustExciseJournalBatch.Type := SustExciseJournalBatch.Type::EPR;
        SustExciseJournalBatch.Modify();

        // [GIVEN] Generate "Total EPR Fee".
        TotalEPRFee := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e", "Total EPR Fee" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", LibraryRandom.RandInt(20));
        SalesLine.Validate("Total EPR Fee", TotalEPRFee);
        SalesLine.Modify();

        // [WHEN] Post a Sales Document.
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        // [WHEN] Invoke "Calculate" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.OpenEdit();
        SustainabilityExciseJournal.Calculate.Invoke();

        // [THEN] Verify "Sust. Excise Jnl. Line" should be created.
        FindSalesInvoiceLine(SalesInvoiceHeader, SalesInvoiceLine);
        SustExciseJournalLine.SetRange("Journal Template Name", SustExciseJournalBatch."Journal Template Name");
        SustExciseJournalLine.SetRange("Journal Batch Name", SustExciseJournalBatch.Name);
        Assert.RecordCount(SustExciseJournalLine, 1);
        VerifyExciseJournalLineFromSalesInvoiceLine(SustExciseJournalLine, SalesInvoiceLine);

        // [GIVEN] Update "Document Type", Description in Excise Journal Line.
        SustExciseJournalLine."Document Type" := SustExciseJournalLine."Document Type"::"Credit Memo";
        SustExciseJournalLine.Validate(Description, SustExciseJournalLine."Source No.");
        SustExciseJournalLine.Modify();

        // [WHEN] Invoke "Register" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.Register.Invoke();

        // [THEN] Verify "Sust. Excise Taxes Trans. Log" should be created.
        FindSalesInvoiceLine(SalesInvoiceHeader, SalesInvoiceLine);
        Assert.RecordCount(SustExciseTransLog, 1);
        Assert.AreEqual(
            true,
            SalesInvoiceLine."EPR Reported",
            StrSubstNo(ValueMustBeEqualErr, SalesInvoiceLine.FieldCaption("EPR Reported"), true, SalesInvoiceLine.TableCaption()));
        VerifyExciseTransactionLogFromExciseJournalLine(SustExciseTransLog, SustExciseJournalLine, 1);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestExciseTaxesTransactionLogMustNotBeCreatedWithDocumentTypeJournalForEntryTypeSales()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
        SustExciseJournalLine: Record "Sust. Excise Jnl. Line";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        SustainabilityExciseJournal: TestPage "Sustainability Excise Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalEPRFee: Decimal;
    begin
        // [SCENARIO 537459] Verify that the "Excise Taxes Transaction Log" must not be created with "Document Type" Journal.
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get a Sustainability Excise Journal Batch.
        SustExciseJournalBatch := SustainabilityExciseJournalMgt.GetASustainabilityJournalBatch();

        // [GIVEN] Update Type in Sustainability Excise Journal Batch.
        SustExciseJournalBatch.Type := SustExciseJournalBatch.Type::EPR;
        SustExciseJournalBatch.Modify();

        // [GIVEN] Generate "Total EPR Fee".
        TotalEPRFee := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e", "Total EPR Fee" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", LibraryRandom.RandInt(20));
        SalesLine.Validate("Total EPR Fee", TotalEPRFee);
        SalesLine.Modify();

        // [WHEN] Post a Sales Document.
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        // [WHEN] Invoke "Calculate" action in "Sustainability Excise Journal".
        SustainabilityExciseJournal.OpenEdit();
        SustainabilityExciseJournal.Calculate.Invoke();

        // [THEN] Verify "Sust. Excise Jnl. Line" should be created.
        FindSalesInvoiceLine(SalesInvoiceHeader, SalesInvoiceLine);
        SustExciseJournalLine.SetRange("Journal Template Name", SustExciseJournalBatch."Journal Template Name");
        SustExciseJournalLine.SetRange("Journal Batch Name", SustExciseJournalBatch.Name);
        Assert.RecordCount(SustExciseJournalLine, 1);
        VerifyExciseJournalLineFromSalesInvoiceLine(SustExciseJournalLine, SalesInvoiceLine);

        // [GIVEN] Update "Document Type", Description in Excise Journal Line.
        SustExciseJournalLine."Document Type" := SustExciseJournalLine."Document Type"::Journal;
        SustExciseJournalLine.Validate(Description, SustExciseJournalLine."Source No.");
        SustExciseJournalLine.Modify();

        // [WHEN] Invoke "Register" action in "Sustainability Excise Journal".
        asserterror SustainabilityExciseJournal.Register.Invoke();

        // [THEN] Verify "Sust. Excise Taxes Trans. Log" must not be created.
        Assert.ExpectedError(
            StrSubstNo(UnsupportedEntryErr,
                SustExciseJournalLine.FieldCaption("Entry Type"),
                SustExciseJournalLine."Entry Type"::" ",
                SustExciseJournalLine.FieldCaption("Document Type"),
                SustExciseJournalLine."Document Type"::Journal));
    end;

    [Test]
    procedure TestEPRRelatedFieldsShouldFlowInSalesInvoiceLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SustainabilityAccount: Record "Sustainability Account";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalEPRFee: Decimal;
    begin
        // [SCENARIO 537459] Verify that the EPR-related fields flow to the "Sales Invoice Line".
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total EPR Fee".
        TotalEPRFee := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e", "Total EPR Fee" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", LibraryRandom.RandInt(20));
        SalesLine.Validate("Total EPR Fee", TotalEPRFee);
        SalesLine.Modify();

        // [WHEN] Post a Sales Document.
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        // [THEN] Verify that the EPR-related fields flow to the "Sales Invoice Line".
        FindSalesInvoiceLine(SalesInvoiceHeader, SalesInvoiceLine);
        Assert.AreEqual(
            TotalEPRFee,
            SalesInvoiceLine."Total EPR Fee",
            StrSubstNo(ValueMustBeEqualErr, SalesInvoiceLine.FieldCaption("Total EPR Fee"), TotalEPRFee, SalesInvoiceLine.TableCaption()));
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sustainability Excise Test");
        LibrarySustainability.CleanUpBeforeTesting();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sustainability Excise Test");

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

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sustainability Excise Test");
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

    local procedure FindPurchaseInvoiceLine(PurchaseInvHeader: Record "Purch. Inv. Header"; var PurchaseInvLine: Record "Purch. Inv. Line")
    begin
        PurchaseInvLine.SetRange("Document No.", PurchaseInvHeader."No.");
        PurchaseInvLine.FindSet();
    end;

    local procedure FindSalesInvoiceLine(SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindSet();
    end;

    local procedure VerifyExciseTransactionLogFromExciseJournalLine(var SustExciseTransLog: Record "Sust. Excise Taxes Trans. Log"; SustExciseJournalLine: Record "Sust. Excise Jnl. Line"; SignFactor: Integer)
    begin
        SustExciseTransLog.FindFirst();
        Assert.AreEqual(
            SustExciseJournalLine."Document Type",
            SustExciseTransLog."Document Type",
            StrSubstNo(ValueMustBeEqualErr, SustExciseTransLog.FieldCaption("Document Type"), SustExciseJournalLine."Document Type", SustExciseTransLog.TableCaption()));
        Assert.AreEqual(
            SustExciseJournalLine."Entry Type",
            SustExciseTransLog."Entry Type",
            StrSubstNo(ValueMustBeEqualErr, SustExciseTransLog.FieldCaption("Entry Type"), SustExciseJournalLine."Entry Type", SustExciseTransLog.TableCaption()));
        Assert.AreEqual(
            SustExciseJournalLine."Partner Type",
            SustExciseTransLog."Partner Type",
            StrSubstNo(ValueMustBeEqualErr, SustExciseTransLog.FieldCaption("Partner Type"), SustExciseJournalLine."Partner Type", SustExciseTransLog.TableCaption()));
        Assert.AreEqual(
            SustExciseJournalLine."Partner No.",
            SustExciseTransLog."Partner No.",
            StrSubstNo(ValueMustBeEqualErr, SustExciseTransLog.FieldCaption("Partner No."), SustExciseJournalLine."Partner No.", SustExciseTransLog.TableCaption()));
        Assert.AreEqual(
            SustExciseJournalLine."Source No.",
            SustExciseTransLog."Source No.",
            StrSubstNo(ValueMustBeEqualErr, SustExciseTransLog.FieldCaption("Source No."), SustExciseJournalLine."Source No.", SustExciseTransLog.TableCaption()));
        Assert.AreEqual(
            SignFactor * SustExciseJournalLine."Total Embedded CO2e Emission",
            SustExciseTransLog."Total Embedded CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustExciseTransLog.FieldCaption("Total Embedded CO2e Emission"), SignFactor * SustExciseJournalLine."Total Embedded CO2e Emission", SustExciseTransLog.TableCaption()));
        Assert.AreEqual(
            SignFactor * SustExciseJournalLine."Total Emission Cost",
            SustExciseTransLog."Total Emission Cost",
            StrSubstNo(ValueMustBeEqualErr, SustExciseTransLog.FieldCaption("Total Emission Cost"), SignFactor * SustExciseJournalLine."Total Emission Cost", SustExciseTransLog.TableCaption()));
        Assert.AreEqual(
            SustExciseJournalLine."Source Document No.",
            SustExciseTransLog."Source Document No.",
            StrSubstNo(ValueMustBeEqualErr, SustExciseTransLog.FieldCaption("Source Document No."), SustExciseJournalLine."Source Document No.", SustExciseTransLog.TableCaption()));
        Assert.AreEqual(
            SustExciseJournalLine."Source Document Line No.",
            SustExciseTransLog."Source Document Line No.",
            StrSubstNo(ValueMustBeEqualErr, SustExciseTransLog.FieldCaption("Source Document Line No."), SustExciseJournalLine."Source Document Line No.", SustExciseTransLog.TableCaption()));
    end;

    local procedure VerifyExciseJournalLineFromPurchInvoiceLine(var SustExciseJournalLine: Record "Sust. Excise Jnl. Line"; PurchaseInvLine: Record "Purch. Inv. Line"; ExpectedCO2eEmission: Decimal)
    begin
        SustExciseJournalLine.FindFirst();
        Assert.AreEqual(
              SustExciseJournalLine."Entry Type"::Purchase,
              SustExciseJournalLine."Entry Type",
              StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Entry Type"), SustExciseJournalLine."Entry Type"::Purchase, SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            SustExciseJournalLine."Partner Type"::Vendor,
            SustExciseJournalLine."Partner Type",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Partner Type"), SustExciseJournalLine."Partner Type"::Vendor, SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            PurchaseInvLine."Buy-from Vendor No.",
            SustExciseJournalLine."Partner No.",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Partner No."), PurchaseInvLine."Buy-from Vendor No.", SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            PurchaseInvLine."Source of Emission Data",
            SustExciseJournalLine."Source of Emission Data",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Source of Emission Data"), PurchaseInvLine."Source of Emission Data", SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            PurchaseInvLine."Emission Verified",
            SustExciseJournalLine."Emission Verified",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Emission Verified"), PurchaseInvLine."Emission Verified", SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            PurchaseInvLine."CBAM Compliance",
            SustExciseJournalLine."CBAM Compliance",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("CBAM Compliance"), PurchaseInvLine."CBAM Compliance", SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            PurchaseInvLine."No.",
            SustExciseJournalLine."Source No.",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Source No."), PurchaseInvLine."No.", SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SustExciseJournalLine."Total Embedded CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Total Embedded CO2e Emission"), ExpectedCO2eEmission, SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            PurchaseInvLine."Total Emission Cost",
            SustExciseJournalLine."Total Emission Cost",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Total Emission Cost"), PurchaseInvLine."Total Emission Cost", SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            PurchaseInvLine."Document No.",
            SustExciseJournalLine."Source Document No.",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Source Document No."), PurchaseInvLine."Document No.", SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            PurchaseInvLine."Line No.",
            SustExciseJournalLine."Source Document Line No.",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Source Document Line No."), PurchaseInvLine."Line No.", SustExciseJournalLine.TableCaption()));
    end;

    local procedure VerifyExciseJournalLineFromSalesInvoiceLine(var SustExciseJournalLine: Record "Sust. Excise Jnl. Line"; SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        SustExciseJournalLine.FindFirst();
        Assert.AreEqual(
              SustExciseJournalLine."Entry Type"::Sales,
              SustExciseJournalLine."Entry Type",
              StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Entry Type"), SustExciseJournalLine."Entry Type"::Sales, SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            SustExciseJournalLine."Partner Type"::Customer,
            SustExciseJournalLine."Partner Type",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Partner Type"), SustExciseJournalLine."Partner Type"::Customer, SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            SalesInvoiceLine."Sell-to Customer No.",
            SustExciseJournalLine."Partner No.",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Partner No."), SalesInvoiceLine."Sell-to Customer No.", SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            SalesInvoiceLine."No.",
            SustExciseJournalLine."Source No.",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Source No."), SalesInvoiceLine."No.", SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            0,
            SustExciseJournalLine."Total Embedded CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Total Embedded CO2e Emission"), 0, SustExciseJournalLine.TableCaption()));
        Assert.AreEqual(
            SalesInvoiceLine."Total EPR Fee",
            SustExciseJournalLine."Total Emission Cost",
            StrSubstNo(ValueMustBeEqualErr, SustExciseJournalLine.FieldCaption("Total Emission Cost"), SalesInvoiceLine."Total EPR Fee", SustExciseJournalLine.TableCaption()));
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