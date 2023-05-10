codeunit 148096 "Swiss QR-Bill Test Purchases"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Swiss QR-Bill] [Purchases]
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryInventory: Codeunit "Library - Inventory";
        Assert: Codeunit Assert;
        SwissQRBillTestLibrary: Codeunit "Swiss QR-Bill Test Library";
        DocumentType: Enum "Purchase Document Type";
        IsInitialized: Boolean;
        ImportFailedTxt: Label 'QR-Bill import failed.';
        DecodeFailedTxt: Label 'Could not decode QR-Bill information.';
        ImportSuccessMsg: Label 'QR-Bill successfully imported.';
        ScanAnotherQst: Label 'Do you want to scan another QR-Bill?';
        ImportCancelledMsg: Label 'QR-Bill import was cancelled.';
        BlankedImportErr: Label 'There is no data to import.';
        ImportWarningTxt: Label 'QR-Bill import warning.';
        ContinueQst: Label 'Do you want to continue?';
        JournalProcessVendorNotFoundTxt: Label 'Could not find a vendor with IBAN or QR-IBAN:\%1', Comment = '%1 - IBAN value';
        PurchInvoicePmtRefAlreadyExistsTxt: Label 'Purchase invoice with the same payment reference already exists for this vendor:';
        PurchOrderPmtRefAlreadyExistsTxt: Label 'Purchase order with the same payment reference already exists for this vendor:';
        VendorLedgerEntryPmtRefAlreadyExistsTxt: Label 'Vendor ledger entry with the same payment reference already exists for this vendor:';
        JnlLinePmtRefAlreadyExistsTxt: Label 'Purchase journal line with the same payment reference already exists for this vendor:';
        IncDocPmtRefAlreadyExistsTxt: Label 'Incoming Document with the same payment reference already exists for this vendor:';
        PurchDocAlreadyQRImportedQst: Label 'The purchase document already has imported QR-Bill.\\Do you want to continue?';
        PurchDocDiffVendorMsg: Label 'The IBAN/QR-IBAN value from the QR-Bill is used on a vendor bank account belonging to another vendor:\%1 %2.\\On this purchase document you can only scan or import QR-Bills that match the vendor:\%3 %4.', Comment = '%1, %3- vendor numbers, %2, %4 - vendor names';
        PurhDocVendBankAccountQst: Label 'A vendor bank account with IBAN or QR-IBAN\%1\was not found.\\Do you want to create a new vendor bank account?', Comment = '%1 - IBAN value';
        VendorTxt: Label 'Vendor: %1 %2', Comment = '%1 - vendor no., %2 - vendor name';
        PaymentRefTxt: Label 'Payment Reference: %1', Comment = '%1 - payment reference number';
        DocumentNoTxt: Label 'Document No.: %1', Comment = '%1 - document no.';
        VendLedgerEntryTxt: Label 'Vendor Ledger Entry No.: %1', Comment = '%1 - vendor ledger entry no.';
        IncDocEntryTxt: Label 'Incoming Document Entry No.: %1', Comment = '%1 - incoming document entry no.';
        JnlTemplateTxt: Label 'Journal Template Name: %1', Comment = '%1 - journal template name';
        JnlBatchTxt: Label 'Journal Batch Name: %1', Comment = '%1 - journal batch name';
        JnlLineTxt: Label 'Line No.: %1', Comment = '%1 - journal line no.';
        CurrencyErr: Label 'Purchase document currency must be equal to QR-Bill currency ''%1''. Current value is ''%2''.', Comment = '%1, %2 - currency codes';
        AmountErr: Label 'Purchase document amount must be equal to QR-Bill amount %1. Current value is %2.', Comment = '%1, %2 - amounts';

    [Test]
    [Scope('OnPrem')]
    procedure Invoice_UI_NoQRBill()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Page "Purchase Invoice" fields, actions w/o QR-Bill
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, '', false, '');

        PurchaseHeader.SetRecFilter();
        PurchaseInvoice.Trap();
        Page.Run(Page::"Purchase Invoice", PurchaseHeader);

        // actions
        Assert.IsTrue(PurchaseInvoice."Swiss QR-Bill Import".Visible(), '');
        Assert.IsTrue(PurchaseInvoice."Swiss QR-Bill Scan".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Void".Visible(), '');

        // fields
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Amount".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Amount".Editable(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Currency".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Currency".Editable(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill IBAN".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill IBAN".Editable(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Bill Info".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Bill Info".Editable(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Unstr. Message".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Unstr. Message".Editable(), '');

        // Payment Reference field
        Assert.IsTrue(PurchaseInvoice."Payment Reference".Visible(), '');
        Assert.IsTrue(PurchaseInvoice."Payment Reference".Editable(), '');

        PurchaseInvoice.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure Invoice_UI_QRBill()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Page "Purchase Invoice" fields, actions in case of QR-Bill
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, '', true, '');

        PurchaseHeader.SetRecFilter();
        PurchaseInvoice.Trap();
        Page.Run(Page::"Purchase Invoice", PurchaseHeader);

        // actions
        Assert.IsTrue(PurchaseInvoice."Swiss QR-Bill Import".Visible(), '');
        Assert.IsTrue(PurchaseInvoice."Swiss QR-Bill Scan".Visible(), '');
        Assert.IsTrue(PurchaseInvoice."Swiss QR-Bill Void".Visible(), '');

        // fields
        Assert.IsTrue(PurchaseInvoice."Swiss QR-Bill Amount".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Amount".Editable(), '');
        Assert.IsTrue(PurchaseInvoice."Swiss QR-Bill Currency".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Currency".Editable(), '');
        Assert.IsTrue(PurchaseInvoice."Swiss QR-Bill IBAN".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill IBAN".Editable(), '');
        Assert.IsTrue(PurchaseInvoice."Swiss QR-Bill Bill Info".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Bill Info".Editable(), '');
        Assert.IsTrue(PurchaseInvoice."Swiss QR-Bill Unstr. Message".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Unstr. Message".Editable(), '');

        // Payment Reference field
        Assert.IsTrue(PurchaseInvoice."Payment Reference".Visible(), '');
        Assert.IsFalse(PurchaseInvoice."Payment Reference".Editable(), '');

        PurchaseInvoice.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure Order_UI_NoQRBill()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseOrder: TestPage "Purchase Order";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Page "Purchase Order" fields, actions w/o QR-Bill
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Order, '', false, '');

        PurchaseHeader.SetRecFilter();
        PurchaseOrder.Trap();
        Page.Run(Page::"Purchase Order", PurchaseHeader);

        // actions
        Assert.IsTrue(PurchaseOrder."Swiss QR-Bill Import".Visible(), '');
        Assert.IsTrue(PurchaseOrder."Swiss QR-Bill Scan".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Void".Visible(), '');

        // fields
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Amount".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Amount".Editable(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Currency".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Currency".Editable(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill IBAN".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill IBAN".Editable(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Bill Info".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Bill Info".Editable(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Unstr. Message".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Unstr. Message".Editable(), '');


        // Payment Reference field
        Assert.IsTrue(PurchaseOrder."Payment Reference".Visible(), '');
        Assert.IsTrue(PurchaseOrder."Payment Reference".Editable(), '');

        PurchaseOrder.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure Order_UI_QRBill()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseOrder: TestPage "Purchase Order";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Page "Purchase Order" fields, actions in case of QR-Bill
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Order, '', true, '');

        PurchaseHeader.SetRecFilter();
        PurchaseOrder.Trap();
        Page.Run(Page::"Purchase Order", PurchaseHeader);

        // actions
        Assert.IsTrue(PurchaseOrder."Swiss QR-Bill Import".Visible(), '');
        Assert.IsTrue(PurchaseOrder."Swiss QR-Bill Scan".Visible(), '');
        Assert.IsTrue(PurchaseOrder."Swiss QR-Bill Void".Visible(), '');

        // fields
        Assert.IsTrue(PurchaseOrder."Swiss QR-Bill Amount".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Amount".Editable(), '');
        Assert.IsTrue(PurchaseOrder."Swiss QR-Bill Currency".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Currency".Editable(), '');
        Assert.IsTrue(PurchaseOrder."Swiss QR-Bill IBAN".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill IBAN".Editable(), '');
        Assert.IsTrue(PurchaseOrder."Swiss QR-Bill Bill Info".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Bill Info".Editable(), '');
        Assert.IsTrue(PurchaseOrder."Swiss QR-Bill Unstr. Message".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Unstr. Message".Editable(), '');

        // Payment Reference field
        Assert.IsTrue(PurchaseOrder."Payment Reference".Visible(), '');
        Assert.IsFalse(PurchaseOrder."Payment Reference".Editable(), '');

        PurchaseOrder.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure Journal_UI_NoQRBill()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseJournal: TestPage "Purchase Journal";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Page "Purchase Journal" fields, actions w/o QR-Bill
        CreateJournalLine(GenJournalLine, '', false, '');

        GenJournalLine.SetRecFilter();
        PurchaseJournal.Trap();
        Page.Run(Page::"Purchase Journal", GenJournalLine);

        // actions
        Assert.IsTrue(PurchaseJournal."Swiss QR-Bill Import".Visible(), '');
        Assert.IsTrue(PurchaseJournal."Swiss QR-Bill Scan".Visible(), '');

        // Payment Reference field
        Assert.IsTrue(PurchaseJournal."Swiss QR-Bill Payment Reference".Visible(), '');
        Assert.IsTrue(PurchaseJournal."Swiss QR-Bill Payment Reference".Editable(), '');

        PurchaseJournal.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure Journal_UI_QRBill()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseJournal: TestPage "Purchase Journal";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Page "Purchase Journal" fields, actions in case of QR-Bill
        CreateJournalLine(GenJournalLine, '', true, '');

        GenJournalLine.SetRecFilter();
        PurchaseJournal.Trap();
        Page.Run(Page::"Purchase Journal", GenJournalLine);

        // actions
        Assert.IsTrue(PurchaseJournal."Swiss QR-Bill Import".Visible(), '');
        Assert.IsTrue(PurchaseJournal."Swiss QR-Bill Scan".Visible(), '');

        // Payment Reference field
        Assert.IsTrue(PurchaseJournal."Swiss QR-Bill Payment Reference".Visible(), '');
        Assert.IsFalse(PurchaseJournal."Swiss QR-Bill Payment Reference".Editable(), '');

        PurchaseJournal.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure Invoice_Scan_Success_Void()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of existing vendor bank account, void after
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, VendorNo, false, '');

        LibraryVariableStorage.Enqueue(QRCodeText);
        ScanToInvoice(PurchaseHeader);

        // success scan
        Assert.ExpectedMessage(ImportSuccessMsg, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, true, PaymentReference, 'DOCNO123', 123.45, 'CHF', IBAN, 'Unstr Msg', BillInfo);

        // success void
        VoidInvoice(PurchaseHeader);
        VerifyPurchDoc(PurchaseHeader, false, '', '', 0, '', '', '', '');

        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure Invoice_Scan_DiffVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: array[2] of Record Vendor;
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of existing vendor bank account, but different current document vendor
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        Vendor[1].Get(VendorNo);
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, '', false, '');
        Vendor[2].Get(PurchaseHeader."Buy-from Vendor No.");

        LibraryVariableStorage.Enqueue(QRCodeText);
        ScanToInvoice(PurchaseHeader);

        // different vendor
        Assert.ExpectedMessage(
            ImportFailedTxt + '\\' +
            StrSubstNo(
                PurchDocDiffVendorMsg,
                Vendor[1]."No.", 'CR Name',
                Vendor[2]."No.", Vendor[2].Name),
            LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, false, '', '', 0, '', '', '', '');

        LibraryVariableStorage.AssertEmpty();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH')]
    procedure Invoice_Scan_Blanked()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of blanked input
        Initialize();
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, '', false, '');

        LibraryVariableStorage.Enqueue('');
        asserterror ScanToInvoice(PurchaseHeader);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(BlankedImportErr);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure Invoice_Scan_DecodeFailed()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of decode fail
        Initialize();
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, '', false, '');

        LibraryVariableStorage.Enqueue('wrong qr-code');
        ScanToInvoice(PurchaseHeader);

        // decode failed
        Assert.ExpectedMessage(ImportFailedTxt + '\\' + DecodeFailedTxt, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, false, '', '', 0, '', '', '', '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,MessageHandler,ConfirmHandler')]
    procedure Invoice_Scan_Replace_Success()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of existing vendor bank account, confirm replace existing QR-bill
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, VendorNo, true, '123');

        LibraryVariableStorage.Enqueue(true); // confirm replace
        LibraryVariableStorage.Enqueue(QRCodeText);
        ScanToInvoice(PurchaseHeader);

        // success scan
        Assert.ExpectedMessage(PurchDocAlreadyQRImportedQst, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(ImportSuccessMsg, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, true, PaymentReference, 'DOCNO123', 123.45, 'CHF', IBAN, 'Unstr Msg', BillInfo);

        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure Invoice_Scan_Replace_Deny()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of existing vendor bank account, deny replace existing QR-bill
        Initialize();
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, '', true, '123');

        LibraryVariableStorage.Enqueue(false); // deny replace
        ScanToInvoice(PurchaseHeader);

        // cancelled import
        Assert.ExpectedMessage(PurchDocAlreadyQRImportedQst, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, true, '123', '', 0, '', '', '', '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,MessageHandler,ConfirmHandler')]
    procedure Invoice_Scan_CreateBankAccount_Cancel()
    var
        PurchaseHeader: Record "Purchase Header";
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice, deny to create a new vendor bank account
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, '', false, '123');

        LibraryVariableStorage.Enqueue(QRCodeText);
        LibraryVariableStorage.Enqueue(false); // deny to create a new bank account
        ScanToInvoice(PurchaseHeader);

        // cancelled import
        Assert.ExpectedMessage(StrSubstNo(PurhDocVendBankAccountQst, IBAN), LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(ImportCancelledMsg, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, false, '123', '', 0, '', '', '', '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,MessageHandler,ConfirmHandler,CreateBankAccountMPH')]
    procedure Invoice_Scan_CreateBankAccount_Confirm()
    var
        PurchaseHeader: Record "Purchase Header";
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice, confirm create a new vendor bank account
        // [SCENARIO 362130] A new vendor bank account "Payment Form" = "Bank Payment Domestic"
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, '', false, '123');

        LibraryVariableStorage.Enqueue(QRCodeText);
        LibraryVariableStorage.Enqueue(true); // confirm to create a new bank account
        LibraryVariableStorage.Enqueue('BANK1'); // new bank account code
        ScanToInvoice(PurchaseHeader);

        // success import
        Assert.ExpectedMessage(StrSubstNo(PurhDocVendBankAccountQst, IBAN), LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(ImportSuccessMsg, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, true, PaymentReference, 'DOCNO123', 123.45, 'CHF', IBAN, 'Unstr Msg', BillInfo);
        VerifyBankAccount(PurchaseHeader."Buy-from Vendor No.", 'BANK1', IBAN);

        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(PurchaseHeader."Buy-from Vendor No.");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler')]
    procedure Invoice_Scan_PmtRefExists_Invoice_Deny()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PmtRefMsg: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of already existing payment reference (invoice), deny import
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, VendorNo, false, PaymentReference);

        // deny import
        PmtRefMsg := CreatePmtReferencePurchDocMsg(PurchaseHeader);
        InvoiceScanPmtRefExistsDeny(VendorNo, IBAN, PaymentReference, PmtRefMsg);

        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler,MessageHandler')]
    procedure Invoice_Scan_PmtRefExists_Invoice_Accept()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PmtRefMsg: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of already existing payment reference (invoice), accept import
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, VendorNo, false, PaymentReference);

        // accept import
        PmtRefMsg := CreatePmtReferencePurchDocMsg(PurchaseHeader);
        InvoiceScanPmtRefExistsAccept(VendorNo, IBAN, PaymentReference, PmtRefMsg);

        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler')]
    procedure Invoice_Scan_PmtRefExists_Order_Deny()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PmtRefMsg: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of already existing payment reference (order), deny import
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Order, VendorNo, false, PaymentReference);

        // deny import
        PmtRefMsg := CreatePmtReferencePurchDocMsg(PurchaseHeader);
        InvoiceScanPmtRefExistsDeny(VendorNo, IBAN, PaymentReference, PmtRefMsg);

        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler,MessageHandler')]
    procedure Invoice_Scan_PmtRefExists_Order_Accept()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PmtRefMsg: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of already existing payment reference (order), accept import
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Order, VendorNo, false, PaymentReference);

        // accept import
        PmtRefMsg := CreatePmtReferencePurchDocMsg(PurchaseHeader);
        InvoiceScanPmtRefExistsAccept(VendorNo, IBAN, PaymentReference, PmtRefMsg);

        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler')]
    procedure Invoice_Scan_PmtRefExists_VLE_Deny()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PmtRefMsg: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of already existing payment reference (vendor ledger entry), deny import
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        MockVendorLedgerEntry(VendorLedgerEntry, VendorNo, PaymentReference);

        // deny import
        PmtRefMsg := CreatePmtReferenceVLEMsg(VendorLedgerEntry);
        InvoiceScanPmtRefExistsDeny(VendorNo, IBAN, PaymentReference, PmtRefMsg);

        LibraryVariableStorage.AssertEmpty();
        VendorLedgerEntry.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler,MessageHandler')]
    procedure Invoice_Scan_PmtRefExists_VLE_Accept()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PmtRefMsg: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of already existing payment reference (vendor ledger entry), accept import
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        MockVendorLedgerEntry(VendorLedgerEntry, VendorNo, PaymentReference);

        // accept import
        PmtRefMsg := CreatePmtReferenceVLEMsg(VendorLedgerEntry);
        InvoiceScanPmtRefExistsAccept(VendorNo, IBAN, PaymentReference, PmtRefMsg);

        LibraryVariableStorage.AssertEmpty();
        VendorLedgerEntry.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler')]
    procedure Invoice_Scan_PmtRefExists_Journal_Deny()
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PmtRefMsg: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of already existing payment reference (journal), deny import
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreateJournalLine(GenJournalLine, VendorNo, false, PaymentReference);

        // deny import
        PmtRefMsg := CreatePmtReferenceJnlLineMsg(GenJournalLine);
        InvoiceScanPmtRefExistsDeny(VendorNo, IBAN, PaymentReference, PmtRefMsg);

        LibraryVariableStorage.AssertEmpty();
        GenJournalLine.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler,MessageHandler')]
    procedure Invoice_Scan_PmtRefExists_Journal_Accept()
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PmtRefMsg: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of already existing payment reference (journal), accept import
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreateJournalLine(GenJournalLine, VendorNo, false, PaymentReference);

        // accept import
        PmtRefMsg := CreatePmtReferenceJnlLineMsg(GenJournalLine);
        InvoiceScanPmtRefExistsAccept(VendorNo, IBAN, PaymentReference, PmtRefMsg);

        LibraryVariableStorage.AssertEmpty();
        GenJournalLine.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler')]
    procedure Invoice_Scan_PmtRefExists_IncDoc_Deny()
    var
        IncomingDocument: Record "Incoming Document";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PmtRefMsg: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of already existing payment reference (incoming document), deny import
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreateIncomingDocument(IncomingDocument, VendorNo, false, PaymentReference);

        // deny import
        PmtRefMsg := CreatePmtReferenceIncDocMsg(IncomingDocument);
        InvoiceScanPmtRefExistsDeny(VendorNo, IBAN, PaymentReference, PmtRefMsg);

        LibraryVariableStorage.AssertEmpty();
        IncomingDocument.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler,MessageHandler')]
    procedure Invoice_Scan_PmtRefExists_IncDoc_Accept()
    var
        IncomingDocument: Record "Incoming Document";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PmtRefMsg: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Invoice in case of already existing payment reference (incoming document), accept import
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreateIncomingDocument(IncomingDocument, VendorNo, false, PaymentReference);

        // accept import
        PmtRefMsg := CreatePmtReferenceIncDocMsg(IncomingDocument);
        InvoiceScanPmtRefExistsAccept(VendorNo, IBAN, PaymentReference, PmtRefMsg);

        LibraryVariableStorage.AssertEmpty();
        IncomingDocument.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure Order_Scan_Success_Void()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Order in case of existing vendor bank account
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Order, VendorNo, false, '');

        LibraryVariableStorage.Enqueue(QRCodeText);
        ScanToOrder(PurchaseHeader);

        // success scan
        Assert.ExpectedMessage(ImportSuccessMsg, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, true, PaymentReference, 'DOCNO123', 123.45, 'CHF', IBAN, 'Unstr Msg', BillInfo);

        // success void
        VoidOrder(PurchaseHeader);
        VerifyPurchDoc(PurchaseHeader, false, '', '', 0, '', '', '', '');

        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,MessageHandler,ConfirmHandler,CreateBankAccountMPH')]
    procedure Order_Scan_CreateBankAccount_Confirm()
    var
        PurchaseHeader: Record "Purchase Header";
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Order, confirm create a new vendor bank account
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Order, '', false, '');

        LibraryVariableStorage.Enqueue(QRCodeText);
        LibraryVariableStorage.Enqueue(true); // confirm to create a new bank account
        LibraryVariableStorage.Enqueue('BANK1'); // new bank account code
        ScanToOrder(PurchaseHeader);

        // success import
        Assert.ExpectedMessage(StrSubstNo(PurhDocVendBankAccountQst, IBAN), LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(ImportSuccessMsg, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, true, PaymentReference, 'DOCNO123', 123.45, 'CHF', IBAN, 'Unstr Msg', BillInfo);
        VerifyBankAccount(PurchaseHeader."Buy-from Vendor No.", 'BANK1', IBAN);

        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(PurchaseHeader."Buy-from Vendor No.");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler')]
    procedure Journal_Scan_Success_Stop()
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Journal in case of existing vendor bank account, single scan
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);

        LibraryVariableStorage.Enqueue(QRCodeText);
        LibraryVariableStorage.Enqueue(false); // do not scan next
        Assert.IsTrue(ScanToJournal(GenJournalLine), '');

        // success scan
        Assert.ExpectedMessage(ImportSuccessMsg + '\\' + ScanAnotherQst, LibraryVariableStorage.DequeueText());
        VerifyJournalLine(
            GenJournalLine, true, VendorNo, PaymentReference, 'DOCNO123', -123.45, '', VendorBankAccountNo, 'Unstr Msg', BillInfo);

        LibraryVariableStorage.AssertEmpty();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler')]
    procedure Journal_Scan_Success_Next()
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        QRCodeText: array[2] of Text;
        PaymentReference: array[2] of Code[50];
        IBAN: Code[50];
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Journal in case of existing vendor bank account, two scans
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference[1] := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        PaymentReference[2] := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        QRCodeText[1] := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 100, 'CHF', PaymentReference[1], 'Unstr Msg 1', 'S1/10/DOCNO1/');
        QRCodeText[2] := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 200, 'CHF', PaymentReference[2], 'Unstr Msg 2', 'S1/10/DOCNO2/');

        LibraryVariableStorage.Enqueue(QRCodeText[1]);
        LibraryVariableStorage.Enqueue(true); // scan next
        LibraryVariableStorage.Enqueue(QRCodeText[2]);
        LibraryVariableStorage.Enqueue(false); // do not scan next
        Assert.IsTrue(ScanToJournal(GenJournalLine), '');

        // success scan
        Assert.ExpectedMessage(ImportSuccessMsg + '\\' + ScanAnotherQst, LibraryVariableStorage.DequeueText());
        VerifyJournalLine(
            GenJournalLine, true, VendorNo, PaymentReference[1], 'DOCNO1', -100, '', VendorBankAccountNo, 'Unstr Msg 1', 'S1/10/DOCNO1/');

        GenJournalLine.Next();
        Assert.ExpectedMessage(ImportSuccessMsg + '\\' + ScanAnotherQst, LibraryVariableStorage.DequeueText());
        VerifyJournalLine(
            GenJournalLine, true, VendorNo, PaymentReference[2], 'DOCNO2', -200, '', VendorBankAccountNo, 'Unstr Msg 2', 'S1/10/DOCNO2/');

        LibraryVariableStorage.AssertEmpty();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure Journal_Scan_VendotNotFound()
    var
        GenJournalLine: Record "Gen. Journal Line";
        QRCodeText: Text;
        IBAN: Code[50];
    begin
        // [FEATURE] [UI]
        // [SCENARIO 351182] Scan QR-Bill into Purchase Journal in case of not found vendor
        Initialize();
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', '', '', '');

        LibraryVariableStorage.Enqueue(QRCodeText);
        Assert.IsFalse(ScanToJournal(GenJournalLine), '');

        // vendor is not found
        Assert.ExpectedMessage(StrSubstNo(JournalProcessVendorNotFoundTxt, IBAN), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure Invoice_Post_Positive_CHF()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO 351182] Post purchase invoice in case of QR-Bill CHF currency
        Initialize();
        SwissQRBillTestLibrary.CreatePurchaseInvoice(PurchaseHeader, '', 100);
        UpdatePurchDoc(PurchaseHeader, true, 'CHF', 110);

        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure Invoice_Post_Positive_EUR()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO 351182] Post purchase invoice in case of QR-Bill EUR currency
        Initialize();
        SwissQRBillTestLibrary.CreatePurchaseInvoice(PurchaseHeader, 'EUR', 100);
        UpdatePurchDoc(PurchaseHeader, true, 'EUR', 110);

        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure Invoice_Post_WrongAmount()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO 351182] Post purchase invoice in case of QR-Bill CHF currency
        Initialize();
        SwissQRBillTestLibrary.CreatePurchaseInvoice(PurchaseHeader, '', 100);
        UpdatePurchDoc(PurchaseHeader, true, 'CHF', 110.01);

        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(AmountErr, PurchaseHeader."Swiss QR-Bill Amount", 110));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure Invoice_Post_WrongCurrency_CHF()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO 351182] Try post purchase invoice in case of QR-Bill EUR currency and document CHF currency
        Initialize();
        SwissQRBillTestLibrary.CreatePurchaseInvoice(PurchaseHeader, '', 100);
        UpdatePurchDoc(PurchaseHeader, true, 'EUR', 110);

        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(CurrencyErr, PurchaseHeader."Swiss QR-Bill Currency", PurchaseHeader."Currency Code"));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure Invoice_Post_WrongCurrency_EUR()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO 351182] Try post purchase invoice in case of QR-Bill CHF currency and document EUR currency
        Initialize();
        SwissQRBillTestLibrary.CreatePurchaseInvoice(PurchaseHeader, 'EUR', 100);
        UpdatePurchDoc(PurchaseHeader, true, 'CHF', 110);

        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(CurrencyErr, '', PurchaseHeader."Currency Code"));
    end;

    [Test]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure OrderScanQRBillZeroAmount()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseOrder: TestPage "Purchase Order";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PostedDocNo: Code[20];
        QRCodeText: Text;
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 457372] Scan QR-Bill into Purchase Order in case of Amount in QR-Bill is zero.
        Initialize();

        // [GIVEN] Purchase Order with Purchase Line with Amount Including VAT = 1000.
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Order, VendorNo, false, '');
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(), 543.21, 1);

        // [GIVEN] QR-Bill text where Amount = 0.
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 0, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);

        // [WHEN] Run scan QR-Bill on the given text.
        LibraryVariableStorage.Enqueue(QRCodeText);
        ScanToOrder(PurchaseHeader);

        // [THEN] QR-Bill text was scanned. Swiss QR-Bill Amount is 0.
        Assert.ExpectedMessage(ImportSuccessMsg, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, true, PaymentReference, 'DOCNO123', 0, 'CHF', IBAN, 'Unstr Msg', BillInfo);

        // [THEN] Swiss QR-Bill Amount field is editable on page Purchase Order.
        PurchaseOrder.OpenEdit();
        PurchaseOrder.Filter.SetFilter("No.", PurchaseHeader."No.");
        Assert.IsTrue(PurchaseOrder."Swiss QR-Bill Amount".Editable(), '');

        // [WHEN] Set Swiss QR-Bill Amount = 1000 and post Purchase Order.
        PurchaseOrder."Swiss QR-Bill Amount".SetValue(PurchaseLine."Amount Including VAT");
        PurchaseOrder.Close();
        PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
        PostedDocNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Purchase Order was posted.
        PurchInvHeader.Get(PostedDocNo);

        LibraryVariableStorage.AssertEmpty();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure InvoiceScanQRBillZeroAmount()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseInvoice: TestPage "Purchase Invoice";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        PostedDocNo: Code[20];
        QRCodeText: Text;
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 457372] Scan QR-Bill into Purchase Invoice in case of Amount in QR-Bill is zero.
        Initialize();

        // [GIVEN] Purchase Invoice with Purchase Line with Amount Including VAT = 1000.
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, VendorNo, false, '');
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(), 543.21, 1);

        // [GIVEN] QR-Bill text where Amount = 0.
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 0, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);

        // [WHEN] Run scan QR-Bill on the given text.
        LibraryVariableStorage.Enqueue(QRCodeText);
        ScanToInvoice(PurchaseHeader);

        // [THEN] QR-Bill text was scanned. Swiss QR-Bill Amount is 0.
        Assert.ExpectedMessage(ImportSuccessMsg, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, true, PaymentReference, 'DOCNO123', 0, 'CHF', IBAN, 'Unstr Msg', BillInfo);

        // [THEN] Swiss QR-Bill Amount field is editable on page Purchase Invoice.
        PurchaseInvoice.OpenEdit();
        PurchaseInvoice.Filter.SetFilter("No.", PurchaseHeader."No.");
        Assert.IsTrue(PurchaseInvoice."Swiss QR-Bill Amount".Editable(), '');

        // [WHEN] Set Swiss QR-Bill Amount = 1000 and post Purchase Invoice.
        PurchaseInvoice."Swiss QR-Bill Amount".SetValue(PurchaseLine."Amount Including VAT");
        PurchaseInvoice.Close();
        PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
        PostedDocNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [THEN] Purchase Invoice was posted.
        PurchInvHeader.Get(PostedDocNo);

        LibraryVariableStorage.AssertEmpty();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure OrderScanQRBillZeroAmountUpdateAmount()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseOrder: TestPage "Purchase Order";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        QRCodeText: Text;
        BillInfo: Text;
        QRBillAmount: Decimal;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 457372] Update Swiss QR-Bill Amount after scan QR-Bill with zero Amount into Purchase Order.
        Initialize();

        // [GIVEN] Purchase Order after QR-Bill with zero Amount was scanned.
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Order, VendorNo, false, '');
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 0, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);
        LibraryVariableStorage.Enqueue(QRCodeText);
        ScanToOrder(PurchaseHeader);

        // [GIVEN] Swiss QR-Bill Amount was set manually on Purchase Order page.
        PurchaseOrder.OpenEdit();
        PurchaseOrder.Filter.SetFilter("No.", PurchaseHeader."No.");
        PurchaseOrder."Swiss QR-Bill Amount".SetValue(543.21);
        PurchaseOrder.Close();

        // [WHEN] Update Swiss QR-Bill Amount.
        QRBillAmount := 987.65;
        PurchaseOrder.OpenEdit();
        PurchaseOrder.Filter.SetFilter("No.", PurchaseHeader."No.");
        PurchaseOrder."Swiss QR-Bill Amount".SetValue(QRBillAmount);
        PurchaseOrder.Close();

        // [THEN] Swiss QR-Bill Amount was updated.
        PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
        Assert.AreEqual(QRBillAmount, PurchaseHeader."Swiss QR-Bill Amount", '');

        LibraryVariableStorage.DequeueText();   // message text
        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure OrderScanQRBillNonZeroAmount()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseOrder: TestPage "Purchase Order";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        QRCodeText: Text;
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 457372] Swiss QR-Bill Amount field after scan QR-Bill with non-zero Amount into Purchase Order.
        Initialize();

        // [GIVEN] Purchase Order after QR-Bill with non-zero Amount was scanned.
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Order, VendorNo, false, '');

        // [GIVEN] QR-Bill text where Amount = 123.45.
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);

        // [WHEN] Run scan QR-Bill on the given text.
        LibraryVariableStorage.Enqueue(QRCodeText);
        ScanToOrder(PurchaseHeader);

        // [THEN] Swiss QR-Bill Amount field is not editable on Purchase Order page.
        PurchaseOrder.OpenEdit();
        PurchaseOrder.Filter.SetFilter("No.", PurchaseHeader."No.");
        Assert.IsFalse(PurchaseOrder."Swiss QR-Bill Amount".Editable(), '');
        PurchaseOrder.Close();

        LibraryVariableStorage.DequeueText();   // message text
        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure InvoiceScanQRBillNonZeroAmount()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseInvoice: TestPage "Purchase Invoice";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        PaymentReference: Code[50];
        IBAN: Code[50];
        QRCodeText: Text;
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 457372] Swiss QR-Bill Amount field after scan QR-Bill with non-zero Amount into Purchase Invoice.
        Initialize();

        // [GIVEN] Purchase Invoice after QR-Bill with non-zero Amount was scanned.
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, VendorNo, false, '');

        // [GIVEN] QR-Bill text where Amount = 123.45.
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);

        // [WHEN] Run scan QR-Bill on the given text.
        LibraryVariableStorage.Enqueue(QRCodeText);
        ScanToInvoice(PurchaseHeader);

        // [THEN] Swiss QR-Bill Amount field is not editable on Purchase Invoice page.
        PurchaseInvoice.OpenEdit();
        PurchaseInvoice.Filter.SetFilter("No.", PurchaseHeader."No.");
        Assert.IsFalse(PurchaseInvoice."Swiss QR-Bill Amount".Editable(), '');
        PurchaseInvoice.Close();

        LibraryVariableStorage.DequeueText();   // message text
        LibraryVariableStorage.AssertEmpty();
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);
    end;

    [Test]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure DocumentDateInPurchInvoiceWhenBillInfoWithDocDate()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 467388] Scan QR-Bill from Purchase Invoice card when Document Date is specified in Billing Information.
        Initialize();

        // [GIVEN] QR-Bill text with Billing Information with Document Date = 15.10.2023.
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123/11/231015';
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);

        // [GIVEN] Purchase Invoice.
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, VendorNo, false, '');

        // [WHEN] Run scan QR-Bill from Purhchase Invoice card on the given QR-Bill text.
        LibraryVariableStorage.Enqueue(QRCodeText);
        ScanToInvoice(PurchaseHeader);

        // [THEN] Posting Date was set to WorkDate, Document Date was set to 15.10.2023 in Purchase Invoice.
        Assert.ExpectedMessage(ImportSuccessMsg, LibraryVariableStorage.DequeueText());
        PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
        PurchaseHeader.TestField("Posting Date", WorkDate());
        PurchaseHeader.TestField("Document Date", 20231015D);

        // tear down
        VoidInvoice(PurchaseHeader);
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('QRBillScanMPH,MessageHandler')]
    procedure DocumentDateInPurchInvoiceWhenBillInfoWithoutDocDate()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 467388] Scan QR-Bill from Purchase Invoice card when Document Date is not specified in Billing Information.
        Initialize();

        // [GIVEN] QR-Bill text with Billing Information without Document Date.
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);

        // [GIVEN] Purchase Invoice.
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, VendorNo, false, '');

        // [WHEN] Run scan QR-Bill from Purhchase Invoice card on the given QR-Bill text.
        LibraryVariableStorage.Enqueue(QRCodeText);
        ScanToInvoice(PurchaseHeader);

        // [THEN] Document Date was set to be equal to Posting Date (WorkDate) in Purchase Invoice.
        Assert.ExpectedMessage(ImportSuccessMsg, LibraryVariableStorage.DequeueText());
        PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
        PurchaseHeader.TestField("Posting Date", WorkDate());
        PurchaseHeader.TestField("Document Date", WorkDate());

        // tear down
        VoidInvoice(PurchaseHeader);
        PurchaseHeader.Delete();
        SwissQRBillTestLibrary.ClearVendor(VendorNo);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler')]
    procedure DocumentDateInGenJnlLineWhenBillInfoWithDocDate()
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
        GenJournalLineCreated: Boolean;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 467388] Scan QR-Bill from Purchase Journal page when Document Date is specified in Billing Information.
        Initialize();

        // [GIVEN] QR-Bill text with Billing Information with Document Date = 15.10.2023.
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123/11/231015';
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);

        // [WHEN] Run scan QR-Bill from Purchase Journal page on the given QR-Bill text.
        LibraryVariableStorage.Enqueue(QRCodeText);
        LibraryVariableStorage.Enqueue(false);  // do not scan next
        GenJournalLineCreated := ScanToJournal(GenJournalLine);

        // [THEN] Posting Date was set to WorkDate, Document Date was set to 15.10.2023 in Gen. Journal Line.
        Assert.IsTrue(GenJournalLineCreated, 'There is no Gen. Journal Line');
        Assert.ExpectedMessage(ImportSuccessMsg + '\\' + ScanAnotherQst, LibraryVariableStorage.DequeueText());
        GenJournalLine.TestField("Document Date", 20231015D);

        // tear down
        SwissQRBillTestLibrary.ClearVendor(VendorNo);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('QRBillScanMPH,ConfirmHandler')]
    procedure DocumentDateInGenJnlLineWhenBillInfoWithoutDocDate()
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
        VendorBankAccountNo: Code[20];
        QRCodeText: Text;
        PaymentReference: Code[50];
        IBAN: Code[50];
        BillInfo: Text;
        GenJournalLineCreated: Boolean;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 467388] Scan QR-Bill from Purchase Journal page when Document Date is not specified in Billing Information.
        Initialize();

        // [GIVEN] QR-Bill text with Billing Information without Document Date.
        IBAN := SwissQRBillTestLibrary.GetRandomIBAN();
        PaymentReference := SwissQRBillTestLibrary.GetRandomQRPaymentReference();
        BillInfo := 'S1/10/DOCNO123';
        SwissQRBillTestLibrary.CreateVendorWithBankAccount(VendorNo, VendorBankAccountNo, IBAN);
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);

        // [WHEN] Run scan QR-Bill from Purchase Journal page on the given QR-Bill text.
        LibraryVariableStorage.Enqueue(QRCodeText);
        LibraryVariableStorage.Enqueue(false);  // do not scan next
        GenJournalLineCreated := ScanToJournal(GenJournalLine);

        // [THEN] Posting Date was set to WorkDate, Document Date was not set in Gen. Journal Line.
        Assert.IsTrue(GenJournalLineCreated, 'There is no Gen. Journal Line');
        Assert.ExpectedMessage(ImportSuccessMsg + '\\' + ScanAnotherQst, LibraryVariableStorage.DequeueText());
        GenJournalLine.TestField("Posting Date", WorkDate());
        GenJournalLine.TestField("Document Date", 0D);

        // tear down
        SwissQRBillTestLibrary.ClearVendor(VendorNo);

        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
        SwissQRBillTestLibrary.ClearJournalRecords();

        if IsInitialized then
            exit;
        IsInitialized := true;

        SwissQRBillTestLibrary.UpdateDefaultVATPostingSetup(10);
    end;

    local procedure InvoiceScanPmtRefExistsDeny(VendorNo: Code[20]; IBAN: Code[50]; PaymentReference: Code[50]; PmtRefMsg: Text)
    var
        PurchaseHeader: Record "Purchase Header";
        QRCodeText: Text;
    begin
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, '', '');
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, VendorNo, false, '123');

        LibraryVariableStorage.Enqueue(QRCodeText);
        LibraryVariableStorage.Enqueue(false); // deny import
        ScanToInvoice(PurchaseHeader);

        // cancelled import
        Assert.ExpectedMessage(PmtRefMsg, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, false, '123', '', 0, '', '', '', '');

        PurchaseHeader.Delete();
    end;

    local procedure InvoiceScanPmtRefExistsAccept(VendorNo: Code[20]; IBAN: Code[50]; PaymentReference: Code[50]; PmtRefMsg: Text)
    var
        PurchaseHeader: Record "Purchase Header";
        QRCodeText: Text;
        BillInfo: Text;
    begin
        BillInfo := 'S1/10/DOCNO123';
        QRCodeText := SwissQRBillTestLibrary.CreateQRCodeText(IBAN, 123.45, 'CHF', PaymentReference, 'Unstr Msg', BillInfo);
        CreatePurchaseHeader(PurchaseHeader, DocumentType::Invoice, VendorNo, false, '123');

        LibraryVariableStorage.Enqueue(QRCodeText);
        LibraryVariableStorage.Enqueue(true); // accept import
        ScanToInvoice(PurchaseHeader);

        // success import
        Assert.ExpectedMessage(PmtRefMsg, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(ImportSuccessMsg, LibraryVariableStorage.DequeueText());
        VerifyPurchDoc(PurchaseHeader, true, PaymentReference, 'DOCNO123', 123.45, 'CHF', IBAN, 'Unstr Msg', BillInfo);

        PurchaseHeader.Delete();
    end;

    local procedure CreatePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; QRBill: Boolean; PmtRef: Code[50])
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader."Swiss QR-Bill" := QRBill;
        PurchaseHeader."Vendor Invoice No." := '';
        PurchaseHeader."Payment Reference" := PmtRef;
        PurchaseHeader.Modify();
    end;

    local procedure CreateJournalLine(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20]; QRBill: Boolean; PmtRef: Code[50])
    var
        SwissQRBillSetup: Record "Swiss QR-Bill Setup";
    begin
        if VendorNo = '' then
            VendorNo := LibraryPurchase.CreateVendorNo();

        SwissQRBillSetup.Get();
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine,
            SwissQRBillSetup."Journal Template", SwissQRBillSetup."Journal Batch",
            GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Vendor,
            VendorNo, 123);

        GenJournalLine."Swiss QR-Bill" := QRBill;
        GenJournalLine."Payment Reference" := PmtRef;
        GenJournalLine.Modify();
    end;

    local procedure CreateIncomingDocument(var IncomingDocument: Record "Incoming Document"; VendorNo: Code[20]; QRBill: Boolean; PmtRef: Code[50])
    begin
        with IncomingDocument do begin
            Init();
            "Entry No." := LibraryUtility.GetNewRecNo(IncomingDocument, FieldNo("Entry No."));
            "Swiss QR-Bill" := QRBill;
            "Vendor No." := VendorNo;
            "Swiss QR-Bill Reference No." := PmtRef;
            Insert();
        end;
    end;

    local procedure CreatePmtReferencePurchDocMsg(PurchaseHeader: Record "Purchase Header") Result: Text
    begin
        with PurchaseHeader do begin
            if "Document Type" = "Document Type"::Invoice then
                Result := PurchInvoicePmtRefAlreadyExistsTxt
            else
                Result := PurchOrderPmtRefAlreadyExistsTxt;
            AddMessageText(Result, StrSubstNo(VendorTxt, "Pay-to Vendor No.", "Pay-to Name"), '\');
            AddMessageText(Result, StrSubstNo(PaymentRefTxt, "Payment Reference"), '\');
            AddMessageText(Result, StrSubstNo(DocumentNoTxt, "No."), '\');
        end;

        exit(ImportWarningTxt + '\\' + Result + '\\' + ContinueQst);
    end;

    local procedure CreatePmtReferenceJnlLineMsg(GenJournalLine: Record "Gen. Journal Line") Result: Text
    var
        Vendor: Record Vendor;
    begin
        with GenJournalLine do
            if Vendor.Get("Account No.") then begin
                Result := JnlLinePmtRefAlreadyExistsTxt;
                AddMessageText(Result, StrSubstNo(VendorTxt, "Account No.", Vendor.Name), '\');
                AddMessageText(Result, StrSubstNo(PaymentRefTxt, "Payment Reference"), '\');
                AddMessageText(Result, StrSubstNo(JnlTemplateTxt, "Journal Template Name"), '\');
                AddMessageText(Result, StrSubstNo(JnlBatchTxt, "Journal Batch Name"), '\');
                AddMessageText(Result, StrSubstNo(JnlLineTxt, "Line No."), '\');
            end;

        exit(ImportWarningTxt + '\\' + Result + '\\' + ContinueQst);
    end;

    local procedure CreatePmtReferenceIncDocMsg(IncomingDocument: Record "Incoming Document") Result: Text
    begin
        with IncomingDocument do begin
            Result := IncDocPmtRefAlreadyExistsTxt;
            AddMessageText(Result, StrSubstNo(VendorTxt, "Vendor No.", "Vendor Name"), '\');
            AddMessageText(Result, StrSubstNo(PaymentRefTxt, "Swiss QR-Bill Reference No."), '\');
            AddMessageText(Result, StrSubstNo(IncDocEntryTxt, "Entry No."), '\');
        end;

        exit(ImportWarningTxt + '\\' + Result + '\\' + ContinueQst);
    end;

    local procedure CreatePmtReferenceVLEMsg(VendorLedgerEntry: Record "Vendor Ledger Entry") Result: Text
    begin
        with VendorLedgerEntry do begin
            Result := VendorLedgerEntryPmtRefAlreadyExistsTxt;
            AddMessageText(Result, StrSubstNo(VendorTxt, "Vendor No.", "Vendor Name"), '\');
            AddMessageText(Result, StrSubstNo(PaymentRefTxt, "Payment Reference"), '\');
            AddMessageText(Result, StrSubstNo(VendLedgerEntryTxt, "Entry No."), '\');
        end;

        exit(ImportWarningTxt + '\\' + Result + '\\' + ContinueQst);
    end;

    local procedure AddMessageText(var TargetMessage: Text; AddText: Text; Sep: Text)
    begin
        TargetMessage += Sep + AddText;
    end;

    local procedure MockVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; VendorNo: Code[20]; PaymentReference: Code[50])
    begin
        with VendorLedgerEntry do begin
            Init();
            "Entry No." := LibraryUtility.GetNewRecNo(VendorLedgerEntry, FieldNo("Entry No."));
            "Document Type" := "Document Type"::Invoice;
            "Vendor No." := VendorNo;
            "Payment Reference" := PaymentReference;
            Insert();
        end;
    end;

    local procedure UpdatePurchDoc(var PurchaseHeader: Record "Purchase Header"; QRBill: Boolean; Currency: Code[10]; Amount: Decimal)
    begin
        PurchaseHeader."Swiss QR-Bill" := QRBill;
        PurchaseHeader."Swiss QR-Bill Currency" := Currency;
        PurchaseHeader."Swiss QR-Bill Amount" := Amount;
        PurchaseHeader.Modify();
    end;

    local procedure ScanToInvoice(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        PurchaseHeader.SetRecFilter();
        PurchaseInvoice.Trap();
        Page.Run(Page::"Purchase Invoice", PurchaseHeader);
        PurchaseInvoice."Swiss QR-Bill Scan".Invoke();
        PurchaseInvoice.Close();
    end;

    local procedure ScanToOrder(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseHeader.SetRecFilter();
        PurchaseOrder.Trap();
        Page.Run(Page::"Purchase Order", PurchaseHeader);
        PurchaseOrder."Swiss QR-Bill Scan".Invoke();
        PurchaseOrder.Close();
    end;

    local procedure ScanToJournal(var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        SwissQRBillSetup: Record "Swiss QR-Bill Setup";
        PurchaseJournal: TestPage "Purchase Journal";
    begin
        PurchaseJournal.Trap();
        Commit();
        Page.Run(Page::"Purchase Journal");
        PurchaseJournal."Swiss QR-Bill Scan".Invoke();
        PurchaseJournal.Close();

        SwissQRBillSetup.Get();
        GenJournalLine.SetRange("Journal Template Name", SwissQRBillSetup."Journal Template");
        GenJournalLine.SetRange("Journal Batch Name", SwissQRBillSetup."Journal Batch");
        exit(GenJournalLine.FindFirst());
    end;

    local procedure VoidInvoice(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        PurchaseHeader.SetRecFilter();
        PurchaseInvoice.Trap();
        Page.Run(Page::"Purchase Invoice", PurchaseHeader);
        PurchaseInvoice."Swiss QR-Bill Void".Invoke();
        PurchaseInvoice.Close();
    end;

    local procedure VoidOrder(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseHeader.SetRecFilter();
        PurchaseOrder.Trap();
        Page.Run(Page::"Purchase Order", PurchaseHeader);
        PurchaseOrder."Swiss QR-Bill Void".Invoke();
        PurchaseOrder.Close();
    end;

    local procedure VerifyPurchDoc(PurchaseHeader: Record "Purchase Header"; QRBill: Boolean; PaymentReference: Code[50]; VendorInvoiceNo: Code[20]; Amount: Decimal; Currency: Code[10]; IBAN: Code[50]; UnstrMsg: Text; BillInfo: Text)
    begin
        PurchaseHeader.Find();
        PurchaseHeader.TestField("Swiss QR-Bill", QRBill);
        PurchaseHeader.TestField("Swiss QR-Bill Amount", Amount);
        PurchaseHeader.TestField("Swiss QR-Bill Currency", Currency);
        PurchaseHeader.TestField("Swiss QR-Bill IBAN", IBAN);
        PurchaseHeader.TestField("Swiss QR-Bill Unstr. Message", UnstrMsg);
        PurchaseHeader.TestField("Swiss QR-Bill Bill Info", BillInfo);
        PurchaseHeader.TestField("Payment Reference", PaymentReference);
        PurchaseHeader.TestField("Vendor Invoice No.", VendorInvoiceNo);
    end;

    local procedure VerifyJournalLine(GenJournalLine: Record "Gen. Journal Line"; QRBill: Boolean; VendorNo: Code[20]; PaymentReference: Code[50]; VendorInvoiceNo: Code[20]; Amount: Decimal; Currency: Code[10]; BankAccount: Code[50]; UnstrMsg: Text; BillInfo: Text)
    begin
        GenJournalLine.Find();
        GenJournalLine.TestField("Document Type", GenJournalLine."Document Type"::Invoice);
        GenJournalLine.TestField("Account Type", GenJournalLine."Account Type"::Vendor);
        GenJournalLine.TestField("Account No.", VendorNo);
        GenJournalLine.TestField("Swiss QR-Bill", QRBill);
        GenJournalLine.TestField(Amount, Amount);
        GenJournalLine.TestField("Currency Code", Currency);
        GenJournalLine.TestField("Recipient Bank Account", BankAccount);
        GenJournalLine.TestField("Message to Recipient", UnstrMsg);
        GenJournalLine.TestField("Transaction Information", BillInfo);
        GenJournalLine.TestField("Payment Reference", PaymentReference);
        GenJournalLine.TestField("External Document No.", VendorInvoiceNo);
    end;

    local procedure VerifyBankAccount(VendorNo: Code[20]; BankAccCode: Code[20]; IBAN: Code[50])
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        VendorBankAccount.Get(VendorNo, BankAccCode);
        VendorBankAccount.TestField(IBAN, IBAN);
        VendorBankAccount.TestField("Payment Form", VendorBankAccount."Payment Form"::"Bank Payment Domestic");
    end;

    [ModalPageHandler]
    procedure QRBillScanMPH(var SwissQRBillScan: TestPage "Swiss QR-Bill Scan")
    begin
        SwissQRBillScan.QRCodeTextField.SetValue(LibraryVariableStorage.DequeueText());
        SwissQRBillScan.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateBankAccountMPH(var SwissQRBillCreateVendBank: TestPage "Swiss QR-Bill Create Vend Bank")
    begin
        SwissQRBillCreateVendBank.BankAccountCodeField.SetValue(LibraryVariableStorage.DequeueText());
        SwissQRBillCreateVendBank.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := LibraryVariableStorage.DequeueBoolean();
        LibraryVariableStorage.Enqueue(Question);
    end;
}
