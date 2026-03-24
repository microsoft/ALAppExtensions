namespace Microsoft.Test.Sustainability;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.Ledger;

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
        LibraryERM: Codeunit "Library - ERM";
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

    [Test]
    procedure VerifySustainabilityLedgerEntryMustBeCreatedForPurchOrderWithChgAssignmentToPurchRetShpt()
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountSubCategory: Record "Sustain. Account Subcategory";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
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
        // [SCENARIO 597149] Verify Sustainability Ledger Entry must be created for Posted Purchase Invoice after assigning Charge to Return Shipment.
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

        // [THEN] Verify "CO2e Emission" must be updated in Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", DocumentNo);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), ExpectedCO2eEmission, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifyCancelledPurchOrderCreatesNegativeEmissionInSustainabilityLedgerEntry()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 581746] Verify cancelled Purchase Order creates negative emission in Sustainability Ledger Entry.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No., Emission CO2, Emission CH4, Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [GIVEN] Post Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Cancel Posted Purchase Invoice.
        PurchaseInvoiceHeader.Get(PostedInvoiceNo);
        CorrectPostedPurchInvoice.CancelPostedInvoice(PurchaseInvoiceHeader);

        // [THEN] Verify the cancellation Sustainability Ledger Entry has negative emission values.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.FindLast();
        Assert.AreEqual(
            -EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), -EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), -EmissionCH4, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), -EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifyCorrectedPurchaseOrderCreatesNegativeEmissionInSustainabilityLedgerEntry()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 581746] Verify corrective credit memo for Purchase Order creates negative emission in Sustainability Ledger Entry.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No., Emission CO2, Emission CH4, Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [GIVEN] Post Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedInvoiceNo);

        // [WHEN] Create and Post Corrective Credit Memo.
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryRandom.RandText(10));
        PurchaseHeader.Modify();
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify the corrective Sustainability Ledger Entry has negative emission values.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.FindLast();
        Assert.AreEqual(
            -EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), -EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), -EmissionCH4, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), -EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryRemovedWhenPurchInvoiceIsCancelled()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 581746] Verify Sustainability Ledger Entry should be removed when Posted Purchase Invoice is cancelled.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Invoice.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Invoice, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No., Emission CO2, Emission CH4, Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [GIVEN] Post Purchase Invoice.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Cancel Posted Purchase Invoice.
        PurchaseInvoiceHeader.Get(PostedInvoiceNo);
        CorrectPostedPurchInvoice.CancelPostedInvoice(PurchaseInvoiceHeader);

        // [THEN] Verify Sustainability Ledger Entry emissions are removed.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O");
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
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryRemovedWhenPurchInvoiceIsCorrected()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 581746] Verify Sustainability Ledger Entry should be removed when corrective credit memo for Purchase Invoice is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Invoice.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Invoice, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No., Emission CO2, Emission CH4, Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [GIVEN] Post Purchase Invoice.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedInvoiceNo);

        // [WHEN] Create and Post Corrective Credit Memo.
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryRandom.RandText(10));
        PurchaseHeader.Modify();
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entry emissions are removed.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O");
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
    end;

    [Test]
    procedure VerifyPositiveEmissionForChargeItemOnPostedPurchaseOrder()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeader2: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO 581746] Verify Sustainability Ledger Entry has positive emission when charge item is assigned to Purchase Receipt.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Purchase Order with Item.
        ItemNo := LibraryInventory.CreateItemNo();
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, ItemNo, LibraryRandom.RandInt(10));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Modify();

        // [GIVEN] Post Purchase Order.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Find Purchase Receipt Line.
        PurchRcptLine.SetRange("Order No.", PurchaseHeader."No.");
        PurchRcptLine.SetRange("No.", ItemNo);
        PurchRcptLine.FindFirst();

        // [GIVEN] Create Purchase Order with Charge Item and Sustainability.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader2, "Purchase Document Type"::Order, PurchaseHeader."Buy-from Vendor No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine2, PurchaseHeader2, "Purchase Line Type"::"Charge (Item)", LibraryInventory.CreateItemChargeNo(), LibraryRandom.RandInt(10));
        PurchaseLine2.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine2.Validate("Sust. Account No.", AccountCode);
        PurchaseLine2.Validate("Emission CO2", EmissionCO2);
        PurchaseLine2.Validate("Emission CH4", EmissionCH4);
        PurchaseLine2.Validate("Emission N2O", EmissionN2O);
        PurchaseLine2.Modify();

        // [GIVEN] Assign Item Charge to Purchase Receipt.
        LibraryInventory.CreateItemChargeAssignPurchase(
            ItemChargeAssignmentPurch, PurchaseLine2,
            ItemChargeAssignmentPurch."Applies-to Doc. Type"::Receipt,
            PurchRcptLine."Document No.", PurchRcptLine."Line No.", PurchRcptLine."No.");

        // [WHEN] Post Purchase Order with Charge Item.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader2, true, true);

        // [THEN] Verify Sustainability Ledger Entry has positive emission.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCH4, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifyNegativeEmissionForChargeItemOnPostedPurchaseReturnOrder()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeader2: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedCrMemoNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO 581746] Verify Sustainability Ledger Entry has negative emission when charge item is assigned to Return Shipment via Purchase Return Order.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create and Post Purchase Return Order with Item.
        ItemNo := LibraryInventory.CreateItemNo();
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::"Return Order", LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, ItemNo, LibraryRandom.RandInt(10));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Modify();
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Find Return Shipment Line.
        ReturnShipmentLine.SetRange("Return Order No.", PurchaseHeader."No.");
        ReturnShipmentLine.SetRange("No.", ItemNo);
        ReturnShipmentLine.FindFirst();

        // [GIVEN] Create Purchase Return Order with Charge Item and Sustainability.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader2, "Purchase Document Type"::"Return Order", PurchaseHeader."Buy-from Vendor No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine2, PurchaseHeader2, "Purchase Line Type"::"Charge (Item)", LibraryInventory.CreateItemChargeNo(), LibraryRandom.RandInt(10));
        PurchaseLine2.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine2.Validate("Sust. Account No.", AccountCode);
        PurchaseLine2.Validate("Emission CO2", EmissionCO2);
        PurchaseLine2.Validate("Emission CH4", EmissionCH4);
        PurchaseLine2.Validate("Emission N2O", EmissionN2O);
        PurchaseLine2.Modify();

        // [GIVEN] Assign Item Charge to Return Shipment.
        LibraryInventory.CreateItemChargeAssignPurchase(
            ItemChargeAssignmentPurch, PurchaseLine2,
            ItemChargeAssignmentPurch."Applies-to Doc. Type"::"Return Shipment",
            ReturnShipmentLine."Document No.", ReturnShipmentLine."Line No.", ReturnShipmentLine."No.");

        // [WHEN] Post Purchase Return Order with Charge Item.
        PostedCrMemoNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader2, true, true);

        // [THEN] Verify Sustainability Ledger Entry has negative emission.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedCrMemoNo);
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            -EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), -EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), -EmissionCH4, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), -EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifyEmissionRemovedForChargeItemWhenPurchInvoiceIsCancelled()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeader2: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO 581746] Verify Sustainability Ledger Entry emissions are removed when Purchase Invoice with charge item is cancelled.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Purchase Order with Item.
        ItemNo := LibraryInventory.CreateItemNo();
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, ItemNo, LibraryRandom.RandInt(10));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Modify();

        // [GIVEN] Post Purchase Order.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Find Purchase Receipt Line.
        PurchRcptLine.SetRange("Order No.", PurchaseHeader."No.");
        PurchRcptLine.SetRange("No.", ItemNo);
        PurchRcptLine.FindFirst();

        // [GIVEN] Create Purchase Order with Charge Item and Sustainability.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader2, "Purchase Document Type"::Order, PurchaseHeader."Buy-from Vendor No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine2, PurchaseHeader2, "Purchase Line Type"::"Charge (Item)", LibraryInventory.CreateItemChargeNo(), LibraryRandom.RandInt(10));
        PurchaseLine2.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine2.Validate("Sust. Account No.", AccountCode);
        PurchaseLine2.Validate("Emission CO2", EmissionCO2);
        PurchaseLine2.Validate("Emission CH4", EmissionCH4);
        PurchaseLine2.Validate("Emission N2O", EmissionN2O);
        PurchaseLine2.Modify();

        // [GIVEN] Assign Item Charge to Purchase Receipt.
        LibraryInventory.CreateItemChargeAssignPurchase(
            ItemChargeAssignmentPurch, PurchaseLine2,
            ItemChargeAssignmentPurch."Applies-to Doc. Type"::Receipt,
            PurchRcptLine."Document No.", PurchRcptLine."Line No.", PurchRcptLine."No.");

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader2);

        // [GIVEN] Post Purchase Order with Charge Item.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader2, true, true);

        // [WHEN] Cancel Posted Purchase Invoice.
        PurchaseInvoiceHeader.Get(PostedInvoiceNo);
        CorrectPostedPurchInvoice.CancelPostedInvoice(PurchaseInvoiceHeader);

        // [THEN] Verify Sustainability Ledger Entry emissions are removed.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O");
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
    end;

    [Test]
    procedure VerifyEmissionRemovedForChargeItemWhenCorrectiveCrMemoIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeader2: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO 581746] Verify Sustainability Ledger Entry emissions are removed when corrective credit memo for Purchase Invoice with charge item is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Purchase Order with Item.
        ItemNo := LibraryInventory.CreateItemNo();
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, ItemNo, LibraryRandom.RandInt(10));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Modify();

        // [GIVEN] Post Purchase Order.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Find Purchase Receipt Line.
        PurchRcptLine.SetRange("Order No.", PurchaseHeader."No.");
        PurchRcptLine.SetRange("No.", ItemNo);
        PurchRcptLine.FindFirst();

        // [GIVEN] Create Purchase Order with Charge Item and Sustainability.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader2, "Purchase Document Type"::Order, PurchaseHeader."Buy-from Vendor No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine2, PurchaseHeader2, "Purchase Line Type"::"Charge (Item)", LibraryInventory.CreateItemChargeNo(), LibraryRandom.RandInt(10));
        PurchaseLine2.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine2.Validate("Sust. Account No.", AccountCode);
        PurchaseLine2.Validate("Emission CO2", EmissionCO2);
        PurchaseLine2.Validate("Emission CH4", EmissionCH4);
        PurchaseLine2.Validate("Emission N2O", EmissionN2O);
        PurchaseLine2.Modify();

        // [GIVEN] Assign Item Charge to Purchase Receipt.
        LibraryInventory.CreateItemChargeAssignPurchase(
            ItemChargeAssignmentPurch, PurchaseLine2,
            ItemChargeAssignmentPurch."Applies-to Doc. Type"::Receipt,
            PurchRcptLine."Document No.", PurchRcptLine."Line No.", PurchRcptLine."No.");

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader2);

        // [GIVEN] Post Purchase Order with Charge Item.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader2, true, true);
        PurchaseInvoiceHeader.Get(PostedInvoiceNo);

        // [WHEN] Create and Post Corrective Credit Memo.
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader2);
        PurchaseHeader2.Validate("Vendor Cr. Memo No.", LibraryRandom.RandText(10));
        PurchaseHeader2.Modify();
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader2, true, true);

        // [THEN] Verify Sustainability Ledger Entry emissions are removed.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O");
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

    local procedure UpdateReasonCodeinPurchaseHeader(var PurchaseHeader: Record "Purchase Header")
    var
        ReasonCode: Record "Reason Code";
    begin
        LibraryERM.CreateReasonCode(ReasonCode);

        PurchaseHeader.Validate("Reason Code", ReasonCode.Code);
        PurchaseHeader.Modify();
    end;
}
