// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Document;

codeunit 139648 "Shpfy Suggest Payment Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        IsInitialized: Boolean;

    [Test]
    procedure UnitTestSuggestShopifyPaymentsOneTransaction()
    var
        Item: Record Item;
        Customer: Record Customer;
        OrderTransaction: Record "Shpfy Order Transaction";
        SuggestPayment: Record "Shpfy Suggest Payment";
        SuggestPayments: Report "Shpfy Suggest Payments";
        OrderId: BigInteger;
        Amount: Decimal;
    begin
        // [SCENARIO] Suggest Shopify payments to create Cash Receipt Journal lines
        // [GIVEN] Invoice is posted
        Initialize();
        Amount := Any.IntegerInRange(10000, 99999);
        OrderId := Any.IntegerInRange(10000, 20000);
        CreateItem(Item, Amount);
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostSalesInvoice(Item, Customer, 1, OrderId);

        // [GIVEN] Shopify transaction is imported
        CreateOrderTransaction(OrderId, Amount, 'manual', OrderTransaction.Type::Sale, OrderTransaction.Status::Success);

        // [WHEN] Create Shopify transactions are run
        OrderTransaction.FindFirst();
        SuggestPayments.GetOrderTransactions(OrderTransaction);

        // [THEN] Temporary suggest payment records are created
        SuggestPayments.GetTempSuggestPayment(SuggestPayment);
        SuggestPayment.FindFirst();
        LibraryAssert.AreEqual(SuggestPayment.Amount, Amount, 'Amounts should match');
    end;

    [Test]
    procedure UnitTestSuggestShopifyPaymentsMultipleTransactions()
    var
        Item: Record Item;
        Customer: Record Customer;
        OrderTransaction: Record "Shpfy Order Transaction";
        SuggestPayment: Record "Shpfy Suggest Payment";
        SuggestPayments: Report "Shpfy Suggest Payments";
        OrderId: BigInteger;
        Amount: Decimal;
    begin
        // [SCENARIO] Suggest Shopify payments to create Cash Receipt Journal lines
        // [GIVEN] Invoice is posted
        Initialize();
        Amount := Any.IntegerInRange(10000, 99999);
        OrderId := Any.IntegerInRange(20000, 30000);
        CreateItem(Item, Amount);
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostSalesInvoice(Item, Customer, 1, OrderId);

        // [GIVEN] Shopify transactions are imported
        CreateOrderTransaction(OrderId, Amount * 0.75, 'manual', OrderTransaction.Type::Sale, OrderTransaction.Status::Success);
        CreateOrderTransaction(OrderId, Amount * 0.25, 'gift_card', OrderTransaction.Type::Sale, OrderTransaction.Status::Success);

        // [WHEN] Create Shopify transactions are run
#pragma warning disable AA0210
        OrderTransaction.SetRange("Shopify Order Id", OrderId);
#pragma warning restore AA0210
        OrderTransaction.FindSet();
        repeat
            SuggestPayments.GetOrderTransactions(OrderTransaction);
        until OrderTransaction.Next() = 0;

        // [THEN] Temporary suggest payment records are created
        SuggestPayments.GetTempSuggestPayment(SuggestPayment);
        SuggestPayment.FindSet();
        repeat
            if SuggestPayment.Gateway = 'manual' then
                LibraryAssert.AreEqual(SuggestPayment.Amount, Amount * 0.75, 'Amounts should match');
            if SuggestPayment.Gateway = 'gift_card' then
                LibraryAssert.AreEqual(SuggestPayment.Amount, Amount * 0.25, 'Amounts should match');
        until SuggestPayment.Next() = 0;
    end;

    [Test]
    procedure UnitTestSuggestShopifyPaymentsDocumentLink()
    var
        Item: Record Item;
        Customer: Record Customer;
        OrderTransaction: Record "Shpfy Order Transaction";
        SuggestPayment: Record "Shpfy Suggest Payment";
        DocLinkToDoc: Record "Shpfy Doc. Link To Doc.";
        SuggestPayments: Report "Shpfy Suggest Payments";
        OrderId1: BigInteger;
        OrderId2: BigInteger;
        SalesInvoiceNo: Code[20];
        Amount: Decimal;
    begin
        // [SCENARIO] Suggest Shopify payments to create Cash Receipt Journal line for linked Sales Invoice
        // [GIVEN] Invoice is posted
        Initialize();
        Amount := Any.IntegerInRange(10000, 99999);
        OrderId1 := Any.IntegerInRange(30000, 40000);
        OrderId2 := Any.IntegerInRange(40000, 50000);
        CreateItem(Item, Amount);
        LibrarySales.CreateCustomer(Customer);
        SalesInvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 2, 0);

        // [GIVEN] Shopify transactions are imported
        CreateOrderTransaction(OrderId1, Amount, 'manual', OrderTransaction.Type::Sale, OrderTransaction.Status::Success);
        CreateOrderTransaction(OrderId2, Amount, 'manual', OrderTransaction.Type::Sale, OrderTransaction.Status::Success);

        // [GIVEN] Link to Sales Invoice is set
        DocLinkToDoc."Shopify Document Type" := DocLinkToDoc."Shopify Document Type"::"Shopify Shop Order";
        DocLinkToDoc."Shopify Document Id" := OrderId1;
        DocLinkToDoc."Document Type" := DocLinkToDoc."Document Type"::"Posted Sales Invoice";
        DocLinkToDoc."Document No." := SalesInvoiceNo;
        DocLinkToDoc.Insert();
        DocLinkToDoc."Shopify Document Id" := OrderId2;
        DocLinkToDoc.Insert();

        // [WHEN] Create Shopify transactions are run
