codeunit 139611 "Shpfy Order Refund Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";

    trigger OnRun()
    begin
        // [FEATURE] [Account Schedule] [Chart]
        IsInitialized := false;
    end;

    local procedure Initialize()
    var
        OrderRefundsHelper: Codeunit "Shpfy Order Refunds Helper";
    begin
        if IsInitialized then
            exit;

        ShopifyIds := OrderRefundsHelper.CreateShopifyDocuments();

        IsInitialized := true;
        Commit();
    end;

    local procedure ResetProccesOnRefund(ReFundId: Integer)
    var
        ShpfyDocLinkToDoc: Record "Shpfy Doc. Link To Doc.";
    begin
        ShpfyDocLinkToDoc.SetRange("Shopify Document Type", ShpfyDocLinkToDoc."Shopify Document Type"::"Shopify Shop Refund");
        ShpfyDocLinkToDoc.SetRange("Shopify Document Id", ReFundId);
        ShpfyDocLinkToDoc.DeleteAll();
    end;

    [Test]
    procedure UnitTestCreateCrMemoFromRefundWithFullyRefundedItem()
    var
        SalesHeader: Record "Sales Header";
        RefundHeader: Record "Shpfy Refund Header";
        RefundId: BigInteger;
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
        CanCreateDocument: boolean;
        ErrorInfo: ErrorInfo;
    begin
        // [SCENARION] Create a Credit Memo from a Shopify Refund where the item is totally refunded.
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        Initialize();

        // [GIVEN] Set the process of the document: "Auto Create Credit Memo";
        IReturnRefundProcess := Enum::"Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo";
        // [GIVEN] The document type Refund
        // [GIVEN] The RefundId of the refund for creating the credit Memo.
        RefundId := ShopifyIds.Get('Refund').Get(1);

        // [WHEN] Execute IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo)
        CanCreateDocument := IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo);
        // [THEN] CancreateDocument must be true
        LibraryAssert.IsTrue(CanCreateDocument, 'The result of IReturnRefundProcess.CanCreateSalesDocumentFor must be true');

        // [WHEN] Execute IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId)
        SalesHeader := IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId);
        // [THEN] SalesHeader."Document Type" = Enum::"Sales Document Type"::"Credit Memo"
        LibraryAssert.AreEqual(Enum::"Sales Document Type"::"Credit Memo", SalesHeader."Document Type", 'SalesHeader."Document Type" must be a Credit Memo');
        // [THEN] Test if SalesHeader."Amount Including VAT" is equal to RefundHeader."Total Refunded Amount"
        RefundHeader.Get(RefundId);
        SalesHeader.CalcFields("Amount Including VAT");
        LibraryAssert.AreEqual(RefundHeader."Total Refunded Amount", SalesHeader."Amount Including VAT", 'The SalesHeader."Amount Including VAT" must be equal to RefundHeader."Total Refunded Amount".');
        // Tear down
        ResetProccesOnRefund(RefundId);
    end;

    [Test]
    procedure UnitTestCreateCrMemoFromRefundForOnlyShipment()
    var
        SalesHeader: Record "Sales Header";
        RefundHeader: Record "Shpfy Refund Header";
        RefundId: BigInteger;
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
        CanCreateDocument: boolean;
        ErrorInfo: ErrorInfo;
    begin
        // [SCENARION] Create a Credit Memo from a Shopify Refund where only the shipment is refunded.
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        Initialize();

        // [GIVEN] Set the process of the document: "Auto Create Credit Memo";
        IReturnRefundProcess := Enum::"Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo";
        // [GIVEN] The document type Refund
        // [GIVEN] The RefundId of the refund for creating the credit Memo.
        RefundId := ShopifyIds.Get('Refund').Get(2);

        // [WHEN] Execute IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo)
        CanCreateDocument := IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo);
        // [THEN] CancreateDocument must be true
        LibraryAssert.IsTrue(CanCreateDocument, 'The result of IReturnRefundProcess.CanCreateSalesDocumentFor must be true');

        // [WHEN] Execute IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId)
        SalesHeader := IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId);
        // [THEN] SalesHeader."Document Type" = Enum::"Sales Document Type"::"Credit Memo"
        LibraryAssert.AreEqual(Enum::"Sales Document Type"::"Credit Memo", SalesHeader."Document Type", 'SalesHeader."Document Type" must be a Credit Memo');
        // [THEN] Test if SalesHeader."Amount Including VAT" is equal to RefundHeader."Total Refunded Amount"
        RefundHeader.Get(RefundId);
        SalesHeader.CalcFields("Amount Including VAT");
        LibraryAssert.AreNearlyEqual(RefundHeader."Total Refunded Amount", SalesHeader."Amount Including VAT", 0.5, 'The SalesHeader."Amount Including VAT" must be equal to RefundHeader."Total Refunded Amount".');
        // Tear down
        ResetProccesOnRefund(RefundId);
    end;

    [Test]
    procedure UnitTestCreateCrMemoFromRefundWithNotRefundedItem()
    var
        SalesHeader: Record "Sales Header";
        RefundHeader: Record "Shpfy Refund Header";
        RefundId: BigInteger;
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
        CanCreateDocument: boolean;
        ErrorInfo: ErrorInfo;
    begin
        // [SCENARION] Create a Credit Memo from a Shopify Refund where the item is not refunded.
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        Initialize();

        // [GIVEN] Set the process of the document: "Auto Create Credit Memo";
        IReturnRefundProcess := Enum::"Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo";
        // [GIVEN] The document type Refund
        // [GIVEN] The RefundId of the refund for creating the credit Memo.
        RefundId := ShopifyIds.Get('Refund').Get(1);

        // [WHEN] Execute IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo)
        CanCreateDocument := IReturnRefundProcess.CanCreateSalesDocumentFor(enum::"Shpfy Source Document Type"::Refund, RefundId, errorInfo);
        // [THEN] CancreateDocument must be true
        LibraryAssert.IsTrue(CanCreateDocument, 'The result of IReturnRefundProcess.CanCreateSalesDocumentFor must be true');

        // [WHEN] Execute IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId)
        SalesHeader := IReturnRefundProcess.CreateSalesDocument(Enum::"Shpfy Source Document Type"::Refund, RefundId);
        // [THEN] SalesHeader."Document Type" = Enum::"Sales Document Type"::"Credit Memo"
        LibraryAssert.AreEqual(Enum::"Sales Document Type"::"Credit Memo", SalesHeader."Document Type", 'SalesHeader."Document Type" must be a Credit Memo');
        // [THEN] Test if SalesHeader."Amount Including VAT" is equal to RefundHeader."Total Refunded Amount"
        RefundHeader.Get(RefundId);
        SalesHeader.CalcFields("Amount Including VAT");
        LibraryAssert.AreEqual(RefundHeader."Total Refunded Amount", SalesHeader."Amount Including VAT", 'The SalesHeader."Amount Including VAT" must be equal to RefundHeader."Total Refunded Amount".');

        // Tear down
        ResetProccesOnRefund(RefundId);
    end;

    var
        ShopifyIds: Dictionary of [Text, List Of [BigInteger]];
        IsInitialized: Boolean;
}