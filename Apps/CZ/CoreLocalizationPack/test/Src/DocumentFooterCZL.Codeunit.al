codeunit 148101 "Document Footer CZL"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        isInitialized: Boolean;
        RowNotFoundErr: Label 'There is no dataset row corresponding to Element Name %1 with value %2.', Comment = '%1=Field Caption,%2=Field Value;';

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Document Footer CZL");

        LibraryRandom.SetSeed(1);  // Use Random Number Generator to generate the seed for RANDOM function.

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Document Footer CZL");

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Document Footer CZL");
    end;

    [Test]
    [HandlerFunctions('RequestPageSalesInvoiceHandler')]
    procedure TestDocumentFooterSalesInvoice()
    var
        DocumentFooterCZL: Record "Document Footer CZL";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesLine: Record "Sales Line";
        ErrorMessage: Text;
    begin
        Initialize();

        // [GIVEN] The document footer has been created.
        CreateDocumentFooter(DocumentFooterCZL, 'CSY');

        // [GIVEN] The sales invoice has been created.
        CreateSalesInvoice(SalesHeader, SalesLine);

        // [GIVEN] The sales invoice has been posted.
        SalesInvoiceHeader."No." := PostSalesDocument(SalesHeader);

        // [WHEN] Run sales invoice report.
        SalesInvoiceHeader.SetRecFilter();
        Report.Run(Report::"Sales Invoice CZL", true, false, SalesInvoiceHeader);

        // [THEN] The footer text from document footer will be printed.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('No_SalesInvoiceHeader', SalesInvoiceHeader."No.");
        if not LibraryReportDataset.GetNextRow() then begin
            ErrorMessage := StrSubstNo(RowNotFoundErr, 'No_SalesInvoiceHeader', SalesInvoiceHeader."No.");
            Error(ErrorMessage);
        end;
        LibraryReportDataset.AssertCurrentRowValueEquals('DocFooterText', DocumentFooterCZL."Footer Text");
    end;

    [Test]
    [HandlerFunctions('RequestPageSalesCrMemoHandler')]
    procedure TestDocumentFooterSalesCrMemo()
    var
        DocumentFooterCZL: Record "Document Footer CZL";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ErrorMessage: Text;
    begin
        Initialize();

        // [GIVEN] The document footer has been created.
        CreateDocumentFooter(DocumentFooterCZL, 'CSY');

        // [GIVEN] The sales credit memo has been created.
        CreateSalesCrMemo(SalesHeader, SalesLine);

        // [GIVEN] The sales credit memo has been posted.
        SalesCrMemoHeader."No." := PostSalesDocument(SalesHeader);

        // [WHEN] Run sales credit memo report.
        SalesCrMemoHeader.SetRecFilter();
        Report.Run(Report::"Sales Credit Memo CZL", true, false, SalesCrMemoHeader);

        // [THEN] The footer text from document footer will be printed.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('No_SalesCrMemoHeader', SalesCrMemoHeader."No.");
        if not LibraryReportDataset.GetNextRow() then begin
            ErrorMessage := StrSubstNo(RowNotFoundErr, 'No_SalesCrMemoHeader', SalesCrMemoHeader."No.");
            Error(ErrorMessage);
        end;
        LibraryReportDataset.AssertCurrentRowValueEquals('DocFooterText', DocumentFooterCZL."Footer Text");
    end;

    [Test]
    [HandlerFunctions('RequestPageSalesQuoteHandler')]
    procedure TestDocumentFooterSalesQuote()
    var
        DocumentFooterCZL: Record "Document Footer CZL";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ErrorMessage: Text;
    begin
        Initialize();

        // [GIVEN] The document footer has been created.
        CreateDocumentFooter(DocumentFooterCZL, 'CSY');

        // [GIVEN] The sales quote has been created.
        CreateSalesQuote(SalesHeader, SalesLine);

        // [WHEN] Run sales quote report.
        Commit();
        Report.Run(Report::"Sales Quote CZL", true, false, SalesHeader);

        // [THEN] The footer text from document footer will be printed.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('No_SalesHeader', SalesHeader."No.");
        if not LibraryReportDataset.GetNextRow() then begin
            ErrorMessage := StrSubstNo(RowNotFoundErr, 'No_SalesHeader', SalesHeader."No.");
            Error(ErrorMessage);
        end;
        LibraryReportDataset.AssertCurrentRowValueEquals('DocFooterText', DocumentFooterCZL."Footer Text");
    end;

    local procedure CreateDocumentFooter(var DocumentFooterCZL: Record "Document Footer CZL"; LanguageCode: Code[10])
    begin
        if DocumentFooterCZL.Get(LanguageCode) then
            exit;

        DocumentFooterCZL.Init();
        DocumentFooterCZL."Language Code" := LanguageCode;
        DocumentFooterCZL."Footer Text" :=
          CopyStr(LibraryUtility.GenerateRandomText(MaxStrLen(DocumentFooterCZL."Footer Text")),
            1, MaxStrLen(DocumentFooterCZL."Footer Text"));
        DocumentFooterCZL.Insert(true);
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type"; CustomerNo: Code[20]; LineType: Enum "Sales Line Type"; LineNo: Code[20])
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader."Language Code" := 'CSY';
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, LineType, LineNo, 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(1000, 2));
        SalesLine.Modify(true);
    end;

    local procedure CreateSalesInvoice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateSalesDocument(
          SalesHeader, SalesLine, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo(),
          SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup());
    end;

    local procedure CreateSalesCrMemo(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateSalesDocument(
          SalesHeader, SalesLine, SalesHeader."Document Type"::"Credit Memo", LibrarySales.CreateCustomerNo(),
          SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup());
    end;

    local procedure CreateSalesQuote(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateSalesDocument(
          SalesHeader, SalesLine, SalesHeader."Document Type"::Quote, LibrarySales.CreateCustomerNo(),
          SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup());
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    [RequestPageHandler]
    procedure RequestPageSalesInvoiceHandler(var SalesInvoiceCZL: TestRequestPage "Sales Invoice CZL")
    begin
        SalesInvoiceCZL.SaveAsXml(
          LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RequestPageSalesCrMemoHandler(var SalesCreditMemoCZL: TestRequestPage "Sales Credit Memo CZL")
    begin
        SalesCreditMemoCZL.SaveAsXml(
          LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RequestPageSalesQuoteHandler(var SalesQuoteCZL: TestRequestPage "Sales Quote CZL")
    begin
        SalesQuoteCZL.SaveAsXml(
          LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}

