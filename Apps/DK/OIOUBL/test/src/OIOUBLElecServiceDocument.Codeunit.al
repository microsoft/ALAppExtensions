// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148055 "OIOUBL-Elec. Service Document"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun();
    begin
        // [FEATURE] [OIOUBL]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryService: Codeunit "Library - Service";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryXMLReadOnServer: Codeunit "Library - XML Read OnServer";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        OIOUBLNewFileMock: Codeunit "OIOUBL-File Events Mock";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        Assert: Codeunit Assert;
        IDCapTxt: Label 'cbc:ID';
        TaxAmountCapTxt: Label 'cbc:TaxExclusiveAmount';
        AccountingCostCodeCapTxt: Label 'cbc:AccountingCostCode';
        OIOUBLFormatNameTxt: Label 'OIOUBL';
        PEPPOLFormatNameTxt: Label 'PEPPOL';
        DefaultCodeTxt: Label 'DEFAULT';
        NonExistingDocumentFormatErr: Label 'The electronic document format OIOUBL does not exist for the document type %1.', Comment = '%1 = Service Invoice Document Type';
        isInitialized: Boolean;

    [Test]
    procedure TestGetCustomerVATRegNoIncCustomerCountryCode();
    var
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        VatNo: Text[20];
    begin
        VatNo := Format(LibraryRandom.RandIntInRange(1000, 99999999));
        Assert.AreEqual('UK' + VatNo, OIOUBLDocumentEncode.GetCustomerVATRegNoIncCustomerCountryCode(VatNo, 'UK'), 'UK addad to VatNo expected');
        Assert.AreEqual('SE' + VatNo, OIOUBLDocumentEncode.GetCustomerVATRegNoIncCustomerCountryCode('SE' + CopyStr(VatNo, 1, 18), 'SE'), 'No extra SE not addad');
    end;

    [Test]
    procedure TestGetCompanyVATRegNoOldAndGetCompanyVATRegNoActTheSame();
    var
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        vatno: Text[20];
        OldError: Text;
    begin
        asserterror vatno := OIOUBLDocumentEncode.GetCompanyVATRegNoOld('12345678901234567890');
        OldError := GetLastErrorText();
        asserterror vatno := FORMAT(OIOUBLDocumentEncode.GetCompanyVATRegNo('12345678901234567890'));
        Assert.AreEqual(OldError, GetLastErrorText(), 'Error should not change');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoSingleLineWithVATWithoutAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Credit Memo with single Item Line with VAT and without Account Code.

        // Setup: Create and Post Service Credit Memo with single Item Line with VAT and without Account Code.
        Initialize();
        ElectronicServiceCreditMemoWithSingleItemLine(LibraryRandom.RandDec(10, 2), '');  // Random value for VAT Percent and Blank for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoSingleLineWithVATAndAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Credit Memo with single Item Line with VAT and Account Code.

        // Setup: Create and Post Service Credit Memo with single Item Line with VAT and Account Code.
        Initialize();
        ElectronicServiceCreditMemoWithSingleItemLine(LibraryRandom.RandDec(10, 2), LibraryUtility.GenerateGUID());  // Random value for VAT Percent and GUID for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoSingleLineWithoutVATAndAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Credit Memo with single Item Line without VAT and Account Code.

        // Setup: Create and Post Service Credit Memo with single Item Line without VAT and Account Code.
        Initialize();
        ElectronicServiceCreditMemoWithSingleItemLine(0, '');  // Zero for VAT Percent and blank value for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoSingleLineWithoutVATWithAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Credit Memo with single Item Line without VAT and with Account Code.

        // Setup: Create and Post Service Credit Memo with single Item Line without VAT and with Account Code.
        Initialize();
        ElectronicServiceCreditMemoWithSingleItemLine(0, LibraryUtility.GenerateGUID());  // Zero value for VAT Percent and GUID for Account Code.
    end;

    local procedure ElectronicServiceCreditMemoWithSingleItemLine(NewVATPct: Decimal; AccountCode: Text[30]);
    var
        ServiceLine: Record "Service Line";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
        TaxAmount: Decimal;
        OldVATPct: Decimal;
    begin
        // Update Service Management Setup, Create and Post Service Credit Memo with single Item Line.
        UpdateServiceSetup();
        OldVATPct := FindAndUpdateVATPostingSetupPct(VATPostingSetup, NewVATPct);
        CreateServiceDocument(
            ServiceLine, ServiceLine."Document Type"::"Credit Memo", CreateCustomer(AccountCode, VATPostingSetup."VAT Bus. Posting Group"),
            ServiceLine.Type::Item, CreateItem(VATPostingSetup."VAT Prod. Posting Group"));
        PostedDocumentNo := PostServiceCrMemo(ServiceLine."Document No.");
        TaxAmount := ROUND((ServiceLine."Line Amount" * ServiceLine."VAT %") / 100, LibraryERM.GetAmountRoundingPrecision());  // Calculate TAX Amount.

        // Exercise.
        RunReportCreateElecServiceCrMemos(PostedDocumentNo);

        // Verify: Verify Document Number, Account Code and Tax Amount on generated XML file of Electronic Service Credit Memo.
        VerifyTaxOnElectronicServiceDocument(PostedDocumentNo, AccountCode, TaxAmount);

        // Tear Down.
        UpdateVATPostingSetupPct(VATPostingSetup, OldVATPct);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoMultipleLineWithVATWithoutAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Credit Memo with multiple Item Line with VAT and without Account Code.

        // Setup: Create and Post Service Credit Memo with multiple Item Line with VAT and without Account Code.
        Initialize();
        ElectronicServiceCreditMemoWithMultipleItemLine(LibraryRandom.RandDec(10, 2), '');  // Random value for VAT Percent and Blank for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoMultipleLineWithVATAndAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Credit Memo with multiple Item Line with VAT and Account Code.

        // Setup: Create and Post Service Credit Memo with multiple Item Line with VAT and Account Code.
        Initialize();
        ElectronicServiceCreditMemoWithMultipleItemLine(LibraryRandom.RandDec(10, 2), LibraryUtility.GenerateGUID());  // Random value for VAT Percent and GUID for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoMultipleLineWithoutVATAndAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Credit Memo with multiple Item Line without VAT and Account Code.

        // Setup: Create and Post Service Credit Memo with multiple Item Line without VAT and Account Code.
        Initialize();
        ElectronicServiceCreditMemoWithMultipleItemLine(0, '');  // Zero for VAT Percent and blank value for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoMultipleLineWithoutVATWithAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Credit Memo with multiple Item Line without VAT and with Account Code.

        // Setup: Create and Post Service Credit Memo with multiple Item Lines without VAT and with Account Code.
        Initialize();
        ElectronicServiceCreditMemoWithMultipleItemLine(0, LibraryUtility.GenerateGUID());  // Zero value for VAT Percent and GUID for Account Code.
    end;

    local procedure ElectronicServiceCreditMemoWithMultipleItemLine(NewVATPct: Decimal; AccountCode: Text[30]);
    var
        ServiceHeader: Record "Service Header";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
        TaxAmount: Decimal;
        OldVATPct: Decimal;
    begin
        // Update Service Management Setup, Create and Post Service Credit Memo with Multiple Item Line.
        UpdateServiceSetup();
        OldVATPct := FindAndUpdateVATPostingSetupPct(VATPostingSetup, NewVATPct);
        CreateServiceHeader(
        ServiceHeader, ServiceHeader."Document Type"::"Credit Memo", CreateCustomer(AccountCode, VATPostingSetup."VAT Bus. Posting Group"));
        TaxAmount := CreateMultipleServiceLine(ServiceHeader, VATPostingSetup."VAT Prod. Posting Group");
        PostedDocumentNo := PostServiceCrMemo(ServiceHeader."No.");

        // Exercise.
        RunReportCreateElecServiceCrMemos(PostedDocumentNo);

        // Verify: Verify Document Number, Account Code and Tax Amount on generated XML file of Electronic Service Credit Memos.
        VerifyTaxOnElectronicServiceDocument(PostedDocumentNo, AccountCode, TaxAmount);

        // Tear Down.
        UpdateVATPostingSetupPct(VATPostingSetup, OldVATPct);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvSingleLineWithVATWithoutAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Invoice with single Item Line with VAT and without Account Code.

        // Setup: Create and Post Service Invoice with single Item Line with VAT and without Account Code.
        Initialize();
        ElectronicServiceInvoiceWithSingleItemLine(LibraryRandom.RandDec(10, 2), '');  // Random value for Percent and Blank for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvSingleLineWithVATAndAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Invoice with single Item Line with VAT and Account Code.

        // Setup: Create and Post Service Invoice with single Item Line with VAT and Account Code.
        Initialize();
        ElectronicServiceInvoiceWithSingleItemLine(LibraryRandom.RandDec(10, 2), LibraryUtility.GenerateGUID());  // Random value for VAT Percent and GUID for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvSingleLineWithoutVATAndAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Invoice with single Item Line without VAT and Account Code.

        // Setup: Create and Post Service Invoice with single Item Line without VAT and Account Code.
        Initialize();
        ElectronicServiceInvoiceWithSingleItemLine(0, '');  // Zero for VAT Percent and blank value for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvSingleLineWithoutVATWithAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Invoice with single Item Line without VAT and with Account Code.

        // Setup: Create and Post Service Invoice with single Item Line without VAT and with Account Code.
        Initialize();
        ElectronicServiceInvoiceWithSingleItemLine(0, LibraryUtility.GenerateGUID());  // Zero value for VAT Percent and Random value for Account Code.
    end;

    local procedure ElectronicServiceInvoiceWithSingleItemLine(VATPct: Decimal; AccountCode: Text[30]);
    var
        ServiceLine: Record "Service Line";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
        TaxAmount: Decimal;
        OldVATPct: Decimal;
    begin
        // Update Service Management Setup, Create and Post Service Invoice with single Item Line.
        UpdateServiceSetup();
        OldVATPct := FindAndUpdateVATPostingSetupPct(VATPostingSetup, VATPct);
        CreateServiceDocument(
            ServiceLine, ServiceLine."Document Type"::Invoice, CreateCustomer(AccountCode, VATPostingSetup."VAT Bus. Posting Group"),
            ServiceLine.Type::Item, CreateItem(VATPostingSetup."VAT Prod. Posting Group"));
        PostedDocumentNo := PostServiceInvoice(ServiceLine."Document No.");
        TaxAmount := ROUND((ServiceLine."Line Amount" * ServiceLine."VAT %") / 100, LibraryERM.GetAmountRoundingPrecision());  // Calculate TAX Amount.

        // Exercise.
        RunReportCreateElecServiceInvoices(PostedDocumentNo);

        // Verify: Verify Document Number, Account Code and Tax Amount on generated XML file of Electronic Service Invoice.
        VerifyTaxOnElectronicServiceDocument(PostedDocumentNo, AccountCode, TaxAmount);

        // Tear Down.
        UpdateVATPostingSetupPct(VATPostingSetup, OldVATPct);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvMultipleLineWithVATWithoutAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Invoice with multiple Item Line with VAT and without Account Code.

        // Setup: Create and Post Service Invoice with multiple Item Lines with VAT and without Account Code.
        Initialize();
        ElectronicServiceInvoiceWithMultipleItemLine(LibraryRandom.RandDec(10, 2), '');  // Random value for VAT Percent and Blank for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvMultipleLineWithVATWithAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Invoice with multiple Item Line with VAT and Account Code.

        // Setup: Create and Post Service Invoice with multiple Item Lines with VAT and Account Code.
        Initialize();
        ElectronicServiceInvoiceWithMultipleItemLine(LibraryRandom.RandDec(10, 2), LibraryUtility.GenerateGUID());  // Random value for VAT Percent and GUID for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvMultipleLineWithoutVATAndAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Invoice with multiple Item Line without VAT and Account Code.

        // Setup: Create and Post Service Invoice with multiple Item Lines without VAT and Account Code.
        Initialize();
        ElectronicServiceInvoiceWithMultipleItemLine(0, '');  // Zero for VAT Percent and blank value for Account Code.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvMultipleLineWithoutVATWithAccCode();
    begin
        // Verify generated XML file after creating Electronic Service Invoice with multiple Item Line without VAT and with Account Code.

        // Setup: Create and Post Service Invoice with multiple Item Lines without VAT and with Account Code.
        Initialize();
        ElectronicServiceInvoiceWithMultipleItemLine(0, LibraryUtility.GenerateGUID());  // Zero value for VAT Percent and Random value for Account Code.
    end;

    local procedure ElectronicServiceInvoiceWithMultipleItemLine(VATPct: Decimal; AccountCode: Text[30]);
    var
        ServiceHeader: Record "Service Header";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
        TaxAmount: Decimal;
        OldVATPct: Decimal;
    begin
        // Update Service Management Setup, Create and Post Service Invoice with multiple Item Line.
        UpdateServiceSetup();
        OldVATPct := FindAndUpdateVATPostingSetupPct(VATPostingSetup, VATPct);
        CreateServiceHeader(
        ServiceHeader, ServiceHeader."Document Type"::Invoice, CreateCustomer(AccountCode, VATPostingSetup."VAT Bus. Posting Group"));
        TaxAmount := CreateMultipleServiceLine(ServiceHeader, VATPostingSetup."VAT Prod. Posting Group");
        PostedDocumentNo := PostServiceInvoice(ServiceHeader."No.");

        // Exercise.
        RunReportCreateElecServiceInvoices(PostedDocumentNo);

        // Verify: Verify Document Number, Account Code and Tax Amount on generated XML file of Electronic Service Invoices.
        VerifyTaxOnElectronicServiceDocument(PostedDocumentNo, AccountCode, TaxAmount);

        // Tear Down.
        UpdateVATPostingSetupPct(VATPostingSetup, OldVATPct);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicServiceInvoiceUsingTypeBlank();
    var
        ServiceLine: Record "Service Line";
    begin
        // Verify created Electronic Invoices from posted Service Invoice with a Service Line Type blank.

        // Setup.
        Initialize();
        CreateElectronicServiceInvoice(ServiceLine.Type::" ", FindStandardText());  // Using Service Line - Type as blank.
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicServiceInvoiceUsingNumberBlank();
    var
        ServiceLine: Record "Service Line";
    begin
        // Verify created Electronic Invoices from posted Service Invoice with a Service Line Number blank.

        // Setup.
        Initialize();
        CreateElectronicServiceInvoice(ServiceLine.Type::Item, '');  // Using Service Line - Type as Item and Number as blank.
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicServiceInvoiceUsingTypeAndNumberBlank();
    var
        ServiceLine: Record "Service Line";
    begin
        // Verify created Electronic Invoices from posted Service Invoice with a Service Line Type and Number both blank.

        // Setup.
        Initialize();
        CreateElectronicServiceInvoice(ServiceLine.Type::" ", '');  // Using Service Line - Type and Number as blank.
    end;

    local procedure CreateElectronicServiceInvoice(Type: Option; ItemNo: Code[20]);
    var
        ServiceLine: Record "Service Line";
        ServiceHeader: Record "Service Header";
        PostedDocumentNo: Code[20];
    begin
        // Update Service Management Setup, Create, Update and Post Service Invoice.
        UpdateServiceSetup();
        CreateServiceDocumentWithItem(ServiceLine, ServiceLine."Document Type"::Invoice);
        ServiceHeader.GET(ServiceLine."Document Type", ServiceLine."Document No.");
        CreateAndUpdateServiceLineTypeAndNumber(ServiceHeader, Type, ItemNo);
        PostedDocumentNo := PostServiceInvoice(ServiceHeader."No.");

        // Exercise.
        RunReportCreateElecServiceInvoices(PostedDocumentNo);

        // Verify: Verify Service Invoice Number and Account Code with Service Header - Account Code on generated xml file of Electronic Invoice.
        VerifyElectronicServiceDocument(PostedDocumentNo, ServiceHeader."OIOUBL-Account Code");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvoiceUsingMultipleGLAccount();
    var
        ServiceHeader: Record "Service Header";
        PostedDocumentNo: Code[20];
    begin
        // Verify created Electronic Invoices from posted Service Invoice using multiple G/L Account Service Line.

        // Setup: Update Service Management Setup, Create, Update and Post Service Invoice.
        Initialize();
        CreateServiceDocumentWithGLAccount(ServiceHeader, ServiceHeader."Document Type"::Invoice);
        PostedDocumentNo := PostServiceInvoice(ServiceHeader."No.");

        // Exercise.
        RunReportCreateElecServiceInvoices(PostedDocumentNo);

        // Verify: Verify Service Invoice Number and Account Code with Service Header - Account Code on generated xml file of Electronic Invoice.
        // Verify: Unit of Measure for Service Line with Type = G/L Account is "EA".
        VerifyElectronicServiceDocument(PostedDocumentNo, ServiceHeader."OIOUBL-Account Code");
        VerifyUnitOfMeasureForInvoiceLineOnElectronicDocument(PEPPOLManagement.GetUoMforPieceINUNECERec20ListID(), 0);
        VerifyUnitOfMeasureForInvoiceLineOnElectronicDocument(PEPPOLManagement.GetUoMforPieceINUNECERec20ListID(), 1);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvoiceUsingMultipleGLAccountAndItem();
    var
        Item: Record Item;
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        PostedDocumentNo: Code[20];
    begin
        // Verify created Electronic Invoices from posted Service Invoice using multiple G/L Account and Item on Service Line.

        // Setup: Update Service Management Setup, Create, Update and Post Service Invoice.
        Initialize();
        CreateServiceDocumentWithGLAccount(ServiceHeader, ServiceHeader."Document Type"::Invoice);
        CreateServiceLine(
            ServiceLine, ServiceHeader, ServiceLine.Type::Item, LibraryInventory.CreateItem(Item), ServiceHeader."OIOUBL-Account Code");
        PostedDocumentNo := PostServiceInvoice(ServiceLine."Document No.");

        // Exercise.
        RunReportCreateElecServiceInvoices(PostedDocumentNo);

        // Verify: Verify Service Invoice Number and Account Code with Service Header - Account Code on generated xml file of Electronic Invoice.
        // Verify: Unit of Measure for Service Line with Type = G/L Account is "EA".
        // Verify: Unit of Measure for Service Line with Type = Item is "International Standard Code" of "Unit of Measure Code" of Service Line.
        VerifyElectronicServiceDocument(PostedDocumentNo, ServiceHeader."OIOUBL-Account Code");
        VerifyUnitOfMeasureForInvoiceLineOnElectronicDocument(PEPPOLManagement.GetUoMforPieceINUNECERec20ListID(), 0);
        VerifyUnitOfMeasureForInvoiceLineOnElectronicDocument(PEPPOLManagement.GetUoMforPieceINUNECERec20ListID(), 1);
        VerifyUnitOfMeasureForInvoiceLineOnElectronicDocument(GetOIOUBLUoMCode(ServiceLine."Unit of Measure Code"), 2);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvoiceUsingMultipleItemAndGLAccount();
    var
        ServiceLine: Record "Service Line";
        PostedDocumentNo: Code[20];
        OIOUBLUoMs: List of [Code[10]];
    begin
        // Verify created Electronic Invoices from posted Service Invoice using multiple Item and G/L Account Service Line.

        // Setup: Update Service Management Setup, Create, Update and Post Service Invoice.
        Initialize();
        CreateServiceDocumentWithMultipleLineAndUOM(ServiceLine, ServiceLine."Document Type"::Invoice, OIOUBLUoMs);
        PostedDocumentNo := PostServiceInvoice(ServiceLine."Document No.");

        // Exercise.
        RunReportCreateElecServiceInvoices(PostedDocumentNo);

        // Verify: Verify Service Invoice Number and Account Code with Service Header - Account Code on generated xml file of Electronic Invoice.        
        // Verify: Unit of Measure for Service Line with Type = Item is "International Standard Code" of "Unit of Measure Code" of Service Line.
        // Verify: Unit of Measure for Service Line with Type = G/L Account is "EA".
        VerifyElectronicServiceDocument(PostedDocumentNo, ServiceLine."OIOUBL-Account Code");
        VerifyUnitOfMeasureForInvoiceLineOnElectronicDocument(OIOUBLUoMs.Get(1), 0);
        VerifyUnitOfMeasureForInvoiceLineOnElectronicDocument(OIOUBLUoMs.Get(2), 1);
        VerifyUnitOfMeasureForInvoiceLineOnElectronicDocument(OIOUBLUoMs.Get(3), 2);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoDecimalUnitPrice();
    var
        ServiceLine: Record "Service Line";
        PostedDocumentNo: Code[20];
        TaxAmount: Decimal;
    begin
        // Verify created Electronic Service Credit Memo from posted Service Credit Memo for an item with more than two decimal digits in Unit Price.

        // Setup: Update Service Management Setup, Create and Post Service Credit Memo.
        Initialize();
        UpdateServiceSetup();
        CreateServiceDocument(
            ServiceLine, ServiceLine."Document Type"::"Credit Memo", CreateCustomer(LibraryUtility.GenerateGUID(), ''),
            ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
        TaxAmount := ServiceLine."Line Amount" * ServiceLine."VAT %" / 100;
        PostedDocumentNo := PostServiceCrMemo(ServiceLine."Document No.");

        // Exercise.
        RunReportCreateElecServiceCrMemos(PostedDocumentNo);

        // Verify: Verify XML file of Electronic Credit Memo generated successfully for Item with more than two decimal digits in Unit Price.
        VerifyTaxOnElectronicServiceDocument(PostedDocumentNo, ServiceLine."OIOUBL-Account Code", TaxAmount);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvoiceDecimalUnitPrice();
    var
        ServiceLine: Record "Service Line";
        PostedDocumentNo: Code[20];
    begin
        // Verify created Electronic Service Invoice from posted Service Invoice for an item with more than two decimal digits in Unit Price.

        // Setup: Update Service Management Setup, Create and Post Service Invoice.
        Initialize();
        UpdateServiceSetup();
        CreateServiceDocument(
            ServiceLine, ServiceLine."Document Type"::Invoice, CreateCustomer(LibraryUtility.GenerateGUID(), ''),
            ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
        PostedDocumentNo := PostServiceInvoice(ServiceLine."Document No.");

        // Exercise.
        RunReportCreateElecServiceInvoices(PostedDocumentNo);

        // Verify: Verify XML file of Electronic Service Invoice generated successfully for Item with more than two decimal digits in Unit Price.
        VerifyElectronicServiceDocument(PostedDocumentNo, ServiceLine."OIOUBL-Account Code");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicServiceCrMemoUsingTypeBlank();
    var
        ServiceLine: Record "Service Line";
    begin
        // Verify created Electronic Credit Memo from posted Service Credit Memo with a Service Line Type blank.

        // Setup.
        Initialize();
        CreateElectronicServiceCrMemo(ServiceLine.Type::" ", FindStandardText());  // Using Service Line - Type as blank.
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicServiceCrMemoUsingNumberBlank();
    var
        ServiceLine: Record "Service Line";
    begin
        // Verify created Electronic Credit Memo from posted Service Credit Memo with a Service Line Number blank.

        // Setup.
        Initialize();
        CreateElectronicServiceCrMemo(ServiceLine.Type::Item, '');  // Using Service Line - Type as Item and Number as blank.
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicServiceCrMemoUsingTypeAndNumberBlank();
    var
        ServiceLine: Record "Service Line";
    begin
        // Verify created Electronic Credit Memo from posted Service Credit Memo with a Service Line Type and Number both blank.

        // Setup.
        Initialize();
        CreateElectronicServiceCrMemo(ServiceLine.Type::" ", '');  // Using Service Line - Type and Number as blank.
    end;

    local procedure CreateElectronicServiceCrMemo(Type: Option; ItemNo: Code[20]);
    var
        ServiceLine: Record "Service Line";
        ServiceHeader: Record "Service Header";
        PostedDocumentNo: Code[20];
    begin
        // Update Service Management Setup, Create, Update and Post Service Credit Memo.
        UpdateServiceSetup();
        CreateServiceDocumentWithItem(ServiceLine, ServiceLine."Document Type"::"Credit Memo");
        ServiceHeader.GET(ServiceLine."Document Type", ServiceLine."Document No.");
        CreateAndUpdateServiceLineTypeAndNumber(ServiceHeader, Type, ItemNo);
        PostedDocumentNo := PostServiceCrMemo(ServiceHeader."No.");

        // Exercise.
        RunReportCreateElecServiceCrMemos(PostedDocumentNo);

        // Verify: Verify Credit Memo Number and Account Code with Service Header - Account Code on generated xml file of Electronic Credit Memo.
        VerifyElectronicServiceDocument(PostedDocumentNo, ServiceHeader."OIOUBL-Account Code");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoUsingMultipleGLAccount();
    var
        ServiceHeader: Record "Service Header";
        PostedDocumentNo: Code[20];
    begin
        // Verify created Electronic Credit Memo from posted Service Credit Memo using multiple G/L Account Service Line.

        // Setup: Update Service Management Setup, Create, Update and Post Service Credit Memo.
        Initialize();
        CreateServiceDocumentWithGLAccount(ServiceHeader, ServiceHeader."Document Type"::"Credit Memo");
        PostedDocumentNo := PostServiceCrMemo(ServiceHeader."No.");

        // Exercise.
        RunReportCreateElecServiceCrMemos(PostedDocumentNo);

        // Verify: Verify Service Credit Memo Number and Account Code with Service Header - Account Code on generated xml file of Electronic Credit Memo.
        // Verify: Unit of Measure for Service Line with Type = G/L Account is "EA".
        VerifyElectronicServiceDocument(PostedDocumentNo, ServiceHeader."OIOUBL-Account Code");
        VerifyUnitOfMeasureForCrMemoLineOnElectronicDocument(PEPPOLManagement.GetUoMforPieceINUNECERec20ListID(), 0);
        VerifyUnitOfMeasureForCrMemoLineOnElectronicDocument(PEPPOLManagement.GetUoMforPieceINUNECERec20ListID(), 1);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoUsingMultipleGLAccountAndItem();
    var
        Item: Record Item;
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        PostedDocumentNo: Code[20];
    begin
        // Verify created Electronic Credit Memo from posted Service Credit Memo using multiple G/L Account and Item on Service Line.

        // Setup: Update Service Management Setup, Create, Update and Post Service Credit Memo.
        Initialize();
        CreateServiceDocumentWithGLAccount(ServiceHeader, ServiceHeader."Document Type"::"Credit Memo");
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, LibraryInventory.CreateItem(Item), ServiceHeader."OIOUBL-Account Code");
        PostedDocumentNo := PostServiceCrMemo(ServiceHeader."No.");

        // Exercise.
        RunReportCreateElecServiceCrMemos(PostedDocumentNo);

        // Verify: Verify Service Credit Memo Number and Account Code with Service Header - Account Code on generated xml file of Electronic Credit Memo.
        // Verify: Unit of Measure for Service Line with Type = G/L Account is "EA".
        // Verify: Unit of Measure for Service Line with Type = Item is "International Standard Code" of "Unit of Measure Code" of Service Line.
        VerifyElectronicServiceDocument(PostedDocumentNo, ServiceHeader."OIOUBL-Account Code");
        VerifyUnitOfMeasureForCrMemoLineOnElectronicDocument(PEPPOLManagement.GetUoMforPieceINUNECERec20ListID(), 0);
        VerifyUnitOfMeasureForCrMemoLineOnElectronicDocument(PEPPOLManagement.GetUoMforPieceINUNECERec20ListID(), 1);
        VerifyUnitOfMeasureForCrMemoLineOnElectronicDocument(GetOIOUBLUoMCode(ServiceLine."Unit of Measure Code"), 2);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCrMemoUsingMultipleItemAndGLAccount();
    var
        ServiceLine: Record "Service Line";
        PostedDocumentNo: Code[20];
        OIOUBLUoMs: List of [Code[10]];
    begin
        // Verify created Electronic Credit Memo from posted Service Credit Memo using multiple Item and G/L Account Service Line.

        // Setup: Update Service Management Setup, Create, Update and Post Service Credit Memo.
        Initialize();
        CreateServiceDocumentWithMultipleLineAndUOM(ServiceLine, ServiceLine."Document Type"::"Credit Memo", OIOUBLUoMs);
        PostedDocumentNo := PostServiceCrMemo(ServiceLine."Document No.");

        // Exercise.
        RunReportCreateElecServiceCrMemos(PostedDocumentNo);

        // Verify: Verify Service Credit Memo Number and Account Code with Service Header - Account Code on generated xml file of Electronic Credit Memo.
        // Verify: Unit of Measure for Service Line with Type = Item is "International Standard Code" of "Unit of Measure Code" of Service Line.
        // Verify: Unit of Measure for Service Line with Type = G/L Account is "EA".
        VerifyElectronicServiceDocument(PostedDocumentNo, ServiceLine."OIOUBL-Account Code");
        VerifyUnitOfMeasureForCrMemoLineOnElectronicDocument(OIOUBLUoMs.Get(1), 0);
        VerifyUnitOfMeasureForCrMemoLineOnElectronicDocument(OIOUBLUoMs.Get(2), 1);
        VerifyUnitOfMeasureForCrMemoLineOnElectronicDocument(OIOUBLUoMs.Get(3), 2);
    end;

    [Test]
    procedure FiltersIssuedFinChargeMemoLineOIOUBLExpIssuedFinChrg();
    var
        IssuedFinChargeMemoLine: Record "Issued Fin. Charge Memo Line";
        OIOUBLExpIssuedFinChrg: Codeunit "OIOUBL-Exp. Issued Fin. Chrg";
        ExpectedHeaderNo: Code[20];
        Filters: Text;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 266923] The function ContainsValidLine of "OIOUBL Exp. Issued Fin. Chrg." sets filters on the record "Issued Fin. Charge Memo Line"

        // [GIVEN] Record "Issued Fin. Charge Memo Line"
        IssuedFinChargeMemoLine.INIT();

        // [GIVEN] Random "Finance Charge Memo No." = 'FIN001'
        ExpectedHeaderNo :=
            LibraryUtility.GenerateRandomCode20(
                IssuedFinChargeMemoLine.FIELDNO("Finance Charge Memo No."), DATABASE::"Issued Fin. Charge Memo Line");

        // [WHEN] Invoke ContainsValidLine
        OIOUBLExpIssuedFinChrg.ContainsValidLine(IssuedFinChargeMemoLine, ExpectedHeaderNo);

        // [THEN] Filters of "Issued Fin. Charge Memo Line":
        // [THEN] "Finance Charge Memo No." = 'FIN001'
        Filters := IssuedFinChargeMemoLine.GETFILTERS();
        Assert.AreNotEqual(STRPOS(Filters, ExpectedHeaderNo), 0, 'Wrong filter on Issued Fin. Charge Memo Line');
    end;

    [Test]
    [HandlerFunctions('PostAndSendConfirmationModalPageHandler,SelectSendingOptionsSetFormatModalPageHandler')]
    procedure PostAndSendServiceInvoiceOIOUBL()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        // [SCENARIO 299031] Post and Send Service Invoice in case OIOUBL profile is selected.
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Invoice", Codeunit::"OIOUBL-Export Service Invoice");

        // [GIVEN] Service Invoice.
        CreateServiceDocumentWithItem(ServiceLine, ServiceLine."Document Type"::Invoice);
        FindServiceHeader(ServiceHeader, ServiceLine);

        // [WHEN] Run "Post and Send" codeunit for Service Invoice, select Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        Codeunit.Run(Codeunit::"Service-Post and Send", ServiceHeader);

        // [THEN] Electronic Document is created and saved to location, specified in Service Setup.
        // [THEN] "No. Printed" value of Posted Service Invoice increases by 1. Bug ID 349569.
        LibraryService.FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
        ServiceInvoiceHeader.TestField("OIOUBL-Electronic Invoice Created", true);
        ServiceInvoiceHeader.TestField("No. Printed", 1);
        VerifyElectronicServiceDocument(ServiceInvoiceHeader."No.", ServiceInvoiceHeader."OIOUBL-Account Code");

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsSetFormatModalPageHandler')]
    procedure SendPostedServiceInvoiceOIOUBL()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 299031] Send Posted Service Invoice in case OIOUBL profile is selected.
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Invoice", Codeunit::"OIOUBL-Export Service Invoice");

        // [GIVEN] Posted Service Invoice.
        PostedDocNo := CreateAndPostServiceInvoice();

        // [WHEN] Run "Send" for Posted Service Invoice, select Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        ServiceInvoiceHeader.SetRange("No.", PostedDocNo);
        ServiceInvoiceHeader.SendRecords();

        // [THEN] Electronic Document is created and saved to location, specified in Service Setup.
        // [THEN] "No. Printed" value of Posted Service Invoice increases by 1. Bug ID 349569.
        ServiceInvoiceHeader.Get(PostedDocNo);
        ServiceInvoiceHeader.TestField("OIOUBL-Electronic Invoice Created", true);
        ServiceInvoiceHeader.TestField("No. Printed", 1);
        VerifyElectronicServiceDocument(ServiceInvoiceHeader."No.", ServiceInvoiceHeader."OIOUBL-Account Code");

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ProfileSelectionMethodStrMenuHandler')]
    procedure SendMultiplePostedServiceInvoicesOIOUBL()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNoLst: List of [Code[20]];
        AccountCodeLst: List of [Text[30]];
        PostedDocNo: Code[20];
    begin
        // [FEATURE] [Zip]
        // [SCENARIO 299031] Send multiple Posted Service Invoices in case OIOUBL profile is selected.
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Invoice", CODEUNIT::"OIOUBL-Export Service Invoice");

        // [GIVEN] Default DocumentSendingProfile Disk::"Electronic Document", Format = OIOUBL; three Posted Service Invoices.
        PostedDocNoLst.AddRange(CreateAndPostServiceInvoice(), CreateAndPostServiceInvoice(), CreateAndPostServiceInvoice());

        // [WHEN] Run "Send" for these Posted Service Invoices.
        ServiceInvoiceHeader.SetFilter("No.", '%1|%2|%3', PostedDocNoLst.Get(1), PostedDocNoLst.Get(2), PostedDocNoLst.Get(3));
        ServiceInvoiceHeader.SendRecords();

        // [THEN] One ZIP file is created at the location, specified in Service Setup.
        // [THEN] ZIP file contains OIOUBL Electronic Document for each Posted Service Invoice.
        foreach PostedDocNo in PostedDocNoLst do begin
            ServiceInvoiceHeader.Get(PostedDocNo);
            ServiceInvoiceHeader.TestField("OIOUBL-Electronic Invoice Created", true);
            AccountCodeLst.Add(ServiceInvoiceHeader."OIOUBL-Account Code");
        end;
        VerifyElectronicServiceDocumentInZipArchive(PostedDocNoLst, AccountCodeLst);
    end;

    [Test]
    [HandlerFunctions('PostAndSendConfirmationModalPageHandler,SelectSendingOptionsSetFormatModalPageHandler')]
    procedure PostAndSendServiceInvoiceNonOIOUBL()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        // [SCENARIO 299031] Post and Send Service Invoice in case non-OIOUBL profile is selected.
        Initialize();
        UpdateCompanySwiftCode();

        // [GIVEN] Service Invoice.
        CreateServiceDocumentWithItem(ServiceLine, ServiceLine."Document Type"::Invoice);
        FindServiceHeader(ServiceHeader, ServiceLine);

        // [WHEN] Run "Post and Send" codeunit for Service Invoice, select Format = PEPPOL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(PEPPOLFormatNameTxt));
        Codeunit.Run(Codeunit::"Service-Post and Send", ServiceHeader);

        // [THEN] Electronic Document is not created at the location, specified in Service Setup - file path is not in the queue.
        LibraryService.FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
        ServiceInvoiceHeader.TestField("OIOUBL-Electronic Invoice Created", false);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('PostAndSendConfirmationModalPageHandler,SelectSendingOptionsSetFormatModalPageHandler')]
    procedure PostAndSendServiceInvoiceNonElectronicDocument()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        // [SCENARIO 299031] Post and Send Service Invoice in case Disk = No in Document Sending Profile.
        Initialize();

        // [GIVEN] Service Invoice.
        CreateServiceDocumentWithItem(ServiceLine, ServiceLine."Document Type"::Invoice);
        FindServiceHeader(ServiceHeader, ServiceLine);

        // [WHEN] Run "Post and Send" codeunit for Service Invoice, select Disk = No, Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::No);
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        Codeunit.Run(Codeunit::"Service-Post and Send", ServiceHeader);

        // [THEN] Electronic Document is not created at the location, specified in Service Setup - file path is not in the queue.
        LibraryService.FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
        ServiceInvoiceHeader.TestField("OIOUBL-Electronic Invoice Created", false);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsSetFormatModalPageHandler')]
    procedure SendPostedServiceInvoiceOIOUBLWithNonStandardCodeunit()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNo: Code[20];
        NonExistingCodeunitID: Integer;
    begin
        // [SCENARIO 327540] Send Posted Service Invoice to OIOUBL in case Electronic Document Format has non-standard "Codeunit ID".
        Initialize();

        // [GIVEN] Electronic Document Format OIOUBL for Service Invoice with nonexisting "Codeunit ID" = "C".
        NonExistingCodeunitID := GetNonExistingCodeunitID();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Invoice", NonExistingCodeunitID);

        // [GIVEN] Posted Service Invoice.
        PostedDocNo := CreateAndPostServiceInvoice();

        // [WHEN] Run "Send" for Posted Service Invoice, select Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        ServiceInvoiceHeader.SetRange("No.", PostedDocNo);
        asserterror ServiceInvoiceHeader.SendRecords();

        // [THEN] Electronic Document is not created. Codeunit "C" is run via Codeunit.Run.
        ServiceInvoiceHeader.Get(PostedDocNo);
        ServiceInvoiceHeader.TestField("OIOUBL-Electronic Invoice Created", false);
        // The codeunit id must be part of the error text.
        Assert.ExpectedError(format(NonExistingCodeunitID));

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('PostAndSendConfirmationModalPageHandler,SelectSendingOptionsSetFormatModalPageHandler')]
    procedure PostAndSendServiceCrMemoOIOUBL()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        // [SCENARIO 299031] Post and Send Service Credit Memo in case OIOUBL profile is selected.
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Credit Memo", Codeunit::"OIOUBL-Export Service Cr.Memo");

        // [GIVEN] Service Credit Memo.
        CreateServiceDocumentWithItem(ServiceLine, ServiceLine."Document Type"::"Credit Memo");
        FindServiceHeader(ServiceHeader, ServiceLine);

        // [WHEN] Run "Post and Send" codeunit for Service Credit Memo, select Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        Codeunit.Run(Codeunit::"Service-Post and Send", ServiceHeader);

        // [THEN] Electronic Document is created and saved to location, specified in Service Setup.
        // [THEN] "No. Printed" value of Posted Service Credit Memo increases by 1. Bug ID 349569.
        LibraryService.FindServiceCrMemoHeader(ServiceCrMemoHeader, ServiceHeader."No.");
        ServiceCrMemoHeader.TestField("OIOUBL-Electronic Credit Memo Created", true);
        ServiceCrMemoHeader.TestField("No. Printed", 1);
        VerifyElectronicServiceDocument(ServiceCrMemoHeader."No.", ServiceLine."OIOUBL-Account Code");

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsSetFormatModalPageHandler')]
    procedure SendPostedServiceCrMemoOIOUBL()
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 299031] Send Posted Service Credit Memo in case OIOUBL profile is selected.
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Credit Memo", Codeunit::"OIOUBL-Export Service Cr.Memo");

        // [GIVEN] Posted Service Credit Memo.
        PostedDocNo := CreateAndPostServiceCrMemo();

        // [WHEN] Run "Send" for Posted Service Credit Memo, select Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        ServiceCrMemoHeader.SetRange("No.", PostedDocNo);
        ServiceCrMemoHeader.SendRecords();

        // [THEN] Electronic Document is created and saved to location, specified in Service Setup.
        // [THEN] "No. Printed" value of Posted Service Credit Memo increases by 1. Bug ID 349569.
        ServiceCrMemoHeader.Get(PostedDocNo);
        ServiceCrMemoHeader.TestField("OIOUBL-Electronic Credit Memo Created", true);
        ServiceCrMemoHeader.TestField("No. Printed", 1);
        VerifyElectronicServiceDocument(ServiceCrMemoHeader."No.", ServiceCrMemoHeader."OIOUBL-Account Code");

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ProfileSelectionMethodStrMenuHandler')]
    procedure SendMultiplePostedServiceCrMemosOIOUBL()
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNoLst: List of [Code[20]];
        AccountCodeLst: List of [Text[30]];
        PostedDocNo: Code[20];
    begin
        // [FEATURE] [Zip]
        // [SCENARIO 318500] Send multiple Posted Service Credit Memos in case OIOUBL profile is selected.
        Initialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Credit Memo", CODEUNIT::"OIOUBL-Export Service Cr.Memo");

        // [GIVEN] Default DocumentSendingProfile Disk::"Electronic Document", Format = OIOUBL; three Posted Service Credit Memos.
        PostedDocNoLst.AddRange(CreateAndPostServiceCrMemo(), CreateAndPostServiceCrMemo(), CreateAndPostServiceCrMemo());

        // [WHEN] Run "Send" for these Posted Service Credit Memos.
        ServiceCrMemoHeader.SetFilter("No.", '%1|%2|%3', PostedDocNoLst.Get(1), PostedDocNoLst.Get(2), PostedDocNoLst.Get(3));
        ServiceCrMemoHeader.SendRecords();

        // [THEN] One ZIP file is created at the location, specified in Service Setup.
        // [THEN] ZIP file contains OIOUBL Electronic Document for each Posted Service Credit Memo.
        foreach PostedDocNo in PostedDocNoLst do begin
            ServiceCrMemoHeader.Get(PostedDocNo);
            ServiceCrMemoHeader.TestField("OIOUBL-Electronic Credit Memo Created", true);
            AccountCodeLst.Add(ServiceCrMemoHeader."OIOUBL-Account Code");
        end;
        VerifyElectronicServiceDocumentInZipArchive(PostedDocNoLst, AccountCodeLst);
    end;

    [Test]
    [HandlerFunctions('PostAndSendConfirmationModalPageHandler,SelectSendingOptionsSetFormatModalPageHandler')]
    procedure PostAndSendServiceCrMemoNonOIOUBL()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        // [SCENARIO 299031] Post and Send Service Credit Memo in case non-OIOUBL profile is selected.
        Initialize();
        UpdateCompanySwiftCode();

        // [GIVEN] Service Credit Memo.
        CreateServiceDocumentWithItem(ServiceLine, ServiceLine."Document Type"::"Credit Memo");
        FindServiceHeader(ServiceHeader, ServiceLine);

        // [WHEN] Run "Post and Send" codeunit for Service Credit Memo, select Format = PEPPOL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(PEPPOLFormatNameTxt));
        Codeunit.Run(Codeunit::"Service-Post and Send", ServiceHeader);

        // [THEN] Electronic Document is not created at the location, specified in Service Setup - file path is not in the queue.
        LibraryService.FindServiceCrMemoHeader(ServiceCrMemoHeader, ServiceHeader."No.");
        ServiceCrMemoHeader.TestField("OIOUBL-Electronic Credit Memo Created", false);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('PostAndSendConfirmationModalPageHandler,SelectSendingOptionsSetFormatModalPageHandler')]
    procedure PostAndSendServiceCrMemoNonElectronicDocument()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        // [SCENARIO 299031] Post and Send Service Credit Memo in case Disk = No in Document Sending Profile.
        Initialize();

        // [GIVEN] Service Credit Memo.
        CreateServiceDocumentWithItem(ServiceLine, ServiceLine."Document Type"::"Credit Memo");
        FindServiceHeader(ServiceHeader, ServiceLine);

        // [WHEN] Run "Post and Send" codeunit for Service Credit Memo, select Disk = No, Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::No);
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        Codeunit.Run(Codeunit::"Service-Post and Send", ServiceHeader);

        // [THEN] Electronic Document is not created at the location, specified in Service Setup - file path is not in the queue.
        LibraryService.FindServiceCrMemoHeader(ServiceCrMemoHeader, ServiceHeader."No.");
        ServiceCrMemoHeader.TestField("OIOUBL-Electronic Credit Memo Created", false);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsSetFormatModalPageHandler')]
    procedure SendPostedServiceCrMemoOIOUBLWithNonStandardCodeunit()
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNo: Code[20];
        NonExistingCodeunitID: Integer;
    begin
        // [SCENARIO 327540] Send Posted Service Credit Memo to OIOUBL in case Electronic Document Format has non-standard "Codeunit ID".
        Initialize();

        // [GIVEN] Electronic Document Format OIOUBL for Service Credit Memo with nonexisting "Codeunit ID" = "C".
        NonExistingCodeunitID := GetNonExistingCodeunitID();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Credit Memo", NonExistingCodeunitID);

        // [GIVEN] Posted Service Credit Memo.
        PostedDocNo := CreateAndPostServiceCrMemo();

        // [WHEN] Run "Send" for Posted Service Credit Memo, select Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        ServiceCrMemoHeader.SetRange("No.", PostedDocNo);
        asserterror ServiceCrMemoHeader.SendRecords();

        // [THEN] OIOUBL Electronic Document is not created. Codeunit "C" is run via Codeunit.Run.
        ServiceCrMemoHeader.Get(PostedDocNo);
        ServiceCrMemoHeader.TestField("OIOUBL-Electronic Credit Memo Created", false);
        // The codeunit id must be part of the error text.
        Assert.ExpectedError(format(NonExistingCodeunitID));

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsSetFormatModalPageHandler')]
    procedure SendPostedServiceDocumentOIOUBLWithoutElectronicDocFormat()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 327540] Send Posted Service Invoice to OIOUBL in case Electronic Document Format does not exist.
        Initialize();

        // [GIVEN] Electronic Document Format OIOUBL for Service Invoice does not exist.
        ElectronicDocumentFormat.SetFilter(Code, OIOUBLFormatNameTxt);
        ElectronicDocumentFormat.SetRange(Usage, ElectronicDocumentFormat.Usage::"Service Invoice");
        ElectronicDocumentFormat.DeleteAll();

        // [GIVEN] Posted Service Invoice.
        PostedDocNo := CreateAndPostServiceInvoice();

        // [WHEN] Run "Send" for Posted Service Invoice, select Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        ServiceInvoiceHeader.SetRange("No.", PostedDocNo);
        asserterror ServiceInvoiceHeader.SendRecords();

        // [THEN] Electronic Document is not created. An error "The electronic document format OIOUBL does not exist" is thrown.
        ServiceInvoiceHeader.Get(PostedDocNo);
        ServiceInvoiceHeader.TestField("OIOUBL-Electronic Invoice Created", false);
        Assert.ExpectedError(StrSubstNo(NonExistingDocumentFormatErr, Format(ElectronicDocumentFormat.Usage::"Service Invoice")));
        Assert.ExpectedErrorCode('Dialog');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('PostAndSendConfirmationYesModalPageHandler,ServiceInvoiceRequestPageHandler,EmailEditorHandler,CloseEmailEditorHandler')]
    procedure PostAndSendServiceInvoiceOIOUBLWithPrintAndEmail();
    begin
        PostAndSendServiceInvoiceOIOUBLWithPrintAndEmailInternal();
    end;

    procedure PostAndSendServiceInvoiceOIOUBLWithPrintAndEmailInternal();
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        // [SCENARIO 336642] Post And Send Service Invoice in case Print, E-Mail - OIOUBL, Disk - OIOUBL are set in Document Sending Profile.
        Initialize();
        DocumentSendingProfile.DeleteAll();
        MailSetupInitialize();
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Invoice", Codeunit::"OIOUBL-Export Service Invoice");

        // [GIVEN] DocumentSendingProfile with Printer = Yes; Disk = "Electronic Document", Format = OIOUBL;
        // [GIVEN] E-Mail = Yes, E-Mail Attachment = "Electronic Document", Format = OIOUBL. Service Invoice.
        CreateDocumentSendingProfile(
            DocumentSendingProfile, DocumentSendingProfile.Printer::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail"::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail Attachment"::"Electronic Document", OIOUBLFormatNameTxt,
            DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        CreateServiceDocumentWithItem(ServiceLine, ServiceHeader."Document Type"::Invoice);
        SetDocumentSendingProfileToCustomer(ServiceLine."Customer No.", DocumentSendingProfile.Code);
        FindServiceHeader(ServiceHeader, ServiceLine);

        // [WHEN] Run "Post and Send" codeunit for Service Invoice.
        Codeunit.Run(Codeunit::"Service-Post and Send", ServiceHeader);

        // [THEN] Service Invoice is posted.
        // [THEN] Report "Service - Invoice" for printing Posted Service Invoice is invoked. Then Email Editor is opened.
        // [THEN] OIOUBL Electronic Document for Posted Service Invoice is created.
        // [THEN] "No. Printed" value of Posted Sales Invoice increases by 2 (cancel Print doesn't count; E-mail, Disk). Bug ID 351595.
        LibraryService.FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
        ServiceInvoiceHeader.TestField("OIOUBL-Electronic Invoice Created", true);
        ServiceInvoiceHeader.TestField("No. Printed", 2);
        VerifyElectronicServiceDocument(ServiceInvoiceHeader."No.", ServiceInvoiceHeader."OIOUBL-Account Code");
    end;

    [Test]
    [HandlerFunctions('PostAndSendConfirmationYesModalPageHandler,ServiceInvoiceRequestPageHandler,EmailEditorHandler,CloseEmailEditorHandler')]
    procedure PostAndSendServiceInvoiceOIOUBLAndPDFWithPrintAndEmail();
    begin
        PostAndSendServiceInvoiceOIOUBLAndPDFWithPrintAndEmailInternal();
    end;

    procedure PostAndSendServiceInvoiceOIOUBLAndPDFWithPrintAndEmailInternal();
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        FileNameLst: List of [Text];
    begin
        // [FEATURE] [Zip]
        // [SCENARIO 336642] Post And Send Service Document in case Print, E-Mail - PDF & OIOUBL, Disk - PDF & OIOUBL are set in Document Sending Profile.
        Initialize();
        DocumentSendingProfile.DeleteAll();
        MailSetupInitialize();
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Invoice", Codeunit::"OIOUBL-Export Service Invoice");

        // [GIVEN] Default DocumentSendingProfile with Printer = Yes; Disk = "PDF & Electronic Document", Format = OIOUBL;
        // [GIVEN] E-Mail = Yes, E-Mail Attachment = "PDF & Electronic Document", Format = OIOUBL. Service Invoice.
        SetDefaultDocumentSendingProfile(
            DocumentSendingProfile.Printer::"Yes (Prompt for Settings)", DocumentSendingProfile."E-Mail"::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail Attachment"::"PDF & Electronic Document", OIOUBLFormatNameTxt,
            DocumentSendingProfile.Disk::"PDF & Electronic Document", OIOUBLFormatNameTxt);
        CreateServiceDocumentWithItem(ServiceLine, ServiceHeader."Document Type"::Invoice);
        FindServiceHeader(ServiceHeader, ServiceLine);

        // [WHEN] Run "Post And Send" codeunit for Service Invoice.
        Codeunit.Run(Codeunit::"Service-Post and Send", ServiceHeader);

        // [THEN] Service Invoice is posted.
        // [THEN] Report "Service - Invoice" for printing Posted Service Invoice is invoked. Then Email Editor is opened.
        // [THEN] ZIP file is created, it contains OIOUBL Electronic Document and PDF with printed copy of Posted Service Invoice.
        LibraryService.FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
        FileNameLst.AddRange(GetFileName(ServiceInvoiceHeader."No.", 'Invoice', 'XML'), GetFileName(ServiceInvoiceHeader."No.", 'Service Invoice', 'PDF'));
        VerifyFileListInZipArchive(FileNameLst);
    end;

    [Test]
    [HandlerFunctions('ProfileSelectionMethodAndCloseEmailStrMenuHandler,ServiceInvoiceRequestPageHandler,EmailEditorHandler')]
    procedure SendPostedServiceInvoiceOIOUBLWithPrintAndEmail()
    begin
        SendPostedServiceInvoiceOIOUBLWithPrintAndEmailInteranl();
    end;

    procedure SendPostedServiceInvoiceOIOUBLWithPrintAndEmailInteranl()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNoLst: List of [Code[20]];
        FileNameLst: List of [Text];
        PostedDocNo: Code[20];
    begin
        // [FEATURE] [Zip]
        // [SCENARIO 336642] Send Posted Service Document in case Print, E-Mail - OIOUBL, Disk - OIOUBL are set in Document Sending Profile.
        Initialize();
        DocumentSendingProfile.DeleteAll();
        MailSetupInitialize();
        CreateElectronicDocumentFormat(
          OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Invoice", Codeunit::"OIOUBL-Export Service Invoice");

        // [GIVEN] Default DocumentSendingProfile with Printer = Yes; Disk = "Electronic Document", Format = OIOUBL;
        // [GIVEN] E-Mail = Yes, E-Mail Attachment = "Electronic Document", Format = OIOUBL. Two Posted Service Invoices.
        CreateDocumentSendingProfile(
            DocumentSendingProfile, DocumentSendingProfile.Printer::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail"::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail Attachment"::"Electronic Document", OIOUBLFormatNameTxt,
            DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        PostedDocNoLst.AddRange(CreateAndPostServiceInvoice(), CreateAndPostServiceInvoice());
        foreach PostedDocNo in PostedDocNoLst do begin
            ServiceInvoiceHeader.Get(PostedDocNo);
            SetDocumentSendingProfileToCustomer(ServiceInvoiceHeader."Customer No.", DocumentSendingProfile.Code);
        end;

        // [WHEN] Run "Send" for these Posted Service Invoices.
        ServiceInvoiceHeader.SetFilter("No.", '%1|%2', PostedDocNoLst.Get(1), PostedDocNoLst.Get(2));
        ServiceInvoiceHeader.SendRecords();

        // [THEN] Report "Service - Invoice" for printing Posted Service Invoice is invoked. Then Email Editor is opened.
        // [THEN] One ZIP file is created, it contains OIOUBL Electronic Document for each Posted Service Invoice.
        foreach PostedDocNo in PostedDocNoLst do begin
            FileNameLst.Add(GetFileName(PostedDocNo, 'Invoice', 'XML'));
            OIOUBLNewFileMock.PopFilePath(); // dequeue unused XML files names
        end;
        VerifyFileListInZipArchive(FileNameLst);
    end;

    [Test]
    [HandlerFunctions('ProfileSelectionMethodAndCloseEmailStrMenuHandler,ServiceInvoiceRequestPageHandler,EmailEditorHandler')]
    procedure SendPostedServiceInvoiceOIOUBLAndPDFWithPrintAndEmail()
    begin
        SendPostedServiceInvoiceOIOUBLAndPDFWithPrintAndEmailInternal();
    end;

    procedure SendPostedServiceInvoiceOIOUBLAndPDFWithPrintAndEmailInternal()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PostedDocNoLst: List of [Code[20]];
        FileNameLst: List of [Text];
    begin
        // [FEATURE] [Zip]
        // [SCENARIO 336642] Send Posted Service Document in case Print, E-Mail - PDF & OIOUBL, Disk - PDF & OIOUBL are set in Document Sending Profile.
        Initialize();
        DocumentSendingProfile.DeleteAll();
        MailSetupInitialize();
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Invoice", Codeunit::"OIOUBL-Export Service Invoice");

        // [GIVEN] Default DocumentSendingProfile with Printer = Yes; Disk = "PDF & Electronic Document", Format = OIOUBL;
        // [GIVEN] E-Mail = Yes, E-Mail Attachment = "PDF & Electronic Document", Format = OIOUBL. Two Posted Service Invoices.
        SetDefaultDocumentSendingProfile(
            DocumentSendingProfile.Printer::"Yes (Prompt for Settings)", DocumentSendingProfile."E-Mail"::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail Attachment"::"PDF & Electronic Document", OIOUBLFormatNameTxt,
            DocumentSendingProfile.Disk::"PDF & Electronic Document", OIOUBLFormatNameTxt);
        PostedDocNoLst.AddRange(CreateAndPostServiceInvoice(), CreateAndPostServiceInvoice());

        // [WHEN] Run "Send" for these Posted Service Invoices.
        ServiceInvoiceHeader.SetFilter("No.", '%1|%2', PostedDocNoLst.Get(1), PostedDocNoLst.Get(2));
        ServiceInvoiceHeader.SendRecords();

        // [THEN] Report "Service - Invoice" for printing Posted Service Invoice is invoked. Then Email Editor is opened.
        // [THEN] Two ZIP files are created, each of them contains OIOUBL Electronic Document and PDF with printed copy of Posted Service Invoice.
        FileNameLst.AddRange(GetFileName(PostedDocNoLst.Get(1), 'Invoice', 'XML'), GetFileName(PostedDocNoLst.Get(1), 'Service Invoice', 'PDF'));
        VerifyFileListInZipArchive(FileNameLst);

        Clear(FileNameLst);
        FileNameLst.AddRange(GetFileName(PostedDocNoLst.Get(2), 'Invoice', 'XML'), GetFileName(PostedDocNoLst.Get(2), 'Service Invoice', 'PDF'));
        VerifyFileListInZipArchive(FileNameLst);
    end;

    [Test]
    [HandlerFunctions('PostAndSendConfirmationYesModalPageHandler,ServiceCreditMemoRequestPageHandler,EmailEditorHandler,CloseEmailEditorHandler')]
    procedure PostAndSendServiceCrMemoOIOUBLWithPrintAndEmail();
    begin
        PostAndSendServiceCrMemoOIOUBLWithPrintAndEmailInternal();
    end;

    procedure PostAndSendServiceCrMemoOIOUBLWithPrintAndEmailInternal();
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        // [SCENARIO 336642] Post And Send Service Credit Memo in case Print, E-Mail - OIOUBL, Disk - OIOUBL are set in Document Sending Profile.
        Initialize();
        DocumentSendingProfile.DeleteAll();
        MailSetupInitialize();
        CreateElectronicDocumentFormat(
            OIOUBLFormatNameTxt, ElectronicDocumentFormat.Usage::"Service Credit Memo", Codeunit::"OIOUBL-Export Service Cr.Memo");

        // [GIVEN] DocumentSendingProfile with Printer = Yes; Disk = "Electronic Document", Format = OIOUBL;
        // [GIVEN] E-Mail = Yes, E-Mail Attachment = "Electronic Document", Format = OIOUBL. Service Credit Memo.
        CreateDocumentSendingProfile(
            DocumentSendingProfile, DocumentSendingProfile.Printer::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail"::"Yes (Prompt for Settings)",
            DocumentSendingProfile."E-Mail Attachment"::"Electronic Document", OIOUBLFormatNameTxt,
            DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);
        CreateServiceDocumentWithItem(ServiceLine, ServiceHeader."Document Type"::"Credit Memo");
        SetDocumentSendingProfileToCustomer(ServiceLine."Customer No.", DocumentSendingProfile.Code);
        FindServiceHeader(ServiceHeader, ServiceLine);

        // [WHEN] Run "Post and Send" codeunit for Service Credit Memo.
        Codeunit.Run(Codeunit::"Service-Post and Send", ServiceHeader);

        // [THEN] Service Credit Memo is posted.
        // [THEN] Report "Service - Credit Memo" for printing Posted Service Credit Memo is invoked. Then Email Editor is opened.
        // [THEN] OIOUBL Electronic Document for Posted Service Credit Memo is created.
        // [THEN] "No. Printed" value of Posted Sales Credit Memo increases by 2 (cancel Print doesn't count; E-mail, Disk). Bug ID 351595.
        LibraryService.FindServiceCrMemoHeader(ServiceCrMemoHeader, ServiceHeader."No.");
        ServiceCrMemoHeader.TestField("OIOUBL-Electronic Credit Memo Created", true);
        ServiceCrMemoHeader.TestField("No. Printed", 2);
        VerifyElectronicServiceDocument(ServiceCrMemoHeader."No.", ServiceCrMemoHeader."OIOUBL-Account Code");
    end;

    [Test]
    procedure AmountPriceDiscountOnServiceInvoiceWithLineInvoiceDiscount()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        OIOUBLExportServiceInvoice: Codeunit "OIOUBL-Export Service Invoice";
        LineExtensionAmounts: List of [Decimal];
        PriceAmounts: List of [Decimal];
        TotalAllowanceChargeAmount: Decimal;
    begin
        // [SCENARIO 341090] Create OIOUBL document for Posted Service Invoice, that has lines with Line Discount and Inv. Discount.
        Initialize();

        // [GIVEN] Posted Service Invoice with two lines. Every line has Line Discount and Invoice Discount.
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice, CreateCustomer(LibraryUtility.GenerateGUID(), ''));
        CreateServiceLineWithLineAndInvoiceDiscount(
            ServiceLine, ServiceHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        CreateServiceLineWithLineAndInvoiceDiscount(
            ServiceLine, ServiceHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceInvoiceHeader.Get(PostServiceInvoice(ServiceHeader."No."));
        GetAmountsServiceInvoiceLines(ServiceInvoiceHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);

        // [WHEN] Create Electronic Document for Posted Service Invoice.
        OIOUBLExportServiceInvoice.ExportXML(ServiceInvoiceHeader);

        // [THEN] InvoiceLine/LineExtensionAmount is equal to Line Amount + Inv. Discount Amount for each Invoice Line.
        // [THEN] InvoiceLine/Price/PriceAmount is equal to (Line Amount + Inv. Discount Amount) / Line Quantity.
        // [THEN] LegalMonetaryTotal/LineExtensionAmount is equal to sum of LineExtensionAmount of InvoiceLine sections.
        // [THEN] AllowanceCharge/Amount is equal to sum of Inv. Discount Amount of Service Invoice Lines.
        VerifyAmountPriceDiscountOnServiceInvoice(
            ServiceInvoiceHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);
    end;

    [Test]
    procedure AmountPriceDiscountOnServiceInvoicePricesInclVATWithLineInvoiceDiscount()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        OIOUBLExportServiceInvoice: Codeunit "OIOUBL-Export Service Invoice";
        LineExtensionAmounts: List of [Decimal];
        PriceAmounts: List of [Decimal];
        TotalAllowanceChargeAmount: Decimal;
    begin
        // [SCENARIO 341090] Create OIOUBL document for Posted Service Invoice, that has lines with Line Discount and Inv. Discount; Prices Incl. VAT is set.
        Initialize();

        // [GIVEN] Posted Service Invoice with two lines, Prices Incl. VAT is set. Every line has Line Discount and Invoice Discount.
        // [GIVEN] VAT = 20%.
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice, CreateCustomer(LibraryUtility.GenerateGUID(), ''));
        SetPricesInclVATOnServiceHeader(ServiceHeader);
        CreateServiceLineWithLineAndInvoiceDiscount(
            ServiceLine, ServiceHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        CreateServiceLineWithLineAndInvoiceDiscount(
            ServiceLine, ServiceHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceInvoiceHeader.Get(PostServiceInvoice(ServiceHeader."No."));
        GetAmountsServiceInvoiceLinesPricesInclVAT(
            ServiceInvoiceHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);

        // [WHEN] Create Electronic Document for Posted Service Invoice.
        OIOUBLExportServiceInvoice.ExportXML(ServiceInvoiceHeader);

        // [THEN] InvoiceLine/LineExtensionAmount is equal to Line Amount + 0.8 * Inv. Discount Amount  for each Invoice Line.
        // [THEN] InvoiceLine/Price/PriceAmount is equal to (Line Amount + 0.8 * Inv. Discount Amount) / Line Quantity.
        // [THEN] LegalMonetaryTotal/LineExtensionAmount is equal to sum of LineExtensionAmount of InvoiceLine sections.
        // [THEN] AllowanceCharge/Amount is equal to sum of 0.8 * Inv. Discount Amount of Service Invoice Lines.
        VerifyAmountPriceDiscountOnServiceInvoice(
            ServiceInvoiceHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);
    end;

    [Test]
    procedure AmountPriceDiscountOnServiceCrMemoWithLineInvoiceDiscount()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        OIOUBLExportServiceCrMemo: Codeunit "OIOUBL-Export Service Cr.Memo";
        LineExtensionAmounts: List of [Decimal];
        PriceAmounts: List of [Decimal];
        TotalAllowanceChargeAmount: Decimal;
    begin
        // [SCENARIO 341090] Create OIOUBL document for Posted Service Credit Memo, that has lines with Line Discount and Inv. Discount.
        Initialize();

        // [GIVEN] Posted Service Credit Memo with two lines. Every line has Line Discount and Invoice Discount.
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::"Credit Memo", CreateCustomer(LibraryUtility.GenerateGUID(), ''));
        CreateServiceLineWithLineAndInvoiceDiscount(
            ServiceLine, ServiceHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        CreateServiceLineWithLineAndInvoiceDiscount(
            ServiceLine, ServiceHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceCrMemoHeader.Get(PostServiceCrMemo(ServiceHeader."No."));
        GetAmountsServiceCrMemoLines(ServiceCrMemoHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);

        // [WHEN] Create Electronic Document for Posted Service Credit Memo.
        OIOUBLExportServiceCrMemo.ExportXML(ServiceCrMemoHeader);

        // [THEN] CreditNoteLine/LineExtensionAmount is equal to Line Amount + Inv. Discount Amount for each Credit Memo Line.
        // [THEN] CreditNoteLine/Price/PriceAmount is equal to (Line Amount + Inv. Discount Amount) / Line Quantity.
        // [THEN] LegalMonetaryTotal/LineExtensionAmount is equal to sum of LineExtensionAmount of CreditNoteLine sections.
        // [THEN] AllowanceCharge/Amount is equal to sum of Inv. Discount Amount of Service CrMemo Lines.
        VerifyAmountPriceDiscountOnServiceCrMemo(ServiceCrMemoHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);
    end;

    [Test]
    procedure AmountPriceDiscountOnServiceCrMemoPricesInclVATWithLineInvoiceDiscount()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        OIOUBLExportServiceCrMemo: Codeunit "OIOUBL-Export Service Cr.Memo";
        LineExtensionAmounts: List of [Decimal];
        PriceAmounts: List of [Decimal];
        TotalAllowanceChargeAmount: Decimal;
    begin
        // [SCENARIO 341090] Create OIOUBL document for Posted Service Credit Memo, that has lines with Line Discount and Inv. Discount; Prices Incl. VAT is set.
        Initialize();

        // [GIVEN] Posted Service Credit Memo with two lines, Prices Incl. VAT is set. Every line has Line Discount and Invoice Discount.
        // [GIVEN] VAT = 20%.
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::"Credit Memo", CreateCustomer(LibraryUtility.GenerateGUID(), ''));
        SetPricesInclVATOnServiceHeader(ServiceHeader);
        CreateServiceLineWithLineAndInvoiceDiscount(
            ServiceLine, ServiceHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        CreateServiceLineWithLineAndInvoiceDiscount(
            ServiceLine, ServiceHeader, LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceCrMemoHeader.Get(PostServiceCrMemo(ServiceHeader."No."));
        GetAmountsServiceCrMemoLinesPricesInclVAT(
            ServiceCrMemoHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);

        // [WHEN] Create Electronic Document for Posted Service Credit Memo.
        OIOUBLExportServiceCrMemo.ExportXML(ServiceCrMemoHeader);

        // [THEN] CreditNoteLine/LineExtensionAmount is equal to Line Amount + 0.8 * Inv. Discount Amount for each Credit Memo Line.
        // [THEN] CreditNoteLine/Price/PriceAmount is equal to (Line Amount + 0.8 * Inv. Discount Amount) / Line Quantity.
        // [THEN] LegalMonetaryTotal/LineExtensionAmount is equal to sum of LineExtensionAmount of CreditNoteLine sections.
        // [THEN] AllowanceCharge/Amount is equal to sum of 0.8 * Inv. Discount Amount of Service CrMemo Lines.
        VerifyAmountPriceDiscountOnServiceCrMemo(ServiceCrMemoHeader."No.", LineExtensionAmounts, PriceAmounts, TotalAllowanceChargeAmount);
    end;

    local procedure Initialize();
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        LibraryVariableStorage.Clear();
        OIOUBLNewFileMock.Setup(OIOUBLNewFileMock);

        DocumentSendingProfile.DeleteAll();
        SetDefaultDocumentSendingProfile(DocumentSendingProfile.Disk::"Electronic Document", OIOUBLFormatNameTxt);

        if isInitialized then
            exit;

        UpdateServiceSetup();
        UpdateOIOUBLCountryRegionCode();
        ModifyGeneralLedgerSetup();

        isInitialized := true;
    end;

    local procedure CreateServiceDocumentWithGLAccount(var ServiceHeader: Record "Service Header"; DocumentType: Option);
    var
        GLAccount: Record "G/L Account";
        ServiceLine: Record "Service Line";
    begin
        UpdateServiceSetup();
        LibraryERM.CreateGLAccount(GLAccount);
        CreateServiceDocument(
        ServiceLine, DocumentType, CreateCustomer(LibraryUtility.GenerateGUID(), ''), ServiceLine.Type::"G/L Account", CreateGLAccount());
        ServiceHeader.GET(ServiceLine."Document Type", ServiceLine."Document No.");
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::"G/L Account", CreateGLAccount(), ServiceHeader."OIOUBL-Account Code");
    end;

    local procedure CreateAndUpdateServiceLineTypeAndNumber(ServiceHeader: Record "Service Header"; Type: Option; No: Code[20]);
    var
        Item: Record Item;
        ServiceLine: Record "Service Line";
    begin
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, LibraryInventory.CreateItem(Item));
        ServiceLine.VALIDATE(Type, Type);
        ServiceLine.VALIDATE("No.", No);
        ServiceLine.MODIFY(true);
    end;

    local procedure CreateCustomer(AccountCode: Text[30]; VATBusPostingGroup: Code[20]): Code[20];
    var
        Customer: Record Customer;
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.GET();
        LibrarySales.CreateCustomer(Customer);
        Customer.VALIDATE("Country/Region Code", CompanyInformation."Country/Region Code");
        Customer.VALIDATE("VAT Registration No.", GenerateVATRegNo(CompanyInformation."Country/Region Code"));
        Customer.VALIDATE(Contact, LibraryUtility.GenerateGUID());
        Customer.VALIDATE("OIOUBL-Account Code", AccountCode);
        Customer.VALIDATE(GLN, SelectGLNNo());
        Customer."VAT Bus. Posting Group" := VATBusPostingGroup;
        Customer.MODIFY(true);
        exit(Customer."No.");
    end;

    local procedure CreateGLAccount(): Code[20];
    var
        GLAccount: Record "G/L Account";
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryERM.FindGeneralPostingSetup(GeneralPostingSetup);
        GLAccount.VALIDATE("Gen. Posting Type", GLAccount."Gen. Posting Type"::Sale);
        GLAccount.VALIDATE("Gen. Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group");
        GLAccount.VALIDATE("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        GLAccount.VALIDATE("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.MODIFY(true);
        exit(GLAccount."No.");
    end;

    local procedure UpdateOIOUBLCountryRegionCode();
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.SETRANGE("OIOUBL-Country/Region Code", '');
        if CountryRegion.FINDFIRST() then
            CountryRegion.MODIFYALL("OIOUBL-Country/Region Code", CountryRegion.Code);
    end;

    local procedure CreateItem(VATProdPostingGroup: Code[20]): Code[20];
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        Item.VALIDATE("VAT Prod. Posting Group", VATProdPostingGroup);
        Item.MODIFY(true);
        exit(Item."No.");
    end;

    local procedure CreateItemWithDecimalUnitPrice(): Code[20];
    var
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        Item.GET(CreateItem(VATPostingSetup."VAT Prod. Posting Group"));
        Item.VALIDATE("Unit Price", LibraryRandom.RandDec(10, 3));  // Unit Price more than two decimal digits required.
        Item.MODIFY(true);
        exit(Item."No.");
    end;

    local procedure CreateMultipleServiceLine(ServiceHeader: Record "Service Header"; VATProdPostingGroup: Code[20]) TaxAmount: Decimal;
    var
        ServiceLine: Record "Service Line";
    begin
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, CreateItem(VATProdPostingGroup), LibraryUtility.GenerateGUID());  // GUID for Account Code.
        TaxAmount := ServiceLine."Line Amount" * ServiceLine."VAT %" / 100;
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, ServiceLine."No.", ServiceLine."OIOUBL-Account Code");
        TaxAmount := ROUND(TaxAmount + (ServiceLine."Line Amount" * ServiceLine."VAT %") / 100, LibraryERM.GetAmountRoundingPrecision());  // Calculate Total TAX Amount.
    end;

    local procedure CreateServiceDocument(var ServiceLine: Record "Service Line"; DocumentType: Option; CustomerNo: Code[20]; Type: Option; ItemNo: Code[20]);
    var
        ServiceHeader: Record "Service Header";
    begin
        CreateServiceHeader(ServiceHeader, DocumentType, CustomerNo);
        CreateServiceLine(ServiceLine, ServiceHeader, Type, ItemNo, ServiceHeader."OIOUBL-Account Code");
    end;

    local procedure CreateServiceDocumentWithItem(var ServiceLine: Record "Service Line"; DocumentType: Option);
    var
        ServiceHeader: Record "Service Header";
    begin
        CreateServiceHeader(ServiceHeader, DocumentType, CreateCustomer(LibraryUtility.GenerateGUID(), ''));
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, LibraryInventory.CreateItemNo(), ServiceHeader."OIOUBL-Account Code");
    end;

    local procedure CreateServiceHeader(var ServiceHeader: Record "Service Header"; DocumentType: Option; CustomerNo: Code[20]);
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType, CustomerNo);
        ServiceHeader.VALIDATE("Bill-to Address", LibraryUtility.GenerateGUID());
        ServiceHeader.VALIDATE("Bill-to City", FindPostCode(ServiceHeader."Country/Region Code"));
        ServiceHeader.Validate("Ship-to Address", LibraryUtility.GenerateGUID());
        ServiceHeader.Validate("Ship-to City", ServiceHeader."Bill-to City");
        ServiceHeader.MODIFY(true);
    end;

    local procedure CreateServiceLine(var ServiceLine: Record "Service Line"; ServiceHeader: Record "Service Header"; Type: Option; ItemNo: Code[20]; AccountCode: Text[30]);
    begin
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, Type, ItemNo);
        ServiceLine.VALIDATE("Unit Price", LibraryRandom.RandDecInRange(100, 200, 2));
        ServiceLine.VALIDATE(Quantity, LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceLine.VALIDATE("OIOUBL-Account Code", AccountCode);
        ServiceLine.MODIFY(true);
    end;

    local procedure CreateServiceLineWithLineAndInvoiceDiscount(var ServiceLine: Record "Service Line"; ServiceHeader: Record "Service Header"; LineDiscountAmt: Decimal; InvDiscountAmt: Decimal)
    begin
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, LibraryInventory.CreateItemNo(), ServiceHeader."OIOUBL-Account Code");
        ServiceLine.Validate("Line Discount Amount", LineDiscountAmt);
        ServiceLine.Validate("Inv. Discount Amount", InvDiscountAmt);
        ServiceLine.Modify(true);
    end;

    local procedure CreateServiceDocumentWithMultipleLineAndUOM(var ServiceLine: Record "Service Line"; DocumentType: Option; var OIOUBLUoMs: List of [Code[10]]);
    var
        Item: Record Item;
        ServiceHeader: Record "Service Header";
    begin
        UpdateServiceSetup();
        CreateServiceDocument(
        ServiceLine, DocumentType, CreateCustomer(LibraryUtility.GenerateGUID(), ''),
        ServiceLine.Type::Item, LibraryInventory.CreateItem(Item));
        OIOUBLUoMs.Add(GetOIOUBLUoMCode(ServiceLine."Unit of Measure Code"));

        ServiceHeader.GET(ServiceLine."Document Type", ServiceLine."Document No.");
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, LibraryInventory.CreateItem(Item), ServiceHeader."OIOUBL-Account Code");
        OIOUBLUoMs.Add(GetOIOUBLUoMCode(ServiceLine."Unit of Measure Code"));

        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::"G/L Account", CreateGLAccount(), ServiceHeader."OIOUBL-Account Code");
        OIOUBLUoMs.Add(PEPPOLManagement.GetUoMforPieceINUNECERec20ListID());
    end;

    local procedure CreateAndPostServiceInvoice(): Code[20];
    var
        ServiceLine: Record "Service Line";
    begin
        CreateServiceDocument(
          ServiceLine, ServiceLine."Document Type"::Invoice, CreateCustomer(LibraryUtility.GenerateGUID(), ''),
          ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
        exit(PostServiceInvoice(ServiceLine."Document No."));
    end;

    local procedure CreateAndPostServiceCrMemo(): Code[20];
    var
        ServiceLine: Record "Service Line";
    begin
        CreateServiceDocument(
          ServiceLine, ServiceLine."Document Type"::"Credit Memo", CreateCustomer(LibraryUtility.GenerateGUID(), ''),
          ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
        exit(PostServiceCrMemo(ServiceLine."Document No."));
    end;

    local procedure CreateElectronicDocumentFormat(DocFormatCode: Code[20]; DocFormatUsage: Option; CodeunitID: Integer);
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        with ElectronicDocumentFormat do begin
            SetFilter(Code, DocFormatCode);
            SetRange(Usage, DocFormatUsage);
            DeleteAll();
            InsertElectronicFormat(DocFormatCode, '', CodeunitID, 0, DocFormatUsage);
        end;
    end;

    local procedure CreateDocumentSendingProfile(var DocumentSendingProfile: Record "Document Sending Profile"; PrinterType: Option; EmailType: Option; EmailAttachment: Option; EmailFormatCode: Code[20]; DiskType: Option; DiskFormatCode: Code[20])
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

    local procedure FindAndUpdateVATPostingSetupPct(var VATPostingSetup: Record "VAT Posting Setup"; NewVATPct: Decimal) OldVATPercent: Decimal;
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        OldVATPercent := UpdateVATPostingSetupPct(VATPostingSetup, NewVATPct);
    end;

    local procedure FindStandardText(): Code[20];
    var
        StandardText: Record "Standard Text";
    begin
        StandardText.FINDFIRST();
        exit(StandardText.Code);
    end;

    local procedure FindPostCode(CountryRegionCode: Code[10]): Text[30];
    var
        PostCode: Record "Post Code";
    begin
        PostCode.SETFILTER("Country/Region Code", CountryRegionCode);
        LibraryERM.FindPostCode(PostCode);
        exit(PostCode.City);
    end;

    local procedure FindServiceHeader(var ServiceHeader: Record "Service Header"; ServiceLine: Record "Service Line")
    begin
        ServiceHeader.SetRange("Document Type", ServiceLine."Document Type");
        ServiceHeader.SetRange("No.", ServiceLine."Document No.");
        ServiceHeader.FindFirst();
    end;

    local procedure FindPostedServiceInvoiceNo(CustomerNo: Code[20]): Code[20];
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        ServiceInvoiceHeader.SETRANGE("Customer No.", CustomerNo);
        ServiceInvoiceHeader.FINDFIRST();
        exit(ServiceInvoiceHeader."No.");
    end;

    local procedure FindPostedServiceCreditMemoNo(CustomerNo: Code[20]): Code[20];
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        ServiceCrMemoHeader.SETRANGE("Customer No.", CustomerNo);
        ServiceCrMemoHeader.FINDFIRST();
        exit(ServiceCrMemoHeader."No.");
    end;

    local procedure FindElectronicDocumentFormatCode(FormatName: Text[20]): Code[20]
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        // Usage option is not used for filtering now. It is set to 0.
        ElectronicDocumentFormat.SetFilter(Code, '%1', '*' + FormatName + '*');
        ElectronicDocumentFormat.FindFirst();
        exit(ElectronicDocumentFormat.Code);
    end;

    local procedure FormatAmount(Amount: Decimal): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(Format(Amount, 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces()))
    end;

    local procedure GenerateVATRegNo(CountryRegionCode: Code[10]): Text[20]
    begin
        exit(CountryRegionCode + PadStr(DelStr(LibraryUtility.GenerateGUID(), 1, 2), 8, '0'));
    end;

    local procedure GetOIOUBLUoMCode(UnitOfMeasureCode: Code[10]): Code[10];
    var
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
    begin
        exit(CopyStr(OIOUBLDocumentEncode.GetUoMCode(UnitOfMeasureCode), 1, MaxStrLen(UnitOfMeasureCode)));
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

    local procedure GetAmountsServiceInvoiceLines(ServiceInvHeaderNo: Code[20]; var LineExtensionAmounts: List of [Decimal]; var PriceAmounts: List of [Decimal]; var TotalAllowanceChargeAmount: Decimal)
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
    begin
        TotalAllowanceChargeAmount := 0;
        with ServiceInvoiceLine do begin
            SetRange("Document No.", ServiceInvHeaderNo);
            FindSet();
            repeat
                LineExtensionAmounts.Add(Amount + "Inv. Discount Amount");
                PriceAmounts.Add(Round((Amount + "Inv. Discount Amount") / Quantity));
                TotalAllowanceChargeAmount += "Inv. Discount Amount";
            until Next() = 0;
        end;
    end;

    local procedure GetAmountsServiceInvoiceLinesPricesInclVAT(ServiceInvHeaderNo: Code[20]; var LineExtensionAmounts: List of [Decimal]; var PriceAmounts: List of [Decimal]; var TotalAllowanceChargeAmount: Decimal)
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
        ExclVATFactor: Decimal;
    begin
        TotalAllowanceChargeAmount := 0;
        with ServiceInvoiceLine do begin
            SetRange("Document No.", ServiceInvHeaderNo);
            FindSet();
            repeat
                ExclVATFactor := 1 + "VAT %" / 100;
                LineExtensionAmounts.Add(Amount + Round("Inv. Discount Amount" / ExclVATFactor));
                PriceAmounts.Add(Round((Amount + Round("Inv. Discount Amount" / ExclVATFactor)) / Quantity));
                TotalAllowanceChargeAmount += Round("Inv. Discount Amount" / ExclVATFactor);
            until Next() = 0;
        end;
    end;

    local procedure GetAmountsServiceCrMemoLines(ServiceCrMemoHeaderNo: Code[20]; var LineExtensionAmounts: List of [Decimal]; var PriceAmounts: List of [Decimal]; var TotalAllowanceChargeAmount: Decimal)
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
    begin
        TotalAllowanceChargeAmount := 0;
        with ServiceCrMemoLine do begin
            SetRange("Document No.", ServiceCrMemoHeaderNo);
            FindSet();
            repeat
                LineExtensionAmounts.Add(Amount + "Inv. Discount Amount");
                PriceAmounts.Add(Round((Amount + "Inv. Discount Amount") / Quantity));
                TotalAllowanceChargeAmount += "Inv. Discount Amount";
            until Next() = 0;
        end;
    end;

    local procedure GetAmountsServiceCrMemoLinesPricesInclVAT(ServiceCrMemoHeaderNo: Code[20]; var LineExtensionAmounts: List of [Decimal]; var PriceAmounts: List of [Decimal]; var TotalAllowanceChargeAmount: Decimal)
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ExclVATFactor: Decimal;
    begin
        TotalAllowanceChargeAmount := 0;
        with ServiceCrMemoLine do begin
            SetRange("Document No.", ServiceCrMemoHeaderNo);
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
        LibraryXPathXMLReader.Initialize(FileName, '');
        LibraryXPathXMLReader.SetDefaultNamespaceUsage(false);
        LibraryXPathXMLReader.AddAdditionalNamespace('cac', 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2');
        LibraryXPathXMLReader.AddAdditionalNamespace('cbc', 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2');
    end;

    local procedure PostServiceCrMemo(DocumentNo: Code[20]) PostedDocumentNo: Code[20];
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.GET(ServiceHeader."Document Type"::"Credit Memo", DocumentNo);
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);  // Post Service Credit Memo as ship and invoice, False - Consume.
        PostedDocumentNo := FindPostedServiceCreditMemoNo(ServiceHeader."Customer No.");
    end;

    local procedure PostServiceInvoice(DocumentNo: Code[20]) PostedDocumentNo: Code[20];
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.GET(ServiceHeader."Document Type"::Invoice, DocumentNo);
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);  // Post Service Invoice as ship and invoice, False - Consume.
        PostedDocumentNo := FindPostedServiceInvoiceNo(ServiceHeader."Customer No.");
    end;

    local procedure RunReportCreateElecServiceCrMemos(No: Code[20]);
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        CreateElecServiceCrMemos: Report "OIOUBL-Create Elec Srv Cr Memo";
    begin
        CLEAR(CreateElecServiceCrMemos);
        ServiceCrMemoHeader.SETRANGE("No.", No);
        CreateElecServiceCrMemos.SETTABLEVIEW(ServiceCrMemoHeader);
        CreateElecServiceCrMemos.USEREQUESTPAGE(false);
        CreateElecServiceCrMemos.RUN();
    end;

    local procedure RunReportCreateElecServiceInvoices(No: Code[20]);
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        CreateElecServiceInvoices: Report "OIOUBL-Create Elec. Srv. Inv.";
    begin
        CLEAR(CreateElecServiceInvoices);
        ServiceInvoiceHeader.SETRANGE("No.", No);
        CreateElecServiceInvoices.SETTABLEVIEW(ServiceInvoiceHeader);
        CreateElecServiceInvoices.USEREQUESTPAGE(false);
        CreateElecServiceInvoices.RUN();
    end;

    local procedure SelectGLNNo(): Code[13];
    var
        Customer: Record Customer;
    begin
        Customer.SETFILTER(GLN, '<>%1', '');
        Customer.FINDFIRST();
        exit(Customer.GLN);
    end;

    local procedure SetDefaultDocumentSendingProfile(DiskType: Option; DiskFormatCode: Code[20]);
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        CreateDocumentSendingProfile(
            DocumentSendingProfile, DocumentSendingProfile.Printer::No, DocumentSendingProfile."E-Mail"::No, 0, '', DiskType, DiskFormatCode);
        DocumentSendingProfile.Default := true;
        DocumentSendingProfile.Modify();
    end;

    local procedure SetDefaultDocumentSendingProfile(PrinterType: Option; EmailType: Option; EmailAttachment: Option; EmailFormatCode: Code[20]; DiskType: Option; DiskFormatCode: Code[20])
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

    local procedure SetPricesInclVATOnServiceHeader(var ServiceHeader: Record "Service Header")
    begin
        ServiceHeader.Validate("Prices Including VAT", true);
        ServiceHeader.Modify(true);
    end;

    local procedure MailSetupInitialize()
    var
        LibraryWorkflow: Codeunit "Library - Workflow";
    begin
        LibraryWorkflow.SetUpEmailAccount();
    end;

    local procedure UpdateVATPostingSetupPct(var VATPostingSetup: Record "VAT Posting Setup"; NewVATPct: Decimal) OldVATPct: Decimal;
    begin
        OldVATPct := VATPostingSetup."VAT %";
        VATPostingSetup.VALIDATE("VAT %", NewVATPct);
        VATPostingSetup.MODIFY(true);
    end;

    local procedure UpdateServiceSetup();
    var
        ServiceSetup: Record "Service Mgt. Setup";
    begin
        with ServiceSetup do begin
            Get();
            Validate("OIOUBL-Service Invoice Path", TemporaryPath());
            Validate("OIOUBL-Service Cr. Memo Path", TemporaryPath());
            Modify(true);
        end;
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

    local procedure ModifyGeneralLedgerSetup();
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        // Make sure that G/L Setup has move then 2 decimal places
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.01;
        GeneralLedgerSetup.Modify();
    end;

    local procedure VerifyTaxOnElectronicServiceDocument(DocumentNo: Code[20]; AccountCode: Text[30]; TaxAmount: Decimal);
    begin
        VerifyElectronicServiceDocument(DocumentNo, AccountCode);
        if TaxAmount = 0 then
            LibraryXMLReadOnServer.VerifyNodeValue(TaxAmountCapTxt, '0.00')  // Formating Tax Amount value upto 4 digit and Format String for two decimal points.
        else
            LibraryXMLReadOnServer.VerifyNodeValue(TaxAmountCapTxt, FORMAT(TaxAmount, 0, '<Precision,2:3><Sign><Integer><Decimals><Comma,.>'));  // Formating Tax Amount value upto 4 digit and Format String for two decimal points.
    end;

    local procedure VerifyElectronicServiceDocument(DocumentNo: Code[20]; AccountCode: Text[30]);
    begin
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath());  // Initialize generated Electronic Document.
        LibraryXMLReadOnServer.VerifyNodeValue(IDCapTxt, DocumentNo);
        LibraryXMLReadOnServer.VerifyNodeValue(AccountingCostCodeCapTxt, AccountCode);
    end;

    local procedure VerifyElectronicServiceDocumentInZipArchive(DocumentNoLst: List of [Code[20]]; AccountCodeLst: List of [Text[30]]);
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
            LibraryXMLReadOnServer.VerifyNodeValue(IDCapTxt, DocumentNoLst.Get(i));
            LibraryXMLReadOnServer.VerifyNodeValue(AccountingCostCodeCapTxt, AccountCodeLst.Get(i));
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

    local procedure VerifyUnitOfMeasureForInvoiceLineOnElectronicDocument(UoMCode: Code[10]; NodeIndex: Integer)
    begin
        LibraryXMLReadOnServer.VerifyAttributeValueByIndexInSubtree('cac:InvoiceLine', 'cbc:InvoicedQuantity', 'unitCode', UoMCode, NodeIndex);
    end;

    local procedure VerifyUnitOfMeasureForCrMemoLineOnElectronicDocument(UoMCode: Code[10]; NodeIndex: Integer)
    begin
        LibraryXMLReadOnServer.VerifyAttributeValueByIndexInSubtree('cac:CreditNoteLine', 'cbc:CreditedQuantity', 'unitCode', UoMCode, NodeIndex);
    end;

    local procedure VerifyAmountPriceDiscountOnServiceInvoice(ServiceInvHeaderNo: Code[20]; LineExtensionAmounts: List of [Decimal]; PriceAmounts: List of [Decimal]; TotalAllowanceChargeAmount: Decimal)
    var
        TotalLineExtensionAmount: Decimal;
        i: Integer;
    begin
        InitializeLibraryXPathXMLReader(OIOUBLNewFileMock.PopFilePath());
        LibraryXPathXMLReader.VerifyNodeValue(IDCapTxt, ServiceInvHeaderNo);

        for i := 1 to LineExtensionAmounts.Count() do begin
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                '//cac:InvoiceLine/cbc:LineExtensionAmount', FormatAmount(LineExtensionAmounts.Get(i)), i - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                '//cac:InvoiceLine/cac:Price/cbc:PriceAmount', FormatAmount(PriceAmounts.Get(i)), i - 1);

            TotalLineExtensionAmount += LineExtensionAmounts.Get(i);
        end;

        LibraryXPathXMLReader.VerifyNodeValueByXPath(
            '//cac:LegalMonetaryTotal/cbc:LineExtensionAmount', FormatAmount(TotalLineExtensionAmount));
        LibraryXPathXMLReader.VerifyNodeValueByXPath(
            '//cac:AllowanceCharge/cbc:Amount', FormatAmount(TotalAllowanceChargeAmount));
    end;

    local procedure VerifyAmountPriceDiscountOnServiceCrMemo(ServiceCmMemoHeaderNo: Code[20]; LineExtensionAmounts: List of [Decimal]; PriceAmounts: List of [Decimal]; TotalAllowanceChargeAmount: Decimal)
    var
        TotalLineExtensionAmount: Decimal;
        i: Integer;
    begin
        InitializeLibraryXPathXMLReader(OIOUBLNewFileMock.PopFilePath());
        LibraryXPathXMLReader.VerifyNodeValue(IDCapTxt, ServiceCmMemoHeaderNo);

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

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
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

    [ModalPageHandler]
    procedure PostAndSendConfirmationModalPageHandler(var PostandSendConfirmation: TestPage "Post and Send Confirmation")
    begin
        PostandSendConfirmation.SelectedSendingProfiles.AssistEdit();
        PostandSendConfirmation.Yes().Invoke();
    end;

    [ModalPageHandler]
    procedure PostAndSendConfirmationYesModalPageHandler(var PostandSendConfirmation: TestPage "Post and Send Confirmation")
    begin
        PostandSendConfirmation.Yes().Invoke();
    end;

    [ModalPageHandler]
    procedure SelectSendingOptionsSetFormatModalPageHandler(var SelectSendingOptions: TestPage "Select Sending Options")
    begin
        SelectSendingOptions.Disk.SetValue(LibraryVariableStorage.DequeueInteger());
        SelectSendingOptions."Disk Format".SetValue(LibraryVariableStorage.DequeueText());
        SelectSendingOptions."Electronic Format".SetValue(SelectSendingOptions."Disk Format".Value());
        SelectSendingOptions."E-Mail Format".SetValue(SelectSendingOptions."Disk Format".Value());
        SelectSendingOptions.OK().Invoke();
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
    procedure ServiceInvoiceRequestPageHandler(var ServiceInvoice: TestRequestPage "Service - Invoice")
    begin
        ServiceInvoice.Cancel().Invoke();
    end;

    [RequestPageHandler]
    procedure ServiceCreditMemoRequestPageHandler(var ServiceCreditMemo: TestRequestPage "Service - Credit Memo")
    begin
        ServiceCreditMemo.Cancel().Invoke();
    end;
}

