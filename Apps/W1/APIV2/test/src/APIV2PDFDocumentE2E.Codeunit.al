codeunit 139841 "APIV2 - PDF Document E2E"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [PDF]
    end;

    var
        Assert: Codeunit Assert;
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        InvoiceServiceNameTxt: Label 'salesInvoices';
        PDFDocumentServiceNameTxt: Label 'pdfDocument';
        SalesCreditMemoServiceNameTxt: Label 'salesCreditMemos';
        PurchaseInvoiceServiceNameTxt: Label 'purchaseInvoices';
        QuoteServiceNameTxt: Label 'salesQuotes';
        OrderServiceNameTxt: Label 'salesOrders';
        PurchaseCreditMemoServiceNameTxt: Label 'purchaseCreditMemos';

    local procedure Initialize()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        if CompanyInformation."Giro No." = '' then
            CompanyInformation."Giro No." := '1234567';
        if CompanyInformation.IBAN = '' then
            CompanyInformation.IBAN := 'GB213 2342 34';
        if CompanyInformation."Bank Name" = '' then
            CompanyInformation."Bank Name" := 'My Bank';
        if CompanyInformation."Bank Account No." = '' then
            CompanyInformation."Bank Account No." := '12431243';
        if CompanyInformation."SWIFT Code" = '' then
            CompanyInformation."SWIFT Code" := 'GBBAKKXX';
        CompanyInformation.Modify();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPDFSalesInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        TempBlob: Codeunit "Temp Blob";
        InvoiceID1: Text;
        InvoiceID2: Text;
        ID1: Text;
        ID2: Text;
        TargetURL: Text;
        SubPageWithContentTxt: Text;
    begin
        // [FEATURE] [Sales] [Invoice]
        // [SCENARIO 184721] Create posted and unposted Sales invoices and use pdfDocument navigation property to get the corresponding PDF
        // [GIVEN] 2 invoices, one posted and one unposted
        Initialize();
        CreateSalesInvoices(InvoiceID1, InvoiceID2);
        SalesInvoiceHeader.Get(InvoiceID1);
        ID1 := SalesInvoiceHeader."Draft Invoice SystemId";
        Assert.AreNotEqual('', ID1, 'ID must not be empty');

        SalesHeader.Get(SalesHeader."Document Type"::Invoice, InvoiceID2);
        ID2 := SalesHeader.SystemId;
        Assert.AreNotEqual('', ID2, 'ID must not be empty');

        // [WHEN] we GET the pdfDocument subpage content on the draft invoice
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(ID2, Page::"APIV2 - Sales Invoices", InvoiceServiceNameTxt, PDFDocumentServiceNameTxt);
        SubPageWithContentTxt := PDFDocumentServiceNameTxt + '/pdfDocumentContent';
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, PDFDocumentServiceNameTxt, SubPageWithContentTxt);
        Commit();

        // [THEN] we receive the binary file with the printed invoice
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlob, TargetURL, 'application/octet-stream', 200);
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, InvoiceID2);

        // [WHEN] we GET the pdfDocument subpage content on the posted invoice
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(ID1, Page::"APIV2 - Sales Invoices", InvoiceServiceNameTxt, PDFDocumentServiceNameTxt);
        SubPageWithContentTxt := PDFDocumentServiceNameTxt + '/pdfDocumentContent';
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, PDFDocumentServiceNameTxt, SubPageWithContentTxt);
        Commit();

        // [THEN] we receive the binary file with the printed invoice, and the invoice is marked as printed
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlob, TargetURL, 'application/octet-stream', 200);
        SalesInvoiceHeader.Get(InvoiceID1);
        Assert.AreEqual(1, SalesInvoiceHeader."No. Printed", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPDFSalesCreditMemo()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        TempBlob: Codeunit "Temp Blob";
        SCMID1: Text;
        SCMID2: Text;
        ID1: Text;
        ID2: Text;
        TargetURL: Text;
        SubPageWithContentTxt: Text;
    begin
        // [FEATURE] [Sales] [Credit Memo]
        // [SCENARIO 184721] Create posted and unposted Sales credit memos and use pdfDocument navigation property to get the corresponding PDF
        // [GIVEN] 2 credit memos, one posted and one unposted
        Initialize();
        CreateSalesCreditMemos(SCMID1, SCMID2);
        SalesCrMemoHeader.Get(SCMID1);
        ID1 := SalesCrMemoHeader."Draft Cr. Memo SystemId";
        Assert.AreNotEqual('', ID1, 'ID must not be empty');

        SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", SCMID2);
        ID2 := SalesHeader.SystemId;
        Assert.AreNotEqual('', ID2, 'ID must not be empty');

        // [WHEN] we GET the pdfDocument subpage content on the draft credit memo
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ID2, Page::"APIV2 - Sales Credit Memos", SalesCreditMemoServiceNameTxt, PDFDocumentServiceNameTxt);
        SubPageWithContentTxt := PDFDocumentServiceNameTxt + '/pdfDocumentContent';
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, PDFDocumentServiceNameTxt, SubPageWithContentTxt);
        Commit();

        // [THEN] we get an error message, because we don't support printing an unposted sales credit memo
        asserterror LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(
            TempBlob, TargetURL, 'application/octet-stream', 200);

        // [WHEN] we GET the pdfDocument subpage content on the posted credit memo
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ID1, Page::"APIV2 - Sales Credit Memos", SalesCreditMemoServiceNameTxt, PDFDocumentServiceNameTxt);
        SubPageWithContentTxt := PDFDocumentServiceNameTxt + '/pdfDocumentContent';
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, PDFDocumentServiceNameTxt, SubPageWithContentTxt);
        Commit();

        // [THEN] we receive the binary file with the printed credit memo, and the credit memo is marked as printed
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlob, TargetURL, 'application/octet-stream', 200);
        SalesCrMemoHeader.Get(SCMID1);
        Assert.AreEqual(1, SalesCrMemoHeader."No. Printed", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPDFSalesQuote()
    var
        SalesHeader: Record "Sales Header";
        TempBlob: Codeunit "Temp Blob";
        QuoteID1: Text;
        ID1: Text;
        TargetURL: Text;
        SubPageWithContentTxt: Text;
    begin
        // [FEATURE] [Sales] [Quote]
        // [SCENARIO 184721] Create Sales quote and use pdfDocument navigation property to get the corresponding PDF
        // [GIVEN] a sales quote
        Initialize();
        CreateSalesQuote(QuoteID1);
        SalesHeader.Get(SalesHeader."Document Type"::Quote, QuoteID1);
        ID1 := SalesHeader.SystemId;
        Assert.AreNotEqual('', ID1, 'ID must not be empty');

        // [WHEN] we GET the pdfDocument subpage content on the draft quote
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(ID1, Page::"APIV2 - Sales Quotes", QuoteServiceNameTxt, PDFDocumentServiceNameTxt);
        SubPageWithContentTxt := PDFDocumentServiceNameTxt + '/pdfDocumentContent';
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, PDFDocumentServiceNameTxt, SubPageWithContentTxt);
        Commit();

        // [THEN] we receive the binary file with the printed quote
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlob, TargetURL, 'application/octet-stream', 200);
        SalesHeader.Get(SalesHeader."Document Type"::Quote, QuoteID1);
        Assert.AreEqual(1, SalesHeader."No. Printed", 'Sales quote is not marked as printed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPDFSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        TempBlob: Codeunit "Temp Blob";
        OrderID: Text;
        ID: Text;
        TargetURL: Text;
        SubPageWithContentTxt: Text;
    begin
        // [FEATURE] [Sales] [Order]
        // [SCENARIO 184721] Create Sales order and use pdfDocument navigation property to get the corresponding PDF
        // [GIVEN] a sales order
        Initialize();
        LibrarySales.CreateSalesOrder(SalesHeader);
        OrderID := SalesHeader."No.";
        ID := SalesHeader.SystemId;
        Assert.AreNotEqual('', ID, 'ID must not be empty');

        // [WHEN] GET the pdfDocument subpage content on the draft order
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(ID, Page::"APIV2 - Sales Orders", OrderServiceNameTxt, PDFDocumentServiceNameTxt);
        SubPageWithContentTxt := PDFDocumentServiceNameTxt + '/pdfDocumentContent';
        TargetURL := LibraryGraphMgt.StrReplace(TargetURL, PDFDocumentServiceNameTxt, SubPageWithContentTxt);
        Commit();

        // [THEN] receive the binary file with the printed order
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlob, TargetURL, 'application/octet-stream', 200);
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderID);
        Assert.AreEqual(1, SalesHeader."No. Printed", 'Sales order is not marked as printed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPDFPurchaseInvoice()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
        TempBlob: Codeunit "Temp Blob";
        InvoiceID1: Text;
        InvoiceID2: Text;
        ID1: Text;
        ID2: Text;
        TargetURL: Text;
        SubPageWithContentTxt: Text;
    begin
        // [FEATURE] [Purchase] [Invoice]
        // [SCENARIO 184721] Create posted and unposted purchase invoices and use pdfDocument navigation property to get the corresponding PDF
        // [GIVEN] 2 invoices, one posted and one unposted
        Initialize();
        CreatePurchaseInvoices(InvoiceID1, InvoiceID2);
        PurchInvHeader.Get(InvoiceID1);
        ID1 := PurchInvHeader."Draft Invoice SystemId";
        Assert.AreNotEqual('', ID1, 'ID must not be empty');

        PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, InvoiceID2);
        ID2 := PurchaseHeader.SystemId;
        Assert.AreNotEqual('', ID2, 'ID must not be empty');

        // [WHEN] we GET the pdfDocument subpage content on the draft invoice
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ID2, PAGE::"APIV2 - Purchase Invoices", PurchaseInvoiceServiceNameTxt, PDFDocumentServiceNameTxt);
        SubPageWithContentTxt := PDFDocumentServiceNameTxt + '/pdfDocumentContent';
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, PDFDocumentServiceNameTxt, SubPageWithContentTxt);
        Commit();

        // [THEN] we get an error message, because we don't support printing an unposted sales credit memo
        asserterror LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(
            TempBlob, TargetURL, 'application/octet-stream', 200);

        // [WHEN] we GET the pdfDocument subpage content on the posted invoice
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ID1, PAGE::"APIV2 - Purchase Invoices", PurchaseInvoiceServiceNameTxt, PDFDocumentServiceNameTxt);
        SubPageWithContentTxt := PDFDocumentServiceNameTxt + '/pdfDocumentContent';
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, PDFDocumentServiceNameTxt, SubPageWithContentTxt);
        Commit();

        // [THEN] we receive the binary file with the printed invoice, and the invoice is marked as printed
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlob, TargetURL, 'application/octet-stream', 200);
        PurchInvHeader.Get(InvoiceID1);
        Assert.AreEqual(1, PurchInvHeader."No. Printed", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPDFPurchaseCreditMemo()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchaseHeader: Record "Purchase Header";
        TempBlob: Codeunit "Temp Blob";
        PCMID1: Text;
        PCMID2: Text;
        ID1: Text;
        ID2: Text;
        TargetURL: Text;
        SubPageWithContentTxt: Text;
    begin
        // [FEATURE] [Purchase] [Credit Memo]
        // [SCENARIO 184721] Create posted and unposted Purchase credit memos and use pdfDocument navigation property to get the corresponding PDF
        // [GIVEN] 2 credit memos, one posted and one unposted
        Initialize();
        CreatePurchaseCreditMemos(PCMID1, PCMID2);
        PurchCrMemoHdr.Get(PCMID1);
        ID1 := PurchCrMemoHdr."Draft Cr. Memo SystemId";
        Assert.AreNotEqual('', ID1, 'ID must not be empty');

        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", PCMID2);
        ID2 := PurchaseHeader.SystemId;
        Assert.AreNotEqual('', ID2, 'ID must not be empty');

        // [WHEN] we GET the pdfDocument subpage content on the draft credit memo
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ID2, Page::"APIV2 - Purchase Credit Memos", PurchaseCreditMemoServiceNameTxt, PDFDocumentServiceNameTxt);
        SubPageWithContentTxt := PDFDocumentServiceNameTxt + '/pdfDocumentContent';
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, PDFDocumentServiceNameTxt, SubPageWithContentTxt);
        Commit();

        // [THEN] we get an error message, because we don't support printing an unposted purchase credit memo
        asserterror LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(
            TempBlob, TargetURL, 'application/octet-stream', 200);

        // [WHEN] we GET the pdfDocument subpage content on the posted credit memo
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ID1, Page::"APIV2 - Purchase Credit Memos", PurchaseCreditMemoServiceNameTxt, PDFDocumentServiceNameTxt);
        SubPageWithContentTxt := PDFDocumentServiceNameTxt + '/pdfDocumentContent';
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, PDFDocumentServiceNameTxt, SubPageWithContentTxt);
        Commit();

        // [THEN] we receive the binary file with the printed credit memo, and the credit memo is marked as printed
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlob, TargetURL, 'application/octet-stream', 200);
        PurchCrMemoHdr.Get(PCMID1);
        Assert.AreEqual(1, PurchCrMemoHdr."No. Printed", '');
    end;

    local procedure CreateSalesInvoices(var InvoiceID1: Text; var InvoiceID2: Text)
    var
        SalesHeader: Record "Sales Header";
        SalesHeaderUnposted: Record "Sales Header";
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        InvoiceID1 := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        LibrarySales.CreateSalesInvoice(SalesHeaderUnposted);
        InvoiceID2 := SalesHeaderUnposted."No.";
        Commit();
    end;

    local procedure CreateSalesCreditMemos(var SCMID1: Text; var SCMID2: Text)
    var
        SalesHeader: Record "Sales Header";
        SalesHeaderUnposted: Record "Sales Header";
    begin
        LibrarySales.CreateSalesCreditMemo(SalesHeader);
        SCMID1 := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        LibrarySales.CreateSalesCreditMemo(SalesHeaderUnposted);
        SCMID2 := SalesHeaderUnposted."No.";
        Commit();
    end;

    local procedure CreatePurchaseInvoices(var InvoiceID1: Text; var InvoiceID2: Text)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderUnposted: Record "Purchase Header";
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        InvoiceID1 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeaderUnposted);
        InvoiceID2 := PurchaseHeaderUnposted."No.";
        Commit();
    end;

    local procedure CreateSalesQuote(var QuoteID1: Text)
    var
        SalesHeader: Record "Sales Header";
        CustomerNo: Code[20];
    begin
        CustomerNo := LibrarySales.CreateCustomerNo();
        LibrarySales.CreateSalesQuoteForCustomerNo(SalesHeader, CustomerNo);
        QuoteID1 := SalesHeader."No.";
        Commit();
    end;

    local procedure CreatePurchaseCreditMemos(var PCMID1: Text; var PCMID2: Text)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderUnposted: Record "Purchase Header";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryPurchase.CreatePurchaseCreditMemo(PurchaseHeader);
        PCMID1 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        LibraryPurchase.CreatePurchaseCreditMemo(PurchaseHeaderUnposted);
        PCMID2 := PurchaseHeaderUnposted."No.";
        Commit();
    end;
}

