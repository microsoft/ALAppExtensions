codeunit 148067 "VIES Declaration CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [VIES Declaration]
        isInitialized := false;
    end;

    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        VATPeriodCZL: Record "VAT Period CZL";
        CountryRegion: Record "Country/Region";
        VATPostingSetup: Record "VAT Posting Setup";
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryTaxCZL: Codeunit "Library - Tax CZL";
        SalesPost: Codeunit "Sales-Post";
        ReleaseVIESDeclarationCZL: Codeunit "Release VIES Declaration CZL";
        TypeHelper: Codeunit "Type Helper";
        XMLBufferWriter: Codeunit "XML Buffer Writer";
        Assert: Codeunit Assert;
        VIESDeclarationLinesCZL: Page "VIES Declaration Lines CZL";
        RequestPageXML: Text;
        isInitialized: Boolean;

    local procedure Initialize();
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"VIES Declaration CZL");
        LibraryRandom.Init();

        VIESDeclarationHeaderCZL.Reset();
        VIESDeclarationHeaderCZL.DeleteAll(false);
        VIESDeclarationLineCZL.Reset();
        VIESDeclarationLineCZL.DeleteAll(false);

        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"VIES Declaration CZL");

        LibraryTaxCZL.SetUseVATDate(true);

        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL."VIES Declaration Nos." := LibraryERM.CreateNoSeriesCode();
        StatutoryReportingSetupCZL."VIES Number of Lines" := 20;
        StatutoryReportingSetupCZL.Modify();

        VATPeriodCZL.SetRange(Closed, false);
        VATPeriodCZL.FindLast();

        CountryRegion.SetFilter("EU Country/Region Code", '<>%1', '');
        CountryRegion.FindFirst();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"VIES Declaration CZL");
    end;

    [Test]
    [HandlerFunctions('SuggestVIESDeclarationRequestPageHandler')]
    procedure CreateVIESDeclarationServiceSales()
    begin
        // [SCENARIO] Create VIES Declaration for service sales
        Initialize();

        // [GIVEN] New EU Customer has been created
        CreateCustomer();

        // [GIVEN] New G/L Account with VAT posting has been created
        CreateGLAccount();

        // [GIVEN] New Sales Invoice has been created
        CreateSalesHeader(Customer."No.", false);

        // [GIVEN] New Sales Invoice Line has been created
        CreateSalesLine();

        // [GIVEN] Sales Invoice Line has been posted
        SalesPost.Run(SalesHeader);

        // [GIVEN] New VIES Declaration Header has been created
        CreateVIESDeclaration('');

        // [WHEN] Run suggest lines
        VIESDeclarationHeaderCZL.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Report.RunModal(Report::"Suggest VIES Declaration CZL", true, false, VIESDeclarationHeaderCZL);

        // [THEN] VIES Declaration Line for Customer will be created
        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."No.");
        VIESDeclarationLineCZL.SetRange("Trade Type", VIESDeclarationLineCZL."Trade Type"::Sales);
        VIESDeclarationLineCZL.SetRange("Country/Region Code", Customer."Country/Region Code");
        VIESDeclarationLineCZL.SetRange("VAT Registration No.", Customer."VAT Registration No.");
        VIESDeclarationLineCZL.FindFirst();

        // [THEN] VIES Declaration Line will be EU Service
        Assert.AreEqual(true, VIESDeclarationLineCZL."EU Service", VIESDeclarationLineCZL.FieldCaption("EU Service"));

        // [THEN] VIES Declaration Line will be Direct Trade
        Assert.AreEqual(VIESDeclarationLineCZL."Trade Role Type"::"Direct Trade", VIESDeclarationLineCZL."Trade Role Type", VIESDeclarationLineCZL.FieldCaption("Trade Role Type"));
    end;

    [Test]
    [HandlerFunctions('SuggestVIESDeclarationRequestPageHandler')]
    procedure CreateVIESDeclaration3PartyTrade()
    begin
        // [SCENARIO] Create VIES Declaration for 3-Party Trade
        Initialize();

        // [GIVEN] New EU Customer has been created
        CreateCustomer();

        // [GIVEN] New G/L Account with VAT posting has been created
        CreateGLAccount();

        // [GIVEN] New Sales Invoice has been created
        CreateSalesHeader(Customer."No.", true);

        // [GIVEN] New Sales Invoice Line has been created
        CreateSalesLine();

        // [GIVEN] Sales Invoice Line has been posted
        SalesPost.Run(SalesHeader);

        // [GIVEN] New VIES Declaration Header has been created
        CreateVIESDeclaration('');

        // [WHEN] Run suggest lines
        VIESDeclarationHeaderCZL.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Report.RunModal(Report::"Suggest VIES Declaration CZL", true, false, VIESDeclarationHeaderCZL);

        // [THEN] VIES Declaration Line for Customer will be created
        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."No.");
        VIESDeclarationLineCZL.SetRange("Trade Type", VIESDeclarationLineCZL."Trade Type"::Sales);
        VIESDeclarationLineCZL.SetRange("Country/Region Code", Customer."Country/Region Code");
        VIESDeclarationLineCZL.SetRange("VAT Registration No.", Customer."VAT Registration No.");
        VIESDeclarationLineCZL.FindFirst();

        // [THEN] VIES Declaration Line will be EU Service
        Assert.AreEqual(true, VIESDeclarationLineCZL."EU Service", VIESDeclarationLineCZL.FieldCaption("EU Service"));

        // [THEN] VIES Declaration Line will be Direct Trade
        Assert.AreEqual(VIESDeclarationLineCZL."Trade Role Type"::"Intermediate Trade", VIESDeclarationLineCZL."Trade Role Type", VIESDeclarationLineCZL.FieldCaption("Trade Role Type"));
    end;

    [Test]
    [HandlerFunctions('SuggestVIESDeclarationRequestPageHandler,VIESDeclarationTestRequestPageHandler')]
    procedure PrintVIESDeclarationTestReport()
    begin
        // [SCENARIO] Print test report for VIES Declaration
        Initialize();

        // [GIVEN] New EU Customer has been created
        CreateCustomer();

        // [GIVEN] New G/L Account with VAT posting has been created
        CreateGLAccount();

        // [GIVEN] New Sales Invoice has been created
        CreateSalesHeader(Customer."No.", false);

        // [GIVEN] New Sales Invoice Line has been created
        CreateSalesLine();

        // [GIVEN] Sales Invoice Line has been posted
        SalesPost.Run(SalesHeader);

        // [GIVEN] New VIES Declaration Header has been created
        CreateVIESDeclaration('');

        // [GIVEN] VIES Declaration lines has been suggested
        VIESDeclarationHeaderCZL.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Report.RunModal(Report::"Suggest VIES Declaration CZL", true, false, VIESDeclarationHeaderCZL);

        // [WHEN] Test report run
        RequestPageXML := Report.RunRequestPage(Report::"VIES Declaration - Test CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"VIES Declaration - Test CZL", VIESDeclarationHeaderCZL, RequestPageXML);

        // [THEN] Report Dataset will contain Customer Invoice
        LibraryReportDataset.AssertElementWithValueExists('VIESDeclarationLine_VATRegistrationNo', Customer."VAT Registration No.");
    end;

    [Test]
    [HandlerFunctions('SuggestVIESDeclarationRequestPageHandler')]
    procedure ExportVIESDeclarationOpened()
    var
        ReleasedErr: Label 'Released';
    begin
        // [SCENARIO] Not possible export opened VIES Declaration
        Initialize();

        // [GIVEN] New EU Customer has been created
        CreateCustomer();

        // [GIVEN] New G/L Account with VAT posting has been created
        CreateGLAccount();

        // [GIVEN] New Sales Invoice has been created
        CreateSalesHeader(Customer."No.", false);

        // [GIVEN] New Sales Invoice Line has been created
        CreateSalesLine();

        // [GIVEN] Sales Invoice Line has been posted
        SalesPost.Run(SalesHeader);

        // [GIVEN] New VIES Declaration Header has been created
        CreateVIESDeclaration('');

        // [GIVEN] VIES Declaration lines has been suggested
        VIESDeclarationHeaderCZL.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Report.RunModal(Report::"Suggest VIES Declaration CZL", true, false, VIESDeclarationHeaderCZL);

        // [WHEN] Export VIES Declaration
        asserterror VIESDeclarationHeaderCZL.Export();

        // [THEN] Error released will occurs
        Assert.ExpectedError(ReleasedErr);
    end;

    [Test]
    [HandlerFunctions('SuggestVIESDeclarationRequestPageHandler')]
    procedure ExportVIESDeclarationReleased()
    var
        TempVIESDeclarationLineCZL: Record "VIES Declaration Line CZL" temporary;
        TempXMLBuffer: Record "XML Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        VIESDeclarationCZL: XmlPort "VIES Declaration CZL";
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [SCENARIO] Export released VIES Declaration
        Initialize();

        // [GIVEN] New EU Customer has been created
        CreateCustomer();

        // [GIVEN] New G/L Account with VAT posting has been created
        CreateGLAccount();

        // [GIVEN] New Sales Invoice has been created
        CreateSalesHeader(Customer."No.", false);

        // [GIVEN] New Sales Invoice Line has been created
        CreateSalesLine();

        // [GIVEN] Sales Invoice Line has been posted
        SalesPost.Run(SalesHeader);

        // [GIVEN] New VIES Declaration Header has been created
        CreateVIESDeclaration('');

        // [GIVEN] VIES Declaration lines has been suggested
        VIESDeclarationHeaderCZL.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Report.RunModal(Report::"Suggest VIES Declaration CZL", true, false, VIESDeclarationHeaderCZL);

        // [GIVEN] VIES Declaration has been released
        ReleaseVIESDeclarationCZL.Run(VIESDeclarationHeaderCZL);

        // [WHEN] Export VIES Declaration
        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."No.");
        if VIESDeclarationLineCZL.FindSet() then
            repeat
                TempVIESDeclarationLineCZL := VIESDeclarationLineCZL;
                TempVIESDeclarationLineCZL.Insert();
            until VIESDeclarationLineCZL.Next() = 0;

        TempBlob.CreateOutStream(OutStream);
        VIESDeclarationCZL.SetHeader(VIESDeclarationHeaderCZL);
        VIESDeclarationCZL.SetLines(TempVIESDeclarationLineCZL);
        VIESDeclarationCZL.SetDestination(OutStream);
        VIESDeclarationCZL.Export();

        // [THEN] Exported XML document will exist
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        XMLBufferWriter.InitializeXMLBufferFromText(TempXMLBuffer, TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.CRLFSeparator()));

        // [THEN] Exported XML document will have VetaD
