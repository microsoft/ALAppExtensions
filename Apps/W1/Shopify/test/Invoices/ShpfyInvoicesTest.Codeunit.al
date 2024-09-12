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
        InvoiceNo := CreateAndPostSalesInvoice(Item, Customer, 1, OrderId);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");

        // [WHEN] Copy the invoice
        CopySalesDocument(SalesHeader, InvoiceNo);

        // [THEN] Shopify related fields are not copied
        LibraryAssert.IsTrue(SalesHeader."Shpfy Order Id" = 0, 'Shpfy Order Id is not copied');
    end;

    local procedure Initialize()
    begin
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

    local procedure CopySalesDocument(var ToSalesHeader: Record "Sales Header"; DocNo: Code[20])
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
    begin
        CopyDocumentMgt.SetProperties(true, false, false, false, false, false, false);
        CopyDocumentMgt.CopySalesDoc("Sales Document Type From"::"Posted Invoice", DocNo, ToSalesHeader);
    end;
}
