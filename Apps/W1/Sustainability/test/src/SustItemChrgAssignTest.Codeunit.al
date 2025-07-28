namespace Microsoft.Test.Sustainability;

using Microsoft.Purchases.Document;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Emission;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Setup;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.History;
using Microsoft.Sales.History;
using Microsoft.Sustainability.Ledger;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item;

codeunit 148210 "Sust. Item Chrg Assign. Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';

    [Test]
    procedure ChargeAssignmentUsingPurchaseInvoice()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 543884] Verify Item Charge Assignment(Purch.) using Sales Order and Purchase Invoice.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        ChargeAssignmentUsingPurchaseDocument(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::Invoice, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e to Assign" must be updated in "Item Charge Assignment (Purch)".
        Assert.AreEqual(
            Round(ExpectedCO2eEmission / Quantity),
            Round(ItemChargeAssignmentPurch."CO2e per Unit"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e per Unit"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Assign"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Assign"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Handle"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Handle"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
    end;

    [Test]
    procedure ChargeAssignmentUsingPurchaseCreditMemo()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 543884] Verify Item Charge Assignment(Purch.) using Sales Order and Purchase Credit Memo.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        ChargeAssignmentUsingPurchaseDocument(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Credit Memo", Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e to Assign" must be updated in "Item Charge Assignment (Purch)".
        Assert.AreEqual(
            Round(ExpectedCO2eEmission / Quantity),
            Round(ItemChargeAssignmentPurch."CO2e per Unit"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e per Unit"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Assign"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Assign"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Handle"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Handle"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
    end;

    [Test]
    procedure ChargeAssignmentUsingPurchaseOrder()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 543884] Verify Item Charge Assignment(Purch.) using Sales Order and Purchase Order.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        ChargeAssignmentUsingPurchaseDocument(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::Order, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e to Assign" must be updated in "Item Charge Assignment (Purch)".
        Assert.AreEqual(
            Round(ExpectedCO2eEmission / Quantity),
            Round(ItemChargeAssignmentPurch."CO2e per Unit"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e per Unit"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Assign"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Assign"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Handle"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Handle"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
    end;

    [Test]
    procedure ChargeAssignmentUsingPurchaseReturnOrder()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 543884] Verify Item Charge Assignment(Purch.) using Sales Order and Purchase Return Order.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        ChargeAssignmentUsingPurchaseDocument(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Return Order", Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e to Assign" must be updated in "Item Charge Assignment (Purch)".
        Assert.AreEqual(
            Round(ExpectedCO2eEmission / Quantity),
            Round(ItemChargeAssignmentPurch."CO2e per Unit"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e per Unit"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Assign"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Assign"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Handle"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Handle"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
    end;

    [Test]
    procedure ChargeAssignmentUsingSalesReturnOrderAndPurchaseOrder()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 543884] Verify Item Charge Assignment(Purch.) using Sales Return Order and Purchase Order.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        ChargeAssignmentUsingSalesRetOrder(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order", Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e to Assign" must be updated in "Item Charge Assignment (Purch)".
        Assert.AreEqual(
            Round(ExpectedCO2eEmission / Quantity),
            Round(ItemChargeAssignmentPurch."CO2e per Unit"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e per Unit"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Assign"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Assign"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Handle"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Handle"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
    end;

    [Test]
    procedure ChargeAssignmentUsingSalesReturnOrderAndPurchaseInvoice()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 543884] Verify Item Charge Assignment(Purch.) using Sales Return Order and Purchase Invoice.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        ChargeAssignmentUsingSalesRetOrder(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Return Order", Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e to Assign" must be updated in "Item Charge Assignment (Purch)".
        Assert.AreEqual(
            Round(ExpectedCO2eEmission / Quantity),
            Round(ItemChargeAssignmentPurch."CO2e per Unit"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e per Unit"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Assign"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Assign"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Handle"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Handle"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
    end;

    [Test]
    procedure ChargeAssignmentUsingSalesReturnOrderAndPurchaseReturnOrder()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 543884] Verify Item Charge Assignment(Purch.) using Sales Return Order and Purchase Return Order.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        ChargeAssignmentUsingSalesRetOrder(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Return Order", Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e to Assign" must be updated in "Item Charge Assignment (Purch)".
        Assert.AreEqual(
            Round(ExpectedCO2eEmission / Quantity),
            Round(ItemChargeAssignmentPurch."CO2e per Unit"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e per Unit"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Assign"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Assign"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Handle"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Handle"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
    end;

    [Test]
    procedure ChargeAssignmentUsingSalesReturnOrderAndPurchaseCreditMemo()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 543884] Verify Item Charge Assignment(Purch.) using Sales Return Order and Purchase Credit Memo.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        ChargeAssignmentUsingSalesRetOrder(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order", Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e to Assign" must be updated in "Item Charge Assignment (Purch)".
        Assert.AreEqual(
            Round(ExpectedCO2eEmission / Quantity),
            Round(ItemChargeAssignmentPurch."CO2e per Unit"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e per Unit"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Assign"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Assign"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(ItemChargeAssignmentPurch."CO2e to Handle"),
            StrSubstNo(ValueMustBeEqualErr, ItemChargeAssignmentPurch.FieldCaption("CO2e to Handle"), Round(ExpectedCO2eEmission), ItemChargeAssignmentPurch.TableCaption()));
    end;

    [Test]
    procedure PurchOrderOrInvoiceWithPositiveChgAssigntToNegativePurchRcpt()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        DocumentNo: Code[20];
    begin
        // [SCENARIO 543884] When Positive Item Charge is assigned in Purchase Order to Purchase Receipt with negative Qty then Sustainability Value Entry has positive "CO2e Amount (Actual)".
        Initialize();

        // [GIVEN] Update "Check Doc. Total Amounts" in "Purchases & Payables Setup".
        UpdateCheckDocTotalAmountsInPurchPayablesSetup(false);

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssigntToPurchRcpt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::Order, -1, 1, 1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, ExpectedCO2eEmission);

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssigntToPurchRcpt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::Invoice, -1, 1, 1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, ExpectedCO2eEmission);
    end;

    [Test]
    procedure PurchOrderOrInvoiceWithNegativeChgAssigntToNegativePurchRcpt()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        DocumentNo: Code[20];
    begin
        // [SCENARIO 543884] When Negative Item Charge is assigned in Purchase Order to Purchase Receipt with negative Qty then Sustainability Value Entry has negative "CO2e Amount (Actual)".
        Initialize();

        // [GIVEN] Update "Check Doc. Total Amounts" in "Purchases & Payables Setup".
        UpdateCheckDocTotalAmountsInPurchPayablesSetup(false);

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssigntToPurchRcpt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::Order, -1, -1, 1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, -1 * ExpectedCO2eEmission);

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssigntToPurchRcpt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::Invoice, -1, -1, 1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, -1 * ExpectedCO2eEmission);
    end;

    [Test]
    procedure PurchRetOrderOrCrMemoWithPositiveChgAssigntToNegativePurchRcpt()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        DocumentNo: Code[20];
    begin
        // [SCENARIO 543884] When Positive Item Charge is assigned in Purchase Return Order to Purchase Receipt with negative Qty then Sustainability Value Entry has negative "CO2e Amount (Actual)".
        Initialize();

        // [GIVEN] Update "Check Doc. Total Amounts" in "Purchases & Payables Setup".
        UpdateCheckDocTotalAmountsInPurchPayablesSetup(false);

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssigntToPurchRcpt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Return Order", -1, 1, 1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, -1 * ExpectedCO2eEmission);

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssigntToPurchRcpt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Credit Memo", -1, 1, 1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, -1 * ExpectedCO2eEmission);
    end;

    [Test]
    procedure PurchRetOrderOrCrMemoWithNegativeChgAssigntToNegativePurchRcpt()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        DocumentNo: Code[20];
    begin
        // [SCENARIO 543884] When Negative Item Charge is assigned in Purchase Return Order to Purchase Receipt with negative Qty then Sustainability Value Entry has positive "CO2e Amount (Actual)".
        Initialize();

        // [GIVEN] Update "Check Doc. Total Amounts" in "Purchases & Payables Setup".
        UpdateCheckDocTotalAmountsInPurchPayablesSetup(false);

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssigntToPurchRcpt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Return Order", -1, -1, 1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, 1 * ExpectedCO2eEmission);

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssigntToPurchRcpt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Credit Memo", -1, -1, 1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, 1 * ExpectedCO2eEmission);
    end;

    [Test]
    procedure PurchOrderWithChgAssigntToPurchRetShpt()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        DocumentNo: Code[20];
    begin
        // [SCENARIO 543884] Verify "CO2e Amount (Actual)" on Sustainability Value Entry for Posted Purchase Invoice after assigning Charge to Return Shipment.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssgntToPurchRetShipt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Order", 1, 1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, 1 * ExpectedCO2eEmission);
    end;

    [Test]
    procedure PurchOrderWithNegtiveCostChgAssigntToPurchRetShpt()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        DocumentNo: Code[20];
    begin
        // [SCENARIO 543884] Verify "CO2e Amount (Actual)" on Sustainability Value Entry for Posted Purchase Invoice after assigning Charge with negative Cost to Return Shipment.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssgntToPurchRetShipt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Order", 1, -1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, 1 * ExpectedCO2eEmission);
    end;

    [Test]
    procedure PurchRetOrderWithChgAssigntToPurchRetShpt()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        DocumentNo: Code[20];
    begin
        // [SCENARIO 543884] Verify "CO2e Amount (Actual)" on Sustainability Value Entry for Posted Purchase Return Memo after assigning Charge to Purchase Return Shipment.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssgntToPurchRetShipt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Return Order", 1, 1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, -1 * ExpectedCO2eEmission);
    end;

    [Test]
    procedure PurchCrMemoWithNegQtyAndCostChgAssgntToPurchRetShipt()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        DocumentNo: Code[20];
    begin
        // [SCENARIO 543884] Verify "CO2e Amount (Actual)" on Sustainability Value Entry for Posted Purchase Credit Memo after assigning negative Charge with negative Cost to Purchase Return Shipment.
        Initialize();

        // [GIVEN] Update "Check Doc. Total Amounts" in "Purchases & Payables Setup".
        UpdateCheckDocTotalAmountsInPurchPayablesSetup(false);

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Sub Category.
        SustAccountSubCategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Generate Quantity andEmission.
        Quantity := LibraryRandom.RandInt(100);
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";

        // [WHEN] Create Purchase Document and Assign Item Charge.
        DocumentNo := PurchDocWithChgAssgntToPurchRetShipt(ItemChargeAssignmentPurch, PurchaseHeader."Document Type"::"Credit Memo", -1, -1, Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e Amount (Actual)" in "Sustainability Value Entry".
        VerifyCO2eAmountActualInSustValueEntry(DocumentNo, ItemChargeAssignmentPurch."Item Charge No.", -1 * Quantity, 1 * ExpectedCO2eEmission);
    end;

    local procedure Initialize()
    var
        InventorySetup: Record "Inventory Setup";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sust. Item Chrg Assign. Test");
        LibrarySustainability.CleanUpBeforeTesting();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sust. Item Chrg Assign. Test");
        LibraryInventory.NoSeriesSetup(InventorySetup);
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        IsInitialized := true;

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sust. Item Chrg Assign. Test");
    end;

    local procedure UpdateCheckDocTotalAmountsInPurchPayablesSetup(CheckDocTotalAmounts: Boolean)
    var
        PurchPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchPayablesSetup.Get();
        PurchPayablesSetup.Validate("Check Doc. Total Amounts", CheckDocTotalAmounts);
        PurchPayablesSetup.Modify();
    end;

    local procedure ChargeAssignmentUsingPurchaseDocument(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; PurchaseDocumentType: Enum "Purchase Document Type"; Quantity: Decimal; AccountCode: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        CreateAndPostSalesOrder(SalesLine, SalesHeader."Document Type"::Order, Quantity);
        CreatePurchaseDocumentUsingChargeItem(PurchaseLine, PurchaseDocumentType, Quantity, LibraryRandom.RandDec(10, 2), AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);
        CreateItemChargeAssignmentUsingShipmentLine(ItemChargeAssignmentPurch, PurchaseLine, SalesLine."Document No.", SalesLine."No.");
    end;

    local procedure ChargeAssignmentUsingSalesRetOrder(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; PurchaseDocumentType: Enum "Purchase Document Type"; SalesDocumentType: Enum "Sales Document Type"; Quantity: Decimal; AccountCode: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
    begin
        CreateAndPostSalesOrder(SalesLine, SalesDocumentType, Quantity);
        CreatePurchaseDocumentUsingChargeItem(PurchaseLine, PurchaseDocumentType, Quantity, LibraryRandom.RandDec(10, 2), AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);
        CreateItemChargeAssignmentUsingReceiptLine(ItemChargeAssignmentPurch, PurchaseLine, SalesLine."Document No.", SalesLine."No.");
    end;

    local procedure PurchDocWithChgAssigntToPurchRcpt(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; DocumentType: Enum "Purchase Document Type"; PurchDocSign: Integer; QuantitySignFactor: Integer; CostSignFactor: Integer; Quantity: Decimal; AccountCode: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        CreateAndPostPurchaseDocument(PurchaseLine, PurchaseHeader."Document Type"::Order, Quantity, PurchDocSign);
        FindReceiptLine(PurchRcptLine, PurchaseLine."Document No.", PurchaseLine."No.");

        CreatePurchaseDocumentWithChargeItemAndItem(PurchaseLine2, DocumentType, PurchaseLine."Buy-from Vendor No.", Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O, QuantitySignFactor, CostSignFactor);
        LibraryInventory.CreateItemChargeAssignPurchase(ItemChargeAssignmentPurch, PurchaseLine2, ItemChargeAssignmentPurch."Applies-to Doc. Type"::Receipt, PurchRcptLine."Document No.", PurchRcptLine."Line No.", PurchRcptLine."No.");
        PurchaseHeader.Get(PurchaseLine2."Document Type", PurchaseLine2."Document No.");

        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure PurchDocWithChgAssgntToPurchRetShipt(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; DocumentType: Enum "Purchase Document Type"; QuantitySignFactor: Integer; CostSignFactor: Integer; Quantity: Decimal; AccountCode: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        ReturnShipmentLine: Record "Return Shipment Line";
    begin
        CreateAndPostPurchaseDocument(PurchaseLine, PurchaseHeader."Document Type"::"Return Order", Quantity, 1);
        FindReturnShipmentLine(ReturnShipmentLine, PurchaseLine."Document No.", PurchaseLine."No.");

        CreatePurchaseDocumentWithChargeItemAndItem(PurchaseLine2, DocumentType, PurchaseLine."Buy-from Vendor No.", Quantity, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O, QuantitySignFactor, CostSignFactor);
        LibraryInventory.CreateItemChargeAssignPurchase(ItemChargeAssignmentPurch, PurchaseLine2, ItemChargeAssignmentPurch."Applies-to Doc. Type"::"Return Shipment", ReturnShipmentLine."Document No.", ReturnShipmentLine."Line No.", ReturnShipmentLine."No.");
        PurchaseHeader.Get(PurchaseLine2."Document Type", PurchaseLine2."Document No.");

        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure CreatePurchaseDocumentWithChargeItemAndItem(var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; Quantity: Decimal; AccountCode: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal; QuantitySignFactor: Integer; CostSignFactor: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, VendorNo);
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, CreateItem(), Quantity, LibraryRandom.RandDec(100, 2), AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"Charge (Item)", LibraryInventory.CreateItemChargeNo(), QuantitySignFactor * PurchaseLine.Quantity, CostSignFactor * PurchaseLine."Direct Unit Cost", AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);
    end;

    local procedure CreateAndPostPurchaseDocument(var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; Quantity: Decimal; SignFactor: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, CreateVendor());
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, CreateItem(), Quantity, LibraryRandom.RandDec(100, 2));
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, CreateItem(), SignFactor * PurchaseLine.Quantity, PurchaseLine."Direct Unit Cost");
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure CreateItemChargeAssignmentUsingReceiptLine(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; PurchaseLine: Record "Purchase Line"; OrderNo: Code[20]; ItemNo: Code[20])
    var
        ReturnReceiptLine: Record "Return Receipt Line";
    begin
        FindReturnReceiptLine(ReturnReceiptLine, OrderNo, ItemNo);
        LibraryInventory.CreateItemChargeAssignPurchase(
          ItemChargeAssignmentPurch, PurchaseLine, ItemChargeAssignmentPurch."Applies-to Doc. Type"::"Return Receipt",
          ReturnReceiptLine."Document No.", ReturnReceiptLine."Line No.", ReturnReceiptLine."No.");
    end;

    local procedure CreateAndPostSalesOrder(var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type"; Quantity: Decimal)
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CreateCustomer());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, CreateItem(), Quantity);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure CreatePurchaseDocumentUsingChargeItem(var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; Quantity: Decimal; DirectUnitCost: Decimal; AccountCode: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, CreateVendor());
        CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"Charge (Item)",
          LibraryInventory.CreateItemChargeNo(), Quantity, DirectUnitCost, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);
        exit(PurchaseLine."No.");
    end;


    local procedure CreateItemChargeAssignmentUsingShipmentLine(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; PurchaseLine: Record "Purchase Line"; PurchaseOrderNo: Code[20]; ItemNo: Code[20])
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        FindShipmentLine(SalesShipmentLine, PurchaseOrderNo, ItemNo);
        LibraryInventory.CreateItemChargeAssignPurchase(
          ItemChargeAssignmentPurch, PurchaseLine, ItemChargeAssignmentPurch."Applies-to Doc. Type"::"Sales Shipment",
          SalesShipmentLine."Document No.", SalesShipmentLine."Line No.", SalesShipmentLine."No.");
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

    local procedure VerifyCO2eAmountActualInSustValueEntry(DocumentNo: Code[20]; ItemChargeNo: Code[20]; ValuedQuantity: Decimal; ExpectedCO2eEmission: Decimal)
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
    begin
        FindSustainabilityValueEntry(SustainabilityValueEntry, DocumentNo, ItemChargeNo, ValuedQuantity);
        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(SustainabilityValueEntry."CO2e Amount (Actual)"),
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), Round(ExpectedCO2eEmission), SustainabilityValueEntry.TableCaption()));
    end;

    local procedure FindSustainabilityValueEntry(var SustainabilityValueEntry: Record "Sustainability Value Entry"; DocumentNo: Code[20]; ItemChargeNo: Code[20]; ValuedQuantity: Decimal)
    begin
        SustainabilityValueEntry.SetRange("Document No.", DocumentNo);
        SustainabilityValueEntry.SetRange(Type, SustainabilityValueEntry.Type::"Charge (Item)");
        SustainabilityValueEntry.SetRange("No.", ItemChargeNo);
        SustainabilityValueEntry.SetRange("Valued Quantity", ValuedQuantity);
        SustainabilityValueEntry.FindFirst();
    end;

    local procedure FindReceiptLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; OrderNo: Code[20]; ItemNo: Code[20])
    begin
        PurchRcptLine.SetRange("Order No.", OrderNo);
        PurchRcptLine.SetRange("No.", ItemNo);
        PurchRcptLine.FindFirst();
    end;

    local procedure FindShipmentLine(var SalesShipmentLine: Record "Sales Shipment Line"; OrderNo: Code[20]; No: Code[20])
    begin
        SalesShipmentLine.SetRange("Order No.", OrderNo);
        SalesShipmentLine.SetRange("No.", No);
        SalesShipmentLine.FindFirst();
    end;

    local procedure FindReturnReceiptLine(var ReturnReceiptLine: Record "Return Receipt Line"; ReturnOrderNo: Code[20]; No: Code[20])
    begin
        ReturnReceiptLine.SetRange("Return Order No.", ReturnOrderNo);
        ReturnReceiptLine.SetRange("No.", No);
        ReturnReceiptLine.FindFirst();
    end;

    local procedure FindReturnShipmentLine(var ReturnShipmentLine: Record "Return Shipment Line"; ReturnOrderNo: Code[20]; ItemNo: Code[20])
    begin
        ReturnShipmentLine.SetRange("Return Order No.", ReturnOrderNo);
        ReturnShipmentLine.SetRange("No.", ItemNo);
        ReturnShipmentLine.FindFirst();
    end;

    local procedure CreatePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; BuyFromVendorNo: Code[20])
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, BuyFromVendorNo);
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
    end;

    local procedure CreatePurchaseLine(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; Type: Enum "Purchase Line Type"; No: Code[20]; Quantity: Decimal; DirectUnitCost: Decimal)
    begin
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Type, No, Quantity);
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Modify(true);
    end;

    local procedure CreatePurchaseLine(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; Type: Enum "Purchase Line Type"; No: Code[20]; Quantity: Decimal; DirectUnitCost: Decimal; AccountCode: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal)
    begin
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Type, No, Quantity);
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify(true);
    end;

    local procedure CreateVendor(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        exit(Vendor."No.");
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        exit(Customer."No.");
    end;

    local procedure CreateItem(): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Unit Price", LibraryRandom.RandDec(10, 2));
        Item.Modify(true);
        exit(Item."No.");
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
}
