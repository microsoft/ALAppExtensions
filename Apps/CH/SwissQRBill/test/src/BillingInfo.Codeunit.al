codeunit 148091 "Swiss QR-Bill Test BillingInfo"
{
    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] [Swiss QR-Bill] [Billing Information] [UT]
    end;

    var
        Assert: Codeunit Assert;
        SwissQRBillTestLibrary: Codeunit "Swiss QR-Bill Test Library";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        SwissQRBillBillingInfoMgt: Codeunit "Swiss QR-Bill Billing Info";
        TagType: Enum "Swiss QR-Bill Billing Detail";
        VATDetailsTotalTxt: Label '%1% for the total amount', Comment = '%1 - VAT percent (0..100)';
        VATDetailsTxt: Label '%1% on %2', Comment = '%1 - VAT percent (0..100), %2 - amount';
        DateRangeTxt: Label '%1 to %2', Comment = '%1 - start\from date, %2 - end\to date';
        PaymentTermsTxt: Label '%1% discount for %2 days', Comment = '%1 - percent value (0..100), %2 - number of days';
        UnsupportedFormatMsg: Label 'Unsupported billing format.';

    [Test]
    [Scope('OnPrem')]
    procedure BillingInfoPageUI()
    var
        SwissQRBillBillingInfo: TestPage "Swiss QR-Bill Billing Info";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Billing Info" fields visibility and editable
        with SwissQRBillBillingInfo do begin
            OpenEdit();
            Assert.IsTrue(Code.Visible(), 'code should be visible');
            Assert.IsTrue(DocumentNo.Visible(), 'document no. should be visible');
            Assert.IsTrue(DocumentDate.Visible(), 'document date should be visible');
            Assert.IsTrue(VATNumber.Visible(), 'vat number should be visible');
            Assert.IsTrue(VATDate.Visible(), 'vat date should be visible');
            Assert.IsTrue(VATDetails.Visible(), 'vat details should be visible');
            Assert.IsTrue(PaymentTerms.Visible(), 'payment terms should be visible');

            Assert.IsTrue(Code.Editable(), 'code should be editable');
            Assert.IsTrue(DocumentNo.Editable(), 'document no. should be editable');
            Assert.IsTrue(DocumentDate.Editable(), 'document date should be editable');
            Assert.IsTrue(VATNumber.Editable(), 'vat number should be editable');
            Assert.IsTrue(VATDate.Editable(), 'vat date should be editable');
            Assert.IsTrue(VATDetails.Editable(), 'vat details should be editable');
            Assert.IsTrue(PaymentTerms.Editable(), 'payment terms should be editable');
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure BillingInfo_InitDefault()
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
    begin
        // [SCENARIO 259169] Record "Swiss QR-Bill Billing Info".InitDefault()
        with SwissQRBillBillingInfo do begin
            InitDefault();
            Assert.AreEqual('DEFAULT', Code, '');
            Assert.IsTrue("Document No.", '');
            Assert.IsTrue("Document Date", '');
            Assert.IsTrue("VAT Number", '');
            Assert.IsTrue("VAT Date", '');
            Assert.IsTrue("VAT Details", '');
            Assert.IsTrue("Payment Terms", '');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetBillingInformation_DisabledAll()
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
        EntryNo: Integer;
    begin
        // [SCENARIO 259169] Record "Swiss QR-Bill Billing Info".GetBillingInformation() in case of disabled all options
        EntryNo := MockCustLedgerEntry('docno123', DMY2Date(30, 12, 2020), DMY2Date(31, 12, 2020), '');
        Assert.AreEqual('', SwissQRBillBillingInfo.GetBillingInformation(EntryNo), 'disabled all bill info options');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetBillingInformation_DocumentNo()
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
        EntryNo: Integer;
    begin
        // [FEATURE] [Document No.]
        // [SCENARIO 259169] Record "Swiss QR-Bill Billing Info".GetBillingInformation() in case of only document no. option
        SwissQRBillBillingInfo.Init();
        SwissQRBillBillingInfo."Document No." := true;
        EntryNo := MockCustLedgerEntry('docno123', DMY2Date(30, 12, 2020), DMY2Date(31, 12, 2020), '');
        Assert.AreEqual('//S1/10/DOCNO123', SwissQRBillBillingInfo.GetBillingInformation(EntryNo), 'document no option');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetBillingInformation_DocumentDate()
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
        EntryNo: Integer;
    begin
        // [FEATURE] [Document Date]
        // [SCENARIO 259169] Record "Swiss QR-Bill Billing Info".GetBillingInformation() in case of only document date option
        SwissQRBillBillingInfo.Init();
        SwissQRBillBillingInfo."Document Date" := true;
        EntryNo := MockCustLedgerEntry('docno123', DMY2Date(30, 12, 2020), DMY2Date(31, 12, 2020), '');
        Assert.AreEqual('//S1/11/201230', SwissQRBillBillingInfo.GetBillingInformation(EntryNo), 'document date option');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetBillingInformation_VATNumber()
    var
        CompanyInfo: Record "Company Information";
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
        EntryNo: Integer;
    begin
        // [FEATURE] [VAT Registration No.]
        // [SCENARIO 259169] Record "Swiss QR-Bill Billing Info".GetBillingInformation() in case of only vat number option
        SwissQRBillBillingInfo.Init();
        SwissQRBillBillingInfo."VAT Number" := true;
        CompanyInfo.Get();
        CompanyInfo.TestField("VAT Registration No.");
        EntryNo := MockCustLedgerEntry('docno123', DMY2Date(30, 12, 2020), DMY2Date(31, 12, 2020), '');
        Assert.AreEqual(
            StrSubstNo('//S1/30/%1', SwissQRBillBillingInfoMgt.FormatVATRegNo(CompanyInfo."VAT Registration No.")),
            SwissQRBillBillingInfo.GetBillingInformation(EntryNo), 'vat number option');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetBillingInformation_VATDate()
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
        EntryNo: Integer;
    begin
        // [FEATURE] [VAT Date]
        // [SCENARIO 259169] Record "Swiss QR-Bill Billing Info".GetBillingInformation() in case of only vat date option
        SwissQRBillBillingInfo.Init();
        SwissQRBillBillingInfo."VAT Date" := true;
        EntryNo := MockCustLedgerEntry('docno123', DMY2Date(30, 12, 2020), DMY2Date(31, 12, 2020), '');
        Assert.AreEqual('//S1/31/201231', SwissQRBillBillingInfo.GetBillingInformation(EntryNo), 'vat date option');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetBillingInformation_VATDetails_0()
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [FEATURE] [VAT]
        // [SCENARIO 259169] Record "Swiss QR-Bill Billing Info".GetBillingInformation() in case of only vat details option, VAT% = 0
        SwissQRBillBillingInfo.Init();
        SwissQRBillBillingInfo."VAT Details" := true;
        SwissQRBillTestLibrary.UpdateDefaultVATPostingSetup(0);
        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', '');
        Assert.AreEqual(
            '//S1/32/0:100',
            SwissQRBillBillingInfo.GetBillingInformation(SalesInvoiceHeader."Cust. Ledger Entry No."), 'vat details option');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetBillingInformation_VATDetails_10()
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [FEATURE] [VAT]
        // [SCENARIO 259169] Record "Swiss QR-Bill Billing Info".GetBillingInformation() in case of only vat details option, VAT% = 10
        SwissQRBillBillingInfo.Init();
        SwissQRBillBillingInfo."VAT Details" := true;
        SwissQRBillTestLibrary.UpdateDefaultVATPostingSetup(10);
        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, '', '');
        Assert.AreEqual(
            '//S1/32/10',
            SwissQRBillBillingInfo.GetBillingInformation(SalesInvoiceHeader."Cust. Ledger Entry No."), 'vat details option');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetBillingInformation_PaymentTerms()
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [FEATURE] [Payment Terms]
        // [SCENARIO 259169] Record "Swiss QR-Bill Billing Info".GetBillingInformation() in case of only payment terms option
        SwissQRBillBillingInfo.Init();
        SwissQRBillBillingInfo."Payment Terms" := true;
        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, SwissQRBillTestLibrary.CreatePaymentTerms(1, 2), '');
        Assert.AreEqual(
            '//S1/40/1:2',
            SwissQRBillBillingInfo.GetBillingInformation(SalesInvoiceHeader."Cust. Ledger Entry No."), 'payment terms option');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetBillingInformation_PaymentTermsWithZeroPct()
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [FEATURE] [Payment Terms]
        // [SCENARIO 364778] Record "Swiss QR-Bill Billing Info".GetBillingInformation() in case of only payment terms option (with zero discount percent)
        SwissQRBillBillingInfo.Init();
        SwissQRBillBillingInfo."Payment Terms" := true;
        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, SwissQRBillTestLibrary.CreatePaymentTerms(0, 2), '');
        Assert.AreEqual(
            '//S1/40/0:2',
            SwissQRBillBillingInfo.GetBillingInformation(SalesInvoiceHeader."Cust. Ledger Entry No."), 'payment terms option');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetBillingInformation_All()
    var
        CompanyInfo: Record "Company Information";
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [SCENARIO 259169] Record "Swiss QR-Bill Billing Info".GetBillingInformation() in case of all enabled option
        CompanyInfo.Get();
        SwissQRBillBillingInfo.InitDefault();
        SwissQRBillTestLibrary.CreatePostSalesInvoice(SalesInvoiceHeader, '', 100, SwissQRBillTestLibrary.CreatePaymentTerms(1, 2), '');
        Assert.AreEqual(
            StrSubstNo(
                '//S1/10/%1/11/%2/30/%3/31/%4/32/10/40/1:2',
                SalesInvoiceHeader."No.", SwissQRBillBillingInfoMgt.FormatDate(SalesInvoiceHeader."Document Date"),
                SwissQRBillBillingInfoMgt.FormatVATRegNo(CompanyInfo."VAT Registration No."),
                SwissQRBillBillingInfoMgt.FormatDate(SalesInvoiceHeader."Posting Date")
            ),
            SwissQRBillBillingInfo.GetBillingInformation(SalesInvoiceHeader."Cust. Ledger Entry No."),
            'all neabled option');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AddBufferRecord()
    var
        SwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail";
    begin
        // [SCENARIO 259169] Record "Swiss QR-Bill Billing Detail".AddBufferRecord()
        SwissQRBillBillingDetail.AddBufferRecord('formatcode', 'tag-code', 'tag-value');
        SwissQRBillBillingDetail.AddBufferRecord('S1', '10', 'docno');
        SwissQRBillBillingDetail.AddBufferRecord('S1', '11', 'docdate');
        SwissQRBillBillingDetail.AddBufferRecord('S1', '20', 'crref');
        SwissQRBillBillingDetail.AddBufferRecord('S1', '30', 'vatno');
        SwissQRBillBillingDetail.AddBufferRecord('S1', '31', 'vatdate');
        SwissQRBillBillingDetail.AddBufferRecord('S1', '32', 'vatdetails');
        SwissQRBillBillingDetail.AddBufferRecord('S1', '33', 'vatpure');
        SwissQRBillBillingDetail.AddBufferRecord('S1', '40', 'pmtterms');

        SwissQRBillBillingDetail.AddBufferRecord('S1', TagType::"Document No.", 'docno', 'docno1');
        SwissQRBillBillingDetail.AddBufferRecord('S1', TagType::"Document Date", 'docdate', 'docdate1');
        SwissQRBillBillingDetail.AddBufferRecord('S1', TagType::"Creditor Reference", 'crref', 'crref1');
        SwissQRBillBillingDetail.AddBufferRecord('S1', TagType::"VAT Registration No.", 'vatno', 'vatno1');
        SwissQRBillBillingDetail.AddBufferRecord('S1', TagType::"VAT Date", 'vatdate', 'vatdate1');
        SwissQRBillBillingDetail.AddBufferRecord('S1', TagType::"VAT Details", 'vatdetails', 'vatdetails1');
        SwissQRBillBillingDetail.AddBufferRecord('S1', TagType::"VAT Purely On Import", 'vatpure', 'vatpure1');
        SwissQRBillBillingDetail.AddBufferRecord('S1', TagType::"Payment Terms", 'pmtterms', 'pmtterms1');

        SwissQRBillBillingDetail.FindSet();
        VerifyDetails(SwissQRBillBillingDetail, 'FORMATCODE', 'TAG-CODE', 'tag-value', TagType::Unknown, '');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '10', 'docno', TagType::"Document No.", '');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '11', 'docdate', TagType::"Document Date", '');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '20', 'crref', TagType::"Creditor Reference", '');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '30', 'vatno', TagType::"VAT Registration No.", '');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '31', 'vatdate', TagType::"VAT Date", '');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '32', 'vatdetails', TagType::"VAT Details", '');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '33', 'vatpure', TagType::"VAT Purely On Import", '');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '40', 'pmtterms', TagType::"Payment Terms", '');

        VerifyDetails(SwissQRBillBillingDetail, 'S1', '10', 'docno', TagType::"Document No.", 'docno1');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '11', 'docdate', TagType::"Document Date", 'docdate1');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '20', 'crref', TagType::"Creditor Reference", 'crref1');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '30', 'vatno', TagType::"VAT Registration No.", 'vatno1');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '31', 'vatdate', TagType::"VAT Date", 'vatdate1');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '32', 'vatdetails', TagType::"VAT Details", 'vatdetails1');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '33', 'vatpure', TagType::"VAT Purely On Import", 'vatpure1');
        VerifyDetails(SwissQRBillBillingDetail, 'S1', '40', 'pmtterms', TagType::"Payment Terms", 'pmtterms1');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure BillingDetailsPageUI()
    var
        SwissQRBillBillingDetails: TestPage "Swiss QR-Bill Billing Details";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Billing Details" fields visibility and editable
        with SwissQRBillBillingDetails do begin
            OpenEdit();
            Assert.IsTrue(FormatCodeField.Visible(), 'format code should be visible');
            Assert.IsTrue(TagField.Visible(), 'tag code should be visible');
            Assert.IsTrue(ValueField.Visible(), 'tag value should be visible');
            Assert.IsTrue(TypeField.Visible(), 'tag type should be visible');
            Assert.IsTrue(DescriptionField.Visible(), 'description should be visible');

            Assert.IsFalse(FormatCodeField.Editable(), 'format code should not be editable');
            Assert.IsFalse(TagField.Editable(), 'tag code should not be editable');
            Assert.IsFalse(ValueField.Editable(), 'tag value should not be editable');
            Assert.IsFalse(TypeField.Editable(), 'tag type should not be editable');
            Assert.IsFalse(DescriptionField.Editable(), 'description should not be editable');
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DrillDownBillingInfo_Blanked()
    begin
        // [FEATURE] [Parse]
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".DrillDownBillingInfo() doesn't show any for the blanked text
        SwissQRBillBillingInfoMgt.DrillDownBillingInfo('');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('MessageHandler')]
    procedure DrillDownBillingInfo_Unsupported()
    begin
        // [FEATURE] [Parse]
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".DrillDownBillingInfo() shows message in case of unsupported format
        Initialize();
        SwissQRBillBillingInfoMgt.DrillDownBillingInfo('unsupported');
        Assert.ExpectedMessage(UnsupportedFormatMsg, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('BillingDetailsMPH')]
    procedure DrillDownBillingInfo_UI_SX()
    begin
        // [FEATURE] [Parse] [UI]
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".DrillDownBillingInfo() shows details for "SX" format
        Initialize();
        SwissQRBillBillingInfoMgt.DrillDownBillingInfo('SX/10/docno/11/docdate/99/1;2;3');
        Assert.AreEqual('SX-10-docno-Unknown-', LibraryVariableStorage.DequeueText(), '');
        Assert.AreEqual('SX-11-docdate-Unknown-', LibraryVariableStorage.DequeueText(), '');
        Assert.AreEqual('SX-99-1;2;3-Unknown-', LibraryVariableStorage.DequeueText(), '');
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('BillingDetailsMPH')]
    procedure DrillDownBillingInfo_UI_S1()
    begin
        // [FEATURE] [Parse] [UI]
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".DrillDownBillingInfo() shows details for "S1" format
        Initialize();
        SwissQRBillBillingInfoMgt.DrillDownBillingInfo(
            'S1/10/docno/11/201231/20/CRREF/30/vat_no-1.2.3/31/201230/32/10:100;20:200;15/40/1:2;3:4');
        with LibraryVariableStorage do begin
            Assert.AreEqual('S1-10-docno-Document No.-docno', DequeueText(), '');
            Assert.AreEqual(StrSubstNo('S1-11-201231-Document Date-%1', Format(20201231D)), DequeueText(), '');
            Assert.AreEqual('S1-20-CRREF-Creditor Reference-CRREF', DequeueText(), '');
            Assert.AreEqual('S1-30-vat_no-1.2.3-VAT Registration No.-123', DequeueText(), '');
            Assert.AreEqual(StrSubstNo('S1-31-201230-VAT Date-%1', Format(20201230D)), DequeueText(), '');
            Assert.AreEqual(StrSubstNo('S1-32-10:100-VAT Details-%1', StrSubstNo(VATDetailsTxt, 10, 100)), DequeueText(), '');
            Assert.AreEqual(StrSubstNo('S1-32-20:200-VAT Details-%1', StrSubstNo(VATDetailsTxt, 20, 200)), DequeueText(), '');
            Assert.AreEqual(StrSubstNo('S1-32-15-VAT Details-%1', StrSubstNo(VATDetailsTotalTxt, 15)), DequeueText(), '');
            Assert.AreEqual(StrSubstNo('S1-40-1:2-Payment Terms-%1', StrSubstNo(PaymentTermsTxt, 1, 2)), DequeueText(), '');
            Assert.AreEqual(StrSubstNo('S1-40-3:4-Payment Terms-%1', StrSubstNo(PaymentTermsTxt, 3, 4)), DequeueText(), '');
            AssertEmpty();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('BillingDetailsMPH')]
    procedure DrillDownBillingInfo_FromCustomPrint()
    var
        SwissQRBillManualPrint: TestPage "Swiss QR-Bill Manual Print";
    begin
        // [FEATURE] [Parse] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Manual Print" drill down billing info
        Initialize();
        SwissQRBillTestLibrary.UpdateCompanyQRIBAN();

        with SwissQRBillManualPrint do begin
            OpenEdit();
            BillingInformation.SetValue('S1/10/DOCNO123');
            BillingInformation.Drilldown();
            Close();
        end;

        with LibraryVariableStorage do begin
            Assert.AreEqual('S1-10-DOCNO123-Document No.-DOCNO123', DequeueText(), '');
            AssertEmpty();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure BillingInfo_FormatDate()
    begin
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".FormatDate()
        Assert.AreEqual('200101', SwissQRBillBillingInfoMgt.FormatDate(DMY2Date(1, 1, 2020)), '');
        Assert.AreEqual('201231', SwissQRBillBillingInfoMgt.FormatDate(DMY2Date(31, 12, 2020)), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure BillingInfo_FormatVATRegNo()
    begin
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".FormatVATRegNo()
        Assert.AreEqual('', SwissQRBillBillingInfoMgt.FormatVATRegNo(''), '');
        Assert.AreEqual('1234567890', SwissQRBillBillingInfoMgt.FormatVATRegNo('1234567890'), '');
        Assert.AreEqual('123456', SwissQRBillBillingInfoMgt.FormatVATRegNo('CH-VAT_1.2-3 4;5 6 '), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure BillingInfo_GetDocumentPaymentTerms()
    begin
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".GetDocumentPaymentTerms()
        Assert.AreEqual('', SwissQRBillBillingInfoMgt.GetDocumentPaymentTerms(''), 'blanked');
        Assert.AreEqual(
            '', SwissQRBillBillingInfoMgt.GetDocumentPaymentTerms(SwissQRBillTestLibrary.CreatePaymentTerms(0, 0)), 'no discount');
        Assert.AreEqual(
            '1:2', SwissQRBillBillingInfoMgt.GetDocumentPaymentTerms(SwissQRBillTestLibrary.CreatePaymentTerms(1, 2)), 'discount');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure BillingInfo_GetDocumentVATDetails()
    var
        TempVATAmountLine: Record "VAT Amount Line" temporary;
    begin
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".GetDocumentVATDetails()
        Assert.AreEqual('', SwissQRBillBillingInfoMgt.GetDocumentVATDetails(TempVATAmountLine), 'blanked buffer');

        MockVATAmountLine(TempVATAmountLine, 0, 100);
        Assert.AreEqual('0:100', SwissQRBillBillingInfoMgt.GetDocumentVATDetails(TempVATAmountLine), '0% on 100');

        TempVATAmountLine.DeleteAll();
        MockVATAmountLine(TempVATAmountLine, 10, 100);
        Assert.AreEqual('10', SwissQRBillBillingInfoMgt.GetDocumentVATDetails(TempVATAmountLine), '10% on 100');

        MockVATAmountLine(TempVATAmountLine, 20, 200);
        Assert.AreEqual('10:100;20:200', SwissQRBillBillingInfoMgt.GetDocumentVATDetails(TempVATAmountLine), '10% on 100, 20% on 200');

        MockVATAmountLine(TempVATAmountLine, 10, 50);
        Assert.AreEqual(
            '10:150;20:200', SwissQRBillBillingInfoMgt.GetDocumentVATDetails(TempVATAmountLine), '10% on 100, 20% on 200, 10% on 50');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateBillingInfoString_Negative()
    var
        TempSwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail" temporary;
    begin
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".CreateBillingInfoString(), negative cases
        Assert.AreEqual('', SwissQRBillBillingInfoMgt.CreateBillingInfoString(TempSwissQRBillBillingDetail, ''), 'blanked buffer');

        TempSwissQRBillBillingDetail.AddBufferRecord('S1', '10', 'docno');
        Assert.AreEqual('', SwissQRBillBillingInfoMgt.CreateBillingInfoString(TempSwissQRBillBillingDetail, 'S2'), 'differ format code');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateBillingInfoString_Positive()
    var
        TempSwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail" temporary;
    begin
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".CreateBillingInfoString(), positive cases
        TempSwissQRBillBillingDetail.AddBufferRecord('SX', '10', 'docno');
        Assert.AreEqual('//SX/10/docno', SwissQRBillBillingInfoMgt.CreateBillingInfoString(TempSwissQRBillBillingDetail, 'SX'), '');

        TempSwissQRBillBillingDetail.AddBufferRecord('S1', 'tag1', 'val1');
        TempSwissQRBillBillingDetail.AddBufferRecord('S1', 'tag2', 'val2');
        TempSwissQRBillBillingDetail.AddBufferRecord('S1', 'tag2', 'val3');
        TempSwissQRBillBillingDetail.AddBufferRecord('S1', 'tag3', 'val4');
        TempSwissQRBillBillingDetail.AddBufferRecord('S2', 'tag1', 'val');
        TempSwissQRBillBillingDetail.AddBufferRecord('S3', 'tag1', 'val');
        Assert.AreEqual(
            '//S1/TAG1/val1/TAG2/val2;val3/TAG3/val4',
            SwissQRBillBillingInfoMgt.CreateBillingInfoString(TempSwissQRBillBillingDetail, 'S1'), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ParseBillingInfo_Blanked()
    var
        TempSwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail" temporary;
    begin
        // [FEATURE] [Parse]
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".ParseBillingInfo(), blanked input
        Assert.IsFalse(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, ''), 'blanked');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ParseBillingInfo_Negative()
    var
        TempSwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail" temporary;
    begin
        // [FEATURE] [Parse]
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".ParseBillingInfo(), wrong input
        Assert.IsFalse(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, 'some text'), '');
        Assert.IsFalse(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, '//////'), '');
        Assert.IsFalse(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, '\\\\\\'), '');
        Assert.IsFalse(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, '      '), '');
        Assert.IsFalse(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, 'S1/10'), '');
        Assert.IsFalse(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, '/S1/10/docno'), '');
        Assert.IsFalse(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, 'S1/10//docno'), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ParseBillingInfo_SX()
    var
        TempSwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail" temporary;
        BillingInfoString: Text;
    begin
        // [FEATURE] [Parse]
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".ParseBillingInfo(), "SX" format
        BillingInfoString := 'SX/10/docno/11/201230/20/CRREF/30/VATNO123/31/201231/32/10:100;20:200;15/33/300/40/1:2;3:4';
        Assert.IsTrue(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, BillingInfoString), '');
        TempSwissQRBillBillingDetail.FindSet();
        VerifyDetails(TempSwissQRBillBillingDetail, 'SX', '10', 'docno', TagType::Unknown, '');
        VerifyDetails(TempSwissQRBillBillingDetail, 'SX', '11', '201230', TagType::Unknown, '');
        VerifyDetails(TempSwissQRBillBillingDetail, 'SX', '20', 'CRREF', TagType::Unknown, '');
        VerifyDetails(TempSwissQRBillBillingDetail, 'SX', '30', 'VATNO123', TagType::Unknown, '');
        VerifyDetails(TempSwissQRBillBillingDetail, 'SX', '31', '201231', TagType::Unknown, '');
        VerifyDetails(TempSwissQRBillBillingDetail, 'SX', '32', '10:100;20:200;15', TagType::Unknown, '');
        VerifyDetails(TempSwissQRBillBillingDetail, 'SX', '33', '300', TagType::Unknown, '');
        VerifyDetails(TempSwissQRBillBillingDetail, 'SX', '40', '1:2;3:4', TagType::Unknown, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ParseBillingInfo_S1()
    var
        TempSwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail" temporary;
        BillingInfoString: Text;
    begin
        // [FEATURE] [Parse]
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".ParseBillingInfo(), "SX" format
        BillingInfoString := 'S1/10/docno/11/201230/20/CRREF/30/VATNO.1-2;3/31/201231/32/10:100;20:200;15/33/300/40/1:2;3:4';
        Assert.IsTrue(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, BillingInfoString), '');
        TempSwissQRBillBillingDetail.FindSet();
        VerifyDetails(TempSwissQRBillBillingDetail, 'S1', '10', 'docno', TagType::"Document No.", 'docno');
        VerifyDetails(TempSwissQRBillBillingDetail, 'S1', '11', '201230', TagType::"Document Date", Format(20201230D));
        VerifyDetails(TempSwissQRBillBillingDetail, 'S1', '20', 'CRREF', TagType::"Creditor Reference", 'CRREF');
        VerifyDetails(TempSwissQRBillBillingDetail, 'S1', '30', 'VATNO.1-2;3', TagType::"VAT Registration No.", '123');
        VerifyDetails(TempSwissQRBillBillingDetail, 'S1', '31', '201231', TagType::"VAT Date", Format(20201231D));
        VerifyDetails(TempSwissQRBillBillingDetail, 'S1', '32', '10:100', TagType::"VAT Details", StrSubstNo(VATDetailsTxt, 10, 100));
        VerifyDetails(TempSwissQRBillBillingDetail, 'S1', '32', '20:200', TagType::"VAT Details", StrSubstNo(VATDetailsTxt, 20, 200));
        VerifyDetails(TempSwissQRBillBillingDetail, 'S1', '32', '15', TagType::"VAT Details", StrSubstNo(VATDetailsTotalTxt, 15));
        VerifyDetails(TempSwissQRBillBillingDetail, 'S1', '33', '300', TagType::"VAT Purely On Import", '300');
        VerifyDetails(TempSwissQRBillBillingDetail, 'S1', '40', '1:2', TagType::"Payment Terms", StrSubstNo(PaymentTermsTxt, 1, 2));
        VerifyDetails(TempSwissQRBillBillingDetail, 'S1', '40', '3:4', TagType::"Payment Terms", StrSubstNo(PaymentTermsTxt, 3, 4));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ParseBillingInfo_SpecialSymbols()
    var
        TempSwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail" temporary;
        BillingInfoString: Text;
    begin
        // [FEATURE] [Parse]
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".ParseBillingInfo(), special encoding of "\" and "/"
        BillingInfoString := 'SX/\/\\t\/\\\//\\\/v\\\/\\';
        Assert.IsTrue(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, BillingInfoString), '');
        VerifyDetails(TempSwissQRBillBillingDetail, 'SX', '/\t/\/', '\/v\/\', TagType::Unknown, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ParseBillingInfo_DateRange()
    var
        TempSwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail" temporary;
        BillingInfoString: Text;
    begin
        // [FEATURE] [Parse]
        // [SCENARIO 259169] Codeunit "Swiss QR-Bill Billing Info".ParseBillingInfo(), date range
        BillingInfoString := 'S1/31/200101201231';
        Assert.IsTrue(SwissQRBillBillingInfoMgt.ParseBillingInfo(TempSwissQRBillBillingDetail, BillingInfoString), '');
        VerifyDetails(
            TempSwissQRBillBillingDetail, 'S1', '31', '200101201231', TagType::"VAT Date",
            StrSubstNo(DateRangeTxt, Format(20200101D), Format(20201231D)));
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
    end;

    local procedure MockVATAmountLine(var VATAmountLine: Record "VAT Amount Line"; VATPct: Decimal; VATBase: Decimal)
    begin
        with VATAmountLine do begin
            "VAT Identifier" := LibraryUtility.GenerateGUID();
            "VAT %" := VATPct;
            "VAT Base" := VATBase;
            Insert();
        end;
    end;

    local procedure MockCustLedgerEntry(DocumentNo: Code[20]; DocumentDate: Date; PostingDate: Date; PmtMethodCode: Code[10]): Integer
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        with CustLedgerEntry do begin
            Init();
            "Entry No." := LibraryUtility.GetNewRecNo(CustLedgerEntry, FieldNo("Entry No."));
            "Document Type" := "Document Type"::Invoice;
            "Document No." := DocumentNo;
            "Document Date" := DocumentDate;
            "Posting Date" := PostingDate;
            "Payment Method Code" := PmtMethodCode;
            Insert();
            exit("Entry No.");
        end;
    end;

    local procedure VerifyDetails(var SwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail"; FormatCode: Code[10]; TagCode: Code[10]; TagValue: Text; TagType: Enum "Swiss QR-Bill Billing Detail"; Description: Text)
    begin
        with SwissQRBillBillingDetail do begin
            Assert.AreEqual(FormatCode, "Format Code", 'format code');
            Assert.AreEqual(TagCode, "Tag Code", 'tag code');
            Assert.AreEqual(TagValue, "Tag Value", 'tag value');
            Assert.AreEqual(TagType, "Tag Type", 'tag type');
            Assert.AreEqual(Description, "Tag Description", 'tag description');
            Next();
        end;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;

    [ModalPageHandler]
    procedure BillingDetailsMPH(var SwissQRBillBillingDetails: TestPage "Swiss QR-Bill Billing Details")
    var
        RecText: Text;
    begin
        with SwissQRBillBillingDetails do
            repeat
                RecText := FormatCodeField.Value();
                RecText += StrSubstNo('-%1', TagField.Value());
                RecText += StrSubstNo('-%1', ValueField.Value());
                RecText += StrSubstNo('-%1', TypeField.Value());
                RecText += StrSubstNo('-%1', DescriptionField.Value());
                LibraryVariableStorage.Enqueue(RecText);
            until not Next();
    end;
}
