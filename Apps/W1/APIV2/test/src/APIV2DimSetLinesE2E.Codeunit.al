codeunit 139825 "APIV2 - Dim. Set Lines E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Dimension Line]
    end;

    var
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryDimension: Codeunit "Library - Dimension";
        Assert: Codeunit "Assert";
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
        GraphMgtJournalLines: Codeunit "Graph Mgt - Journal Lines";
        LibraryGraphJournalLines: Codeunit "Library - Graph Journal Lines";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        ServiceNameTxt: Label 'dimensionSetLines';
        DimensionIdNameTxt: Label 'id';
        DimensionCodeNameTxt: Label 'code';
        DimensionValueIdNameTxt: Label 'valueId';
        DimensionValueCodeNameTxt: Label 'valueCode';

    procedure Initialize()
    begin
    end;

    [Test]
    procedure TestCreateJournalLineDimensionSetLine()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DocumentRecordRef: RecordRef;
        JournalName: Code[10];
        JournalLineGUID: Guid;
    begin
        // [SCENARIO] Create a dimension line in journal through a POST method and check if it was created
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateJournal();

        // [GIVEN] a line in the journal
        JournalLineGUID := CreateJournalLine(JournalName);

        DocumentRecordRef.GetTable(GenJournalLine);

        TestCreateDimSetLine(DocumentRecordRef, JournalLineGUID, Page::"APIV2 - JournalLines", 'journalLines');
    end;

    [Test]
    procedure TestCreateSalesOrderDimensionSetLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;

    begin
        // [SCENARIO] Create a dimension line in a sales order and a sales order line through a POST method and check if it was created
        // [GIVEN] A sales order
        LibrarySales.CreateSalesOrder(SalesHeader);
        DocumentRecordRef.GetTable(SalesHeader);

        TestCreateDimSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Orders", 'salesOrders');

        // [GIVEN] A sales order Line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestCreateDimSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Orders", 'salesOrders', 'salesOrderLines');
    end;

    [Test]
    procedure TestCreateSalesQuoteDimensionSetLine()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
        CustomerNo: Code[20];
    begin
        // [SCENARIO] Create a dimension line in a sales quote and sales quote line through a POST method and check if it was created
        // [GIVEN] A sales quote
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";
        LibrarySales.CreateSalesQuoteForCustomerNo(SalesHeader, CustomerNo);
        DocumentRecordRef.GetTable(SalesHeader);

        TestCreateDimSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Quotes", 'salesQuotes');

        // [GIVEN] A sales quote line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestCreateDimSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Quotes", 'salesQuotes', 'salesQuoteLines');
    end;

    [Test]
    procedure TestCreateSalesCrMemoDimensionSetLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a sales credit memo and a sales cr memo line through a POST method and check if it was created
        // [GIVEN] A sales credit memo
        LibrarySales.CreateSalesCreditMemo(SalesHeader);
        DocumentRecordRef.GetTable(SalesHeader);

        TestCreateDimSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Credit Memos", 'salesCreditMemos');

        // [GIVEN] A sales credit memo line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestCreateDimSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Credit Memos", 'salesCreditMemos', 'salesCreditMemoLines');
    end;

    [Test]
    procedure TestCreateSalesInvoiceDimensionSetLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a sales invoice and a sales invoice line through a POST method and check if it was created
        // [GIVEN] A sales invoice
        LibrarySales.CreateSalesInvoice(SalesHeader);
        DocumentRecordRef.GetTable(SalesHeader);

        TestCreateDimSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Invoices", 'salesInvoices');

        // [GIVEN] A sales invoice line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestCreateDimSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Invoices", 'salesInvoices', 'salesInvoiceLines');
    end;

    [Test]
    procedure TestCreatePurchaseInvoiceDimensionSetLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a purchase invoice and a purchase invoice line through a POST method and check if it was created
        // [GIVEN] A purchase invoice
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        DocumentRecordRef.GetTable(PurchaseHeader);

        TestCreateDimSetLine(DocumentRecordRef, PurchaseHeader.SystemId, Page::"APIV2 - Purchase Invoices", 'purchaseInvoices');

        // [GIVEN] A purchase invoice line
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineId := Format(PurchaseLine.SystemId);
        LineRecordRef.GetTable(PurchaseLine);

        TestCreateDimSetLineForLines(LineRecordRef, PurchaseHeader.SystemId, LineId, Page::"APIV2 - Purchase Invoices", 'purchaseInvoices', 'purchaseInvoiceLines');
    end;

    [Test]
    procedure TestCreatePurchaseOrderDimensionSetLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a purchase order and a purchase order line through a POST method and check if it was created
        // [GIVEN] A purchase order
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        DocumentRecordRef.GetTable(PurchaseHeader);

        TestCreateDimSetLine(DocumentRecordRef, PurchaseHeader.SystemId, Page::"APIV2 - Purchase Orders", 'purchaseOrders');

        // [GIVEN] A purchase order line
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineId := Format(PurchaseLine.SystemId);
        LineRecordRef.GetTable(PurchaseLine);

        TestCreateDimSetLineForLines(LineRecordRef, PurchaseHeader.SystemId, LineId, Page::"APIV2 - Purchase Orders", 'purchaseOrders', 'purchaseOrderLines');
    end;

    [Test]
    procedure TestCreateTimeRegEntryDimensionSetLine()
    var
        TimeSheetDetail: Record "Time Sheet Detail";
        UserSetup: Record "User Setup";
        GraphMgtTimeRegistration: Codeunit "Graph Mgt - Time Registration";
        DocumentRecordRef: RecordRef;
        TimeSheetDetailId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a time registration entry through a POST method and check if it was created
        // [GIVEN] A Time registration entry
        UserSetup.DeleteAll();
        GraphMgtTimeRegistration.InitUserSetup();
        TimeSheetDetailId := CreateTimeSheet();
        TimeSheetDetail.SetRange(SystemId, TimeSheetDetailId);
        TimeSheetDetail.FindFirst();
        DocumentRecordRef.GetTable(TimeSheetDetail);

        TestCreateDimSetLine(DocumentRecordRef, TimeSheetDetailId, Page::"APIV2 - Time Registr. Entries", 'timeRegistrationEntries');
    end;

    [Test]
    procedure TestCreateDimensionSetLineFailsWithoutParentId()
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Creating a dimension line through a POST method without specifying a parent Id fails
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a dimension with a value
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', DimensionCodeNameTxt, Dimension.Code);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, DimensionValueCodeNameTxt, DimensionValue.Code);
        Commit();

        // [WHEN] we POST the JSON to the web service
        // [THEN] the request fails because it doesn't have a parent Id
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Dimension Set Lines", ServiceNameTxt);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);
    end;

    [Test]
    procedure TestCreateDoesntWorkWithAlreadyExistingCode()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        JournalName: Code[10];
        JournalLineGUID: Guid;
        LineNo: Integer;
        LineJSON: array[2] of Text;
        DimensionCode: Code[20];
        DimensionValueCode: array[2] of Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Try to create a dimension line with an already existing code
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateJournal();

        // [GIVEN] a journal in the General Journal Table
        LineNo := LibraryGraphJournalLines.GetNextJournalLineNo(JournalName);
        JournalLineGUID := CreateJournalLine(JournalName);

        // [GIVEN] 2 dimension json texts
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode := Dimension.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValueCode[1] := DimensionValue.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValueCode[2] := DimensionValue.Code;
        LineJSON[1] := CreateDimensionJSON(DimensionCode, DimensionValueCode[1]);
        LineJSON[2] := CreateDimensionJSON(DimensionCode, DimensionValueCode[2]);
        Commit();

        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", 'journalLines', ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText);

        // [WHEN] we POST the JSON to the web service, with the journal filter
        ResponseText := '';
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[2], ResponseText);

        // [THEN] the POST should fail and the dimension should stay the same
        Assert.AreEqual('', ResponseText, 'The POST should fail.');

        GenJournalLine.SetRange("Journal Template Name", GraphMgtJournal.GetDefaultJournalLinesTemplateName());
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();
        Assert.IsTrue(
          DimensionSetIDContainsDimension(GenJournalLine."Dimension Set ID", DimensionCode, DimensionValueCode[1]),
          'The dimension line should exist in the SetID of the journal line.');
    end;

    [Test]
    procedure TestGetDimensionSetLinesOfJournalLines()
    var
        JournalName: Code[10];
        JournalLineGUID: Guid;
    begin
        // [SCENARIO] Create dimension lines in a journal line and use a GET method to retrieve them
        // [GIVEN] a journal in the General Journal Table
        LibraryGraphJournalLines.Initialize();

        JournalName := LibraryGraphJournalLines.CreateJournal();
        JournalLineGUID := CreateJournalLine(JournalName);

        TestGetDimSetLines(JournalLineGUID, 'Journal Line', Page::"APIV2 - JournalLines", 'journalLines');
    end;

    [Test]
    procedure TestGetDimensionSetLinesOfSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineId: Guid;
    begin
        // [SCENARIO] Create dimension lines in a sales order and sales order line and use a GET method to retrieve them
        // [GIVEN] a sales order with lines
        LibrarySales.CreateSalesOrder(SalesHeader);

        TestGetDimSetLines(SalesHeader.SystemId, 'Sales Order', Page::"APIV2 - Sales Orders", 'salesOrders');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);

        TestGetDimSetLinesForLines(LineId, SalesHeader.SystemId, 'Sales Order Line', Page::"APIV2 - Sales Orders", 'salesOrders', 'salesOrderLines');
    end;

    [Test]
    procedure TestGetDimensionSetLinesOfSalesQuote()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        CustomerNo: Code[20];
        LineId: Guid;
    begin
        // [SCENARIO] Create dimension lines in a sales quote and sales quote line and use a GET method to retrieve them
        // [GIVEN] a sales quote with lines
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";
        LibrarySales.CreateSalesQuoteForCustomerNo(SalesHeader, CustomerNo);

        TestGetDimSetLines(SalesHeader.SystemId, 'Sales Quote', Page::"APIV2 - Sales Quotes", 'salesQuotes');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);

        TestGetDimSetLinesForLines(LineId, SalesHeader.SystemId, 'Sales Quote Line', Page::"APIV2 - Sales Quotes", 'salesQuotes', 'salesQuoteLines');
    end;

    [Test]
    procedure TestGetDimensionSetLinesOfSalesCrMemo()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineId: Guid;
    begin
        // [SCENARIO] Create dimension lines in a sales cr memo and sales cr memo line and use a GET method to retrieve them
        // [GIVEN] a sales cr memo with lines
        LibrarySales.CreateSalesCreditMemo(SalesHeader);

        TestGetDimSetLines(SalesHeader.SystemId, 'Sales Credit Memo', Page::"APIV2 - Sales Credit Memos", 'salesCreditMemos');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);

        TestGetDimSetLinesForLines(LineId, SalesHeader.SystemId, 'Sales Credit Memo Line', Page::"APIV2 - Sales Credit Memos", 'salesCreditMemos', 'salesCreditMemoLines');
    end;

    [Test]
    procedure TestGetDimensionSetLinesOfSalesInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineId: Guid;
    begin
        // [SCENARIO] Create dimension lines in a sales invoice and sales invoice line and use a GET method to retrieve them
        // [GIVEN] a sales invoice with lines
        LibrarySales.CreateSalesInvoice(SalesHeader);

        TestGetDimSetLines(SalesHeader.SystemId, 'Sales Invoice', Page::"APIV2 - Sales Invoices", 'salesInvoices');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);

        TestGetDimSetLinesForLines(LineId, SalesHeader.SystemId, 'Sales Invoice Line', Page::"APIV2 - Sales Invoices", 'salesInvoices', 'salesInvoiceLines');
    end;

    [Test]
    procedure TestGetDimensionSetLinesOfPurchaseInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineId: Guid;
    begin
        // [SCENARIO] Create dimension lines in a pucrhase invoice and purchase invoice line and use a GET method to retrieve them
        // [GIVEN] a purchase invoice with lines
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);

        TestGetDimSetLines(PurchaseHeader.SystemId, 'Purchase Invoice', Page::"APIV2 - Purchase Invoices", 'purchaseInvoices');

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineId := Format(PurchaseLine.SystemId);

        TestGetDimSetLinesForLines(LineId, PurchaseHeader.SystemId, 'Purchase Invoice Line', Page::"APIV2 - Purchase Invoices", 'purchaseInvoices', 'purchaseInvoiceLines');
    end;

    [Test]
    procedure TestGetDimensionSetLinesOfPurchaseOrder()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineId: Guid;
    begin
        // [SCENARIO] Create dimension lines in a pucrhase order and purchase order line and use a GET method to retrieve them
        // [GIVEN] a purchase order with lines
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);

        TestGetDimSetLines(PurchaseHeader.SystemId, 'Purchase Order', Page::"APIV2 - Purchase Orders", 'purchaseOrders');

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineId := Format(PurchaseLine.SystemId);

        TestGetDimSetLinesForLines(LineId, PurchaseHeader.SystemId, 'Purchase Order Line', Page::"APIV2 - Purchase Orders", 'purchaseOrders', 'purchaseOrderLines');
    end;

    [Test]
    procedure TestGetDimensionSetLinesOfTimeRegEntry()
    var
        TimeSheetDetail: Record "Time Sheet Detail";
        UserSetup: Record "User Setup";
        GraphMgtTimeRegistration: Codeunit "Graph Mgt - Time Registration";
        DocumentRecordRef: RecordRef;
        TimeSheetDetailId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a time registration entry through a POST method and and use a GET method to retrieve them
        // [GIVEN] A Time registration entry
        UserSetup.DeleteAll();
        GraphMgtTimeRegistration.InitUserSetup();
        TimeSheetDetailId := CreateTimeSheet();
        TimeSheetDetail.SetRange(SystemId, TimeSheetDetailId);
        TimeSheetDetail.FindFirst();
        DocumentRecordRef.GetTable(TimeSheetDetail);

        TestGetDimSetLines(TimeSheetDetailId, 'Time Registration Entry', Page::"APIV2 - Time Registr. Entries", 'timeRegistrationEntries');
    end;

    [Test]
    procedure TestGetDimensionSetLinesOfGLEntry()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Dimension: Record "Dimension";
        DefaultDimension: Record "Default Dimension";
        DocumentNo: Code[20];
        GLEntryId: Guid;
        ResponseText: Text;
        TargetURL: Text;
        DimensionSetValue: Text;
    begin
        // [SCENARIO] Create a G/L Entry with dimenions after Posting Sales Invoice and use a GET method to retreive them

        // [GIVEN] Create Customer, Items and Sales Invoice for different Items.
        LibraryDimension.FindDimension(Dimension);
        CreateSalesOrder(
          SalesHeader, SalesLine, '', Dimension.Code, DefaultDimension."Value Posting"::" ", SalesHeader."Document Type"::Invoice);

        // [WHEN] Post the Sales Invoice.
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, false, false);

        // [THEN] Verify that the dimension was created
        GLEntryId := VerifyGLEntryDimension(SalesLine, DocumentNo);

        // [WHEN] we GET the JSON to the web service
        TargetURL := GetTargetURLWithExpandDimensions(GLEntryId, Page::"APIV2 - G/L Entries", 'generalLedgerEntries');
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the dimension set lines of the response must have a parent id the same as the receipt id
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'dimensionSetLines', DimensionSetValue);
        VerifyDimensions(DimensionSetValue, LowerCase(Format(GLEntryId)));
    end;

    [Test]
    procedure TestGetDimensionSetLinesFailsWithoutFilter()
    var
        GLAccount: Record "G/L Account";
        AccountNo: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Using a GET request to retrieve dimension lines without a filter fails
        LibraryGraphJournalLines.Initialize();

        AccountNo := LibraryGraphJournalLines.CreateAccount();
        GLAccount.Get(AccountNo);

        // [GIVEN] a Target URL without filters
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Dimension Set Lines", ServiceNameTxt);

        // [WHEN] we GET from the web service
        // [THEN] the request fails
        asserterror LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);
    end;

    [Test]
    procedure TestModifyDimensionSetLineOfGenJournalLine()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DocumentRecordRef: RecordRef;
        JournalName: Code[10];
        JournalLineGUID: Guid;
    begin
        // [SCENARIO] Create a dimension line, use a PATCH method to change it and then verify the changes
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal and a journal line
        JournalName := LibraryGraphJournalLines.CreateJournal();
        JournalLineGUID := CreateJournalLine(JournalName);

        DocumentRecordRef.GetTable(GenJournalLine);

        TestModifyDimensionSetLine(DocumentRecordRef, JournalLineGUID, Page::"APIV2 - JournalLines", 'journalLines');
    end;

    [Test]
    procedure TestModifyDimensionSetLineOfSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a sales order and a sales order line, use a PATCH method to change it and then verify the changes
        // [GIVEN] A sales order
        LibrarySales.CreateSalesOrder(SalesHeader);
        DocumentRecordRef.GetTable(SalesHeader);

        TestModifyDimensionSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Orders", 'salesOrders');

        // [GIVEN] A sales order Line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestModifyDimensionSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Orders", 'salesOrders', 'salesOrderLines');
    end;

    [Test]
    procedure TestModifyDimensionSetLineOfSalesQuote()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
        CustomerNo: Code[20];
    begin
        // [SCENARIO] Create a dimension line in a sales quote and a sales quote line, use a PATCH method to change it and then verify the changes
        // [GIVEN] A sales quote
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";
        LibrarySales.CreateSalesQuoteForCustomerNo(SalesHeader, CustomerNo);
        DocumentRecordRef.GetTable(SalesHeader);

        TestModifyDimensionSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Quotes", 'salesQuotes');

        // [GIVEN] A sales quote Line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestModifyDimensionSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Quotes", 'salesQuotes', 'salesQuoteLines');
    end;

    [Test]
    procedure TestModifySalesCrMemoDimensionSetLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a sales credit memo and a sales cr memo line, use a PATCH method to change it and then verify the changes
        // [GIVEN] A sales credit memo
        LibrarySales.CreateSalesCreditMemo(SalesHeader);
        DocumentRecordRef.GetTable(SalesHeader);

        TestModifyDimensionSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Credit Memos", 'salesCreditMemos');

        // [GIVEN] A sales credit memo line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestModifyDimensionSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Credit Memos", 'salesCreditMemos', 'salesCreditMemoLines');
    end;

    [Test]
    procedure TestModifySalesInvoiceDimensionSetLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a sales invoice and a sales invoice line, use a PATCH method to change it and then verify the changes
        // [GIVEN] A sales invoice
        LibrarySales.CreateSalesInvoice(SalesHeader);
        DocumentRecordRef.GetTable(SalesHeader);

        TestModifyDimensionSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Invoices", 'salesInvoices');

        // [GIVEN] A sales invoice line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestModifyDimensionSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Invoices", 'salesInvoices', 'salesInvoiceLines');
    end;

    [Test]
    procedure TestModifyPurchaseInvoiceDimensionSetLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a purchase invoice and a purchase invoice line, use a PATCH method to change it and then verify the changes
        // [GIVEN] A purchase invoice
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        DocumentRecordRef.GetTable(PurchaseHeader);

        TestModifyDimensionSetLine(DocumentRecordRef, PurchaseHeader.SystemId, Page::"APIV2 - Purchase Invoices", 'purchaseInvoices');

        // [GIVEN] A purchase invoice line
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineId := Format(PurchaseLine.SystemId);
        LineRecordRef.GetTable(PurchaseLine);

        TestModifyDimensionSetLineForLines(LineRecordRef, PurchaseHeader.SystemId, LineId, Page::"APIV2 - Purchase Invoices", 'purchaseInvoices', 'purchaseInvoiceLines');
    end;

    [Test]
    procedure TestModifyPurchaseOrderDimensionSetLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a purchase order and a purchase order line, use a PATCH method to change it and then verify the changes
        // [GIVEN] A purchase order
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        DocumentRecordRef.GetTable(PurchaseHeader);

        TestModifyDimensionSetLine(DocumentRecordRef, PurchaseHeader.SystemId, Page::"APIV2 - Purchase Orders", 'purchaseOrders');

        // [GIVEN] A purchase order line
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineId := Format(PurchaseLine.SystemId);
        LineRecordRef.GetTable(PurchaseLine);

        TestModifyDimensionSetLineForLines(LineRecordRef, PurchaseHeader.SystemId, LineId, Page::"APIV2 - Purchase Orders", 'purchaseOrders', 'purchaseOrderLines');
    end;

    [Test]
    procedure TestModifyTimeRegEntryDimensionSetLine()
    var
        TimeSheetDetail: Record "Time Sheet Detail";
        UserSetup: Record "User Setup";
        GraphMgtTimeRegistration: Codeunit "Graph Mgt - Time Registration";
        DocumentRecordRef: RecordRef;
        TimeSheetDetailId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a time registration entry, use a PATCH method to change it and then verify the changes
        // [GIVEN] A Time registration entry
        UserSetup.DeleteAll();
        GraphMgtTimeRegistration.InitUserSetup();
        TimeSheetDetailId := CreateTimeSheet();
        TimeSheetDetail.SetRange(SystemId, TimeSheetDetailId);
        TimeSheetDetail.FindFirst();
        DocumentRecordRef.GetTable(TimeSheetDetail);

        TestModifyDimensionSetLine(DocumentRecordRef, TimeSheetDetailId, Page::"APIV2 - Time Registr. Entries", 'timeRegistrationEntries');
    end;

    local procedure TestModifyDimensionSetLine(DocumentRecordRef: RecordRef; DocumentId: Guid; APIPage: Integer; DocServiceNameTxt: Text)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        GenJournalLine: Record "Gen. Journal Line";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TimeSheetDetail: Record "Time Sheet Detail";
        DimensionGUID: Guid;
        LineJSON: array[2] of Text;
        DimensionCode: Code[20];
        DimensionValueCode: array[2] of Code[20];
        ResponseText: Text;
        TargetURL: Text;
        DimensionSetID: Integer;
    begin
        // [GIVEN] 2 dimension json texts
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode := Dimension.Code;
        DimensionGUID := Dimension.SystemId;
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValueCode[1] := DimensionValue.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValueCode[2] := DimensionValue.Code;
        LineJSON[1] := CreateDimensionJSON(DimensionCode, DimensionValueCode[1]);

        // [GIVEN] a json text with the new dimension value
        LineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', DimensionValueCodeNameTxt, DimensionValueCode[2]);
        Commit();

        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, APIPage, DocServiceNameTxt, ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText);

        // [WHEN] we PATCH the JSON to the web service, with the corresponding keys
        ResponseText := '';
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, APIPage, DocServiceNameTxt, ServiceNameTxt) + '(' + LibraryGraphMgt.StripBrackets(Format(DimensionGUID)) + ')';
        LibraryGraphMgt.PatchToWebService(TargetURL, LineJSON[2], ResponseText);

        // [THEN] the dimension lines in the journal should have the values that were given
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        VerifyJSONContainsDimensionValues(ResponseText, DimensionCode, DimensionValueCode[2]);

        case DocumentRecordRef.Number() of
            Database::"Gen. Journal Line":
                begin
                    GenJournalLine.SetRange("Journal Template Name", GraphMgtJournal.GetDefaultJournalLinesTemplateName());
                    GenJournalLine.SetRange(SystemId, DocumentId);
                    GenJournalLine.FindFirst();
                    DimensionSetID := GenJournalLine."Dimension Set ID";
                end;
            Database::"Sales Header":
                begin
                    SalesHeader.SetRange(SystemId, DocumentId);
                    SalesHeader.FindFirst();
                    DimensionSetID := SalesHeader."Dimension Set ID";
                end;
            Database::"Purchase Header":
                begin
                    PurchaseHeader.SetRange(SystemId, DocumentId);
                    PurchaseHeader.FindFirst();
                    DimensionSetID := PurchaseHeader."Dimension Set ID";
                end;
            Database::"Time Sheet Detail":
                begin
                    TimeSheetDetail.SetRange(SystemId, DocumentId);
                    TimeSheetDetail.FindFirst();
                    DimensionSetID := TimeSheetDetail."Dimension Set ID";
                end;
        end;

        Assert.IsTrue(
          DimensionSetIDContainsDimension(DimensionSetID, DimensionCode, DimensionValueCode[2]),
          'The dimension line should exist in the SetID of the journal line.');
    end;

    [Test]
    procedure TestModifyOfDimensionCodeDoesntWork()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        JournalName: Code[10];
        JournalLineGUID: Guid;
        DimensionGUID: Guid;
        LineJSON: array[2] of Text;
        DimensionCode: array[2] of Code[20];
        DimensionValueCode: array[2] of Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Try to change the code of an existing dimension line
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal and a journal line
        JournalName := LibraryGraphJournalLines.CreateJournal();
        JournalLineGUID := CreateJournalLine(JournalName);

        // [GIVEN] 2 dimensions with dimension values
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode[1] := Dimension.Code;
        DimensionGUID := Dimension.SystemId;
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode[2] := Dimension.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionCode[1]);
        DimensionValueCode[1] := DimensionValue.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionCode[2]);
        DimensionValueCode[2] := DimensionValue.Code;

        LineJSON[1] := CreateDimensionJSON(DimensionCode[1], DimensionValueCode[1]);
        LineJSON[2] := CreateDimensionJSON(DimensionCode[2], DimensionValueCode[2]);
        Commit();

        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", 'journalLines', ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText);

        // [WHEN] we PATCH the JSON to the web service, with the new dimension code
        ResponseText := '';
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", 'journalLines', ServiceNameTxt) + '(' + LibraryGraphMgt.StripBrackets(Format(DimensionGUID)) + ')';
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, LineJSON[2], ResponseText);

        // [THEN] the patch should fail and the dimension line should remain the same
        Assert.AreEqual('', ResponseText, 'The PATCH should fail.');

        GenJournalLine.GetBySystemId(JournalLineGUID);
        Assert.IsTrue(
          DimensionSetIDContainsDimension(GenJournalLine."Dimension Set ID", DimensionCode[1], DimensionValueCode[1]),
          'The dimension line should exist in the SetID of the journal line.');
    end;

    [Test]
    procedure TestDeleteDimensionSetLineOfGenJournalLines()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DocumentRecordRef: RecordRef;
        JournalName: Code[10];
        JournalLineGUID: Guid;
    begin
        // [SCENARIO] Create a dimension line, use a DELETE method to remove it and then verify the deletion
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal and a journal line
        JournalName := LibraryGraphJournalLines.CreateJournal();
        JournalLineGUID := CreateJournalLine(JournalName);

        DocumentRecordRef.GetTable(GenJournalLine);

        TestDeleteDimSetLine(DocumentRecordRef, JournalLineGUID, Page::"APIV2 - JournalLines", 'journalLines');
    end;

    [Test]
    procedure TestDeleteSalesOrderDimensionSetLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;

    begin
        // [SCENARIO] Create a dimension line in a sales order and a sales order, use a DELETE method to remove it and then verify the deletion
        // [GIVEN] A sales order
        LibrarySales.CreateSalesOrder(SalesHeader);
        DocumentRecordRef.GetTable(SalesHeader);

        TestDeleteDimSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Orders", 'salesOrders');

        // [GIVEN] A sales order Line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestDeleteDimSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Orders", 'salesOrders', 'salesOrderLines');
    end;

    [Test]
    procedure TestDeleteSalesQuoteDimensionSetLine()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
        CustomerNo: Code[20];
    begin
        // [SCENARIO] Create a dimension line in a sales quote and sales quote line, use a DELETE method to remove it and then verify the deletion
        // [GIVEN] A sales quote
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";
        LibrarySales.CreateSalesQuoteForCustomerNo(SalesHeader, CustomerNo);
        DocumentRecordRef.GetTable(SalesHeader);

        TestDeleteDimSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Quotes", 'salesQuotes');

        // [GIVEN] A sales quote line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestDeleteDimSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Quotes", 'salesQuotes', 'salesQuoteLines');
    end;

    [Test]
    procedure TestDeleteSalesCrMemoDimensionSetLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a sales credit memo and a sales cr memo line, use a DELETE method to remove it and then verify the deletion
        // [GIVEN] A sales credit memo
        LibrarySales.CreateSalesCreditMemo(SalesHeader);
        DocumentRecordRef.GetTable(SalesHeader);

        TestDeleteDimSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Credit Memos", 'salesCreditMemos');

        // [GIVEN] A sales credit memo line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestDeleteDimSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Credit Memos", 'salesCreditMemos', 'salesCreditMemoLines');
    end;

    [Test]
    procedure TestDeleteSalesInvoiceDimensionSetLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a sales invoice and a sales invoice line, use a DELETE method to remove it and then verify the deletion
        // [GIVEN] A sales invoice
        LibrarySales.CreateSalesInvoice(SalesHeader);
        DocumentRecordRef.GetTable(SalesHeader);

        TestDeleteDimSetLine(DocumentRecordRef, SalesHeader.SystemId, Page::"APIV2 - Sales Invoices", 'salesInvoices');

        // [GIVEN] A sales invoice line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LineId := Format(SalesLine.SystemId);
        LineRecordRef.GetTable(SalesLine);

        TestDeleteDimSetLineForLines(LineRecordRef, SalesHeader.SystemId, LineId, Page::"APIV2 - Sales Invoices", 'salesInvoices', 'salesInvoiceLines');
    end;

    [Test]
    procedure TestDeletePurchaseInvoiceDimensionSetLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a purchase invoice and a purchase invoice line, use a DELETE method to remove it and then verify the deletion
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        DocumentRecordRef.GetTable(PurchaseHeader);

        TestDeleteDimSetLine(DocumentRecordRef, PurchaseHeader.SystemId, Page::"APIV2 - Purchase Invoices", 'purchaseInvoices');

        // [GIVEN] A purchase invoice line
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineId := Format(PurchaseLine.SystemId);
        LineRecordRef.GetTable(PurchaseLine);

        TestDeleteDimSetLineForLines(LineRecordRef, PurchaseHeader.SystemId, LineId, Page::"APIV2 - Purchase Invoices", 'purchaseInvoices', 'purchaseInvoiceLines');
    end;

    [Test]
    procedure TestDeletePurchaseOrderDimensionSetLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentRecordRef: RecordRef;
        LineRecordRef: RecordRef;
        LineId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a purchase order and a purchase order, use a DELETE method to remove it and then verify the deletion
        // [GIVEN] A purchase order
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        DocumentRecordRef.GetTable(PurchaseHeader);

        TestDeleteDimSetLine(DocumentRecordRef, PurchaseHeader.SystemId, Page::"APIV2 - Purchase Orders", 'purchaseOrders');

        // [GIVEN] A purchase order line
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineId := Format(PurchaseLine.SystemId);
        LineRecordRef.GetTable(PurchaseLine);

        TestDeleteDimSetLineForLines(LineRecordRef, PurchaseHeader.SystemId, LineId, Page::"APIV2 - Purchase Orders", 'purchaseOrders', 'purchaseOrderLines');
    end;

    [Test]
    procedure TestDeleteTimeRegEntryDimensionSetLine()
    var
        TimeSheetDetail: Record "Time Sheet Detail";
        DocumentRecordRef: RecordRef;
        TimeSheetDetailId: Guid;
    begin
        // [SCENARIO] Create a dimension line in a time registration entry, use a DELETE method to remove it and then verify the deletion
        // [GIVEN] A Time registration entry
        TimeSheetDetailId := CreateTimeSheet();
        TimeSheetDetail.SetRange(SystemId, TimeSheetDetailId);
        TimeSheetDetail.FindFirst();
        DocumentRecordRef.GetTable(TimeSheetDetail);

        TestDeleteDimSetLine(DocumentRecordRef, TimeSheetDetailId, Page::"APIV2 - Time Registr. Entries", 'timeRegistrationEntries');
    end;

    local procedure TestDeleteDimSetLine(DocumentRecordRef: RecordRef; DocumentId: Guid; APIPage: Integer; DocServiceNameTxt: Text)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        GenJournalLine: Record "Gen. Journal Line";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TimeSheetDetail: Record "Time Sheet Detail";
        DimensionSetID: Integer;
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [GIVEN] a dimension line in the journal line
        LibraryDimension.CreateDimension(Dimension);
        DimensionValue.Reset();
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LineJSON := CreateDimensionJSON(Dimension.Code, DimensionValue.Code);
        Commit();

        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, APIPage, DocServiceNameTxt, ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [WHEN] we DELETE the dimension line from the web service, with the corresponding keys
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, APIPage, DocServiceNameTxt, ServiceNameTxt) + '(' + LibraryGraphMgt.StripBrackets(Format(Dimension.SystemId)) + ')';
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        case DocumentRecordRef.Number() of
            Database::"Gen. Journal Line":
                begin
                    GenJournalLine.SetRange("Journal Template Name", GraphMgtJournal.GetDefaultJournalLinesTemplateName());
                    GenJournalLine.SetRange(SystemId, DocumentId);
                    GenJournalLine.FindFirst();
                    DimensionSetID := GenJournalLine."Dimension Set ID";
                end;
            Database::"Sales Header":
                begin
                    SalesHeader.SetRange(SystemId, DocumentId);
                    SalesHeader.FindFirst();
                    DimensionSetID := SalesHeader."Dimension Set ID";
                end;
            Database::"Purchase Header":
                begin
                    PurchaseHeader.SetRange(SystemId, DocumentId);
                    PurchaseHeader.FindFirst();
                    DimensionSetID := PurchaseHeader."Dimension Set ID";
                end;
            Database::"Time Sheet Detail":
                begin
                    TimeSheetDetail.SetRange(SystemId, DocumentId);
                    TimeSheetDetail.FindFirst();
                    DimensionSetID := TimeSheetDetail."Dimension Set ID";
                end;
        end;

        // [THEN] the dimension line shouldn't exist in the table
        Assert.IsFalse(
          DimensionSetIDContainsDimension(DimensionSetID, Dimension.Code, DimensionValue.Code),
          'The dimension line shouldn''t exist in the SetID of the journal line.');
    end;

    local procedure TestDeleteDimSetLineForLines(LineRecordRef: RecordRef; ParentId: Guid; LineId: Guid; ParentAPIPage: Integer; ParentServiceNameTxt: Text; LineServiceNameTxt: Text)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        DimensionSetID: Integer;
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [GIVEN] a dimension line in the journal line
        LibraryDimension.CreateDimension(Dimension);
        DimensionValue.Reset();
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LineJSON := CreateDimensionJSON(Dimension.Code, DimensionValue.Code);
        Commit();

        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(ParentId, ParentAPIPage, ParentServiceNameTxt, LineServiceNameTxt);
        TargetURL := TargetURL + '(' + LibraryGraphMgt.StripBrackets(LineId) + ')' + '/dimensionSetLines';
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [WHEN] we DELETE the dimension line from the web service, with the corresponding keys
        ResponseText := '';
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(ParentId, ParentAPIPage, ParentServiceNameTxt, LineServiceNameTxt);
        TargetURL := TargetURL + '(' + LibraryGraphMgt.StripBrackets(LineId) + ')' + '/dimensionSetLines';
        TargetURL := TargetURL + '(' + LibraryGraphMgt.StripBrackets(Format(Dimension.SystemId)) + ')';

        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        case LineRecordRef.Number() of
            Database::"Sales Line":
                begin
                    SalesLine.SetRange(SystemId, LineId);
                    SalesLine.FindFirst();
                    DimensionSetID := SalesLine."Dimension Set ID";
                end;
            Database::"Purchase Line":
                begin
                    PurchaseLine.SetRange(SystemId, LineId);
                    PurchaseLine.FindFirst();
                    DimensionSetID := PurchaseLine."Dimension Set ID";
                end;
        end;

        // [THEN] the dimension line shouldn't exist in the table
        Assert.IsFalse(
          DimensionSetIDContainsDimension(DimensionSetID, Dimension.Code, DimensionValue.Code),
          'The dimension line shouldn''t exist in the SetID of the journal line.');
    end;

    local procedure TestCreateDimSetLine(DocumentRecordRef: RecordRef; DocumentId: Guid; APIPage: Integer; DocServiceNameTxt: Text)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        GenJournalLine: Record "Gen. Journal Line";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TimeSheetDetail: Record "Time Sheet Detail";
        DimensionSetID: Integer;
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [GIVEN] a dimension with a value
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LineJSON := CreateDimensionJSON(Dimension.Code, DimensionValue.Code);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, DimensionIdNameTxt, LibraryGraphMgt.StripBrackets(Format(Dimension.SystemId)));
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, DimensionValueIdNameTxt, LibraryGraphMgt.StripBrackets(Format(DimensionValue.SystemId)));
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, APIPage, DocServiceNameTxt, ServiceNameTxt);

        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the dimension information and the journal should have the new dimension
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        VerifyJSONContainsDimensionValues(ResponseText, Dimension.Code, DimensionValue.Code);

        case DocumentRecordRef.Number() of
            Database::"Gen. Journal Line":
                begin
                    GenJournalLine.SetRange("Journal Template Name", GraphMgtJournal.GetDefaultJournalLinesTemplateName());
                    GenJournalLine.SetRange(SystemId, DocumentId);
                    GenJournalLine.FindFirst();
                    DimensionSetID := GenJournalLine."Dimension Set ID";
                end;
            Database::"Sales Header":
                begin
                    SalesHeader.SetRange(SystemId, DocumentId);
                    SalesHeader.FindFirst();
                    DimensionSetID := SalesHeader."Dimension Set ID";
                end;
            Database::"Purchase Header":
                begin
                    PurchaseHeader.SetRange(SystemId, DocumentId);
                    PurchaseHeader.FindFirst();
                    DimensionSetID := PurchaseHeader."Dimension Set ID";
                end;
            Database::"Time Sheet Detail":
                begin
                    TimeSheetDetail.SetRange(SystemId, DocumentId);
                    TimeSheetDetail.FindFirst();
                    DimensionSetID := TimeSheetDetail."Dimension Set ID";
                end;
        end;

        Assert.IsTrue(DimensionSetIDContainsDimension(DimensionSetID, Dimension.Code, DimensionValue.Code),
                       'The dimension line should exist in the SetID of the journal line.');
    end;

    local procedure TestCreateDimSetLineForLines(LineRecordRef: RecordRef; ParentId: Guid; LineId: Guid; ParentAPIPage: Integer; ParentServiceNameTxt: Text; LineServiceNameTxt: Text)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        DimensionSetID: Integer;
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [GIVEN] a dimension with a value
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LineJSON := CreateDimensionJSON(Dimension.Code, DimensionValue.Code);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, DimensionIdNameTxt, LibraryGraphMgt.StripBrackets(Format(Dimension.SystemId)));
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, DimensionValueIdNameTxt, LibraryGraphMgt.StripBrackets(Format(DimensionValue.SystemId)));
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(ParentId, ParentAPIPage, ParentServiceNameTxt, LineServiceNameTxt);
        TargetURL := TargetURL + '(' + LibraryGraphMgt.StripBrackets(LineId) + ')' + '/dimensionSetLines';

        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the dimension information and the journal should have the new dimension
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        VerifyJSONContainsDimensionValues(ResponseText, Dimension.Code, DimensionValue.Code);

        case LineRecordRef.Number() of
            Database::"Sales Line":
                begin
                    SalesLine.SetRange(SystemId, LineId);
                    SalesLine.FindFirst();
                    DimensionSetID := SalesLine."Dimension Set ID";
                end;
            Database::"Purchase Line":
                begin
                    PurchaseLine.SetRange(SystemId, LineId);
                    PurchaseLine.FindFirst();
                    DimensionSetID := PurchaseLine."Dimension Set ID";
                end;
        end;

        Assert.IsTrue(DimensionSetIDContainsDimension(DimensionSetID, Dimension.Code, DimensionValue.Code),
                       'The dimension line should exist in the SetID of the journal line.');
    end;

    local procedure TestGetDimSetLines(DocumentId: Guid; DocumentTypeTxt: Text; APIPage: Integer; DocServiceNameTxt: Text)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        LineJSON: array[2] of Text;
        DimensionCode: array[2] of Code[20];
        DimensionValueCode: array[2] of Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [GIVEN] 2 dimensions with dimension values
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode[2] := Dimension.Code;
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode[1] := Dimension.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionCode[2]);
        DimensionValueCode[2] := DimensionValue.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionCode[1]);
        DimensionValueCode[1] := DimensionValue.Code;

        LineJSON[2] := CreateDimensionJSON(DimensionCode[2], DimensionValueCode[2]);
        LineJSON[1] := CreateDimensionJSON(DimensionCode[1], DimensionValueCode[1]);
        Commit();

        // [GIVEN] the dimension lines are added
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, APIPage, DocServiceNameTxt, ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[2], ResponseText);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText);

        // [WHEN] we GET the JSON to the web service
        ResponseText := '';
        TargetURL := CreateDimensionSetLinesURLWithFilter(DocumentId, DocumentTypeTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 dimension lines should exist in the response
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, DimensionCodeNameTxt, DimensionCode[2], DimensionCode[1], LineJSON[2], LineJSON[1]),
          'Could not find the lines in JSON');
        VerifyJSONContainsDimensionValues(LineJSON[2], DimensionCode[2], DimensionValueCode[2]);
        VerifyJSONContainsDimensionValues(LineJSON[1], DimensionCode[1], DimensionValueCode[1]);
    end;

    local procedure TestGetDimSetLinesForLines(DocumentId: Guid; ParentId: Guid; DocumentTypeTxt: Text; ParentAPIPage: Integer; ParentServiceNameTxt: Text; LineServiceNameTxt: Text)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        LineJSON: array[2] of Text;
        DimensionCode: array[2] of Code[20];
        DimensionValueCode: array[2] of Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [GIVEN] 2 dimensions with dimension values
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode[2] := Dimension.Code;
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode[1] := Dimension.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionCode[2]);
        DimensionValueCode[2] := DimensionValue.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionCode[1]);
        DimensionValueCode[1] := DimensionValue.Code;

        LineJSON[2] := CreateDimensionJSON(DimensionCode[2], DimensionValueCode[2]);
        LineJSON[1] := CreateDimensionJSON(DimensionCode[1], DimensionValueCode[1]);
        Commit();

        // [GIVEN] the dimension lines are added
        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(ParentId, ParentAPIPage, ParentServiceNameTxt, LineServiceNameTxt);
        TargetURL := TargetURL + '(' + LibraryGraphMgt.StripBrackets(DocumentId) + ')' + '/dimensionSetLines';
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[2], ResponseText);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText);

        // [WHEN] we POST the JSON to the web service
        ResponseText := '';
        TargetURL := CreateDimensionSetLinesURLWithFilter(DocumentId, DocumentTypeTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 dimension lines should exist in the response
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, DimensionCodeNameTxt, DimensionCode[2], DimensionCode[1], LineJSON[2], LineJSON[1]),
          'Could not find the lines in JSON');
        VerifyJSONContainsDimensionValues(LineJSON[2], DimensionCode[2], DimensionValueCode[2]);
        VerifyJSONContainsDimensionValues(LineJSON[1], DimensionCode[1], DimensionValueCode[1]);
    end;

    local procedure TestModifyDimensionSetLineForLines(LineRecordRef: RecordRef; ParentId: Guid; LineId: Guid; ParentAPIPage: Integer; ParentServiceNameTxt: Text; LineServiceNameTxt: Text)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        DimensionGUID: Guid;
        LineJSON: array[2] of Text;
        DimensionCode: Code[20];
        DimensionValueCode: array[2] of Code[20];
        ResponseText: Text;
        TargetURL: Text;
        DimensionSetID: Integer;
    begin
        // [GIVEN] 2 dimension json texts
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode := Dimension.Code;
        DimensionGUID := Dimension.SystemId;
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValueCode[1] := DimensionValue.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValueCode[2] := DimensionValue.Code;
        LineJSON[1] := CreateDimensionJSON(DimensionCode, DimensionValueCode[1]);

        // [GIVEN] a json text with the new dimension value
        LineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', DimensionValueCodeNameTxt, DimensionValueCode[2]);
        Commit();

        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(ParentId, ParentAPIPage, ParentServiceNameTxt, LineServiceNameTxt);
        TargetURL := TargetURL + '(' + LibraryGraphMgt.StripBrackets(LineId) + ')' + '/dimensionSetLines';

        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText);

        // [WHEN] we PATCH the JSON to the web service, with the corresponding keys
        ResponseText := '';
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(ParentId, ParentAPIPage, ParentServiceNameTxt, LineServiceNameTxt);
        TargetURL := TargetURL + '(' + LibraryGraphMgt.StripBrackets(LineId) + ')' + '/dimensionSetLines';
        TargetURL := TargetURL + '(' + LibraryGraphMgt.StripBrackets(Format(DimensionGUID)) + ')';
        LibraryGraphMgt.PatchToWebService(TargetURL, LineJSON[2], ResponseText);

        // [THEN] the dimension lines in the journal should have the values that were given
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        VerifyJSONContainsDimensionValues(ResponseText, DimensionCode, DimensionValueCode[2]);

        case LineRecordRef.Number() of
            Database::"Sales Line":
                begin
                    SalesLine.SetRange(SystemId, LineId);
                    SalesLine.FindFirst();
                    DimensionSetID := SalesLine."Dimension Set ID";
                end;
            Database::"Purchase Line":
                begin
                    PurchaseLine.SetRange(SystemId, LineId);
                    PurchaseLine.FindFirst();
                    DimensionSetID := PurchaseLine."Dimension Set ID";
                end;
        end;

        Assert.IsTrue(
          DimensionSetIDContainsDimension(DimensionSetID, DimensionCode, DimensionValueCode[2]),
          'The dimension line should exist in the SetID of the journal line.');
    end;

    local procedure CreateDimensionJSON(DimensionCode: Code[20]; DimensionValueCode: Code[20]): Text
    var
        LineJSON: Text;
    begin
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', DimensionCodeNameTxt, DimensionCode);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, DimensionValueCodeNameTxt, DimensionValueCode);

        exit(LineJSON);
    end;

    local procedure CreateJournalLine(JournalName: Code[10]): Guid
    var
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
    begin
        LineNo := LibraryGraphJournalLines.CreateSimpleJournalLine(JournalName);
        GraphMgtJournalLines.SetJournalLineTemplateAndBatch(GenJournalLine, JournalName);
        GraphMgtJournalLines.SetJournalLineFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();
        exit(GenJournalLine.SystemId);
    end;

    local procedure CreateDimensionSetLinesURLWithFilter(ParentIDFilter: Guid; ParentTypeFilter: Text): Text
    var
        TargetURL: Text;
        UrlFilter: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Dimension Set Lines", ServiceNameTxt);

        UrlFilter := '$filter=parentId eq ' + LibraryGraphMgt.StripBrackets(Format(ParentIDFilter)) + ' and parentType eq ''' + ParentTypeFilter + '''';

        if STRPOS(TargetURL, '?') <> 0 then
            TargetURL := TargetURL + '&' + UrlFilter
        else
            TargetURL := TargetURL + '?' + UrlFilter;

        exit(TargetURL);
    end;

    local procedure VerifyJSONContainsDimensionValues(JSONTxt: Text; ExpectedDimensionCode: Text; ExpectedDimensionValueCode: Text)
    var
        DimensionCodeValue: Text;
        DimensionValueCodeValue: Text;
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(JSONTxt, DimensionCodeNameTxt, DimensionCodeValue), 'Could not find dimension code.');
        Assert.AreEqual(ExpectedDimensionCode, DimensionCodeValue, 'Dimension code does not match.');

        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(JSONTxt, DimensionValueCodeNameTxt, DimensionValueCodeValue),
          'Could not find dimension value code.');
        Assert.AreEqual(ExpectedDimensionValueCode, DimensionValueCodeValue, 'Dimension value code does not match.');
    end;

    local procedure DimensionSetIDContainsDimension(DimensionSetID: Integer; DimensionCode: Code[20]; DimensionValueCode: Code[20]): Boolean
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        DimensionSetEntry.SetRange("Dimension Set ID", DimensionSetID);
        DimensionSetEntry.SetRange("Dimension Code", DimensionCode);
        DimensionSetEntry.SetRange("Dimension Value Code", DimensionValueCode);

        exit(not DimensionSetEntry.IsEmpty());
    end;

    local procedure CreateTimeSheet(): Guid
    var
        TimeSheetLine: Record "Time Sheet Line";
        Employee: Record Employee;
        LibraryRandom: Codeunit "Library - Random";
        ResourceNo: Code[20];
        Date: Date;
        TimeSheetHeaderNo: Code[20];
        TimeSheetLineNo: Integer;
        AccPeriodStartingDate: Date;
        Quantity: Decimal;
    begin
        AccPeriodStartingDate := GetAccountingPeriodStartingDate();
        Date := CalcDate('<CW+1D>', AccPeriodStartingDate);
        TimeSheetHeaderNo := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(TimeSheetHeaderNo));
        ResourceNo := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(ResourceNo));
        Quantity := LibraryRandom.RandDec(255, 0);

        CreateResource(ResourceNo);
        CreateEmployee(Employee, ResourceNo);

        CreateTimeSheetHeader(TimeSheetHeaderNo, Date, ResourceNo);
        TimeSheetLineNo := CreateTimeSheetLine(TimeSheetHeaderNo, TimeSheetLine.Type::Resource);
        exit(CreateTimeSheetDetail(TimeSheetHeaderNo, TimeSheetLineNo, Date, Quantity));
    end;

    local procedure GetAccountingPeriodStartingDate(): Date
    var
        AccountingPeriod: Record "Accounting Period";
        LibraryTimeSheet: Codeunit "Library - Time Sheet";
    begin
        // AccountingPeriod.DELETEALL(TRUE);
        LibraryTimeSheet.GetAccountingPeriod(AccountingPeriod);
        Commit();
        exit(AccountingPeriod."Starting Date");
    end;

    local procedure CreateResource(ResourceNo: Code[20])
    var
        Resource: Record Resource;
        UnitOfMeasure: Record "Unit of Measure";
        GraphMgtTimeRegistration: Codeunit "Graph Mgt - Time Registration";
    begin
        Resource.Init();
        Resource.Validate("No.", ResourceNo);
        Resource.Insert();
        if not UnitOfMeasure.Get('HOUR') then begin
            UnitOfMeasure.Validate(Code, 'HOUR');
            UnitOfMeasure.Insert(true);
        end;
        Resource.Validate("Base Unit of Measure", UnitOfMeasure.Code);
        Resource.Modify(true);
        GraphMgtTimeRegistration.ModifyResourceToUseTimeSheet(Resource);
        Commit();
    end;

    local procedure CreateEmployee(var Employee: Record Employee; ResourceNo: Code[20])
    begin
        if ResourceNo <> '' then
            Employee.Validate("Resource No.", ResourceNo);
        Employee.Insert(true);
        Commit();
    end;

    local procedure CreateTimeSheetHeader(TimeSheetHeaderNo: Code[20]; Date: Date; ResourceNo: Code[20])
    var
        TimeSheetHeader: Record "Time Sheet Header";
    begin
        TimeSheetHeader.Validate("No.", TimeSheetHeaderNo);
        TimeSheetHeader.Validate("Starting Date", Date);
        TimeSheetHeader.Validate("Resource No.", ResourceNo);
        TimeSheetHeader.Validate("Owner User ID", UserId);
        TimeSheetHeader.Validate("Approver User ID", UserId);
        TimeSheetHeader.Insert(true);
        Commit();
    end;

    local procedure CreateTimeSheetLine(TimeSheetHeaderNo: Code[20]; Type: Option): Integer
    var
        TimeSheetLine: Record "Time Sheet Line";
        TimeSheetHeader: Record "Time Sheet Header";
    begin
        TimeSheetLine.Init();
        TimeSheetLine.Validate("Time Sheet No.", TimeSheetHeaderNo);
        TimeSheetLine.Validate("Line No.", TimeSheetHeader.GetLastLineNo() + 10000);
        TimeSheetLine.Validate(Type, Type);
        TimeSheetLine.Validate(Status, TimeSheetLine.Status::Open);
        TimeSheetLine.Insert(true);
        Commit();

        exit(TimeSheetLine."Line No.");
    end;

    local procedure CreateTimeSheetDetail(TimeSheetHeaderNo: Code[20]; TimeSheetLineNo: Integer; Date: Date; Quantity: Decimal): Guid
    var
        TimeSheetDetail: Record "Time Sheet Detail";
    begin
        TimeSheetDetail.Init();
        TimeSheetDetail.Validate("Time Sheet No.", TimeSheetHeaderNo);
        TimeSheetDetail.Validate("Time Sheet Line No.", TimeSheetLineNo);
        TimeSheetDetail.Validate(Date, Date);
        TimeSheetDetail.Validate(Quantity, Quantity);
        TimeSheetDetail.Validate(Status, TimeSheetDetail.Status::Open);
        TimeSheetDetail.Insert(true);
        Commit();

        exit(TimeSheetDetail.SystemId);
    end;

    local procedure VerifyGLEntryDimension(SalesLine: Record "Sales Line"; DocumentNo: Code[20]): Guid
    var
        GLEntry: Record "G/L Entry";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetRange("Document No.", DocumentNo);
        SalesInvoiceLine.SetRange("No.", SalesLine."No.");
        SalesInvoiceLine.FindFirst();

        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Invoice);
        GLEntry.SetRange(Amount, -SalesInvoiceLine.Amount);
        GLEntry.FindFirst();
        GLEntry.TestField("Dimension Set ID", SalesLine."Dimension Set ID");
        exit(GLEntry.SystemId);
    end;

    local procedure CreateSalesOrder(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CustomerDimensionCode: Code[20]; ItemDimensionCode: Code[20]; ValuePosting: Option; DocumentType: Enum "Sales Document Type")
    var
        DefaultDimension: Record "Default Dimension";
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibrarySales.CreateSalesHeader(
          SalesHeader, DocumentType, CreateCustomerWithDimension(DefaultDimension, ValuePosting, CustomerDimensionCode));

        // Use Random because value is not important.
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::Item, CreateItemWithDimension(ItemDimensionCode, ValuePosting),
          LibraryRandom.RandDec(10, 2));
    end;

    local procedure CreateItemWithDimension(DimensionCode: Code[20]; ValuePosting: Option) ItemNo: Code[20]
    var
        Item: Record Item;
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibraryInventory.CreateItem(Item);
        // Use Random because value is not important.
        Item.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        Item.Modify(true);
        ItemNo := Item."No.";
        if DimensionCode = '' then
            exit;
        LibraryDimension.FindDimensionValue(DimensionValue, DimensionCode);
        LibraryDimension.CreateDefaultDimensionItem(DefaultDimension, Item."No.", DimensionCode, DimensionValue.Code);
        DefaultDimension.Validate("Value Posting", ValuePosting);
        DefaultDimension.Modify(true);
    end;

    local procedure CreateCustomerWithDimension(var DefaultDimension: Record "Default Dimension"; ValuePosting: Option; DimensionCode: Code[20]): Code[20]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Customer: Record Customer;
        DimensionValue: Record "Dimension Value";
    begin
        LibrarySales.CreateCustomer(Customer);
        if DimensionCode = '' then
            exit(Customer."No.");
        LibraryDimension.FindDimensionValue(DimensionValue, DimensionCode);
        LibraryDimension.CreateDefaultDimensionCustomer(DefaultDimension, Customer."No.", DimensionCode, DimensionValue.Code);
        DefaultDimension.Validate("Value Posting", ValuePosting);
        DefaultDimension.Modify(true);
        // another default dimension causing no error
        GeneralLedgerSetup.Get();
        if DimensionCode <> GeneralLedgerSetup."Shortcut Dimension 1 Code" then begin
            LibraryDimension.CreateDimWithDimValue(DimensionValue);
            LibraryDimension.CreateDefaultDimensionCustomer(
              DefaultDimension, Customer."No.", DimensionValue."Dimension Code", DimensionValue.Code);
            DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"Code Mandatory");
            DefaultDimension.Modify(true);
        end;
        exit(Customer."No.");
    end;

    local procedure VerifyDimensions(DimensionSetValue: Text; IdTxt: Text)
    var
        Index: Integer;
        DimensionTxt: Text;
        ParentIdValue: Text;
    begin
        Index := 0;
        repeat
            DimensionTxt := LibraryGraphMgt.GetObjectFromCollectionByIndex(DimensionSetValue, Index);

            LibraryGraphMgt.GetPropertyValueFromJSON(DimensionTxt, 'parentId', ParentIdValue);
            LibraryGraphMgt.VerifyIDFieldInJson(DimensionTxt, 'parentId');
            ParentIdValue := '{' + ParentIdValue + '}';
            Assert.AreEqual(ParentIdValue, IdTxt, 'The parent ID value is wrong.');
            Index := Index + 1;
        until (Index = LibraryGraphMgt.GetCollectionCountFromJSON(DimensionSetValue))
    end;

    local procedure GetTargetURLWithExpandDimensions(Id: Guid; APIPage: Integer; DocServiceNameTxt: Text): Text;
    var
        TargetURL: Text;
        URLFilter: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL(Id, APIPage, DocServiceNameTxt);
        URLFilter := '$expand=dimensionSetLines';

        if StrPos(TargetURL, '?') <> 0 then
            TargetURL := TargetURL + '&' + UrlFilter
        else
            TargetURL := TargetURL + '?' + UrlFilter;

        exit(TargetURL);
    end;
}