#pragma warning disable AA0210
        OrderTransaction.SetFilter("Shopify Order Id", '%1|%2', OrderId1, OrderId2);
#pragma warning restore AA0210
        OrderTransaction.FindSet();
        repeat
            SuggestPayments.GetOrderTransactions(OrderTransaction);
        until OrderTransaction.Next() = 0;

        // [THEN] Temporary suggest payment records are created
        SuggestPayments.GetTempSuggestPayment(SuggestPayment);
        SuggestPayment.FindSet();
        repeat
            LibraryAssert.AreEqual(SuggestPayment.Amount, Amount, 'Amounts should match');
        until SuggestPayment.Next() = 0;
    end;

    [HandlerFunctions('SuggestShopifyPaymentsRequestPageHandler')]
    [Test]
    procedure UnitTestSuggestShopifyPaymentsFailedTransaction()
    var
        Item: Record Item;
        Customer: Record Customer;
        OrderTransaction: Record "Shpfy Order Transaction";
        GenJournalLine: Record "Gen. Journal Line";
        CashReceiptJournal: TestPage "Cash Receipt Journal";
        OrderId: BigInteger;
        SuccessTransactionId: BigInteger;
        Amount: Decimal;
    begin
        // [SCENARIO] Suggest Shopify payments does not create Cash Receipt Journal lines for failed transactions
        // [GIVEN] Invoice is posted
        Initialize();
        Amount := Any.IntegerInRange(10000, 99999);
        OrderId := Any.IntegerInRange(50000, 60000);
        CreateItem(Item, Amount);
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostSalesInvoice(Item, Customer, 1, OrderId);

        // [GIVEN] One failed one success Shopify transaction is imported
        CreateOrderTransaction(OrderId, Amount, 'manual', OrderTransaction.Type::Sale, OrderTransaction.Status::Failure);
        SuccessTransactionId := CreateOrderTransaction(OrderId, Amount, 'manual', OrderTransaction.Type::Sale, OrderTransaction.Status::Success);
        Commit();

        // [WHEN] Report is run
        CashReceiptJournal.OpenView();
        CashReceiptJournal.SuggestShopifyPayments.Invoke();

        // [THEN] Only one Cash Receipt Journal line is created
#pragma warning disable AA0210
        GenJournalLine.SetRange("Document Type", GenJournalLine."Document Type"::Payment);
