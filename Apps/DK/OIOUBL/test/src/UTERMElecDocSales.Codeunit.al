// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148054 "OIOUBL-UT ERM Elec. Doc Sales"
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
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryXMLReadOnServer: Codeunit "Library - XML Read OnServer";
        OIOUBLNewFileMock: Codeunit "OIOUBL-File Events Mock";
        GLNNoTxt: Label '3974567891234';
        IDTxt: Label 'cbc:ID';
        TaxAmountTxt: Label 'cbc:TaxExclusiveAmount';
        DefaultProfileIDTxt: Label 'Procurement-BilSim-1.0';
        WrongAllowanceChargeErr: Label 'Wrong Count of "AllowanceCharge".';
        WrongInvoiceLineCountErr: Label 'Wrong count of "InvoiceLine".';
        BaseQuantityTxt: Label 'cbc:BaseQuantity';

    [Test]
    procedure CreateAndPostSalesInvoiceWithSingleLine();
    var
        SalesLine: Record "Sales Line";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice with Single Line.
        CreateAndPostSalesDocumentWithSingleLine(SalesLine."Document Type"::Invoice);
    end;

    [Test]
    procedure CreateAndPostSalesCreditMemoWithSingleLine();
    var
        SalesLine: Record "Sales Line";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Single Line.
        CreateAndPostSalesDocumentWithSingleLine(SalesLine."Document Type"::"Credit Memo");
    end;

    local procedure CreateAndPostSalesDocumentWithSingleLine(DocumentType: Option);
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
        OIOUBLExportSalesCrMemo: Codeunit "OIOUBL-Export Sales Cr. Memo";
        DocumentNo: Code[20];
        TaxAmount: Decimal;
    begin
        // [GIVEN] Posted Sales Document with a single line.
        Initialize();
        CreateSalesDocument(SalesLine, DocumentType, SalesLine.Type::Item, LibraryInventory.CreateItem(Item));
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        TaxAmount := (SalesLine."Line Amount" * SalesLine."VAT %") / 100;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        if DocumentType = SalesLine."Document Type"::Invoice then
            SalesInvoiceHeader.GET(DocumentNo)
        else
            SalesCrMemoHeader.GET(DocumentNo);

        // [WHEN] Electronic Invoice or Credit Memo created.
        if DocumentType = SalesLine."Document Type"::Invoice then
            OIOUBLExportSalesInvoice.ExportXML(SalesInvoiceHeader)
        else
            OIOUBLExportSalesCrMemo.ExportXML(SalesCrMemoHeader);

        // [THEN] The following values are verified on generated xml file of Electronic Invoice or Credit Memo: Sales Document No., Tax Amount, BaseQuantity.
        VerifyDocumentNoAndTaxAmount(DocumentNo, TaxAmount);
    end;

    [Test]
    procedure ElectronicSalesCreditMemoWithMultipleGL();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Multiple GL and different VAT type and %.
        CreateAndPostSalesDocumentWithMultipleGL(SalesHeader."Document Type"::"Credit Memo");
    end;

    [Test]
    procedure ElectronicSalesInvoiceWithMultipleGL();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice with Multiple GL and different VAT type and %.
        CreateAndPostSalesDocumentWithMultipleGL(SalesHeader."Document Type"::Invoice);
    end;

    local procedure CreateAndPostSalesDocumentWithMultipleGL(DocumentType: Option);
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
        OIOUBLExportSalesCrMemo: Codeunit "OIOUBL-Export Sales Cr. Memo";
        DocumentNo: Code[20];
        TaxAmount: Decimal;
    begin
        // [GIVEN] Posted Sales Document with a multiple GL and different VAT type and %.
        Initialize();
        CreateSalesDocument(SalesLine, DocumentType, SalesLine.Type::"G/L Account", CreateGLAccount(FindNormalVAT()));
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", CreateGLAccount(FindZeroVAT()));
        CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::"G/L Account",
          CreateGLAccount(FindReverseChargeVAT(VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT")));
        TaxAmount := CalculateTaxAmount(SalesHeader);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        if DocumentType = SalesLine."Document Type"::Invoice then
            SalesInvoiceHeader.GET(DocumentNo)
        else
            SalesCrMemoHeader.GET(DocumentNo);

        // [WHEN] Electronic Invoice or Credit Memo created.
        if DocumentType = SalesLine."Document Type"::Invoice then
            OIOUBLExportSalesInvoice.ExportXML(SalesInvoiceHeader)
        else
            OIOUBLExportSalesCrMemo.ExportXML(SalesCrMemoHeader);

        // [THEN] The following values are verified on generated xml file of Electronic Invoice or Credit Memo: Sales Document No., Tax Amount, BaseQuantity.
        VerifyDocumentNoAndTaxAmount(DocumentNo, TaxAmount);
    end;

    [Test]
    procedure ElectronicSalesCreditMemoMultipleItemsChargeItemAndGL();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Multiple Item,Charge Item and GL.
        CreateAndPostSalesDocumentMultipleItemsChargeItemAndGL(
          SalesHeader."Document Type"::"Credit Memo");
    end;

    [Test]
    procedure ElectronicSalesInvoiceMultipleItemsChargeItemAndGL();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice with Multiple Item,Charge Item and GL.
        CreateAndPostSalesDocumentMultipleItemsChargeItemAndGL(
          SalesHeader."Document Type"::Invoice);
    end;

    local procedure CreateAndPostSalesDocumentMultipleItemsChargeItemAndGL(DocumentType: Option);
    var
        Item: Record Item;
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        UnitOfMeasure: Record "Unit of Measure";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
        OIOUBLExportSalesCrMemo: Codeunit "OIOUBL-Export Sales Cr. Memo";
        DocumentNo: Code[20];
        TaxAmount: Decimal;
    begin
        // [GIVEN] Posted Sales Document with a multiple Item, Charge Item and GL.
        Initialize();
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        CreateSalesDocument(SalesLine, DocumentType, SalesLine.Type::Item, LibraryInventory.CreateItem(Item));
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItem(Item));
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
        if DocumentType = SalesLine."Document Type"::Invoice then
            SalesInvoiceHeader.GET(DocumentNo)
        else
            SalesCrMemoHeader.GET(DocumentNo);

        // [WHEN] Electronic Invoice or Credit Memo created.
        if DocumentType = SalesLine."Document Type"::Invoice then
            OIOUBLExportSalesInvoice.ExportXML(SalesInvoiceHeader)
        else
            OIOUBLExportSalesCrMemo.ExportXML(SalesCrMemoHeader);

        // [THEN] The following values are verified on generated xml file of Electronic Invoice or Credit Memo: Sales Document No., Tax Amount, BaseQuantity.
        VerifyDocumentNoAndTaxAmount(DocumentNo, TaxAmount);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ElectronicSalesCreditMemoSalesLineTypeBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Line Type Blank.
        CreateAndPostSalesDocumentSalesLineTypeBlank(
          SalesHeader."Document Type"::"Credit Memo", FindStandardText(), '');  // Use Blank for Descrption.
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ElectronicSalesInvoiceSalesLineTypeBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice Sales Line Type Blank.
        CreateAndPostSalesDocumentSalesLineTypeBlank(
          SalesHeader."Document Type"::Invoice, FindStandardText(), '');  // Use Blank for Descrption.
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ElectronicSalesCreditMemoSalesLineNoBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Line No. Blank.
        CreateAndPostSalesDocumentSalesLineTypeBlank(
          SalesHeader."Document Type"::"Credit Memo", '', 'Follow the Items Below');  // Use Blank for Sales Line No.
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ElectronicSalesInvoiceSalesLineNoBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice Sales Line No. Blank.
        CreateAndPostSalesDocumentSalesLineTypeBlank(
          SalesHeader."Document Type"::Invoice, '', 'Follow the Items Below');  // Use Blank for Sales Line No.
    end;

    local procedure CreateAndPostSalesDocumentSalesLineTypeBlank(DocumentType: Option; LineNo: Code[20]; Descrption: Text[50]);
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
        OIOUBLExportSalesCrMemo: Codeunit "OIOUBL-Export Sales Cr. Memo";
        DocumentNo: Code[20];
        TaxAmount: Decimal;
    begin
        // [GIVEN] Created and Posted Sales Document Sales Line Type Blank
        Initialize();
        CreateSalesDocument(SalesLine, DocumentType, SalesLine.Type::Item, LibraryInventory.CreateItem(Item));
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        CreateSalesLineWithBlankLines(
          SalesLine."Line No.", DocumentType, SalesHeader."No.", LineNo, Descrption);  // Use Blank for Descrption.
        TaxAmount := CalculateTaxAmount(SalesHeader);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        if DocumentType = SalesLine."Document Type"::Invoice then
            SalesInvoiceHeader.GET(DocumentNo)
        else
            SalesCrMemoHeader.GET(DocumentNo);

        // [WHEN] Electronic Invoice or Credit Memo created.
        if DocumentType = SalesLine."Document Type"::Invoice then
            OIOUBLExportSalesInvoice.ExportXML(SalesInvoiceHeader)
        else
            OIOUBLExportSalesCrMemo.ExportXML(SalesCrMemoHeader);

        // [THEN] The following values are verified on generated xml file of Electronic Invoice or Credit Memo: Sales Document No., Tax Amount, BaseQuantity.
        VerifyDocumentNoAndTaxAmount(DocumentNo, TaxAmount);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ElectronicSalesCreditMemoSalesLineTypeAndNoBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Credit Memo from posted Sales Credit Memo with Type and Line No. Blank.
        CreateAndPostSalesDocumentSalesLineTypeAndNoBlank(
          SalesHeader."Document Type"::"Credit Memo");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ElectronicSalesInvoiceSalesLineTypeAndNoBlank();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify created Electronic Invoice from posted Sales Invoice with Type and Line No. Blank.
        CreateAndPostSalesDocumentSalesLineTypeAndNoBlank(SalesHeader."Document Type"::Invoice);
    end;

    local procedure CreateAndPostSalesDocumentSalesLineTypeAndNoBlank(DocumentType: Option);
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
        OIOUBLExportSalesCrMemo: Codeunit "OIOUBL-Export Sales Cr. Memo";
        DocumentNo: Code[20];
        TaxAmount: Decimal;
    begin
        // [GIVEN] Created and Posted Sales Document Sales Line Type and Line No. Blank.
        Initialize();
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLineWithBlankLines(SalesLine."Line No.", DocumentType, SalesHeader."No.", '', 'Test');  // Use Blank for Sales Line No.,Value not important required only for test Purpoase.
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItem(Item));
        TaxAmount := CalculateTaxAmount(SalesHeader);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        if DocumentType = SalesLine."Document Type"::Invoice then
            SalesInvoiceHeader.GET(DocumentNo)
        else
            SalesCrMemoHeader.GET(DocumentNo);

        // [WHEN] Electronic Invoice or Credit Memo created.
        if DocumentType = SalesLine."Document Type"::Invoice then
            OIOUBLExportSalesInvoice.ExportXML(SalesInvoiceHeader)
        else
            OIOUBLExportSalesCrMemo.ExportXML(SalesCrMemoHeader);

        // [THEN] The following values are verified on generated xml file of Electronic Invoice or Credit Memo: Sales Document No., Tax Amount, BaseQuantity.
        VerifyDocumentNoAndTaxAmount(DocumentNo, TaxAmount);
    end;

    [Test]
    procedure CheckAllowanceChargeInOIOUBLReport();
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
        DocumentNo: Code[20];
        ExpectedResult: Decimal;
    begin
        // [SCENARIO 377873] OIOUBL XML File shouldn't contain XML node "LegalMonetaryTotal/AllowanceTotalAmount" and should contain XML node "InvoiceLine/AllowanceCharge" with line discount
        Initialize();

        // [GIVEN] Posted sales invoice with two sales lines
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice);

        // [GIVEN] First sales line with line discount = "X"
        ExpectedResult := CreateSalesLineWithDiscount(SalesHeader, LibraryRandom.RandIntInRange(1, 50));

        // [GIVEN] Second sales line without line discount
        CreateSalesLineWithDiscount(SalesHeader, 0);

        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // LibraryVariableStorage.Enqueue(DocumentNo);
        SalesInvoiceHeader.GET(DocumentNo);
        // [WHEN] Run report "OIOUBL-Create Elec. Invoices"
        // CODEUNIT.RUN(CODEUNIT::"OIOUBL-Export Sales Invoice",SalesInvoiceHeader);
        OIOUBLExportSalesInvoice.ExportXML(SalesInvoiceHeader);

        // [THEN] OIOUBL XML file does not contain XML node "LegalMonetaryTotal/AllowanceTotalAmount"
        // [THEN] Contains XML node "InvoiceLine/cac:AllowanceCharge/cbc:Amount" with value = "X" for first invoice line
        // [THEN] Doesn't contain XML node "InvoiceLine/cac:AllowanceCharge" for second invoice line
        VerifyAllowanceCharge(DocumentNo, ExpectedResult);
    end;

    local procedure Initialize();
    var
        SalesHeader: Record "Sales Header";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        CLEAR(LibraryVariableStorage);
        UpdateSalesReceivablesSetup();
        UpdateOIOUBLCountryRegionCode();
        LibraryERM.DisableMyNotifications(CopyStr(USERID(), 1, 50), SalesHeader.GetModifyCustomerAddressNotificationId());

        DocumentSendingProfile.DELETEALL();
        DocumentSendingProfile.INIT();
        DocumentSendingProfile.Default := true;
        DocumentSendingProfile."Electronic Format" := 'OIOUBL';
        DocumentSendingProfile.INSERT();

        OIOUBLNewFileMock.Setup(OIOUBLNewFileMock);
    end;

    local procedure CalculateTaxAmount(SalesHeader: Record "Sales Header"): Decimal;
    var
        TaxAmount: Decimal;
    begin
        SalesHeader.CALCFIELDS(Amount, "Amount Including VAT");
        TaxAmount := SalesHeader."Amount Including VAT" - SalesHeader.Amount;
        exit(TaxAmount);
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

    local procedure CreateSalesDocument(var SalesLine: Record "Sales Line"; DocumentType: Option; Type: Option; No: Code[20]);
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLine(SalesLine, SalesHeader, Type, No);
    end;

    local procedure CreateSalesHeader(var SalesHeader: Record "Sales Header"; DocumentType: Option);
    var
        PostCode: Record "Post Code";
    begin
        LibraryERM.FindPostCode(PostCode);
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CreateCustomer());
        SalesHeader.VALIDATE("Sell-to Contact", SalesHeader."No.");
        SalesHeader.VALIDATE("Bill-to Address", SalesHeader."No.");
        SalesHeader.VALIDATE("Bill-to City", PostCode.City);
        SalesHeader.MODIFY(true);
        ClearVATRegistrationForCustomer(SalesHeader."Sell-to Customer No.");
    end;

    local procedure CreateSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Type: Option; No: Code[20]);
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, Type, No, LibraryRandom.RandDec(10, 2));  // Random Value for Quantity.
        SalesLine.VALIDATE("Unit Price", LibraryRandom.RandDec(10, 2));  // Random Value for Unit Price.
        SalesLine.VALIDATE("Unit of Measure", UnitOfMeasure.Code);
        SalesLine.MODIFY(true);
    end;

    local procedure CreateSalesLineWithBlankLines(LineNo: Integer; DocumentType: Option; DocumentNo: Code[20]; No: Code[20]; Description: Text[50]);
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

    local procedure CreateSalesLineWithDiscount(SalesHeader: Record "Sales Header"; Discount: Integer): Decimal;
    var
        SalesLine: Record "Sales Line";
    begin
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo());
        SalesLine.VALIDATE("Line Discount %", Discount);
        SalesLine.MODIFY(true);
        exit(SalesLine."Inv. Discount Amount" + SalesLine."Line Discount Amount");
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

    local procedure FindReverseChargeVAT(VATCalculationType: Option): Code[20];
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
        SalesReceivablesSetup.GET();
        SalesReceivablesSetup.VALIDATE("OIOUBL-Cr. Memo Path", TEMPORARYPATH());
        SalesReceivablesSetup.VALIDATE("OIOUBL-Invoice Path", TEMPORARYPATH());
        SalesReceivablesSetup.VALIDATE("OIOUBL-Default Profile Code", CreateOIOUBLProfile());
        SalesReceivablesSetup.MODIFY(true);
    end;

    local procedure CreateOIOUBLProfile(): Code[10];
    var
        OIOUBLProfile: Record "OIOUBL-Profile";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        with OIOUBLProfile do begin
            VALIDATE("OIOUBL-Code", LibraryUtility.GenerateRandomCode(FIELDNO("OIOUBL-Code"), DATABASE::"OIOUBL-Profile"));
            VALIDATE("OIOUBL-Profile ID", DefaultProfileIDTxt);

            INSERT(true);
            exit("OIOUBL-Code");
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

    local procedure VerifyDocumentNoAndTaxAmount(DocumentNo: Code[20]; TaxAmount: Decimal);
    begin
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath()); // Initialize generated Electronic Invoice and Credit Memo.
        LibraryXMLReadOnServer.VerifyNodeValue(IDTxt, DocumentNo);
        LibraryXMLReadOnServer.VerifyNodeValue(TaxAmountTxt, FORMAT(ROUND(TaxAmount, LibraryERM.GetAmountRoundingPrecision()), 0, '<Precision,2:3><Sign><Integer><Decimals><Comma,.>'));
        LibraryXMLReadOnServer.VerifyNodeValue(BaseQuantityTxt, '1');
    end;

    local procedure VerifyAllowanceCharge(DocumentNo: Code[20]; ExpectedValue: Decimal);
    begin
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath());
        LibraryXMLReadOnServer.VerifyNodeValue(IDTxt, DocumentNo);
        LibraryXMLReadOnServer.VerifyElementAbsenceInSubtree('cac:LegalMonetaryTotal', 'cbc:AllowanceTotalAmount');
        Assert.AreEqual(2, LibraryXMLReadOnServer.GetNodesCount('cac:InvoiceLine'), WrongInvoiceLineCountErr);
        LibraryXMLReadOnServer.VerifyNodeValueInSubtree('cac:InvoiceLine', 'cbc:Amount', FORMAT(ExpectedValue, 0, '<Precision,2:3><Sign><Integer><Decimals><Comma,.>'));
        Assert.AreEqual(1, LibraryXMLReadOnServer.GetNodesCount('cac:AllowanceCharge'), WrongAllowanceChargeErr);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024]);
    begin
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := true;
    end;
}

