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
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        OIOUBLNewFileMock: Codeunit "OIOUBL-File Events Mock";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        Assert: Codeunit Assert;
        IDCapTxt: Label 'cbc:ID';
        TaxAmountCapTxt: Label 'cbc:TaxExclusiveAmount';
        DefaultProfileIDTxt: Label 'Procurement-BilSim-1.0';
        AccountingCostCodeCapTxt: Label 'cbc:AccountingCostCode';
        OIOUBLFormatNameTxt: Label 'OIOUBL';
        PEPPOLFormatNameTxt: Label 'PEPPOL';

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
        UpdateOIOUBLPathOnServiceManagementSetup();
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
        UpdateOIOUBLPathOnServiceManagementSetup();
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
        UpdateOIOUBLPathOnServiceManagementSetup();
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
        UpdateOIOUBLPathOnServiceManagementSetup();
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
        Item: Record Item;
        ServiceLine: Record "Service Line";
        ServiceHeader: Record "Service Header";
        PostedDocumentNo: Code[20];
    begin
        // Update Service Management Setup, Create, Update and Post Service Invoice.
        UpdateOIOUBLPathOnServiceManagementSetup();
        CreateServiceDocument(
        ServiceLine, ServiceLine."Document Type"::Invoice, CreateCustomer(LibraryUtility.GenerateGUID(), ''), ServiceLine.Type::Item,
        LibraryInventory.CreateItem(Item));  // Using blank value for VAT Bus. Posting Group.
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
        UpdateOIOUBLPathOnServiceManagementSetup();
        CreateServiceDocument(
        ServiceLine, ServiceLine."Document Type"::"Credit Memo", CreateCustomer(LibraryUtility.GenerateGUID(), ''), ServiceLine.Type::Item,
        CreateItemWithDecimalUnitPrice());
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
        UpdateOIOUBLPathOnServiceManagementSetup();
        CreateServiceDocument(
        ServiceLine, ServiceLine."Document Type"::Invoice, CreateCustomer(LibraryUtility.GenerateGUID(), ''), ServiceLine.Type::Item,
        CreateItemWithDecimalUnitPrice());
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
        Item: Record Item;
        ServiceLine: Record "Service Line";
        ServiceHeader: Record "Service Header";
        PostedDocumentNo: Code[20];
    begin
        // Update Service Management Setup, Create, Update and Post Service Credit Memo.
        UpdateOIOUBLPathOnServiceManagementSetup();
        CreateServiceDocument(
        ServiceLine, ServiceLine."Document Type"::"Credit Memo", CreateCustomer(LibraryUtility.GenerateGUID(), ''), ServiceLine.Type::Item,
        LibraryInventory.CreateItem(Item));  // Using blank value for VAT Bus. Posting Group.
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
    begin
        // [SCENARIO 299031] Post and Send Service Invoice in case OIOUBL profile is selected.
        Initialize();

        // [GIVEN] Service Invoice.
        CreateServiceDocument(
          ServiceLine, ServiceLine."Document Type"::Invoice, CreateCustomer(LibraryUtility.GenerateGUID(), ''),
          ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
        FindServiceHeader(ServiceHeader, ServiceLine);

        // [WHEN] Run "Post and Send" codeunit for Service Invoice, select Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        Codeunit.Run(Codeunit::"Service-Post and Send", ServiceHeader);

        // [THEN] Electronic Document is created and saved to location, specified in Service Setup.
        LibraryService.FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
        ServiceInvoiceHeader.TestField("OIOUBL-Electronic Invoice Created", true);
        VerifyElectronicServiceDocument(ServiceInvoiceHeader."No.", ServiceLine."OIOUBL-Account Code");

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsSetFormatModalPageHandler')]
    procedure SendPostedServiceInvoiceOIOUBL()
    var
        ServiceLine: Record "Service Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 299031] Send Posted Service Invoice in case OIOUBL profile is selected.
        Initialize();

        // [GIVEN] Posted Service Invoice.
        CreateServiceDocument(
          ServiceLine, ServiceLine."Document Type"::Invoice, CreateCustomer(LibraryUtility.GenerateGUID(), ''),
          ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
        PostedDocNo := PostServiceInvoice(ServiceLine."Document No.");
        ServiceInvoiceHeader.Get(PostedDocNo);

        // [WHEN] Run "Send" for Posted Service Invoice, select Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        ServiceInvoiceHeader.SetRecFilter();
        ServiceInvoiceHeader.SendRecords();

        // [THEN] Electronic Document is created and saved to location, specified in Service Setup.
        ServiceInvoiceHeader.Get(PostedDocNo);
        ServiceInvoiceHeader.TestField("OIOUBL-Electronic Invoice Created", true);
        VerifyElectronicServiceDocument(ServiceInvoiceHeader."No.", ServiceLine."OIOUBL-Account Code");

        LibraryVariableStorage.AssertEmpty();
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
        CreateServiceDocument(
          ServiceLine, ServiceLine."Document Type"::Invoice, CreateCustomer(LibraryUtility.GenerateGUID(), ''),
          ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
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
        CreateServiceDocument(
          ServiceLine, ServiceLine."Document Type"::Invoice, CreateCustomer(LibraryUtility.GenerateGUID(), ''),
          ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
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
    [HandlerFunctions('PostAndSendConfirmationModalPageHandler,SelectSendingOptionsSetFormatModalPageHandler')]
    procedure PostAndSendServiceCrMemoOIOUBL()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        // [SCENARIO 299031] Post and Send Service Credit Memo in case OIOUBL profile is selected.
        Initialize();

        // [GIVEN] Service Credit Memo.
        CreateServiceDocument(
          ServiceLine, ServiceLine."Document Type"::"Credit Memo", CreateCustomer(LibraryUtility.GenerateGUID(), ''),
          ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
        FindServiceHeader(ServiceHeader, ServiceLine);

        // [WHEN] Run "Post and Send" codeunit for Service Credit Memo, select Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        Codeunit.Run(Codeunit::"Service-Post and Send", ServiceHeader);

        // [THEN] Electronic Document is created and saved to location, specified in Service Setup.
        LibraryService.FindServiceCrMemoHeader(ServiceCrMemoHeader, ServiceHeader."No.");
        ServiceCrMemoHeader.TestField("OIOUBL-Electronic Credit Memo Created", true);
        VerifyElectronicServiceDocument(ServiceCrMemoHeader."No.", ServiceLine."OIOUBL-Account Code");

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionsSetFormatModalPageHandler')]
    procedure SendPostedServiceCrMemoOIOUBL()
    var
        ServiceLine: Record "Service Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 299031] Send Posted Service Credit Memo in case OIOUBL profile is selected.
        Initialize();

        // [GIVEN] Posted Service Credit Memo.
        CreateServiceDocument(
          ServiceLine, ServiceLine."Document Type"::"Credit Memo", CreateCustomer(LibraryUtility.GenerateGUID(), ''),
          ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
        PostedDocNo := PostServiceCrMemo(ServiceLine."Document No.");
        ServiceCrMemoHeader.Get(PostedDocNo);

        // [WHEN] Run "Send" for Service Credit Memo, select Format = OIOUBL.
        LibraryVariableStorage.Enqueue(DocumentSendingProfile.Disk::"Electronic Document");
        LibraryVariableStorage.Enqueue(FindElectronicDocumentFormatCode(OIOUBLFormatNameTxt));
        ServiceCrMemoHeader.SetRecFilter();
        ServiceCrMemoHeader.SendRecords();

        // [THEN] Electronic Document is created and saved to location, specified in Service Setup.
        ServiceCrMemoHeader.Get(PostedDocNo);
        ServiceCrMemoHeader.TestField("OIOUBL-Electronic Credit Memo Created", true);
        VerifyElectronicServiceDocument(ServiceCrMemoHeader."No.", ServiceLine."OIOUBL-Account Code");

        LibraryVariableStorage.AssertEmpty();
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
        CreateServiceDocument(
          ServiceLine, ServiceLine."Document Type"::"Credit Memo", CreateCustomer(LibraryUtility.GenerateGUID(), ''),
          ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
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
        CreateServiceDocument(
          ServiceLine, ServiceLine."Document Type"::"Credit Memo", CreateCustomer(LibraryUtility.GenerateGUID(), ''),
          ServiceLine.Type::Item, CreateItemWithDecimalUnitPrice());
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

    local procedure Initialize();
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        UpdateSalesSetup();
        UpdateOIOUBLCountryRegionCode();

        DocumentSendingProfile.DELETEALL();
        DocumentSendingProfile.INIT();
        DocumentSendingProfile.Default := true;
        DocumentSendingProfile."Electronic Format" := OIOUBLFormatNameTxt;
        DocumentSendingProfile.INSERT();

        OIOUBLNewFileMock.Setup(OIOUBLNewFileMock);
    end;

    local procedure CreateServiceDocumentWithGLAccount(var ServiceHeader: Record "Service Header"; DocumentType: Option);
    var
        GLAccount: Record "G/L Account";
        ServiceLine: Record "Service Line";
    begin
        UpdateOIOUBLPathOnServiceManagementSetup();
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
        ServiceLine.VALIDATE("Unit Price", LibraryRandom.RandDec(10, 2));
        ServiceLine.VALIDATE(Quantity, LibraryRandom.RandDec(10, 2));
        ServiceLine.VALIDATE("OIOUBL-Account Code", AccountCode);
        ServiceLine.MODIFY(true);
    end;

    local procedure CreateServiceDocumentWithMultipleLineAndUOM(var ServiceLine: Record "Service Line"; DocumentType: Option; var OIOUBLUoMs: List of [Code[10]]);
    var
        Item: Record Item;
        ServiceHeader: Record "Service Header";
    begin
        UpdateOIOUBLPathOnServiceManagementSetup();
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

    local procedure VerifyTaxOnElectronicServiceDocument(DocumentNo: Code[20]; AccountCode: Text[30]; TaxAmount: Decimal);
    begin
        VerifyElectronicServiceDocument(DocumentNo, AccountCode);
        if TaxAmount = 0 then
            LibraryXMLReadOnServer.VerifyNodeValue(TaxAmountCapTxt, '0.00')  // Formating Tax Amount value upto 4 digit and Format String for two decimal points.
        else
            LibraryXMLReadOnServer.VerifyNodeValue(TaxAmountCapTxt, FORMAT(TaxAmount, 0, 9));  // Formating Tax Amount value upto 4 digit and Format String for two decimal points.
    end;

    local procedure VerifyElectronicServiceDocument(DocumentNo: Code[20]; AccountCode: Text[30]);
    begin
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath());  // Initialize generated Electronic Document.
        LibraryXMLReadOnServer.VerifyNodeValue(IDCapTxt, DocumentNo);
        LibraryXMLReadOnServer.VerifyNodeValue(AccountingCostCodeCapTxt, AccountCode);
    end;

    local procedure VerifyUnitOfMeasureForInvoiceLineOnElectronicDocument(UoMCode: Code[10]; NodeIndex: Integer)
    begin
        LibraryXMLReadOnServer.VerifyAttributeValueByIndexInSubtree('cac:InvoiceLine', 'cbc:InvoicedQuantity', 'unitCode', UoMCode, NodeIndex);
    end;

    local procedure VerifyUnitOfMeasureForCrMemoLineOnElectronicDocument(UoMCode: Code[10]; NodeIndex: Integer)
    begin
        LibraryXMLReadOnServer.VerifyAttributeValueByIndexInSubtree('cac:CreditNoteLine', 'cbc:CreditedQuantity', 'unitCode', UoMCode, NodeIndex);
    end;

    local procedure UpdateOIOUBLPathOnServiceManagementSetup();
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        ServiceMgtSetup.GET();
        ServiceMgtSetup.VALIDATE("OIOUBL-Service Cr. Memo Path", TEMPORARYPATH());
        ServiceMgtSetup.VALIDATE("OIOUBL-Service Invoice Path", TEMPORARYPATH());
        ServiceMgtSetup.MODIFY(true);
    end;

    local procedure UpdateServiceLineUnitOfMeasure(ServiceLine: Record "Service Line");
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        ServiceLine.VALIDATE("Unit of Measure", UnitOfMeasure.Code);
        ServiceLine.MODIFY(true);
    end;

    local procedure UpdateVATPostingSetupPct(var VATPostingSetup: Record "VAT Posting Setup"; NewVATPct: Decimal) OldVATPct: Decimal;
    begin
        OldVATPct := VATPostingSetup."VAT %";
        VATPostingSetup.VALIDATE("VAT %", NewVATPct);
        VATPostingSetup.MODIFY(true);
    end;

    local procedure UpdateSalesSetup();
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        with SalesSetup do begin
            GET();
            VALIDATE("OIOUBL-Default Profile Code", CreateOIOUBLProfile());
            MODIFY(true);
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

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
    end;

    [MessageHandler]
    procedure MessageHandler(Meassage: Text[1024]);
    begin
    end;

    [ModalPageHandler]
    procedure PostAndSendConfirmationModalPageHandler(var PostandSendConfirmation: TestPage "Post and Send Confirmation")
    begin
        PostandSendConfirmation.SelectedSendingProfiles.AssistEdit();
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
}

