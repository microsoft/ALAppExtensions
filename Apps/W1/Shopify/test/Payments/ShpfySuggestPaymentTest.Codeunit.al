codeunit 139648 "Shpfy Suggest Payment Test"
{
    Subtype = Test;
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
        OrderId := Any.IntegerInRange(10000, 99999);
        CreateItem(Item, Amount);
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostSalesInvoice(Item, Customer, 1, OrderId);

        // [GIVEN] Shopify transaction is imported
        CreateOrderTransaction(OrderId, Amount, 'manual', OrderTransaction.Type::Sale);

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
        OrderId := Any.IntegerInRange(10000, 99999);
        CreateItem(Item, Amount);
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostSalesInvoice(Item, Customer, 1, OrderId);

        // [GIVEN] Shopify transactions are imported
        CreateOrderTransaction(OrderId, Amount * 0.75, 'manual', OrderTransaction.Type::Sale);
        CreateOrderTransaction(OrderId, Amount * 0.25, 'gift_card', OrderTransaction.Type::Sale);

        // [WHEN] Create Shopify transactions are run
        OrderTransaction.SetRange("Shopify Order Id", OrderId);
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
        OrderId1 := Any.IntegerInRange(10000, 99999);
        OrderId2 := Any.IntegerInRange(10000, 99999);
        OrderId3 := Any.IntegerInRange(10000, 99999);
        CreateItem(Item, Amount);
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostSalesInvoice(Item, Customer, 1, OrderId1);
        CreateAndPostSalesInvoice(Item, Customer, 1, OrderId2);
        CreateAndPostSalesInvoice(Item, Customer, 2, OrderId3);

        // [GIVEN] Shopify transactions are imported
        CreateOrderTransaction(OrderId1, Amount, 'manual', OrderTransaction.Type::Sale);
        CreateOrderTransaction(OrderId2, Amount * 0.75, 'manual', OrderTransaction.Type::Sale);
        CreateOrderTransaction(OrderId2, Amount * 0.25, 'gift_card', OrderTransaction.Type::Sale);
        CreateOrderTransaction(OrderId3, Amount * 2, 'bogus', OrderTransaction.Type::Sale);
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
        OrderId := Any.IntegerInRange(10000, 99999);
        RefundId := Any.IntegerInRange(10000, 99999);
        CreateRefund(OrderId, RefundId, Amount);
        CreateItem(Item, Amount);
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostSalesCreditMemo(Item, Customer, 1, RefundId);

        // [GIVEN] Shopify transaction is imported
        CreateOrderTransaction(OrderId, Amount, 'manual', OrderTransaction.Type::Refund);

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

    local procedure CreateOrderTransaction(OrderId: BigInteger; Amount: Decimal; Gateway: Code[20]; TransactionType: Enum "Shpfy Transaction Type")
    var
        OrderTransaction: Record "Shpfy Order Transaction";
    begin
        OrderTransaction."Shopify Transaction Id" := Any.IntegerInRange(10000, 99999);
        OrderTransaction."Shopify Order Id" := OrderId;
        OrderTransaction.Amount := Amount;
        OrderTransaction.Gateway := Gateway;
        OrderTransaction.Type := TransactionType;
        OrderTransaction.Insert();
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