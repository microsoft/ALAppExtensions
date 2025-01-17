codeunit 148099 "Sales Reports CZL"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        RowNotFoundErr: Label 'There is no dataset row corresponding to Element Name %1 with value %2.', Comment = '%1=Field Caption,%2=Field Value;';

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sales Reports CZL");

        LibraryRandom.SetSeed(1);  // Use Random Number Generator to generate the seed for RANDOM function.
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sales Reports CZL");

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sales Reports CZL");
    end;

    [Test]
    [HandlerFunctions('RequestPageSalesCrMemoHandler')]
    procedure PrintingInternalCorrectionDocument()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedDocumentNo: Code[20];
        ErrorMessage: Text;
    begin
        Initialize();

        // [GIVEN] The sales credit memo with internal correction type has been created.
        CreateSalesDocument(SalesHeader, SalesLine, SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.Validate("Credit Memo Type CZL", SalesHeader."Credit Memo Type CZL"::"Internal Correction");
        SalesHeader.Modify();

        // [GIVEN] The sales credit memo has been posted.
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [WHEN] Post sales credit memo.
        PrintCreditMemo(PostedDocumentNo);

        // [THEN] The report will be correctly printed.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('No_SalesCrMemoHeader', PostedDocumentNo);
        if not LibraryReportDataset.GetNextRow() then begin
            ErrorMessage := StrSubstNo(RowNotFoundErr, 'No_SalesCrMemoHeader', PostedDocumentNo);
            Error(ErrorMessage);
        end;
        LibraryReportDataset.AssertCurrentRowValueEquals(
          'CreditMemoType_SalesCrMemoHeader', Format(SalesHeader."Credit Memo Type CZL"::"Internal Correction", 0, '<Number>'));
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type")
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup(), 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10000, 2));
        SalesLine.Validate(Description, SalesHeader."No.");
        SalesLine.Modify(true);
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure PrintCreditMemo(DocumentNo: Code[20])
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.Get(DocumentNo);
        SalesCrMemoHeader.SetRecFilter();
        Report.Run(Report::"Sales Credit Memo CZL", true, false, SalesCrMemoHeader);
    end;

    [RequestPageHandler]
    procedure RequestPageSalesCrMemoHandler(var SalesCreditMemoCZL: TestRequestPage "Sales Credit Memo CZL")
    begin
        SalesCreditMemoCZL.SaveAsXml(
          LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}

