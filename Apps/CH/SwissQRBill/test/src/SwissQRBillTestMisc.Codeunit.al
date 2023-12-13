codeunit 148093 "Swiss QR-Bill Test Misc"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Swiss QR-Bill]
    end;

    var
        Assert: Codeunit Assert;
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        SwissQRBillTestLibrary: Codeunit "Swiss QR-Bill Test Library";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IBANType: Enum "Swiss QR-Bill IBAN Type";
        ReferenceType: Enum "Swiss QR-Bill Payment Reference Type";
        ChangeQRBillBankAccountQst: Label 'Do you want to copy Bal. Acount No. to the QR-Bill Bank Account No.?';

    [Test]
    [Scope('OnPrem')]
    procedure QRBillSetupPage_UIVisibility()
    var
        SwissQRBillSetup: TestPage "Swiss QR-Bill Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Setup" fields visibility and editability
        with SwissQRBillSetup do begin
            OpenEdit();
            Assert.IsTrue("Address Type".Visible(), '');
            Assert.IsTrue(DefaultQRBillLayout.Visible(), '');
            Assert.IsTrue(LastUsedReferenceNo.Visible(), '');
            Assert.IsTrue(QRIBAN.Visible(), '');
            Assert.IsTrue(IBAN.Visible(), '');
            Assert.IsTrue(PaymentMethods.Visible(), '');
            Assert.IsTrue(DocumentTypes.Visible(), '');

            Assert.IsTrue(PaymentJnlTemplate.Visible(), '');
            Assert.IsTrue(PaymentJnlBatch.Visible(), '');

            Assert.IsTrue(SEPANonEuroExport.Visible(), '');
            Assert.IsTrue(OpenGLSetup.Visible(), '');
            Assert.IsTrue(SEPACT.Visible(), '');
            Assert.IsTrue(SEPADD.Visible(), '');
            Assert.IsTrue(SEPACAMT.Visible(), '');

            Assert.IsTrue("Address Type".Editable(), '');
            Assert.IsTrue(DefaultQRBillLayout.Editable(), '');
            Assert.IsFalse(LastUsedReferenceNo.Editable(), '');
            Assert.IsFalse(QRIBAN.Editable(), '');
            Assert.IsFalse(IBAN.Editable(), '');
            Assert.IsFalse(PaymentMethods.Editable(), '');
            Assert.IsFalse(DocumentTypes.Editable(), '');

            Assert.IsTrue(PaymentJnlTemplate.Editable(), '');
            Assert.IsTrue(PaymentJnlBatch.Editable(), '');

            Assert.IsFalse(SEPANonEuroExport.Editable(), '');
            Assert.IsFalse(OpenGLSetup.Editable(), '');
            Assert.IsFalse(SEPACT.Editable(), '');
            Assert.IsFalse(SEPADD.Editable(), '');
            Assert.IsFalse(SEPACAMT.Editable(), '');
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CompanyInformationMPH')]
    procedure QRBillSetupPage_DrillDown_QRIBAN()
    var
        CompanyInformation: Record "Company Information";
        SwissQRBillSetup: TestPage "Swiss QR-Bill Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Setup" assert and drill down "QR-IBAN"
        SwissQRBillTestLibrary.UpdateCompanyQRIBAN();
        CompanyInformation.Get();

        with SwissQRBillSetup do begin
            OpenEdit();
            QRIBAN.AssertEquals(CompanyInformation."Swiss QR-Bill IBAN");
            QRIBAN.Drilldown();
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CompanyInformationMPH')]
    procedure QRBillSetupPage_DrillDown_IBAN()
    var
        CompanyInformation: Record "Company Information";
        SwissQRBillSetup: TestPage "Swiss QR-Bill Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Setup" assert and drill down "IBAN"
        CompanyInformation.Get();

        with SwissQRBillSetup do begin
            OpenEdit();
            IBAN.AssertEquals(CompanyInformation.IBAN);
            IBAN.Drilldown();
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('PaymentMethodsMPH')]
    procedure QRBillSetupPage_DrillDown_PmtMethods()
    var
        SwissQRBillSetup: TestPage "Swiss QR-Bill Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Setup" assert and drill down "Payment Methods"
        with SwissQRBillSetup do begin
            OpenEdit();
            PaymentMethods.AssertEquals(SwissQRBillMgt.FormatQRPaymentMethodsCount(SwissQRBillMgt.CalcQRPaymentMethodsCount()));
            PaymentMethods.Drilldown();
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ReportsMPH')]
    procedure QRBillSetupPage_DrillDown_Reports()
    var
        SwissQRBillSetup: TestPage "Swiss QR-Bill Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Setup" assert and drill down Document Types
        with SwissQRBillSetup do begin
            OpenEdit();
            DocumentTypes.AssertEquals(SwissQRBillMgt.FormatEnabledReportsCount(SwissQRBillMgt.CalcEnabledReportsCount()));
            DocumentTypes.Drilldown();
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillLayoutMPH')]
    procedure QRBillSetupPage_LookUp_DefaultLayout()
    var
        SwissQRBillSetup: TestPage "Swiss QR-Bill Setup";
        QRLayout: Code[20];
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Setup" assert and look up default layout
        QRLayout := SwissQRBillTestLibrary.CreateQRLayout(IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', '');
        SwissQRBillTestLibrary.UpdateDefaultLayout(QRLayout);

        with SwissQRBillSetup do begin
            OpenEdit();
            DefaultQRBillLayout.AssertEquals(QRLayout);
            DefaultQRBillLayout.Lookup();
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('GLSetupMPH')]
    procedure QRBillSetupPage_DrillDown_GLSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SwissQRBillSetup: TestPage "Swiss QR-Bill Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Setup" assert and drill down SEPA Non-Euro Export
        GeneralLedgerSetup.Get();
        with SwissQRBillSetup do begin
            OpenEdit();
            SEPANonEuroExport.AssertEquals(GeneralLedgerSetup."SEPA Non-Euro Export");
            OpenGLSetup.Drilldown();
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure QRBillSetupPage_DrillDown_SEPACT()
    var
        SwissQRBillSetup: TestPage "Swiss QR-Bill Setup";
        BankExportImportSetup: TestPage "Bank Export/Import Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Setup" assert and drill down SEPA CT
        with SwissQRBillSetup do begin
            OpenEdit();
            SEPACT.AssertEquals(True);
            BankExportImportSetup.Trap();
            SEPACT.Drilldown();
            BankExportImportSetup."Processing Codeunit ID".AssertEquals(11520);
            BankExportImportSetup.Close();
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure QRBillSetupPage_DrillDown_SEPADD()
    var
        SwissQRBillSetup: TestPage "Swiss QR-Bill Setup";
        BankExportImportSetup: TestPage "Bank Export/Import Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Setup" assert and drill down SEPA DD
        with SwissQRBillSetup do begin
            OpenEdit();
            SEPADD.AssertEquals(True);
            BankExportImportSetup.Trap();
            SEPADD.Drilldown();
            BankExportImportSetup."Processing Codeunit ID".AssertEquals(11530);
            BankExportImportSetup.Close();
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure QRBillSetupPage_DrillDown_SEPACAMT()
    var
        SwissQRBillSetup: TestPage "Swiss QR-Bill Setup";
        BankExportImportSetup: TestPage "Bank Export/Import Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Setup" assert and drill down SEPA CAMT
        with SwissQRBillSetup do begin
            OpenEdit();
            SEPACAMT.AssertEquals(True);
            BankExportImportSetup.Trap();
            SEPACAMT.Drilldown();
            BankExportImportSetup."Data Exch. Def. Code".AssertEquals('SEPA CAMT 054');
            BankExportImportSetup.Close();
            Close();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('BillingInfoMPH')]
    procedure QRBillLayouts_LookUp_BillingInfo()
    var
        SwissQRBillLayout: Record "Swiss QR-Bill Layout";
        SwissQRBillLayoutPage: TestPage "Swiss QR-Bill Layout";
        QRLayout: Code[20];
        BillingInfo: Code[20];
    begin
        // [FEATURE] [UI]
        // [SCENARIO 259169] Page "Swiss QR-Bill Layout" assert and look up billing information
        BillingInfo := SwissQRBillTestLibrary.CreateFullBillingInfo();
        QRLayout := SwissQRBillTestLibrary.CreateQRLayout(IBANType::"QR-IBAN", ReferenceType::"QR Reference", '', BillingInfo);
        SwissQRBillTestLibrary.UpdateDefaultLayout(QRLayout);

        SwissQRBillLayout.SetRange(Code, QRLayout);
        SwissQRBillLayoutPage.Trap();
        Page.Run(Page::"Swiss QR-Bill Layout", SwissQRBillLayout);
        SwissQRBillLayoutPage.BillingFormat.AssertEquals(BillingInfo);
        SwissQRBillLayoutPage.BillingFormat.Lookup();
        SwissQRBillLayoutPage.Close();
    end;

    [Test]
    procedure PaymentMethodQRBillBankAccountUI()
    var
        PaymentMethod: Record "Payment Method";
        PaymentMethods: TestPage "Payment Methods";
        BankAccountNo: Code[20];
    begin
        // [FEATURE] [UT] [UI] [Payment Method]
        // [SCENARIO 259169] Payment Methods page contains QR-Bill Bank Account No. field
        BankAccountNo := SwissQRBillTestLibrary.CreateBankAccount('', '');
        PaymentMethod.Get(SwissQRBillTestLibrary.CreatePaymentMethodWithQRBillBank(BankAccountNo));
        PaymentMethod.SetRecFilter();

        PaymentMethods.Trap();
        Page.Run(Page::"Payment Methods", PaymentMethod);
        PaymentMethods."Swiss QR-Bill Bank Account No.".AssertEquals(BankAccountNo);

        BankAccountNo := SwissQRBillTestLibrary.CreateBankAccount('', '');
        PaymentMethods."Swiss QR-Bill Bank Account No.".SetValue(BankAccountNo);
        PaymentMethods.Close();
        PaymentMethod.Find();
        PaymentMethod.TestField("Swiss QR-Bill Bank Account No.", BankAccountNo);
    end;

    [Test]
    procedure QRBillBankAccountIsCopiedFromBalAccSilent()
    var
        PaymentMethod: Record "Payment Method";
        BankAccountNo: Code[20];
    begin
        // [FEATURE] [UI] [Payment Method]
        // [SCENARIO 259169] System copies Bal Account No. into QR-Bill Bank Account No. field in case of blanked QR-Bill Bank Account No.
        BankAccountNo := SwissQRBillTestLibrary.CreateBankAccount('', '');
        PaymentMethod.Validate("Bal. Account Type", PaymentMethod."Bal. Account Type"::"Bank Account");

        PaymentMethod.Validate("Bal. Account No.", BankAccountNo);

        PaymentMethod.TestField("Swiss QR-Bill Bank Account No.", BankAccountNo);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure QRBillBankAccountIsNotClearedOnBlankBalAccSilent()
    var
        PaymentMethod: Record "Payment Method";
        BankAccountNo: Code[20];
    begin
        // [FEATURE] [UI] [Payment Method]
        // [SCENARIO 259169] QR-Bill Bank Account No. is not cleared on blank Bal. Account No.
        BankAccountNo := SwissQRBillTestLibrary.CreateBankAccount('', '');
        PaymentMethod.Validate("Bal. Account Type", PaymentMethod."Bal. Account Type"::"Bank Account");
        PaymentMethod.Validate("Bal. Account No.", BankAccountNo);
        PaymentMethod.Validate("Swiss QR-Bill Bank Account No.", BankAccountNo);

        PaymentMethod.Validate("Bal. Account No.", '');

        PaymentMethod.TestField("Swiss QR-Bill Bank Account No.", BankAccountNo);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ConfirmQRBillBankAccountCopyFromBalAccPositive()
    var
        PaymentMethod: Record "Payment Method";
        BankAccountNo: Code[20];
    begin
        // [FEATURE] [UI] [Payment Method]
        // [SCENARIO 259169] System confirms to copy Bal Account No. into QR-Bill Bank Account No. (accept confirm)
        PaymentMethod.Validate("Bal. Account Type", PaymentMethod."Bal. Account Type"::"Bank Account");
        PaymentMethod.Validate("Swiss QR-Bill Bank Account No.", SwissQRBillTestLibrary.CreateBankAccount('', ''));

        BankAccountNo := SwissQRBillTestLibrary.CreateBankAccount('', '');
        LibraryVariableStorage.Enqueue(true); // confirm copy
        PaymentMethod.Validate("Bal. Account No.", BankAccountNo);

        PaymentMethod.TestField("Swiss QR-Bill Bank Account No.", BankAccountNo);
        Assert.AreEqual(ChangeQRBillBankAccountQst, LibraryVariableStorage.DequeueText(), '');
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ConfirmQRBillBankAccountCopyFromBalAccNegative()
    var
        PaymentMethod: Record "Payment Method";
        BankAccountNo: Code[20];
    begin
        // [FEATURE] [UI] [Payment Method]
        // [SCENARIO 259169] System confirms to copy Bal Account No. into QR-Bill Bank Account No. (deny confirm)
        PaymentMethod.Validate("Bal. Account Type", PaymentMethod."Bal. Account Type"::"Bank Account");
        BankAccountNo := SwissQRBillTestLibrary.CreateBankAccount('', '');
        PaymentMethod.Validate("Swiss QR-Bill Bank Account No.", BankAccountNo);

        LibraryVariableStorage.Enqueue(false); // deny copy
        PaymentMethod.Validate("Bal. Account No.", SwissQRBillTestLibrary.CreateBankAccount('', ''));

        PaymentMethod.TestField("Swiss QR-Bill Bank Account No.", BankAccountNo);
        Assert.AreEqual(ChangeQRBillBankAccountQst, LibraryVariableStorage.DequeueText(), '');
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure NoConfirmQRBillBankAccountCopyFromBalAccTheSameValue()
    var
        PaymentMethod: Record "Payment Method";
        BankAccountNo: Code[20];
    begin
        // [FEATURE] [UI] [Payment Method]
        // [SCENARIO 259169] There is no confirm to copy Bal Account No. into QR-Bill Bank Account No. in case of the same value
        PaymentMethod.Validate("Bal. Account Type", PaymentMethod."Bal. Account Type"::"Bank Account");
        BankAccountNo := SwissQRBillTestLibrary.CreateBankAccount('', '');
        PaymentMethod.Validate("Swiss QR-Bill Bank Account No.", BankAccountNo);

        PaymentMethod.Validate("Bal. Account No.", BankAccountNo);

        PaymentMethod.TestField("Swiss QR-Bill Bank Account No.", BankAccountNo);
        LibraryVariableStorage.AssertEmpty();
    end;

    [ModalPageHandler]
    procedure QRBillLayoutMPH(var SwissQRBillLayout: TestPage "Swiss QR-Bill Layout")
    begin
    end;

    [ModalPageHandler]
    procedure BillingInfoMPH(var SwissQRBillBillingInfo: TestPage "Swiss QR-Bill Billing Info")
    begin
    end;

    [ModalPageHandler]
    procedure CompanyInformationMPH(var CompanyInformation: TestPage "Company Information")
    begin
    end;

    [ModalPageHandler]
    procedure PaymentMethodsMPH(var PaymentMethods: TestPage "Payment Methods")
    begin
    end;

    [ModalPageHandler]
    procedure ReportsMPH(var SwissQRBillReports: TestPage "Swiss QR-Bill Reports")
    begin
    end;

    [ModalPageHandler]
    procedure GLSetupMPH(var GeneralLedgerSetup: TestPage "General Ledger Setup")
    begin
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean);
    begin
        LibraryVariableStorage.Enqueue(Question);
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;
}
