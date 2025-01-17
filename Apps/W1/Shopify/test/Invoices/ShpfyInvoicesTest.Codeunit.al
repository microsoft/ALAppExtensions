codeunit 139695 "Shpfy Invoices Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Customer: Record Customer;
        Item: Record Item;
        Shop: Record "Shpfy Shop";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryAssert: Codeunit "Library Assert";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        IsInitialized: Boolean;

    #region Test Methods
    [Test]
    procedure UnitTestCopyInvoice()
    var
        SalesHeader: Record "Sales Header";
        OrderId: BigInteger;
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Shopify related fields are not copied to the new invoice
        Initialize();

        // [GIVEN] Posted sales invoice with Shopify related fields and empty invoice
        OrderId := LibraryRandom.RandIntInRange(10000, 99999);
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, false, OrderId);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");

        // [WHEN] Copy the invoice
        CopySalesDocument(SalesHeader, InvoiceNo);

        // [THEN] Shopify related fields are not copied
        LibraryAssert.IsTrue(SalesHeader."Shpfy Order Id" = 0, 'Shpfy Order Id is not copied');
    end;

    [Test]
    procedure UnitTestMapPostedSalesInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        TempOrderHeader: Record "Shpfy Order Header" temporary;
        TempOrderLine: Record "Shpfy Order Line" temporary;
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        OrderId: BigInteger;
        InvoiceNo: Code[20];
        OrderTaxLines: Dictionary of [Text, Decimal];
    begin
        // [SCENARIO] Header and lines are mapped correctly
        Initialize();

        // [GIVEN] Posted sales invoice
        OrderId := LibraryRandom.RandIntInRange(10000, 99999);
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, false, OrderId);
        SalesInvoiceHeader.Get(InvoiceNo);
        SalesInvoiceLine.SetRange("Document No.", InvoiceNo);
        SalesInvoiceLine.FindFirst();

        // [WHEN] Map the posted invoice
        PostedInvoiceExport.MapPostedSalesInvoiceData(SalesInvoiceHeader, TempOrderHeader, TempOrderLine, OrderTaxLines);

        // [THEN] Header is mapped correctly
        LibraryAssert.AreEqual(TempOrderHeader."Sales Invoice No.", SalesInvoiceHeader."No.", 'Sales Invoice No. is mapped correctly');
        LibraryAssert.AreEqual(TempOrderHeader."Sales Order No.", SalesInvoiceHeader."Order No.", 'Sales Order No. is mapped correctly');
        LibraryAssert.AreEqual(TempOrderHeader."Created At", SalesInvoiceHeader.SystemCreatedAt, 'Created At is mapped correctly');
        LibraryAssert.IsTrue(TempOrderHeader.Confirmed, 'Confirmed is mapped correctly');
        LibraryAssert.AreEqual(TempOrderHeader."Updated At", SalesInvoiceHeader.SystemModifiedAt, 'Updated At is mapped correctly');
        LibraryAssert.AreEqual(TempOrderHeader."Document Date", SalesInvoiceHeader."Document Date", 'Document Date is mapped correctly');
        SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");
        LibraryAssert.AreEqual(TempOrderHeader."VAT Amount", SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount, 'VAT Amount is mapped correctly');
        LibraryAssert.AreEqual(TempOrderHeader."Discount Amount", SalesInvoiceHeader."Invoice Discount Amount", 'Discount Amount is mapped correctly');
        LibraryAssert.AreEqual(TempOrderHeader."Fulfillment Status", Enum::"Shpfy Order Fulfill. Status"::Fulfilled, 'Fulfillment Status is mapped correctly');

        // [THEN] Lines are mapped correctly
        LibraryAssert.AreEqual(TempOrderLine.Description, SalesInvoiceLine.Description, 'Description is mapped correctly');
        LibraryAssert.AreEqual(TempOrderLine.Quantity, SalesInvoiceLine.Quantity, 'Quantity is mapped correctly');
        LibraryAssert.AreEqual(TempOrderLine."Item No.", SalesInvoiceLine."No.", 'Item No. is mapped correctly');
        LibraryAssert.AreEqual(TempOrderLine."Variant Code", SalesInvoiceLine."Variant Code", 'Variant Code is mapped correctly');
        LibraryAssert.IsFalse(TempOrderLine."Gift Card", 'Gift Card is mapped correctly');
        LibraryAssert.IsFalse(TempOrderLine.Taxable, 'Taxable is mapped correctly');
        LibraryAssert.AreEqual(TempOrderLine."Unit Price", SalesInvoiceLine."Unit Price", 'Unit Price is mapped correctly');
    end;

    [Test]
    procedure UnitTestMapZeroQuantityLine()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempOrderHeader: Record "Shpfy Order Header" temporary;
        TempOrderLine: Record "Shpfy Order Line" temporary;
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        OrderId: BigInteger;
        InvoiceNo: Code[20];
        OrderTaxLines: Dictionary of [Text, Decimal];
    begin
        // [SCENARIO] Lines with zero quantity are not mapped
        Initialize();

        // [GIVEN] Posted sales invoice with two lines, one with zero quantity
        OrderId := LibraryRandom.RandIntInRange(10000, 99999);
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, true, OrderId);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [WHEN] Map the posted invoice
        PostedInvoiceExport.MapPostedSalesInvoiceData(SalesInvoiceHeader, TempOrderHeader, TempOrderLine, OrderTaxLines);

        // [THEN] Only one line is mapped
        LibraryAssert.RecordCount(TempOrderLine, 1);
    end;

    [Test]
    procedure UnitTestExportWithoutSettingEnabled()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SyncInvoicestoShpfy: Report "Shpfy Sync Invoices to Shpfy";
        InvoiceNo: Code[20];
        PostedInvoiceSyncNotSetErr: Label 'Posted Invoice Sync is not enabled for this shop.';
        ErrorMessage: Text;
    begin
        // [SCENARIO] Sales invoice export without the setup enabled is not exported
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Posted Invoice Sync" := false;
        Shop.Modify(false);

        // [GIVEN] Posted sales invoice
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, false, 0);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [WHEN] Execute the posted sales invoice export report
        SyncInvoicestoShpfy.SetShop(Shop.Code);
        SyncInvoicestoShpfy.UseRequestPage(false);
        asserterror SyncInvoicestoShpfy.Run();
        ErrorMessage := GetLastErrorText();

        // [THEN] Posted sales invoice is not exported
        LibraryAssert.IsTrue(ErrorMessage.Contains(PostedInvoiceSyncNotSetErr), 'Posted Invoice Sync should not be executed.');
    end;

    [Test]
    procedure UnitTestExportWithoutShopifyCustomerOrCompanySet()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ShpfyCustomer: Record "Shpfy Customer";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Sales invoice export without the Shopify customer or company set.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Posted Invoice Sync" := true;
        Shop.Modify(false);

        // [GIVEN] There is no Shopify customer or company set
        ShpfyCustomer.DeleteAll(false);

        // [GIVEN] Posted sales invoice
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, false, 0);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [WHEN] Execute the posted sales invoice export
        PostedInvoiceExport.Run(SalesInvoiceHeader);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [THEN] Posted sales invoice is not exported
        LibraryAssert.AreEqual(Format(-2), Format(SalesInvoiceHeader."Shpfy Order Id"), 'Shpfy Order Id is not set correctly.');
    end;

    [Test]
    procedure UnitTestExportWithoutShopifyPaymentTerms()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PaymentTerms: Record "Shpfy Payment Terms";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Sales invoice export without the Shopify payment terms set up.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();
        Shop."Posted Invoice Sync" := true;
        Shop.Modify(false);

        // [GIVEN] Posted sales invoice
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, false, 0);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [GIVEN] Created Shopify company
        CreateShopifyCustomer(SalesInvoiceHeader."Bill-to Customer No.");

        // [GIVEN] There is no Shopify payment terms set
        PaymentTerms.DeleteAll(false);

        // [WHEN] Execute the posted sales invoice export
        PostedInvoiceExport.Run(SalesInvoiceHeader);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [THEN] Posted sales invoice is not exported
        LibraryAssert.AreEqual(Format(-2), Format(SalesInvoiceHeader."Shpfy Order Id"), 'Shpfy Order Id is not set correctly.');
    end;

    [Test]
    procedure UnitTestExportWithDefaultCustomerFromSetup()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Sales invoice export with the default customer same as the bill-to customer.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] Posted sales invoice
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, false, 0);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [GIVEN] Created Shopify company
        CreateShopifyCustomer(SalesInvoiceHeader."Bill-to Customer No.");

        // [GIVEN] Created payment terms
        CreatePrimaryPaymentTerms();

        // [GIVEN] Default customer is set to the bill-to customer
        Shop."Default Customer No." := SalesInvoiceHeader."Bill-to Customer No.";
        Shop.Modify(false);

        // [WHEN] Execute the posted sales invoice export
        PostedInvoiceExport.SetShop(Shop.Code);
        PostedInvoiceExport.Run(SalesInvoiceHeader);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [THEN] Posted sales invoice is not exported
        LibraryAssert.AreEqual(Format(-2), Format(SalesInvoiceHeader."Shpfy Order Id"), 'Shpfy Order Id is not set correctly.');
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestExportWithFractionQuantity()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Sales invoice export with fraction quantity.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] Posted sales invoice with fraction quantity
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, LibraryRandom.RandDec(5, 2), false, 0);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [GIVEN] Created Shopify company
        CreateShopifyCustomer(SalesInvoiceHeader."Bill-to Customer No.");

        // [GIVEN] Created payment terms
        CreatePrimaryPaymentTerms();

        // [WHEN] Execute the posted sales invoice export
        PostedInvoiceExport.SetShop(Shop.Code);
        PostedInvoiceExport.Run(SalesInvoiceHeader);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [THEN] Posted sales invoice is not exported
        LibraryAssert.AreEqual(Format(-2), Format(SalesInvoiceHeader."Shpfy Order Id"), 'Shpfy Order Id is not set correctly.');
    end;

    [Test]
    procedure UnitTestExportWithCustomerTemplateSet()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Sales invoice export with Shopify customer template set up.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] Posted sales invoice with fraction quantity
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, false, 0);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [GIVEN] Created Shopify company
        CreateShopifyCustomer(SalesInvoiceHeader."Bill-to Customer No.");

        // [GIVEN] Created payment terms
        CreatePrimaryPaymentTerms();

        // [GIVEN] Created Shopify customer template
        CreateCustomerTemplate(SalesInvoiceHeader."Bill-to Customer No.");

        // [WHEN] Execute the posted sales invoice export
        PostedInvoiceExport.SetShop(Shop.Code);
        PostedInvoiceExport.Run(SalesInvoiceHeader);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [THEN] Posted sales invoice is not exported
        LibraryAssert.AreEqual(Format(-2), Format(SalesInvoiceHeader."Shpfy Order Id"), 'Shpfy Order Id is not set correctly.');
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestExportWithoutCreatedDraftOrder()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoicesAPISubscriber: Codeunit "Shpfy Invoices API Subscriber";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Sales invoice export without successfuly created draft order.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] Posted sales invoice with fraction quantity
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, false, 0);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [GIVEN] Created Shopify company
        CreateShopifyCustomer(SalesInvoiceHeader."Bill-to Customer No.");

        // [GIVEN] Created payment terms
        CreatePrimaryPaymentTerms();

        // [WHEN] Execute the posted sales invoice export
        InvoicesAPISubscriber.SetFullDraftOrder(false);
        BindSubscription(InvoicesAPISubscriber);
        PostedInvoiceExport.SetShop(Shop.Code);
        PostedInvoiceExport.Run(SalesInvoiceHeader);
        SalesInvoiceHeader.Get(InvoiceNo);
        UnbindSubscription(InvoicesAPISubscriber);

        // [THEN] Posted sales invoice is not exported
        LibraryAssert.AreEqual(Format(-1), Format(SalesInvoiceHeader."Shpfy Order Id"), 'Shpfy Order Id is not set correctly.');
    end;

    [Test]
    procedure UnitTestSuccessfulSalesInvoiceExportUpdatesOrderInformation()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoicesAPISubscriber: Codeunit "Shpfy Invoices API Subscriber";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        OrderId: BigInteger;
        InvoiceNo: Code[20];
        OrderNo: Code[50];
    begin
        // [SCENARIO] Sales invoice exported successfully updates posted sales invoice with Shopify order information.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] Shopify order id and no
        OrderId := LibraryRandom.RandIntInRange(10000, 99999);
        OrderNo := LibraryRandom.RandText(10);

        // [GIVEN] Posted sales invoice with fraction quantity
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, false, 0);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [GIVEN] Created Shopify company
        CreateShopifyCustomer(SalesInvoiceHeader."Bill-to Customer No.");

        // [GIVEN] Created payment terms
        CreatePrimaryPaymentTerms();

        // [WHEN] Execute the posted sales invoice export
        InvoicesAPISubscriber.SetFullDraftOrder(true);
        InvoicesAPISubscriber.SetShopifyOrderId(OrderId);
        InvoicesAPISubscriber.SetShopifyOrderNo(OrderNo);
        BindSubscription(InvoicesAPISubscriber);
        PostedInvoiceExport.SetShop(Shop.Code);
        PostedInvoiceExport.Run(SalesInvoiceHeader);
        SalesInvoiceHeader.Get(InvoiceNo);
        UnbindSubscription(InvoicesAPISubscriber);

        // [THEN] Posted sales invoice is not exported
        LibraryAssert.AreEqual(OrderId, SalesInvoiceHeader."Shpfy Order Id", 'Shpfy Order Id is not set correctly.');
        LibraryAssert.AreEqual(OrderNo, SalesInvoiceHeader."Shpfy Order No.", 'Shpfy Order No. is not set correctly.');
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestSuccessfulSalesInvoiceExportCreatesProcessedRecord()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoiceHeader: Record "Shpfy Invoice Header";
        InvoicesAPISubscriber: Codeunit "Shpfy Invoices API Subscriber";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        OrderId: BigInteger;
        InvoiceNo: Code[20];
        OrderNo: Code[50];
    begin
        // [SCENARIO] Sales invoice exported successfully creates shopify invoice header record.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] Shopify order id and no
        OrderId := LibraryRandom.RandIntInRange(10000, 99999);
        OrderNo := LibraryRandom.RandText(10);

        // [GIVEN] Posted sales invoice with fraction quantity
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, false, 0);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [GIVEN] Created Shopify company
        CreateShopifyCustomer(SalesInvoiceHeader."Bill-to Customer No.");

        // [GIVEN] Created payment terms
        CreatePrimaryPaymentTerms();

        // [WHEN] Execute the posted sales invoice export
        InvoicesAPISubscriber.SetFullDraftOrder(true);
        InvoicesAPISubscriber.SetShopifyOrderId(OrderId);
        InvoicesAPISubscriber.SetShopifyOrderNo(OrderNo);
        BindSubscription(InvoicesAPISubscriber);
        PostedInvoiceExport.SetShop(Shop.Code);
        PostedInvoiceExport.Run(SalesInvoiceHeader);
        SalesInvoiceHeader.Get(InvoiceNo);
        UnbindSubscription(InvoicesAPISubscriber);

        // [THEN] Shopify invoice header is created
        LibraryAssert.IsTrue(InvoiceHeader.Get(SalesInvoiceHeader."Shpfy Order Id"), 'Shpfy Invoice Header is not created.');
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestSuccessfulSalesInvoiceExportCreatesDocumentLink()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocLinkToBCDoc: Record "Shpfy Doc. Link To Doc.";
        BCDocumentTypeConvert: Codeunit "Shpfy BC Document Type Convert";
        InvoicesAPISubscriber: Codeunit "Shpfy Invoices API Subscriber";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        OrderId: BigInteger;
        InvoiceNo: Code[20];
        OrderNo: Code[50];
    begin
        // [SCENARIO] Sales invoice exported successfully creates document link.
        Initialize();

        // [GIVEN] Shopify Shop
        Shop := CommunicationMgt.GetShopRecord();

        // [GIVEN] Shopify order id and no
        OrderId := LibraryRandom.RandIntInRange(10000, 99999);
        OrderNo := LibraryRandom.RandText(10);

        // [GIVEN] Posted sales invoice with fraction quantity
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, false, 0);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [GIVEN] Created Shopify company
        CreateShopifyCustomer(SalesInvoiceHeader."Bill-to Customer No.");

        // [GIVEN] Created payment terms
        CreatePrimaryPaymentTerms();

        // [WHEN] Execute the posted sales invoice export
        InvoicesAPISubscriber.SetFullDraftOrder(true);
        InvoicesAPISubscriber.SetShopifyOrderId(OrderId);
        InvoicesAPISubscriber.SetShopifyOrderNo(OrderNo);
        BindSubscription(InvoicesAPISubscriber);
        PostedInvoiceExport.SetShop(Shop.Code);
        PostedInvoiceExport.Run(SalesInvoiceHeader);
        SalesInvoiceHeader.Get(InvoiceNo);
        UnbindSubscription(InvoicesAPISubscriber);

        // [THEN] Shopify document link is created
        LibraryAssert.IsTrue(
            DocLinkToBCDoc.Get(
                "Shpfy Shop Document Type"::"Shopify Shop Order",
                SalesInvoiceHeader."Shpfy Order Id",
                BCDocumentTypeConvert.Convert(SalesInvoiceHeader),
                SalesInvoiceHeader."No."),
            'Shpfy document link is not created.'
        );
        IsInitialized := false;
    end;
    #endregion

    #region Local Procedures
    local procedure Initialize()
    var
        ShpfyCustomer: Record "Shpfy Customer";
        ShopifyCustomerTemplate: Record "Shpfy Customer Template";
        DocLinkToBCDoc: Record "Shpfy Doc. Link To Doc.";
        InvoiceHeader: Record "Shpfy Invoice Header";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        if IsInitialized then
            exit;

        Codeunit.Run(Codeunit::"Shpfy Initialize Test");

        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateCustomer(Customer);
        ShopifyCustomerTemplate.DeleteAll(false);
        InvoiceHeader.DeleteAll(false);
        DocLinkToBCDoc.DeleteAll(false);
        ShpfyCustomer.DeleteAll(false);

        IsInitialized := true;
    end;

    local procedure CreateAndPostSalesInvoice(
        Item: Record Item;
        Customer: Record Customer;
        Quantity: Decimal;
        AddComment: Boolean;
        OrderId: BigInteger
    ): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader."Shpfy Order Id" := OrderId;
        SalesHeader.Modify(false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", Quantity);
        if AddComment then begin
            LibrarySales.CreateSalesLineSimple(SalesLine, SalesHeader);
            SalesLine."Type" := SalesLine.Type::" ";
            SalesLine.Description := 'Comment';
        end;
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CopySalesDocument(var ToSalesHeader: Record "Sales Header"; DocNo: Code[20])
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
    begin
        CopyDocumentMgt.SetProperties(true, false, false, false, false, false, false);
        CopyDocumentMgt.CopySalesDoc("Sales Document Type From"::"Posted Invoice", DocNo, ToSalesHeader);
    end;

    local procedure CreateShopifyCustomer(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        ShpfyCustomer: Record "Shpfy Customer";
    begin
        Customer.Get(CustomerNo);

        if ShopifyCustomerEmpty(Customer.SystemId) then begin
            ShpfyCustomer.Init();
            ShpfyCustomer.Id := LibraryRandom.RandInt(99999);
            ShpfyCustomer."Customer SystemId" := Customer.SystemId;
            ShpfyCustomer.Insert(false);
        end;
    end;

    local procedure CreatePrimaryPaymentTerms()
    var
        PaymentTerms: Record "Shpfy Payment Terms";
    begin
        if PrimaryPaymentTermsEmpty() then begin
            PaymentTerms.Init();
            PaymentTerms."Shop Code" := Shop.Code;
            PaymentTerms.Id := LibraryRandom.RandInt(99999);
            PaymentTerms."Is Primary" := true;
            PaymentTerms.Insert(false);
        end;
    end;

    local procedure PrimaryPaymentTermsEmpty(): Boolean
    var
        PaymentTerms: Record "Shpfy Payment Terms";
    begin
        PaymentTerms.SetRange("Shop Code", Shop.Code);
        PaymentTerms.SetRange("Is Primary", true);
        exit(PaymentTerms.IsEmpty());
    end;

    local procedure ShopifyCustomerEmpty(CustomerId: Guid): Boolean
    var
        ShpfyCustomer: Record "Shpfy Customer";
    begin
        ShpfyCustomer.SetRange("Customer SystemId", CustomerId);
        exit(ShpfyCustomer.IsEmpty());
    end;

    local procedure CreateCustomerTemplate(CustomerNo: Code[20])
    var
        ShopifyCustomerTemplate: Record "Shpfy Customer Template";
        LibraryERM: Codeunit "Library - ERM";
    begin
        ShopifyCustomerTemplate.Init();
        ShopifyCustomerTemplate."Default Customer No." := CustomerNo;
        ShopifyCustomerTemplate."Shop Code" := Shop.Code;
        ShopifyCustomerTemplate."Country/Region Code" := LibraryERM.CreateCountryRegion();
        ShopifyCustomerTemplate.Insert(false);
    end;
    #endregion
}
