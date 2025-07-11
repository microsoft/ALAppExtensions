codeunit 139609 "Shpfy Order Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        isInitialized: Boolean;

    local procedure Initialize();

    begin
        if isInitialized then
            exit;
        LibraryRandom.Init();
        isInitialized := true;
    end;

    [Test]
    procedure TestSalesOrderWithShopifyOrderNo()
    var
        ShpfyOrderNo: Code[50];
    begin
        Initialize();
        ShpfyOrderNo := LibraryRandom.RandText(MaxStrLen(ShpfyOrderNo));
        Assert.AreEqual(ShpfyOrderNo, CreateSalesOrder(ShpfyOrderNo), 'Shpfy Order No. must be the same as on the order');
        ShpfyOrderNo := '';
        Assert.AreEqual(ShpfyOrderNo, CreateSalesOrder(ShpfyOrderNo), 'Shpfy Order No. must be blank');

    end;

    Local procedure CreateSalesOrder(ShpfyOrderNo: Code[50]): Code[50]
    var
        Customer: Record Customer;
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostDocumentNo: code[50];
        OrderNo: Code[50];
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesOrder(SalesHeader);
        OrderNo := SalesHeader."No.";
        LibrarySales.CreateSalesLineSimple(SalesLine, SalesHeader);
        SalesHeader."Shpfy Order No." := ShpfyOrderNo;
        PostDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesShipmentHeader.SetRange("Order No.", OrderNo);
        SalesShipmentHeader.FindFirst();
        exit(SalesShipmentHeader."Shpfy Order No.");
    end;

}
