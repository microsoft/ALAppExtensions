codeunit 148092 "Swiss QR-Bill Test Print"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Swiss QR-Bill] [Report]
    end;

    var
        Assert: Codeunit Assert;
        SwissQRBillTestLibrary: Codeunit "Swiss QR-Bill Test Library";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibrarySales: Codeunit "Library - Sales";
        LibraryService: Codeunit "Library - Service";
        ReportType: Enum "Swiss QR-Bill Reports";
        IBANType: Enum "Swiss QR-Bill IBAN Type";
        ReferenceType: Enum "Swiss QR-Bill Payment Reference Type";
        IsInitialized: Boolean;
        DocumentTypesTxt: Label '%1 of %2 Document Types enabled for QR-Bills', Comment = '%1, %2 - number of records';
        BlankedOutputErr: Label 'There is no document found to print QR-Bill with the specified filters. Only CHF and EUR currency is allowed.';

    [Test]
    [Scope('OnPrem')]
    procedure ReportsPageUIVisibility()
    var
        SwissQRBillReports: TestPage "Swiss QR-Bill Reports";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Reports" fields visibility and editable
        with SwissQRBillReports do begin
            OpenEdit();
            Assert.IsTrue("Report Type".Visible(), 'Type should be visible');
            Assert.IsTrue(Enabled.Visible(), 'Enabled should be visible');

            Assert.IsFalse("Report Type".Editable(), 'Type should not be editable');
            Assert.IsTrue(Enabled.Editable(), 'Enabled should be editable');
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ReportSelectionSalesMPH')]
    procedure ReportsPageDrillDown_SalesInvoice()
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Reports" drill-down sales invoice
        Initialize();

        PageDrillDown(ReportType::"Posted Sales Invoice");
        Assert.AreEqual('Invoice', LibraryVariableStorage.DequeueText(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ReportSelectionServiceMPH')]
    procedure ReportsPageDrillDown_ServiceInvoice()
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Reports" drill-down service invoice
        Initialize();

        PageDrillDown(ReportType::"Posted Service Invoice");
        Assert.AreEqual('Invoice', LibraryVariableStorage.DequeueText(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ReportSelectionReminderMPH')]
    procedure ReportsPageDrillDown_Reminder()
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Reports" drill-down reminder
        Initialize();

        PageDrillDown(ReportType::"Issued Reminder");
        Assert.AreEqual('Reminder', LibraryVariableStorage.DequeueText(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ReportSelectionReminderMPH')]
    procedure ReportsPageDrillDown_FinCharge()
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Reports" drill-down finance charge memo
        Initialize();

        PageDrillDown(ReportType::"Issued Finance Charge Memo");
        Assert.AreEqual('Fin. Charge', LibraryVariableStorage.DequeueText(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReportsEnabling()
    var
        TempSwissQRBillReports: Record "Swiss QR-Bill Reports" temporary;
    begin
        // [SCENARIO 259169] Record "Swiss QR-Bill Reports" enabling reports
        with TempSwissQRBillReports do begin
            InitBuffer();
            Assert.RecordCount(TempSwissQRBillReports, 2);

            ModifyAll(Enabled, false);
            VerifyAllReportEnabling(false, false, false, false);

            FindFirst();
            VerifyReportEnabling(TempSwissQRBillReports, 1, ReportType::"Posted Sales Invoice", true, true, false, false, false);
            VerifyReportEnabling(TempSwissQRBillReports, 2, ReportType::"Posted Service Invoice", true, true, true, false, false);
            // VerifyReportEnabling(Reports, 3, ReportType::"Issued Reminder", true, true, true, true, false);
            // VerifyReportEnabling(Reports, 4, ReportType::"Issued Finance Charge Memo", true, true, true, true, true);

            FindFirst();
            VerifyReportEnabling(TempSwissQRBillReports, 1, ReportType::"Posted Sales Invoice", false, false, true, false, false);
            VerifyReportEnabling(TempSwissQRBillReports, 0, ReportType::"Posted Service Invoice", false, false, false, false, false);
            // VerifyReportEnabling(Reports, 1, ReportType::"Issued Reminder", false, false, false, false, true);
            // VerifyReportEnabling(Reports, 0, ReportType::"Issued Finance Charge Memo", false, false, false, false, false);
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure Print_PostedSalesInvoice_Disabled()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of empty report selections
        Initialize();
        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', '');

        asserterror PrintPostedSalesInvoice(SalesInvoiceHeader);

        Assert.ExpectedError('The Report Selections table is empty.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_CHF_QRIBAN()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentReference: Code[50];
        QRLayout: Code[20];
        BilliingInfoString: Text;
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of CHF, default QRIBAN type, blanked pmt. method
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        QRLayout :=
            SwissQRBillTestLibrary.CreateQRLayout(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', SwissQRBillTestLibrary.CreateFullBillingInfo());
        SwissQRBillTestLibrary.UpdateDefaultLayout(QRLayout);

        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, SwissQRBillTestLibrary.CreatePaymentTerms(1, 2), '');
        Customer.Get(SalesInvoiceHeader."Bill-to Customer No.");
        PaymentReference := SwissQRBillTestLibrary.GetNextReferenceNo(ReferenceType::"QR Reference", false);

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        CustLedgerEntry.Get(SalesInvoiceHeader."Cust. Ledger Entry No.");
        Assert.AreEqual(PaymentReference, CustLedgerEntry."Payment Reference", 'Payment Reference');
        Assert.AreEqual(PaymentReference, SalesInvoiceHeader."Payment Reference", 'Payment Reference');
        Assert.AreEqual(QRLayout, SwissQRBillTestLibrary.GetQRLayoutForThePostedSalesInvoice(SalesInvoiceHeader), '');
        BilliingInfoString := SwissQRBillTestLibrary.GetBillInfoString(QRLayout, SalesInvoiceHeader."Cust. Ledger Entry No.");

        VerifyReportDataset(
            'CHF', 110, SwissQRBillTestLibrary.FormatReferenceNo(SalesInvoiceHeader."Payment Reference"), BilliingInfoString);
        VerifyReportDatasetCreditorInfo(GetReportCompanyInfo(IBANType::"QR-IBAN"));
        VerifyReportDatasetDebitorInfo(ReportFormatCustomerPartyInfo(Customer));
        VerifyReportDatasetAltProc('', '', '', '');
        VerifyReportDatasetLablels();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedServiceInvoice_CHF_QRIBAN()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentReference: Code[50];
        QRLayout: Code[20];
        BilliingInfoString: Text;
    begin
        // [FEATURE] [UI] [Print] [Service]
        // [SCENARIO 259169] Print posted sales invoice in case of CHF, default QRIBAN type, blanked pmt. method
        Initialize();
        EnableReport(ReportType::"Posted Service Invoice", true);
        QRLayout :=
            SwissQRBillTestLibrary.CreateQRLayout(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', SwissQRBillTestLibrary.CreateFullBillingInfo());
        SwissQRBillTestLibrary.UpdateDefaultLayout(QRLayout);

        SwissQRBillTestLibrary.CreatePostServiceInvoice(ServiceInvoiceHeader, '', 100, SwissQRBillTestLibrary.CreatePaymentTerms(1, 2), '');
        Customer.Get(ServiceInvoiceHeader."Bill-to Customer No.");
        PaymentReference := SwissQRBillTestLibrary.GetNextReferenceNo(ReferenceType::"QR Reference", false);

        PrintPostedServiceInvoice(ServiceInvoiceHeader);

        Assert.IsTrue(
            SwissQRBillMgt.FindCustLedgerEntry(
                CustLedgerEntry."Entry No.", Customer."No.", CustLedgerEntry."Document Type"::Invoice,
                ServiceInvoiceHeader."No.", ServiceInvoiceHeader."Posting Date"), '');
        CustLedgerEntry.Find();
        Assert.AreEqual(PaymentReference, CustLedgerEntry."Payment Reference", 'Payment Reference');
        Assert.AreEqual(PaymentReference, ServiceInvoiceHeader."Payment Reference", 'Payment Reference');
        Assert.AreEqual(QRLayout, SwissQRBillTestLibrary.GetQRLayoutForThePostedServiceInvoice(ServiceInvoiceHeader), '');
        BilliingInfoString := SwissQRBillTestLibrary.GetBillInfoString(QRLayout, CustLedgerEntry."Entry No.");

        VerifyReportDataset('CHF', 110, SwissQRBillTestLibrary.FormatReferenceNo(PaymentReference), BilliingInfoString);
        VerifyReportDatasetCreditorInfo(GetReportCompanyInfo(IBANType::"QR-IBAN"));
        VerifyReportDatasetDebitorInfo(ReportFormatCustomerPartyInfo(Customer));
        VerifyReportDatasetAltProc('', '', '', '');
        VerifyReportDatasetLablels();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_EUR_QRIBAN()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentReference: Code[50];
        QRLayout: Code[20];
        BilliingInfoString: Text;
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of EUR, default QRIBAN type, blanked pmt. method
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        QRLayout :=
            SwissQRBillTestLibrary.CreateQRLayout(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', SwissQRBillTestLibrary.CreateFullBillingInfo());
        SwissQRBillTestLibrary.UpdateDefaultLayout(QRLayout);

        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, 'EUR', 100, SwissQRBillTestLibrary.CreatePaymentTerms(1, 2), '');
        Customer.Get(SalesInvoiceHeader."Bill-to Customer No.");
        PaymentReference := SwissQRBillTestLibrary.GetNextReferenceNo(ReferenceType::"QR Reference", false);

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        CustLedgerEntry.Get(SalesInvoiceHeader."Cust. Ledger Entry No.");
        Assert.AreEqual(PaymentReference, CustLedgerEntry."Payment Reference", 'Payment Reference');
        Assert.AreEqual(PaymentReference, SalesInvoiceHeader."Payment Reference", 'Payment Reference');
        Assert.AreEqual(QRLayout, SwissQRBillTestLibrary.GetQRLayoutForThePostedSalesInvoice(SalesInvoiceHeader), '');
        BilliingInfoString := SwissQRBillTestLibrary.GetBillInfoString(QRLayout, SalesInvoiceHeader."Cust. Ledger Entry No.");

        VerifyReportDataset(
            'EUR', 110, SwissQRBillTestLibrary.FormatReferenceNo(SalesInvoiceHeader."Payment Reference"), BilliingInfoString);
        VerifyReportDatasetCreditorInfo(GetReportCompanyInfo(IBANType::"QR-IBAN"));
        VerifyReportDatasetDebitorInfo(ReportFormatCustomerPartyInfo(Customer));
        VerifyReportDatasetAltProc('', '', '', '');
        VerifyReportDatasetLablels();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_CHF_IBAN_PMTMTD_QRIBAN()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PaymentReference: Code[50];
        QRLayout: Code[20];
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of CHF, default IBAN type, pmt. method for QRIBAN
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.UpdateDefaultLayout(
            SwissQRBillTestLibrary.CreateQRLayout(IBANType::IBAN, ReferenceType::"Creditor Reference (ISO 11649)", '', ''));

        QRLayout := SwissQRBillTestLibrary.CreateQRLayout(IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', '');
        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', SwissQRBillTestLibrary.CreatePaymentMethod(QRLayout));
        PaymentReference := SwissQRBillTestLibrary.GetNextReferenceNo(ReferenceType::"QR Reference", false);

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        Assert.AreEqual(PaymentReference, SalesInvoiceHeader."Payment Reference", 'Payment Reference');
        Assert.AreEqual(QRLayout, SwissQRBillTestLibrary.GetQRLayoutForThePostedSalesInvoice(SalesInvoiceHeader), '');

        VerifyReportDataset('CHF', 110, SwissQRBillTestLibrary.FormatReferenceNo(SalesInvoiceHeader."Payment Reference"), '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_EUR_QRIBAN_PMTMTD_IBAN()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PaymentReference: Code[50];
        QRLayout: Code[20];
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of EUR, default QR-IBAN type, pmt. method for IBAN
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.UpdateDefaultLayout(
            SwissQRBillTestLibrary.CreateQRLayout(IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', ''));

        QRLayout := SwissQRBillTestLibrary.CreateQRLayout(IBANType::IBAN, ReferenceType::"Creditor Reference (ISO 11649)", '', '');
        SwissQRBillTestLibrary.CreatePostSalesInvoice(
            SalesInvoiceHeader, 'EUR', 100, '', SwissQRBillTestLibrary.CreatePaymentMethod(QRLayout));
        PaymentReference := SwissQRBillTestLibrary.GetNextReferenceNo(ReferenceType::"Creditor Reference (ISO 11649)", false);

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        Assert.AreEqual(PaymentReference, SalesInvoiceHeader."Payment Reference", 'Payment Reference');
        Assert.AreEqual(QRLayout, SwissQRBillTestLibrary.GetQRLayoutForThePostedSalesInvoice(SalesInvoiceHeader), '');

        VerifyReportDataset('EUR', 110, SwissQRBillTestLibrary.FormatReferenceNo(SalesInvoiceHeader."Payment Reference"), '');
        VerifyReportDatasetCreditorInfo(GetReportCompanyInfo(IBANType::IBAN));
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_UnstrMsg()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        UnstrMessage: Text;
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of unstructured message
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        UnstrMessage := LibraryUtility.GenerateGUID();
        SwissQRBillTestLibrary.UpdateDefaultLayout(
            SwissQRBillTestLibrary.CreateQRLayout(IBANType::"QR-IBAN", ReferenceType::"QR Reference", UnstrMessage, ''));

        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', '');
        SwissQRBillTestLibrary.GetNextReferenceNo(ReferenceType::"QR Reference", false);

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        VerifyReportDataset('CHF', 110, SwissQRBillTestLibrary.FormatReferenceNo(SalesInvoiceHeader."Payment Reference"), UnstrMessage);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_BIllInfoAndUnstrMsg()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        QRLayout: Code[20];
        BilliingInfoString: Text;
        UnstrMessage: Text;
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of billing info and unstructured message
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        UnstrMessage := LibraryUtility.GenerateGUID();
        QRLayout :=
            SwissQRBillTestLibrary.CreateQRLayout(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", UnstrMessage, SwissQRBillTestLibrary.CreateFullBillingInfo());
        SwissQRBillTestLibrary.UpdateDefaultLayout(QRLayout);

        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', '');
        SwissQRBillTestLibrary.GetNextReferenceNo(ReferenceType::"QR Reference", false);

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        BilliingInfoString := SwissQRBillTestLibrary.GetBillInfoString(QRLayout, SalesInvoiceHeader."Cust. Ledger Entry No.");

        UnstrMessage += ' ' + BilliingInfoString;
        VerifyReportDataset('CHF', 110, SwissQRBillTestLibrary.FormatReferenceNo(SalesInvoiceHeader."Payment Reference"), UnstrMessage);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_AltProc1()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        AltName1: Text;
        AltValue1: Text;
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of alternative procedure 1
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        AltName1 := LibraryUtility.GenerateGUID();
        AltValue1 := LibraryUtility.GenerateGUID();
        SwissQRBillTestLibrary.UpdateDefaultLayout(
            SwissQRBillTestLibrary.CreateQRLayoutFull(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', '', AltName1, AltValue1, '', ''));

        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', '');

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        VerifyReportDatasetAltProc(AltName1, AltValue1, '', '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_AltProc2()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        AltName2: Text;
        AltValue2: Text;
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of alternative procedure 2
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        AltName2 := LibraryUtility.GenerateGUID();
        AltValue2 := LibraryUtility.GenerateGUID();
        SwissQRBillTestLibrary.UpdateDefaultLayout(
            SwissQRBillTestLibrary.CreateQRLayoutFull(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', '', '', '', AltName2, AltValue2));

        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', '');

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        VerifyReportDatasetAltProc('', '', AltName2, AltValue2);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_AltProcBoth()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        AltName: array[2] of Text;
        AltValue: array[2] of Text;
        i: Integer;
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of both alternative procedures
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        for i := 1 to ArrayLen(AltName) do begin
            AltName[i] := LibraryUtility.GenerateGUID();
            AltValue[i] := LibraryUtility.GenerateGUID();
        end;
        SwissQRBillTestLibrary.UpdateDefaultLayout(
            SwissQRBillTestLibrary.CreateQRLayoutFull(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', '', AltName[1], AltValue[1], AltName[2], AltValue[2]));

        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', '');

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        VerifyReportDatasetAltProc(AltName[1], AltValue[1], AltName[2], AltValue[2]);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_BIllInfoUnstrMsgAndBothAltProc()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        QRLayout: Code[20];
        BilliingInfoString: Text;
        UnstrMessage: Text;
        AltName: array[2] of Text;
        AltValue: array[2] of Text;
        i: Integer;
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of billing info, unstructured message and both alternative procedures
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        for i := 1 to ArrayLen(AltName) do begin
            AltName[i] := LibraryUtility.GenerateGUID();
            AltValue[i] := LibraryUtility.GenerateGUID();
        end;
        UnstrMessage := LibraryUtility.GenerateGUID();
        QRLayout :=
            SwissQRBillTestLibrary.CreateQRLayoutFull(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", UnstrMessage, SwissQRBillTestLibrary.CreateFullBillingInfo(),
                AltName[1], AltValue[1], AltName[2], AltValue[2]);
        SwissQRBillTestLibrary.UpdateDefaultLayout(QRLayout);

        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', '');

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        BilliingInfoString := SwissQRBillTestLibrary.GetBillInfoString(QRLayout, SalesInvoiceHeader."Cust. Ledger Entry No.");
        UnstrMessage += ' ' + BilliingInfoString;
        VerifyReportDataset('CHF', 110, SwissQRBillTestLibrary.FormatReferenceNo(SalesInvoiceHeader."Payment Reference"), UnstrMessage);
        VerifyReportDatasetAltProc(AltName[1], AltValue[1], AltName[2], AltValue[2]);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_USD()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print posted sales invoice in case of EUR currency
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, 'USD', 100, '', '');

        asserterror PrintPostedSalesInvoice(SalesInvoiceHeader);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(BlankedOutputErr);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_AlreadyPrinted_QRRef()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentReference: Code[50];
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print already printed posted sales invoices in case of QR-reference (QR-IBAN)
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.UpdateDefaultLayout(
            SwissQRBillTestLibrary.CreateQRLayout(IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', ''));

        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', '');
        PrintPostedSalesInvoice(SalesInvoiceHeader);
        SalesInvoiceHeader.TestField("Payment Reference");
        PaymentReference := SalesInvoiceHeader."Payment Reference";

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        CustLedgerEntry.Get(SalesInvoiceHeader."Cust. Ledger Entry No.");
        Assert.AreEqual(PaymentReference, CustLedgerEntry."Payment Reference", '');
        Assert.AreEqual(PaymentReference, SalesInvoiceHeader."Payment Reference", '');
        VerifyReportDataset('CHF', 110, SwissQRBillTestLibrary.FormatReferenceNo(PaymentReference), '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_AlreadyPrinted_CRRef()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentReference: Code[50];
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 259169] Print already printed posted sales invoices in case of Creditor-reference (IBAN)
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.UpdateDefaultLayout(
            SwissQRBillTestLibrary.CreateQRLayout(IBANType::IBAN, ReferenceType::"Creditor Reference (ISO 11649)", '', ''));

        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', '');
        PrintPostedSalesInvoice(SalesInvoiceHeader);
        SalesInvoiceHeader.TestField("Payment Reference");
        PaymentReference := SalesInvoiceHeader."Payment Reference";

        PrintPostedSalesInvoice(SalesInvoiceHeader);

        CustLedgerEntry.Get(SalesInvoiceHeader."Cust. Ledger Entry No.");
        Assert.AreEqual(PaymentReference, CustLedgerEntry."Payment Reference", '');
        Assert.AreEqual(PaymentReference, SalesInvoiceHeader."Payment Reference", '');
        VerifyReportDataset('CHF', 110, SwissQRBillTestLibrary.FormatReferenceNo(PaymentReference), '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_FromBuffer()
    var
        TempSwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary;
        PaymentReference: Code[50];
    begin
        // [FEATURE] [Print]
        // [SCENARIO 259169] Print from "Swiss QR-Bill Buffer"
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.UpdateDefaultLayout(
            SwissQRBillTestLibrary.CreateQRLayout(IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', ''));
        PaymentReference := SwissQRBillTestLibrary.GetNextReferenceNo(ReferenceType::"QR Reference", false);

        with TempSwissQRBillBuffer do begin
            InitBuffer('');
            Validate(Amount, LibraryRandom.RandDecInRange(1000, 2000, 2));
            Validate("Unstructured Message", LibraryUtility.GenerateGUID());
            Insert();

            PrintFromBuffer(TempSwissQRBillBuffer);

            Find();
            TestField("Payment Reference", SwissQRBillTestLibrary.FormatReferenceNo(PaymentReference));
            VerifyReportDataset('CHF', Amount, SwissQRBillTestLibrary.FormatReferenceNo(PaymentReference), "Unstructured Message");
        end;
    end;

    [Test]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_BlankedBankAccountQRIBAN()
    var
        SalesInvoiceHeader: Record 112;
    begin
        // [FEATURE] [UI] [Print] [QR-IBAN] [Payment Method]
        // [SCENARIO 259169] An error occurs on missing QR-IBAN value in bank account specified in payment method
        Initialize();

        // [GIVEN] QR-Bills are setup with QR-IBAN by default
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.UpdateDefaultLayout(
          SwissQRBillTestLibrary.CreateQRLayout(IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', ''));
        // [GIVEN] Bank Account "B" with blanked QR-IBAN value
        // [GIVEN] Posted sales invoice with payment method having QR-Bill Bank Account No. = "B"
        SwissQRBillTestLibrary.CreatePostSalesInvoice(
          SalesInvoiceHeader, '', 100, '',
          SwissQRBillTestLibrary.CreatePaymentMethodWithQRBillBank(SwissQRBillTestLibrary.CreateBankAccount('', '')));

        // [WHEN] Print QR-Bill for the invoice
        asserterror PrintPostedSalesInvoice(SalesInvoiceHeader);

        // [THEN] An error occurs on missing QR-IBAN value in Bank Account "B"
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError('QR-IBAN must have a value in Bank Account');
    end;

    [Test]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_BlankedBankAccountIBAN()
    var
        SalesInvoiceHeader: Record 112;
    begin
        // [FEATURE] [UI] [Print] [IBAN] [Payment Method]
        // [SCENARIO 259169] An error occurs on missing IBAN value in bank account specified in payment method
        Initialize();

        // [GIVEN] QR-Bills are setup with IBAN by default
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.UpdateDefaultLayout(
          SwissQRBillTestLibrary.CreateQRLayout(IBANType::IBAN, ReferenceType::"Creditor Reference (ISO 11649)", '', ''));
        // [GIVEN] Bank Account "B" with blanked IBAN value
        // [GIVEN] Posted sales invoice with payment method having QR-Bill Bank Account No. = "B"
        SwissQRBillTestLibrary.CreatePostSalesInvoice(
          SalesInvoiceHeader, '', 100, '',
          SwissQRBillTestLibrary.CreatePaymentMethodWithQRBillBank(SwissQRBillTestLibrary.CreateBankAccount('', '')));

        // [WHEN] Print QR-Bill for the invoice
        asserterror PrintPostedSalesInvoice(SalesInvoiceHeader);

        // [THEN] An error occurs on missing IBAN value in Bank Account "B"
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError('IBAN must have a value in Bank Account');
    end;

    [Test]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_BlankedCompanyQRIBAN()
    var
        SalesInvoiceHeader: Record 112;
    begin
        // [FEATURE] [UI] [Print] [QR-IBAN]
        // [SCENARIO 259169] An error occurs on missing QR-IBAN value in company information
        Initialize();

        // [GIVEN] QR-Bills are setup with QR-IBAN by default
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.UpdateDefaultLayout(
          SwissQRBillTestLibrary.CreateQRLayout(IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', ''));
        // [GIVEN] Company information with blanked QR-IBAN value
        SwissQRBillTestLibrary.UpdateCompanyIBANAndQRIBAN('', '');
        // [GIVEN] Posted sales invoice with payment method having blanked QR-Bill Bank Account No.
        SwissQRBillTestLibrary.CreatePostSalesInvoice(
          SalesInvoiceHeader, '', 100, '',
          SwissQRBillTestLibrary.CreatePaymentMethodWithQRBillBank(SwissQRBillTestLibrary.CreateBankAccount('', '')));

        // [WHEN] Print QR-Bill for the invoice
        asserterror PrintPostedSalesInvoice(SalesInvoiceHeader);

        // [THEN] An error occurs on missing QR-IBAN value in company information
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError('QR-IBAN must have a value in Company Information');
    end;

    [Test]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_BlankedCompanyIBAN()
    var
        SalesInvoiceHeader: Record 112;
    begin
        // [FEATURE] [UI] [Print] [IBAN]
        // [SCENARIO 259169] An error occurs on missing IBAN value in company information
        Initialize();

        // [GIVEN] QR-Bills are setup with IBAN by default
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.UpdateDefaultLayout(
          SwissQRBillTestLibrary.CreateQRLayout(IBANType::IBAN, ReferenceType::"Creditor Reference (ISO 11649)", '', ''));
        // [GIVEN] Company information with blanked IBAN value
        SwissQRBillTestLibrary.UpdateCompanyIBANAndQRIBAN('', '');
        // [GIVEN] Posted sales invoice with payment method having blanked QR-Bill Bank Account No.
        SwissQRBillTestLibrary.CreatePostSalesInvoice(
          SalesInvoiceHeader, '', 100, '',
          SwissQRBillTestLibrary.CreatePaymentMethodWithQRBillBank(SwissQRBillTestLibrary.CreateBankAccount('', '')));

        // [WHEN] Print QR-Bill for the invoice
        asserterror PrintPostedSalesInvoice(SalesInvoiceHeader);

        // [THEN] An error occurs on missing QR-IBAN value in company information
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError('IBAN must have a value in Company Information');
    end;

    [Test]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_BankAccountQRIBAN()
    var
        SalesInvoiceHeader: Record 112;
        QRIBAN: Code[50];
    begin
        // [FEATURE] [UI] [Print] [QR-IBAN] [Payment Method]
        // [SCENARIO 259169] Print posted sales invoice with QR-IBAN value from bank account specified in payment method
        Initialize();

        // [GIVEN] QR-Bills are setup with QR-IBAN by default
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.UpdateDefaultLayout(
          SwissQRBillTestLibrary.CreateQRLayout(IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', ''));
        // [GIVEN] Bank Account "B" with QR-IBAN = "X"
        // [GIVEN] Posted sales invoice with payment method having QR-Bill Bank Account No. = "B"
        QRIBAN := LibraryUtility.GenerateGUID();
        SwissQRBillTestLibrary.CreatePostSalesInvoice(
          SalesInvoiceHeader, '', 100, '',
          SwissQRBillTestLibrary.CreatePaymentMethodWithQRBillBank(SwissQRBillTestLibrary.CreateBankAccount('', QRIBAN)));

        // [WHEN] Print QR-Bill for the invoice
        PrintPostedSalesInvoice(SalesInvoiceHeader);

        // [THEN] QR-Bill has been printed with creditor IBAN = "X"
        VerifyReportDatasetCreditorInfo(SwissQRBillMgt.FormatIBAN(QRIBAN));
    end;

    [Test]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure Print_PostedSalesInvoice_BankAccountIBAN()
    var
        SalesInvoiceHeader: Record 112;
        IBAN: Code[50];
    begin
        // [FEATURE] [UI] [Print] [IBAN] [Payment Method]
        // [SCENARIO 259169] Print posted sales invoice with IBAN value from bank account specified in payment method
        Initialize();

        // [GIVEN] QR-Bills are setup with IBAN by default
        EnableReport(ReportType::"Posted Sales Invoice", true);
        SwissQRBillTestLibrary.UpdateDefaultLayout(
          SwissQRBillTestLibrary.CreateQRLayout(IBANType::IBAN, ReferenceType::"Creditor Reference (ISO 11649)", '', ''));
        // [GIVEN] Bank Account "B" with IBAN = "X"
        // [GIVEN] Posted sales invoice with payment method having QR-Bill Bank Account No. = "B"
        IBAN := LibraryUtility.GenerateGUID();
        SwissQRBillTestLibrary.CreatePostSalesInvoice(
          SalesInvoiceHeader, '', 100, '',
          SwissQRBillTestLibrary.CreatePaymentMethodWithQRBillBank(SwissQRBillTestLibrary.CreateBankAccount(IBAN, '')));

        // [WHEN] Print QR-Bill for the invoice
        PrintPostedSalesInvoice(SalesInvoiceHeader);

        // [THEN] QR-Bill has been printed with creditor IBAN = "X"
        VerifyReportDatasetCreditorInfo(SwissQRBillMgt.FormatIBAN(IBAN));
    end;

    [Test]
    procedure PrintUmlautsUsingWesternEuropeanISO88591Codepage()
    var
        TempBlob: Codeunit "Temp Blob";
        SwissQRBillIBarcodeProvider: DotNet "Swiss QR-Bill IBarcode Provider";
        SwissQRBillQRCodeProvider: DotNet "Swiss QR-Bill QRCode Provider";
        SwissQRBillErrorCorrectionLevel: DotNet "Swiss QR-Bill Error Correction Level";
        OutStream: OutStream;
        UmlautChars: Text;
        i: Integer;
    begin
        // [SCENARIO 409387] QR Bills can be printed with umlaut symbols within the QR Code using Western European ISO-8859-1 codepage
        UmlautChars := PadStr('', 64, ' ');
        for i := 192 to 255 do
            UmlautChars[i - 191] := i;

        TempBlob.CreateOutStream(OutStream);
        SwissQRBillIBarcodeProvider := SwissQRBillQRCodeProvider.QRCodeProvider();
        SwissQRBillIBarcodeProvider.GetBarcodeStream(UmlautChars, OutStream, SwissQRBillErrorCorrectionLevel::Medium, 5, 0, 28591);
    end;

    [Test]
    procedure PrintUmlautsUsingUTF8CodepageECIModeOn()
    var
        TempBlob: Codeunit "Temp Blob";
        SwissQRBillIBarcodeProvider: DotNet "Swiss QR-Bill IBarcode Provider";
        SwissQRBillQRCodeProvider: DotNet "Swiss QR-Bill QRCode Provider";
        SwissQRBillErrorCorrectionLevel: DotNet "Swiss QR-Bill Error Correction Level";
        OutStream: OutStream;
        UmlautChars: Text;
        i: Integer;
    begin
        // [SCENARIO 440686] QR Bills can be printed with umlaut symbols within the QR Code using UTF-8 codepage with enabled ECI mode.
        UmlautChars := PadStr('', 64, ' ');
        for i := 192 to 255 do
            UmlautChars[i - 191] := i;

        TempBlob.CreateOutStream(OutStream);
        SwissQRBillIBarcodeProvider := SwissQRBillQRCodeProvider.QRCodeProvider();
        SwissQRBillIBarcodeProvider.GetBarcodeStream(UmlautChars, OutStream, SwissQRBillErrorCorrectionLevel::Medium, 5, 0, 65001, false, true);
    end;

    [Test]
    procedure PrintUmlautsUsingUTF8CodepageECIModeOff()
    var
        TempBlob: Codeunit "Temp Blob";
        SwissQRBillIBarcodeProvider: DotNet "Swiss QR-Bill IBarcode Provider";
        SwissQRBillQRCodeProvider: DotNet "Swiss QR-Bill QRCode Provider";
        SwissQRBillErrorCorrectionLevel: DotNet "Swiss QR-Bill Error Correction Level";
        OutStream: OutStream;
        UmlautChars: Text;
        i: Integer;
    begin
        // [SCENARIO 440686] QR Bills can be printed with umlaut symbols within the QR Code using UTF-8 codepage with disabled ECI mode.
        UmlautChars := PadStr('', 64, ' ');
        for i := 192 to 255 do
            UmlautChars[i - 191] := i;

        TempBlob.CreateOutStream(OutStream);
        SwissQRBillIBarcodeProvider := SwissQRBillQRCodeProvider.QRCodeProvider();
        SwissQRBillIBarcodeProvider.GetBarcodeStream(UmlautChars, OutStream, SwissQRBillErrorCorrectionLevel::Medium, 5, 0, 65001, false, false);
    end;

    [Test]
    procedure PrintUmlautsUsingUTF8CodepageBOMOnECIModeOn()
    var
        TempBlob: Codeunit "Temp Blob";
        SwissQRBillIBarcodeProvider: DotNet "Swiss QR-Bill IBarcode Provider";
        SwissQRBillQRCodeProvider: DotNet "Swiss QR-Bill QRCode Provider";
        SwissQRBillErrorCorrectionLevel: DotNet "Swiss QR-Bill Error Correction Level";
        OutStream: OutStream;
        UmlautChars: Text;
        i: Integer;
    begin
        // [SCENARIO 440686] QR Bills can be printed with umlaut symbols within the QR Code using UTF-8 codepage with enabled ECI mode and byte-order-mark set.
        UmlautChars := PadStr('', 64, ' ');
        for i := 192 to 255 do
            UmlautChars[i - 191] := i;

        TempBlob.CreateOutStream(OutStream);
        SwissQRBillIBarcodeProvider := SwissQRBillQRCodeProvider.QRCodeProvider();
        SwissQRBillIBarcodeProvider.GetBarcodeStream(UmlautChars, OutStream, SwissQRBillErrorCorrectionLevel::Medium, 5, 0, 65001, true, true);
    end;

    [Test]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure TenantMediaWhenPrintPostedSalesInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TenantMedia: Record "Tenant Media";
        TenantMediaThumbnails: Record "Tenant Media Thumbnails";
        QRLayout: Code[20];
    begin
        // [FEATURE] [Print]
        // [SCENARIO 449921] Tenant Media and Tenant Media Thumbnails records when print posted sales invoice.
        Initialize();
        TenantMedia.DeleteAll();
        TenantMediaThumbnails.DeleteAll();

        // [GIVEN] Report 11510 "Swiss QR-Bill Print" is set as a default report for printing posted sales invoices.
        EnableReport(ReportType::"Posted Sales Invoice", true);
        QRLayout :=
            SwissQRBillTestLibrary.CreateQRLayout(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', SwissQRBillTestLibrary.CreateFullBillingInfo());
        SwissQRBillTestLibrary.UpdateDefaultLayout(QRLayout);

        // [GIVEN] Posted sales invoice.
        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, SwissQRBillTestLibrary.CreatePaymentTerms(1, 2), '');

        // [WHEN] Print posted sales invoice.
        PrintPostedSalesInvoice(SalesInvoiceHeader);

        // [THEN] Report layout was printed.
        // [THEN] Tenant Media and Tenant Media Thumbnails records that were created during report run, are removed in the end.
        VerifyReportDatasetCreditorInfo(GetReportCompanyInfo(IBANType::"QR-IBAN"));
        Assert.IsTrue(TenantMedia.IsEmpty(), 'Tenant Media was not removed');
        Assert.IsTrue(TenantMediaThumbnails.IsEmpty(), 'Tenant Media Thumbnails were not removed');
    end;

    [Test]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure TenantMediaWhenPrintMultiplePostedSalesInvoices()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TenantMedia: Record "Tenant Media";
        TenantMediaThumbnails: Record "Tenant Media Thumbnails";
        SalesInvoiceHeaderNo: array[2] of Code[20];
        QRLayout: Code[20];
    begin
        // [FEATURE] [Print]
        // [SCENARIO 449921] Tenant Media and Tenant Media Thumbnails records when print multiple posted sales invoices.
        Initialize();
        TenantMedia.DeleteAll();
        TenantMediaThumbnails.DeleteAll();

        // [GIVEN] Report 11510 "Swiss QR-Bill Print" is set as a default report for printing posted sales invoices.
        EnableReport(ReportType::"Posted Sales Invoice", true);
        QRLayout :=
            SwissQRBillTestLibrary.CreateQRLayout(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', SwissQRBillTestLibrary.CreateFullBillingInfo());
        SwissQRBillTestLibrary.UpdateDefaultLayout(QRLayout);

        // [GIVEN] Two posted sales invoices.
        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, SwissQRBillTestLibrary.CreatePaymentTerms(1, 2), '');
        SalesInvoiceHeaderNo[1] := SalesInvoiceHeader."No.";
        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, SwissQRBillTestLibrary.CreatePaymentTerms(1, 2), '');
        SalesInvoiceHeaderNo[2] := SalesInvoiceHeader."No.";

        // [WHEN] Print both posted sales invoices.
        SalesInvoiceHeader.SetFilter("No.", '%1|%2', SalesInvoiceHeaderNo[1], SalesInvoiceHeaderNo[2]);
        SalesInvoiceHeader.PrintRecords(true);

        // [THEN] Report layout was printed.
        // [THEN] Tenant Media and Tenant Media Thumbnails records that were created during report run, are removed in the end.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.GetNextRow();
        VerifyReportDatasetCreditorInfo(GetReportCompanyInfo(IBANType::"QR-IBAN"));
        Assert.IsTrue(TenantMedia.IsEmpty(), 'Tenant Media was not removed');
        Assert.IsTrue(TenantMediaThumbnails.IsEmpty(), 'Tenant Media Thumbnails were not removed');
    end;

    [Test]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure PrintPostedSalesInvoiceDifferentBillToAddress()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        BillToInfo: Dictionary of [Text, Text];
        QRLayout: Code[20];
    begin
        // [FEATURE] [UI] [Print]
        // [SCENARIO 486959] Print posted sales invoice when Bill-to information is different from the Sell-to information.
        Initialize();
        EnableReport(ReportType::"Posted Sales Invoice", true);
        QRLayout :=
            SwissQRBillTestLibrary.CreateQRLayout(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', SwissQRBillTestLibrary.CreateFullBillingInfo());
        SwissQRBillTestLibrary.UpdateDefaultLayout(QRLayout);

        // [GIVEN] Posted Sales Invoice with Bill-to information different from the Sell-to information.
        SwissQRBillTestLibrary.CreateSalesInvoice(SalesHeader, '', 100, SwissQRBillTestLibrary.CreatePaymentTerms(1, 2), '');
        BillToInfo.Add('BillToName', LibraryUtility.GenerateGUID());
        BillToInfo.Add('BillToAddress', LibraryUtility.GenerateGUID());
        BillToInfo.Add('BillToAddress2', LibraryUtility.GenerateGUID());
        BillToInfo.Add('BillToPostCode', LibraryUtility.GenerateGUID());
        BillToInfo.Add('BillToCity', LibraryUtility.GenerateGUID());
        BillToInfo.Add('BillToCountryRegion', LibraryUtility.GenerateGUID());
        UpdateBillToInfoOnSalesInvoice(SalesHeader, BillToInfo);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, false, true));

        // [WHEN] Run Swiss QR-Bill report on Posted Sales Invoice.
        PrintPostedSalesInvoice(SalesInvoiceHeader);

        // [THEN] Section Payable By contains Bill-to information.
        VerifyReportDatasetDebitorInfo(FormatPayableByInfo(BillToInfo));
    end;

    [Test]
    [HandlerFunctions('QRBillPrintRPH')]
    procedure PrintPostedServiceInvoiceDifferentBillToAddress()
    var
        ServiceHeader: Record "Service Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        BillToInfo: Dictionary of [Text, Text];
        QRLayout: Code[20];
    begin
        // [FEATURE] [UI] [Print] [Service]
        // [SCENARIO 486959] Print posted service invoice when Bill-to information is different from the Sell-to information.
        Initialize();
        EnableReport(ReportType::"Posted Service Invoice", true);
        QRLayout :=
            SwissQRBillTestLibrary.CreateQRLayout(
                IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', SwissQRBillTestLibrary.CreateFullBillingInfo());
        SwissQRBillTestLibrary.UpdateDefaultLayout(QRLayout);

        // [GIVEN] Posted Service Invoice with Bill-to information different from the Sell-to information.
        SwissQRBillTestLibrary.CreateServiceInvoice(ServiceHeader, '', 100, SwissQRBillTestLibrary.CreatePaymentTerms(1, 2), '');
        BillToInfo.Add('BillToName', LibraryUtility.GenerateGUID());
        BillToInfo.Add('BillToAddress', LibraryUtility.GenerateGUID());
        BillToInfo.Add('BillToAddress2', LibraryUtility.GenerateGUID());
        BillToInfo.Add('BillToPostCode', LibraryUtility.GenerateGUID());
        BillToInfo.Add('BillToCity', LibraryUtility.GenerateGUID());
        BillToInfo.Add('BillToCountryRegion', LibraryUtility.GenerateGUID());
        UpdateBillToInfoOnServiceInvoice(ServiceHeader, BillToInfo);
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        LibraryService.FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");

        // [WHEN] Run Swiss QR-Bill report on Posted Sales Invoice.
        PrintPostedServiceInvoice(ServiceInvoiceHeader);

        // [THEN] Section Payable By contains Bill-to information.
        VerifyReportDatasetDebitorInfo(FormatPayableByInfo(BillToInfo));
    end;

    local procedure Initialize()
    var
        DummyReportSelections: Record "Report Selections";
    begin
        ClearReportSelections(DummyReportSelections.Usage::"S.Invoice");
        ClearReportSelections(DummyReportSelections.Usage::"SM.Invoice");
        LibraryVariableStorage.Clear();
        LibrarySetupStorage.Restore();

        if IsInitialized then
            exit;
        IsInitialized := true;

        SwissQRBillTestLibrary.UpdateDefaultVATPostingSetup(10);
        SwissQRBillTestLibrary.UpdateCompanyQRIBAN();
        LibrarySetupStorage.Save(Database::"Company Information");
    end;

    local procedure PageDrillDown(ReportTypeFilter: Enum "Swiss QR-Bill Reports")
    var
        SwissQRBillReports: TestPage "Swiss QR-Bill Reports";
    begin
        with SwissQRBillReports do begin
            OpenEdit();
            Filter.SetFilter("Report Type", Format(ReportTypeFilter));
            "Report Type".Drilldown();
            Close();
        end;
    end;

    local procedure PrintPostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        PostedSalesInvoicePage: TestPage "Posted Sales Invoice";
    begin
        PostedSalesInvoicePage.Trap();
        Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader);
        Commit();
        PostedSalesInvoicePage.Print.Invoke();
        PostedSalesInvoicePage.Close();

        SalesInvoiceHeader.Find();
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.GetNextRow();
    end;

    local procedure PrintPostedServiceInvoice(var ServiceInvoiceHeader: Record "Service Invoice Header")
    var
        PostedServiceInvoicePage: TestPage "Posted Service Invoice";
    begin
        PostedServiceInvoicePage.Trap();
        Page.Run(Page::"Posted Service Invoice", ServiceInvoiceHeader);
        Commit();
        PostedServiceInvoicePage."&Print".Invoke();
        PostedServiceInvoicePage.Close();

        ServiceInvoiceHeader.Find();
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.GetNextRow();
    end;

    local procedure PrintFromBuffer(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer")
    var
        SwissQRBillPrint: Report "Swiss QR-Bill Print";
    begin
        Commit();
        SwissQRBillPrint.SetBuffer(SwissQRBillBuffer);
        SwissQRBillPrint.RunModal();

        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.GetNextRow();
    end;

    local procedure ClearReportSelections(UsageFilter: Enum "Report Selection Usage")
    var
        ReportSelections: Record "Report Selections";
    begin
        with ReportSelections do begin
            SetRange(Usage, UsageFilter);
            DeleteAll();
        end;
    end;

    local procedure EnableReport(ReportType: Enum "Swiss QR-Bill Reports"; Enable: Boolean)
    var
        TempSwissQRBillReports: Record "Swiss QR-Bill Reports" temporary;
    begin
        with TempSwissQRBillReports do begin
            Validate("Report Type", ReportType);
            Validate(Enabled, Enable);
        end;
    end;

    local procedure GetReportCompanyInfo(IBANTypeLcl: Enum "Swiss QR-Bill IBAN Type") Result: Text
    var
        CompanyInformation: Record "Company Information";
        TempSwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary;
        TempCustomer: Record Customer temporary;
        IBAN: Code[50];
    begin
        CompanyInformation.Get();
        if IBANTypeLcl = IBANType::IBAN then
            IBAN := CompanyInformation.IBAN
        else
            IBAN := CompanyInformation."Swiss QR-Bill IBAN";
        Result := SwissQRBillMgt.FormatIBAN(IBAN);
        TempSwissQRBillBuffer.SetCompanyInformation();
        if TempSwissQRBillBuffer.GetCreditorInfo(TempCustomer) then
            SwissQRBillMgt.AddLine(Result, ReportFormatCustomerPartyInfo(TempCustomer));
    end;

    local procedure ReportFormatCustomerPartyInfo(Customer: Record Customer) Result: Text
    begin
        with Customer do begin
            SwissQRBillMgt.AddLineIfNotBlanked(Result, CopyStr(Name, 1, 70));
            SwissQRBillMgt.AddLineIfNotBlanked(Result, CopyStr(Address + ' ' + "Address 2", 1, 70));
            SwissQRBillMgt.AddLineIfNotBlanked(Result, CopyStr("Post Code" + ' ' + City, 1, 70));
        end;
    end;

    local procedure FormatPayableByInfo(BillToInfo: Dictionary of [Text, Text]) Result: Text
    begin
        SwissQRBillMgt.AddLineIfNotBlanked(Result, CopyStr(BillToInfo.Get('BillToName'), 1, 70));
        SwissQRBillMgt.AddLineIfNotBlanked(Result, CopyStr(BillToInfo.Get('BillToAddress') + ' ' + BillToInfo.Get('BillToAddress2'), 1, 70));
        SwissQRBillMgt.AddLineIfNotBlanked(Result, CopyStr(BillToInfo.Get('BillToPostCode') + ' ' + BillToInfo.Get('BillToCity'), 1, 70));
    end;

    local procedure UpdateBillToInfoOnSalesInvoice(var SalesHeader: Record "Sales Header"; BillToInfo: Dictionary of [Text, Text])
    begin
        SalesHeader."Bill-to Name" := CopyStr(BillToInfo.Get('BillToName'), 1, MaxStrLen(SalesHeader."Bill-to Name"));
        SalesHeader."Bill-to Address" := CopyStr(BillToInfo.Get('BillToAddress'), 1, MaxStrLen(SalesHeader."Bill-to Address"));
        SalesHeader."Bill-to Address 2" := CopyStr(BillToInfo.Get('BillToAddress2'), 1, MaxStrLen(SalesHeader."Bill-to Address 2"));
        SalesHeader."Bill-to Post Code" := CopyStr(BillToInfo.Get('BillToPostCode'), 1, MaxStrLen(SalesHeader."Bill-to Post Code"));
        SalesHeader."Bill-to City" := CopyStr(BillToInfo.Get('BillToCity'), 1, MaxStrLen(SalesHeader."Bill-to City"));
        SalesHeader."Bill-to Country/Region Code" := CopyStr(BillToInfo.Get('BillToCountryRegion'), 1, MaxStrLen(SalesHeader."Bill-to Country/Region Code"));
        SalesHeader.Modify();
    end;

    local procedure UpdateBillToInfoOnServiceInvoice(var ServiceHeader: Record "Service Header"; BillToInfo: Dictionary of [Text, Text])
    begin
        ServiceHeader."Bill-to Name" := CopyStr(BillToInfo.Get('BillToName'), 1, MaxStrLen(ServiceHeader."Bill-to Name"));
        ServiceHeader."Bill-to Address" := CopyStr(BillToInfo.Get('BillToAddress'), 1, MaxStrLen(ServiceHeader."Bill-to Address"));
        ServiceHeader."Bill-to Address 2" := CopyStr(BillToInfo.Get('BillToAddress2'), 1, MaxStrLen(ServiceHeader."Bill-to Address 2"));
        ServiceHeader."Bill-to Post Code" := CopyStr(BillToInfo.Get('BillToPostCode'), 1, MaxStrLen(ServiceHeader."Bill-to Post Code"));
        ServiceHeader."Bill-to City" := CopyStr(BillToInfo.Get('BillToCity'), 1, MaxStrLen(ServiceHeader."Bill-to City"));
        ServiceHeader."Bill-to Country/Region Code" := CopyStr(BillToInfo.Get('BillToCountryRegion'), 1, MaxStrLen(ServiceHeader."Bill-to Country/Region Code"));
        ServiceHeader.Modify();
    end;

    local procedure VerifyReportEnabling(var SwissQRBillReports: Record "Swiss QR-Bill Reports"; ExpectedCount: Integer; ExpectedCurrentType: Enum "Swiss QR-Bill Reports"; Enable: Boolean;
                                                                                                                                                  SalesInvoice: Boolean;
                                                                                                                                                  ServiceInvoice: Boolean;
                                                                                                                                                  Reminder: Boolean;
                                                                                                                                                  FinCharge: Boolean)
    var
        EnabledReportsCount: Integer;
    begin
        Assert.AreEqual(ExpectedCurrentType, SwissQRBillReports."Report Type", '');
        SwissQRBillReports.Validate(Enabled, Enable);
        VerifyAllReportEnabling(SalesInvoice, ServiceInvoice, Reminder, FinCharge);
        SwissQRBillReports.Next();
        EnabledReportsCount := SwissQRBillMgt.CalcEnabledReportsCount();
        Assert.AreEqual(ExpectedCount, EnabledReportsCount, '');
        Assert.AreEqual(
            StrSubstNo(DocumentTypesTxt, EnabledReportsCount, 2), SwissQRBillMgt.FormatEnabledReportsCount(EnabledReportsCount), '');
    end;

    local procedure VerifyAllReportEnabling(SalesInvoice: Boolean; ServiceInvoice: Boolean; Reminder: Boolean; FinCharge: Boolean)
    var
        DummyReportSelections: Record "Report Selections";
    begin
        VerifyReportSelection(DummyReportSelections.Usage::"S.Invoice", SalesInvoice);
        VerifyReportSelection(DummyReportSelections.Usage::"SM.Invoice", ServiceInvoice);
        VerifyReportSelection(DummyReportSelections.Usage::Reminder, Reminder);
        VerifyReportSelection(DummyReportSelections.Usage::"Fin.Charge", FinCharge);
    end;

    local procedure VerifyReportSelection(UsageFilter: Enum "Report Selection Usage"; ExpectedEnabled: Boolean)
    var
        ReportSelections: Record "Report Selections";
    begin
        with ReportSelections do begin
            SetRange(Usage, UsageFilter);
            SetRange("Report ID", Report::"Swiss QR-Bill Print");
            if ExpectedEnabled then
                Assert.RecordIsNotEmpty(ReportSelections)
            else
                Assert.RecordIsEmpty(ReportSelections);
        end;
    end;

    local procedure VerifyReportDataset(Currency: Text; Amount: Decimal; ReferenceNo: Text; BillInfo: Text)
    begin
        LibraryReportDataset.AssertCurrentRowValueEquals('CurrencyText', Currency);
        LibraryReportDataset.AssertCurrentRowValueEquals('AmountText', SwissQRBillTestLibrary.FormatAmount(Amount));
        LibraryReportDataset.AssertCurrentRowValueEquals('ReferenceText', ReferenceNo);
        LibraryReportDataset.AssertCurrentRowValueEquals('AdditionalInformationText', BillInfo);
    end;

    local procedure VerifyReportDatasetCreditorInfo(ExpectedText: Text)
    begin
        VerifyReportDatasetText('AccountPayableToText', ExpectedText);
    end;

    local procedure VerifyReportDatasetDebitorInfo(ExpectedText: Text)
    begin
        VerifyReportDatasetText('PayableByText', ExpectedText);
    end;

    local procedure VerifyReportDatasetText(DatasetFieldName: Text; ExpectedText: text)
    var
        Variant: Variant;
        ActualText: Text;
    begin
        LibraryReportDataset.GetElementValueInCurrentRow(DatasetFieldName, Variant);
        ActualText := Variant;
        ActualText := SwissQRBillTestLibrary.ReplaceLineBreakWithBackSlash(ActualText).Trim();
        ExpectedText := SwissQRBillTestLibrary.ReplaceLineBreakWithBackSlash(ExpectedText).Trim();
        Assert.ExpectedMessage(ExpectedText, ActualText);
    end;

    local procedure VerifyReportDatasetAltProc(Name1: Text; Value1: text; Name2: Text; Value2: text)
    begin
        LibraryReportDataset.AssertCurrentRowValueEquals('AltProcName1Lbl', Name1);
        LibraryReportDataset.AssertCurrentRowValueEquals('AltProcName2Lbl', Name2);
        LibraryReportDataset.AssertCurrentRowValueEquals('AltProcValue1Text', Value1);
        LibraryReportDataset.AssertCurrentRowValueEquals('AltProcValue2Text', Value2);
    end;

    local procedure VerifyReportDatasetLablels()
    begin
        LibraryReportDataset.AssertCurrentRowValueEquals('PaymentPartLbl', 'Payment part');
        LibraryReportDataset.AssertCurrentRowValueEquals('AccountPayableToLbl', 'Account / Payable to');
        LibraryReportDataset.AssertCurrentRowValueEquals('ReferenceLbl', 'Reference');
        LibraryReportDataset.AssertCurrentRowValueEquals('AdditionalInformationLbl', 'Additional information');
        LibraryReportDataset.AssertCurrentRowValueEquals('CurrencyLbl', 'Currency');
        LibraryReportDataset.AssertCurrentRowValueEquals('AmountLbl', 'Amount');
        LibraryReportDataset.AssertCurrentRowValueEquals('ReceiptLbl', 'Receipt');
        LibraryReportDataset.AssertCurrentRowValueEquals('AcceptancePointLbl', 'Acceptance point');
        LibraryReportDataset.AssertCurrentRowValueEquals('PayableByLbl', 'Payable by');
        LibraryReportDataset.AssertCurrentRowValueEquals('PayableByNameAddressLbl', 'Payable by (name/address)');
        LibraryReportDataset.AssertCurrentRowValueEquals('SeparateLbl', 'Separate before paying in');
    end;

    [ModalPageHandler]
    procedure ReportSelectionSalesMPH(var ReportSelectionSales: TestPage "Report Selection - Sales")
    begin
        LibraryVariableStorage.Enqueue(ReportSelectionSales.ReportUsage.Value());
    end;

    [ModalPageHandler]
    procedure ReportSelectionServiceMPH(var ReportSelectionService: TestPage "Report Selection - Service")
    begin
        LibraryVariableStorage.Enqueue(ReportSelectionService.ReportUsage2.Value());
    end;

    [ModalPageHandler]
    procedure ReportSelectionReminderMPH(var ReportSelectionReminder: TestPage "Report Selection - Reminder")
    begin
        LibraryVariableStorage.Enqueue(ReportSelectionReminder.ReportUsage2.Value());
    end;

    [RequestPageHandler]
    procedure QRBillPrintRPH(var SwissQRBillPrint: TestRequestPage "Swiss QR-Bill Print")
    begin
        SwissQRBillPrint.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}
