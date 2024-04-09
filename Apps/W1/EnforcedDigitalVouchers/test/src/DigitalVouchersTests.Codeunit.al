codeunit 139515 "Digital Vouchers Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        NotPossibleToPostWithoutVoucherErr: Label 'Not possible to post without attaching the digital voucher.';
        DialogErrorCodeTok: Label 'Dialog', Locked = true;
        CannotRemoveReferenceRecordFromIncDocErr: Label 'Cannot remove the reference record from the incoming document because it is used for the enforced digital voucher functionality';
        DetachQst: Label 'Do you want to remove the reference from this incoming document to posted document';
        RemovePostedRecordManuallyMsg: Label 'The reference to the posted record has been removed.\\Remember to correct the posted record if needed.';

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
        DocNo := ReceiveAndInvoicePurchaseDocument();
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
        DocNo := ReceiveAndInvoicePurchaseDocument();
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
        asserterror ReceiveAndInvoicePurchaseDocument();
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
        DocNo := ReceiveAndInvoicePurchaseDocumentWithIncDoc();
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
        DocNo := ReceiveAndInvoicePurchaseDocument(PurchHeader);
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
        DocNo := ReceiveAndInvoicePurchaseDocumentWithIncDoc(PurchHeader);
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
        DocNo := ReceiveAndInvoicePurchaseDocumentWithIncDoc(PurchHeader);
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

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Digital Vouchers Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Digital Vouchers Tests");

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
        InitSetup(EntryType, CheckType, false, false);
    end;

    local procedure InitSetupGenerateAutomatically(EntryType: Enum "Digital Voucher Entry Type"; CheckType: Enum "Digital Voucher Check Type")
    begin
        InitSetup(EntryType, CheckType, true, false);
    end;

    local procedure InitSetupGenerateAutomaticallySkipIfManuallyAdded(EntryType: Enum "Digital Voucher Entry Type"; CheckType: Enum "Digital Voucher Check Type")
    begin
        InitSetup(EntryType, CheckType, true, true);
    end;

    local procedure InitSetup(EntryType: Enum "Digital Voucher Entry Type"; CheckType: Enum "Digital Voucher Check Type"; GenerateAutomatically: Boolean; SkipIsManuallyAdded: Boolean)
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        DigitalVoucherEntrySetup.SetRange("Entry Type", EntryType);
        DigitalVoucherEntrySetup.DeleteAll();
        DigitalVoucherEntrySetup."Entry Type" := EntryType;
        DigitalVoucherEntrySetup."Check Type" := CheckType;
        DigitalVoucherEntrySetup."Generate Automatically" := GenerateAutomatically;
        DigitalVoucherEntrySetup."Skip If Manually Added" := SkipIsManuallyAdded;
        DigitalVoucherEntrySetup.Insert();
    end;

    local procedure InitializeReportSelectionPurchaseInvoice()
    var
        ReportSelections: Record "Report Selections";
        Usage: Enum "Report Selection Usage";
    begin
        Usage := "Report Selection Usage"::"P.Invoice";
        ReportSelections.SetRange("Usage", Usage);
        ReportSelections.DeleteAll();
        ReportSelections.Usage := Usage;
        ReportSelections."Report ID" := Report::"Purchase - Invoice";
        ReportSelections.Insert();
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

    local procedure ReceiveAndInvoicePurchaseDocument(): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(ReceiveAndInvoicePurchaseDocument(PurchaseHeader));
    end;

    local procedure ReceiveAndInvoicePurchaseDocumentWithIncDoc(): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(ReceiveAndInvoicePurchaseDocumentWithIncDoc(PurchaseHeader));
    end;

    local procedure ReceiveAndInvoicePurchaseDocument(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure ReceiveAndInvoicePurchaseDocumentWithIncDoc(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        PurchaseHeader.Validate("Incoming Document Entry No.", MockIncomingDocument(PurchaseHeader."Posting Date", PurchaseHeader."No."));
        PurchaseHeader.Modify(true);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure AssertVendorLedgerEntryExists(DocNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, DocNo);
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
}