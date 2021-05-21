codeunit 139829 "APIV2 - Purchase Invoices E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Purchase] [Invoice]
    end;

    var
        TempIgnoredFieldsForComparison: Record 2000000041 temporary;
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPurchase: Codeunit "Library - Purchase";
        InvoiceServiceNameTxt: Label 'purchaseInvoices';
        ActionPostTxt: Label 'Microsoft.NAV.post', Locked = true;
        NotEmptyResponseErr: Label 'Response body should be empty.';
        CannotFindDraftInvoiceErr: Label 'Cannot find the draft invoice.';
        CannotFindPostedInvoiceErr: Label 'Cannot find the posted invoice.';
        InvoiceStatusErr: Label 'The invoice status is incorrect.';

    local procedure Initialize()
    begin
    end;

    [Test]
    procedure TestGetInvoices()
    var
        InvoiceID1: Text;
        InvoiceID2: Text;
        InvoiceJSON1: Text;
        InvoiceJSON2: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Create posted and unposted Purchase invoices and use a GET method to retrieve them
        // [GIVEN] 2 invoices, one posted and one unposted
        Initialize();
        CreatePurchaseInvoices(InvoiceID1, InvoiceID2);
        Commit();

        // [WHEN] we GET all the invoices from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 invoices should exist in the response
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'number', InvoiceID1, InvoiceID2, InvoiceJSON1, InvoiceJSON2),
          'Could not find the invoices in JSON');
        LibraryGraphMgt.VerifyIDInJson(InvoiceJSON1);
        LibraryGraphMgt.VerifyIDInJson(InvoiceJSON2);
    end;

    [Test]
    procedure TestGetInvoiceFromPostedOrderCorrectOrderIdAndNo()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        OrderId: Guid;
        OrderNo: Code[20];
        InvoiceId: Guid;
        InvoiceNo: Code[20];
        TargetURL: Text;
        ResponseText: Text;
        OrderIdValue: Text;
        OrderNoValue: Text;
    begin
        // [SCENARIO] Create a Purchase Invoice from a Purchase Order and use GET method to retrieve them and check the orderId and orderNumber
        // [GIVEN] A purchase invoice created by posting a purchase order
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        OrderId := PurchaseHeader.SystemId;
        OrderNo := PurchaseHeader."No.";
        InvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Commit();

        PurchInvHeader.SetRange("No.", InvoiceNo);
        PurchInvHeader.FindFirst();
        InvoiceId := PurchInvHeader.SystemId;

        // [WHEN] we get the invoice from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(InvoiceId, Page::"APIV2 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the orderId field exists in the response
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'orderId');

        // [THEN] The orderId and orderNumber fields correspond to the id and number of the sales order
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'orderId', OrderIdValue);
        Assert.AreEqual(OrderIdValue, Format(Lowercase(LibraryGraphMgt.StripBrackets(OrderId))), 'The order id value is wrong.');

        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'orderNumber', OrderNoValue);
        Assert.AreEqual(OrderNoValue, Format(OrderNo), 'The order number value is wrong.');
    end;

    [Test]
    procedure TestPostInvoices()
    var
        PurchaseHeader: Record "Purchase Header";
        BuyFromVendor: Record "Vendor";
        ShipToVendor: Record "Vendor";
        VendorNo: Text;
        InvoiceDate: Date;
        ResponseText: Text;
        InvoiceNumber: Text;
        TargetURL: Text;
        InvoiceJSON: Text;
    begin
        // [SCENARIO 184721] Create unposted Purchase invoices
        // [GIVEN] A vendor
        Initialize();

        LibraryPurchase.CreateVendorWithAddress(BuyFromVendor);
        LibraryPurchase.CreateVendorWithAddress(ShipToVendor);
        VendorNo := BuyFromVendor."No.";
        InvoiceDate := WorkDate();

        InvoiceJSON := CreateInvoiceJSONWithAddress(BuyFromVendor, ShipToVendor, InvoiceDate);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceJSON, ResponseText);

        // [THEN] the response text should have the correct Id, invoice address and the invoice should exist in the table with currency code set by default
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', InvoiceNumber),
          'Could not find purchase invoice number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.SetRange("No.", InvoiceNumber);
        PurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        PurchaseHeader.SetRange("Document Date", InvoiceDate);
        PurchaseHeader.SetRange("Posting Date", InvoiceDate);
        Assert.IsTrue(PurchaseHeader.FindFirst(), 'The unposted invoice should exist');

        LibraryGraphDocumentTools.CheckPurchaseDocumentBuyFromAddress(BuyFromVendor, PurchaseHeader, false, false);
        LibraryGraphDocumentTools.CheckPurchaseDocumentShipToAddress(ShipToVendor, PurchaseHeader, false, false);

        Assert.AreEqual('', PurchaseHeader."Currency Code", 'The invoice should have the LCY currency code set by default');
    end;

    [Test]
    procedure TestPostPurchaseInvoiceWithCurrency()
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record "Vendor";
        VendorNo: Text;
        ResponseText: Text;
        InvoiceNumber: Text;
        TargetURL: Text;
        InvoiceJSON: Text;
        CurrencyCode: Code[10];
    begin
        // [SCENARIO 184721] Create posted and unposted with specific currency set and use HTTP POST to create them
        Initialize();

        // [GIVEN] an Invoice with a non-LCY currencyCode set
        LibraryPurchase.CreateVendor(Vendor);
        VendorNo := Vendor."No.";

        CurrencyCode := GetCurrencyCode();
        InvoiceJSON := CreateInvoiceJSON('vendorNumber', VendorNo, 'currencyCode', CurrencyCode);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceJSON, ResponseText);

        // [THEN] the response text should contain the invoice ID and the integration record table should map the PurchaseInvoiceId with the ID
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', InvoiceNumber),
          'Could not find Purchase invoice number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        // [THEN] the invoice should exist in the tables
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.SetRange("No.", InvoiceNumber);
        PurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        Assert.IsTrue(PurchaseHeader.FindFirst(), 'The unposted invoice should exist');
        Assert.AreEqual(CurrencyCode, PurchaseHeader."Currency Code", 'The invoice should have the correct currency code');
    end;

    [Test]
    procedure TestModifyInvoices()
    begin
        TestMultipleModifyInvoices(false, false);
    end;

    [Test]
    procedure TestEmptyModifyInvoices()
    begin
        TestMultipleModifyInvoices(true, false);
    end;

    [Test]
    procedure TestPartialModifyInvoices()
    begin
        TestMultipleModifyInvoices(false, true);
    end;

    local procedure TestMultipleModifyInvoices(EmptyData: Boolean; PartiallyEmptyData: Boolean)
    var
        BuyFromVendor: Record "Vendor";
        ShipToVendor: Record "Vendor";
        PurchaseLine: Record "Purchase Line";
        Item: Record "Item";
        PurchaseHeader: Record "Purchase Header";
        InvoiceIntegrationID: Text;
        InvoiceID: Text;
        ResponseText: Text;
        TargetURL: Text;
        InvoiceJSON: Text;
    begin
        // [SCENARIO 184721] Create Purchase Invoice, use a PATCH method to change it and then verify the changes
        Initialize();
        LibraryPurchase.CreateVendorWithAddress(BuyFromVendor);
        LibraryPurchase.CreateVendorWithAddress(ShipToVendor);

        // [GIVEN] an order with the previously created vendor
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, BuyFromVendor."No.");

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [GIVEN] an line in the previously created order
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        InvoiceID := PurchaseHeader."No.";

        // [GIVEN] the invoice's unique ID
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("No.", InvoiceID);
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.FindFirst();
        InvoiceIntegrationID := PurchaseHeader.SystemId;
        Assert.AreNotEqual('', InvoiceIntegrationID, 'ID should not be empty');

        if EmptyData then
            InvoiceJSON := '{}'
        else
            InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'vendorNumber', BuyFromVendor."No.");

        // [GIVEN] a JSON text with an Item that has the PostalAddress
        LibraryGraphDocumentTools.GetVendorAddressJSON(InvoiceJSON, BuyFromVendor, 'buyFrom', EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.GetVendorAddressJSON(InvoiceJSON, ShipToVendor, 'shipTo', EmptyData, PartiallyEmptyData);

        Commit();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(InvoiceIntegrationID, Page::"APIV2 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceJSON, ResponseText);

        // [THEN] the item should have the Unit of Measure as a value in the table
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.SetRange("No.", InvoiceID);
        Assert.IsTrue(PurchaseHeader.FindFirst(), 'The unposted invoice should exist');

        // [THEN] the response text should contain the invoice address
        LibraryGraphDocumentTools.CheckPurchaseDocumentBuyFromAddress(BuyFromVendor, PurchaseHeader, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.CheckPurchaseDocumentShipToAddress(ShipToVendor, PurchaseHeader, EmptyData, PartiallyEmptyData);
    end;

    [Test]
    procedure TestDeleteInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        InvoiceID: Text;
        ID: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Createunposted Purchase invoice and use HTTP DELETE to delete it
        // [GIVEN] An unposted invoice
        Initialize();
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        ModifyPurchaseHeaderPostingDate(PurchaseHeader, WorkDate());
        InvoiceID := PurchaseHeader."No.";
        Commit();

        PurchaseHeader.Reset();
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, InvoiceID);
        ID := PurchaseHeader.SystemId;
        Assert.AreNotEqual('', ID, 'ID should not be empty');

        // [WHEN] we DELETE the item from the web service, with the item's unique ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ID, Page::"APIV2 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the invoice shouldn't exist in the tables
        if PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, InvoiceID) then
            Assert.ExpectedError('The unposted invoice should not exist');
    end;

    [Test]
    procedure TestCreateInvoiceThroughPageAndAPI()
    var
        PagePurchaseHeader: Record "Purchase Header";
        ApiPurchaseHeader: Record "Purchase Header";
        Vendor: Record "Vendor";
        RecordField: Record Field;
        ApiRecordRef: RecordRef;
        PageRecordRef: RecordRef;
        PurchaseInvoice: TestPage "Purchase Invoice";
        VendorNo: Text;
        InvoiceDate: Date;
        ResponseText: Text;
        TargetURL: Text;
        InvoiceJSON: Text;
    begin
        // [SCENARIO 184721] Create an invoice both through the client UI and through the API
        // [SCENARIO] and compare them. They should be the same and have the same fields autocompleted wherever needed.
        // [GIVEN] An unposted invoice
        Initialize();
        LibraryGraphDocumentTools.InitializeUIPage();

        LibraryPurchase.CreateVendorWithAddress(Vendor);
        VendorNo := Vendor."No.";
        InvoiceDate := WorkDate();

        // [GIVEN] a json describing our new invoice
        InvoiceJSON := CreateInvoiceJSONWithAddress(Vendor, Vendor, InvoiceDate);
        Commit();

        // [WHEN] we POST the JSON to the web service and create another invoice through the test page
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceJSON, ResponseText);

        CreateInvoiceThroughTestPage(PurchaseInvoice, Vendor, InvoiceDate, InvoiceDate);

        // [THEN] the invoice should exist in the table and match the invoice created from the page
        ApiPurchaseHeader.Reset();
        ApiPurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        ApiPurchaseHeader.SetRange("Document Type", ApiPurchaseHeader."Document Type"::Invoice);
        ApiPurchaseHeader.SetRange("Document Date", InvoiceDate);
        ApiPurchaseHeader.SetRange("Posting Date", InvoiceDate);
        Assert.IsTrue(ApiPurchaseHeader.FindFirst(), 'The unposted invoice should exist');

        // Ignore these fields when comparing Page and API Invoices
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseHeader.FieldNo("No."), Database::"Purchase Header");
        LibraryUtility.AddTempField(
          TempIgnoredFieldsForComparison, ApiPurchaseHeader.FieldNo("Posting Description"), Database::"Purchase Header");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseHeader.FieldNo(Id), Database::"Purchase Header");
        // Special ignore case for ES
        RecordField.SetRange(TableNo, Database::"Purchase Header");
        RecordField.SetRange(FieldName, 'Due Date Modified');
        if RecordField.FindFirst() then
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, RecordField."No.", Database::"Purchase Header");

        PagePurchaseHeader.Get(PagePurchaseHeader."Document Type"::Invoice, PurchaseInvoice."No.".Value());
        ApiRecordRef.GetTable(ApiPurchaseHeader);
        PageRecordRef.GetTable(PagePurchaseHeader);
        Assert.RecordsAreEqualExceptCertainFields(ApiRecordRef, PageRecordRef, TempIgnoredFieldsForComparison,
          'Page and API Invoice do not match');
    end;

    [Test]
    procedure TestPostInvoiceFailsWithoutVendorNoOrId()
    var
        Currency: Record "Currency";
        ResponseText: Text;
        TargetURL: Text;
        InvoiceJSON: Text;
        CurrencyCode: Code[10];
    begin
        // [SCENARIO 184721] Create an invoice wihtout Vendor throws an error
        Initialize();

        // [GIVEN] a purchase invoice JSON with currency only
        Currency.SetFilter(Code, '<>%1', '');
        Currency.FindFirst();
        CurrencyCode := Currency.Code;
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON('', 'currencyCode', CurrencyCode);
        Commit();

        // [WHEN] we POST the JSON to the web service
        // [THEN] an error is received
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Invoices", InvoiceServiceNameTxt);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, InvoiceJSON, ResponseText);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionPostPurchaseInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        TempPurchInvEntityAggregate: Record "Purch. Inv. Entity Aggregate" temporary;
        DraftInvoiceRecordRef: RecordRef;
        DocumentId: Guid;
        DocumentNo: Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can post a purchase invoice through the API.
        Initialize();

        // [GIVEN] Draft purchase invoice exists
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        DraftInvoiceRecordRef.GetTable(PurchaseHeader);
        DocumentId := PurchaseHeader.SystemId;
        DocumentNo := PurchaseHeader."No.";
        Commit();

        VerifyDraftPurchaseInvoice(DocumentId, TempPurchInvEntityAggregate.Status::Draft);

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, Page::"APIV2 - Purchase Invoices", InvoiceServiceNameTxt, ActionPostTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Invoice is posted
        FindPostedPurchaseInvoiceByPreAssignedNo(DocumentNo, PurchInvHeader);
        VerifyPostedPurchaseInvoice(PurchInvHeader."Draft Invoice SystemId", TempPurchInvEntityAggregate.Status::Open);
    end;

    local procedure CreatePurchaseInvoices(var InvoiceID1: Text; var InvoiceID2: Text)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryPurchase.SetAllowDocumentDeletionBeforeDate(WorkDate() + 1);
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        ModifyPurchaseHeaderPostingDate(PurchaseHeader, WorkDate());
        InvoiceID1 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        ModifyPurchaseHeaderPostingDate(PurchaseHeader, WorkDate());
        InvoiceID2 := PurchaseHeader."No.";
        Commit();
    end;

    local procedure CreateInvoiceJSONWithAddress(BuyFromVendor: Record "Vendor"; ShipToVendor: Record "Vendor"; InvoiceDate: Date): Text
    var
        InvoiceJSON: Text;
    begin
        InvoiceJSON := CreateInvoiceJSON('vendorId', BuyFromVendor.SystemId, 'invoiceDate', InvoiceDate);

        LibraryGraphDocumentTools.GetVendorAddressJSON(InvoiceJSON, BuyFromVendor, 'buyFrom', false, false);
        if BuyFromVendor."No." <> ShipToVendor."No." then
            LibraryGraphDocumentTools.GetVendorAddressJSON(InvoiceJSON, ShipToVendor, 'shipTo', false, false);

        exit(InvoiceJSON);
    end;

    local procedure CreateInvoiceThroughTestPage(var PurchaseInvoice: TestPage "Purchase Invoice"; Vendor: Record "Vendor"; DocumentDate: Date; PostingDate: Date)
    begin
        PurchaseInvoice.OpenNew();
        PurchaseInvoice."Buy-from Vendor No.".SetValue(Vendor."No.");
        PurchaseInvoice."Document Date".SetValue(DocumentDate);
        PurchaseInvoice."Posting Date".SetValue(PostingDate);
    end;

    local procedure ModifyPurchaseHeaderPostingDate(var PurchaseHeader: Record "Purchase Header"; PostingDate: Date)
    begin
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify(true);
    end;

    local procedure GetCurrencyCode(): Code[10]
    var
        Currency: Record "Currency";
    begin
        Currency.SetFilter(Code, '<>%1', '');
        if Currency.FindFirst() then
            exit(Currency.Code);
    end;

    local procedure CreateInvoiceJSON(PropertyName1: Text; PropertyValue1: Variant; PropertyName2: Text; PropertyValue2: Variant): Text
    var
        InvoiceJSON: Text;
    begin
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON('', PropertyName1, PropertyValue1);
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, PropertyName2, PropertyValue2);
        exit(InvoiceJSON);
    end;

    local procedure FindPostedPurchaseInvoiceByPreAssignedNo(PreAssignedNo: Code[20]; var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        PurchInvHeader.SetCurrentKey("Pre-Assigned No.");
        PurchInvHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        Assert.IsTrue(PurchInvHeader.FindFirst(), CannotFindPostedInvoiceErr);
    end;

    local procedure VerifyDraftPurchaseInvoice(DocumentId: Guid; Status: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvEntityAggregate: Record "Purch. Inv. Entity Aggregate";
    begin
        Assert.IsTrue(PurchaseHeader.GetBySystemId(DocumentId), CannotFindDraftInvoiceErr);

        PurchInvEntityAggregate.SetRange(Id, DocumentId);
        Assert.IsTrue(PurchInvEntityAggregate.FindFirst(), CannotFindDraftInvoiceErr);
        Assert.AreEqual(Status, PurchInvEntityAggregate.Status, InvoiceStatusErr);
    end;

    local procedure VerifyPostedPurchaseInvoice(DocumentId: Guid; Status: Integer)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvEntityAggregate: Record "Purch. Inv. Entity Aggregate";
    begin
        PurchInvHeader.SetRange("Draft Invoice SystemId", DocumentId);
        Assert.IsFalse(PurchInvHeader.IsEmpty(), CannotFindPostedInvoiceErr);

        PurchInvEntityAggregate.SetRange(Id, DocumentId);
        Assert.IsTrue(PurchInvEntityAggregate.FindFirst(), CannotFindPostedInvoiceErr);
        Assert.AreEqual(Status, PurchInvEntityAggregate.Status, InvoiceStatusErr);
    end;

}
