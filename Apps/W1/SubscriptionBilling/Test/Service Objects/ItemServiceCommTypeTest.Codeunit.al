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

    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        BOMComponent: Record "BOM Component";
        Item: Record Item;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";

    trigger OnRun()
    begin
        ContractTestLibrary.EnableNewPricingExperience();
    end;

    [Test]
    procedure ExpectErrorServiceCommitmentItemAssignment()
    begin
        //TODO: for sit.mim -> This test does not check anything although it is successful
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SalesLine.Type := SalesLine.Type::Item;
        asserterror SalesLine.Validate("No.", Item."No.");
        PurchaseLine.Type := PurchaseLine.Type::Item;
        asserterror PurchaseLine.Validate("No.", Item."No.");
        BOMComponent.Type := BOMComponent.Type::Item;
        asserterror BOMComponent.Validate("No.", Item."No.");
    end;

    [Test]
    procedure CheckServiceCommitmentItemOption()
    begin
        ContractTestLibrary.CreateInventoryItem(Item);
        Commit(); //retain testing data
        asserterror Item.Validate("Service Commitment Option", Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item.Validate(Type, Item.Type::"Non-Inventory");
        Item.Modify(false);
        Item.Validate("Service Commitment Option", Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item.TestField("Allow Invoice Disc.", false);
        Commit(); //retain testing data
        asserterror Item.Validate(Type, Item.Type::Inventory);
        asserterror Item.Validate("Allow Invoice Disc.", true);
        Item.Validate("Service Commitment Option", Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        Item.TestField("Allow Invoice Disc.", true);
    end;

    [Test]
    procedure CheckBillingItemOption()
    begin
        ContractTestLibrary.CreateInventoryItem(Item);
        Commit(); // retain data after asserterror
        asserterror Item.Validate("Service Commitment Option", Enum::"Item Service Commitment Type"::"Invoicing Item");
        Item.Validate(Type, Item.Type::"Non-Inventory");
        Item.Modify(false);
        Item.Validate("Service Commitment Option", Enum::"Item Service Commitment Type"::"Invoicing Item");
        asserterror Item.Validate(Type, Item.Type::Inventory);
    end;

    [Test]
    procedure ExpectErrorUsingServiceCommitmentItemAndBillingItemOnSalesReturnOrder()
    begin
        ClearAll();
        // [GIVEN] Create Sales Return Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Return Order", '');
        Commit(); // retain data after asserterror
        // [WHEN] Try to enter Sales Line with Item which is Service Commitment Item or Invoicing Item
        // [THEN] expect error is thrown
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", 1);
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", 1);
    end;

    [Test]
    procedure ExpectErrorUsingServiceCommitmentItemAndBillingItemOnPurchaseReturnOrder()
    begin
        ClearAll();
        // [GIVEN] Create Purchase Return Order
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Return Order", '');
        Commit(); // retain data after asserterror
        // [WHEN] Try to enter Purchase Line with Item which is Service Commitment Item or Invoicing Item
        // [THEN] expect error is thrown
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        asserterror LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Enum::"Purchase Line Type"::Item, Item."No.", 1);
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        asserterror LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Enum::"Purchase Line Type"::Item, Item."No.", 1);
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

        // [WHEN] Try to post Purchase Line with Item which is Service Commitment Item
        // [THEN] expect error is thrown
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    [Test]
    procedure ExpectErrorUsingServiceCommitmentItemAndAllowInvoiceDiscountOnSalesLine()
    begin
        ClearAll();
        // [GIVEN] Create Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        // [WHEN] Try to set Allow Invoice Discount on Sales Line with Item which is Service Commitment Item
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
        // [GIVEN] Create Service Commitment Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        // [WHEN] Try to set Allow Invoice Discount on Sales Price with Item which is Service Commitment Item
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
}