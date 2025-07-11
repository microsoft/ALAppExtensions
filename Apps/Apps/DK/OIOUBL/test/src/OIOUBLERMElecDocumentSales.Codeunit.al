// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148053 "OIOUBL-ERM Elec Document Sales"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun();
    begin
        // [FEATURE] [OIOUBL]
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryXMLReadOnServer: Codeunit "Library - XML Read OnServer";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        LibraryUtility: Codeunit "Library - Utility";
        OIOUBLNewFileMock: Codeunit "OIOUBL-File Events Mock";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        AmountErr: Label '%1 must be %2 in %3.', Comment = '%1 = Amount Field Caption; %2 = Amount Value; %3 = GL Entry Table Caption';
        GLNNoTxt: Label '3974567891234';
        IDTxt: Label 'cbc:ID';
        AccountingCostCodeTxt: Label 'cbc:AccountingCostCode';
        TaxAmountTxt: Label 'cbc:TaxExclusiveAmount';
        DefaultProfileIDTxt: Label 'Procurement-BilSim-1.0';
        WrongAllowanceChargeErr: Label 'Wrong value of "AllowanceCharge".';
        DefaultCodeTxt: Label 'DEFAULT', Comment = 'Translate as we translate default term in local languages';
        OIOUBLFormatNameTxt: Label 'OIOUBL';
        PEPPOLFormatNameTxt: Label 'PEPPOL BIS 3.0';
        WrongInvoiceLineCountErr: Label 'Wrong count of "InvoiceLine".';
        BaseQuantityTxt: Label 'cbc:BaseQuantity';
        NonExistingDocumentFormatErr: Label 'The electronic document format OIOUBL does not exist for the document type %1.', Comment = '%1 = Sales Invoice';
        WrongFileNameErr: Label 'File name should be: %1', Comment = '%1 - Client File Name';
        isInitialized: Boolean;
        CountryRegionCodeLbl: Label 'DK';
        VATRegNoLbl: Label 'DK12345678';
        GLNLbl: Label '4701234560006';
        ErrorMustMatchErr: Label 'Error must match.';
        CountryRegionErr: Label 'Country/Region Code must have a value in Country/Region: Code=DK.';

    [Test]
    procedure GLEntryAfterPostSalesInvoice();
    var
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // Verify the GL Entry created after posting Sales Invoice.
        Initialize();
        DocumentNo := CreateAndPostSalesDocument(SalesLine, SalesLine."Document Type"::Invoice);

        // Verify.
        VerifyGLEntry(DocumentNo, -SalesLine.Amount);
    end;

    [Test]
    procedure GLEntryAfterPostSalesCreditMemo();
    var
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // Verify the GL Entry created after posting Sales Credit Memo.
        Initialize();
        DocumentNo := CreateAndPostSalesDocument(SalesLine, SalesLine."Document Type"::"Credit Memo");

        // Verify.
        VerifyGLEntry(DocumentNo, SalesLine.Amount);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateAndPostSalesInvoiceWithSingleLine();
    var
        SalesLine: Record "Sales Line";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice with Single Line.
        CreateAndPostSalesDocumentWithSingleLine(SalesLine."Document Type"::Invoice, REPORT::"OIOUBL-Create Elec. Invoices");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateAndPostSalesCreditMemoWithSingleLine();
    var
        SalesLine: Record "Sales Line";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Single Line.
        CreateAndPostSalesDocumentWithSingleLine(SalesLine."Document Type"::"Credit Memo", REPORT::"OIOUBL-Create Elec. Cr. Memos");
    end;

    local procedure CreateAndPostSalesDocumentWithSingleLine(DocumentType: Enum "Sales Line Type"; ReportID: Integer);
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
        TaxAmount: Decimal;
    begin
        // [GIVEN] Posted Sales Document with a single line.
        Initialize();
        CreateSalesDocumentWithItem(SalesLine, DocumentType);
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        TaxAmount := (SalesLine."Line Amount" * SalesLine."VAT %") / 100;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Electronic Invoice or Credit Memo created.
        RunReport(ReportID, DocumentNo);

        // [THEN] The following values are verified on generated xml file of Electronic Invoice or Credit Memo: Sales Document No., Tax Amount, BaseQuantity.
        VerifyDocumentNoAndTaxAmount(DocumentNo, TaxAmount);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicSalesCreditMemoWithMultipleGL();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Multiple GL and different VAT type and %.
        CreateAndPostSalesDocumentWithMultipleGL(SalesHeader."Document Type"::"Credit Memo", REPORT::"OIOUBL-Create Elec. Cr. Memos");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicSalesInvoiceWithMultipleGL();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice with Multiple GL and different VAT type and %.
        CreateAndPostSalesDocumentWithMultipleGL(SalesHeader."Document Type"::Invoice, REPORT::"OIOUBL-Create Elec. Invoices");
    end;

    local procedure CreateAndPostSalesDocumentWithMultipleGL(DocumentType: Enum "Sales Document Type"; ReportID: Integer);
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        DocumentNo: Code[20];
        TaxAmount: Decimal;
    begin
        // [GIVEN] Posted Sales Document with a multiple GL and different VAT type and %.
        Initialize();
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", CreateGLAccount(FindNormalVAT()));
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", CreateGLAccount(FindZeroVAT()));
        CreateSalesLine(
            SalesLine, SalesHeader, SalesLine.Type::"G/L Account",
            CreateGLAccount(FindReverseChargeVAT(VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT")));
        TaxAmount := CalculateTaxAmount(SalesHeader);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Electronic Invoice or Credit Memo created.
        RunReport(ReportID, DocumentNo);

        // [THEN] The following values are verified on generated xml file of Electronic Invoice or Credit Memo: Sales Document No., Tax Amount, BaseQuantity.
        VerifyDocumentNoAndTaxAmount(DocumentNo, TaxAmount);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicSalesCreditMemoMultipleItemsChargeItemAndGL();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Multiple Item,Charge Item and GL.
        CreateAndPostSalesDocumentMultipleItemsChargeItemAndGL(
        SalesHeader."Document Type"::"Credit Memo", REPORT::"OIOUBL-Create Elec. Cr. Memos");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicSalesInvoiceMultipleItemsChargeItemAndGL();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice with Multiple Item,Charge Item and GL.
        CreateAndPostSalesDocumentMultipleItemsChargeItemAndGL(
        SalesHeader."Document Type"::Invoice, REPORT::"OIOUBL-Create Elec. Invoices");
    end;

    local procedure CreateAndPostSalesDocumentMultipleItemsChargeItemAndGL(DocumentType: Enum "Sales Document Type"; ReportID: Integer);
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        UnitOfMeasure: Record "Unit of Measure";
        DocumentNo: Code[20];
        TaxAmount: Decimal;
    begin
        // [GIVEN] Posted Sales Document with a multiple Item, Charge Item and GL.
        Initialize();
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo());
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo());
        LibrarySales.CreateSalesLine(
            SalesLine, SalesHeader, SalesLine.Type::"Charge (Item)",
            LibraryInventory.CreateItemChargeNo(), LibraryRandom.RandDec(10, 2));  // Random Value for Quantity.
        SalesLine.VALIDATE("Unit of Measure", UnitOfMeasure.Code);
        SalesLine.VALIDATE("Unit Price", LibraryRandom.RandDec(100, 2));  // Random Value for Unit Price.
        SalesLine.MODIFY(true);
        LibraryInventory.CreateItemChargeAssignment(
            ItemChargeAssignmentSales, SalesLine,
            SalesLine."Document Type"::Invoice, SalesLine."Document No.", SalesLine."Line No.", SalesLine."No.");
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", CreateGLAccount(FindNormalVAT()));
        TaxAmount := CalculateTaxAmount(SalesHeader);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Electronic Invoice or Credit Memo created.
        RunReport(ReportID, DocumentNo);

        // [THEN] The following values are verified on generated xml file of Electronic Invoice or Credit Memo: Sales Document No., Tax Amount, BaseQuantity.
        VerifyDocumentNoAndTaxAmount(DocumentNo, TaxAmount);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicSalesCreditMemoSalesLineTypeBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Line Type Blank.
        CreateAndPostSalesDocumentSalesLineTypeBlank(
          SalesHeader."Document Type"::"Credit Memo", REPORT::"OIOUBL-Create Elec. Cr. Memos", FindStandardText(), '');  // Use Blank for Descrption.
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicSalesInvoiceSalesLineTypeBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice Sales Line Type Blank.
        CreateAndPostSalesDocumentSalesLineTypeBlank(
          SalesHeader."Document Type"::Invoice, REPORT::"OIOUBL-Create Elec. Invoices", FindStandardText(), '');  // Use Blank for Descrption.
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicSalesCreditMemoSalesLineNoBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Line No. Blank.
        CreateAndPostSalesDocumentSalesLineTypeBlank(
          SalesHeader."Document Type"::"Credit Memo", REPORT::"OIOUBL-Create Elec. Cr. Memos", '', 'Follow the Items Below');  // Use Blank for Sales Line No.
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicSalesInvoiceSalesLineNoBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice Sales Line No. Blank.
        CreateAndPostSalesDocumentSalesLineTypeBlank(
        SalesHeader."Document Type"::Invoice, REPORT::"OIOUBL-Create Elec. Invoices", '', 'Follow the Items Below');  // Use Blank for Sales Line No.
    end;

    local procedure CreateAndPostSalesDocumentSalesLineTypeBlank(DocumentType: Enum "Sales Document Type"; ReportID: Integer;
                                                                                   LineNo: Code[20];
                                                                                   Descrption: Text[50]);
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentSendingProfile: Record "Document Sending Profile";
        DocumentNo: Code[20];
        TaxAmount: Decimal;
    begin
        Initialize();
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [GIVEN] Created and Posted Sales Document Sales Line Type Blank
        CreateSalesDocumentWithItem(SalesLine, DocumentType);
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        CreateSalesLineWithBlankLines(
        SalesLine."Line No.", DocumentType, SalesHeader."No.", LineNo, Descrption);  // Use Blank for Descrption.
        TaxAmount := CalculateTaxAmount(SalesHeader);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Electronic Invoice or Credit Memo created.
        RunReport(ReportID, DocumentNo);

        // [THEN] The following values are verified on generated xml file of Electronic Invoice or Credit Memo: Sales Document No., Tax Amount, BaseQuantity.
        VerifyDocumentNoAndTaxAmount(DocumentNo, TaxAmount);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicSalesCreditMemoSalesLineTypeAndNoBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Type and Line No. Blank.
        CreateAndPostSalesDocumentSalesLineTypeAndNoBlank(
        SalesHeader."Document Type"::"Credit Memo", REPORT::"OIOUBL-Create Elec. Cr. Memos");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicSalesInvoiceSalesLineTypeAndNoBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice with Type and Line No. Blank.
        CreateAndPostSalesDocumentSalesLineTypeAndNoBlank(SalesHeader."Document Type"::Invoice, REPORT::"OIOUBL-Create Elec. Invoices");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckAllowanceChargeInOIOUBLReport();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
        ExpectedResult: Decimal;
    begin
        // [SCENARIO 377873] OIOUBL XML File shouldn't contain XML node "LegalMonetaryTotal/AllowanceTotalAmount" and should contain XML node "InvoiceLine/AllowanceCharge" with line discount
        // [SCENARIO 280609] CurrencyID attribute has value of "LCY Code" of General Ledger Setup in exported OIOUBL file
        Initialize();

        // [GIVEN] "LCY Code" is "DKK" in "General Ledger Setup"
        // [GIVEN] Posted sales invoice with two sales lines
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice);

        // [GIVEN] First sales line with line discount = "X"
        CreateSalesLineWithDiscount(SalesLine, SalesHeader, LibraryRandom.RandIntInRange(1, 50));
        ExpectedResult := SalesLine."Inv. Discount Amount" + SalesLine."Line Discount Amount";

        // [GIVEN] Second sales line without line discount
        CreateSalesLineWithDiscount(SalesLine, SalesHeader, 0);

        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Run report "OIOUBL-Create Elec. Invoices"
        RunReportCreateElecSalesInvoices(DocumentNo);

        // [THEN] OIOUBL XML file does not contain XML node "LegalMonetaryTotal/AllowanceTotalAmount"
        // [THEN] Contains XML node "InvoiceLine/cac:AllowanceCharge/cbc:Amount" with value = "X" for first invoice line
        // [THEN] Doesn't contain XML node "InvoiceLine/cac:AllowanceCharge" for second invoice line
        // [THEN] CurrencyID attribute is "DKK" in exported file
        VerifyAllowanceCharge(DocumentNo, ExpectedResult);
    end;

    [Test]
    [HandlerFunctions('PostandSendModalPageHandler')]
    procedure PostAndSendSalesInvoiceOIOUBL();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        InteractionLogEntry: Record "Interaction Log Entry";
        SalesInvoice: TestPage "Sales Invoice";
    begin
        // [SCENARIO 378908] Post And Send Sales Invoice to Disk = Electronic Document (OIOUBL) should create electronic document
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Invoice", CODEUNIT::"OIOUBL-Export Sales Invoice");

        // [GIVEN] Default DocumentSendingProfile Disk::"Electronic Document"; Sales Invoice;
        CreateSalesDocumentWithItem(SalesLine, SalesHeader."Document Type"::Invoice);
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [WHEN] PostAndSend to Disk = Electronic Document.
        SalesInvoice.OPENEDIT();
        SalesInvoice.Filter.SetFilter("No.", SalesHeader."No.");
        SalesInvoice.PostAndSend.INVOKE();

        // [THEN] Sales Invoice is posted.
        // [THEN] OIOUBL Electronic Document is created at the location, specified in Sales Setup.
        // [THEN] "No. Printed" value of Posted Sales Invoice increases by 1. Bug ID 349569.
        FindSalesInvoiceHeader(SalesInvoiceHeader, SalesHeader."No.");
        SalesInvoiceHeader.TESTFIELD("OIOUBL-Electronic Invoice Created", true);
        SalesInvoiceHeader.TestField("No. Printed", 1);
        VerifyElectronicSalesDocument(SalesInvoiceHeader."No.", SalesInvoiceHeader."OIOUBL-Account Code");
        VerifyInteractionLogEntry(InteractionLogEntry."Document Type"::"Sales Inv.", SalesInvoiceHeader."No.");
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsOKModalPageHandler')]
    procedure SendPostedSalesInvoiceOIOUBL();
    var
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        InteractionLogEntry: Record "Interaction Log Entry";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 378908] Send Posted Sales Invoice to Disk = Electronic Document (OIOUBL) should create electronic document.
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Invoice", CODEUNIT::"OIOUBL-Export Sales Invoice");

        // [GIVEN] DefaultDocumentSendingProfile Disk::"Electronic Document", Format = OIOUBL; Posted Sales Invoice;
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        PostedDocNo := CreateAndPostSalesDocument(SalesLine, SalesLine."Document Type"::Invoice);

        // [WHEN] Run "Send" for Posted Sales Invoice.
        SalesInvoiceHeader.SetRange("No.", PostedDocNo);
        SalesInvoiceHeader.SendRecords();

        // [THEN] OIOUBL Electronic Document is created at the location, specified in Sales Setup.
        // [THEN] "No. Printed" value of Posted Sales Invoice increases by 1. Bug ID 349569.
        SalesInvoiceHeader.Get(PostedDocNo);
        SalesInvoiceHeader.TESTFIELD("OIOUBL-Electronic Invoice Created", true);
        SalesInvoiceHeader.TestField("No. Printed", 1);
        VerifyElectronicSalesDocument(SalesInvoiceHeader."No.", SalesInvoiceHeader."OIOUBL-Account Code");
        VerifyInteractionLogEntry(InteractionLogEntry."Document Type"::"Sales Inv.", SalesInvoiceHeader."No.");
    end;

    [Test]
    [HandlerFunctions('ProfileSelectionMethodStrMenuHandler')]
    procedure SendMultiplePostedSalesInvoicesOIOUBL();
    var
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        InteractionLogEntry: Record "Interaction Log Entry";
        PostedDocNoLst: List of [Code[20]];
        AccountCodeLst: List of [Text[30]];
        PostedDocNoFilter: Text;
        PostedDocNo: Code[20];
    begin
        // [FEATURE] [Zip]
        // [SCENARIO 318500] Send multiple Posted Sales Invoices to Disk = Electronic Document (OIOUBL).
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Invoice", CODEUNIT::"OIOUBL-Export Sales Invoice");

        // [GIVEN] Default DocumentSendingProfile Disk::"Electronic Document", Format = OIOUBL; three Posted Sales Invoices;
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        CreateMultiplePostedSalesDocuments(PostedDocNoLst, PostedDocNoFilter, SalesLine."Document Type"::Invoice, 3);

        // [WHEN] Run "Send" for these Posted Sales Invoices.
        SalesInvoiceHeader.SetFilter("No.", PostedDocNoFilter);
        SalesInvoiceHeader.SendRecords();

        // [THEN] One ZIP file is created at the location, specified in Sales Setup.
        // [THEN] ZIP file contains OIOUBL Electronic Document for each Posted Sales Invoice.
        foreach PostedDocNo in PostedDocNoLst do begin
            SalesInvoiceHeader.Get(PostedDocNo);
            SalesInvoiceHeader.TESTFIELD("OIOUBL-Electronic Invoice Created", true);
            VerifyInteractionLogEntry(InteractionLogEntry."Document Type"::"Sales Inv.", SalesInvoiceHeader."No.");
            AccountCodeLst.Add(SalesInvoiceHeader."OIOUBL-Account Code");
        end;
        VerifyElectronicSalesDocumentInZipArchive(PostedDocNoLst, AccountCodeLst);
    end;

    [Test]
    [HandlerFunctions('PostandSendModalPageHandler')]
    procedure PostAndSendSalesInvoiceNonOIOUBL();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        SalesInvoice: TestPage "Sales Invoice";
    begin
        // [SCENARIO 299031] Post and Send Sales Invoice in case non-OIOUBL profile is selected.
        Initialize();
        UpdateCompanySwiftCode();
        CreateElectronicDocumentFormat(
          PEPPOLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Invoice", CODEUNIT::"Exp. Sales Inv. PEPPOL BIS3.0");

        // [GIVEN] Document Sending Profile = PEPPOL; Sales Invoice.
        CreateSalesDocumentWithItem(SalesLine, SalesHeader."Document Type"::Invoice);
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", PEPPOLFormatNameTxt);

        // [WHEN] Post And Send to Disk = Electronic Document.
        SalesInvoice.OPENEDIT();
        SalesInvoice.Filter.SetFilter("No.", SalesHeader."No.");
        SalesInvoice.PostAndSend.INVOKE();

        // [THEN] Sales Invoice is posted.
        // [THEN] Electronic Document is not created at the location, specified in Sales Setup - file path is not in the queue.
        FindSalesInvoiceHeader(SalesInvoiceHeader, SalesHeader."No.");
        SalesInvoiceHeader.TESTFIELD("OIOUBL-Electronic Invoice Created", false);
    end;

    [Test]
    [HandlerFunctions('PostandSendModalPageHandler')]
    procedure PostAndSendSalesInvoiceDiskIsNotElectronicDocument();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        SalesInvoice: TestPage "Sales Invoice";
    begin
        // [SCENARIO 299031] Post and Send Sales Invoice in case Disk = No in Document Sending Profile.
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Invoice", CODEUNIT::"OIOUBL-Export Sales Invoice");

        // [GIVEN] Document Sending Profile = OIOUBL, Disk = No; Sales Invoice.
        CreateSalesDocumentWithItem(SalesLine, SalesHeader."Document Type"::Invoice);
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::No, OIOUBLFormatNameTxt);

        // [WHEN] Post And Send.
        SalesInvoice.OPENEDIT();
        SalesInvoice.Filter.SetFilter("No.", SalesHeader."No.");
        SalesInvoice.PostAndSend.INVOKE();

        // [THEN] Sales Invoice is posted.
        // [THEN] Electronic Document is not created at the location, specified in Sales Setup - file path is not in the queue.
        FindSalesInvoiceHeader(SalesInvoiceHeader, SalesHeader."No.");
        SalesInvoiceHeader.TESTFIELD("OIOUBL-Electronic Invoice Created", false);
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsOKModalPageHandler')]
    procedure SendPostedSalesInvoiceOIOUBLWithNonStandardCodeunit();
    var
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNo: Code[20];
        NonExistingCodeunitID: Integer;
    begin
        // [SCENARIO 327540] Send Posted Sales Invoice to OIOUBL in case Electronic Document Format has non-standard "Codeunit ID".
        Initialize();

        // [GIVEN] Electronic Document Format OIOUBL for Sales Invoice with nonexisting "Codeunit ID" = "C".
        NonExistingCodeunitID := GetNonExistingCodeunitID();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Invoice", NonExistingCodeunitID);

        // [GIVEN] DefaultDocumentSendingProfile Disk::"Electronic Document", Format = OIOUBL; Posted Sales Invoice;
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        PostedDocNo := CreateAndPostSalesDocument(SalesLine, SalesLine."Document Type"::Invoice);

        // [WHEN] Run "Send" for Posted Sales Invoice.
        SalesInvoiceHeader.SetRange("No.", PostedDocNo);
        asserterror SalesInvoiceHeader.SendRecords();

        // [THEN] OIOUBL Electronic Document is not created. Codeunit "C" is run via Codeunit.Run.
        SalesInvoiceHeader.Get(PostedDocNo);
        SalesInvoiceHeader.TESTFIELD("OIOUBL-Electronic Invoice Created", false);
        // The codeunit id must be part of the error text.
        Assert.ExpectedError(format(NonExistingCodeunitID));
    end;

    [Test]
    [HandlerFunctions('PostandSendModalPageHandler')]
    procedure PostAndSendSalesCreditMemoOIOUBL();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        InteractionLogEntry: Record "Interaction Log Entry";
        SalesCreditMemo: TestPage "Sales Credit Memo";
    begin
        // [SCENARIO 378908] Post And Send Sales Credit Memo to Disk = Electronic Document (OIOUBL) should create electronic document
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Credit Memo", CODEUNIT::"OIOUBL-Export Sales Cr. Memo");

        // [GIVEN] DefaultDocumentSendingProfile Disk::"Electronic Document"; Sales Credit Memo;
        CreateSalesDocumentWithItem(SalesLine, SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [WHEN] PostAndSend to Disk = Electronic Document.
        SalesCreditMemo.OPENEDIT();
        SalesCreditMemo.Filter.SetFilter("No.", SalesHeader."No.");
        SalesCreditMemo.PostAndSend.INVOKE();

        // [THEN] Sales Credit Memo is posted.
        // [THEN] OIOUBL Electronic Document is created at the location, specified in Sales Setup.
        // [THEN] "No. Printed" value of Posted Sales Credit Memo increases by 1. Bug ID 349569.
        FindSalesCrMemoHeader(SalesCrMemoHeader, SalesHeader."No.");
        SalesCrMemoHeader.TESTFIELD("OIOUBL-Electronic Credit Memo Created", true);
        SalesCrMemoHeader.TestField("No. Printed", 1);
        VerifyElectronicSalesDocument(SalesCrMemoHeader."No.", SalesCrMemoHeader."OIOUBL-Account Code");
        VerifyInteractionLogEntry(InteractionLogEntry."Document Type"::"Sales Cr. Memo", SalesCrMemoHeader."No.");
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsOKModalPageHandler')]
    procedure SendPostedSalesCreditMemoOIOUBL();
    var
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        InteractionLogEntry: Record "Interaction Log Entry";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 378908] Send Posted Sales Credit Memo to Disk = Electronic Document (OIOUBL) should create electronic document.
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Credit Memo", CODEUNIT::"OIOUBL-Export Sales Cr. Memo");

        // [GIVEN] DefaultDocumentSendingProfile Disk::"Electronic Document", Format = OIOUBL; Posted Sales Credit Memo;
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        PostedDocNo := CreateAndPostSalesDocument(SalesLine, SalesLine."Document Type"::"Credit Memo");

        // [WHEN] Run "Send" for Posted Sales Credit Memo.
        SalesCrMemoHeader.SetRange("No.", PostedDocNo);
        SalesCrMemoHeader.SendRecords();

        // [THEN] OIOUBL Electronic Document is created at the location, specified in Sales Setup.
        // [THEN] "No. Printed" value of Posted Sales Credit Memo increases by 1. Bug ID 349569.
        SalesCrMemoHeader.Get(PostedDocNo);
        SalesCrMemoHeader.TESTFIELD("OIOUBL-Electronic Credit Memo Created", true);
        SalesCrMemoHeader.TestField("No. Printed", 1);
        VerifyElectronicSalesDocument(SalesCrMemoHeader."No.", SalesCrMemoHeader."OIOUBL-Account Code");
        VerifyInteractionLogEntry(InteractionLogEntry."Document Type"::"Sales Cr. Memo", SalesCrMemoHeader."No.");
    end;

    [Test]
    [HandlerFunctions('ProfileSelectionMethodStrMenuHandler')]
    procedure SendMultiplePostedSalesCreditMemosOIOUBL();
    var
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        InteractionLogEntry: Record "Interaction Log Entry";
        PostedDocNoLst: List of [Code[20]];
        AccountCodeLst: List of [Text[30]];
        PostedDocNoFilter: Text;
        PostedDocNo: Code[20];
    begin
        // [FEATURE] [Zip]
        // [SCENARIO 318500] Send multiple Posted Sales Credit Memo to Disk = Electronic Document (OIOUBL).
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Credit Memo", CODEUNIT::"OIOUBL-Export Sales Cr. Memo");

        // [GIVEN] DefaultDocumentSendingProfile Disk::"Electronic Document", Format = OIOUBL; three Posted Sales Credit Memos.
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        CreateMultiplePostedSalesDocuments(PostedDocNoLst, PostedDocNoFilter, SalesLine."Document Type"::"Credit Memo", 3);

        // [WHEN] Run "Send" for these Posted Sales Credit Memos.
        SalesCrMemoHeader.SetFilter("No.", PostedDocNoFilter);
        SalesCrMemoHeader.SendRecords();

        // [THEN] One ZIP file is created at the location, specified in Sales Setup.
        // [THEN] ZIP file contains OIOUBL Electronic Document for each Posted Sales Credit Memo.
        foreach PostedDocNo in PostedDocNoLst do begin
            SalesCrMemoHeader.Get(PostedDocNo);
            SalesCrMemoHeader.TESTFIELD("OIOUBL-Electronic Credit Memo Created", true);
            VerifyInteractionLogEntry(InteractionLogEntry."Document Type"::"Sales Cr. Memo", SalesCrMemoHeader."No.");
            AccountCodeLst.Add(SalesCrMemoHeader."OIOUBL-Account Code");
        end;
        VerifyElectronicSalesDocumentInZipArchive(PostedDocNoLst, AccountCodeLst);
    end;

    [Test]
    [HandlerFunctions('PostandSendModalPageHandler')]
    procedure PostAndSendSalesCreditMemoNonOIOUBL();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        SalesCreditMemo: TestPage "Sales Credit Memo";
    begin
        // [SCENARIO 299031] Post and Send Service Credit Memo in case non-OIOUBL profile is selected.
        Initialize();
        UpdateCompanySwiftCode();
        CreateElectronicDocumentFormat(
          PEPPOLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Credit Memo", CODEUNIT::"Exp. Sales CrM. PEPPOL BIS3.0");

        // [GIVEN] Document Sending Profile = PEPPOL; Sales Credit Memo.
        CreateSalesDocumentWithItem(SalesLine, SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", PEPPOLFormatNameTxt);

        // [WHEN] PostAndSend to Disk = Electronic Document.
        SalesCreditMemo.OPENEDIT();
        SalesCreditMemo.Filter.SetFilter("No.", SalesHeader."No.");
        SalesCreditMemo.PostAndSend.INVOKE();

        // [THEN] Sales Credit Memo is posted.
        // [THEN] Electronic Document is created at the location, specified in Sales Setup - file path is not in the queue.
        FindSalesCrMemoHeader(SalesCrMemoHeader, SalesHeader."No.");
        SalesCrMemoHeader.TESTFIELD("OIOUBL-Electronic Credit Memo Created", false);
    end;

    [Test]
    [HandlerFunctions('PostandSendModalPageHandler')]
    procedure PostAndSendSalesCreditMemoDiskIsNotElectronicDocument();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        SalesCreditMemo: TestPage "Sales Credit Memo";
    begin
        // [SCENARIO 299031] Post and Send Service Credit Memo in case Disk = No in Document Sending Profile.
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Credit Memo", CODEUNIT::"OIOUBL-Export Sales Cr. Memo");

        // [GIVEN] Document Sending Profile = OIOUBL, Disk = No; Sales Credit Memo.
        CreateSalesDocumentWithItem(SalesLine, SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::No, OIOUBLFormatNameTxt);

        // [WHEN] Post And Send.
        SalesCreditMemo.OPENEDIT();
        SalesCreditMemo.Filter.SetFilter("No.", SalesHeader."No.");
        SalesCreditMemo.PostAndSend.INVOKE();

        // [THEN] Sales Credit Memo is posted.
        // [THEN] Electronic Document is not created at the location, specified in Sales Setup - file path is not in the queue.
        FindSalesCrMemoHeader(SalesCrMemoHeader, SalesHeader."No.");
        SalesCrMemoHeader.TESTFIELD("OIOUBL-Electronic Credit Memo Created", false);
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsOKModalPageHandler')]
    procedure SendPostedSalesCreditMemoOIOUBLWithNonStandardCodeunit();
    var
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNo: Code[20];
        NonExistingCodeunitID: Integer;
    begin
        // [SCENARIO 327540] Send Posted Sales Credit Memo to OIOUBL in case Electronic Document Format has non-standard "Codeunit ID".
        Initialize();

        // [GIVEN] Electronic Document Format OIOUBL for Sales Credit Memo with nonexisting "Codeunit ID" = "C".
        NonExistingCodeunitID := GetNonExistingCodeunitID();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Credit Memo", NonExistingCodeunitID);

        // [GIVEN] DefaultDocumentSendingProfile Disk::"Electronic Document", Format = OIOUBL; Posted Sales Credit Memo;
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        PostedDocNo := CreateAndPostSalesDocument(SalesLine, SalesLine."Document Type"::"Credit Memo");

        // [WHEN] Run "Send" for Posted Sales Credit Memo.
        SalesCrMemoHeader.SetRange("No.", PostedDocNo);
        asserterror SalesCrMemoHeader.SendRecords();

        // [THEN] OIOUBL Electronic Document is not created. Codeunit "C" is run via Codeunit.Run.
        SalesCrMemoHeader.Get(PostedDocNo);
        SalesCrMemoHeader.TESTFIELD("OIOUBL-Electronic Credit Memo Created", false);
        // The codeunit id must be part of the error text.
        Assert.ExpectedError(format(NonExistingCodeunitID));
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsOKModalPageHandler')]
    procedure SendPostedSalesDocumentOIOUBLWithoutElectronicDocFormat();
    var
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 327540] Send Posted Sales Invoice to OIOUBL in case Electronic Document Format does not exist.
        Initialize();

        // [GIVEN] Electronic Document Format OIOUBL for Sales Invoice does not exist.
        ElectronicDocumentFormat.SetFilter(Code, OIOUBLFormatNameTxt);
        ElectronicDocumentFormat.SetRange(Usage, ElectronicDocumentFormat.Usage::"Sales Invoice");
        ElectronicDocumentFormat.DeleteAll();

        // [GIVEN] DefaultDocumentSendingProfile Disk::"Electronic Document", Format = OIOUBL; Posted Sales Invoice;
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        PostedDocNo := CreateAndPostSalesDocument(SalesLine, SalesLine."Document Type"::Invoice);

        // [WHEN] Run "Send" for Posted Sales Invoice.
        SalesInvoiceHeader.SetRange("No.", PostedDocNo);
        asserterror SalesInvoiceHeader.SendRecords();

        // [THEN] OIOUBL Electronic Document is not created. An error "The electronic document format OIOUBL does not exist" is thrown.
        SalesInvoiceHeader.Get(PostedDocNo);
        SalesInvoiceHeader.TESTFIELD("OIOUBL-Electronic Invoice Created", false);
        Assert.ExpectedError(StrSubstNo(NonExistingDocumentFormatErr, Format(ElectronicDocumentFormat.Usage::"Sales Invoice")));
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    [HandlerFunctions('PostandSendModalPageHandler,ShipInvoiceQstStrMenuHandler,ErrorMessagesPageHandler')]
    procedure ShipAndSendSalesOrderOIOUBL();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        // [SCENARIO 327540] Post (Ship only) And Send Sales Order to OIOUBL.
        Initialize();

        // [GIVEN] DefaultDocumentSendingProfile Disk::"Electronic Document"; Sales Order;
        CreateSalesDocumentWithItem(SalesLine, SalesHeader."Document Type"::Order);
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [WHEN] Run "Post and Send" for Sales Order. Select "Ship" option for posting.
        LibraryVariableStorage.Enqueue(SalesHeader.RecordId());
        SalesHeader.SendToPosting(Codeunit::"Sales-Post and Send");

        // [THEN] OIOUBL Electronic Document is not created. An error "The Sales Shipment Header table is not supported." is thrown.
        Assert.AreEqual('The Sales Shipment Header table is not supported.', LibraryVariableStorage.DequeueText(), '');
        Assert.AreEqual('Error', LibraryVariableStorage.DequeueText(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('PostandSendModalPageHandler,StandardSalesInvoiceRequestPageHandler,EmailEditorHandler,CloseEmailEditorHandler')]
    procedure PostAndSendSalesInvoiceOIOUBLWithPrintAndEmail();
    begin
        PostAndSendSalesInvoiceOIOUBLWithPrintAndEmailInternal();
    end;

    procedure PostAndSendSalesInvoiceOIOUBLWithPrintAndEmailInternal();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        SalesInvoice: TestPage "Sales Invoice";
    begin
        // [SCENARIO 336642] Post And Send Sales Invoice in case Print, E-Mail - OIOUBL, Disk - OIOUBL are set in Document Sending Profile.
        Initialize();
        MailSetupInitialize();
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Invoice", Codeunit::"OIOUBL-Export Sales Invoice");

        // [GIVEN] DocumentSendingProfile with Printer = Yes; Disk = "Electronic Document", Format = OIOUBL;
        // [GIVEN] E-Mail = Yes, E-Mail Attachment = "Electronic Document", Format = OIOUBL. Sales Invoice.
        CreateDocumentSendingProfile(
            DocumentSendingProfile, DocumentSendingProfile.Printer::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail"::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail Attachment"::"Electronic Document", OIOUBLFormatNameTxt,
            DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        CreateSalesDocumentWithItem(SalesLine, SalesHeader."Document Type"::Invoice);
        SetDocumentSendingProfileToCustomer(SalesLine."Sell-to Customer No.", DocumentSendingProfile.Code);
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");

        // [WHEN] Run "Post And Send" for Sales Invoice.
        SalesInvoice.OpenEdit();
        SalesInvoice.Filter.SetFilter("No.", SalesHeader."No.");
        SalesInvoice.PostAndSend.Invoke();

        // [THEN] Sales Invoice is posted.
        // [THEN] Report "Standard Sales - Invoice" for printing Posted Sales Invoice is invoked. Then Email Editor is opened.
        // [THEN] OIOUBL Electronic Document for Posted Sales Invoice is created.
        // [THEN] "No. Printed" value of Posted Sales Invoice increases by 3 (Print, E-mail, Disk). Bug ID 351595.
        FindSalesInvoiceHeader(SalesInvoiceHeader, SalesHeader."No.");
        SalesInvoiceHeader.TestField("OIOUBL-Electronic Invoice Created", true);
        SalesInvoiceHeader.TestField("No. Printed", 3);
        VerifyElectronicSalesDocument(SalesInvoiceHeader."No.", SalesInvoiceHeader."OIOUBL-Account Code");
    end;

    [Test]
    [HandlerFunctions('PostandSendModalPageHandler,StandardSalesInvoiceRequestPageHandler,EmailEditorHandler,CloseEmailEditorHandler')]
    procedure PostAndSendSalesInvoiceOIOUBLAndPDFWithPrintAndEmail();
    begin
        PostAndSendSalesInvoiceOIOUBLAndPDFWithPrintAndEmailInternal();
    end;

    procedure PostAndSendSalesInvoiceOIOUBLAndPDFWithPrintAndEmailInternal();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        SalesInvoice: TestPage "Sales Invoice";
        FileNameLst: List of [Text];
    begin
        // [FEATURE] [Zip]
        // [SCENARIO 336642] Post And Send Sales Document in case Print, E-Mail - PDF & OIOUBL, Disk - PDF & OIOUBL are set in Document Sending Profile.
        Initialize();
        MailSetupInitialize();
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Invoice", Codeunit::"OIOUBL-Export Sales Invoice");

        // [GIVEN] Default DocumentSendingProfile with Printer = Yes; Disk = "PDF & Electronic Document", Format = OIOUBL;
        // [GIVEN] E-Mail = Yes, E-Mail Attachment = "PDF & Electronic Document", Format = OIOUBL. Sales Invoice.
        SetDefaultDocumentSendingProfile(
            DocumentSendingProfile.Printer::"Yes (Prompt for Settings)", DocumentSendingProfile."E-Mail"::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail Attachment"::"PDF & Electronic Document", OIOUBLFormatNameTxt,
            DocumentSendingProfile.Disk::"PDF & Electronic Document", OIOUBLFormatNameTxt);
        CreateSalesDocumentWithItem(SalesLine, SalesHeader."Document Type"::Invoice);
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");

        // [WHEN] Run "Post And Send" for Sales Invoice.
        SalesInvoice.OpenEdit();
        SalesInvoice.Filter.SetFilter("No.", SalesHeader."No.");
        SalesInvoice.PostAndSend.Invoke();

        // [THEN] Sales Invoice is posted.
        // [THEN] Report "Standard Sales - Invoice" for printing Posted Sales Invoice is invoked. Then Email Editor is opened.
        // [THEN] ZIP file is created, it contains OIOUBL Electronic Document and PDF with printed copy of Posted Sales Invoice.
        FindSalesInvoiceHeader(SalesInvoiceHeader, SalesHeader."No.");
        FileNameLst.AddRange(GetFileName(SalesInvoiceHeader."No.", 'Invoice', 'XML'), GetFileName(SalesInvoiceHeader."No.", 'Sales Invoice', 'PDF'));
        VerifyFileListInZipArchive(FileNameLst);
    end;

    [Test]
    [HandlerFunctions('ProfileSelectionMethodStrMenuHandler,StandardSalesInvoiceRequestPageHandler,EmailEditorHandler')]
    procedure SendPostedSalesInvoiceOIOUBLWithPrintAndEmail();
    begin
        SendPostedSalesInvoiceOIOUBLWithPrintAndEmailInternal();
    end;

    procedure SendPostedSalesInvoiceOIOUBLWithPrintAndEmailInternal()
    var
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNoLst: List of [Code[20]];
        FileNameLst: List of [Text];
        PostedDocNoFilter: Text;
        PostedDocNo: Code[20];
    begin
        // [FEATURE] [Zip]
        // [SCENARIO 336642] Send Posted Sales Document in case Print, E-Mail - OIOUBL, Disk - OIOUBL are set in Document Sending Profile.
        Initialize();
        MailSetupInitialize();
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Invoice", Codeunit::"OIOUBL-Export Sales Invoice");

        // [GIVEN] Default DocumentSendingProfile with Printer = Yes; Disk = "Electronic Document", Format = OIOUBL;
        // [GIVEN] E-Mail = Yes, E-Mail Attachment = "Electronic Document", Format = OIOUBL. Two Posted Sales Invoices.
        CreateDocumentSendingProfile(
            DocumentSendingProfile, DocumentSendingProfile.Printer::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail"::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail Attachment"::"Electronic Document", OIOUBLFormatNameTxt,
            DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        CreateMultiplePostedSalesDocuments(PostedDocNoLst, PostedDocNoFilter, SalesLine."Document Type"::Invoice, 2);
        foreach PostedDocNo in PostedDocNoLst do begin
            SalesInvoiceHeader.Get(PostedDocNo);
            SetDocumentSendingProfileToCustomer(SalesInvoiceHeader."Sell-to Customer No.", DocumentSendingProfile.Code);
        end;

        // [WHEN] Run "Send" for these Posted Sales Invoices.
        SalesInvoiceHeader.SetFilter("No.", PostedDocNoFilter);
        SalesInvoiceHeader.SendRecords();

        // [THEN] Report "Standard Sales - Invoice" for printing Posted Sales Invoice is invoked. Then Email Editor is opened.
        // [THEN] One ZIP file is created, it contains OIOUBL Electronic Document for each Posted Sales Invoice.
        foreach PostedDocNo in PostedDocNoLst do begin
            FileNameLst.Add(GetFileName(PostedDocNo, 'Invoice', 'XML'));
            OIOUBLNewFileMock.PopFilePath(); // dequeue unused XML files names
        end;
        VerifyFileListInZipArchive(FileNameLst);
    end;

    [Test]
    [HandlerFunctions('ProfileSelectionMethodAndCloseEmailStrMenuHandler,StandardSalesInvoiceRequestPageHandler,EmailEditorHandler')]
    procedure SendPostedSalesInvoiceOIOUBLAndPDFWithPrintAndEmail();
    begin
        SendPostedSalesInvoiceOIOUBLAndPDFWithPrintAndEmailInternal();
    end;

    procedure SendPostedSalesInvoiceOIOUBLAndPDFWithPrintAndEmailInternal()
    var
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNoLst: List of [Code[20]];
        FileNameLst: List of [Text];
        PostedDocNoFilter: Text;
    begin
        // [FEATURE] [Zip]
        // [SCENARIO 336642] Send Posted Sales Document in case Print, E-Mail - PDF & OIOUBL, Disk - PDF & OIOUBL are set in Document Sending Profile.
        Initialize();
        MailSetupInitialize();
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Invoice", Codeunit::"OIOUBL-Export Sales Invoice");

        // [GIVEN] Default DocumentSendingProfile with Printer = Yes; Disk = "PDF & Electronic Document", Format = OIOUBL;
        // [GIVEN] E-Mail = Yes, E-Mail Attachment = "PDF & Electronic Document", Format = OIOUBL. Two Posted Sales Invoices.
        SetDefaultDocumentSendingProfile(
            DocumentSendingProfile.Printer::"Yes (Prompt for Settings)", DocumentSendingProfile."E-Mail"::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail Attachment"::"PDF & Electronic Document", OIOUBLFormatNameTxt,
            DocumentSendingProfile.Disk::"PDF & Electronic Document", OIOUBLFormatNameTxt);
        CreateMultiplePostedSalesDocuments(PostedDocNoLst, PostedDocNoFilter, SalesLine."Document Type"::Invoice, 2);

        // [WHEN] Run "Send" for these Posted Sales Invoices.
        SalesInvoiceHeader.SetFilter("No.", PostedDocNoFilter);
        SalesInvoiceHeader.SendRecords();

        // [THEN] Report "Standard Sales - Invoice" for printing Posted Sales Invoice is invoked. Then Email Editor is opened.
        // [THEN] Two ZIP files are created, each of them contains OIOUBL Electronic Document and PDF with printed copy of Posted Sales Invoice.
        FileNameLst.AddRange(GetFileName(PostedDocNoLst.Get(1), 'Invoice', 'XML'), GetFileName(PostedDocNoLst.Get(1), 'S.Invoice', 'PDF'));
        VerifyFileListInZipArchive(FileNameLst);

        Clear(FileNameLst);
        FileNameLst.AddRange(GetFileName(PostedDocNoLst.Get(2), 'Invoice', 'XML'), GetFileName(PostedDocNoLst.Get(2), 'S.Invoice', 'PDF'));
        VerifyFileListInZipArchive(FileNameLst);
    end;

    [Test]
    [HandlerFunctions('PostandSendModalPageHandler,StandardSalesCreditMemoRequestPageHandler,EmailEditorHandler,CloseEmailEditorHandler')]
    procedure PostAndSendSalesCrMemoOIOUBLWithPrintAndEmail();
    begin
        PostAndSendSalesCrMemoOIOUBLWithPrintAndEmailInternal();
    end;

    procedure PostAndSendSalesCrMemoOIOUBLWithPrintAndEmailInternal();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        SalesCreditMemo: TestPage "Sales Credit Memo";
    begin
        // [SCENARIO 336642] Post And Send Sales Credit Memo in case Print, E-Mail - OIOUBL, Disk - OIOUBL are set in Document Sending Profile.
        Initialize();
        MailSetupInitialize();
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Credit Memo", Codeunit::"OIOUBL-Export Sales Cr. Memo");

        // [GIVEN] DocumentSendingProfile with Printer = Yes; Disk = "Electronic Document", Format = OIOUBL;
        // [GIVEN] E-Mail = Yes, E-Mail Attachment = "Electronic Document", Format = OIOUBL. Sales Credit Memo.
        CreateDocumentSendingProfile(
            DocumentSendingProfile, DocumentSendingProfile.Printer::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail"::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail Attachment"::"Electronic Document", OIOUBLFormatNameTxt,
            DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        CreateSalesDocumentWithItem(SalesLine, SalesHeader."Document Type"::"Credit Memo");
        SetDocumentSendingProfileToCustomer(SalesLine."Sell-to Customer No.", DocumentSendingProfile.Code);
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");

        // [WHEN] Run "Post And Send" for Sales Credit Memo.
        SalesCreditMemo.OpenEdit();
        SalesCreditMemo.Filter.SetFilter("No.", SalesHeader."No.");
        SalesCreditMemo.PostAndSend.Invoke();

        // [THEN] Sales Credit Memo is posted.
        // [THEN] Report "Standard Sales - Credit Memo" for printing Posted Sales Credit Memo is invoked. Then Email Editor is opened.
        // [THEN] OIOUBL Electronic Document for Posted Sales Credit Memo is created.
        // [THEN] "No. Printed" value of Posted Sales Credit Memo increases by 3 (Print, E-mail, Disk). Bug ID 351595.
        FindSalesCrMemoHeader(SalesCrMemoHeader, SalesHeader."No.");
        SalesCrMemoHeader.TestField("OIOUBL-Electronic Credit Memo Created", true);
        SalesCrMemoHeader.TestField("No. Printed", 3);
        VerifyElectronicSalesDocument(SalesCrMemoHeader."No.", SalesCrMemoHeader."OIOUBL-Account Code");
    end;

    [Test]
    procedure AmountPriceDiscountOnSalesInvoiceWithLineInvoiceDiscount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
        LineExtensionAmounts: List of [Decimal];
        PriceAmounts: List of [Decimal];
        AllowanceChargeAmounts: List of [Decimal];
        TotalAllowanceChargeAmount: Decimal;
    begin
        // [SCENARIO 341090] Create OIOUBL document for Posted Sales Invoice, that has lines with Line Discount and Inv. Discount.
        Initialize();

        // [GIVEN] Posted Sales Invoice with two lines. Every line has Line Discount and Invoice Discount.
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice);
        CreateSalesLineWithLineAndInvoiceDiscount(
            SalesLine, SalesHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        CreateSalesLineWithLineAndInvoiceDiscount(
            SalesLine, SalesHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, false, true));
        GetAmountsSalesInvoiceLines(SalesInvoiceHeader."No.", LineExtensionAmounts, PriceAmounts, AllowanceChargeAmounts, TotalAllowanceChargeAmount);

        // [WHEN] Create Electronic Document for Posted Sales Invoice.
        OIOUBLExportSalesInvoice.ExportXML(SalesInvoiceHeader);

        // [THEN] InvoiceLine/LineExtensionAmount is equal to Line Amount + Inv. Discount Amount for each Invoice Line.
        // [THEN] InvoiceLine/Price/PriceAmount is equal to (Line Amount + Inv. Discount Amount) / Line Quantity.
        // [THEN] InvoiceLine/AllowanceCharge/Amount is equal to Line Discount.
        // [THEN] LegalMonetaryTotal/LineExtensionAmount is equal to sum of LineExtensionAmount of InvoiceLine sections.
        // [THEN] AllowanceCharge/Amount is equal to sum of Inv. Discount Amount of Sales Invoice Lines.
        VerifyAmountPriceDiscountOnSalesInvoice(
            SalesInvoiceHeader."No.", LineExtensionAmounts, PriceAmounts, AllowanceChargeAmounts, TotalAllowanceChargeAmount);
    end;

    [Test]
    procedure AmountPriceDiscountOnSalesInvoicePricesInclVATWithLineInvoiceDiscount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
        LineExtensionAmounts: List of [Decimal];
        PriceAmounts: List of [Decimal];
        AllowanceChargeAmounts: List of [Decimal];
        TotalAllowanceChargeAmount: Decimal;
    begin
        // [SCENARIO 341090] Create OIOUBL document for Posted Sales Invoice, that has lines with Line Discount and Inv. Discount; Prices Incl. VAT is set.
        Initialize();

        // [GIVEN] Posted Sales Invoice with two lines, Prices Incl. VAT is set. Every line has Line Discount and Invoice Discount.
        // [GIVEN] VAT = 20%.
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice);
        SetPricesInclVATOnSalesHeader(SalesHeader);
        CreateSalesLineWithLineAndInvoiceDiscount(
            SalesLine, SalesHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        CreateSalesLineWithLineAndInvoiceDiscount(
            SalesLine, SalesHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, false, true));
        GetAmountsSalesInvoiceLinesPricesInclVAT(
            SalesInvoiceHeader."No.", LineExtensionAmounts, PriceAmounts, AllowanceChargeAmounts, TotalAllowanceChargeAmount);

        // [WHEN] Create Electronic Document for Posted Sales Invoice.
        OIOUBLExportSalesInvoice.ExportXML(SalesInvoiceHeader);

        // [THEN] InvoiceLine/LineExtensionAmount is equal to Line Amount + 0.8 * Inv. Discount Amount  for each Invoice Line.
        // [THEN] InvoiceLine/Price/PriceAmount is equal to (Line Amount + 0.8 * Inv. Discount Amount) / Line Quantity.
        // [THEN] InvoiceLine/AllowanceCharge/Amount is equal to 0.8 * Line Discount.
        // [THEN] LegalMonetaryTotal/LineExtensionAmount is equal to sum of LineExtensionAmount of InvoiceLine sections.
        // [THEN] AllowanceCharge/Amount is equal to sum of 0.8 * Inv. Discount Amount of Sales Invoice Lines.
        VerifyAmountPriceDiscountOnSalesInvoice(
            SalesInvoiceHeader."No.", LineExtensionAmounts, PriceAmounts, AllowanceChargeAmounts, TotalAllowanceChargeAmount);
    end;

    [Test]
    procedure AmountPriceDiscountOnSalesCrMemoWithLineInvoiceDiscount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OIOUBLExportSalesCrMemo: Codeunit "OIOUBL-Export Sales Cr. Memo";
        LineExtensionAmounts: List of [Decimal];
        PriceAmounts: List of [Decimal];
        TotalAllowanceChargeAmount: Decimal;
    begin
        // [SCENARIO 341090] Create OIOUBL document for Posted Sales Credit Memo, that has lines with Line Discount and Inv. Discount.
        Initialize();

        // [GIVEN] Posted Sales Credit Memo with two lines. Every line has Line Discount and Invoice Discount.
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo");
        CreateSalesLineWithLineAndInvoiceDiscount(
            SalesLine, SalesHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        CreateSalesLineWithLineAndInvoiceDiscount(
            SalesLine, SalesHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        SalesCrMemoHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, false, true));
        GetAmountsSalesCrMemoLines(SalesCrMemoHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);

        // [WHEN] Create Electronic Document for Posted Sales Credit Memo.
        OIOUBLExportSalesCrMemo.ExportXML(SalesCrMemoHeader);

        // [THEN] CreditNoteLine/LineExtensionAmount is equal to Line Amount + Inv. Discount Amount for each Credit Memo Line.
        // [THEN] CreditNoteLine/Price/PriceAmount is equal to (Line Amount + Inv. Discount Amount) / Line Quantity.
        // [THEN] LegalMonetaryTotal/LineExtensionAmount is equal to sum of LineExtensionAmount of CreditNoteLine sections.
        // [THEN] AllowanceCharge/Amount is equal to sum of Inv. Discount Amount of Sales CrMemo Lines.
        VerifyAmountPriceDiscountOnSalesCrMemo(SalesCrMemoHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);
    end;

    [Test]
    procedure AmountPriceDiscountOnSalesCrMemoPricesInclVATWithLineInvoiceDiscount()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OIOUBLExportSalesCrMemo: Codeunit "OIOUBL-Export Sales Cr. Memo";
        LineExtensionAmounts: List of [Decimal];
        PriceAmounts: List of [Decimal];
        TotalAllowanceChargeAmount: Decimal;
    begin
        // [SCENARIO 341090] Create OIOUBL document for Posted Sales Credit Memo, that has lines with Line Discount and Inv. Discount; Prices Incl. VAT is set.
        Initialize();

        // [GIVEN] Posted Sales Credit Memo with two lines, Prices Incl. VAT is set. Every line has Line Discount and Invoice Discount.
        // [GIVEN] VAT = 20%.
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo");
        SetPricesInclVATOnSalesHeader(SalesHeader);
        CreateSalesLineWithLineAndInvoiceDiscount(
            SalesLine, SalesHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        CreateSalesLineWithLineAndInvoiceDiscount(
            SalesLine, SalesHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        SalesCrMemoHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, false, true));
        GetAmountsSalesCrMemoLinesPricesInclVAT(
            SalesCrMemoHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);

        // [WHEN] Create Electronic Document for Posted Sales Credit Memo.
        OIOUBLExportSalesCrMemo.ExportXML(SalesCrMemoHeader);

        // [THEN] CreditNoteLine/LineExtensionAmount is equal to Line Amount + 0.8 * Inv. Discount Amount for each Credit Memo Line.
        // [THEN] CreditNoteLine/Price/PriceAmount is equal to (Line Amount + 0.8 * Inv. Discount Amount) / Line Quantity.
        // [THEN] LegalMonetaryTotal/LineExtensionAmount is equal to sum of LineExtensionAmount of CreditNoteLine sections.
        // [THEN] AllowanceCharge/Amount is equal to sum of 0.8 * Inv. Discount Amount of Sales CrMemo Lines.
        VerifyAmountPriceDiscountOnSalesCrMemo(SalesCrMemoHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);
    end;

    [Test]
    procedure UnitPriceXmlExportPrecision()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
    begin
        // [FEATURE] [Export]
        // [SCENARIO 412134] Unit Price xml node export value precision is 4 decimals
        Initialize();
        ModifyGeneralLedgerSetup(0.0001);

        // [GIVEN] Posted Sales Invoice with Unit Price = 123.4567, Quantity = 100
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice);
        LibrarySales.CreateSalesLineWithUnitPrice(SalesLine, SalesHeader, LibraryInventory.CreateItemNo(), 123.4567, 100);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, false, true));

        // [WHEN] Create Electronic Document for Posted Sales Invoice.
        OIOUBLExportSalesInvoice.ExportXML(SalesInvoiceHeader);

        // [THEN] Exported xml node "PriceAmount" = "123.4567", "LineExtensionAmount" = "12345.67"
        InitializeLibraryXPathXMLReader(OIOUBLNewFileMock.PopFilePath());
        LibraryXPathXMLReader.VerifyNodeValueByXPath('//cac:InvoiceLine/cac:Price/cbc:PriceAmount', '123.4567');
        LibraryXPathXMLReader.VerifyNodeValueByXPath('//cac:InvoiceLine/cbc:LineExtensionAmount', '12345.67');
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsOKModalPageHandler')]
    procedure SendPostedSalesInvoiceNonBlankExternalDocNo()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ExternalDocNo: Code[35];
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 428611] Create OIOUBL document for Posted Sales Invoice with non-blank External Document No.
        Initialize();

        // [GIVEN] Default Document Sending Profile with Disk "Electronic Document", Format "OIOUBL".
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, "Electronic Document Format Usage"::"Sales Invoice", Codeunit::"OIOUBL-Export Sales Invoice");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [GIVEN] Posted Sales Invoice with External Document No. = "E".
        CreateSalesDocumentWithItem(SalesLine, "Sales Document Type"::Invoice);
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        ExternalDocNo := LibraryUtility.GenerateGUID();
        UpdateExtDocNoOnSalesHeader(SalesHeader, ExternalDocNo);
        PostedDocNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [WHEN] Run "Send" for Posted Sales Invoice.
        SalesInvoiceHeader.SetRange("No.", PostedDocNo);
        SalesInvoiceHeader.SendRecords();

        // [THEN] OIOUBL XML document is created, nodes cbc:ID have value "E".
        InitializeLibraryXPathXMLReader(OIOUBLNewFileMock.PopFilePath());
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('//cac:OrderReference/cbc:ID', ExternalDocNo, 0);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('//cac:InvoiceLine/cac:OrderLineReference/cac:OrderReference/cbc:ID', ExternalDocNo);
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsOKModalPageHandler')]
    procedure SendPostedSalesInvoiceBlankExternalDocNo()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 428611] Create OIOUBL document for Posted Sales Invoice with blank External Document No.
        Initialize();

        // [GIVEN] Default Document Sending Profile with Disk "Electronic Document", Format "OIOUBL".
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, "Electronic Document Format Usage"::"Sales Invoice", Codeunit::"OIOUBL-Export Sales Invoice");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [GIVEN] "Document No. as Ext. Doc. No." is set on Sales & Receivables Setup.
        UpdateDocNoAsExtDocNoOnSalesSetup(true);

        // [GIVEN] Posted Sales Invoice with blank External Document No. and No. = "A".
        CreateSalesDocumentWithItem(SalesLine, "Sales Document Type"::Invoice);
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        UpdateExtDocNoOnSalesHeader(SalesHeader, '');
        PostedDocNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [WHEN] Run "Send" for Posted Sales Invoice.
        SalesInvoiceHeader.SetRange("No.", PostedDocNo);
        SalesInvoiceHeader.SendRecords();

        // [THEN] OIOUBL XML document is created, nodes cbc:ID have value "A".
        InitializeLibraryXPathXMLReader(OIOUBLNewFileMock.PopFilePath());
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('//cac:OrderReference/cbc:ID', PostedDocNo, 0);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('//cac:InvoiceLine/cac:OrderLineReference/cac:OrderReference/cbc:ID', PostedDocNo);
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsOKModalPageHandler')]
    procedure SendPostedSalesOrderNonBlankExternalDocNo()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ExternalDocNo: Code[35];
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 428611] Create OIOUBL document for Posted Sales Order with non-blank External Document No.
        Initialize();

        // [GIVEN] Default Document Sending Profile with Disk "Electronic Document", Format "OIOUBL".
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, "Electronic Document Format Usage"::"Sales Invoice", Codeunit::"OIOUBL-Export Sales Invoice");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [GIVEN] Posted Sales Order with External Document No. = "E".
        CreateSalesDocumentWithItem(SalesLine, "Sales Document Type"::Order);
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        ExternalDocNo := LibraryUtility.GenerateGUID();
        UpdateExtDocNoOnSalesHeader(SalesHeader, ExternalDocNo);
        PostedDocNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Run "Send" for Posted Sales Invoice.
        SalesInvoiceHeader.SetRange("No.", PostedDocNo);
        SalesInvoiceHeader.SendRecords();

        // [THEN] OIOUBL XML document is created, nodes cbc:ID have value "E".
        InitializeLibraryXPathXMLReader(OIOUBLNewFileMock.PopFilePath());
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('//cac:OrderReference/cbc:ID', ExternalDocNo, 0);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('//cac:InvoiceLine/cac:OrderLineReference/cac:OrderReference/cbc:ID', ExternalDocNo);
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsOKModalPageHandler')]
    procedure SendPostedSalesOrderBlankExternalDocNo()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 428611] Create OIOUBL document for Posted Sales Order with blank External Document No.
        Initialize();

        // [GIVEN] Default Document Sending Profile with Disk "Electronic Document", Format "OIOUBL".
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, "Electronic Document Format Usage"::"Sales Invoice", Codeunit::"OIOUBL-Export Sales Invoice");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [GIVEN] "Document No. as Ext. Doc. No." is set on Sales & Receivables Setup.
        UpdateDocNoAsExtDocNoOnSalesSetup(true);

        // [GIVEN] Posted Sales Order with blank External Document No. and No. = "A".
        CreateSalesDocumentWithItem(SalesLine, "Sales Document Type"::Order);
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        UpdateExtDocNoOnSalesHeader(SalesHeader, '');
        PostedDocNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Run "Send" for Posted Sales Invoice.
        SalesInvoiceHeader.SetRange("No.", PostedDocNo);
        SalesInvoiceHeader.SendRecords();

        // [THEN] OIOUBL XML document is created, nodes cbc:ID have value "A".
        InitializeLibraryXPathXMLReader(OIOUBLNewFileMock.PopFilePath());
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('//cac:OrderReference/cbc:ID', PostedDocNo, 0);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('//cac:InvoiceLine/cac:OrderLineReference/cac:OrderReference/cbc:ID', PostedDocNo);
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsOKModalPageHandler')]
    procedure SendPostedSalesCrMemoNonBlankExternalDocNo()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ExternalDocNo: Code[35];
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 428611] Create OIOUBL document for Posted Sales Credit Memo with non-blank External Document No.
        Initialize();

        // [GIVEN] Default Document Sending Profile with Disk "Electronic Document", Format "OIOUBL".
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, "Electronic Document Format Usage"::"Sales Credit Memo", Codeunit::"OIOUBL-Export Sales Cr. Memo");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [GIVEN] Posted Sales Credit Memo with External Document No. = "E".
        CreateSalesDocumentWithItem(SalesLine, "Sales Document Type"::"Credit Memo");
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        ExternalDocNo := LibraryUtility.GenerateGUID();
        UpdateExtDocNoOnSalesHeader(SalesHeader, ExternalDocNo);
        PostedDocNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [WHEN] Run "Send" for Posted Sales Credit Memo.
        SalesCrMemoHeader.SetRange("No.", PostedDocNo);
        SalesCrMemoHeader.SendRecords();

        // [THEN] OIOUBL XML document is created, node cbc:ID has value "E".
        InitializeLibraryXPathXMLReader(OIOUBLNewFileMock.PopFilePath());
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('//cac:OrderReference/cbc:ID', ExternalDocNo, 0);
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsOKModalPageHandler')]
    procedure SendPostedSalesCrMemoBlankExternalDocNo()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 428611] Create OIOUBL document for Posted Sales Credit Memo with blank External Document No.
        Initialize();

        // [GIVEN] Default Document Sending Profile with Disk "Electronic Document", Format "OIOUBL".
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, "Electronic Document Format Usage"::"Sales Credit Memo", Codeunit::"OIOUBL-Export Sales Cr. Memo");
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [GIVEN] "Document No. as Ext. Doc. No." is set on Sales & Receivables Setup.
        UpdateDocNoAsExtDocNoOnSalesSetup(true);

        // [GIVEN] Posted Sales Invoice with blank External Document No. and No. = "A".
        CreateSalesDocumentWithItem(SalesLine, "Sales Document Type"::"Credit Memo");
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        UpdateExtDocNoOnSalesHeader(SalesHeader, '');
        PostedDocNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [WHEN] Run "Send" for Posted Sales Credit Memo.
        SalesCrMemoHeader.SetRange("No.", PostedDocNo);
        SalesCrMemoHeader.SendRecords();

        // [THEN] OIOUBL XML document is created, node cbc:ID has value "A".
        InitializeLibraryXPathXMLReader(OIOUBLNewFileMock.PopFilePath());
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('//cac:OrderReference/cbc:ID', PostedDocNo, 0);
    end;

    [Test]
    procedure SendPostedSalesInvoiceOIOUBLAndVerifyFileName()
    var
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        FileMgt: Codeunit "File Management";
        PostedDocNo: Code[20];
        ExpectedFileName: Text;
        ActualFileName: Text;
    begin
        // [SCENARIO 435433] To verify if file name with Electronic Document option from Posted Sales Invoice is following a nomenclature : CompanyName - Invoice Document No.xml
        Initialize();
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Sales Invoice", Codeunit::"OIOUBL-Export Sales Invoice");

        // [GIVEN] Default DocumentSendingProfile with Printer = No; Disk = "Electronic Document", Format = OIOUBL;
        // [GIVEN] E-Mail = No, E-Mail Attachment = "Electronic Document", Format = OIOUBL. One Posted Sales Invoice.
        CreateDocumentSendingProfile(
            DocumentSendingProfile, DocumentSendingProfile.Printer::No,
            DocumentSendingProfile."E-Mail"::No,
            DocumentSendingProfile."E-Mail Attachment"::"Electronic Document", OIOUBLFormatNameTxt,
            DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        PostedDocNo := CreateAndPostSalesDocument(SalesLine, "Sales Document Type"::Order);
        SalesInvoiceHeader.Get(PostedDocNo);
        SetDocumentSendingProfileToCustomer(SalesInvoiceHeader."Sell-to Customer No.", DocumentSendingProfile.Code);
        ExpectedFileName := CopyStr(
            StrSubstNo('%1 - %2 %3.%4', FileMgt.StripNotsupportChrInFileName(CompanyName), Format("Sales Document Type"::Invoice), SalesInvoiceHeader."No.", 'XML'), 1, 250);

        // [WHEN] Export the xml file for electronic document
        SalesInvoiceHeader.SetRecFilter();
        ActualFileName := GetXMLExportFileName(SalesInvoiceHeader, OIOUBLFormatNameTxt);

        // [THEN] Client File Name should be CompanyName - Invoice Document No.xml
        Assert.AreEqual(ExpectedFileName, ActualFileName, StrSubstNo(WrongFileNameErr, ExpectedFileName));
    end;

    [Test]
    procedure ShipSOwithCountryRegionCodeBlankInDKCountriesRegions()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentSendingProfile: Record "Document Sending Profile";
        Customer: Record Customer;
        Item: Record Item;
        CountriesRegions: Record "Country/Region";
        SalesPost: Codeunit "Sales-Post";
    begin
        // [SCENARIO 472494] Error message appears regards a missing OIOUBL Country/Region Code in "Post / Ship" scenario in the Danish version.
        Initialize();

        // [GIVEN] Create a Document Sending Profile Code.
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [GIVEN] Find DK Code in Countries/Regions.
        CountriesRegions.Setfilter(Code, CountryRegionCodeLbl);
        CountriesRegions.FindFirst();

        // [GIVEN] Set OIOUBL-Country/Region Code to Blank for DK Code of Countries/Regions.
        CountriesRegions.Validate("OIOUBL-Country/Region Code", '');
        CountriesRegions.Modify(true);

        // [GIVEN] Create a Customer with Address.
        LibrarySales.CreateCustomerWithAddress(Customer);

        // [GIVEN] Update Document Sending Profile, VAT Registration, GLN, GLN in Electronic Document, OIOUBL-Account Code,
        // OIOUBL-Profile Code, Registration Number in the Customer record.
        Customer.Validate("Document Sending Profile", '');
        Customer."VAT Registration No." := VATRegNoLbl;
        Customer.Validate(GLN, GLNLbl);
        Customer.Validate("Use GLN in Electronic Document", true);
        Customer.Validate("OIOUBL-Account Code", LibraryRandom.RandText(5));
        Customer.Validate("OIOUBL-Profile Code", CreateOIOUBLProfile());
        Customer.Validate("Registration Number", LibraryRandom.RandText(5));
        Customer.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Create a SalesOrder with a SalesLine of an Item.
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(1));

        // [GIVEN] Update VAT Registration No,  OIOUBL-GLN, OIOUBL-Account Code, OIOUBL-Profile Code from Customer to Sales Header & Ship equals to True.
        SalesHeader."VAT Registration No." := Customer."VAT Registration No.";
        SalesHeader.Validate("OIOUBL-GLN", Customer.GLN);
        SalesHeader.Validate("OIOUBL-Account Code", Customer."OIOUBL-Account Code");
        SalesHeader.Validate("OIOUBL-Profile Code", Customer."OIOUBL-Profile Code");
        SalesHeader.Validate(Ship, true);
        SalesHeader.Modify();

        // [WHEN] Run "Post" for Sales Order.
        SalesPost.Run(SalesHeader);

        // [VERIFY] Verify No error is thrown while posting.
        assert.AreNotEqual(CountryRegionErr, GetLastErrorText, ErrorMustMatchErr);
    end;

    local procedure Initialize();
    var
        SalesHeader: Record "Sales Header";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        DocumentSendingProfile.DeleteAll();
        OIOUBLNewFileMock.Setup(OIOUBLNewFileMock);
        LibrarySetupStorage.Restore();

        if isInitialized then
            exit;

        UpdateSalesReceivablesSetup();
        UpdateOIOUBLCountryRegionCode();
        ModifyGeneralLedgerSetup(0.01);

        LibraryERM.DisableMyNotifications(CopyStr(UserId(), 1, 50), SalesHeader.GetModifyCustomerAddressNotificationId());
        LibrarySetupStorage.SaveGeneralLedgerSetup();

        isInitialized := true;
    end;

    local procedure CreateAndPostSalesDocumentSalesLineTypeAndNoBlank(DocumentType: Enum "Sales Document Type"; ReportID: Integer);
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentSendingProfile: Record "Document Sending Profile";
        DocumentNo: Code[20];
        TaxAmount: Decimal;
    begin
        Initialize();
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        // [GIVEN] Created and Posted Sales Document Sales Line Type and Line No. Blank.
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLineWithBlankLines(SalesLine."Line No.", DocumentType, SalesHeader."No.", '', 'Test');  // Use Blank for Sales Line No.,Value not important required only for test Purpoase.
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItem(Item));
        TaxAmount := CalculateTaxAmount(SalesHeader);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Electronic Invoice or Credit Memo created.
        RunReport(ReportID, DocumentNo);

        // [THEN] The following values are verified on generated xml file of Electronic Invoice or Credit Memo: Sales Document No., Tax Amount, BaseQuantity.
        VerifyDocumentNoAndTaxAmount(DocumentNo, TaxAmount);
    end;

    local procedure CalculateTaxAmount(SalesHeader: Record "Sales Header"): Decimal;
    var
        TaxAmount: Decimal;
    begin
        SalesHeader.CALCFIELDS(Amount, "Amount Including VAT");
        TaxAmount := SalesHeader."Amount Including VAT" - SalesHeader.Amount;
        exit(TaxAmount);
    end;

    local procedure CreateAndPostSalesDocument(var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type"): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesDocumentWithItem(SalesLine, DocumentType);
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");

        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateMultiplePostedSalesDocuments(var PostedDocNoLst: List of [Code[20]]; var PostedDocNoFilter: Text; DocumentType: Enum "Sales Document Type"; NumberOfDocuments: Integer);
    var
        SalesLine: Record "Sales Line";
        i: Integer;
    begin
        Clear(PostedDocNoLst);
        PostedDocNoFilter := '';

        for i := 1 to NumberOfDocuments do begin
            PostedDocNoLst.Add(CreateAndPostSalesDocument(SalesLine, DocumentType));
            PostedDocNoFilter += PostedDocNoLst.Get(i) + '|';
        end;
        PostedDocNoFilter := DelChr(PostedDocNoFilter, '>', '|');
    end;

    local procedure CreateCustomer(): Code[20];
    var
        Customer: Record Customer;
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.GET();
        LibrarySales.CreateCustomer(Customer);
        Customer.VALIDATE("Country/Region Code", CompanyInformation."Country/Region Code");
        Customer.VALIDATE("VAT Registration No.", CompanyInformation."VAT Registration No.");
        Customer.VALIDATE(GLN, GLNNoTxt);
        Customer.MODIFY(true);
        exit(Customer."No.")
    end;

    local procedure CreateGLAccount(VATProdPostingGroup: Code[20]): Code[20];
    var
        GLAccount: Record "G/L Account";
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        LibraryERM.FindGeneralPostingSetup(GeneralPostingSetup);
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.VALIDATE("Gen. Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group");
        GLAccount.VALIDATE("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        GLAccount.VALIDATE("VAT Prod. Posting Group", VATProdPostingGroup);
        GLAccount.MODIFY(true);
        exit(GLAccount."No.");
    end;

    local procedure CreateSalesDocumentWithItem(var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type");
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo());
    end;

    local procedure CreateSalesHeader(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type");
    var
        PostCode: Record "Post Code";
    begin
        LibraryERM.FindPostCode(PostCode);
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CreateCustomer());
        SalesHeader.VALIDATE("Sell-to Contact", SalesHeader."No.");
        SalesHeader.VALIDATE("Bill-to Address", LibraryUtility.GenerateGUID());
        SalesHeader.VALIDATE("Bill-to City", PostCode.City);
        SalesHeader.Validate("Ship-to Address", LibraryUtility.GenerateGUID());
        SalesHeader.Validate("Ship-to City", PostCode.City);
        SalesHeader.Validate("Your Reference", LibraryUtility.GenerateGUID());
        SalesHeader.MODIFY(true);
        ClearVATRegistrationForCustomer(SalesHeader."Sell-to Customer No.");
    end;

    local procedure CreateSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Type: Enum "Sales Line Type"; No: Code[20]);
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibrarySales.CreateSalesLine(
        SalesLine, SalesHeader, Type, No, LibraryRandom.RandDecInRange(10, 20, 2));  // Random Value for Quantity.
        SalesLine.VALIDATE("Unit Price", LibraryRandom.RandDecInRange(100, 200, 2));  // Random Value for Unit Price.
        SalesLine.VALIDATE("Unit of Measure", UnitOfMeasure.Code);
        SalesLine.MODIFY(true);
    end;

    local procedure CreateSalesLineWithBlankLines(LineNo: Integer; DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20];
                                                                                     No: Code[20];
                                                                                     Description: Text[50]);
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.VALIDATE("Document Type", DocumentType);
        SalesLine.VALIDATE("Document No.", DocumentNo);
        SalesLine.VALIDATE("Line No.", LineNo + 1);  // Value Not Mandatory, require only for test
        SalesLine.INSERT(true);  // Feature Specific,Since Blank Type, No and Line Required in tests.
        SalesLine.VALIDATE(Type, SalesLine.Type::" ");
        SalesLine.VALIDATE("No.", No);
        SalesLine.VALIDATE(Description, Description);
        SalesLine.MODIFY(true);
    end;

    local procedure CreateSalesLineWithDiscount(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; LineDiscountPct: Integer)
    begin
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo());
        SalesLine.Validate("Line Discount %", LineDiscountPct);
        SalesLine.Modify(true);
    end;

    local procedure CreateSalesLineWithLineAndInvoiceDiscount(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; LineDiscountAmt: Decimal; InvDiscountAmt: Decimal)
    begin
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo());
        SalesLine.Validate("Line Discount Amount", LineDiscountAmt);
        SalesLine.Validate("Inv. Discount Amount", InvDiscountAmt);
        SalesLine.Modify(true);
    end;

    local procedure CreateElectronicDocumentFormat(DocFormatCode: Code[20]; DocFormatUsage: Enum "Electronic Document Format Usage"; CodeunitID: Integer);
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        with ElectronicDocumentFormat do begin
            SetFilter(Code, DocFormatCode);
            SetRange(Usage, DocFormatUsage);
            DeleteAll();
            InsertElectronicFormat(DocFormatCode, '', CodeunitID, 0, DocFormatUsage.AsInteger());
        end;
    end;

    local procedure CreateOIOUBLProfile(): Code[10];
    var
        OIOUBLProfile: Record "OIOUBL-Profile";
    // LibraryUtility: Codeunit "Library - Utility";
    begin
        with OIOUBLProfile do begin
            VALIDATE("OIOUBL-Code", LibraryUtility.GenerateRandomCode(FIELDNO("OIOUBL-Code"), DATABASE::"OIOUBL-Profile"));
            VALIDATE("OIOUBL-Profile ID", DefaultProfileIDTxt);

            INSERT(true);
            exit("OIOUBL-Code");
        end;
    end;

    local procedure CreateDocumentSendingProfile(var DocumentSendingProfile: Record "Document Sending Profile"; PrinterType: Option; EmailType: Option; EmailAttachment: Enum "Document Sending Profile Attachment Type"; EmailFormatCode: Code[20];
                                                                                                                                                                             DiskType: Enum "Doc. Sending Profile Disk";
                                                                                                                                                                             DiskFormatCode: Code[20])
    begin
        with DocumentSendingProfile do begin
            Init();
            Code := DefaultCodeTxt;
            Printer := PrinterType;
            "E-Mail" := EmailType;
            "E-Mail Attachment" := EmailAttachment;
            "E-Mail Format" := EmailFormatCode;
            Disk := DiskType;
            "Disk Format" := DiskFormatCode;
            Default := true;
            Insert();
        end;
    end;

    local procedure ClearVATRegistrationForCustomer(CustomerNo: Code[20]);
    var
        Customer: Record Customer;
    begin
        Customer.GET(CustomerNo);
        Customer."VAT Registration No." := '';
        Customer.MODIFY();
    end;

    local procedure FindStandardText(): Code[20];
    var
        StandardText: Record "Standard Text";
    begin
        StandardText.FINDFIRST();
        exit(StandardText.Code);
    end;

    local procedure FindNormalVAT(): Code[20];
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        exit(VATPostingSetup."VAT Prod. Posting Group");
    end;

    local procedure FindReverseChargeVAT(VATCalculationType: Enum "Tax Calculation Type"): Code[20];
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATCalculationType);
        VATPostingSetup.VALIDATE("VAT %", 0); // Value 0 is required for zero Vat Amount;
        VATPostingSetup.MODIFY(true);
        exit(VATPostingSetup."VAT Prod. Posting Group");
    end;

    local procedure FindZeroVAT(): Code[20];
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SETRANGE("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.SETRANGE("VAT %", 0);
        VATPostingSetup.FINDFIRST();
        exit(VATPostingSetup."VAT Prod. Posting Group");
    end;

    local procedure FindSalesInvoiceHeader(var SalesInvoiceHeader: Record "Sales Invoice Header"; PreAssignedNo: Code[20])
    begin
        SalesInvoiceHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        SalesInvoiceHeader.FindFirst();
    end;

    local procedure FindSalesCrMemoHeader(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PreAssignedNo: Code[20])
    begin
        SalesCrMemoHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        SalesCrMemoHeader.FindFirst();
    end;

    local procedure FormatAmount(Amount: Decimal): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(Format(Amount, 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces()))
    end;

    local procedure GetNonExistingCodeunitID(): Integer;
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
        AllObj.FindLast();
        exit(AllObj."Object ID" + 1);
    end;

    local procedure GetFileName(DocumentNo: Code[20]; DocumentType: Text; Extension: Code[3]): Text[250]
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
        RecordVariant: Variant;
    begin
        exit(ElectronicDocumentFormat.GetAttachmentFileName(RecordVariant, DocumentNo, DocumentType, Extension));
    end;

    local procedure GetAmountsSalesInvoiceLines(SalesInvHeaderNo: Code[20]; var LineExtensionAmounts: List of [Decimal]; var PriceAmounts: List of [Decimal]; var AllowanceChargeAmounts: List of [Decimal]; var TotalAllowanceChargeAmount: Decimal)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        TotalAllowanceChargeAmount := 0;
        with SalesInvoiceLine do begin
            SetRange("Document No.", SalesInvHeaderNo);
            FindSet();
            repeat
                LineExtensionAmounts.Add(Amount + "Inv. Discount Amount");
                PriceAmounts.Add(Round((Amount + "Inv. Discount Amount") / Quantity));
                AllowanceChargeAmounts.Add("Line Discount Amount");
                TotalAllowanceChargeAmount += "Inv. Discount Amount";
            until Next() = 0;
        end;
    end;

    local procedure GetAmountsSalesInvoiceLinesPricesInclVAT(SalesInvHeaderNo: Code[20]; var LineExtensionAmounts: List of [Decimal]; var PriceAmounts: List of [Decimal]; var AllowanceChargeAmounts: List of [Decimal]; var TotalAllowanceChargeAmount: Decimal)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        ExclVATFactor: Decimal;
    begin
        TotalAllowanceChargeAmount := 0;
        with SalesInvoiceLine do begin
            SetRange("Document No.", SalesInvHeaderNo);
            FindSet();
            repeat
                ExclVATFactor := 1 + "VAT %" / 100;
                LineExtensionAmounts.Add(Amount + Round("Inv. Discount Amount" / ExclVATFactor));
                PriceAmounts.Add(Round((Amount + Round("Inv. Discount Amount" / ExclVATFactor)) / Quantity));
                AllowanceChargeAmounts.Add(Round("Line Discount Amount" / ExclVATFactor));
                TotalAllowanceChargeAmount += Round("Inv. Discount Amount" / ExclVATFactor);
            until Next() = 0;
        end;
    end;

    local procedure GetAmountsSalesCrMemoLines(SalesCrMemoHeaderNo: Code[20]; var LineExtensionAmounts: List of [Decimal]; var PriceAmounts: List of [Decimal]; var TotalAllowanceChargeAmount: Decimal)
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        TotalAllowanceChargeAmount := 0;
        with SalesCrMemoLine do begin
            SetRange("Document No.", SalesCrMemoHeaderNo);
            FindSet();
            repeat
                LineExtensionAmounts.Add(Amount + "Inv. Discount Amount");
                PriceAmounts.Add(Round((Amount + "Inv. Discount Amount") / Quantity));
                TotalAllowanceChargeAmount += "Inv. Discount Amount";
            until Next() = 0;
        end;
    end;

    local procedure GetAmountsSalesCrMemoLinesPricesInclVAT(SalesCrMemoHeaderNo: Code[20]; var LineExtensionAmounts: List of [Decimal]; var PriceAmounts: List of [Decimal]; var TotalAllowanceChargeAmount: Decimal)
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ExclVATFactor: Decimal;
    begin
        TotalAllowanceChargeAmount := 0;
        with SalesCrMemoLine do begin
            SetRange("Document No.", SalesCrMemoHeaderNo);
            FindSet();
            repeat
                ExclVATFactor := 1 + "VAT %" / 100;
                LineExtensionAmounts.Add(Amount + Round("Inv. Discount Amount" / ExclVATFactor));
                PriceAmounts.Add(Round((Amount + Round("Inv. Discount Amount" / ExclVATFactor)) / Quantity));
                TotalAllowanceChargeAmount += Round("Inv. Discount Amount" / ExclVATFactor);
            until Next() = 0;
        end;
    end;

    local procedure InitializeLibraryXPathXMLReader(FileName: Text)
    begin
        Clear(LibraryXPathXMLReader);
        LibraryXPathXMLReader.Initialize(FileName, 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2');
        LibraryXPathXMLReader.SetDefaultNamespaceUsage(false);
        LibraryXPathXMLReader.AddAdditionalNamespace('cac', 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2');
        LibraryXPathXMLReader.AddAdditionalNamespace('cbc', 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2');
    end;

    local procedure RunReport(ReportID: Integer; No: Code[20]);
    begin
        if ReportID = REPORT::"OIOUBL-Create Elec. Cr. Memos" then
            RunReportCreateElecSalesCrMemos(No)
        else
            RunReportCreateElecSalesInvoices(No);
    end;

    local procedure RunReportCreateElecSalesCrMemos(No: Code[20]);
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CreateElecSalesCrMemos: Report "OIOUBL-Create Elec. Cr. Memos";
    begin
        CLEAR(CreateElecSalesCrMemos);
        SalesCrMemoHeader.SETRANGE("No.", No);
        CreateElecSalesCrMemos.SETTABLEVIEW(SalesCrMemoHeader);
        CreateElecSalesCrMemos.USEREQUESTPAGE(false);
        CreateElecSalesCrMemos.RUN();
    end;

    local procedure RunReportCreateElecSalesInvoices(No: Code[20]);
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CreateElecSalesInvoice: Report "OIOUBL-Create Elec. Invoices";
    begin
        CLEAR(CreateElecSalesInvoice);
        SalesInvoiceHeader.SETRANGE("No.", No);
        SalesInvoiceHeader.FindFirst();
        CreateElecSalesInvoice.SETTABLEVIEW(SalesInvoiceHeader);
        CreateElecSalesInvoice.USEREQUESTPAGE(false);
        CreateElecSalesInvoice.RUN();
    end;

    local procedure SetDefaultDocumentSendingProfile(DiskType: Enum "Doc. Sending Profile Disk"; DiskFormatCode: Code[20]);
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        CreateDocumentSendingProfile(
            DocumentSendingProfile, DocumentSendingProfile.Printer::No, DocumentSendingProfile."E-Mail"::No,
            "Document Sending Profile Attachment Type"::PDF, '', DiskType, DiskFormatCode);
        DocumentSendingProfile.Default := true;
        DocumentSendingProfile.Modify();
    end;

    local procedure SetDefaultDocumentSendingProfile(PrinterType: Option; EmailType: Option; EmailAttachment: Enum "Document Sending Profile Attachment Type"; EmailFormatCode: Code[20];
                                                                                                                  DiskType: Enum "Doc. Sending Profile Disk";
                                                                                                                  DiskFormatCode: Code[20])
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        CreateDocumentSendingProfile(DocumentSendingProfile, PrinterType, EmailType, EmailAttachment, EmailFormatCode, DiskType, DiskFormatCode);
        DocumentSendingProfile.Default := true;
        DocumentSendingProfile.Modify();
    end;

    local procedure SetDocumentSendingProfileToCustomer(CustomerNo: Code[20]; DocumentSendingProfileCode: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        Customer."Document Sending Profile" := DocumentSendingProfileCode;
        Customer.Modify();
    end;

    local procedure SetPricesInclVATOnSalesHeader(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Modify(true);
    end;

    local procedure MailSetupInitialize()
    var
        LibraryWorkflow: Codeunit "Library - Workflow";
    begin
        LibraryWorkflow.SetUpEmailAccount();
    end;

    local procedure UpdateOIOUBLCountryRegionCode();
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.SETRANGE("OIOUBL-Country/Region Code", '');
        if CountryRegion.FINDFIRST() then
            CountryRegion.MODIFYALL("OIOUBL-Country/Region Code", CountryRegion.Code);
    end;

    local procedure UpdateSalesReceivablesSetup();
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        // Use TEMPORARYPATH to save the generated xml to avoid hardcoding for path.
        with SalesReceivablesSetup do begin
            Get();
            Validate("OIOUBL-Invoice Path", TemporaryPath());
            Validate("OIOUBL-Cr. Memo Path", TemporaryPath());
            Validate("OIOUBL-Default Profile Code", CreateOIOUBLProfile());
            Modify(true);
        end;
    end;

    local procedure UpdateDocNoAsExtDocNoOnSalesSetup(DocNoAsExtDocNo: Boolean)
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Document No. as Ext. Doc. No.", DocNoAsExtDocNo);
        SalesReceivablesSetup.Modify(true);
    end;

    local procedure UpdateCompanySwiftCode()
    var
        CompanyInformation: Record "Company Information";
    begin
        with CompanyInformation do begin
            Get();
            Validate("SWIFT Code", DelStr(LibraryUtility.GenerateGUID(), 1, 2));
            Modify(true);
        end;
    end;

    local procedure UpdateExtDocNoOnSalesHeader(var SalesHeader: Record "Sales Header"; ExternalDocumentNo: Code[35])
    begin
        SalesHeader.Validate("External Document No.", ExternalDocumentNo);
        SalesHeader.Modify(true);
    end;

    local procedure ModifyGeneralLedgerSetup(UnitAmountRoundingPrecision: Decimal);
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        // Make sure that G/L Setup has 2 decimal places
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := UnitAmountRoundingPrecision;
        GeneralLedgerSetup.Modify();
    end;

    local procedure VerifyElectronicSalesDocument(DocumentNo: Code[20]; AccountCode: Text[30]);
    begin
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath());
        LibraryXMLReadOnServer.VerifyNodeValue(IDTxt, DocumentNo);
        LibraryXMLReadOnServer.VerifyNodeValue(AccountingCostCodeTxt, AccountCode);
    end;

    local procedure VerifyElectronicSalesDocumentInZipArchive(DocumentNoLst: List of [Code[20]]; AccountCodeLst: List of [Text[30]]);
    var
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        ZipFile: File;
        ZipFileInStream: InStream;
        ZipEntryOutStream: OutStream;
        XMLInStream: InStream;
        ZipEntryList: List of [Text];
        ZipEntry: Text;
        i: Integer;
    begin
        for i := 1 to DocumentNoLst.Count() do // dequeue unused XML files names
            OIOUBLNewFileMock.PopFilePath();

        i := 0;
        ZipFile.WriteMode(false);
        ZipFile.Open(OIOUBLNewFileMock.PopFilePath());
        ZipFile.CreateInStream(ZipFileInStream);
        DataCompression.OpenZipArchive(ZipFileInStream, false);
        DataCompression.GetEntryList(ZipEntryList);
        foreach ZipEntry in ZipEntryList do begin
            i += 1;
            Clear(TempBlob);
            TempBlob.CreateOutStream(ZipEntryOutStream);
            DataCompression.ExtractEntry(ZipEntry, ZipEntryOutStream);
            TempBlob.CreateInStream(XMLInStream);
            LibraryXMLReadOnServer.LoadXMLDocFromInStream(XMLInStream);
            LibraryXMLReadOnServer.VerifyNodeValue(IDTxt, DocumentNoLst.Get(i));
            LibraryXMLReadOnServer.VerifyNodeValue(AccountingCostCodeTxt, AccountCodeLst.Get(i));
        end;
        DataCompression.CloseZipArchive();
        ZipFile.Close();
    end;

    local procedure VerifyFileListInZipArchive(FileNameList: List of [Text])
    var
        DataCompression: Codeunit "Data Compression";
        ZipFile: File;
        ZipFileInStream: InStream;
        ZipEntryList: List of [Text];
        ZipEntry: Text;
        i: Integer;
    begin
        i := 0;
        ZipFile.WriteMode(false);
        ZipFile.Open(OIOUBLNewFileMock.PopFilePath());
        ZipFile.CreateInStream(ZipFileInStream);
        DataCompression.OpenZipArchive(ZipFileInStream, false);
        DataCompression.GetEntryList(ZipEntryList);
        foreach ZipEntry in ZipEntryList do begin
            i += 1;
            Assert.AreEqual(FileNameList.Get(i), ZipEntry, '');
        end;
        DataCompression.CloseZipArchive();
        ZipFile.Close();
    end;

    local procedure VerifyDocumentNoAndTaxAmount(DocumentNo: Code[20]; TaxAmount: Decimal);
    begin
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath()); // Initialize generated Electronic Invoice and Credit Memo.
        LibraryXMLReadOnServer.VerifyNodeValue(IDTxt, DocumentNo);
        LibraryXMLReadOnServer.VerifyNodeValue(TaxAmountTxt, FORMAT(ROUND(TaxAmount, LibraryERM.GetAmountRoundingPrecision()), 0, '<Precision,2:3><Sign><Integer><Decimals><Comma,.>'));
        LibraryXMLReadOnServer.VerifyNodeValue(BaseQuantityTxt, '1');
    end;

    local procedure VerifyGLEntry(DocumentNo: Code[20]; Amount: Decimal);
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SETRANGE("Document No.", DocumentNo);
        GLEntry.FINDFIRST();
        Assert.AreNearlyEqual(
        Amount, GLEntry.Amount, LibraryERM.GetAmountRoundingPrecision(),
        STRSUBSTNO(AmountErr, GLEntry.FIELDCAPTION(Amount), GLEntry.Amount, GLEntry.TABLECAPTION()));
    end;

    local procedure VerifyInteractionLogEntry(DocumentType: Enum "Interaction Log Entry Document Type"; DocumentNo: Code[20])
    var
        InteractionLogEntry: Record "Interaction Log Entry";
    begin
        InteractionLogEntry.SetRange("Document Type", DocumentType);
        InteractionLogEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordIsNotEmpty(InteractionLogEntry);
    end;

    local procedure VerifyAllowanceCharge(DocumentNo: Code[20]; ExpectedValue: Decimal);
    var
        GeneralLedgerSetup: record "General Ledger Setup";
    begin
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath());
        LibraryXMLReadOnServer.VerifyNodeValue(IDTxt, DocumentNo);
        LibraryXMLReadOnServer.VerifyElementAbsenceInSubtree('cac:LegalMonetaryTotal', 'cbc:AllowanceTotalAmount');
        Assert.AreEqual(2, LibraryXMLReadOnServer.GetNodesCount('cac:InvoiceLine'), WrongInvoiceLineCountErr);
        LibraryXMLReadOnServer.VerifyNodeValueInSubtree('cac:InvoiceLine', 'cbc:Amount', FORMAT(ExpectedValue, 0, '<Precision,2:3><Sign><Integer><Decimals><Comma,.>'));
        Assert.AreEqual(1, LibraryXMLReadOnServer.GetNodesCount('cac:AllowanceCharge'), WrongAllowanceChargeErr);

        GeneralLedgerSetup.Get();
        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:PaymentTerms', 'cbc:Amount', 'currencyID', GeneralLedgerSetup."LCY Code");
        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:AllowanceCharge', 'cbc:Amount', 'currencyID', GeneralLedgerSetup."LCY Code");
        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:AllowanceCharge', 'cbc:BaseAmount', 'currencyID', GeneralLedgerSetup."LCY Code");
        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:TaxTotal', 'cbc:TaxAmount', 'currencyID', GeneralLedgerSetup."LCY Code");
        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:TaxSubtotal', 'cbc:TaxableAmount', 'currencyID', GeneralLedgerSetup."LCY Code");
        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:TaxSubtotal', 'cbc:TaxAmount', 'currencyID', GeneralLedgerSetup."LCY Code");

        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:LegalMonetaryTotal', 'cbc:LineExtensionAmount', 'currencyID', GeneralLedgerSetup."LCY Code");
        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:LegalMonetaryTotal', 'cbc:TaxExclusiveAmount', 'currencyID', GeneralLedgerSetup."LCY Code");
        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:LegalMonetaryTotal', 'cbc:TaxInclusiveAmount', 'currencyID', GeneralLedgerSetup."LCY Code");
        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:LegalMonetaryTotal', 'cbc:PayableAmount', 'currencyID', GeneralLedgerSetup."LCY Code");

        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:InvoiceLine', 'cbc:LineExtensionAmount', 'currencyID', GeneralLedgerSetup."LCY Code");
        LibraryXMLReadOnServer.VerifyAttributeValueInSubtree('cac:Price', 'cbc:PriceAmount', 'currencyID', GeneralLedgerSetup."LCY Code")
    end;

    local procedure VerifyAmountPriceDiscountOnSalesInvoice(SalesInvHeaderNo: Code[20]; LineExtensionAmounts: List of [Decimal]; PriceAmounts: List of [Decimal]; AllowanceChargeAmounts: List of [Decimal]; TotalAllowanceChargeAmount: Decimal)
    var
        TotalLineExtensionAmount: Decimal;
        i: Integer;
    begin
        InitializeLibraryXPathXMLReader(OIOUBLNewFileMock.PopFilePath());
        LibraryXPathXMLReader.VerifyNodeValue(IDTxt, SalesInvHeaderNo);

        for i := 1 to LineExtensionAmounts.Count() do begin
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                '//cac:InvoiceLine/cbc:LineExtensionAmount', FormatAmount(LineExtensionAmounts.Get(i)), i - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                '//cac:InvoiceLine/cac:Price/cbc:PriceAmount', FormatAmount(PriceAmounts.Get(i)), i - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                '//cac:InvoiceLine/cac:AllowanceCharge/cbc:Amount', FormatAmount(AllowanceChargeAmounts.Get(i)), i - 1);

            TotalLineExtensionAmount += LineExtensionAmounts.Get(i);
        end;

        LibraryXPathXMLReader.VerifyNodeValueByXPath(
            '//cac:LegalMonetaryTotal/cbc:LineExtensionAmount', FormatAmount(TotalLineExtensionAmount));
        LibraryXPathXMLReader.VerifyNodeValueByXPath(
            '//cac:AllowanceCharge/cbc:Amount', FormatAmount(TotalAllowanceChargeAmount));
    end;

    local procedure VerifyAmountPriceDiscountOnSalesCrMemo(SalesCmMemoHeaderNo: Code[20]; LineExtensionAmounts: List of [Decimal]; PriceAmounts: List of [Decimal]; TotalAllowanceChargeAmount: Decimal)
    var
        TotalLineExtensionAmount: Decimal;
        i: Integer;
    begin
        InitializeLibraryXPathXMLReader(OIOUBLNewFileMock.PopFilePath());
        LibraryXPathXMLReader.VerifyNodeValue(IDTxt, SalesCmMemoHeaderNo);

        for i := 1 to LineExtensionAmounts.Count() do begin
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                '//cac:CreditNoteLine/cbc:LineExtensionAmount', FormatAmount(LineExtensionAmounts.Get(i)), i - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                '//cac:CreditNoteLine/cac:Price/cbc:PriceAmount', FormatAmount(PriceAmounts.Get(i)), i - 1);

            TotalLineExtensionAmount += LineExtensionAmounts.Get(i);
        end;

        LibraryXPathXMLReader.VerifyNodeValueByXPath(
            '//cac:LegalMonetaryTotal/cbc:LineExtensionAmount', FormatAmount(TotalLineExtensionAmount));
        LibraryXPathXMLReader.VerifyNodeValueByXPath(
            '//cac:AllowanceCharge/cbc:Amount', FormatAmount(TotalAllowanceChargeAmount));
    end;

    local procedure GetXMLExportFileName(DocumentVariant: Variant; FormatCode: Code[20]): Text
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
        TempBlob: Codeunit "Temp Blob";
        ClientFileName: Text[250];
    begin
        ElectronicDocumentFormat.SendElectronically(TempBlob, ClientFileName, DocumentVariant, FormatCode);
        exit(ClientFileName);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := true;
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure CloseEmailEditorHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1;
    end;

    [MessageHandler]
    procedure MessageHandler(Meassage: Text[1024]);
    begin
    end;

    [StrMenuHandler]
    procedure ProfileSelectionMethodStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 3; // Use the default profile for all selected documents without confimation.
    end;

    [StrMenuHandler]
    procedure ProfileSelectionMethodAndCloseEmailStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        if Options = 'Yes,No' then
            Choice := 1 // Close email
        else
            Choice := 3; // Use the default profile for all selected documents without confimation.
    end;

    [StrMenuHandler]
    procedure ShipInvoiceQstStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1; // Ship
    end;

    [PageHandler]
    procedure ErrorMessagesPageHandler(var ErrorMessages: TestPage "Error Messages");
    begin
        ErrorMessages.Filter.SetFilter("Context Record ID", LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.Enqueue(ErrorMessages.Description.Value());
        LibraryVariableStorage.Enqueue(ErrorMessages."Message Type".Value());
        ErrorMessages.Close();
    end;

    [ModalPageHandler]
    procedure PostandSendModalPageHandler(var PostandSendConfirmation: TestPage "Post and Send Confirmation");
    begin
        PostandSendConfirmation.Yes().INVOKE();
    end;

    [ModalPageHandler]
    procedure SelectSendingOptionsOKModalPageHandler(var SelectSendingOptions: TestPage "Select Sending Options")
    begin
        SelectSendingOptions.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure EmailEditorHandler(var EmailDialog: TestPage "Email Editor")
    begin
    end;

    [RequestPageHandler]
    procedure StandardSalesInvoiceRequestPageHandler(var StandardSalesInvoice: TestRequestPage "Standard Sales - Invoice")
    begin
        StandardSalesInvoice.Cancel().Invoke();
    end;

    [RequestPageHandler]
    procedure StandardSalesCreditMemoRequestPageHandler(var StandardSalesCreditMemo: TestRequestPage "Standard Sales - Credit Memo")
    begin
        StandardSalesCreditMemo.Cancel().Invoke();
    end;
}

