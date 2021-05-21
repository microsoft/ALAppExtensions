codeunit 139729 "APIV1 - Purchase Invoices E2E"
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
        COMMIT();

        // [WHEN] we GET all the invoices from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Purchase Invoices", InvoiceServiceNameTxt);
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
        InvoiceWithComplexJSON: Text;
    begin
        // [SCENARIO 184721] Create unposted Purchase invoices
        // [GIVEN] A vendor
        Initialize();

        LibraryPurchase.CreateVendorWithAddress(BuyFromVendor);
        LibraryPurchase.CreateVendorWithAddress(ShipToVendor);
        VendorNo := BuyFromVendor."No.";
        InvoiceDate := WORKDATE();

        InvoiceWithComplexJSON := CreateInvoiceJSONWithAddress(BuyFromVendor, ShipToVendor, InvoiceDate);
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceWithComplexJSON, ResponseText);

        // [THEN] the response text should have the correct Id, invoice address and the invoice should exist in the table with currency code set by default
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', InvoiceNumber),
          'Could not find purchase invoice number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        PurchaseHeader.RESET();
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.SETRANGE("No.", InvoiceNumber);
        PurchaseHeader.SETRANGE("Buy-from Vendor No.", VendorNo);
        PurchaseHeader.SETRANGE("Document Date", InvoiceDate);
        PurchaseHeader.SETRANGE("Posting Date", InvoiceDate);
        Assert.IsTrue(PurchaseHeader.FINDFIRST(), 'The unposted invoice should exist');

        LibraryGraphDocumentTools.VerifyPurchaseDocumentBuyFromAddress(BuyFromVendor, PurchaseHeader, ResponseText, FALSE, FALSE);
        LibraryGraphDocumentTools.VerifyPurchaseDocumentShipToAddress(ShipToVendor, PurchaseHeader, ResponseText, FALSE, FALSE);

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
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceJSON, ResponseText);

        // [THEN] the response text should contain the invoice ID and the integration record table should map the PurchaseInvoiceId with the ID
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', InvoiceNumber),
          'Could not find Purchase invoice number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        // [THEN] the invoice should exist in the tables
        PurchaseHeader.RESET();
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.SETRANGE("No.", InvoiceNumber);
        PurchaseHeader.SETRANGE("Buy-from Vendor No.", VendorNo);
        Assert.IsTrue(PurchaseHeader.FINDFIRST(), 'The unposted invoice should exist');
        Assert.AreEqual(CurrencyCode, PurchaseHeader."Currency Code", 'The invoice should have the correct currency code');
    end;

    [Test]
    procedure TestModifyInvoices()
    begin
        TestMultipleModifyInvoices(FALSE, FALSE);
    end;

    [Test]
    procedure TestEmptyModifyInvoices()
    begin
        TestMultipleModifyInvoices(TRUE, FALSE);
    end;

    [Test]
    procedure TestPartialModifyInvoices()
    begin
        TestMultipleModifyInvoices(FALSE, TRUE);
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
        InvoiceWithComplexJSON: Text;
        BuyFromAddressComplexTypeJSON: Text;
        ShipToAddressComplexTypeJSON: Text;
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
        PurchaseHeader.RESET();
        PurchaseHeader.SETRANGE("No.", InvoiceID);
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.FINDFIRST();
        InvoiceIntegrationID := PurchaseHeader.SystemId;
        Assert.AreNotEqual('', InvoiceIntegrationID, 'ID should not be empty');

        IF EmptyData THEN
            InvoiceJSON := '{}'
        ELSE
            InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'vendorNumber', BuyFromVendor."No.");

        // [GIVEN] a JSON text with an Item that has the PostalAddress complex types
        LibraryGraphDocumentTools.GetVendorAddressComplexType(BuyFromAddressComplexTypeJSON, BuyFromVendor, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.GetVendorAddressComplexType(ShipToAddressComplexTypeJSON, ShipToVendor, EmptyData, PartiallyEmptyData);
        InvoiceWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(InvoiceJSON, 'buyFromAddress', BuyFromAddressComplexTypeJSON);
        InvoiceWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(InvoiceWithComplexJSON, 'shipToAddress', ShipToAddressComplexTypeJSON);

        COMMIT();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(InvoiceIntegrationID, PAGE::"APIV1 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceWithComplexJSON, ResponseText);

        // [THEN] the item should have the Unit of Measure as a value in the table
        PurchaseHeader.RESET();
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.SETRANGE("No.", InvoiceID);
        Assert.IsTrue(PurchaseHeader.FINDFIRST(), 'The unposted invoice should exist');

        // [THEN] the response text should contain the invoice address
        LibraryGraphDocumentTools.VerifyPurchaseDocumentBuyFromAddress(BuyFromVendor, PurchaseHeader, ResponseText, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.VerifyPurchaseDocumentShipToAddress(ShipToVendor, PurchaseHeader, ResponseText, EmptyData, PartiallyEmptyData);
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
        ModifyPurchaseHeaderPostingDate(PurchaseHeader, WORKDATE());
        InvoiceID := PurchaseHeader."No.";
        Commit();

        PurchaseHeader.RESET();
        PurchaseHeader.GET(PurchaseHeader."Document Type"::Invoice, InvoiceID);
        ID := PurchaseHeader.SystemId;
        Assert.AreNotEqual('', ID, 'ID should not be empty');

        // [WHEN] we DELETE the item from the web service, with the item's unique ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ID, PAGE::"APIV1 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the invoice shouldn't exist in the tables
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Invoice, InvoiceID) THEN
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
        InvoiceWithComplexJSON: Text;
    begin
        // [SCENARIO 184721] Create an invoice both through the client UI and through the API
        // [SCENARIO] and compare them. They should be the same and have the same fields autocompleted wherever needed.
        // [GIVEN] An unposted invoice
        Initialize();
        LibraryGraphDocumentTools.InitializeUIPage();

        LibraryPurchase.CreateVendorWithAddress(Vendor);
        VendorNo := Vendor."No.";
        InvoiceDate := WORKDATE();

        // [GIVEN] a json describing our new invoice
        InvoiceWithComplexJSON := CreateInvoiceJSONWithAddress(Vendor, Vendor, InvoiceDate);
        COMMIT();

        // [WHEN] we POST the JSON to the web service and create another invoice through the test page
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Purchase Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceWithComplexJSON, ResponseText);

        CreateInvoiceThroughTestPage(PurchaseInvoice, Vendor, InvoiceDate, InvoiceDate);

        // [THEN] the invoice should exist in the table and match the invoice created from the page
        ApiPurchaseHeader.RESET();
        ApiPurchaseHeader.SETRANGE("Buy-from Vendor No.", VendorNo);
        ApiPurchaseHeader.SETRANGE("Document Type", ApiPurchaseHeader."Document Type"::Invoice);
        ApiPurchaseHeader.SETRANGE("Document Date", InvoiceDate);
        ApiPurchaseHeader.SETRANGE("Posting Date", InvoiceDate);
        Assert.IsTrue(ApiPurchaseHeader.FINDFIRST(), 'The unposted invoice should exist');

        // Ignore these fields when comparing Page and API Invoices
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseHeader.FIELDNO("No."), DATABASE::"Purchase Header");
        LibraryUtility.AddTempField(
          TempIgnoredFieldsForComparison, ApiPurchaseHeader.FIELDNO("Posting Description"), DATABASE::"Purchase Header");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiPurchaseHeader.FIELDNO(Id), DATABASE::"Purchase Header");
        // Special ignore case for ES
        RecordField.SETRANGE(TableNo, DATABASE::"Purchase Header");
        RecordField.SETRANGE(FieldName, 'Due Date Modified');
        if RecordField.FINDFIRST() then
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, RecordField."No.", DATABASE::"Purchase Header");

        PagePurchaseHeader.GET(PagePurchaseHeader."Document Type"::Invoice, PurchaseInvoice."No.".VALUE());
        ApiRecordRef.GETTABLE(ApiPurchaseHeader);
        PageRecordRef.GETTABLE(PagePurchaseHeader);
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
        Currency.SETFILTER(Code, '<>%1', '');
        Currency.FINDFIRST();
        CurrencyCode := Currency.Code;
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON('', 'currencyCode', CurrencyCode);
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        // [THEN] an error is received
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Purchase Invoices", InvoiceServiceNameTxt);
        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, InvoiceJSON, ResponseText);
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
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Purchase Invoices", InvoiceServiceNameTxt, ActionPostTxt);
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
        LibraryPurchase.SetAllowDocumentDeletionBeforeDate(WORKDATE() + 1);
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        ModifyPurchaseHeaderPostingDate(PurchaseHeader, WORKDATE());
        InvoiceID1 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, FALSE, TRUE);

        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        ModifyPurchaseHeaderPostingDate(PurchaseHeader, WORKDATE());
        InvoiceID2 := PurchaseHeader."No.";
        COMMIT();
    end;

    local procedure CreateInvoiceJSONWithAddress(BuyFromVendor: Record "Vendor"; ShipToVendor: Record "Vendor"; InvoiceDate: Date): Text
    var
        InvoiceJSON: Text;
        BuyFromAddressComplexTypeJSON: Text;
        ShipToAddressComplexTypeJSON: Text;
        InvoiceWithComplexJSON: Text;
    begin
        InvoiceJSON := CreateInvoiceJSON('vendorId', BuyFromVendor.SystemId, 'invoiceDate', InvoiceDate);
        InvoiceWithComplexJSON := InvoiceJSON;
        LibraryGraphDocumentTools.GetVendorAddressComplexType(BuyFromAddressComplexTypeJSON, BuyFromVendor, FALSE, FALSE);
        InvoiceWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(InvoiceWithComplexJSON, 'buyFromAddress', BuyFromAddressComplexTypeJSON);
        if BuyFromVendor."No." <> ShipToVendor."No." then begin
            LibraryGraphDocumentTools.GetVendorAddressComplexType(ShipToAddressComplexTypeJSON, ShipToVendor, FALSE, FALSE);
            InvoiceWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(InvoiceWithComplexJSON, 'shipToAddress', ShipToAddressComplexTypeJSON);
        end;
        EXIT(InvoiceWithComplexJSON);
    end;

    local procedure CreateInvoiceThroughTestPage(var PurchaseInvoice: TestPage "Purchase Invoice"; Vendor: Record "Vendor"; DocumentDate: Date; PostingDate: Date)
    begin
        PurchaseInvoice.OPENNEW();
        PurchaseInvoice."Buy-from Vendor No.".SETVALUE(Vendor."No.");
        PurchaseInvoice."Document Date".SETVALUE(DocumentDate);
        PurchaseInvoice."Posting Date".SETVALUE(PostingDate);
    end;

    local procedure ModifyPurchaseHeaderPostingDate(var PurchaseHeader: Record "Purchase Header"; PostingDate: Date)
    begin
        PurchaseHeader.VALIDATE("Posting Date", PostingDate);
        PurchaseHeader.MODIFY(TRUE);
    end;

    local procedure GetCurrencyCode(): Code[10]
    var
        Currency: Record "Currency";
    begin
        Currency.SETFILTER(Code, '<>%1', '');
        IF Currency.FINDFIRST() THEN
            EXIT(Currency.Code);
    end;

    local procedure CreateInvoiceJSON(PropertyName1: Text; PropertyValue1: Variant; PropertyName2: Text; PropertyValue2: Variant): Text
    var
        InvoiceJSON: Text;
    begin
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON('', PropertyName1, PropertyValue1);
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, PropertyName2, PropertyValue2);
        EXIT(InvoiceJSON);
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
