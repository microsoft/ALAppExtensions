codeunit 139695 "Shpfy Invoices Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        IsInitialized: Boolean;

    [Test]
    procedure UnitTestCopyInvoice()
    var
        Item: Record Item;
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        InvoiceNo: Code[20];
        OrderId: BigInteger;
    begin
        // [SCENARIO] Shopify related fields are not copied to the new invoice
        // [GIVEN] Posted sales invoice with Shopify related fields and empty invoice
        Initialize();
        OrderId := Any.IntegerInRange(10000, 99999);
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateCustomer(Customer);
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
        Item: Record Item;
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        TempOrderHeader: Record "Shpfy Order Header" temporary;
        TempOrderLine: Record "Shpfy Order Line" temporary;
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        InvoiceNo: Code[20];
        OrderId: BigInteger;
        OrderTaxLines: Dictionary of [Text, Decimal];
    begin
        // [SCENARIO] Header and lines are mapped correctly
        // [GIVEN] Posted sales invoice
        Initialize();
        OrderId := Any.IntegerInRange(10000, 99999);
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateCustomer(Customer);
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
        Item: Record Item;
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempOrderHeader: Record "Shpfy Order Header" temporary;
        TempOrderLine: Record "Shpfy Order Line" temporary;
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        InvoiceNo: Code[20];
        OrderId: BigInteger;
        OrderTaxLines: Dictionary of [Text, Decimal];
    begin
        // [SCENARIO] Lines with zero quantity are not mapped
        // [GIVEN] Posted sales invoice with two lines, one with zero quantity
        Initialize();
        OrderId := Any.IntegerInRange(10000, 99999);
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateCustomer(Customer);
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, true, OrderId);
        SalesInvoiceHeader.Get(InvoiceNo);

        // [WHEN] Map the posted invoice
        PostedInvoiceExport.MapPostedSalesInvoiceData(SalesInvoiceHeader, TempOrderHeader, TempOrderLine, OrderTaxLines);

        // [THEN] Only one line is mapped
        LibraryAssert.RecordCount(TempOrderLine, 1);
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
        IsInitialized := true;
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
    end;

    local procedure CreateAndPostSalesInvoice(Item: Record Item; Customer: Record Customer; NumberOfLines: Integer; AddComment: Boolean; OrderId: BigInteger): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader."Shpfy Order Id" := OrderId;
        SalesHeader.Modify();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", NumberOfLines);
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
}