#pragma warning disable AA0210
        TempXMLBuffer.SetFilter(Path, '/Pisemnost/DPHSHV/vetaD/*');
        Assert.AreNotEqual(0, TempXMLBuffer.Count(), 'VetaD');

        // [THEN] Exported VetaD will have shvies_forma = R
        TempXMLBuffer.SetFilter(Path, '/Pisemnost/DPHSHV/vetaD/@shvies_forma');
#pragma warning restore AA0210
        TempXMLBuffer.FindFirst();
        Assert.AreEqual('R', TempXMLBuffer.Value, 'shvies_forma');

        // [THEN] Exported XML document will have VetaR
        TempXMLBuffer.SetFilter(Path, '/Pisemnost/DPHSHV/vetaR/*');
        Assert.AreNotEqual(0, TempXMLBuffer.Count(), 'VetaR');

        // [THEN] Exported VetaR will have c_vat = Customer's VAT Registration No.
        TempXMLBuffer.SetFilter(Path, '/Pisemnost/DPHSHV/vetaR/@c_vat');
        TempXMLBuffer.SetFilter(Value, Customer."VAT Registration No.");
        Assert.AreEqual(1, TempXMLBuffer.Count(), 'c_vat');
    end;

    [Test]
    [HandlerFunctions('SuggestVIESDeclarationRequestPageHandler,GetLineForCorrectionModalPageHandler')]
    procedure CreateVIESDeclarationCorrective()
    begin
        // [SCENARIO] Create and modify corrective VIES Declaration
        Initialize();

        // [GIVEN] New EU Customer has been created
        CreateCustomer();

        // [GIVEN] New G/L Account with VAT posting has been created
        CreateGLAccount();

        // [GIVEN] New Sales Invoice has been created
        CreateSalesHeader(Customer."No.", true);

        // [GIVEN] New Sales Invoice Line has been created
        CreateSalesLine();

        // [GIVEN] Sales Invoice Line has been posted
        SalesPost.Run(SalesHeader);

        // [GIVEN] New VIES Declaration Header has been created
        CreateVIESDeclaration('');

        // [GIVEN] VIES Declaration lines has been suggested
        VIESDeclarationHeaderCZL.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Report.RunModal(Report::"Suggest VIES Declaration CZL", true, false, VIESDeclarationHeaderCZL);

        // [GIVEN] VIES Declaration has been released
        ReleaseVIESDeclarationCZL.Run(VIESDeclarationHeaderCZL);

        // [GIVEN] New corrective VIES Declaration Header has been created
        VIESDeclarationHeaderCZL.Reset();
        CreateVIESDeclaration(VIESDeclarationHeaderCZL."No.");
        VIESDeclarationHeaderCZL.SetRange("No.", VIESDeclarationHeaderCZL."No.");

        // [WHEN] Get VIES Declaration line for correction
        VIESDeclarationLinesCZL.SetToDeclaration(VIESDeclarationHeaderCZL);
        VIESDeclarationLinesCZL.LookupMode := true;
        if VIESDeclarationLinesCZL.RunModal() = Action::LookupOK then
            VIESDeclarationLinesCZL.CopyLineToDeclaration();

        // [THEN] Corrective VIES Declaration will have two lines
        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."No.");
        VIESDeclarationLineCZL.FindFirst();
        Assert.AreEqual(VIESDeclarationLineCZL."Line Type"::Cancellation, VIESDeclarationLineCZL."Line Type", VIESDeclarationLineCZL.FieldCaption("Line Type"));
        VIESDeclarationLineCZL.FindLast();
        Assert.AreEqual(VIESDeclarationLineCZL."Line Type"::Correction, VIESDeclarationLineCZL."Line Type", VIESDeclarationLineCZL.FieldCaption("Line Type"));

        // [THEN] Corrective VIES Declaration Line will have VAT Registration No. editable
        VIESDeclarationLineCZL.Validate("VAT Registration No.", CopyStr(LibraryRandom.RandText(20), 1, 20));
        VIESDeclarationLineCZL.Modify();
    end;

    [Test]
    [HandlerFunctions('SuggestVIESDeclarationRequestPageHandler,GetLineForCorrectionModalPageHandler')]
    procedure ExportVIESDeclarationCorrective()
    var
        TempVIESDeclarationLineCZL: Record "VIES Declaration Line CZL" temporary;
        TempXMLBuffer: Record "XML Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        VIESDeclarationCZL: XmlPort "VIES Declaration CZL";
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [SCENARIO] Export corrective VIES Declaration
        Initialize();

        // [GIVEN] New EU Customer has been created
        CreateCustomer();

        // [GIVEN] New G/L Account with VAT posting has been created
        CreateGLAccount();

        // [GIVEN] New Sales Invoice has been created
        CreateSalesHeader(Customer."No.", true);

        // [GIVEN] New Sales Invoice Line has been created
        CreateSalesLine();

        // [GIVEN] Sales Invoice Line has been posted
        SalesPost.Run(SalesHeader);

        // [GIVEN] New VIES Declaration Header has been created
        CreateVIESDeclaration('');

        // [GIVEN] VIES Declaration lines has been suggested
        VIESDeclarationHeaderCZL.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Report.RunModal(Report::"Suggest VIES Declaration CZL", true, false, VIESDeclarationHeaderCZL);

        // [GIVEN] VIES Declaration has been released
        ReleaseVIESDeclarationCZL.Run(VIESDeclarationHeaderCZL);

        // [GIVEN] New corrective VIES Declaration Header has been created
        VIESDeclarationHeaderCZL.Reset();
        CreateVIESDeclaration(VIESDeclarationHeaderCZL."No.");
        VIESDeclarationHeaderCZL.SetRange("No.", VIESDeclarationHeaderCZL."No.");

        // [Given] VIES Declaration line for correction has been get
        VIESDeclarationLinesCZL.SetToDeclaration(VIESDeclarationHeaderCZL);
        VIESDeclarationLinesCZL.LookupMode := true;
        if VIESDeclarationLinesCZL.RunModal() = Action::LookupOK then
            VIESDeclarationLinesCZL.CopyLineToDeclaration();

        // [GIVEN] Corrective VIES Declaration has been released
        ReleaseVIESDeclarationCZL.Run(VIESDeclarationHeaderCZL);

        // [WHEN] Export corrective VIES Declaration
        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."No.");
        if VIESDeclarationLineCZL.FindSet() then
            repeat
                TempVIESDeclarationLineCZL := VIESDeclarationLineCZL;
                TempVIESDeclarationLineCZL.Insert();
            until VIESDeclarationLineCZL.Next() = 0;

        TempBlob.CreateOutStream(OutStream);
        VIESDeclarationCZL.SetHeader(VIESDeclarationHeaderCZL);
        VIESDeclarationCZL.SetLines(TempVIESDeclarationLineCZL);
        VIESDeclarationCZL.SetDestination(OutStream);
        VIESDeclarationCZL.Export();

        // [THEN] Exported XML document will exist
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        XMLBufferWriter.InitializeXMLBufferFromText(TempXMLBuffer, TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.CRLFSeparator()));

        // [THEN] Exported XML document will have VetaD
