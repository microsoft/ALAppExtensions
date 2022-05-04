codeunit 139728 "APIV1 - Sales Credit Memos E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Sales] [Credit Memo]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryERM: Codeunit "Library - ERM";
        CreditMemoServiceNameTxt: Label 'salesCreditMemos';
        DiscountAmountFieldTxt: Label 'discountAmount';
        ActionPostTxt: Label 'Microsoft.NAV.post', Locked = true;
        ActionPostAndSendTxt: Label 'Microsoft.NAV.postAndSend', Locked = true;
        ActionCancelTxt: Label 'Microsoft.NAV.cancel', Locked = true;
        ActionCancelAndSendTxt: Label 'Microsoft.NAV.cancelAndSend', Locked = true;
        ActionSendTxt: Label 'Microsoft.NAV.send', Locked = true;
        NotEmptyResponseErr: Label 'Response body should be empty.';
        CannotFindDraftCreditMemoErr: Label 'Cannot find the draft credit memo.';
        CannotFindPostedCreditMemoErr: Label 'Cannot find the posted credit memo.';
        EmptyParameterErr: Label 'Email parameter %1 is empty.', Locked = true;
        NotTransferredParameterErr: Label 'Email parameter %1 is not transferred.', Locked = true;
        CreditMemoStatusErr: Label 'The credit memo status is incorrect.';
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
        DeleteJobQueueEntry(CODEUNIT::"APIV1 - Send Sales Document");
    end;

    [Test]
    procedure TestGetCreditMemos()
    var
        CreditMemoNo1: Text;
        CreditMemoNo2: Text;
        CreditMemoJSON1: Text;
        CreditMemoJSON2: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create posted and unposted sales credit memos and use a GET method to retrieve them

        // [GIVEN] 2 credit memos, one posted and one unposted
        CreateSalesCreditMemos(CreditMemoNo1, CreditMemoNo2);
        COMMIT();

        // [WHEN] we GET all the credit memos from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 credit memos should exist in the response
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'number', CreditMemoNo1, CreditMemoNo2, CreditMemoJSON1, CreditMemoJSON2),
          'Could not find the credit memos in JSON');
        LibraryGraphMgt.VerifyIDInJson(CreditMemoJSON1);
        LibraryGraphMgt.VerifyIDInJson(CreditMemoJSON2);
    end;

    [Test]
    procedure TestPostCreditMemos()
    var
        SalesHeader: Record "Sales Header";
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        CustomerNo: Text;
        CreditMemoDate: Date;
        CreditMemoPostingDate: Date;
        ResponseText: Text;
        CreditMemoNumber: Text;
        TargetURL: Text;
        CreditMemoWithComplexJSON: Text;
    begin
        // [SCENARIO] Create posted and unposted Sales credit memos and use HTTP POST to delete them

        // [GIVEN] 2 credit memos, one posted and one unposted
        LibrarySales.CreateCustomerWithAddress(SellToCustomer);
        LibrarySales.CreateCustomerWithAddress(BillToCustomer);
        CustomerNo := SellToCustomer."No.";
        CreditMemoDate := WorkDate();
        CreditMemoPostingDate := WorkDate();

        CreditMemoWithComplexJSON := CreateCreditMemoJSONWithAddress(SellToCustomer, BillToCustomer, CreditMemoDate, CreditMemoPostingDate);
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CreditMemoWithComplexJSON, ResponseText);

        // [THEN] the response text should have the correct Id, credit memo address and the credit memo should exist in the table with currency code set by default
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', CreditMemoNumber),
          'Could not find sales credit memo number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        GetSalesCreditMemoHeaderByCustomerNumberAndDate(
            CustomerNo, CreditMemoNumber, CreditMemoDate, CreditMemoPostingDate, SalesHeader, 'The unposted credit memo should exist');

        LibraryGraphDocumentTools.VerifySalesDocumentSellToAddress(SellToCustomer, SalesHeader, ResponseText, FALSE, FALSE);
        LibraryGraphDocumentTools.VerifySalesDocumentBillToAddress(BillToCustomer, SalesHeader, ResponseText, FALSE, FALSE);

        Assert.AreEqual('', SalesHeader."Currency Code", 'The credit memo should have the LCY currency code set by default');
    end;

    [Test]
    procedure TestPostCreditMemoWithCurrency()
    var
        SalesHeader: Record "Sales Header";
        Currency: Record "Currency";
        Customer: Record "Customer";
        CustomerNo: Text;
        ResponseText: Text;
        CreditMemoNumber: Text;
        TargetURL: Text;
        CreditMemoJSON: Text;
        CurrencyCode: Code[10];
    begin
        // [SCENARIO] Create posted and unposted with specific currency set and use HTTP POST to create them

        // [GIVEN] an CreditMemo with a non-LCY currencyCode set
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";

        Currency.SETFILTER(Code, '<>%1', '');
        Currency.FINDFIRST();
        CurrencyCode := Currency.Code;
        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON('', 'customerNumber', CustomerNo);
        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoJSON, 'currencyCode', CurrencyCode);
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CreditMemoJSON, ResponseText);

        // [THEN] the response text should contain the credit memo ID and the integration record table should map the SalesCreditMemoID with the ID
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', CreditMemoNumber),
          'Could not find sales credit memo number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        // [THEN] the credit memo should exist in the tables
        GetSalesCreditMemoHeaderByCustomerAndNumber(CustomerNo, CreditMemoNumber, SalesHeader, 'The unposted credit memo should exist');
        Assert.AreEqual(CurrencyCode, SalesHeader."Currency Code", 'The credit memo should have the correct currency code');
    end;

    [Test]
    procedure TestModifyCreditMemos()
    begin
        TestMultipleModifyCreditMemos(FALSE, FALSE);
    end;

    [Test]
    procedure TestEmptyModifyCreditMemos()
    begin
        TestMultipleModifyCreditMemos(TRUE, FALSE);
    end;

    [Test]
    procedure TestPartialModifyCreditMemos()
    begin
        TestMultipleModifyCreditMemos(FALSE, TRUE);
    end;

    local procedure TestMultipleModifyCreditMemos(EmptyData: Boolean; PartiallyEmptyData: Boolean)
    var
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        SalesLine: Record "Sales Line";
        Item: Record "Item";
        SalesHeader: Record "Sales Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        CreditMemoID: Text;
        CreditMemoNo: Text;
        ResponseText: Text;
        TargetURL: Text;
        CreditMemoJSON: Text;
        CreditMemoWithComplexJSON: Text;
        SellToAddressComplexTypeJSON: Text;
        BillToAddressComplexTypeJSON: Text;
    begin
        // [SCENARIO] Create Sales CreditMemo, use a PATCH method to change it and then verify the changes
        LibrarySales.CreateCustomerWithAddress(SellToCustomer);
        LibrarySales.CreateCustomerWithAddress(BillToCustomer);

        // [GIVEN] an order with the previously created customer
        LibrarySales.CreateSalesperson(SalespersonPurchaser);

        // [GIVEN] an order with the previously created customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", SellToCustomer."No.");

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [GIVEN] an line in the previously created order
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        CreditMemoNo := SalesHeader."No.";

        // [GIVEN] the credit memo's unique ID
        SalesHeader.GET(SalesHeader."Document Type"::"Credit Memo", CreditMemoNo);
        CreditMemoID := SalesHeader.SystemId;
        Assert.AreNotEqual('', CreditMemoID, 'ID should not be empty');

        IF EmptyData THEN
            CreditMemoJSON := '{}'
        ELSE BEGIN
            CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoJSON, 'salesperson', SalespersonPurchaser.Code);
            CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoJSON, 'customerNumber', SellToCustomer."No.");
        END;

        // [GIVEN] a JSON text with an Item that has the addresses complex types
        CreditMemoWithComplexJSON := CreditMemoJSON;
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(SellToAddressComplexTypeJSON, SellToCustomer, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(BillToAddressComplexTypeJSON, BillToCustomer, EmptyData, PartiallyEmptyData);
        CreditMemoWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(CreditMemoWithComplexJSON, 'sellingPostalAddress', SellToAddressComplexTypeJSON);
        CreditMemoWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(CreditMemoWithComplexJSON, 'billingPostalAddress', BillToAddressComplexTypeJSON);

        COMMIT();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(CreditMemoID, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, CreditMemoWithComplexJSON, ResponseText);

        // [THEN] the item should have the Unit of Measure as a value in the table
        Assert.IsTrue(
          SalesHeader.GET(SalesHeader."Document Type"::"Credit Memo", CreditMemoNo), 'The unposted credit memo should exist');
        IF NOT EmptyData THEN
            Assert.AreEqual(SalesHeader."Salesperson Code", SalespersonPurchaser.Code, 'The patch of Sales Person code was unsuccessful');

        // [THEN] the response text should contain the credit memo address
        LibraryGraphDocumentTools.VerifySalesDocumentSellToAddress(SellToCustomer, SalesHeader, ResponseText, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.VerifySalesDocumentBillToAddress(BillToCustomer, SalesHeader, ResponseText, EmptyData, PartiallyEmptyData);
    end;

    [Test]
    procedure TestDeleteCreditMemo()
    var
        SalesHeader: Record "Sales Header";
        CreditMemoNo: Text;
        CreditMemoID: Text;
    begin
        // [SCENARIO] Create unposted sales credit memo and use HTTP DELETE to delete it

        // [GIVEN] An unposted credit memo
        CreateDraftSalesCreditMemo(SalesHeader);
        CreditMemoNo := SalesHeader."No.";
        Commit();

        SalesHeader.GET(SalesHeader."Document Type"::"Credit Memo", CreditMemoNo);
        CreditMemoID := SalesHeader.SystemId;
        Assert.AreNotEqual('', CreditMemoID, 'ID should not be empty');

        // [WHEN] we DELETE the item from the web service, with the item's unique ID
        DeleteCreditMemoThroughAPI(CreditMemoID);

        // [THEN] the credit memo shouldn't exist in the tables
        IF SalesHeader.GET(SalesHeader."Document Type"::"Credit Memo", CreditMemoNo) THEN
            Assert.ExpectedError('The unposted credit memo should not exist');
    end;

    [Test]
    procedure TestCreateCreditMemoThroughPageAndAPI()
    var
        PageSalesHeader: Record "Sales Header";
        ApiSalesHeader: Record "Sales Header";
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        SalesCreditMemo: TestPage "Sales Credit Memo";
        CustomerNo: Text;
        CreditMemoDate: Date;
        CreditMemoPostingDate: Date;
        CreditMemoWithComplexJSON: Text;
    begin
        // [SCENARIO] Create an credit memo both through the client UI and through the API
        // [SCENARIO] and compare them. They should be the same and have the same fields autocompleted wherever needed.

        // [GIVEN] An unposted credit memo
        LibraryGraphDocumentTools.InitializeUIPage();

        LibrarySales.CreateCustomer(SellToCustomer);
        CustomerNo := SellToCustomer."No.";
        CreditMemoDate := WorkDate();
        CreditMemoPostingDate := WorkDate();

        // [GIVEN] a json describing our new credit memo
        CreditMemoWithComplexJSON := CreateCreditMemoJSONWithAddress(SellToCustomer, BillToCustomer, CreditMemoDate, CreditMemoPostingDate);
        COMMIT();

        // [WHEN] we POST the JSON to the web service and create another credit memo through the test page
        CreateCreditMemoThroughAPI(CreditMemoWithComplexJSON);
        CreateCreditMemoThroughTestPage(SalesCreditMemo, SellToCustomer, CreditMemoDate, CreditMemoDate);

        // [THEN] the credit memo should exist in the table and match the credit memo created from the page
        GetSalesCreditMemoHeaderByCustomerAndDate(CustomerNo, CreditMemoDate, CreditMemoPostingDate, ApiSalesHeader, 'The unposted credit memo should exist');
        PageSalesHeader.GET(PageSalesHeader."Document Type"::"Credit Memo", SalesCreditMemo."No.".VALUE());

        VerifyCreditMemosMatching(ApiSalesHeader, PageSalesHeader);
    end;

    [Test]
    procedure TestGetCreditMemosAppliesDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        DiscountPct: Decimal;
    begin
        // [SCENARIO] When an credit memo is created,the GET Method should update the credit memo and assign a total

        // [GIVEN] 2 credit memos, one posted and one unposted without totals assigned
        LibraryGraphDocumentTools.CreateDocumentWithDiscountPctPending(
          SalesHeader, DiscountPct, SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.CALCFIELDS("Recalculate Invoice Disc.");
        Assert.IsTrue(SalesHeader."Recalculate Invoice Disc.", 'Setup error - recalculate credit memo disc. should be set');

        COMMIT();

        // [WHEN] we GET all the credit memos from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 1 credit memo should exist in the response and CreditMemo Discount Should be Applied
        VerifyGettingAgainKeepsETag(ResponseText, TargetURL);
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        LibraryGraphDocumentTools.VerifySalesTotals(
          SalesHeader, ResponseText, DiscountPct, SalesHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestGetCreditMemosRedistributesDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        ResponseText: Text;
        TargetURL: Text;
        DiscountPct: Decimal;
        DiscountAmt: Decimal;
    begin
        // [SCENARIO] When an credit memo is created, the GET Method should update the credit memo and assign a total

        // [GIVEN] 2 credit memos, one posted and one unposted with discount amount that should be redistributed
        LibraryGraphDocumentTools.CreateDocumentWithDiscountPctPending(
          SalesHeader, DiscountPct, SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.CALCFIELDS(Amount);
        DiscountAmt := LibraryRandom.RandDecInRange(1, ROUND(SalesHeader.Amount / 2, 1), 1);
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(DiscountAmt, SalesHeader);
        GetFirstSalesCreditMemoLine(SalesHeader, SalesLine);
        SalesLine.VALIDATE(Quantity, SalesLine.Quantity + 1);
        SalesLine.MODIFY(TRUE);
        SalesHeader.CALCFIELDS("Recalculate Invoice Disc.");
        Assert.IsTrue(SalesHeader."Recalculate Invoice Disc.", 'Setup error - recalculate credit memo disc. should be set');
        COMMIT();

        // [WHEN] we GET all the credit memos from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the credit memo should exist in the response and CreditMemo Discount Should be Applied
        VerifyGettingAgainKeepsETag(ResponseText, TargetURL);
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        LibraryGraphDocumentTools.VerifySalesTotals(
          SalesHeader, ResponseText, DiscountAmt, SalesHeader."Invoice Discount Calculation"::Amount);
    end;

    [Test]
    procedure TestModifyCreditMemoSetManualDiscount()
    var
        Customer: Record "Customer";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record "Item";
        InvoiceDiscountAmount: Decimal;
        TargetURL: Text;
        CreditMemoJSON: Text;
        ResponseText: Text;
        CreditMemoID: Text;
    begin
        // [SCENARIO 184721] Create Credit Memo, use a PATCH method to change it and then verify the changes
        LibrarySales.CreateCustomerWithAddress(Customer);

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [GIVEN] an order with the previously created customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", Customer."No.");

        // [GIVEN] an line in the previously created Credit memo
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        SalesHeader.SETAUTOCALCFIELDS(Amount);
        SalesHeader.FIND();
        CreditMemoID := SalesHeader."No.";
        InvoiceDiscountAmount := Round(SalesHeader.Amount / 2, LibraryERM.GetCurrencyAmountRoundingPrecision(SalesHeader."Currency Code"), '=');
        COMMIT();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt);
        CreditMemoJSON := STRSUBSTNO('{"%1": %2}', DiscountAmountFieldTxt, FORMAT(InvoiceDiscountAmount, 0, 9));
        LibraryGraphMgt.PatchToWebService(TargetURL, CreditMemoJSON, ResponseText);

        // [THEN] Response contains the updated value
        VerifyValidPostRequest(ResponseText, CreditMemoID);
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
        CreditMemoJSON: Text;
        ResponseText: Text;
        CreditMemoID: Text;
    begin
        // [SCENARIO 184721] Clearing manually set discount

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [Given] a customer
        LibrarySales.CreateCustomerWithAddress(Customer);

        // [GIVEN] an order with the previously created customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", Customer."No.");

        // [GIVEN] an line in the previously created credit memo
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        SalesHeader.SETAUTOCALCFIELDS(Amount);
        SalesHeader.FIND();

        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(SalesHeader.Amount / 2, SalesHeader);

        COMMIT();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.SystemId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt);
        CreditMemoJSON := STRSUBSTNO('{"%1": %2}', DiscountAmountFieldTxt, FORMAT(0, 0, 9));
        LibraryGraphMgt.PatchToWebService(TargetURL, CreditMemoJSON, ResponseText);

        // [THEN] Discount should be removed
        CreditMemoID := SalesHeader."No.";
        VerifyValidPostRequest(ResponseText, CreditMemoID);
        LibraryGraphDocumentTools.VerifyValidDiscountAmount(ResponseText, 0);

        // [THEN] Header value was updated
        SalesHeader.FIND();
        SalesHeader.CALCFIELDS("Invoice Discount Amount");
        Assert.AreEqual(0, SalesHeader."Invoice Discount Amount", 'Invoice discount Amount was not set');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionPostCreditMemo()
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempSalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer" temporary;
        DraftCreditMemoRecordRef: RecordRef;
        PostedCreditMemoRecordRef: RecordRef;
        DocumentId: Guid;
        DocumentNo: Code[20];
        ResponseText: Text;
        TargetURL: Text;
        DraftCreditMemoEmailAddress: Text;
        DraftCreditMemoEmailSubject: Text;
        PostedCreditMemoEmailAddress: Text;
        PostedCreditMemoEmailSubject: Text;
    begin
        // [SCENARIO] User can post a sales credit memo through the API.

        // [GIVEN] Draft sales credit memo exists
        CreateDraftSalesCreditMemo(SalesHeader);
        SetCustomerEmail(SalesHeader."Sell-to Customer No.");
        CreateEmailParameters(SalesHeader);
        DraftCreditMemoRecordRef.GetTable(SalesHeader);
        GetEmailParameters(DraftCreditMemoRecordRef, DraftCreditMemoEmailAddress, DraftCreditMemoEmailSubject);
        DocumentId := SalesHeader.SystemId;
        DocumentNo := SalesHeader."No.";
        Commit();
        Assert.IsTrue(DraftCreditMemoEmailAddress <> '', StrSubstNo(EmptyParameterErr, 'Address'));
        Assert.IsTrue(DraftCreditMemoEmailSubject <> '', StrSubstNo(EmptyParameterErr, 'Subject'));

        VerifyDraftSalesCreditMemo(DocumentId, TempSalesCrMemoEntityBuffer.Status::Draft.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt, ActionPostTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Credit memo is posted
        FindPostedCreditMemoByPreAssignedNo(DocumentNo, SalesCrMemoHeader);
        VerifyPostedSalesCreditMemo(SalesCrMemoHeader."Draft Cr. Memo SystemId", TempSalesCrMemoEntityBuffer.Status::Open.AsInteger());

        // [THEN] Email parameters are transferred from the draft credit memo to the posted credit memo
        PostedCreditMemoRecordRef.GetTable(SalesCrMemoHeader);
        GetEmailParameters(PostedCreditMemoRecordRef, PostedCreditMemoEmailAddress, PostedCreditMemoEmailSubject);
        Assert.AreEqual(DraftCreditMemoEmailAddress, PostedCreditMemoEmailAddress, StrSubstNo(NotTransferredParameterErr, 'Address'));
        Assert.AreEqual(DraftCreditMemoEmailSubject, PostedCreditMemoEmailSubject, StrSubstNo(NotTransferredParameterErr, 'Subject'));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionPostAndSendCreditMemo()
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempSalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer" temporary;
        DocumentId: Guid;
        DocumentNo: Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can post and send a sales credit memo through the API.
        InitializeForSending();

        // [GIVEN] Draft sales credit memos exists
        CreateDraftSalesCreditMemo(SalesHeader);
        SetCustomerEmail(SalesHeader."Sell-to Customer No.");
        DocumentNo := SalesHeader."No.";
        DocumentId := SalesHeader.SystemId;
        Commit();
        VerifyDraftSalesCreditMemo(DocumentId, TempSalesCrMemoEntityBuffer.Status::Draft.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            DocumentId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt, ActionPostAndSendTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Credit memo is posted
        FindPostedCreditMemoByPreAssignedNo(DocumentNo, SalesCrMemoHeader);
        VerifyPostedSalesCreditMemo(SalesCrMemoHeader."Draft Cr. Memo SystemId", TempSalesCrMemoEntityBuffer.Status::Open.AsInteger());

        // [THEN] Mailing job is created
        CheckJobQueueEntry(CODEUNIT::"Document-Mailing");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionCancelNonCorrectiveCreditMemo()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempSalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can cancel a posted sales credit memo through API.

        // [GIVEN] Non-corrective sales credit memo exists
        CreatePostedSalesCreditMemo(SalesCrMemoHeader);
        SetCustomerEmail(SalesCrMemoHeader."Sell-to Customer No.");
        DocumentId := SalesCrMemoHeader."Draft Cr. Memo SystemId";
        Commit();
        VerifyPostedSalesCreditMemo(DocumentId, TempSalesCrMemoEntityBuffer.Status::Open.AsInteger());


        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            DocumentId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt, ActionCancelTxt);

        // [THEN] Cancelation is now allowed
        asserterror LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionCancelCorrectiveCreditMemo()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempSalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can cancel a posted sales credit memo through API.

        // [GIVEN] Corrective sales credit memo exists
        CreateCorrectiveSalesCreditMemo(SalesCrMemoHeader);
        SetCustomerEmail(SalesCrMemoHeader."Sell-to Customer No.");
        DocumentId := SalesCrMemoHeader."Draft Cr. Memo SystemId";
        Commit();
        VerifyPostedSalesCreditMemo(DocumentId, TempSalesCrMemoEntityBuffer.Status::Corrective.AsInteger());


        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            DocumentId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt, ActionCancelTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Credit memo is cancelled
        VerifyPostedSalesCreditMemo(DocumentId, TempSalesCrMemoEntityBuffer.Status::Canceled.AsInteger());
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionCancelAndSendCorrectiveCreditMemo()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempSalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can cancel a posted sales credit memo through API.
        InitializeForSending();

        // [GIVEN] Corrective sales credit memo exists
        CreateCorrectiveSalesCreditMemo(SalesCrMemoHeader);
        SetCustomerEmail(SalesCrMemoHeader."Sell-to Customer No.");
        DocumentId := SalesCrMemoHeader."Draft Cr. Memo SystemId";
        Commit();
        VerifyPostedSalesCreditMemo(DocumentId, TempSalesCrMemoEntityBuffer.Status::Corrective.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            DocumentId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt, ActionCancelAndSendTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Credit memo is cancelled
        VerifyPostedSalesCreditMemo(DocumentId, TempSalesCrMemoEntityBuffer.Status::Canceled.AsInteger());

        // [THEN] Mailing job is created
        CheckJobQueueEntry(CODEUNIT::"APIV1 - Send Sales Document");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionSendPostedCreditMemo()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempSalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can send a posted sales credit memo through the API.
        InitializeForSending();

        // [GIVEN] Posted sales credit memo exists
        CreatePostedSalesCreditMemo(SalesCrMemoHeader);
        SetCustomerEmail(SalesCrMemoHeader."Sell-to Customer No.");
        DocumentId := SalesCrMemoHeader."Draft Cr. Memo SystemId";
        Commit();
        VerifyPostedSalesCreditMemo(DocumentId, TempSalesCrMemoEntityBuffer.Status::Open.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt, ActionSendTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Mailing job is created
        CheckJobQueueEntry(CODEUNIT::"Document-Mailing");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionSendDraftCreditMemo()
    var
        SalesHeader: Record "Sales Header";
        TempSalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Sending a draft sales credit memo through the API throws an error
        InitializeForSending();

        // [GIVEN] Draft sales credit memo exists
        CreateDraftSalesCreditMemo(SalesHeader);
        SetCustomerEmail(SalesHeader."Sell-to Customer No.");
        DocumentId := SalesHeader.SystemId;
        Commit();
        VerifyDraftSalesCreditMemo(DocumentId, TempSalesCrMemoEntityBuffer.Status::Draft.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt, ActionSendTxt);

        // [THEN] Sendig is now allowed
        asserterror LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionSendCancelledCreditMemo()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempSalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can send a draft sales credit memo through the API.
        InitializeForSending();

        // [GIVEN] Cancelled sales credit memo exists
        CreateCancelledSalesCreditMemo(SalesCrMemoHeader);
        SetCustomerEmail(SalesCrMemoHeader."Sell-to Customer No.");
        DocumentId := SalesCrMemoHeader."Draft Cr. Memo SystemId";
        Commit();
        VerifyPostedSalesCreditMemo(DocumentId, TempSalesCrMemoEntityBuffer.Status::Canceled.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt, ActionSendTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Mailing job is created
        CheckJobQueueEntry(CODEUNIT::"APIV1 - Send Sales Document");
    end;

    local procedure CreateCorrectiveSalesCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        InvoiceCode: Code[20];
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        ModifySalesHeaderPostingDate(SalesHeader, WORKDATE());
        InvoiceCode := LibrarySales.PostSalesDocument(SalesHeader, false, true);
        SalesInvoiceHeader.Get(InvoiceCode);
        Commit();
        CODEUNIT.Run(CODEUNIT::"Correct Posted Sales Invoice", SalesInvoiceHeader);
        SalesCrMemoHeader.SetRange("Applies-to Doc. No.", SalesInvoiceHeader."No.");
        SalesCrMemoHeader.FindFirst();
    end;

    local procedure CreateDraftSalesCreditMemo(var SalesHeader: Record "Sales Header")
    begin
        LibrarySales.CreateSalesCreditMemo(SalesHeader);
        ModifySalesHeaderPostingDate(SalesHeader, WORKDATE());
    end;

    local procedure CreatePostedSalesCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesHeader: Record "Sales Header";
        CreditMemoCode: Code[20];
    begin
        CreateDraftSalesCreditMemo(SalesHeader);
        CreditMemoCode := LibrarySales.PostSalesDocument(SalesHeader, false, true);
        SalesCrMemoHeader.Get(CreditMemoCode);
    end;

    local procedure CreateCancelledSalesCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        CreatePostedSalesCreditMemo(SalesCrMemoHeader);
        CODEUNIT.Run(CODEUNIT::"Cancel Posted Sales Cr. Memo", SalesCrMemoHeader);
    end;

    local procedure CreateSalesCreditMemos(var CreditMemoNo1: Text; var CreditMemoNo2: Text)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.SetAllowDocumentDeletionBeforeDate(WORKDATE() + 1);
        CreatePostedSalesCreditMemo(SalesCrMemoHeader);
        CreateDraftSalesCreditMemo(SalesHeader);
        CreditMemoNo1 := SalesCrMemoHeader."No.";
        CreditMemoNo2 := SalesHeader."No.";
        COMMIT();
    end;

    local procedure CreateCreditMemoJSONWithAddress(SellToCustomer: Record "Customer"; BillToCustomer: Record "Customer"; CreditMemoDate: Date; CreditMemoPostingDate: Date): Text
    var
        CreditMemoJSON: Text;
        SellToAddressComplexTypeJSON: Text;
        BillToAddressComplexTypeJSON: Text;
        CreditMemoWithComplexJSON: Text;
    begin
        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON('', 'customerNumber', SellToCustomer."No.");
        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoJSON, 'creditMemoDate', CreditMemoDate);
        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoJSON, 'postingDate', CreditMemoPostingDate);

        CreditMemoWithComplexJSON := CreditMemoJSON;
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(SellToAddressComplexTypeJSON, SellToCustomer, FALSE, FALSE);
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(BillToAddressComplexTypeJSON, BillToCustomer, FALSE, FALSE);
        CreditMemoWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(CreditMemoWithComplexJSON, 'sellingPostalAddress', SellToAddressComplexTypeJSON);
        CreditMemoWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(CreditMemoWithComplexJSON, 'billingPostalAddress', BillToAddressComplexTypeJSON);
        EXIT(CreditMemoWithComplexJSON);
    end;

    local procedure CreateCreditMemoThroughTestPage(var SalesCreditMemo: TestPage "Sales Credit Memo"; Customer: Record "Customer"; DocumentDate: Date; PostingDate: Date)
    begin
        SalesCreditMemo.OPENNEW();
        SalesCreditMemo."Sell-to Customer No.".SETVALUE(Customer."No.");
        SalesCreditMemo."Document Date".SETVALUE(DocumentDate);
        SalesCreditMemo."Posting Date".SETVALUE(PostingDate);
    end;

    local procedure CreateCreditMemoThroughAPI(CreditMemoWithComplexJSON: Text)
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CreditMemoWithComplexJSON, ResponseText);
    end;

    local procedure DeleteCreditMemoThroughAPI(CreditMemoID: Text)
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL(CreditMemoID, PAGE::"APIV1 - Sales Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);
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

    local procedure GetFirstSalesCreditMemoLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
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

    local procedure VerifyValidPostRequest(ResponseText: Text; var CreditMemoNumber: Text)
    begin
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', CreditMemoNumber),
          'Could not find sales credit memo number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
    end;

    local procedure GetSalesCreditMemoHeaderByCustomerNumberAndDate(CustomerNo: Text; CreditMemoNo: Text; CreditMemoDate: Date; CreditMemoPostingDate: Date; var SalesHeader: Record "Sales Header"; ErrorMessage: Text)
    begin
        SalesHeader.RESET();
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SETRANGE("No.", CreditMemoNo);
        SalesHeader.SETRANGE("Sell-to Customer No.", CustomerNo);
        SalesHeader.SETRANGE("Document Date", CreditMemoDate);
        SalesHeader.SETRANGE("Posting Date", CreditMemoPostingDate);
        Assert.IsTrue(SalesHeader.FINDFIRST(), ErrorMessage);
    end;

    local procedure GetSalesCreditMemoHeaderByCustomerAndNumber(CustomerNo: Text; CreditMemoNo: Text; var SalesHeader: Record "Sales Header"; ErrorMessage: Text)
    begin
        SalesHeader.RESET();
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SETRANGE("No.", CreditMemoNo);
        SalesHeader.SETRANGE("Sell-to Customer No.", CustomerNo);
        Assert.IsTrue(SalesHeader.FINDFIRST(), ErrorMessage);
    end;

    local procedure GetSalesCreditMemoHeaderByCustomerAndDate(CustomerNo: Text; CreditMemoDate: Date; CreditMemoPostingDate: Date; var SalesHeader: Record "Sales Header"; ErrorMessage: Text)
    begin
        SalesHeader.RESET();
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SETRANGE("Sell-to Customer No.", CustomerNo);
        SalesHeader.SETRANGE("Document Date", CreditMemoDate);
        SalesHeader.SETRANGE("Posting Date", CreditMemoPostingDate);
        Assert.IsTrue(SalesHeader.FINDFIRST(), ErrorMessage);
    end;

    local procedure VerifyCreditMemosMatching(var SalesHeader1: Record "Sales Header"; var SalesHeader2: Record "Sales Header")
    var
        TempIgnoredFieldsForComparison: Record 2000000041 temporary;
        RecordField: Record Field;
        SalesHeader1RecordRef: RecordRef;
        SalesHeader2RecordRef: RecordRef;
    begin
        // Ignore these fields when comparing Page and API CreditMemos
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, SalesHeader1.FIELDNO("No."), DATABASE::"Sales Header");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, SalesHeader1.FIELDNO("Posting Description"), DATABASE::"Sales Header");
#pragma warning disable AL0432
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, SalesHeader1.FIELDNO(Id), DATABASE::"Sales Header");
#pragma warning restore AL0432
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, SalesHeader1.FIELDNO("Order Date"), DATABASE::"Sales Header");      // it is always set as Today() in API
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, SalesHeader1.FIELDNO("Shipment Date"), DATABASE::"Sales Header");   // it is always set as Today() in API
        // Special ignore case for ES
        RecordField.SETRANGE(TableNo, DATABASE::"Sales Header");
        RecordField.SETRANGE(FieldName, 'Due Date Modified');
        if RecordField.FINDFIRST() then
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, RecordField."No.", DATABASE::"Sales Header");

        // Time zone will impact how the date from the page vs WebService is saved. If removed this will fail in snap between 12:00 - 1 AM
        IF TIME() < 020000T THEN
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, SalesHeader1.FIELDNO("Posting Date"), DATABASE::"Sales Header");

        SalesHeader1RecordRef.GETTABLE(SalesHeader1);
        SalesHeader2RecordRef.GETTABLE(SalesHeader2);

        Assert.RecordsAreEqualExceptCertainFields(
          SalesHeader1RecordRef, SalesHeader2RecordRef, TempIgnoredFieldsForComparison, 'Credit Memos do not match');
    end;

    local procedure CreateEmailParameters(var SalesHeader: Record "Sales Header")
    var
        EmailParameter: Record "Email Parameter";
    begin
        EmailParameter.SaveParameterValue(
          SalesHeader."No.", SalesHeader."Document Type".AsInteger(),
          EmailParameter."Parameter Type"::Address.AsInteger(),
          StrSubstNo('%1@home.local', CopyStr(CreateGuid(), 2, 8)));
        EmailParameter.SaveParameterValue(
          SalesHeader."No.", SalesHeader."Document Type".AsInteger(),
          EmailParameter."Parameter Type"::Subject.AsInteger(), Format(CreateGuid()));
    end;

    local procedure GetEmailParameters(var RecordRef: RecordRef; var Email: Text; var Subject: Text)
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        EmailParameter: Record "Email Parameter";
    begin
        Email := '';
        Subject := '';
        case RecordRef.Number() of
            DATABASE::"Sales Header":
                begin
                    RecordRef.SetTable(SalesHeader);
                    if EmailParameter.GetEntryWithReportUsage(
                         SalesHeader."No.", SalesHeader."Document Type".AsInteger(), EmailParameter."Parameter Type"::Address.AsInteger())
                    then
                        Email := EmailParameter.GetParameterValue();
                    if EmailParameter.GetEntryWithReportUsage(
                         SalesHeader."No.", SalesHeader."Document Type".AsInteger(), EmailParameter."Parameter Type"::Subject.AsInteger())
                    then
                        Subject := EmailParameter.GetParameterValue();
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    RecordRef.SetTable(SalesCrMemoHeader);
                    if EmailParameter.GetEntryWithReportUsage(
                         SalesCrMemoHeader."No.", SalesHeader."Document Type"::"Credit Memo".AsInteger(), EmailParameter."Parameter Type"::Address.AsInteger())
                    then
                        Email := EmailParameter.GetParameterValue();
                    if EmailParameter.GetEntryWithReportUsage(
                         SalesCrMemoHeader."No.", SalesHeader."Document Type"::"Credit Memo".AsInteger(), EmailParameter."Parameter Type"::Subject.AsInteger())
                    then
                        Subject := EmailParameter.GetParameterValue();
                end;
        end;
    end;

    local procedure SetCustomerEmail(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        Customer."E-Mail" := 'somebody@somewhere.com';
        Customer.Modify(true);
    end;

    local procedure FindPostedCreditMemoByPreAssignedNo(PreAssignedNo: Code[20]; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        SalesCrMemoHeader.SetCurrentKey("Pre-Assigned No.");
        SalesCrMemoHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        Assert.IsTrue(SalesCrMemoHeader.FindFirst(), CannotFindPostedCreditMemoErr);
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

    local procedure VerifyPostedSalesCreditMemo(DocumentId: Guid; Status: Integer)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";
    begin
        SalesCrMemoHeader.SetRange("Draft Cr. Memo SystemId", DocumentId);
        Assert.IsFalse(SalesCrMemoHeader.IsEmpty(), CannotFindPostedCreditMemoErr);

        SalesCrMemoEntityBuffer.SetRange(Id, DocumentId);
        Assert.IsTrue(SalesCrMemoEntityBuffer.FindFirst(), CannotFindPostedCreditMemoErr);
        Assert.AreEqual(Status, SalesCrMemoEntityBuffer.Status, CreditMemoStatusErr);
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
}

