// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Test.EServices.EDocument;

using Microsoft.eServices.EDocument;
using Microsoft.Foundation.Address;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Tests.EServices.EDocument;

codeunit 139649 "E-Doc. Attachment Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;
        DialogErrorCodeTok: Label 'Dialog', Locked = true;
        NotPossibleToPostWithoutEDocumentErr: Label 'Not possible to post without linking an E-Document.', Locked = true;
        EDocumentTok: Label 'E-Document', Locked = true;

    [Test]
    procedure GenerateAutomaticallyEnabledWhenCheckTypeSetToEDocument()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        // [FEATURE] [Digital Voucher] [E-Document]
        // [SCENARIO] Generate Automatically is auto-enabled when Check Type is set to E-Document
        Initialize();

        // [GIVEN] Setup record for Purchase Document with Generate Automatically = false
        DigitalVoucherEntrySetup."Entry Type" := DigitalVoucherEntrySetup."Entry Type"::"Purchase Document";
        DigitalVoucherEntrySetup."Generate Automatically" := false;

        // [WHEN] Validate Check Type = E-Document
        DigitalVoucherEntrySetup.Validate("Check Type", DigitalVoucherEntrySetup."Check Type"::"E-Document");

        // [THEN] Generate Automatically is automatically set to true
        DigitalVoucherEntrySetup.TestField("Generate Automatically", true);
    end;

    [Test]
    procedure GenerateAutomaticallyCannotBeDisabledForEDocument()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        GenerateAutomaticallyErrorTok: Label 'Generate Automatically must be enabled', Locked = true;
    begin
        // [FEATURE] [Digital Voucher] [E-Document]
        // [SCENARIO] Generate Automatically cannot be disabled when Check Type = E-Document
        Initialize();

        // [GIVEN] Entry Type = Purchase Document, Check Type = E-Document
        DigitalVoucherEntrySetup."Entry Type" := DigitalVoucherEntrySetup."Entry Type"::"Purchase Document";
        DigitalVoucherEntrySetup.Validate("Check Type", DigitalVoucherEntrySetup."Check Type"::"E-Document");

        // [WHEN] Try to disable Generate Automatically
        asserterror DigitalVoucherEntrySetup.Validate("Generate Automatically", false);

        // [THEN] Error: Generate Automatically must be enabled when Check Type is E-Document
        Assert.ExpectedError(GenerateAutomaticallyErrorTok);
    end;

    [Test]
    procedure EDocumentCheckTypeNotAllowedForGeneralJournal()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        // [FEATURE] [Digital Voucher] [E-Document]
        // [SCENARIO] E-Document check type is not allowed for General Journal
        Initialize();

        // [GIVEN] Entry Type = General Journal
        DigitalVoucherEntrySetup."Entry Type" := DigitalVoucherEntrySetup."Entry Type"::"General Journal";

        // [WHEN] Validate Check Type = E-Document
        asserterror DigitalVoucherEntrySetup.Validate("Check Type", DigitalVoucherEntrySetup."Check Type"::"E-Document");

        // [THEN] Error mentioning E-Document requires Sales Document or Purchase Document
        Assert.ExpectedError(EDocumentTok);
    end;

    [Test]
    procedure EDocumentCheckTypeNotAllowedForSalesJournal()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        // [FEATURE] [Digital Voucher] [E-Document]
        // [SCENARIO] E-Document check type is not allowed for Sales Journal
        Initialize();

        // [GIVEN] Entry Type = Sales Journal
        DigitalVoucherEntrySetup."Entry Type" := DigitalVoucherEntrySetup."Entry Type"::"Sales Journal";

        // [WHEN] Validate Check Type = E-Document
        asserterror DigitalVoucherEntrySetup.Validate("Check Type", DigitalVoucherEntrySetup."Check Type"::"E-Document");

        // [THEN] Error mentioning E-Document requires Sales Document or Purchase Document
        Assert.ExpectedError(EDocumentTok);
    end;

    [Test]
    procedure EDocumentCheckTypeNotAllowedForPurchaseJournal()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        // [FEATURE] [Digital Voucher] [E-Document]
        // [SCENARIO] E-Document check type is not allowed for Purchase Journal
        Initialize();

        // [GIVEN] Entry Type = Purchase Journal
        DigitalVoucherEntrySetup."Entry Type" := DigitalVoucherEntrySetup."Entry Type"::"Purchase Journal";

        // [WHEN] Validate Check Type = E-Document
        asserterror DigitalVoucherEntrySetup.Validate("Check Type", DigitalVoucherEntrySetup."Check Type"::"E-Document");

        // [THEN] Error mentioning E-Document requires Sales Document or Purchase Document
        Assert.ExpectedError(EDocumentTok);
    end;

    [Test]
    procedure PurchaseInvoiceCannotPostWithoutEDocument()
    var
        DummyEDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
    begin
        // [FEATURE] [Digital Voucher] [E-Document]
        // [SCENARIO] Purchase invoice posting fails when E-Document check is enabled but no e-document linked
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        EnableDigitalVoucherFeature();

        // [GIVEN] Digital voucher entry setup for purchase document is "E-Document"
        InitSetupEDocument("Digital Voucher Entry Type"::"Purchase Document");

        // [GIVEN] Purchase invoice WITHOUT linked e-document
        CreatePurchaseDocument(PurchaseHeader, "Purchase Document Type"::Invoice, DummyEDocument);

        // [WHEN] Post purchase invoice
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Error: Not possible to post without linking an E-Document
        Assert.ExpectedErrorCode(DialogErrorCodeTok);
        Assert.ExpectedError(NotPossibleToPostWithoutEDocumentErr);

        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchaseInvoiceEDocumentAttachedAfterPosting()
    var
        EDocument: Record "E-Document";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        DocNo: Code[20];
    begin
        // [FEATURE] [Digital Voucher] [E-Document]
        // [SCENARIO] Purchase invoice with e-document creates incoming attachment with Is E-Document = true
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        EnableDigitalVoucherFeature();

        // [GIVEN] Digital voucher entry setup for purchase document is "E-Document"
        InitSetupEDocument("Digital Voucher Entry Type"::"Purchase Document");

        // [GIVEN] Purchase invoice with linked e-document
        CreatePurchaseDocumentWithEDocument(PurchaseHeader, EDocument, "Purchase Document Type"::Invoice);

        // [WHEN] Post purchase invoice (e-document attachment happens automatically)
        DocNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Incoming attachment exists with "Is E-Document" = true
        PurchInvHeader.Get(DocNo);
        AssertEDocumentIncomingAttachmentExists(PurchInvHeader."Posting Date", PurchInvHeader."No.");

        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure PurchaseCreditMemoEDocumentAttachedAfterPosting()
    var
        EDocument: Record "E-Document";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchaseHeader: Record "Purchase Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        DocNo: Code[20];
    begin
        // [FEATURE] [Digital Voucher] [E-Document]
        // [SCENARIO] Purchase credit memo with e-document creates incoming attachment with Is E-Document = true
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        EnableDigitalVoucherFeature();

        // [GIVEN] Digital voucher entry setup for purchase document is "E-Document"
        InitSetupEDocument("Digital Voucher Entry Type"::"Purchase Document");

        // [GIVEN] Purchase credit memo with linked e-document
        CreatePurchaseDocumentWithEDocument(PurchaseHeader, EDocument, "Purchase Document Type"::"Credit Memo");

        // [WHEN] Post purchase credit memo (e-document attachment happens automatically)
        DocNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Incoming attachment exists with "Is E-Document" = true
        PurchCrMemoHdr.Get(DocNo);
        AssertEDocumentIncomingAttachmentExists(PurchCrMemoHdr."Posting Date", PurchCrMemoHdr."No.");

        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure SalesInvoiceEDocumentAttachedAfterExport()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        DocNo: Code[20];
    begin
        // [FEATURE] [Digital Voucher] [E-Document]
        // [SCENARIO] Sales invoice e-document export creates incoming attachment with Is E-Document = true
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        EnableDigitalVoucherFeature();

        // [GIVEN] Digital voucher entry setup for sales document is "E-Document"
        InitSetupEDocument("Digital Voucher Entry Type"::"Sales Document");

        // [WHEN] Posted sales invoice
        DocNo := CreateSalesDocumentWithEDocRequirements(SalesHeader, "Sales Document Type"::Invoice);
        SalesInvoiceHeader.Get(DocNo);

        // [THEN] Incoming attachment exists with "Is E-Document" = true
        AssertEDocumentIncomingAttachmentExists(SalesInvoiceHeader."Posting Date", SalesInvoiceHeader."No.");

        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    [Test]
    procedure SalesCreditMemoEDocumentAttachedAfterExport()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        DigVouchersDisableEnforce: Codeunit "Dig. Vouchers Disable Enforce";
        DocNo: Code[20];
    begin
        // [FEATURE] [Digital Voucher] [E-Document]
        // [SCENARIO] Sales credit memo e-document export creates incoming attachment with Is E-Document = true
        Initialize();
        BindSubscription(DigVouchersDisableEnforce);
        EnableDigitalVoucherFeature();

        // [GIVEN] Digital voucher entry setup for sales document is "E-Document"
        InitSetupEDocument("Digital Voucher Entry Type"::"Sales Document");

        // [WHEN] Posted sales credit memo
        DocNo := CreateSalesDocumentWithEDocRequirements(SalesHeader, "Sales Document Type"::"Credit Memo");
        SalesCrMemoHeader.Get(DocNo);

        // [THEN] Incoming attachment exists with "Is E-Document" = true
        AssertEDocumentIncomingAttachmentExists(SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."No.");

        UnbindSubscription(DigVouchersDisableEnforce);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"E-Doc. Attachment Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"E-Doc. Attachment Tests");

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"E-Doc. Attachment Tests");
    end;

    local procedure EnableDigitalVoucherFeature()
    var
        DigitalVoucherSetup: Record "Digital Voucher Setup";
    begin
        if DigitalVoucherSetup.Get() then
            DigitalVoucherSetup.Delete(false);
        DigitalVoucherSetup.Enabled := true;
        DigitalVoucherSetup.Insert(false);
    end;

    local procedure InitSetupEDocument(EntryType: Enum "Digital Voucher Entry Type")
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        DigitalVoucherEntrySetup.SetRange("Entry Type", EntryType);
        DigitalVoucherEntrySetup.DeleteAll(false);
        DigitalVoucherEntrySetup."Entry Type" := EntryType;
        DigitalVoucherEntrySetup.Validate("Check Type", DigitalVoucherEntrySetup."Check Type"::"E-Document");
        DigitalVoucherEntrySetup.Insert(false);
    end;

    local procedure CreatePurchaseDocumentWithEDocument(var PurchaseHeader: Record "Purchase Header"; var EDocument: Record "E-Document"; DocumentType: Enum "Purchase Document Type")
    var
        EDocumentService: Record "E-Document Service";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocLogHelper: Codeunit "E-Document Log Helper";
        OutStream: OutStream;
        EDocType: Enum "E-Document Type";
        XmlRootTag: Text;
        FileName: Text;
    begin
        case DocumentType of
            "Purchase Document Type"::Invoice:
                begin
                    EDocType := EDocType::"Purchase Invoice";
                    XmlRootTag := 'Invoice';
                    FileName := 'test-invoice.xml';
                end;
            "Purchase Document Type"::"Credit Memo":
                begin
                    EDocType := EDocType::"Purchase Credit Memo";
                    XmlRootTag := 'CreditNote';
                    FileName := 'test-credit-memo.xml';
                end;
        end;

        CreateService(EDocumentService);

        EDocDataStorage.Init();
        EDocDataStorage."File Format" := EDocDataStorage."File Format"::XML;
        EDocDataStorage."Data Storage".CreateOutStream(OutStream);
        OutStream.WriteText(StrSubstNo('<?xml version="1.0"?><%1><ID>%2</ID></%1>', XmlRootTag, PurchaseHeader."No."));
        EDocDataStorage.Insert(true);

        EDocument.Init();
        EDocument.Service := EDocumentService.Code;
        EDocument.Direction := EDocument.Direction::Incoming;
        EDocument."Document Type" := EDocType;
        EDocument."Unstructured Data Entry No." := EDocDataStorage."Entry No.";
        EDocument."File Name" := FileName;
        EDocument.Insert(true);
        EDocLogHelper.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::Created);
        CreatePurchaseDocument(PurchaseHeader, DocumentType, EDocument);
    end;

    local procedure AssertEDocumentIncomingAttachmentExists(PostingDate: Date; DocNo: Code[20])
    var
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        NoIncomingDocumentTxt: Label 'No incoming document found for %1 on %2', Comment = '%1 = Document No., %2 = Posting Date';
    begin
        Assert.IsTrue(
            IncomingDocument.FindByDocumentNoAndPostingDate(IncomingDocument, DocNo, Format(PostingDate)),
            StrSubstNo(NoIncomingDocumentTxt, DocNo, PostingDate));

        IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        IncomingDocumentAttachment.SetRange("Is E-Document", true);

        Assert.RecordIsNotEmpty(IncomingDocumentAttachment);
    end;

    local procedure CreateSalesDocumentWithEDocRequirements(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type"): Code[20]
    var
        Customer: Record Customer;
        PostCode: Record "Post Code";
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomerAddress(Customer);
        Customer.Validate(GLN, '1234567890128');
        Customer.Modify(false);

        case DocumentType of
            "Sales Document Type"::Invoice:
                LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");
            "Sales Document Type"::"Credit Memo":
                LibrarySales.CreateSalesCreditMemoForCustomerNo(SalesHeader, Customer."No.");
        end;

        SalesHeader.Validate("Bill-to Address", LibraryRandom.RandText(MaxStrLen(SalesHeader."Bill-to Address")));
        LibraryERM.CreatePostCode(PostCode);
        SalesHeader.Validate("Bill-to Post Code", PostCode.Code);
        SalesHeader.Validate("Your Reference", LibraryRandom.RandText(MaxStrLen(SalesHeader."Your Reference")));

        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateService(var EDocService: Record "E-Document Service")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        EDocService.Init();
        EDocService.Code := LibraryUtility.GenerateRandomCode20(EDocService.FieldNo(Code), Database::"E-Document Service");
        EDocService.Insert(false);
    end;

    local procedure CreatePurchaseDocument(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; var EDocument: Record "E-Document")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item,
            LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(10));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));
        PurchaseLine.Modify(true);
        PurchaseHeader.CalcFields(Amount, "Amount Including VAT");
        PurchaseHeader.Validate("Doc. Amount Incl. VAT", PurchaseHeader."Amount Including VAT");
        PurchaseHeader.Validate("E-Document Link", EDocument.SystemId);
        PurchaseHeader.Modify(false);
        if EDocument."Entry No" <> 0 then begin
            EDocument."Document No." := PurchaseHeader."No.";
            EDocument."Posting Date" := PurchaseHeader."Posting Date";
            EDocument."Document Record ID" := PurchaseHeader.RecordId();
            EDocument.Modify(false);
        end;
    end;
}