#pragma warning disable AA0210
        TempXMLBuffer.SetFilter(Path, '/Pisemnost/DPHSHV/vetaD/*');
        Assert.AreNotEqual(0, TempXMLBuffer.Count(), 'VetaD');

        // [THEN] Exported VetaD will have shvies_forma = N
        TempXMLBuffer.SetFilter(Path, '/Pisemnost/DPHSHV/vetaD/@shvies_forma');
#pragma warning restore AA0210
        TempXMLBuffer.FindFirst();
        Assert.AreEqual('N', TempXMLBuffer.Value, 'shvies_forma');

        // [THEN] Exported XML document will have VetaR
        TempXMLBuffer.SetFilter(Path, '/Pisemnost/DPHSHV/vetaR/*');
        Assert.AreNotEqual(0, TempXMLBuffer.Count(), 'VetaR');

        // [THEN] Exported VetaR will have c_vat = Customer's VAT Registration No.
        TempXMLBuffer.SetFilter(Path, '/Pisemnost/DPHSHV/vetaR/@c_vat');
        TempXMLBuffer.SetFilter(Value, Customer."VAT Registration No.");
        Assert.AreEqual(2, TempXMLBuffer.Count(), 'c_vat');
    end;

    local procedure CreateCustomer();
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", CountryRegion.Code);
        Customer."VAT Registration No." := CopyStr(LibraryRandom.RandText(20), 1, 20);
        Customer.Modify();
    end;

    local procedure CreateGLAccount()
    begin
        GLAccount.Get(LibraryERM.CreateGLAccountWithSalesSetup());
        VATPostingSetup.Get(GLAccount."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");
        VATPostingSetup.Validate("EU Service", true);
        VATPostingSetup.Validate("VIES Sales CZL", true);
        VATPostingSetup.Modify();
    end;

    local procedure CreateSalesHeader(CustomerNo: Code[20]; "3PartyIntermedRole": Boolean)
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        SalesHeader.Validate("Posting Date", VATPeriodCZL."Starting Date");
        if "3PartyIntermedRole" then
            SalesHeader.Validate("EU 3-Party Intermed. Role CZL", true);
        SalesHeader.Modify();
    end;

    local procedure CreateSalesLine()
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", GLAccount."No.", 1);
        SalesLine.Validate("Unit Price", 10000);
        SalesLine.Modify(true);
    end;

    local procedure CreateVIESDeclaration(CorrectedDeclarationNo: Code[20])
    begin
        VIESDeclarationHeaderCZL.Init();
        VIESDeclarationHeaderCZL."No." := '';
        VIESDeclarationHeaderCZL.Insert(true);
        if CorrectedDeclarationNo = '' then begin
            VIESDeclarationHeaderCZL.Validate("Declaration Period", VIESDeclarationHeaderCZL."Declaration Period"::Month);
            VIESDeclarationHeaderCZL.Validate("Declaration Type", VIESDeclarationHeaderCZL."Declaration Type"::Normal);
            VIESDeclarationHeaderCZL.Validate("Period No.", Date2DMY(VATPeriodCZL."Starting Date", 2));
            VIESDeclarationHeaderCZL.Validate(Year, Date2DMY(VATPeriodCZL."Starting Date", 3));
        end else begin
            VIESDeclarationHeaderCZL.Validate("Declaration Type", VIESDeclarationHeaderCZL."Declaration Type"::Corrective);
            VIESDeclarationHeaderCZL.Validate("Corrected Declaration No.", CorrectedDeclarationNo);
        end;
        VIESDeclarationHeaderCZL.Modify();
        Commit();
    end;

    [RequestPageHandler]
    procedure SuggestVIESDeclarationRequestPageHandler(var SuggestVIESDeclarationCZL: TestRequestPage "Suggest VIES Declaration CZL")
    begin
        SuggestVIESDeclarationCZL.DeleteLinesCZL.SetValue(true);
        SuggestVIESDeclarationCZL.IncludingAdvancePaymentsCZL.SetValue(false);
        SuggestVIESDeclarationCZL.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure VIESDeclarationTestRequestPageHandler(var VIESDeclarationTestCZL: TestRequestPage "VIES Declaration - Test CZL")
    begin
        VIESDeclarationTestCZL.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure GetLineForCorrectionModalPageHandler(var VIESDeclarationLinesCZL: TestPage "VIES Declaration Lines CZL")
    begin
        VIESDeclarationLinesCZL.Filter.SetFilter("VAT Registration No.", Customer."VAT Registration No.");
        VIESDeclarationLinesCZL.OK().Invoke();
    end;
}
