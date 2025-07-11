codeunit 139865 "APIV2 - Purch. Cr. Memos E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Purchase] [Credit Memo]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        CreditMemoServiceNameTxt: Label 'purchaseCreditMemos';
        DiscountAmountFieldTxt: Label 'discountAmount';
        ActionPostTxt: Label 'Microsoft.NAV.post', Locked = true;
        ActionCancelTxt: Label 'Microsoft.NAV.cancel', Locked = true;
        NotEmptyResponseErr: Label 'Response body should be empty.';
        CannotFindDraftCreditMemoErr: Label 'Cannot find the draft credit memo.';
        CannotFindPostedCreditMemoErr: Label 'Cannot find the posted credit memo.';
        CreditMemoStatusErr: Label 'The credit memo status is incorrect.';

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
        // [SCENARIO] Create posted and unposted purchase credit memos and use a GET method to retrieve them
        // [GIVEN] 2 credit memos, one posted and one unposted
        CreatePurchaseCreditMemos(CreditMemoNo1, CreditMemoNo2);
        Commit();

        // [WHEN] we GET all the credit memos from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt);
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
        PurchaseHeader: Record "Purchase Header";
        BuyFromVendor: Record Vendor;
        PayToVendor: Record Vendor;
        VendorNo: Text;
        CreditMemoDate: Date;
        CreditMemoPostingDate: Date;
        ResponseText: Text;
        CreditMemoNumber: Text;
        TargetURL: Text;
        CreditMemo: Text;
    begin
        // [SCENARIO] Create posted and unposted Purchase credit memos and use HTTP POST to delete them
        // [GIVEN] 2 credit memos, one posted and one unposted
        LibraryPurchase.CreateVendorWithAddress(BuyFromVendor);
        LibraryPurchase.CreateVendorWithAddress(PayToVendor);
        VendorNo := BuyFromVendor."No.";
        CreditMemoDate := WorkDate();
        CreditMemoPostingDate := WorkDate();

        CreditMemo := CreateCreditMemoJSONWithAddress(BuyFromVendor, PayToVendor, CreditMemoDate, CreditMemoPostingDate);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CreditMemo, ResponseText);

        // [THEN] the response text should have the correct Id, credit memo address and the credit memo should exist in the table with currency code set by default
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', CreditMemoNumber),
          'Could not find purchase credit memo number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        GetPurchaseCreditMemoHeaderByVendorNumberAndDate(
            VendorNo, CreditMemoNumber, CreditMemoDate, CreditMemoPostingDate, PurchaseHeader, 'The unposted credit memo should exist');

        LibraryGraphDocumentTools.CheckPurchaseDocumentBuyFromAddress(BuyFromVendor, PurchaseHeader, false, false);
        LibraryGraphDocumentTools.CheckPurchaseDocumentPayToAddress(PayToVendor, PurchaseHeader, false, false);

        Assert.AreEqual('', PurchaseHeader."Currency Code", 'The credit memo should have the LCY currency code set by default');
    end;

    [Test]
    procedure TestPostCreditMemoWithCurrency()
    var
        PurchaseHeader: Record "Purchase Header";
        Currency: Record "Currency";
        Vendor: Record Vendor;
        VendorNo: Text;
        ResponseText: Text;
        CreditMemoNumber: Text;
        TargetURL: Text;
        CreditMemoJSON: Text;
        CurrencyCode: Code[10];
    begin
        // [SCENARIO] Create posted and unposted with specific currency set and use HTTP POST to create them

        // [GIVEN] an CreditMemo with a non-LCY currencyCode set
        LibraryPurchase.CreateVendor(Vendor);
        VendorNo := Vendor."No.";

        Currency.SetFilter(Code, '<>%1', '');
        Currency.FindFirst();
        CurrencyCode := Currency.Code;
        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON('', 'vendorNumber', VendorNo);
        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoJSON, 'currencyCode', CurrencyCode);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CreditMemoJSON, ResponseText);

        // [THEN] the response text should contain the credit memo ID and the integration record table should map the PurchaseCreditMemoID with the ID
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', CreditMemoNumber),
          'Could not find purchase credit memo number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        // [THEN] the credit memo should exist in the tables
        GetPurchaseCreditMemoHeaderByVendorAndNumber(VendorNo, CreditMemoNumber, PurchaseHeader, 'The unposted credit memo should exist');
        Assert.AreEqual(CurrencyCode, PurchaseHeader."Currency Code", 'The credit memo should have the correct currency code');
    end;

    [Test]
    procedure TestPostCreditMemoWithVendorCreditMemoNo()
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        VendorNo: Text;
        ResponseText: Text;
        CreditMemoNumber: Text;
        TargetURL: Text;
        CreditMemoJSON: Text;
        VendorCreditMemoNumber: Text;
    begin
        // [SCENARIO] Create posted and unposted with specific vendor credit memo number set and use HTTP POST to create them

        // [GIVEN] A credit memo with vendor credit memo number set
        LibraryPurchase.CreateVendor(Vendor);
        VendorNo := Vendor."No.";
        VendorCreditMemoNumber := LibraryRandom.RandText(15).ToUpper();

        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON('', 'vendorNumber', VendorNo);
        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoJSON, 'vendorCreditMemoNumber', VendorCreditMemoNumber);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CreditMemoJSON, ResponseText);

        // [THEN] the response text should contain the credit memo ID
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', CreditMemoNumber),
          'Could not find purchase credit memo number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        // [THEN] the credit memo should exist in the tables
        GetPurchaseCreditMemoHeaderByVendorAndNumber(VendorNo, CreditMemoNumber, PurchaseHeader, 'The unposted credit memo should exist');
        Assert.AreEqual(VendorCreditMemoNumber, PurchaseHeader."Vendor Cr. Memo No.", 'The credit memo should have the correct vendor credit memo number');
    end;

    [Test]
    procedure TestModifyCreditMemos()
    begin
        TestMultipleModifyCreditMemos(false, false);
    end;

    [Test]
    procedure TestEmptyModifyCreditMemos()
    begin
        TestMultipleModifyCreditMemos(true, false);
    end;

    [Test]
    procedure TestPartialModifyCreditMemos()
    begin
        TestMultipleModifyCreditMemos(false, true);
    end;

    local procedure TestMultipleModifyCreditMemos(EmptyData: Boolean; PartiallyEmptyData: Boolean)
    var
        BuyFromVendor: Record Vendor;
        PayToVendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        Item: Record "Item";
        PurchaseHeader: Record "Purchase Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoID: Text;
        CreditMemoNo: Text;
        ResponseText: Text;
        TargetURL: Text;
        CreditMemoJSON: Text;
    begin
        // [SCENARIO] Create Purchase CreditMemo, use a PATCH method to change it and then verify the changes
        LibraryPurchase.CreateVendorWithAddress(BuyFromVendor);
        LibraryPurchase.CreateVendorWithAddress(PayToVendor);

        // [GIVEN] an order with the previously created vendor
        LibrarySales.CreateSalesperson(SalespersonPurchaser);

        // [GIVEN] an order with the previously created vendor
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", BuyFromVendor."No.");

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [GIVEN] an line in the previously created order
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        CreditMemoNo := PurchaseHeader."No.";

        // [GIVEN] the credit memo's unique ID
        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", CreditMemoNo);
        CreditMemoID := PurchaseHeader.SystemId;
        Assert.AreNotEqual('', CreditMemoID, 'ID should not be empty');

        if EmptyData then
            CreditMemoJSON := '{}'
        else begin
            CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoJSON, 'purchaser', SalespersonPurchaser.Code);
            CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoJSON, 'vendorNumber', BuyFromVendor."No.");
        end;

        // [GIVEN] a JSON text with an Item that has the addresses 
        LibraryGraphDocumentTools.GetVendorAddressJSON(CreditMemoJSON, BuyFromVendor, 'buyFrom', EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.GetVendorAddressJSON(CreditMemoJSON, PayToVendor, 'payTo', EmptyData, PartiallyEmptyData);

        Commit();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(CreditMemoID, Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, CreditMemoJSON, ResponseText);

        // [THEN] the item should have the Unit of Measure as a value in the table
        Assert.IsTrue(
          PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", CreditMemoNo), 'The unposted credit memo should exist');
        if not EmptyData then
            Assert.AreEqual(PurchaseHeader."Purchaser Code", SalespersonPurchaser.Code, 'The patch of Purchase Person code was unsuccessful');

        // [THEN] the response text should contain the credit memo address
        LibraryGraphDocumentTools.CheckPurchaseDocumentBuyFromAddress(BuyFromVendor, PurchaseHeader, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.CheckPurchaseDocumentPayToAddress(PayToVendor, PurchaseHeader, EmptyData, PartiallyEmptyData);
    end;

    [Test]
    procedure TestDeleteCreditMemo()
    var
        PurchaseHeader: Record "Purchase Header";
        CreditMemoNo: Text;
        CreditMemoID: Text;
    begin
        // [SCENARIO] Create unposted purchase credit memo and use HTTP DELETE to delete it
        // [GIVEN] An unposted credit memo
        CreateDraftPurchaseCreditMemo(PurchaseHeader);
        CreditMemoNo := PurchaseHeader."No.";
        Commit();

        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", CreditMemoNo);
        CreditMemoID := PurchaseHeader.SystemId;
        Assert.AreNotEqual('', CreditMemoID, 'ID should not be empty');

        // [WHEN] we DELETE the item from the web service, with the item's unique ID
        DeleteCreditMemoThroughAPI(CreditMemoID);

        // [THEN] the credit memo shouldn't exist in the tables
        if PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", CreditMemoNo) then
            Assert.ExpectedError('The unposted credit memo should not exist');
    end;

    [Test]
    procedure TestCreateCreditMemoThroughPageAndAPI()
    var
        PagePurchaseHeader: Record "Purchase Header";
        ApiPurchaseHeader: Record "Purchase Header";
        BuyFromVendor: Record Vendor;
        PayToVendor: Record Vendor;
        PurchaseCreditMemo: TestPage "Purchase Credit Memo";
        VendorNo: Text;
        CreditMemoDate: Date;
        CreditMemoPostingDate: Date;
        CreditMemoJSON: Text;
    begin
        // [SCENARIO] Create an credit memo both through the client UI and through the API
        // [SCENARIO] and compare them. They should be the same and have the same fields autocompleted wherever needed.
        // [GIVEN] An unposted credit memo
        LibraryGraphDocumentTools.InitializeUIPage();

        LibraryPurchase.CreateVendor(BuyFromVendor);
        VendorNo := BuyFromVendor."No.";
        CreditMemoDate := WorkDate();
        CreditMemoPostingDate := WorkDate();

        // [GIVEN] a json describing our new credit memo
        CreditMemoJSON := CreateCreditMemoJSONWithAddress(BuyFromVendor, PayToVendor, CreditMemoDate, CreditMemoPostingDate);
        Commit();

        // [WHEN] we POST the JSON to the web service and create another credit memo through the test page
        CreateCreditMemoThroughAPI(CreditMemoJSON);
        CreateCreditMemoThroughTestPage(PurchaseCreditMemo, BuyFromVendor, CreditMemoDate, CreditMemoDate);

        // [THEN] the credit memo should exist in the table and match the credit memo created from the page
        GetPurchaseCreditMemoHeaderByVendorAndDate(VendorNo, CreditMemoDate, CreditMemoPostingDate, ApiPurchaseHeader, 'The unposted credit memo should exist');
        PagePurchaseHeader.Get(PagePurchaseHeader."Document Type"::"Credit Memo", PurchaseCreditMemo."No.".Value());

        VerifyCreditMemosMatching(ApiPurchaseHeader, PagePurchaseHeader);
    end;

    [Test]
    procedure TestModifyCreditMemoSetManualDiscount()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record "Item";
        InvoiceDiscountAmount: Decimal;
        TargetURL: Text;
        CreditMemoJSON: Text;
        ResponseText: Text;
        CreditMemoID: Text;
    begin
        // [SCENARIO 184721] Create Credit Memo, use a PATCH method to change it and then verify the changes
        LibraryPurchase.CreateVendorWithAddress(Vendor);

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [GIVEN] an order with the previously created vendor
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", Vendor."No.");

        // [GIVEN] an line in the previously created Credit memo
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        PurchaseHeader.SetAutoCalcFields(Amount);
        PurchaseHeader.Find();
        CreditMemoID := PurchaseHeader."No.";
        InvoiceDiscountAmount := Round(PurchaseHeader.Amount / 2, LibraryERM.GetCurrencyAmountRoundingPrecision(PurchaseHeader."Currency Code"), '=');
        Commit();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(PurchaseHeader.SystemId, Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt);
        CreditMemoJSON := StrSubstNo('{"%1": %2}', DiscountAmountFieldTxt, Format(InvoiceDiscountAmount, 0, 9));
        LibraryGraphMgt.PatchToWebService(TargetURL, CreditMemoJSON, ResponseText);

        // [THEN] Response contains the updated value
        VerifyValidPostRequest(ResponseText, CreditMemoID);
        LibraryGraphDocumentTools.VerifyValidDiscountAmount(ResponseText, InvoiceDiscountAmount);

        // [THEN] Header value was updated
        PurchaseHeader.Find();
        PurchaseHeader.CalcFields("Invoice Discount Amount");
        Assert.AreEqual(InvoiceDiscountAmount, PurchaseHeader."Invoice Discount Amount", 'Invoice discount Amount was not set');
    end;

    [Test]
    procedure TestClearingManualDiscounts()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record "Item";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
        TargetURL: Text;
        CreditMemoJSON: Text;
        ResponseText: Text;
        CreditMemoID: Text;
    begin
        // [SCENARIO 184721] Clearing manually set discount

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [Given] a vendor
        LibraryPurchase.CreateVendorWithAddress(Vendor);

        // [GIVEN] an order with the previously created vendor
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", Vendor."No.");

        // [GIVEN] an line in the previously created credit memo
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        PurchaseHeader.SetAutoCalcFields(Amount);
        PurchaseHeader.Find();

        PurchCalcDiscByType.ApplyInvDiscBasedOnAmt(PurchaseHeader.Amount / 2, PurchaseHeader);

        Commit();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(PurchaseHeader.SystemId, Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt);
        CreditMemoJSON := StrSubstNo('{"%1": %2}', DiscountAmountFieldTxt, Format(0, 0, 9));
        LibraryGraphMgt.PatchToWebService(TargetURL, CreditMemoJSON, ResponseText);

        // [THEN] Discount should be removed
        CreditMemoID := PurchaseHeader."No.";
        VerifyValidPostRequest(ResponseText, CreditMemoID);
        LibraryGraphDocumentTools.VerifyValidDiscountAmount(ResponseText, 0);

        // [THEN] Header value was updated
        PurchaseHeader.Find();
        PurchaseHeader.CalcFields("Invoice Discount Amount");
        Assert.AreEqual(0, PurchaseHeader."Invoice Discount Amount", 'Invoice discount Amount was not set');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionPostCreditMemo()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        TempPurchCrMemoEntityBuffer: Record "Purch. Cr. Memo Entity Buffer" temporary;
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        DocumentId: Guid;
        DocumentNo: Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can post a purchase credit memo through the API.
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        // [GIVEN] Draft purchase credit memo exists
        CreateDraftPurchaseCreditMemo(PurchaseHeader);
        DocumentId := PurchaseHeader.SystemId;
        DocumentNo := PurchaseHeader."No.";
        Commit();

        VerifyDraftPurchaseCreditMemo(DocumentId, TempPurchCrMemoEntityBuffer.Status::Draft.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt, ActionPostTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Credit memo is posted
        FindPostedCreditMemoByPreAssignedNo(DocumentNo, PurchCrMemoHdr);
        VerifyPostedPurchaseCreditMemo(PurchCrMemoHdr."Draft Cr. Memo SystemId", TempPurchCrMemoEntityBuffer.Status::Open.AsInteger());
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionCancelNonCorrectiveCreditMemo()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        TempPurchCrMemoEntityBuffer: Record "Purch. Cr. Memo Entity Buffer" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can cancel a posted purchase credit memo through API.

        // [GIVEN] Non-corrective purchase credit memo exists
        CreatePostedPurchaseCreditMemo(PurchCrMemoHdr);
        SetVendorEmail(PurchCrMemoHdr."Buy-from Vendor No.");
        DocumentId := PurchCrMemoHdr."Draft Cr. Memo SystemId";
        Commit();
        VerifyPostedPurchaseCreditMemo(DocumentId, TempPurchCrMemoEntityBuffer.Status::Open.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            DocumentId, Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt, ActionCancelTxt);

        // [THEN] Cancelation is now allowed
        asserterror LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionCancelCorrectiveCreditMemo()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        TempPurchCrMemoEntityBuffer: Record "Purch. Cr. Memo Entity Buffer" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can cancel a posted purchase credit memo through API.

        // [GIVEN] Corrective purchase credit memo exists
        CreateCorrectivePurchaseCreditMemo(PurchCrMemoHdr);
        SetVendorEmail(PurchCrMemoHdr."Buy-from Vendor No.");
        DocumentId := PurchCrMemoHdr."Draft Cr. Memo SystemId";
        Commit();
        VerifyPostedPurchaseCreditMemo(DocumentId, TempPurchCrMemoEntityBuffer.Status::Corrective.AsInteger());

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            DocumentId, Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt, ActionCancelTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Credit memo is cancelled
        VerifyPostedPurchaseCreditMemo(DocumentId, TempPurchCrMemoEntityBuffer.Status::Canceled.AsInteger());
    end;

    local procedure CreateCorrectivePurchaseCreditMemo(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
        InvoiceCode: Code[20];
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        InvoiceCode := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        PurchInvHeader.Get(InvoiceCode);
        Commit();
        Codeunit.Run(Codeunit::"Correct Posted Purch. Invoice", PurchInvHeader);
        PurchCrMemoHdr.SetRange("Applies-to Doc. No.", PurchInvHeader."No.");
        PurchCrMemoHdr.FindFirst();
    end;

    local procedure CreateDraftPurchaseCreditMemo(var PurchaseHeader: Record "Purchase Header")
    begin
        LibraryPurchase.CreatePurchaseCreditMemo(PurchaseHeader);
    end;

    local procedure CreatePostedPurchaseCreditMemo(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        PurchaseHeader: Record "Purchase Header";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        CreditMemoCode: Code[20];
    begin
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        CreateDraftPurchaseCreditMemo(PurchaseHeader);
        CreditMemoCode := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        PurchCrMemoHdr.Get(CreditMemoCode);
    end;

    local procedure CreatePurchaseCreditMemos(var CreditMemoNo1: Text; var CreditMemoNo2: Text)
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryPurchase.SetAllowDocumentDeletionBeforeDate(WorkDate() + 1);
        CreatePostedPurchaseCreditMemo(PurchCrMemoHdr);
        CreateDraftPurchaseCreditMemo(PurchaseHeader);
        CreditMemoNo1 := PurchCrMemoHdr."No.";
        CreditMemoNo2 := PurchaseHeader."No.";
        Commit();
    end;

    local procedure CreateCreditMemoJSONWithAddress(BuyFromVendor: Record Vendor; PayToVendor: Record Vendor; CreditMemoDate: Date; CreditMemoPostingDate: Date): Text
    var
        CreditMemoJSON: Text;
    begin
        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON('', 'vendorNumber', BuyFromVendor."No.");
        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoJSON, 'creditMemoDate', CreditMemoDate);
        CreditMemoJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoJSON, 'postingDate', CreditMemoPostingDate);

        LibraryGraphDocumentTools.GetVendorAddressJSON(CreditMemoJSON, BuyFromVendor, 'buyFrom', false, false);
        LibraryGraphDocumentTools.GetVendorAddressJSON(CreditMemoJSON, PayToVendor, 'payTo', false, false);

        exit(CreditMemoJSON);
    end;

    local procedure CreateCreditMemoThroughTestPage(var PurchaseCreditMemo: TestPage "Purchase Credit Memo"; Vendor: Record Vendor; DocumentDate: Date; PostingDate: Date)
    begin
        PurchaseCreditMemo.OpenNew();
        PurchaseCreditMemo."Buy-from Vendor No.".SetValue(Vendor."No.");
        PurchaseCreditMemo."Document Date".SetValue(DocumentDate);
        PurchaseCreditMemo."Posting Date".SetValue(PostingDate);
    end;

    local procedure CreateCreditMemoThroughAPI(CreditMemoJSON: Text)
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CreditMemoJSON, ResponseText);
    end;

    local procedure DeleteCreditMemoThroughAPI(CreditMemoID: Text)
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL(CreditMemoID, Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);
    end;

    local procedure VerifyValidPostRequest(ResponseText: Text; var CreditMemoNumber: Text)
    begin
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', CreditMemoNumber),
          'Could not find purchase credit memo number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
    end;

    local procedure GetPurchaseCreditMemoHeaderByVendorNumberAndDate(VendorNo: Text; CreditMemoNo: Text; CreditMemoDate: Date; CreditMemoPostingDate: Date; var PurchaseHeader: Record "Purchase Header"; ErrorMessage: Text)
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseHeader.SetRange("No.", CreditMemoNo);
        PurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        PurchaseHeader.SetRange("Document Date", CreditMemoDate);
        PurchaseHeader.SetRange("Posting Date", CreditMemoPostingDate);
        Assert.IsTrue(PurchaseHeader.FindFirst(), ErrorMessage);
    end;

    local procedure GetPurchaseCreditMemoHeaderByVendorAndNumber(VendorNo: Text; CreditMemoNo: Text; var PurchaseHeader: Record "Purchase Header"; ErrorMessage: Text)
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseHeader.SetRange("No.", CreditMemoNo);
        PurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        Assert.IsTrue(PurchaseHeader.FindFirst(), ErrorMessage);
    end;

    local procedure GetPurchaseCreditMemoHeaderByVendorAndDate(VendorNo: Text; CreditMemoDate: Date; CreditMemoPostingDate: Date; var PurchaseHeader: Record "Purchase Header"; ErrorMessage: Text)
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        PurchaseHeader.SetRange("Document Date", CreditMemoDate);
        PurchaseHeader.SetRange("Posting Date", CreditMemoPostingDate);
        Assert.IsTrue(PurchaseHeader.FindFirst(), ErrorMessage);
    end;

    local procedure VerifyCreditMemosMatching(var PurchaseHeader1: Record "Purchase Header"; var PurchaseHeader2: Record "Purchase Header")
    var
        TempIgnoredFieldsForComparison: Record 2000000041 temporary;
        RecordField: Record Field;
        PurchaseHeader1RecordRef: RecordRef;
        PurchaseHeader2RecordRef: RecordRef;
    begin
        // Ignore these fields when comparing Page and API CreditMemos
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, PurchaseHeader1.FieldNo("No."), Database::"Purchase Header");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, PurchaseHeader1.FieldNo("Posting Description"), Database::"Purchase Header");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, PurchaseHeader1.FieldNo("Order Date"), Database::"Purchase Header");  // it is always set as Today() in API
        // Special ignore case for ES
        RecordField.SetRange(TableNo, Database::"Purchase Header");
        RecordField.SetRange(FieldName, 'Due Date Modified');
        if RecordField.FindFirst() then
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, RecordField."No.", Database::"Purchase Header");

        // Time zone will impact how the date from the page vs WebService is saved. If removed this will fail in snap between 12:00 - 1 AM
        if TIME() < 020000T then
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, PurchaseHeader1.FieldNo("Posting Date"), Database::"Purchase Header");

        PurchaseHeader1RecordRef.GetTable(PurchaseHeader1);
        PurchaseHeader2RecordRef.GetTable(PurchaseHeader2);

        Assert.RecordsAreEqualExceptCertainFields(
          PurchaseHeader1RecordRef, PurchaseHeader2RecordRef, TempIgnoredFieldsForComparison, 'Credit Memos do not match');
    end;

    local procedure SetVendorEmail(VendorNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(VendorNo);
        Vendor.Validate("E-Mail", LibraryUtility.GenerateRandomEmail());
        Vendor.Modify(true);
    end;

    local procedure FindPostedCreditMemoByPreAssignedNo(PreAssignedNo: Code[20]; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
        PurchCrMemoHdr.SetCurrentKey("Pre-Assigned No.");
        PurchCrMemoHdr.SetRange("Pre-Assigned No.", PreAssignedNo);
        Assert.IsTrue(PurchCrMemoHdr.FindFirst(), CannotFindPostedCreditMemoErr);
    end;

    local procedure VerifyDraftPurchaseCreditMemo(DocumentId: Guid; Status: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchCrMemoEntityBuffer: Record "Purch. Cr. Memo Entity Buffer";
    begin
        Assert.IsTrue(PurchaseHeader.GetBySystemId(DocumentId), CannotFindDraftCreditMemoErr);

        PurchCrMemoEntityBuffer.SetRange(Id, DocumentId);
        Assert.IsTrue(PurchCrMemoEntityBuffer.FindFirst(), CannotFindDraftCreditMemoErr);
        Assert.AreEqual(Status, PurchCrMemoEntityBuffer.Status, CreditMemoStatusErr);
    end;

    local procedure VerifyPostedPurchaseCreditMemo(DocumentId: Guid; Status: Integer)
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoEntityBuffer: Record "Purch. Cr. Memo Entity Buffer";
    begin
        PurchCrMemoHdr.SetRange("Draft Cr. Memo SystemId", DocumentId);
        Assert.IsFalse(PurchCrMemoHdr.IsEmpty(), CannotFindPostedCreditMemoErr);

        PurchCrMemoEntityBuffer.SetRange(Id, DocumentId);
        Assert.IsTrue(PurchCrMemoEntityBuffer.FindFirst(), CannotFindPostedCreditMemoErr);
        Assert.AreEqual(Status, PurchCrMemoEntityBuffer.Status, CreditMemoStatusErr);
    end;
}

