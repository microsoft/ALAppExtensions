codeunit 148100 "Tax Reports CZL"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryTaxCZL: Codeunit "Library - Tax CZL";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Tax Reports CZL");

        LibraryRandom.SetSeed(1);  // Use Random Number Generator to generate the seed for RANDOM function.
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Tax Reports CZL");

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Tax Reports CZL");
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPageDocumentationForVATHandler,RequestPageCreateVATPeriodHandler')]
    procedure PrintingDocumentationForVATOutVATDate()
    begin
        PrintingDocumentationForVAT(true);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPageDocumentationForVATHandler,RequestPageCreateVATPeriodHandler')]
    procedure PrintingDocumentationForVATInVATDate()
    begin
        PrintingDocumentationForVAT(false);
    end;

    local procedure PrintingDocumentationForVAT(OutVATDate: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedDocumentNo: Code[20];
        StartDate: Date;
    begin
        Initialize();

        // [GIVEN] The use vat date has been enabled.
        LibraryTaxCZL.SetUseVATDate(true);

        // [GIVEN] The vat period has been recreated.
        DeleteVATPeriod();
        RunCreateVATPeriod();

        // [GIVEN] The purchase invoice has been created.
        CreatePurchInvoice(PurchaseHeader, PurchaseLine);
#if not CLEAN22
#pragma warning disable AL0432
        PurchaseHeader.Validate("VAT Date CZL", CalcDate('<+1M>', PurchaseHeader."Posting Date"));
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Date CZL");
#pragma warning restore AL0432
#else
        PurchaseHeader.Validate("VAT Reporting Date", CalcDate('<+1M>', PurchaseHeader."Posting Date"));
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Reporting Date");
#endif
        PurchaseHeader.Modify();

        // [GIVEN] The purchase invoice has been posted.
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [WHEN] Print documentation for vat report.
        if OutVATDate then
            StartDate := CalcDate('<-CM>', PurchaseHeader."Posting Date")
        else
#if not CLEAN22
#pragma warning disable AL0432
            StartDate := CalcDate('<-CM>', PurchaseHeader."VAT Date CZL");
#pragma warning restore AL0432
#else
            StartDate := CalcDate('<-CM>', PurchaseHeader."VAT Reporting Date");
#endif
        PrintDocumentationForVAT(StartDate, Enum::"VAT Statement Report Selection"::Open, true);

        // [THEN] If the start date of report was equal to posting date of purchase invoice then the purchase invoice won't be printed else the document will be printed.
        if OutVATDate then
            LibraryReportDataset.AssertElementWithValueNotExist('DocumentNo_VATEntry', PostedDocumentNo)
        else
            LibraryReportDataset.AssertElementWithValueExists('DocumentNo_VATEntry', PostedDocumentNo);
    end;

    local procedure CreatePurchDocument(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; Amount: Decimal)
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Direct Unit Cost", Amount);
        PurchaseLine.Modify(true);
    end;

    local procedure CreatePurchInvoice(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
        CreatePurchDocument(PurchaseHeader, PurchaseLine, PurchaseHeader."Document Type"::Invoice, LibraryRandom.RandDec(10000, 2));
    end;

    local procedure DeleteVATPeriod()
    var
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        VATPeriodCZL.DeleteAll();
    end;

    local procedure PostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure PrintDocumentationForVAT(StartDate: Date; Selection: Enum "VAT Statement Report Selection"; PrintVATEntries: Boolean)
    var
        XmlParameters: Text;
    begin
        LibraryVariableStorage.Enqueue(StartDate);
        LibraryVariableStorage.Enqueue(Selection);
        LibraryVariableStorage.Enqueue(PrintVATEntries);

        XmlParameters := Report.RunRequestPage(Report::"Documentation for VAT CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"Documentation for VAT CZL", '', XmlParameters);
    end;

    local procedure RunCreateVATPeriod()
    begin
        LibraryVariableStorage.Enqueue(CalcDate('<-CY>', WorkDate()));
        LibraryVariableStorage.Enqueue(12);
        LibraryVariableStorage.Enqueue('1M');
        LibraryTaxCZL.RunCreateVATPeriod();
    end;

    [RequestPageHandler]
    procedure RequestPageCreateVATPeriodHandler(var CreateVATPeriodCZL: TestRequestPage "Create VAT Period CZL")
    begin
        CreateVATPeriodCZL.VATPeriodStartDateCZL.SetValue(LibraryVariableStorage.DequeueDate());
        CreateVATPeriodCZL.NoOfPeriodsCZL.SetValue(LibraryVariableStorage.DequeueInteger());
        CreateVATPeriodCZL.PeriodLengthCZL.SetValue(LibraryVariableStorage.DequeueText());
        CreateVATPeriodCZL.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure RequestPageDocumentationForVATHandler(var DocumentationforVATCZL: TestRequestPage "Documentation for VAT CZL")
    begin
        DocumentationforVATCZL.StartDateReqCZL.SetValue(LibraryVariableStorage.DequeueDate());
        DocumentationforVATCZL.SelectionCZL.SetValue(LibraryVariableStorage.DequeueInteger());
        DocumentationforVATCZL.PrintVATEntriesCZL.SetValue(LibraryVariableStorage.DequeueBoolean());
        DocumentationforVATCZL.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure YesConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}

