codeunit 139709 "Sales Invoices E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Sales] [Invoice]
    end;

    var
        TempIgnoredFieldsForComparison: Record 2000000041 temporary;
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryERM: Codeunit "Library - ERM";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        NumberFieldTxt: Label 'number';
        InvoiceServiceNameTxt: Label 'salesInvoices';
        CustomerNumberFieldTxt: Label 'customerNumber';
        CurrencyIdFieldTxt: Label 'currencyId';
        PaymentTermsIdFieldTxt: Label 'paymentTermsId';
        ShipmentMethodIdFieldTxt: Label 'shipmentMethodId';
        BlankGUID: Guid;
        DiscountAmountFieldTxt: Label 'discountAmount';
        ActionPostTxt: Label 'Microsoft.NAV.post', Locked = true;
        ActionPostAndSendTxt: Label 'Microsoft.NAV.postAndSend', Locked = true;
        ActionCancelTxt: Label 'Microsoft.NAV.cancel', Locked = true;
        ActionCancelAndSendTxt: Label 'Microsoft.NAV.cancelAndSend', Locked = true;
        ActionSendTxt: Label 'Microsoft.NAV.send', Locked = true;
        ActionMakeCorrectiveCreditMemoTxt: Label 'Microsoft.NAV.makeCorrectiveCreditMemo', Locked = true;
        InvoiceStatusErr: Label 'The invoice status is incorrect.';
        CreditMemoStatusErr: Label 'The credit memo status is incorrect.';
        NotEmptyResponseErr: Label 'Response body should be empty.';
        NotTransferredParameterErr: Label 'Email parameter %1 is not transferred.', Locked = true;
        CannotFindDraftInvoiceErr: Label 'Cannot find the draft invoice.';
        CannotFindPostedInvoiceErr: Label 'Cannot find the posted invoice.';
        CannotFindDraftCreditMemoErr: Label 'Cannot find the draft credit memo.';
        CreditMemoIdErr: Label 'The credit memo ID should differ from the invoice ID.', Locked = true;
        EmptyParameterErr: Label 'Email parameter %1 is empty.', Locked = true;
        NotEmptyParameterErr: Label 'Email parameter %1 is not empty.', Locked = true;
        MailingJobErr: Label 'The mailing job is not created.', Locked = true;

    local procedure InitializeForSending()
    var
        EmailAccount: Record "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        EmailScenario: Codeunit "Email Scenario";
    begin
        ConnectorMock.AddAccount(EmailAccount); // Create an email account
        EmailScenario.SetDefaultEmailAccount(EmailAccount); // Set the email account as default

        DeleteJobQueueEntry(CODEUNIT::"Document-Mailing");
        DeleteJobQueueEntry(CODEUNIT::"O365 Sales Cancel Invoice");
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
        // [SCENARIO 184721] Create posted and unposted Sales invoices and use a GET method to retrieve them

        // [GIVEN] 2 invoices, one posted and one unposted
        CreateSalesInvoices(InvoiceID1, InvoiceID2);
        COMMIT();

        // [WHEN] we GET all the invoices from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
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
        SalesHeader: Record "Sales Header";
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        ShipToCustomer: Record "Customer";
        CustomerNo: Text;
        InvoiceDate: Date;
        InvoicePostingDate: Date;
        ResponseText: Text;
        InvoiceNumber: Text;
        TargetURL: Text;
        InvoiceWithComplexJSON: Text;
    begin
        // [SCENARIO 184721] Create posted and unposted Sales invoices and use HTTP POST to delete them
        // [GIVEN] 2 invoices, one posted and one unposted

        LibrarySales.CreateCustomer(SellToCustomer);
        LibrarySales.CreateCustomer(BillToCustomer);
        LibrarySales.CreateCustomer(ShipToCustomer);
        CustomerNo := SellToCustomer."No.";
        InvoiceDate := WorkDate();
        InvoicePostingDate := WorkDate();

        InvoiceWithComplexJSON := CreateInvoiceJSONWithAddress(SellToCustomer, BillToCustomer, ShipToCustomer, InvoiceDate, InvoicePostingDate);
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceWithComplexJSON, ResponseText);

        // [THEN] the response text should have the correct Id, invoice address and the invoice should exist in the table with currency code set by default
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', InvoiceNumber),
          'Could not find sales invoice number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        SalesHeader.RESET();
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SETRANGE("No.", InvoiceNumber);
        SalesHeader.SETRANGE("Sell-to Customer No.", CustomerNo);
        SalesHeader.SETRANGE("Document Date", InvoiceDate);
        Assert.IsTrue(SalesHeader.FINDFIRST(), 'The unposted invoice should exist');
        Assert.AreEqual('', SalesHeader."Currency Code", 'The invoice should have the LCY currency code set by default');

        LibraryGraphDocumentTools.VerifySalesDocumentSellToAddress(SellToCustomer, SalesHeader, ResponseText, FALSE, FALSE);
        LibraryGraphDocumentTools.VerifySalesDocumentBillToAddress(BillToCustomer, SalesHeader, ResponseText, FALSE, FALSE);
        LibraryGraphDocumentTools.VerifySalesDocumentShipToAddress(ShipToCustomer, SalesHeader, ResponseText, FALSE, FALSE);
    end;

    [Test]
    procedure TestPostInvoiceWithCurrency()
    var
        SalesHeader: Record "Sales Header";
        Currency: Record "Currency";
        Customer: Record "Customer";
        CustomerNo: Text;
        ResponseText: Text;
        InvoiceNumber: Text;
        TargetURL: Text;
        InvoiceJSON: Text;
        CurrencyCode: Code[10];
    begin
        // [SCENARIO 184721] Create posted and unposted with specific currency set and use HTTP POST to create them

        // [GIVEN] an Invoice with a non-LCY currencyCode set
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";

        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON('', 'customerNumber', CustomerNo);
        Currency.SETFILTER(Code, '<>%1', '');
        Currency.FINDFIRST();
        CurrencyCode := Currency.Code;
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'currencyCode', CurrencyCode);
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceJSON, ResponseText);

        // [THEN] the response text should contain the invoice ID and the integration record table should map the SalesInvoiceId with the ID
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', InvoiceNumber),
          'Could not find sales invoice number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        // [THEN] the invoice should exist in the tables
        SalesHeader.RESET();
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SETRANGE("No.", InvoiceNumber);
        SalesHeader.SETRANGE("Sell-to Customer No.", CustomerNo);
        Assert.IsTrue(SalesHeader.FINDFIRST(), 'The unposted invoice should exist');
        Assert.AreEqual(CurrencyCode, SalesHeader."Currency Code", 'The invoice should have the correct currency code');
    end;

    [Test]
    procedure TestPostInvoiceWithEmail()
    var
        SalesHeader: Record "Sales Header";
        Currency: Record "Currency";
        Customer: Record "Customer";
        CustomerNo: Text;
        ResponseText: Text;
        InvoiceNumber: Text;
        TargetURL: Text;
        InvoiceJSON: Text;
        Email: Text;
        CurrencyCode: Code[10];
    begin
        // [SCENARIO 285872] Create posted and unposted with specific email set and use HTTP POST to create them
        Email := 'test@microsoft.com';

        // [GIVEN] an Customer with  no email set
        LibrarySales.CreateCustomer(Customer);
        Customer."E-Mail" := '';
        CustomerNo := Customer."No.";
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'customerNumber', CustomerNo);

        Currency.SETFILTER(Code, '<>%1', '');
        Currency.FINDFIRST();
        CurrencyCode := Currency.Code;
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'currencyCode', CurrencyCode);
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'email', Email);
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceJSON, ResponseText);

        // [THEN] the response text should contain the invoice ID and the integration record table should map the SalesInvoiceId with the ID
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', InvoiceNumber),
          'Could not find sales invoice number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        // [THEN] the invoice should exist in the tables
        SalesHeader.RESET();
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SETRANGE("No.", InvoiceNumber);
        SalesHeader.SETRANGE("Sell-to Customer No.", CustomerNo);
        Assert.IsTrue(SalesHeader.FINDFIRST(), 'The unposted invoice should exist');
        Assert.AreEqual(Email, SalesHeader."Sell-to E-Mail", 'The invoice should have the correct email');
    end;



    [Test]
    procedure TestPostInvoiceWithDates()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        DueDate: Date;
        PostingDate: Date;
        InvoiceDate: Date;
        CustomerNo: Text;
        ResponseText: Text;
        InvoiceNumber: Text;
        TargetURL: Text;
        InvoiceJSON: Text;
    begin
        // [SCENARIO 184721] Create unposted with specific document and due date set and use HTTP POST to create them

        // [GIVEN] an Invoice with a document and due date set
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";

        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON('', CustomerNumberFieldTxt, CustomerNo);

        InvoiceDate := WORKDATE();
        DueDate := CALCDATE('<1D>', InvoiceDate);
        PostingDate := CALCDATE('<1D>', InvoiceDate);

        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'invoiceDate', FORMAT(InvoiceDate, 0, 9));
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'dueDate', FORMAT(DueDate, 0, 9));
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'postingDate', FORMAT(PostingDate, 0, 9));
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceJSON, ResponseText);

        // [THEN] the response text should contain the invoice ID and the integration record table should map the SalesInvoiceId with the ID
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', InvoiceNumber),
          'Could not find sales invoice number');

        // [THEN] the invoice should exist in the tables
        SalesHeader.RESET();
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SETRANGE("No.", InvoiceNumber);
        SalesHeader.SETRANGE("Sell-to Customer No.", CustomerNo);
        Assert.IsTrue(SalesHeader.FINDFIRST(), 'The unposted invoice should exist');
        Assert.AreEqual(InvoiceDate, SalesHeader."Document Date", 'The invoice should have the correct document date');
        Assert.AreEqual(DueDate, SalesHeader."Due Date", 'The invoice should have the correct due date');
        Assert.AreEqual(PostingDate, SalesHeader."Posting Date", 'The invoice should have the correct posting date');
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
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        ShipToCustomer: Record "Customer";
        SalesLine: Record "Sales Line";
        Item: Record "Item";
        SalesHeader: Record "Sales Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        InvoiceIntegrationID: Text;
        InvoiceID: Text;
        ResponseText: Text;
        TargetURL: Text;
        InvoiceJSON: Text;
        InvoiceWithComplexJSON: Text;
        SellToAddressComplexTypeJSON: Text;
        ShipToAddressComplexTypeJSON: Text;
    begin
        // [SCENARIO 184721] Create Sales Invoice, use a PATCH method to change it and then verify the changes

        LibrarySales.CreateCustomerWithAddress(SellToCustomer);
        LibrarySales.CreateCustomerWithAddress(BillToCustomer);
        LibrarySales.CreateCustomerWithAddress(ShipToCustomer);

        // [GIVEN] a Sales Person purchaser
        LibrarySales.CreateSalesperson(SalespersonPurchaser);

        // [GIVEN] an order with the previously created customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, SellToCustomer."No.");

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [GIVEN] an line in the previously created order
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        InvoiceID := SalesHeader."No.";

        // [GIVEN] the invoice's unique ID
        SalesHeader.RESET();
        SalesHeader.SETRANGE("No.", InvoiceID);
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.FINDFIRST();
        InvoiceIntegrationID := SalesHeader.SystemId;
        Assert.AreNotEqual('', InvoiceIntegrationID, 'ID should not be empty');

        IF EmptyData THEN
            InvoiceJSON := '{}'
        ELSE BEGIN
            InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'salesperson', SalespersonPurchaser.Code);
            InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'customerNumber', SellToCustomer."No.");
            InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'billToCustomerNumber', BillToCustomer."No.");
        END;

        // [GIVEN] a JSON text with an Item that has the addresses complex types
        InvoiceWithComplexJSON := InvoiceJSON;
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(SellToAddressComplexTypeJSON, SellToCustomer, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(ShipToAddressComplexTypeJSON, ShipToCustomer, EmptyData, PartiallyEmptyData);
        InvoiceWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(InvoiceWithComplexJSON, 'sellingPostalAddress', SellToAddressComplexTypeJSON);
        InvoiceWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(InvoiceWithComplexJSON, 'shippingPostalAddress', ShipToAddressComplexTypeJSON);

        COMMIT();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(InvoiceIntegrationID, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceWithComplexJSON, ResponseText);

        // [THEN] the item should have the Unit of Measure as a value in the table
        SalesHeader.RESET();
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SETRANGE("No.", InvoiceID);
        Assert.IsTrue(SalesHeader.FINDFIRST(), 'The unposted invoice should exist');
        IF NOT EmptyData THEN
            Assert.AreEqual(SalesHeader."Salesperson Code", SalespersonPurchaser.Code, 'The patch of Sales Person code was unsuccessful');

        // [THEN] the response text should contain the invoice address
        LibraryGraphDocumentTools.VerifySalesDocumentSellToAddress(SellToCustomer, SalesHeader, ResponseText, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.VerifySalesDocumentBillToAddress(BillToCustomer, SalesHeader, ResponseText, EmptyData, FALSE);
        LibraryGraphDocumentTools.VerifySalesDocumentShipToAddress(ShipToCustomer, SalesHeader, ResponseText, EmptyData, PartiallyEmptyData);
    end;

    [Test]
    procedure TestModifyingWithBlankIdEmptiesTheCodeAndTheId()
    var
        Customer: Record "Customer";
        SalesHeader: Record "Sales Header";
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        Currency: Record "Currency";
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        InvoiceID: Text;
        ResponseText: Text;
        TargetURL: Text;
        InvoiceWithBlanksJSON: Text;
    begin
        // [SCENARIO 184721] Create Sales Invoice with all the Ids filled, use a PATCH method to blank the Ids and the Codes
        LibrarySales.CreateCustomerWithAddress(Customer);

        // [GIVEN] a currency
        LibraryERM.CreateCurrency(Currency);

        // [GIVEN] payment Terms
        LibraryERM.CreatePaymentTerms(PaymentTerms);

        // [GIVEN] a shipment Method
        CreateShipmentMethod(ShipmentMethod);

        // [GIVEN] an invoice with the previously created customer and extra values
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader."Currency Code" := Currency.Code;
        SalesHeader."Payment Terms Code" := PaymentTerms.Code;
        SalesHeader."Shipment Method Code" := ShipmentMethod.Code;
        SalesHeader.MODIFY();
        InvoiceID := SalesHeader.SystemId;
        COMMIT();

        // [GIVEN] that the extra values are not empty
        SalesInvoiceEntityAggregate.RESET();
        SalesInvoiceEntityAggregate.SETRANGE(Id, InvoiceID);
        Assert.IsTrue(SalesInvoiceEntityAggregate.FINDFIRST(), 'The unposted invoice should exist');
        Assert.AreNotEqual(BlankGUID, SalesInvoiceEntityAggregate."Currency Id", 'The Id of the currency should not be blank.');
        Assert.AreNotEqual('', SalesInvoiceEntityAggregate."Currency Code", 'The code of the currency should be not blank.');
        Assert.AreNotEqual(BlankGUID, SalesInvoiceEntityAggregate."Payment Terms Id", 'The Id of the payment terms should not be blank.');
        Assert.AreNotEqual('', SalesInvoiceEntityAggregate."Payment Terms Code", 'The code of the payment terms should not be blank.');
        Assert.AreNotEqual(
          BlankGUID, SalesInvoiceEntityAggregate."Shipment Method Id", 'The Id of the shipment method should not be blank.');
        Assert.AreNotEqual('', SalesInvoiceEntityAggregate."Shipment Method Code", 'The code of the shipment method should not be blank.');

        // [GIVEN] a json with blank Ids on the extra values
        InvoiceWithBlanksJSON := LibraryGraphMgt.AddPropertytoJSON('', CurrencyIdFieldTxt, BlankGUID);
        InvoiceWithBlanksJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceWithBlanksJSON, PaymentTermsIdFieldTxt, BlankGUID);
        InvoiceWithBlanksJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceWithBlanksJSON, ShipmentMethodIdFieldTxt, BlankGUID);
        COMMIT();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(InvoiceID, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceWithBlanksJSON, ResponseText);

        // [THEN] the item should have the extra values blanked
        SalesInvoiceEntityAggregate.RESET();
        SalesInvoiceEntityAggregate.SETRANGE(Id, InvoiceID);
        Assert.IsTrue(SalesInvoiceEntityAggregate.FINDFIRST(), 'The unposted invoice should exist');
        Assert.AreEqual(BlankGUID, SalesInvoiceEntityAggregate."Currency Id", 'The Id of the currency should be blanked.');
        Assert.AreEqual('', SalesInvoiceEntityAggregate."Currency Code", 'The code of the currency should be blanked.');
        Assert.AreEqual(BlankGUID, SalesInvoiceEntityAggregate."Payment Terms Id", 'The Id of the payment terms should be blanked.');
        Assert.AreEqual('', SalesInvoiceEntityAggregate."Payment Terms Code", 'The code of the payment terms should be blanked.');
        Assert.AreEqual(BlankGUID, SalesInvoiceEntityAggregate."Shipment Method Id", 'The Id of the shipment method should be blanked.');
        Assert.AreEqual('', SalesInvoiceEntityAggregate."Shipment Method Code", 'The code of the shipment method should be blanked.');
    end;

    [Test]
    procedure TestModifyInvoiceNumberForDraftInvoice()
    var
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        NewInvoiceNumber: Text;
        NewInvoiceNumberJSON: Text;
    begin
        // [SCENARIO 184721] Create draft invoice and issue a patch request to change the number

        // [GIVEN] 1 draft invoice and a json with a new number
        LibrarySales.CreateSalesInvoice(SalesHeader);
        NewInvoiceNumber := COPYSTR(CREATEGUID(), 1, MAXSTRLEN(SalesHeader."No."));
        NewInvoiceNumberJSON := LibraryGraphMgt.AddPropertytoJSON('', NumberFieldTxt, NewInvoiceNumber);
        COMMIT();

        // [WHEN] we PATCH the JSON to the web service, with the new number we should get an error
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, NewInvoiceNumberJSON, ResponseText);
        Assert.AreNotEqual(0, STRPOS(GETLASTERRORTEXT(), 'read-only'), 'The string "read-only" should exist in the error message');
    end;

    [Test]
    procedure TestDeleteInvoice()
    var
        SalesHeader: Record "Sales Header";
        InvoiceID: Text;
        ID: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Create unposted Sales invoice and use HTTP DELETE to delete it

        // [GIVEN] An unposted invoice
        CreateDraftSalesInvoice(SalesHeader);
        InvoiceID := SalesHeader."No.";
        Commit();

        SalesHeader.RESET();
        SalesHeader.GET(SalesHeader."Document Type"::Invoice, InvoiceID);
        ID := SalesHeader.SystemId;
        Assert.AreNotEqual('', ID, 'ID should not be empty');

        // [WHEN] we DELETE the item from the web service, with the item's unique ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ID, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the invoice shouldn't exist in the tables
        IF SalesHeader.GET(SalesHeader."Document Type"::Invoice, InvoiceID) THEN
            Assert.ExpectedError('The unposted invoice should not exist');
    end;

    [Test]
    procedure TestCreateInvoiceThroughPageAndAPI()
    var
        PageSalesHeader: Record "Sales Header";
        ApiSalesHeader: Record "Sales Header";
        RecordField: Record Field;
        Customer: Record "Customer";
        ApiRecordRef: RecordRef;
        PageRecordRef: RecordRef;
        SalesInvoice: TestPage "Sales Invoice";
        CustomerNo: Text;
        InvoiceDate: Date;
        InvoicePostingDate: Date;
        ResponseText: Text;
        TargetURL: Text;
        InvoiceWithComplexJSON: Text;
    begin
        // [SCENARIO 184721] Create an invoice both through the client UI and through the API
        // [SCENARIO] and compare them. They should be the same and have the same fields autocompleted wherever needed.

        // [GIVEN] An unposted invoice
        LibraryGraphDocumentTools.InitializeUIPage();
        LibraryApplicationArea.DisableApplicationAreaSetup();

        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";
        InvoiceDate := WorkDate();
        InvoicePostingDate := WorkDate();

        // [GIVEN] a json describing our new invoice
        InvoiceWithComplexJSON := CreateInvoiceJSONWithAddress(Customer, Customer, Customer, InvoiceDate, InvoicePostingDate);
        COMMIT();

        // [WHEN] we POST the JSON to the web service and create another invoice through the test page
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceWithComplexJSON, ResponseText);

        CreateInvoiceThroughTestPage(SalesInvoice, Customer, InvoiceDate);

        // [THEN] the invoice should exist in the table and match the invoice created from the page
        ApiSalesHeader.RESET();
        ApiSalesHeader.SETRANGE("Sell-to Customer No.", CustomerNo);
        ApiSalesHeader.SETRANGE("Document Type", ApiSalesHeader."Document Type"::Invoice);
        ApiSalesHeader.SETRANGE("Document Date", InvoiceDate);
        Assert.IsTrue(ApiSalesHeader.FINDFIRST(), 'The unposted invoice should exist');

        // Ignore these fields when comparing Page and API Invoices
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("No."), DATABASE::"Sales Header");
        LibraryUtility.AddTempField(
          TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Posting Description"), DATABASE::"Sales Header");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Order Date"), DATABASE::"Sales Header");    // it is always set as Today() in API
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Shipment Date"), DATABASE::"Sales Header"); // it is always set as Today() in API
        // Special ignore case for ES
        RecordField.SETRANGE(TableNo, DATABASE::"Sales Header");
        RecordField.SETRANGE(FieldName, 'Due Date Modified');
        if RecordField.FINDFIRST() then
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, RecordField."No.", DATABASE::"Sales Header");

        // Time zone will impact how the date from the page vs WebService is saved. If removed this will fail in snap between 12:00 - 1 AM
        IF TIME() < 020000T THEN
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Posting Date"), DATABASE::"Sales Header");

        PageSalesHeader.GET(PageSalesHeader."Document Type"::Invoice, SalesInvoice."No.".VALUE());
        ApiRecordRef.GETTABLE(ApiSalesHeader);
        PageRecordRef.GETTABLE(PageSalesHeader);
        Assert.RecordsAreEqualExceptCertainFields(ApiRecordRef, PageRecordRef, TempIgnoredFieldsForComparison,
          'Page and API Invoice do not match');

        // tear down
        LibraryApplicationArea.EnableEssentialSetup();
    end;

    [Test]
    procedure TestGetInvoicesAppliesDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        DiscountPct: Decimal;
    begin
        // [SCENARIO 184721] When an invoice is created,the GET Method should update the invoice and assign a total

        // [GIVEN] 2 invoices, one posted and one unposted without totals assigned
        LibraryGraphDocumentTools.CreateDocumentWithDiscountPctPending(
          SalesHeader, DiscountPct, SalesHeader."Document Type"::Invoice);
        SalesHeader.CALCFIELDS("Recalculate Invoice Disc.");
        Assert.IsTrue(SalesHeader."Recalculate Invoice Disc.", 'Setup error - recalculate invoice disc. should be set');

        COMMIT();

        // [WHEN] we GET all the invoices from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 1 invoice should exist in the response and Invoice Discount Should be Applied
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        LibraryGraphDocumentTools.VerifySalesTotals(
          SalesHeader, ResponseText, DiscountPct, SalesHeader."Invoice Discount Calculation"::"%");
        VerifyGettingAgainKeepsETag(ResponseText, TargetURL);
    end;

    [Test]
    procedure TestGetInvoicesRedistributesDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        ResponseText: Text;
        TargetURL: Text;
        DiscountPct: Decimal;
        DiscountAmt, InvDiscAmount : Decimal;
    begin
        // [SCENARIO 184721] When an invoice is created, the GET Method should update the invoice and assign a total

        // [GIVEN] 2 invoices, one posted and one unposted with discount amount that should be redistributed
        LibraryGraphDocumentTools.CreateDocumentWithDiscountPctPending(
          SalesHeader, DiscountPct, SalesHeader."Document Type"::Invoice);
        SalesHeader.CALCFIELDS(Amount);
        DiscountAmt := LibraryRandom.RandDecInRange(1, ROUND(SalesHeader.Amount / 2, 1), 1);
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(DiscountAmt, SalesHeader);
        GetFirstSalesInvoiceLine(SalesHeader, SalesLine);
        InvDiscAmount := SalesLine."Inv. Discount Amount";
        SalesLine.VALIDATE(Quantity, SalesLine.Quantity + 1);
        SalesLine.MODIFY(TRUE);
        SalesHeader.CALCFIELDS("Recalculate Invoice Disc.");
        Assert.IsTrue(SalesHeader."Recalculate Invoice Disc.", 'Setup error - recalculate invoice disc. should be set');
        COMMIT();

        // [WHEN] we GET all the invoices from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the invoice should exist in the response and Invoice Discount Should be Applied
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        LibraryGraphDocumentTools.VerifySalesTotals(
          SalesHeader, ResponseText, DiscountAmt - InvDiscAmount, SalesHeader."Invoice Discount Calculation"::Amount);
        VerifyGettingAgainKeepsETag(ResponseText, TargetURL);
    end;

    [Test]
    procedure TestPostInvoiceFailsWithoutCustomerNoOrId()
    var
        Currency: Record "Currency";
        ResponseText: Text;
        TargetURL: Text;
        InvoiceJSON: Text;
        CurrencyCode: Code[10];
    begin
        // [SCENARIO 184721] Create an invoice wihtout Customer throws an error

        // [GIVEN] a sales invoice JSON with currency only
        Currency.SETFILTER(Code, '<>%1', '');
        Currency.FINDFIRST();
        CurrencyCode := Currency.Code;
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON('', 'currencyCode', CurrencyCode);
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        // [THEN] an error is received
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, InvoiceJSON, ResponseText);
    end;

    [Test]
    procedure TestModifyInvoiceSetManualDiscount()
    var
        Customer: Record "Customer";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record "Item";
        InvoiceDiscountAmount: Decimal;
        TargetURL: Text;
        InvoiceJSON: Text;
        ResponseText: Text;
        InvoiceID: Text;
    begin
        // [SCENARIO 184721] Create Sales Invoice, use a PATCH method to change it and then verify the changes
        LibrarySales.CreateCustomerWithAddress(Customer);

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [GIVEN] an order with the previously created customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");

        // [GIVEN] an line in the previously created order
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        SalesHeader.FIND();
        SalesHeader.CALCFIELDS(Amount);
        InvoiceID := SalesHeader."No.";
        InvoiceDiscountAmount := Round(SalesHeader.Amount / 2, LibraryERM.GetCurrencyAmountRoundingPrecision(SalesHeader."Currency Code"), '=');
        COMMIT();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        InvoiceJSON := STRSUBSTNO('{"%1": %2}', DiscountAmountFieldTxt, FORMAT(InvoiceDiscountAmount, 0, 9));
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceJSON, ResponseText);

        // [THEN] Response contains the updated value
        VerifyValidPostRequest(ResponseText, InvoiceID);
        LibraryGraphDocumentTools.VerifyValidDiscountAmount(ResponseText, InvoiceDiscountAmount);

        // [THEN] Header value was updated
        SalesHeader.FIND();
        SalesHeader.CALCFIELDS("Invoice Discount Amount");
        Assert.AreEqual(InvoiceDiscountAmount, SalesHeader."Invoice Discount Amount", 'Invoice discount Amount was not set');
    end;

    [Test]
    procedure TestClearingManualDiscounts()
    var
        Customer: Record "Customer";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record "Item";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        TargetURL: Text;
        InvoiceJSON: Text;
        ResponseText: Text;
        InvoiceID: Text;
    begin
        // [SCENARIO 184721] Clearing manually set discount

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [Given] a customer
        LibrarySales.CreateCustomerWithAddress(Customer);

        // [GIVEN] an order with the previously created customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");

        // [GIVEN] an line in the previously created order
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        SalesHeader.FIND();
        InvoiceID := SalesHeader."No.";
        SalesHeader.CALCFIELDS(Amount);

        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(SalesHeader.Amount / 2, SalesHeader);

        COMMIT();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt);
        InvoiceJSON := STRSUBSTNO('{"%1": %2}', DiscountAmountFieldTxt, FORMAT(0, 0, 9));
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceJSON, ResponseText);

        // [THEN] Discount should be removed
        VerifyValidPostRequest(ResponseText, InvoiceID);
        LibraryGraphDocumentTools.VerifyValidDiscountAmount(ResponseText, 0);

        // [THEN] Header value was updated
        SalesHeader.SETAUTOCALCFIELDS("Invoice Discount Amount");
        SalesHeader.FIND();
        Assert.AreEqual(0, SalesHeader."Invoice Discount Amount", 'Invoice discount Amount was not set');
        SalesHeader.NEXT();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionPostInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate" temporary;
        DraftInvoiceRecordRef: RecordRef;
        PostedInvoiceRecordRef: RecordRef;
        DocumentId: Guid;
        DocumentNo: Code[20];
        ResponseText: Text;
        TargetURL: Text;
        DraftInvoiceEmailAddress: Text;
        DraftInvoiceEmailSubject: Text;
        PostedInvoiceEmailAddress: Text;
        PostedInvoiceEmailSubject: Text;
    begin
        // [SCENARIO] User can post a sales invoice through the API.

        // [GIVEN] Draft sales invoice exists
        CreateDraftSalesInvoice(SalesHeader);
        DraftInvoiceRecordRef.GetTable(SalesHeader);
        CreateEmailParameters(DraftInvoiceRecordRef);
        GetEmailParameters(DraftInvoiceRecordRef, DraftInvoiceEmailAddress, DraftInvoiceEmailSubject);
        DocumentId := SalesHeader.SystemId;
        DocumentNo := SalesHeader."No.";
        Commit();
        Assert.IsTrue(DraftInvoiceEmailAddress <> '', StrSubstNo(EmptyParameterErr, 'Address'));
        Assert.IsTrue(DraftInvoiceEmailSubject <> '', StrSubstNo(EmptyParameterErr, 'Subject'));

        VerifyDraftSalesInvoice(DocumentId, TempSalesInvoiceEntityAggregate.Status::Draft.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt, ActionPostTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Invoice is posted
        FindPostedInvoiceByPreAssignedNo(DocumentNo, SalesInvoiceHeader);
        VerifyPostedSalesInvoice(SalesInvoiceHeader."Draft Invoice SystemId", TempSalesInvoiceEntityAggregate.Status::Open.AsInteger());

        // [THEN] Email parameters are transferred from the draft invoice to the posted invoice
        PostedInvoiceRecordRef.GetTable(SalesInvoiceHeader);
        GetEmailParameters(PostedInvoiceRecordRef, PostedInvoiceEmailAddress, PostedInvoiceEmailSubject);
        Assert.AreEqual(DraftInvoiceEmailAddress, PostedInvoiceEmailAddress, StrSubstNo(NotTransferredParameterErr, 'Address'));
        Assert.AreEqual(DraftInvoiceEmailSubject, PostedInvoiceEmailSubject, StrSubstNo(NotTransferredParameterErr, 'Subject'));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionPostAndSendInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate" temporary;
        DocumentId: Guid;
        DocumentNo: Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can post and send a sales invoice through the API.
        InitializeForSending();

        // [GIVEN] Draft sales invoice exists
        CreateDraftSalesInvoice(SalesHeader);
        SetCustomerEmail(SalesHeader."Sell-to Customer No.");
        DocumentNo := SalesHeader."No.";
        DocumentId := SalesHeader.SystemId;
        Commit();
        VerifyDraftSalesInvoice(DocumentId, TempSalesInvoiceEntityAggregate.Status::Draft.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            DocumentId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt, ActionPostAndSendTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Invoice is posted
        FindPostedInvoiceByPreAssignedNo(DocumentNo, SalesInvoiceHeader);
        VerifyPostedSalesInvoice(SalesInvoiceHeader."Draft Invoice SystemId", TempSalesInvoiceEntityAggregate.Status::Open.AsInteger());

        // [THEN] Mailing job is created
        CheckJobQueueEntry(CODEUNIT::"Document-Mailing");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionCancelInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can cancel a posted sales invoice through API.

        // [GIVEN] Posted sales invoice exists
        CreatePostedSalesInvoice(SalesInvoiceHeader);
        SetCustomerEmail(SalesInvoiceHeader."Sell-to Customer No.");
        DocumentId := SalesInvoiceHeader."Draft Invoice SystemId";

        // Special case for AU
        LibrarySales.SetDefaultCancelReasonCodeForSalesAndReceivablesSetup();

        Commit();
        VerifyPostedSalesInvoice(DocumentId, TempSalesInvoiceEntityAggregate.Status::Open.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            DocumentId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt, ActionCancelTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Invoice is cancelled
        VerifyPostedSalesInvoice(DocumentId, TempSalesInvoiceEntityAggregate.Status::Canceled.AsInteger());
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionCancelAndSendInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can cancel a posted sales invoice through API.
        InitializeForSending();

        // [GIVEN] Posted sales invoice exists
        CreatePostedSalesInvoice(SalesInvoiceHeader);
        SetCustomerEmail(SalesInvoiceHeader."Sell-to Customer No.");
        DocumentId := SalesInvoiceHeader."Draft Invoice SystemId";

        // Special case for AU
        LibrarySales.SetDefaultCancelReasonCodeForSalesAndReceivablesSetup();

        Commit();
        VerifyPostedSalesInvoice(DocumentId, TempSalesInvoiceEntityAggregate.Status::Open.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            DocumentId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt, ActionCancelAndSendTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Invoice is cancelled
        VerifyPostedSalesInvoice(DocumentId, TempSalesInvoiceEntityAggregate.Status::Canceled.AsInteger());

        // [THEN] Mailing job is created
        CheckJobQueueEntry(CODEUNIT::"O365 Sales Cancel Invoice");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionSendPostedInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can send a posted sales invoice through the API.
        InitializeForSending();

        // [GIVEN] Posted sales invoice exists
        CreatePostedSalesInvoice(SalesInvoiceHeader);
        SetCustomerEmail(SalesInvoiceHeader."Sell-to Customer No.");
        DocumentId := SalesInvoiceHeader."Draft Invoice SystemId";
        Commit();
        VerifyPostedSalesInvoice(DocumentId, TempSalesInvoiceEntityAggregate.Status::Open.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt, ActionSendTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Mailing job is created
        CheckJobQueueEntry(CODEUNIT::"Document-Mailing");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionSendDraftInvoice()
    var
        SalesHeader: Record "Sales Header";
        TempSalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can send a draft sales invoice through the API.
        InitializeForSending();

        // [GIVEN] Draft sales invoice exists
        CreateDraftSalesInvoice(SalesHeader);
        SetCustomerEmail(SalesHeader."Sell-to Customer No.");
        DocumentId := SalesHeader.SystemId;
        Commit();
        VerifyDraftSalesInvoice(DocumentId, TempSalesInvoiceEntityAggregate.Status::Draft.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt, ActionSendTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Mailing job is created
        CheckJobQueueEntry(CODEUNIT::"Document-Mailing");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionSendCancelledInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can send a draft sales invoice through the API.
        InitializeForSending();

        // [GIVEN] Cancelled sales invoice exists
        CreateCancelledSalesInvoice(SalesInvoiceHeader);
        SetCustomerEmail(SalesInvoiceHeader."Sell-to Customer No.");
        DocumentId := SalesInvoiceHeader."Draft Invoice SystemId";
        Commit();
        VerifyPostedSalesInvoice(DocumentId, TempSalesInvoiceEntityAggregate.Status::Canceled.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt, ActionSendTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Mailing job is created
        CheckJobQueueEntry(CODEUNIT::"O365 Sales Cancel Invoice");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionMakeCorrectiveCreditMemo()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate" temporary;
        TempSalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer" temporary;
        PostedInvoiceRecordRef: RecordRef;
        DraftCreditMemoRecordRef: RecordRef;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
        InvoiceEmailAddress: Text;
        InvoiceEmailSubject: Text;
        CreditMemoEmailAddress: Text;
        CreditMemoEmailSubject: Text;
    begin
        // [SCENARIO] User can create a corrective credit memo for the posted sales invoice through the API.

        // [GIVEN] A posted sales invoice exists
        CreatePostedSalesInvoice(SalesInvoiceHeader);
        PostedInvoiceRecordRef.GetTable(SalesInvoiceHeader);
        CreateEmailParameters(PostedInvoiceRecordRef);
        GetEmailParameters(PostedInvoiceRecordRef, InvoiceEmailAddress, InvoiceEmailSubject);
        DocumentId := SalesInvoiceHeader."Draft Invoice SystemId";
        Commit();
        Assert.IsTrue(InvoiceEmailAddress <> '', StrSubstNo(EmptyParameterErr, 'Address'));
        Assert.IsTrue(InvoiceEmailSubject <> '', StrSubstNo(EmptyParameterErr, 'Subject'));
        VerifyPostedSalesInvoice(DocumentId, TempSalesInvoiceEntityAggregate.Status::Open.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt, ActionMakeCorrectiveCreditMemoTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Credit memo is created
        SalesHeader.SetRange("Applies-to Doc. No.", SalesInvoiceHeader."No.");
        Assert.IsTrue(SalesHeader.FindFirst(), CannotFindDraftCreditMemoErr);
        Assert.AreNotEqual(DocumentId, SalesHeader.SystemId, CreditMemoIdErr);
        VerifyDraftSalesCreditMemo(SalesHeader.SystemId, TempSalesCrMemoEntityBuffer.Status::Draft.AsInteger());

        // [THEN] Email parameters are not transferred
        DraftCreditMemoRecordRef.GetTable(SalesHeader);
        GetEmailParameters(DraftCreditMemoRecordRef, InvoiceEmailAddress, InvoiceEmailSubject);
        Assert.AreEqual('', CreditMemoEmailAddress, StrSubstNo(NotEmptyParameterErr, 'Address'));
        Assert.AreEqual('', CreditMemoEmailSubject, StrSubstNo(NotEmptyParameterErr, 'Subject'));
    end;

    local procedure CreateEmailParameters(var RecordRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
        EmailParameter: Record "Email Parameter";
        Number: Code[20];
    begin
        Number := GetInvoiceNumber(RecordRef);
        EmailParameter.SaveParameterValue(
            Number, SalesHeader."Document Type"::Invoice.AsInteger(),
            EmailParameter."Parameter Type"::Address.AsInteger(),
            StrSubstNo('%1@home.local', CopyStr(CreateGuid(), 2, 8)));
        EmailParameter.SaveParameterValue(
            Number, SalesHeader."Document Type"::Invoice.AsInteger(),
            EmailParameter."Parameter Type"::Subject.AsInteger(), Format(CreateGuid()));
    end;

    local procedure GetEmailParameters(var RecordRef: RecordRef; var Email: Text; var Subject: Text)
    var
        SalesHeader: Record "Sales Header";
        EmailParameter: Record "Email Parameter";
        Number: Code[20];
    begin
        Email := '';
        Subject := '';
        Number := GetInvoiceNumber(RecordRef);
        if EmailParameter.GetEntryWithReportUsage(
                Number, SalesHeader."Document Type"::Invoice.AsInteger(), EmailParameter."Parameter Type"::Address.AsInteger())
        then
            Email := EmailParameter.GetParameterValue();
        if EmailParameter.GetEntryWithReportUsage(
                Number, SalesHeader."Document Type"::Invoice.AsInteger(), EmailParameter."Parameter Type"::Subject.AsInteger())
        then
            Subject := EmailParameter.GetParameterValue();
    end;

    local procedure GetInvoiceNumber(var RecordRef: RecordRef): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if RecordRef.Number() = DATABASE::"Sales Invoice Header" then begin
            RecordRef.SetTable(SalesInvoiceHeader);
            exit(SalesInvoiceHeader."No.");
        end;

        RecordRef.SetTable(SalesHeader);
        exit(SalesHeader."No.");
    end;

    local procedure SetCustomerEmail(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        Customer."E-Mail" := 'somebody@somewhere.com';
        Customer.Modify(true);
    end;

    local procedure FindPostedInvoiceByPreAssignedNo(PreAssignedNo: Code[20]; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader.SetCurrentKey("Pre-Assigned No.");
        SalesInvoiceHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        Assert.IsTrue(SalesInvoiceHeader.FindFirst(), CannotFindPostedInvoiceErr);
    end;

    local procedure GetJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"; CodeunitID: Integer): Boolean
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitID);
        exit(JobQueueEntry.FindFirst());
    end;

    local procedure CheckJobQueueEntry(CodeunitID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not GetJobQueueEntry(JobQueueEntry, CodeunitID) then
            Error(MailingJobErr);
        JobQueueEntry.Cancel();
    end;

    local procedure DeleteJobQueueEntry(CodeunitID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        while JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CodeunitID) do
            JobQueueEntry.Cancel();
    end;

    local procedure VerifyDraftSalesInvoice(DocumentId: Guid; Status: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        Assert.IsTrue(SalesHeader.GetBySystemId(DocumentId), CannotFindDraftInvoiceErr);

        SalesInvoiceEntityAggregate.SetRange(Id, DocumentId);
        Assert.IsTrue(SalesInvoiceEntityAggregate.FindFirst(), CannotFindDraftInvoiceErr);
        Assert.AreEqual(Status, SalesInvoiceEntityAggregate.Status, InvoiceStatusErr);
    end;

    local procedure VerifyPostedSalesInvoice(DocumentId: Guid; Status: Integer)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        SalesInvoiceHeader.SetRange("Draft Invoice SystemId", DocumentId);
        Assert.IsFalse(SalesInvoiceHeader.IsEmpty(), CannotFindPostedInvoiceErr);

        SalesInvoiceEntityAggregate.SetRange(Id, DocumentId);
        Assert.IsTrue(SalesInvoiceEntityAggregate.FindFirst(), CannotFindPostedInvoiceErr);
        Assert.AreEqual(Status, SalesInvoiceEntityAggregate.Status, InvoiceStatusErr);
    end;

    local procedure VerifyDraftSalesCreditMemo(DocumentId: Guid; Status: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";
    begin
        Assert.IsTrue(SalesHeader.GetBySystemId(DocumentId), CannotFindDraftCreditMemoErr);

        SalesCrMemoEntityBuffer.SetRange(Id, DocumentId);
        Assert.IsTrue(SalesCrMemoEntityBuffer.FindFirst(), CannotFindDraftCreditMemoErr);
        Assert.AreEqual(Status, SalesCrMemoEntityBuffer.Status, CreditMemoStatusErr);
    end;


    local procedure CreateDraftSalesInvoice(var SalesHeader: Record "Sales Header")
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        ModifySalesHeaderPostingDate(SalesHeader, WORKDATE());
    end;

    local procedure CreatePostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesHeader: Record "Sales Header";
        InvoiceCode: Code[20];
    begin
        CreateDraftSalesInvoice(SalesHeader);
        InvoiceCode := LibrarySales.PostSalesDocument(SalesHeader, false, true);
        SalesInvoiceHeader.Get(InvoiceCode);
    end;

    local procedure CreateCancelledSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        CreatePostedSalesInvoice(SalesInvoiceHeader);
        CODEUNIT.Run(CODEUNIT::"Correct Posted Sales Invoice", SalesInvoiceHeader);
    end;

    local procedure CreateSalesInvoices(var InvoiceID1: Text; var InvoiceID2: Text)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.SetAllowDocumentDeletionBeforeDate(WORKDATE() + 1);
        CreatePostedSalesInvoice(SalesInvoiceHeader);
        CreateDraftSalesInvoice(SalesHeader);
        InvoiceID1 := SalesInvoiceHeader."No.";
        InvoiceID2 := SalesHeader."No.";
        COMMIT();
    end;

    local procedure CreateInvoiceJSONWithAddress(SellToCustomer: Record "Customer"; BillToCustomer: Record "Customer"; ShipToCustomer: Record "Customer"; InvoiceDate: Date; InvoicePostingDate: Date): Text
    var
        InvoiceJSON: Text;
        SellToAddressComplexTypeJSON: Text;
        ShipToAddressComplexTypeJSON: Text;
        InvoiceWithComplexJSON: Text;
    begin
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON('', 'customerNumber', SellToCustomer."No.");
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'invoiceDate', InvoiceDate);
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'postingDate', InvoicePostingDate);
        InvoiceJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceJSON, 'billToCustomerNumber', BillToCustomer."No.");

        InvoiceWithComplexJSON := InvoiceJSON;
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(SellToAddressComplexTypeJSON, SellToCustomer, FALSE, FALSE);
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(ShipToAddressComplexTypeJSON, ShipToCustomer, FALSE, FALSE);
        InvoiceWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(InvoiceWithComplexJSON, 'sellingPostalAddress', SellToAddressComplexTypeJSON);
        InvoiceWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(InvoiceWithComplexJSON, 'shippingPostalAddress', ShipToAddressComplexTypeJSON);
        EXIT(InvoiceWithComplexJSON);
    end;

    local procedure CreateInvoiceThroughTestPage(var SalesInvoice: TestPage "Sales Invoice"; Customer: Record "Customer"; InvoiceDate: Date)
    begin
        SalesInvoice.OPENNEW();
        SalesInvoice."Sell-to Customer No.".SETVALUE(Customer."No.");
        SalesInvoice."Document Date".SETVALUE(InvoiceDate);
    end;

    local procedure CreateShipmentMethod(var ShipmentMethod: Record "Shipment Method")
    begin
        WITH ShipmentMethod DO BEGIN
            INIT();
            Code := LibraryUtility.GenerateRandomCode(FIELDNO(Code), DATABASE::"Shipment Method");
            Description := Code;
            INSERT(TRUE);
        END;
    end;

    local procedure VerifyGettingAgainKeepsETag(JSONText: Text; TargetURL: Text)
    var
        ETag: Text;
        NewResponseText: Text;
        NewETag: Text;
    begin
        Assert.IsTrue(LibraryGraphMgt.GetETagFromJSON(JSONText, ETag), 'Could not get etag');
        LibraryGraphMgt.GetFromWebService(NewResponseText, TargetURL);
        Assert.IsTrue(LibraryGraphMgt.GetETagFromJSON(NewResponseText, NewETag), 'Could not get ETag from new request');
        Assert.AreEqual(ETag, NewETag, 'Getting twice should not change ETags');
    end;

    local procedure GetFirstSalesInvoiceLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.RESET();
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.FINDFIRST();
    end;

    local procedure ModifySalesHeaderPostingDate(var SalesHeader: Record "Sales Header"; PostingDate: Date)
    begin
        SalesHeader.VALIDATE("Posting Date", PostingDate);
        SalesHeader.MODIFY(TRUE);
    end;

    local procedure VerifyValidPostRequest(ResponseText: Text; var InvoiceNumber: Text)
    begin
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', InvoiceNumber),
          'Could not find sales invoice number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
    end;
}
