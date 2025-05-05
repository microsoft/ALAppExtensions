codeunit 139515 "Digital Vouchers Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        Assert: Codeunit Assert;
        LibraryWorkflow: Codeunit "Library - Workflow";
        ActiveDirectoryMockEvents: Codeunit "Active Directory Mock Events";
        LibrarySmallBusiness: Codeunit "Library - Small Business";
        LibraryService: Codeunit "Library - Service";
        IsInitialized: Boolean;
        NotPossibleToPostWithoutVoucherErr: Label 'Not possible to post without attaching the digital voucher.';
        DialogErrorCodeTok: Label 'Dialog', Locked = true;
        CannotRemoveReferenceRecordFromIncDocErr: Label 'Cannot remove the reference record from the incoming document because it is used for the enforced digital voucher functionality';
        DetachQst: Label 'Do you want to remove the reference from this incoming document to posted document';
        RemovePostedRecordManuallyMsg: Label 'The reference to the posted record has been removed.\\Remember to correct the posted record if needed.';
        DoYouWantToPostQst: Label 'Do you want to post the journal lines?';
        PaymentLineAppliedMsg: Label '%1 payment lines out of 1 are applied.\\', Comment = '%1 - number';
        DoYouWantTPostPmtQst: Label 'Do you want to post the payments?';
        LinesPostedMsg: Label 'The journal lines were successfully posted.';

    trigger OnRun()
    begin
        // [FEATURE] [Digital Voucher]
    end;

    [Test]
    procedure PurchInvNoVoucherFeatureDisabledAttachmentCheck()
    var
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        DocNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 475787] Stan can post a purchase invoice without a digital voucher when there is attachment check, but the feature not enabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is disabled
        DisableDigitalVoucherFeature();
        // [GIVEN] Digital voucher entry setup for purchase document is "Attachment"
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::Attachment);
        // [WHEN] Post purchase document
        DocNo := ReceiveAndInvoicePurchaseInvoice();
        // [THEN] The document is posted without the digital voucher
        AssertVendorLedgerEntryExists(DocNo);
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchInvNoVoucherFeatureEnabledNoCheck()
    var
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        DocNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 475787] Stan can post a purchase invoice without a digital voucher when there is no check and the feature is enabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is disabled
        EnableDigitalVoucherFeature();
        // [GIVEN] Digital voucher entry setup for purchase document is "No Check"
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::"No Check");
        // [WHEN] Post purchase document
        DocNo := ReceiveAndInvoicePurchaseInvoice();
        // [THEN] The document is posted without the digital voucher
        AssertVendorLedgerEntryExists(DocNo);
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchInvNoVoucherFeatureEnabledAttachment()
    var
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 475787] Stan cannot post a purchase invoice without a digital voucher when there is attachment check and the feature is enabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher functionality is enabled
        EnableDigitalVoucherFeature();
        // [GIVEN] Digital Voucher Entry Setup for Purchase Document is "Attachment"
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::Attachment);
        // [WHEN] Post purchase document
        asserterror ReceiveAndInvoicePurchaseInvoice();
        // [THEN] Error "Not possible to post without the voucher" is shown
        Assert.ExpectedErrorCode(DialogErrorCodeTok);
        Assert.ExpectedError(NotPossibleToPostWithoutVoucherErr);
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchInvVoucherFeatureEnabledAttachment()
    var
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        DocNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 475787] Stan can post a purchase invoice with the manually attached digital voucher when there is attachment check and the feature is enabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        // [GIVEN] Digital voucher entry setup for purchase document is "Attachment"
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Purchase invoice and Incoming document with attachment is created for the purchase document        
        // [WHEN] Post the purchase document
        DocNo := ReceiveAndInvoicePurchaseInvoiceWithIncDoc();
        // [THEN] The document is posted with the digital voucher
        AssertVendorLedgerEntryExists(DocNo);
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchInvVoucherFeatureEnabledAttachmentAutogenerated()
    var
        PurchHeader: Record "Purchase Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        DocNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 475787] Stan can post a purchase invoice with a digital voucher generated automatically when there is attachment check and the feature is enabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionPurchaseInvoice();
        // [GIVEN] Digital voucher entry setup for purchase document is "Attachment", "Generate Automatically" is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::Attachment);
        // [WHEN] Post purchase document
        DocNo := ReceiveAndInvoicePurchaseInvoice(PurchHeader);
        // [THEN] Incoming document with attachment is connected to the posted purchase document
        VerifyIncomingDocumentWithAttachmentsExists(PurchHeader."Posting Date", DocNo, 1);
        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchInvVoucherFeatureEnabledAttachmentAutogeneratedAndManual()
    var
        PurchHeader: Record "Purchase Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        DocNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 475787] Stan can post a purchase invoice with autogenerated and manual digital vouchers when there is attachment check and the feature is enabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionPurchaseInvoice();
        // [GIVEN] Digital voucher entry setup for purchase document is "Attachment", "Generate Automatically" is enabled, "Skip If Manually Added" is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Purcnase invoice and Incoming document with attachment is created for the purchase document        
        // [WHEN] Post purchase document
        DocNo := ReceiveAndInvoicePurchaseInvoiceWithIncDoc(PurchHeader);
        // [THEN] Incoming document with two attachments is connected to the posted purchase document
        VerifyIncomingDocumentWithAttachmentsExists(PurchHeader."Posting Date", DocNo, 2);
        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchInvVoucherFeatureEnabledAttachmentAutogeneratedSkipped()
    var
        PurchHeader: Record "Purchase Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        DocNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 475787] Stan can post a purchase invoice with a digital voucher not generated automatically because of manual incoming document when there is attachment check and the feature is enabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionPurchaseInvoice();
        // [GIVEN] Digital voucher entry setup for purchase document is "Attachment", "Generate Automatically" is enabled, "Skip If Manually Added" is enabled
        InitSetupGenerateAutomaticallySkipIfManuallyAdded("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Purchase invoice and Incoming document with attachment is created for the purchase document
        // [WHEN] Post purchase document
        DocNo := ReceiveAndInvoicePurchaseInvoiceWithIncDoc(PurchHeader);
        // [THEN] Incoming document with one attachment is connected to the posted purchase document
        VerifyIncomingDocumentWithAttachmentsExists(PurchHeader."Posting Date", DocNo, 1);
        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure DotNotCheckVoucherOnBeforeRemoveReferencedRecordsWhenFeatureDisabled()
    var
        IncomingDocument: Record "Incoming Document";
        SalesInvHeader: Record "Sales Invoice Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        BlankRecID: RecordId;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 498196] Stan can remove the reference to the posted document from the incoming document when the feature is disabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        DisableDigitalVoucherFeature();
        // [GIVEN] Sales invoice and Incoming document is created
        SalesInvHeader."No." := LibraryUtility.GenerateGUID();
        SalesInvHeader.Insert();
        IncomingDocument."Entry No." := LibraryUtility.GetNewRecNo(IncomingDocument, IncomingDocument.FieldNo("Entry No."));
        IncomingDocument.Posted := true;
        IncomingDocument."Related Record ID" := SalesInvHeader.RecordId();
        IncomingDocument.Insert();
        LibraryVariableStorage.Enqueue(DetachQst);
        LibraryVariableStorage.Enqueue(true);
        LibraryVariableStorage.Enqueue(RemovePostedRecordManuallyMsg);
        // [WHEN] Remove the reference to the posted document from the incoming document
        IncomingDocument.RemoveReferencedRecords();
        // [THEN] The reference to the posted document is removed from the incoming document
        IncomingDocument.Find();
        IncomingDocument.TestField("Related Record ID", BlankRecID);

        LibraryVariableStorage.AssertEmpty();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure CheckVoucherOnBeforeRemoveReferencedRecordsWhenFeatureEnabled()
    var
        IncomingDocument: Record "Incoming Document";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 498196] Stan cannot remove the reference to the posted document from the incoming document when the feature is enabled
        Initialize();
        EnableDigitalVoucherFeature();
        // [GIVEN] Sales invoice and Incoming document is created
        SalesInvHeader."No." := LibraryUtility.GenerateGUID();
        SalesInvHeader.Insert();
        IncomingDocument."Entry No." := LibraryUtility.GetNewRecNo(IncomingDocument, IncomingDocument.FieldNo("Entry No."));
        IncomingDocument.Posted := true;
        IncomingDocument."Related Record ID" := SalesInvHeader.RecordId();
        IncomingDocument.Insert();
        // [WHEN] Remove the reference to the posted document from the incoming document
        asserterror IncomingDocument.RemoveReferencedRecords();
        // [THEN] Error "Cannot remove the reference record from the incoming document because it is used for the enforced digital voucher functionality" is shown
        Assert.ExpectedError(CannotRemoveReferenceRecordFromIncDocErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ErrorMessagePageHandler')]
    procedure PostBlankDocumentGeneralJournalLineWithRequiredAttachmentAndNoDigitalVoucher()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
    begin
        // [SCENARIO 554830] Stan cannot post a blank document general journal line with required attachment and no digital voucher

        Initialize();
        EnableDigitalVoucherFeature();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher entry setup for general journal is "Attachment" and "Consider Blank. Doc Type" option is enabled
        InitSetupCheckWithConsiderBlankDocType("Digital Voucher Entry Type"::"General Journal", "Digital Voucher Check Type"::Attachment, true);
        // [GIVEN] General journal line with "Document Type" = "" is created
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::" ", GenJournalLine."Account Type"::"G/L Account",
            LibraryERm.CreateGLAccountNo(), LibraryRandom.RandDec(100, 2));
        LibraryVariableStorage.Enqueue(DoYouWantToPostQst);
        LibraryVariableStorage.Enqueue(true);
        LibraryVariableStorage.Enqueue(NotPossibleToPostWithoutVoucherErr);
        // [WHEN] Post general journal
        asserterror BatchProcessingMgt.BatchProcessGenJournalLine(GenJournalLine, Codeunit::"Gen. Jnl.-Post");

        // [THEN] Error "Not possible to post without the voucher" is shown in the error message page
        // Verified in the ErrorMessagePageHandler

        LibraryVariableStorage.AssertEmpty();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure PostBlankDocumentGeneralJournalLineWithoutVoucherAndNoConsiderBlankDocTypeOption()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        DocNo: Code[20];
    begin
        // [SCENARIO 554830] Stan can post a blank document general journal line without digital voucher and disabled "Consider Blank. Document Type" option

        Initialize();
        EnableDigitalVoucherFeature();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher entry setup for general journal is "Attachment" and "Consider Blank Doc. Type" option is disabled
        InitSetupCheckOnly("Digital Voucher Entry Type"::"General Journal", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] General journal line with "Document Type" = "" is created
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::" ", GenJournalLine."Account Type"::"G/L Account",
            LibraryERm.CreateGLAccountNo(), LibraryRandom.RandDec(100, 2));
        DocNo := GenJournalLine."Document No.";
        LibraryVariableStorage.Enqueue(DoYouWantToPostQst);
        LibraryVariableStorage.Enqueue(true);
        LibraryVariableStorage.Enqueue(LinesPostedMsg);
        // [WHEN] Post general journal
        BatchProcessingMgt.BatchProcessGenJournalLine(GenJournalLine, Codeunit::"Gen. Jnl.-Post");

        // [THEN] General ledger entries are posted without the digital voucher
        GLEntry.SetRange("Posting Date", GenJournalLine."Posting Date");
        GLEntry.SetRange("Document No.", DocNo);
        Assert.RecordCount(GLEntry, 2);

        LibraryVariableStorage.AssertEmpty();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PostBlankDocTypeWithGenerateAutomaticallyAndConsiderBlankDocType()
    var
        GenJournalLine: Record "Gen. Journal Line";
        IncomingDocument: Record "Incoming Document";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        DocNo: Code[20];
        PostingDate: Date;
    begin
        // [SCENARIO 554830] Stan can post blank document general journal line with automatically generated voucher when "Consider Blank Doc. Type" option is enabled

        Initialize();
        EnableDigitalVoucherFeature();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher entry setup for general journal is "Attachment", "Generate Automatically" option is enabled and "Consider Blank Doc. Type" option is enabled
        InitSetupGenerateAutomaticallyAndConsiderBlankDocType("Digital Voucher Entry Type"::"General Journal", "Digital Voucher Check Type"::Attachment, true);
        // [GIVEN] General journal line with "Document Type" = "" is created
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::" ", GenJournalLine."Account Type"::"G/L Account",
            LibraryERm.CreateGLAccountNo(), LibraryRandom.RandDec(100, 2));
        DocNo := GenJournalLine."Document No.";
        PostingDate := GenJournalLine."Posting Date";
        // [WHEN] Post general journal line
        Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", GenJournalLine);

        // [THEN] Digital voucher is generated for the general journal line
        Assert.IsTrue(
            IncomingDocument.FindByDocumentNoAndPostingDate(
                IncomingDocument, DocNo, Format(PostingDate)),
            'Digital voucher has not been generated');

        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure NoDigitalVoucherIsGeneratedForBlankDocGenJnlLineWhenConsiderBlankDocTypeIsOff()
    var
        GenJournalLine: Record "Gen. Journal Line";
        IncomingDocument: Record "Incoming Document";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        DocNo: Code[20];
        PostingDate: Date;
    begin
        // [SCENARIO 554830] No digital voucher is generated for blank document general journal line when "Consider Blank Doc. Type" option is disabled

        Initialize();
        EnableDigitalVoucherFeature();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher entry setup for general journal is "Attachment", "Generate Automatically" option is enabled and "Consider Blank Doc. Type" option is disabled
        InitSetupGenerateAutomaticallyAndConsiderBlankDocType("Digital Voucher Entry Type"::"General Journal", "Digital Voucher Check Type"::Attachment, false);
        // [GIVEN] General journal line with "Document Type" = "" is created
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::" ", GenJournalLine."Account Type"::"G/L Account",
            LibraryERm.CreateGLAccountNo(), LibraryRandom.RandDec(100, 2));
        DocNo := GenJournalLine."Document No.";
        PostingDate := GenJournalLine."Posting Date";
        // [WHEN] Post general journal line
        Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", GenJournalLine);

        // [THEN] Digital voucher is not generated for the general journal line
        Assert.IsFalse(
            IncomingDocument.FindByDocumentNoAndPostingDate(
                IncomingDocument, DocNo, Format(PostingDate)),
            'Digital voucher has been generated');

        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ErrorMessagePageHandler')]
    procedure PostSalesJournalLineWithRequiredAttachmentAndNoDigitalVoucher()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
    begin
        // [SCENARIO 537136] Stan cannot post a sales journal line with required attachment and no digital voucher

        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher entry setup for sales journal is "Attachment"
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Sales Journal", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Sales journal line is created
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Customer,
            LibrarySales.CreateCustomerNo(), LibraryRandom.RandDec(100, 2));
        LibraryVariableStorage.Enqueue(DoYouWantToPostQst);
        LibraryVariableStorage.Enqueue(true);
        LibraryVariableStorage.Enqueue(NotPossibleToPostWithoutVoucherErr);
        // [WHEN] Post sales journal
        asserterror BatchProcessingMgt.BatchProcessGenJournalLine(GenJournalLine, Codeunit::"Gen. Jnl.-Post");

        // [THEN] Error "Not possible to post without the voucher" is shown in the error message page
        // Verified in the ErrorMessagePageHandler

        LibraryVariableStorage.AssertEmpty();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ErrorMessagePageHandler')]
    procedure PostPurchaseJournalLineWithRequiredAttachmentAndNoDigitalVoucher()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
    begin
        // [SCENARIO 537136] Stan cannot post a purchase journal line with required attachment and no digital voucher

        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher entry setup for purchase journal is "Attachment"
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Purchase Journal", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Purchase journal line is created
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Vendor,
            LibraryPurchase.CreateVendorNo(), LibraryRandom.RandDec(100, 2));
        LibraryVariableStorage.Enqueue(DoYouWantToPostQst);
        LibraryVariableStorage.Enqueue(true);
        LibraryVariableStorage.Enqueue(NotPossibleToPostWithoutVoucherErr);
        // [WHEN] Post purchase journal
        asserterror BatchProcessingMgt.BatchProcessGenJournalLine(GenJournalLine, Codeunit::"Gen. Jnl.-Post");

        // [THEN] Error "Not possible to post without the voucher" is shown in the error message page
        // Verified in the ErrorMessagePageHandler

        LibraryVariableStorage.AssertEmpty();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    [HandlerFunctions('StrMenuHandler,VerifyNoAttachmentsInEmailEditorModalPageHandler')]
    procedure PostSalesDocAndSendEmailWithDigitalVoucherAutomaticallyGenerated()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
    begin
        // [SCENARIO 537262] The automatically generated digital voucher is not suggested as an attachment during emailing

        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Email account is set up
        LibraryWorkflow.SetUpEmailAccount();
        BindActiveDirectoryMockEvents();
        // [GIVEN] Sales shipment report selections without attachment
        PrepareSalesShipmentReportSelectionsForEmailBodyWithoutAttachment();
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment" and "Generate Automatically" option is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);

        // [GIVEN] Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithUnitPrice(
            SalesLine, SalesHeader, LibraryInventory.CreateItemNo(),
            LibraryRandom.RandDec(100, 2), LibraryRandom.RandInt(100));

        // [GIVEN] Custom report selection for the customer for email body
        CreateCustomReportSelectionForCustomer(SalesHeader."Sell-to Customer No.", "Report Selection Usage"::"S.Shipment", Report::"Sales - Shipment");

        LibraryVariableStorage.Enqueue(1); // option for posting only shipment
        LibraryVariableStorage.Enqueue(3); // option for emailing to discard and not send any email
        // [WHEN] Post sales order and send email
        LibrarySales.PostSalesDocumentAndEmail(SalesHeader, true, true);

        // [THEN] No attachments are suggested in the E-mail editor
        // Verified in the VerifyNoAttachmentsInEmailEditorModalPageHandler

        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PostMultipleGeneralJournalLinesWithGenerateAutomaticallyOption()
    var
        GenJournalLine: array[2] of Record "Gen. Journal Line";
        GenJournalLineToPost: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        IncomingDocument: Record "Incoming Document";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        i: Integer;
    begin
        // [SCENARIO 537486] Stan can post multiple general journals lines with different documents and digital voucher set to by automatically generated

        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher entry setup for general journal is "Attachment" and "Generate Automatically" option is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"General Journal", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] General journal lines with the same template and batch are created
        // [GIVEN] General journal line "X" with "Posting Date" = 01.01.2024 and "Document No." = "X"
        // [GIVEN] General journal line "Y" with "Posting Date" = 01.01.2024 and "Document No." = "Y"
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate("Force Doc. Balance", false);
        GenJournalTemplate.Modify(true);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        for i := 1 to ArrayLen(GenJournalLine) do
            LibraryJournals.CreateGenJournalLine(
                GenJournalLine[i], GenJournalTemplate.Name, GenJournalBatch.Name,
                GenJournalLine[i]."Document Type"::Invoice, GenJournalLine[i]."Account Type"::"G/L Account",
                LibraryERM.CreateGLAccountNo(), GenJournalLine[i]."Bal. Account Type"::"G/L Account",
                LibraryERM.CreateGLAccountNo(), LibraryRandom.RandDec(100, 2));
        GenJournalLineToPost.SetRange("Journal Template Name", GenJournalTemplate.Name);
        GenJournalLineToPost.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLineToPost.FindSet();
        // [WHEN] Post both general journal lines
        Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", GenJournalLineToPost);

        // [THEN] Two digital vouchers generated for each combination of "Document No." and "Posting Date"
        for i := 1 to ArrayLen(GenJournalLine) do
            Assert.IsTrue(
                IncomingDocument.FindByDocumentNoAndPostingDate(
                    IncomingDocument, GenJournalLine[i]."Document No.", Format(GenJournalLine[i]."Posting Date")),
                'Digital voucher has not been generated');
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchInvVoucherFeatureEnabledAttachmentCorrect()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 538880] Stan can post a corrective purchase credit memo the digital voucher feature is enabled with the attachment check

        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionPurchaseInvoice();
        // [GIVEN] Digital voucher entry setup for purchase document is "Attachment", "Generate Automatically" is not enabled
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Posted purchase invoice and Incoming document with attachment
        PurchInvHeader.Get(ReceiveAndInvoicePurchaseInvoiceWithIncDoc());
        // [WHEN] Correct the posted purchase invoice
        CorrectPostedPurchInvoice.CancelPostedInvoice(PurchInvHeader);
        // [THEN] Incoming document with attachment is connected to the posted corrective credit memo
        LibrarySmallBusiness.FindPurchCorrectiveCrMemo(PurchCrMemoHdr, PurchInvHeader);
        VerifyIncomingDocumentWithAttachmentsExists(PurchCrMemoHdr."Posting Date", PurchCrMemoHdr."No.", 1);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure SalesInvVoucherFeatureEnabledAttachmentCorrect()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 538880] Stan can post a corrective sales credit memo the digital voucher feature is enabled with the attachment check

        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionSalesInvoice();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment", "Generate Automatically" is not enabled
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Posted sales invoice and Incoming document with attachment
        SalesInvHeader.Get(ShipAndInvoiceSalesDocumentWithIncDoc());
        // [WHEN] Correct the posted sales invoice
        CorrectPostedSalesInvoice.CancelPostedInvoice(SalesInvHeader);
        // [THEN] Incoming document with attachment is connected to the posted corrective credit memo
        LibrarySmallBusiness.FindSalesCorrectiveCrMemo(SalesCrMemoHeader, SalesInvHeader);
        VerifyIncomingDocumentWithAttachmentsExists(SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."No.", 1);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure ServiceInvNoVoucherFeatureEnabledAttachment()
    var
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
    begin
        // [FEATURE] [Service]
        // [SCENARIO 475787] Stan cannot post a service invoice without a digital voucher when there is attachment check and the feature is enabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher functionality is enabled
        EnableDigitalVoucherFeature();
        // [GIVEN] Digital Voucher Entry Setup for sales Document is "Attachment"
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Service invoice without incoming document
        // [WHEN] Post service document
        asserterror PostServiceInvoice();
        // [THEN] Error "Not possible to post without the voucher" is shown
        Assert.ExpectedErrorCode(DialogErrorCodeTok);
        Assert.ExpectedError(NotPossibleToPostWithoutVoucherErr);
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure ServInvVoucherFeatureEnabledAttachment()
    var
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        DocNo: Code[20];
    begin
        // [FEATURE] [Service]
        // [SCENARIO 475787] Stan can post a service invoice with the manually attached digital voucher when there is attachment check and the feature is enabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment"
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Service invoice with incoming document       
        // [WHEN] Post the service document
        DocNo := PostServiceInvoiceWithIncDoc();
        // [THEN] The document is posted with the digital voucher
        VerifyIncomingDocumentWithAttachmentsExists(WorkDate(), DocNo, 1);

        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure ServInvVoucherFeatureEnabledAttachmentAutogenerated()
    var
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        DocNo: Code[20];
    begin
        // [FEATURE] [Service]
        // [SCENARIO 475787] Stan can post a service invoice with a digital voucher generated automatically when there is attachment check and the feature is enabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionServiceInvoice();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment", "Generate Automatically" is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Service invoice without incoming document
        // [WHEN] Post the service document
        DocNo := PostServiceInvoice();
        // [THEN] The document is posted with the digital voucher
        VerifyIncomingDocumentWithAttachmentsExists(WorkDate(), DocNo, 1);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure ServCrMemoVoucherFeatureEnabledAttachmentAutogenerated()
    var
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        DocNo: Code[20];
    begin
        // [FEATURE] [Service]
        // [SCENARIO 475787] Stan can post a service credit memo with a digital voucher generated automatically when there is attachment check and the feature is enabled
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionServiceCrMemo();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment", "Generate Automatically" is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Service credit memo without incoming document
        // [WHEN] Post the service credit memo
        DocNo := PostServiceCrMemo();
        // [THEN] The document is posted with the digital voucher
        VerifyIncomingDocumentWithAttachmentsExists(WorkDate(), DocNo, 1);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler')]
    procedure PaymentReconciliationDoesNotRequireDigitalVoucher()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        VendLedgEntry: Record "Vendor Ledger Entry";
        PostedPmtReconHdr: Record "Posted Payment Recon. Hdr";
        BankAccReconPostYesNo: Codeunit "Bank Acc. Recon. Post (Yes/No)";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        BankAccountNo: Code[20];
    begin
        // [SCENARIO 539186] Stan can post a payment reconciliation without a digital voucher

        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled for purchase document and purchase journal
        EnableDigitalVoucherFeature();
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::Attachment);
        InitSetupCheckOnly("Digital Voucher Entry Type"::"Purchase Journal", "Digital Voucher Check Type"::Attachment);

        // [GIVEN] Payment account reconciliation with the purchase invoice
        BankAccountNo := CreateBankAccForPaymentReconciliation();
        LibraryERM.FindVendorLedgerEntry(
            VendLedgEntry, VendLedgEntry."Document Type"::Invoice, ReceiveAndInvoicePurchaseInvoiceWithIncDoc());
        CreatePmtReconForVendor(BankAccReconciliation, VendLedgEntry, BankAccountNo);
        LibraryVariableStorage.Enqueue(StrSubstNo(PaymentLineAppliedMsg, 1));
        LibraryVariableStorage.Enqueue(DoYouWantTPostPmtQst);
        LibraryVariableStorage.Enqueue(true);
        CODEUNIT.Run(CODEUNIT::"Match Bank Pmt. Appl.", BankAccReconciliation);

        // [WHEN] Post payment account reconciliation
        Assert.IsTrue(BankAccReconPostYesNo.BankAccReconPostYesNo(BankAccReconciliation), 'Not all payments posted.');

        // [THEN] Payment Acc. Reconciliation has been posted
        PostedPmtReconHdr.Get(BankAccReconciliation."Bank Account No.", BankAccReconciliation."Statement No.");

        LibraryVariableStorage.AssertEmpty();

        UnbindSubscription(DigVouchersDisableEnforce);
        NotificationLifecycleMgt.RecallAllNotifications();
    end;

    [Test]
    procedure SalesCrMemoVoucherFeatureEnabledGenerateAutomatically()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 539494] Stan can post a sales credit memo with the digital voucher automatically generated

        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionSalesCrMemo();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment", "Generate Automatically" is not enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        // [When] Post sales credit memo
        SalesCrMemoHeader.Get(ReceiveAndInvoiceSalesCrMemo());
        // [THEN] Incoming document with attachment is connected to the posted sales credit memo
        VerifyIncomingDocumentWithAttachmentsExists(SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."No.", 1);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchCrMemoVoucherFeatureEnabledGenerateAutomatically()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 539494] Stan can post a purchase credit memo with the digital voucher automatically generated

        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionPurchaseCrMemo();
        // [GIVEN] Digital voucher entry setup for purchase document is "Attachment", "Generate Automatically" is not enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::Attachment);
        // [When] Post purchase credit memo
        PurchCrMemoHdr.Get(ShipAndInvoicePurchaseCrMemo());
        // [THEN] Incoming document with attachment is connected to the posted purchase credit memo
        VerifyIncomingDocumentWithAttachmentsExists(PurchCrMemoHdr."Posting Date", PurchCrMemoHdr."No.", 1);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PrepmtSalesInvVoucherFeatureEnabledGenerateAutomatically()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 539494] Stan can post a prepayment sales invoice with the digital voucher automatically generated

        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionSalesInvoice();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment", "Generate Automatically" is not enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        // [WHEN] Post prepayment sales invoice
        SalesInvHeader.Get(PostSalesPrepmtInv());
        // [THEN] Incoming document with attachment is connected to the posted prepayment sales invoice
        VerifyIncomingDocumentWithAttachmentsExists(SalesInvHeader."Posting Date", SalesInvHeader."No.", 1);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PrepmtSalesCrMemoVoucherFeatureEnabledGenerateAutomatically()
    var
        SalesHeader: Record "Sales Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        NoSeries: Codeunit "No. Series";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 539494] Stan can post a prepayment sales credit memo with the digital voucher automatically generated

        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionSalesInvoice();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment", "Generate Automatically" is not enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] Posted prepayment sales invoice
        CreateSalesPrepmtInv(SalesHeader);
        LibrarySales.PostSalesPrepaymentInvoice(SalesHeader);
        DocumentNo := NoSeries.PeekNextNo(SalesHeader."Prepmt. Cr. Memo No. Series");
        // [WHEN] Post prepayment sales credit memo
        LibrarySales.PostSalesPrepaymentCrMemo(SalesHeader);
        // [THEN] Incoming document with attachment is connected to the posted prepayment sales credit memo
        VerifyIncomingDocumentWithAttachmentsExists(SalesHeader."Posting Date", DocumentNo, 1);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchInvVoucherAutomaticGenerationDoesNoChangeNoPrinted()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 542580] An automatic generation of the digital voucher does not change the "No. Printed" of the posted purchase invoice
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionPurchaseInvoice();
        // [GIVEN] Digital voucher entry setup for purchase document is "Attachment", "Generate Automatically" is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::Attachment);
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddPurchDocsPost();
        // [WHEN] Post purchase invoice
        PurchInvHeader.Get(ReceiveAndInvoicePurchaseInvoice());
        // [THEN] "No. Printed" is 0 for the posted purchase invoice
        PurchInvHeader.TestField("No. Printed", 0);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchCrMemoVoucherAutomaticGenerationDoesNoChangeNoPrinted()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 542580] An automatic generation of the digital voucher does not change the "No. Printed" of the posted purchase credit memo
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionPurchaseCrMemo();
        // [GIVEN] Digital voucher entry setup for purchase document is "Attachment", "Generate Automatically" is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Purchase Document", "Digital Voucher Check Type"::Attachment);
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddPurchDocsPost();
        // [WHEN] Post purchase credit memo
        PurchCrMemoHdr.Get(ShipAndInvoicePurchaseCrMemo());
        // [THEN] "No. Printed" is 0 for the posted purchase credit memo
        PurchCrMemoHdr.TestField("No. Printed", 0);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure SalesInvVoucherAutomaticGenerationDoesNoChangeNoPrinted()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 542580] An automatic generation of the digital voucher does not change the "No. Printed" of the posted sales invoice
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionSalesInvoice();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment", "Generate Automatically" is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsPost();
        // [WHEN] Post sales invoice
        SalesInvHeader.Get(ShipAndInvoiceSalesInvoice());
        // [THEN] "No. Printed" is 0 for the posted sales invoice
        SalesInvHeader.TestField("No. Printed", 0);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
        LibraryLowerPermissions.SetOutsideO365Scope();
    end;

    [Test]
    procedure SalesCrMemoVoucherAutomaticGenerationDoesNoChangeNoPrinted()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 542580] An automatic generation of the digital voucher does not change the "No. Printed" of the posted sales credit memo
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionSalesCrMemo();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment", "Generate Automatically" is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsPost();
        // [WHEN] Post sales credit memo
        SalesCrMemoHeader.Get(ReceiveAndInvoiceSalesCrMemo());
        // [THEN] "No. Printed" is 0 for the posted sales credit memo
        SalesCrMemoHeader.TestField("No. Printed", 0);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure ServiceInvVoucherAutomaticGenerationDoesNoChangeNoPrinted()
    var
        ServInvHeader: Record "Service Invoice Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        // [FEATURE] [Service]
        // [SCENARIO 542580] An automatic generation of the digital voucher does not change the "No. Printed" of the posted service invoice
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionServiceInvoice();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment", "Generate Automatically" is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddO365WhseEdit();
        LibraryLowerPermissions.AddAccountPayables();
        LibraryLowerPermissions.AddO365ServiceMgtEdit();
        // [WHEN] Post service invoice
        ServInvHeader.Get(PostServiceInvoice());
        // [THEN] "No. Printed" is 0 for the posted service invoice
        ServInvHeader.TestField("No. Printed", 0);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure ServiceCrMemoVoucherAutomaticGenerationDoesNoChangeNoPrinted()
    var
        ServCrMemoHeader: Record "Service Cr.Memo Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        // [FEATURE] [Service]
        // [SCENARIO 542580] An automatic generation of the digital voucher does not change the "No. Printed" of the posted service credit memo
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        InitializeReportSelectionServiceCrMemo();
        // [GIVEN] Digital voucher entry setup for sales document is "Attachment", "Generate Automatically" is enabled
        InitSetupGenerateAutomatically("Digital Voucher Entry Type"::"Sales Document", "Digital Voucher Check Type"::Attachment);
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddO365WhseEdit();
        LibraryLowerPermissions.AddAccountPayables();
        LibraryLowerPermissions.AddO365ServiceMgtEdit();
        // [WHEN] Post service credit memo
        ServCrMemoHeader.Get(PostServiceCrMemo());
        // [THEN] "No. Printed" is 0 for the posted service credit memo
        ServCrMemoHeader.TestField("No. Printed", 0);

        NotificationLifecycleMgt.RecallAllNotifications();
        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PostMultipleGeneralJournalLinesSamePostingDateDocNoOnlyFirstHasIncDoc()
    var
        GenJournalLine: array[2] of Record "Gen. Journal Line";
        GenJournalLineToPost: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        IncomingDocument: Record "Incoming Document";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        DocNo: Code[20];
        i: Integer;
    begin
        // [SCENARIO 540097] Stan can post multiple general journals lines with same posting date and document number, only the first line has incoming document

        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        // [GIVEN] Digital voucher entry setup for general journal is "Attachment"
        InitSetupCheckOnly("Digital Voucher Entry Type"::"General Journal", "Digital Voucher Check Type"::Attachment);
        // [GIVEN] General journal lines with the same template and batch are created
        // [GIVEN] General journal line "X" with "Posting Date" = 01.01.2024 and "Document No." = "X"
        // [GIVEN] General journal line "Y" with "Posting Date" = 01.01.2024 and "Document No." = "X"
        DocNo := LibraryUtility.GenerateGUID();
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        for i := 1 to ArrayLen(GenJournalLine) do begin
            LibraryJournals.CreateGenJournalLine(
                GenJournalLine[i], GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
                GenJournalLine[i]."Document Type"::Invoice, GenJournalLine[i]."Account Type"::"G/L Account",
                LibraryERM.CreateGLAccountNo(), GenJournalLine[i]."Bal. Account Type"::"G/L Account",
                LibraryERM.CreateGLAccountNo(), LibraryRandom.RandDec(100, 2));
            GenJournalLine[i].Validate("Document No.", DocNo);
            GenJournalLine[i].Modify(true);
        end;
        // [GIVEN] Only journal line "X" has incoming document attached
        GenJournalLine[1]."Incoming Document Entry No." := MockIncomingDocument();
        GenJournalLine[1].Modify(true);

        GenJournalLineToPost.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLineToPost.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLineToPost.FindSet();
        // [WHEN] Post both general journal lines
        Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", GenJournalLineToPost);

        // [THEN] Posting is successfull and we have an incoming document with "Posting Date" = 01.01.2024 and "Document No." = "X"
        IncomingDocument.SetRange("Posting Date", GenJournalLine[1]."Posting Date");
        IncomingDocument.SetRange("Document No.", GenJournalLine[1]."Document No.");
        Assert.RecordIsNotEmpty(IncomingDocument);

        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    local procedure Initialize()
    var
        CompanyInformation: Record "Company Information";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate("Allow Blank Payment Info.", true);
        CompanyInformation.Modify(true);
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Digital Vouchers Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Digital Vouchers Tests");

        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Digital Vouchers Tests");
    end;

    local procedure EnableDigitalVoucherFeature()
    begin
        SetEnableDigitalVoucherFeature(true);
    end;

    local procedure DisableDigitalVoucherFeature()
    begin
        SetEnableDigitalVoucherFeature(false);
    end;

    local procedure SetEnableDigitalVoucherFeature(NewEnabled: Boolean)
    var
        DigitalVoucherSetup: Record "Digital Voucher Setup";
    begin
        DigitalVoucherSetup.DeleteAll();
        DigitalVoucherSetup.Enabled := NewEnabled;
        DigitalVoucherSetup.Insert();
    end;

    local procedure InitSetupCheckOnly(EntryType: Enum "Digital Voucher Entry Type"; CheckType: Enum "Digital Voucher Check Type")
    begin
        InitSetup(EntryType, CheckType, false, false, false);
    end;

    local procedure InitSetupCheckWithConsiderBlankDocType(EntryType: Enum "Digital Voucher Entry Type"; CheckType: Enum "Digital Voucher Check Type"; ConsiderBlankDocType: Boolean)
    begin
        InitSetup(EntryType, CheckType, false, false, ConsiderBlankDocType);
    end;

    local procedure InitSetupGenerateAutomatically(EntryType: Enum "Digital Voucher Entry Type"; CheckType: Enum "Digital Voucher Check Type")
    begin
        InitSetup(EntryType, CheckType, true, false, false);
    end;

    local procedure InitSetupGenerateAutomaticallyAndConsiderBlankDocType(EntryType: Enum "Digital Voucher Entry Type"; CheckType: Enum "Digital Voucher Check Type"; ConsiderBlankDocType: Boolean)
    begin
        InitSetup(EntryType, CheckType, true, false, ConsiderBlankDocType);
    end;

    local procedure InitSetupGenerateAutomaticallySkipIfManuallyAdded(EntryType: Enum "Digital Voucher Entry Type"; CheckType: Enum "Digital Voucher Check Type")
    begin
        InitSetup(EntryType, CheckType, true, true, false);
    end;

    local procedure InitSetup(EntryType: Enum "Digital Voucher Entry Type"; CheckType: Enum "Digital Voucher Check Type"; GenerateAutomatically: Boolean; SkipIsManuallyAdded: Boolean; ConsiderBlankDocType: Boolean)
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        DigitalVoucherEntrySetup.SetRange("Entry Type", EntryType);
        DigitalVoucherEntrySetup.DeleteAll();
        DigitalVoucherEntrySetup."Entry Type" := EntryType;
        DigitalVoucherEntrySetup."Check Type" := CheckType;
        DigitalVoucherEntrySetup."Generate Automatically" := GenerateAutomatically;
        DigitalVoucherEntrySetup."Skip If Manually Added" := SkipIsManuallyAdded;
        DigitalVoucherEntrySetup."Consider Blank Doc. Type" := ConsiderBlankDocType;
        DigitalVoucherEntrySetup.Insert();
    end;

    local procedure InitializeReportSelectionPurchaseInvoice()
    begin
        InitializeReportSelection("Report Selection Usage"::"P.Invoice", Report::"Purchase - Invoice");
    end;

    local procedure InitializeReportSelectionPurchaseCrMemo()
    begin
        InitializeReportSelection("Report Selection Usage"::"P.Cr.Memo", Report::"Purchase - Credit Memo");
    end;

    local procedure InitializeReportSelectionServiceInvoice()
    begin
        InitializeReportSelection("Report Selection Usage"::"SM.Invoice", Report::"Service - Invoice");
    end;

    local procedure InitializeReportSelectionServiceCrMemo()
    begin
        InitializeReportSelection("Report Selection Usage"::"SM.Credit Memo", Report::"Service - Credit Memo");
    end;

    local procedure InitializeReportSelection(RepSelectionUsage: Enum "Report Selection Usage"; ReportId: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange("Usage", RepSelectionUsage);
        ReportSelections.DeleteAll();
        ReportSelections.Usage := RepSelectionUsage;
        ReportSelections."Report ID" := ReportId;
        ReportSelections.Insert();
    end;

    local procedure InitializeReportSelectionSalesInvoice()
    var
        ReportSelections: Record "Report Selections";
        Usage: Enum "Report Selection Usage";
    begin
        Usage := "Report Selection Usage"::"S.Invoice";
        ReportSelections.SetRange("Usage", Usage);
        ReportSelections.DeleteAll();
        ReportSelections.Usage := Usage;
        ReportSelections."Report ID" := Report::"Standard Sales - Invoice";
        ReportSelections.Insert();
    end;

    local procedure InitializeReportSelectionSalesCrMemo()
    var
        ReportSelections: Record "Report Selections";
        Usage: Enum "Report Selection Usage";
    begin
        Usage := "Report Selection Usage"::"S.Cr.Memo";
        ReportSelections.SetRange("Usage", Usage);
        ReportSelections.DeleteAll();
        ReportSelections.Usage := Usage;
        ReportSelections."Report ID" := Report::"Standard Sales - Credit Memo";
        ReportSelections.Insert();
    end;

    local procedure CreateBankAccForPaymentReconciliation(): Code[20]
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Last Statement No.", Format(LibraryRandom.RandInt(10)));
        BankAccount.Modify(true);
        exit(BankAccount."No.");
    end;

    local procedure CreatePmtReconForVendor(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; VendLedgEntry: Record "Vendor Ledger Entry"; BankAccountNo: Code[20])
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        VendLedgEntry.CalcFields("Remaining Amount");
        LibraryERM.CreateBankAccReconciliation(
          BankAccReconciliation, BankAccountNo, BankAccReconciliation."Statement Type"::"Payment Application");
        CreateBankAccReconciliationLine(
            BankAccReconciliation, BankAccReconciliationLine, BankAccReconciliationLine."Account Type"::Vendor,
            VendLedgEntry."Vendor No.", VendLedgEntry."Remaining Amount", WorkDate());
        BankAccReconciliation.Validate("Post Payments Only", true);
        BankAccReconciliationLine.Modify(true);
    end;

    local procedure MockIncomingDocument(PostingDate: Date; DocNo: Code[20]): Integer
    var
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
    begin
        IncomingDocument."Entry No." :=
            LibraryUtility.GetNewRecNo(IncomingDocument, IncomingDocument.FieldNo("Entry No."));
        IncomingDocument."Posting Date" := PostingDate;
        IncomingDocument."Document No." := DocNo;
        IncomingDocument.Insert();
        IncomingDocumentAttachment."Incoming Document Entry No." := IncomingDocument."Entry No.";
        IncomingDocumentAttachment.Insert();
        exit(IncomingDocument."Entry No.");
    end;

    local procedure MockIncomingDocument(): Integer
    var
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
    begin
        IncomingDocument."Entry No." :=
            LibraryUtility.GetNewRecNo(IncomingDocument, IncomingDocument.FieldNo("Entry No."));
        IncomingDocument.Insert();
        IncomingDocumentAttachment."Incoming Document Entry No." := IncomingDocument."Entry No.";
        IncomingDocumentAttachment.Insert();
        exit(IncomingDocument."Entry No.");
    end;

    local procedure ReceiveAndInvoicePurchaseInvoice(): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(ReceiveAndInvoicePurchaseInvoice(PurchaseHeader));
    end;

    local procedure ReceiveAndInvoicePurchaseInvoiceWithIncDoc(): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(ReceiveAndInvoicePurchaseInvoiceWithIncDoc(PurchaseHeader));
    end;

    local procedure ReceiveAndInvoicePurchaseInvoice(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure ShipAndInvoicePurchaseCrMemo(): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryPurchase.CreatePurchaseCreditMemo(PurchaseHeader);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure ReceiveAndInvoicePurchaseInvoiceWithIncDoc(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        PurchaseHeader.Validate("Incoming Document Entry No.", MockIncomingDocument(PurchaseHeader."Posting Date", PurchaseHeader."No."));
        PurchaseHeader.Modify(true);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure ReceiveAndInvoiceSalesCrMemo(): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesCreditMemo(SalesHeader);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure ShipAndInvoiceSalesInvoice(): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure ReceiveAndInvoiceSalesInvoice(): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesCreditMemo(SalesHeader);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure ShipAndInvoiceSalesDocumentWithIncDoc(): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        SalesHeader.Validate("Incoming Document Entry No.", MockIncomingDocument(SalesHeader."Posting Date", SalesHeader."No."));
        SalesHeader.Modify(true);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure PostSalesPrepmtInv(): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesPrepmtInv(SalesHeader);
        exit(LibrarySales.PostSalesPrepaymentInvoice(SalesHeader));
    end;

    local procedure CreateSalesPrepmtInv(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        SalesHeader.Validate("Prepayment %", LibraryRandom.RandInt(50));
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(
            SalesLine, SalesHeader, SalesLine.Type::"G/L Account",
            LibraryERM.CreateGLAccountWithSalesSetup(), LibraryRandom.RandInt(5));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 1));
        SalesLine.Modify(true);
        GeneralPostingSetup.Get(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
        GeneralPostingSetup."Sales Prepayments Account" := LibraryERM.CreateGLAccountWithSalesSetup();
        GeneralPostingSetup.Modify(true);
    end;

    local procedure PostServiceInvoice(): Code[20]
    var
        ServiceHeader: Record "Service Header";
    begin
        CreateServiceDocument(ServiceHeader, ServiceHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        exit(GetServInvNoAfterPosting(ServiceHeader));
    end;

    local procedure PostServiceInvoiceWithIncDoc(): Code[20]
    var
        ServiceHeader: Record "Service Header";
    begin
        CreateServiceDocument(ServiceHeader, ServiceHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Incoming Document Entry No.", MockIncomingDocument(ServiceHeader."Posting Date", ServiceHeader."No."));
        ServiceHeader.Modify(true);
        exit(GetServInvNoAfterPosting(ServiceHeader));
    end;

    local procedure GetServInvNoAfterPosting(var ServiceHeader: Record "Service Header"): Code[20]
    var
        ServInvHeader: Record "Service Invoice Header";
    begin
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        ServInvHeader.SetRange("Pre-Assigned No.", ServiceHeader."No.");
        ServInvHeader.FindFirst();
        exit(ServInvHeader."No.");
    end;

    local procedure PostServiceCrMemo(): Code[20]
    var
        ServiceHeader: Record "Service Header";
    begin
        CreateServiceDocument(ServiceHeader, ServiceHeader."Document Type"::"Credit Memo", LibrarySales.CreateCustomerNo());
        exit(GetServCrMemoNoAfterPosting(ServiceHeader));
    end;

    local procedure GetServCrMemoNoAfterPosting(var ServiceHeader: Record "Service Header"): Code[20]
    var
        ServCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        ServCrMemoHeader.SetRange("Pre-Assigned No.", ServiceHeader."No.");
        ServCrMemoHeader.FindFirst();
        exit(ServCrMemoHeader."No.");
    end;

    local procedure CreateServiceDocument(var ServiceHeader: Record "Service Header"; DocType: Enum "Service Document Type"; CustNo: Code[20])
    var
        ServiceLine: Record "Service Line";
        ServiceItem: Record "Service Item";
        ServiceItemLine: Record "Service Item Line";
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, DocType, CustNo);
        ServiceHeader.Validate("Order Date", WorkDate());
        ServiceHeader.Modify(true);
        LibraryService.CreateServiceItem(ServiceItem, ServiceHeader."Customer No.");
        LibraryService.CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");
        LibraryService.CreateServiceLineWithQuantity(
          ServiceLine, ServiceHeader, ServiceLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));
        ServiceLine.Validate("Unit Price", LibraryRandom.RandDecInRange(1000, 2000, 2));
        ServiceLine.Modify(true);
    end;

    local procedure AssertVendorLedgerEntryExists(DocNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, DocNo);
    end;

    local procedure PrepareSalesShipmentReportSelectionsForEmailBodyWithoutAttachment()
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Shipment");
        ReportSelections.ModifyAll("Use for Email Body", false);
        ReportSelections.ModifyAll("Use for Email Attachment", false);
    end;

    local procedure CreateCustomReportSelectionForCustomer(CustomerNo: Code[20]; ReportSelectionUsage: Enum "Report Selection Usage"; ReportID: Integer)
    var
        CustomReportSelection: Record "Custom Report Selection";
        CustomReportLayout: Record "Custom Report Layout";
    begin
        CustomReportSelection.Init();
        CustomReportSelection.Validate("Source Type", Database::Customer);
        CustomReportSelection.Validate("Source No.", CustomerNo);
        CustomReportSelection.Validate(Usage, ReportSelectionUsage);
        CustomReportSelection.Validate(Sequence, 1);
        CustomReportSelection.Validate("Report ID", ReportID);
        CustomReportSelection.Validate("Use for Email Body", true);
        CustomReportSelection.Validate("Use for Email Attachment", false);
        CustomReportSelection.Validate(
            "Email Body Layout Code", CustomReportLayout.InitBuiltInLayout(CustomReportSelection."Report ID", CustomReportLayout.Type::Word.AsInteger()));
        CustomReportSelection.Insert(true);
    end;

    local procedure BindActiveDirectoryMockEvents()
    begin
        if ActiveDirectoryMockEvents.Enabled() then
            exit;
        BindSubscription(ActiveDirectoryMockEvents);
        ActiveDirectoryMockEvents.Enable();
    end;

    local procedure CreateBankAccReconciliationLine(BankAccReconciliation: Record "Bank Acc. Reconciliation"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; Amount: Decimal; Date: Date)
    begin
        LibraryERM.CreateBankAccReconciliationLn(BankAccReconciliationLine, BankAccReconciliation);
        BankAccReconciliationLine.Validate("Account Type", AccountType);
        BankAccReconciliationLine.Validate("Account No.", AccountNo);
        BankAccReconciliationLine.Validate("Document No.", LibraryUtility.GenerateGUID());
        BankAccReconciliationLine.Validate("Statement Amount", Amount);
        BankAccReconciliationLine.Validate("Transaction Date", Date);
        BankAccReconciliationLine.Validate(Description, AccountNo);
        BankAccReconciliationLine.Modify(true);
    end;

    local procedure VerifyIncomingDocumentWithAttachmentsExists(PostingDate: Date; DocNo: Code[20]; AttachmentsCount: Integer)
    var
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
    begin
        IncomingDocument.SetRange("Posting Date", PostingDate);
        IncomingDocument.SetRange("Document No.", DocNo);
        IncomingDocument.FindFirst();
        IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        Assert.RecordCount(IncomingDocumentAttachment, AttachmentsCount);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Question);
        ;
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Message);
    end;

    [PageHandler]
    procedure ErrorMessagePageHandler(var ErrorMessagesPage: TestPage "Error Messages")
    begin
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), ErrorMessagesPage.Description, 'Error message description is not correct');
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure StrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := LibraryVariableStorage.DequeueInteger();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure VerifyNoAttachmentsInEmailEditorModalPageHandler(var TestEmailEditor: TestPage "Email Editor")
    begin
        TestEmailEditor.Attachments.FileName.AssertEquals('');
    end;
}