#pragma warning restore AA0210
        GenJournalLine.SetRange("Account No.", Customer."No.");
        LibraryAssert.RecordCount(GenJournalLine, 1);
        GenJournalLine.FindFirst();
        LibraryAssert.AreEqual(GenJournalLine."Shpfy Transaction Id", SuccessTransactionId, 'Transaction Ids should match');
    end;

    [HandlerFunctions('SuggestShopifyPaymentsRequestPageHandler')]
    [Test]
    procedure UnitTestSuggestShopifyPaymentsJournalLines()
    var
        Item: Record Item;
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        OrderTransaction: Record "Shpfy Order Transaction";
        CashReceiptJournal: TestPage "Cash Receipt Journal";
        OrderId1: BigInteger;
        OrderId2: BigInteger;
        OrderId3: BigInteger;
        Amount: Decimal;
    begin
        // [SCENARIO] Suggest Shopify payments to create Cash Receipt Journal lines
        // [GIVEN] Invoice is posted
        Initialize();
        Amount := Any.IntegerInRange(10000, 99999);
        OrderId1 := Any.IntegerInRange(60000, 70000);
        OrderId2 := Any.IntegerInRange(70000, 80000);
        OrderId3 := Any.IntegerInRange(80000, 90000);
        CreateItem(Item, Amount);
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostSalesInvoice(Item, Customer, 1, OrderId1);
        CreateAndPostSalesInvoice(Item, Customer, 1, OrderId2);
        CreateAndPostSalesInvoice(Item, Customer, 2, OrderId3);

        // [GIVEN] Shopify transactions are imported
        CreateOrderTransaction(OrderId1, Amount, 'manual', OrderTransaction.Type::Sale, OrderTransaction.Status::Success);
        CreateOrderTransaction(OrderId2, Amount * 0.75, 'manual', OrderTransaction.Type::Sale, OrderTransaction.Status::Success);
        CreateOrderTransaction(OrderId2, Amount * 0.25, 'gift_card', OrderTransaction.Type::Sale, OrderTransaction.Status::Success);
        CreateOrderTransaction(OrderId3, Amount * 2, 'bogus', OrderTransaction.Type::Sale, OrderTransaction.Status::Success);
        Commit();

        // [WHEN] Report is run
        CashReceiptJournal.OpenView();
        CashReceiptJournal.SuggestShopifyPayments.Invoke();

        // [THEN] Cash Receipt Journal lines are created
        GenJournalLine.SetRange("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLine.SetRange("Account No.", Customer."No.");
        LibraryAssert.RecordCount(GenJournalLine, 4);
    end;

    [Test]
    procedure UnitTestSuggestShopifyPaymentsRefunds()
    var
        Item: Record Item;
        Customer: Record Customer;
        OrderTransaction: Record "Shpfy Order Transaction";
        SuggestPayment: Record "Shpfy Suggest Payment";
        SuggestPayments: Report "Shpfy Suggest Payments";
        OrderId: BigInteger;
        RefundId: BigInteger;
        Amount: Decimal;
    begin
        // [SCENARIO] Suggest Shopify payments to create Cash Receipt Journal lines
        // [GIVEN] Invoice is posted
        Initialize();
        Amount := Any.IntegerInRange(10000, 99999);
        OrderId := Any.IntegerInRange(90000, 99999);
        RefundId := Any.IntegerInRange(10000, 99999);
        CreateRefund(OrderId, RefundId, Amount);
        CreateItem(Item, Amount);
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostSalesCreditMemo(Item, Customer, 1, RefundId);

        // [GIVEN] Shopify transaction is imported
        CreateOrderTransaction(OrderId, Amount, 'manual', OrderTransaction.Type::Refund, OrderTransaction.Status::Success);

        // [WHEN] Create Shopify transactions are run
        OrderTransaction.FindFirst();
        SuggestPayments.GetOrderTransactions(OrderTransaction);

        // [THEN] Temporary suggest payment records are created
        SuggestPayments.GetTempSuggestPayment(SuggestPayment);
        SuggestPayment.FindFirst();
        LibraryAssert.AreEqual(SuggestPayment.Amount, -Amount, 'Amounts should match');
    end;

    local procedure Initialize()
    var
        OrderTransaction: Record "Shpfy Order Transaction";
    begin
        OrderTransaction.DeleteAll();
        if IsInitialized then
            exit;
        IsInitialized := true;
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
    end;

    local procedure CreateAndPostSalesInvoice(Item: Record Item; Customer: Record Customer; NumberOfLines: Integer; OrderId: BigInteger): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader."Shpfy Order Id" := OrderId;
        SalesHeader.Modify();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", NumberOfLines);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateAndPostSalesCreditMemo(Item: Record Item; Customer: Record Customer; NumberOfLines: Integer; RefundId: BigInteger): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", Customer."No.");
        SalesHeader."Shpfy Refund Id" := RefundId;
        SalesHeader.Modify();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", NumberOfLines);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateItem(var Item: Record Item; Amount: Decimal)
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Unit Price", Amount);
        Item.Validate("Last Direct Cost", Amount);
        Item.Modify(true);
    end;

    local procedure CreateOrderTransaction(OrderId: BigInteger; Amount: Decimal; Gateway: Code[20]; TransactionType: Enum "Shpfy Transaction Type"; Status: Enum "Shpfy Transaction Status"): BigInteger
    var
        OrderTransaction: Record "Shpfy Order Transaction";
    begin
        OrderTransaction."Shopify Transaction Id" := Any.IntegerInRange(10000, 99999);
        OrderTransaction."Shopify Order Id" := OrderId;
        OrderTransaction.Amount := Amount;
        OrderTransaction.Gateway := Gateway;
        OrderTransaction.Type := TransactionType;
        OrderTransaction.Status := Status;
        OrderTransaction.Insert();
        exit(OrderTransaction."Shopify Transaction Id");
    end;

    local procedure CreateRefund(OrderId: BigInteger; RefundId: BigInteger; Amount: Decimal)
    var
        RefundHeader: Record "Shpfy Refund Header";
    begin
        RefundHeader."Refund Id" := RefundId;
        RefundHeader."Order Id" := OrderId;
        RefundHeader."Total Refunded Amount" := Amount;
        RefundHeader.Insert();
    end;

    [RequestPageHandler]
    procedure SuggestShopifyPaymentsRequestPageHandler(var SuggestPayments: TestRequestPage "Shpfy Suggest Payments")
    begin
        SuggestPayments.OK().Invoke();
    end;
}
