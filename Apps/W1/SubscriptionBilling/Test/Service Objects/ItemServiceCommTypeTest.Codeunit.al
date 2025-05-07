namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.BOM;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;
using Microsoft.Pricing.PriceList;
using Microsoft.Pricing.Source;
using Microsoft.Pricing.Asset;

codeunit 139885 "Item Service Comm. Type Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    trigger OnRun()
    begin
        ContractTestLibrary.EnableNewPricingExperience();
    end;

    var
        BOMComponent: Record "BOM Component";
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        AssertThat: Codeunit Assert;
        ServiceCommitmentItemErr: Label 'Items that are marked as Subscription Item may not be used here. Please choose another item.';
        InvoicingItemErr: Label 'Items that are marked as Invoicing Item may not be used here. Please choose another item.';

    #region Tests

    [Test]
    procedure CheckBillingItemOption()
    begin
        ContractTestLibrary.CreateInventoryItem(Item);
        Commit(); // retain data after asserterror
        asserterror Item.Validate("Subscription Option", Enum::"Item Service Commitment Type"::"Invoicing Item");
        Item.Validate(Type, Item.Type::"Non-Inventory");
        Item.Modify(false);
        Item.Validate("Subscription Option", Enum::"Item Service Commitment Type"::"Invoicing Item");
        asserterror Item.Validate(Type, Item.Type::Inventory);
    end;

    [Test]
    procedure CheckServiceCommitmentItemOption()
    begin
        ContractTestLibrary.CreateInventoryItem(Item);
        Commit(); // retain testing data
        asserterror Item.Validate("Subscription Option", Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item.Validate(Type, Item.Type::"Non-Inventory");
        Item.Modify(false);
        Item.Validate("Subscription Option", Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item.TestField("Allow Invoice Disc.", false);
        Commit(); // retain testing data
        asserterror Item.Validate(Type, Item.Type::Inventory);
        asserterror Item.Validate("Allow Invoice Disc.", true);
        Item.Validate("Subscription Option", Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        Item.TestField("Allow Invoice Disc.", true);
    end;

    [Test]
    procedure ExpectErrorPostingServiceCommitmentItemOnPurchaseInvoice()
    begin
        ClearAll();
        // [GIVEN] Create Purchase Return Order
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, '');
        Commit(); // retain data after asserterror
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Enum::"Purchase Line Type"::Item, Item."No.", 1);

        // [WHEN] Try to post Purchase Line with Item which is Subscription Item
        // [THEN] expect error is thrown
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    [Test]
    procedure ExpectErrorUsingBillingItemOnBOM()
    begin
        ClearAll();
        // [GIVEN] Create Invoicing Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        // [WHEN] Try to enter BOM Component with Item which is Invoicing Item
        BOMComponent.Type := BOMComponent.Type::Item;
        asserterror BOMComponent.Validate("No.", Item."No.");
        // [THEN] expect error is thrown
        AssertThat.ExpectedError(InvoicingItemErr);
    end;

    [Test]
    procedure ExpectErrorUsingServiceCommitmentItemOnSalesInvoice()
    begin
        ClearAll();
        // [GIVEN] Create Sales Invoice
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, '');
        // [WHEN] Try to enter Sales Line with Item which is Subscription Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", 1);
        // [THEN] expect error is thrown
        AssertThat.ExpectedError(ServiceCommitmentItemErr);
    end;

    [Test]
    procedure ExpectErrorUsingServiceCommitmentItemOnPurchaseQuote()
    begin
        ClearAll();
        // [GIVEN] Create Purchase Invoice
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Quote, '');
        // [WHEN] Try to enter Purchase Line with Item which is Subscription Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        asserterror LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Enum::"Purchase Line Type"::Item, Item."No.", 1);
        // [THEN] expect error is thrown
        AssertThat.ExpectedError(ServiceCommitmentItemErr);
    end;

    [Test]
    procedure ExpectErrorUsingServiceCommitmentItemAndAllowInvoiceDiscountOnSalesLine()
    begin
        ClearAll();
        // [GIVEN] Create Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        // [WHEN] Try to set Allow Invoice Discount on Sales Line with Item which is Subscription Item
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", 1);
        SalesLine.TestField("Allow Invoice Disc.", false);
        asserterror SalesLine.Validate("Allow Invoice Disc.", true);
    end;

    [Test]
    procedure ExpectErrorUsingServiceCommitmentItemAndAllowInvoiceDiscountOnSalesPrice()
    var
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
    begin
        ClearAll();
        // [GIVEN] Create Subscription Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        // [WHEN] Try to set Allow Invoice Discount on Sales Price with Item which is Subscription Item
        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Sale, "Price Source Type"::"All Customers", '');
        PriceListHeader.Status := "Price Status"::Active;
        PriceListHeader."Allow Updating Defaults" := true;
        PriceListHeader."Currency Code" := '';
        PriceListHeader.Modify(true);

        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader, "Price Amount Type"::Price, "Price Asset Type"::Item, Item."No.");
        PriceListLine.TestField("Allow Invoice Disc.", false);
        // [THEN] expect error is thrown
        asserterror PriceListLine.Validate("Allow Invoice Disc.", true);
    end;

    [Test]
    procedure ExpectErrorUsingServiceCommitmentItemAndBillingItemOnPurchaseReturnOrder()
    begin
        ClearAll();
        // [GIVEN] Create Purchase Return Order
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Return Order", '');
        Commit(); // retain data after asserterror
        // [WHEN] Try to enter Purchase Line with Item which is Subscription Item or Invoicing Item
        // [THEN] expect error is thrown
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        asserterror LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Enum::"Purchase Line Type"::Item, Item."No.", 1);
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        asserterror LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Enum::"Purchase Line Type"::Item, Item."No.", 1);
    end;

    [Test]
    procedure ExpectErrorUsingServiceCommitmentItemAndBillingItemOnSalesReturnOrder()
    begin
        ClearAll();
        // [GIVEN] Create Sales Return Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Return Order", '');
        Commit(); // retain data after asserterror
        // [WHEN] Try to enter Sales Line with Item which is Subscription Item or Invoicing Item
        // [THEN] expect error is thrown
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", 1);
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", 1);
    end;

    #endregion Tests
}
