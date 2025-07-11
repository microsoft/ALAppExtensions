codeunit 139614 "EU 3-Party Test"
{
    // [FEATURE] [EU 3-Party] [Purchase]
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPlanning: Codeunit "Library - Planning";
        IsInitialized: Boolean;

    [Test]
    [Scope('OnPrem')]
    procedure PurchaseInvoiceEUThirdPartyTradeTrue()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // Test to verify EU 3-Party Trade True after posting Purchase Invoice.
        PostPurchaseDocumentWithEUThirdParty(PurchaseHeader."Document Type"::Invoice, true);  // True for EU 3-Party Trade.
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchaseOrderEUThirdPartyTradeTrue()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // Test to verify EU 3-Party Trade True after posting Purchase Order.
        PostPurchaseDocumentWithEUThirdParty(PurchaseHeader."Document Type"::Order, true);  // True for EU 3-Party Trade.
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchaseOrderEUThirdPartyTradeFalse()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // Test to verify EU 3-Party Trade False after posting Purchase Order.
        PostPurchaseDocumentWithEUThirdParty(PurchaseHeader."Document Type"::Order, false);  // False for EU 3-Party Trade.
    end;

    local procedure PostPurchaseDocumentWithEUThirdParty(DocumentType: Enum "Purchase Document Type"; EUThirdPartyTrade: Boolean)
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        // Setup.
        Initialize();
        CreatePurchaseHeader(PurchaseHeader, DocumentType, EUThirdPartyTrade, '');  // Blank for Customer No.
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItem(Item), LibraryRandom.RandDec(10, 2));  // Take random Quantity.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));
        PurchaseLine.Modify(true);

        // Exercise.
        PurchInvHeader.Get(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));  // True for receive and invoice.

        // Verify.
        PurchInvHeader.TestField("EU 3 Party Trade", EUThirdPartyTrade);
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure EUThirdPartyTrueOnSalesFalseOnPurchase()
    begin
        // Test to verify EU 3-Party Trade on Purchase Order, When EU 3-Party Trade True on Sales Header, True on Purchase Header and confirm message Yes.
        PurchaseDropShipmentWithEUThirdParty(true, false, true);  // EU 3-Party Trade - True on Sales Header, False and True on Purchase Header.
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler,ConfirmHandlerFalse')]
    [Scope('OnPrem')]
    procedure EUThirdPartyFalseOnPurchaseTrueOnSales()
    begin
        // Test to verify EU 3-Party Trade on Purchase Order, When EU 3-Party Trade True on Sales Header, False on Purchase Header and confirm message No.
        PurchaseDropShipmentWithEUThirdParty(true, false, false);  // EU 3-Party Trade - True on Sales Header, False and True on Purchase Header.
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure EUThirdPartyFalseOnSalesTrueOnPurchase()
    begin
        // Test to verify EU 3-Party Trade on Purchase Order, When EU 3-Party Trade False on Sales Header, True on Purchase Header and confirm message Yes.
        PurchaseDropShipmentWithEUThirdParty(false, true, false);  // EU 3-Party Trade - False on Sales Header, True and False on Purchase Header.
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler,ConfirmHandlerFalse')]
    [Scope('OnPrem')]
    procedure EUThirdPartyTrueOnPurchaseFalseOnSales()
    begin
        // Test to verify EU 3-Party Trade on Purchase Order, When EU 3-Party Trade False on Sales Header, True on Purchase Header and confirm message No.
        PurchaseDropShipmentWithEUThirdParty(false, true, true);  // EU 3-Party Trade - False on Sales Header, True and True on Purchase Header.
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler')]
    [Scope('OnPrem')]
    procedure EUThirdPartyFalseOnPurchaseFalseOnSales()
    begin
        // Test to verify EU 3-Party Trade on Purchase Order, When EU 3-Party Trade False on Sales Header, False on Purchase Header.
        PurchaseDropShipmentWithEUThirdParty(false, false, false);  // EU 3-Party Trade - False on Sales Header, False and False on Purchase Header.
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler')]
    [Scope('OnPrem')]
    procedure EUThirdPartyTrueOnPurchaseTrueOnSales()
    begin
        // Test to verify EU 3-Party Trade on Purchase Order, When EU 3-Party Trade True on Sales Header, True on Purchase Header.
        PurchaseDropShipmentWithEUThirdParty(true, true, true);  // EU 3-Party Trade - True on Sales Header, True and True on Purchase Header.
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;
        EnableEU3PartyTradePurchase();
        DisableCheckDocTotalAmount();
        IsInitialized := true;
    end;

    local procedure PurchaseDropShipmentWithEUThirdParty(EUThirdPartyTradeSales: Boolean; EUThirdPartyTradePurchase: Boolean; EUThirdPartyTrade: Boolean)
    var
        Customer: Record Customer;
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // Setup.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("EU 3-Party Trade", EUThirdPartyTradeSales);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItem(Item), LibraryRandom.RandDec(10, 2));  // Take random Quantity.
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        SalesLine.Validate("Purchasing Code", FindPurchasingCode());
        SalesLine.Modify(true);
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, EUThirdPartyTradePurchase, Customer."No.");

        // Exercise.
        LibraryPurchase.GetDropShipment(PurchaseHeader);  // Opens SalesListModalPageHandler.

        // Verify.
        PurchaseHeader.TestField("EU 3 Party Trade", EUThirdPartyTrade);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        PurchaseLine.TestField("No.", SalesLine."No.");
        PurchaseLine.TestField(Quantity, SalesLine.Quantity);
    end;

    [Test]
    [HandlerFunctions('VATStatementPreviewPageHandler,VATStatementTemplateListModalPageHandler')]
    [Scope('OnPrem')]
    procedure VATStatementPreviewForPurchaseInvWithoutCurrency()
    begin
        // Test to verify Amount on VAT Statement Preview page for Purchase Invoice with EUThirdPartyTrade and without Currency.

        // Setup.
        Initialize();
        VATStatementPreviewForPurchaseInvoiceWithEUThirdPartyTrade('');  // Using Blank for Currency Code.
    end;

    [Test]
    [HandlerFunctions('VATStatementPreviewPageHandler,VATStatementTemplateListModalPageHandler')]
    [Scope('OnPrem')]
    procedure VATStatementPreviewForPurchaseInvoiceWithCurrency()
    var
        CurrencyCode: Code[10];
    begin
        // Test to verify Amount on VAT Statement Preview page for Purchase Invoice with EUThirdPartyTrade and Currency.

        // Setup: Create Currency with Exchange rate and update Additional Reporting Currency on General Ledger Setup.
        Initialize();
        CurrencyCode := CreateCurrencyWithExchangeRate();
        UpdateAdditionalReportingCurrOnGeneralLedgerSetup(CurrencyCode);
        VATStatementPreviewForPurchaseInvoiceWithEUThirdPartyTrade(CurrencyCode);
    end;

    local procedure VATStatementPreviewForPurchaseInvoiceWithEUThirdPartyTrade(CurrencyCode: Code[10])
    var
        PurchaseLine: Record "Purchase Line";
        VATStatementLine: Record "VAT Statement Line";
        VATStatement: TestPage "VAT Statement";
        OldInvoiceRounding: Boolean;
    begin
        // Create and Post Purchase Invoice with EUThirdPartyTrade. Create VAT Statement Line. Open VAT Statement page.
        OldInvoiceRounding := UpdatePurchasesPayablesSetup(false);  // False for Invoice Rounding.
        CreateAndPostPurchaseInvoice(PurchaseLine, CurrencyCode);
        CreateVATStatementLine(
          VATStatementLine, VATStatementLine."Gen. Posting Type"::Purchase, PurchaseLine."VAT Bus. Posting Group",
          PurchaseLine."VAT Prod. Posting Group");
        LibraryVariableStorage.Enqueue(VATStatementLine."Statement Template Name");  // Enqueue for VATStatementTemplateListModalPageHandler.
        LibraryVariableStorage.Enqueue(
          LibraryERM.ConvertCurrency(PurchaseLine."Line Amount" * PurchaseLine."VAT %" / 100, CurrencyCode, '', WorkDate()));  // Enqueue for VATStatementPreviewPageHandler. Using Blank for ToCurrency.
        VATStatement.OpenEdit();
        VATStatement.CurrentStmtName.SetValue(VATStatementLine."Statement Name");

        // Exercise.
        VATStatement."P&review".Invoke();  // Opens VATStatementTemplateListModalPageHandler and VATStatementPreviewPageHandler.

        // Verify: Verification is done in VATStatementPreviewPageHandler.
        VATStatement.Close();

        // Tear Down.
        UpdatePurchasesPayablesSetup(OldInvoiceRounding);
        DeleteVATStatementTemplate(VATStatementLine."Statement Template Name");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VATEntryForPurchaseInvoiceEUThirdPartyTrue()
    var
        PurchaseHeader: Record "Purchase Header";
        PostedPurchaseInvioceNo: Code[20];
    begin
        // [FEATURE] [Purchase] [VAT]
        // [SCENARIO 225986] VAT Entry EU Third Party is TRUE if Posted Purchase Invoice EU Third Party is TRUE
        Initialize();

        // [GIVEN] Purchase Invoice "PI" with EU Third Party = TRUE
        // [WHEN] Post "PI"
        PostedPurchaseInvioceNo := CreateAndPostPurchaseInvoiceWithEUThirdParty(PurchaseHeader, true);
        // [THEN] Created VAT Entry EU Third Party is TRUE
        VerifyVATEntryEUThirdPartyTrade(PostedPurchaseInvioceNo, true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VATEntryForPurchaseInvoiceEUThirdPartyFalse()
    var
        PurchaseHeader: Record "Purchase Header";
        PostedPurchaseInvioceNo: Code[20];
    begin
        // [FEATURE] [Purchase] [VAT]
        // [SCENARIO 225986] VAT Entry EU Third Party is FALSE if Posted Purchase Invoice EU Third Party is FALSE
        Initialize();

        // [GIVEN] Purchase Invoice "PI" with EU Third Party = FALSE
        // [WHEN] Post "PI"
        PostedPurchaseInvioceNo := CreateAndPostPurchaseInvoiceWithEUThirdParty(PurchaseHeader, false);
        // [THEN] Created VAT Entry EU Third Party is FALSE
        VerifyVATEntryEUThirdPartyTrade(PostedPurchaseInvioceNo, false);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure S461741_EUThirdPartyTradeCopiedOnPurchaseOrderFromDropShipmentSalesOrder()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReqWkshTemplate: Record "Req. Wksh. Template";
        RequisitionWkshName: Record "Requisition Wksh. Name";
        RequisitionLine: Record "Requisition Line";
        GetSalesOrders: Report "Get Sales Orders";
    begin
        // [FEATURE] [Special Order] [Drop Shipment] [Requisition Worksheet] [Purchase] [EU 3-Party Trade]
        // [SCENARIO 461741] "EU 3 Party Trade" flag is copied from Sales Order in a Drop Shipment Purchase Order created from the Requisition Worksheet.
        Initialize();

        // [GIVEN] Create Sales Order with "EU 3-Party Trade" and "Drop Shipment".
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("EU 3-Party Trade", true);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItem(Item), LibraryRandom.RandDec(10, 2));  // Take random Quantity.
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        SalesLine.Validate("Drop Shipment", true);
        SalesLine.Modify(true);

        // [GIVEN] Execute Get Sales Orders in Requisition Worksheet.
        ReqWkshTemplate.SetRange(Type, ReqWkshTemplate.Type::"Req.");
        ReqWkshTemplate.FindFirst();
        LibraryPlanning.CreateRequisitionWkshName(RequisitionWkshName, ReqWkshTemplate.Name);

        RequisitionLine.Init();
        RequisitionLine.Validate("Worksheet Template Name", RequisitionWkshName."Worksheet Template Name");
        RequisitionLine.Validate("Journal Batch Name", RequisitionWkshName.Name);
        RequisitionLine.Validate("Line No.", 10000);

        Clear(GetSalesOrders);
        SalesLine.SetRange("Document Type", SalesLine."Document Type");
        SalesLine.SetRange("Document No.", SalesLine."Document No.");
        GetSalesOrders.SetTableView(SalesLine);
        GetSalesOrders.SetReqWkshLine(RequisitionLine, 0);
        GetSalesOrders.UseRequestPage(false);
        GetSalesOrders.RunModal();
        RequisitionLine.Find();

        // [GIVEN] Insert "Vendor No." in Requisition Worksheet Line.
        LibraryPurchase.CreateVendor(Vendor);
        RequisitionLine.Validate("Vendor No.", Vendor."No.");
        RequisitionLine.Modify(true);
        Commit();

        // [WHEN] Create Purchase Order from Requisition Worksheet.
        LibraryPlanning.CarryOutReqWksh(RequisitionLine, WorkDate(), WorkDate(), WorkDate(), WorkDate(), '');

        // [THEN] Find created Purchase Order and verify that "EU 3 Party Trade" is the same as in Sales Order.
        PurchaseHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        PurchaseHeader.FindFirst();
        PurchaseHeader.TestField("EU 3 Party Trade", SalesHeader."EU 3-Party Trade");

        // [THEN] Verify that Item and Quantity are the same as in Sales Order.
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        PurchaseLine.TestField("No.", SalesLine."No.");
        PurchaseLine.TestField(Quantity, SalesLine.Quantity);
    end;

    local procedure CreateAndPostPurchaseInvoice(var PurchaseLine: Record "Purchase Line"; CurrencyCode: Code[10])
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        CreateVATPostingSetup(VATPostingSetup, false);
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, true, '');  // Using True for EUThirdPartyTrade and Blank used for Customer No.
        PurchaseHeader.Validate("Currency Code", CurrencyCode);
        PurchaseHeader.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        PurchaseHeader.Modify(true);
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, CreateItem(VATPostingSetup."VAT Prod. Posting Group"),
          LibraryRandom.RandDec(10, 2));  // Random value used for Quantity.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));
        PurchaseLine.Modify(true);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);  // Post as Receive and Invoice.
    end;

    local procedure CreateAndPostPurchaseInvoiceWithEUThirdParty(var PurchaseHeader: Record "Purchase Header"; EUThirdPartyTrade: Boolean): Code[20]
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, EUThirdPartyTrade, '');
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandDec(10, 2));
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure CreateCurrencyWithExchangeRate(): Code[10]
    var
        Currency: Record Currency;
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateCurrency(Currency);
        Currency.Validate("Residual Gains Account", GLAccount."No.");
        Currency.Validate("Residual Losses Account", GLAccount."No.");
        Currency.Modify(true);
        LibraryERM.CreateRandomExchangeRate(Currency.Code);
        exit(Currency.Code);
    end;

    local procedure CreateItem(VATProdPostingGroup: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        Item.Modify(true);
        exit(Item."No.");
    end;

    local procedure CreatePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; EUThirdPartyTrade: Boolean; CustomerNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, Vendor."No.");
        PurchaseHeader.Validate("EU 3 Party Trade", EUThirdPartyTrade);
        PurchaseHeader.Validate("Sell-to Customer No.", CustomerNo);

        PurchaseHeader.Modify(true);
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; EUService: Boolean)
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code);
        VATPostingSetup.Validate("EU Service", EUService);
        VATPostingSetup.Modify(true);
    end;

    local procedure CreateVATStatementLine(var VATStatementLine: Record "VAT Statement Line"; GenPostingType: Enum "General Posting Type"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    var
        VATStatementName: Record "VAT Statement Name";
        VATStatementTemplate: Record "VAT Statement Template";
        EU3PartyTradeFilter: Enum "EU3 Party Trade Filter";
    begin
        LibraryERM.CreateVATStatementTemplate(VATStatementTemplate);
        LibraryERM.CreateVATStatementName(VATStatementName, VATStatementTemplate.Name);
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine.Validate("Row No.", Format(LibraryRandom.RandInt(100)));
        VATStatementLine.Validate(Type, VATStatementLine.Type::"VAT Entry Totaling");
        VATStatementLine.Validate("Amount Type", VATStatementLine."Amount Type"::Amount);
        VATStatementLine.Validate("Gen. Posting Type", GenPostingType);
        VATStatementLine.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        VATStatementLine.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        VATStatementLine.Validate("EU 3 Party Trade", EU3PartyTradeFilter::EU3);
        VATStatementLine.Modify(true);
    end;

    local procedure DeleteVATStatementTemplate(VATStatementTemplateName: Code[10])
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        VATStatementTemplate.Get(VATStatementTemplateName);
        VATStatementTemplate.Delete(true);
    end;

    local procedure FindPurchasingCode(): Code[10]
    var
        Purchasing: Record Purchasing;
    begin
        Purchasing.SetRange("Drop Shipment", true);
        Purchasing.FindFirst();
        exit(Purchasing.Code);
    end;

    local procedure UpdateAdditionalReportingCurrOnGeneralLedgerSetup(CurrencyCode: Code[10]) OldAdditionalReportingCurrency: Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        OldAdditionalReportingCurrency := GeneralLedgerSetup."Additional Reporting Currency";
        GeneralLedgerSetup."Additional Reporting Currency" := CurrencyCode;
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure UpdatePurchasesPayablesSetup(InvoiceRounding: Boolean) OldInvoiceRounding: Boolean
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        OldInvoiceRounding := PurchasesPayablesSetup."Invoice Rounding";
        PurchasesPayablesSetup.Validate("Invoice Rounding", InvoiceRounding);
        PurchasesPayablesSetup.Modify(true);
    end;

    local procedure VerifyVATEntryEUThirdPartyTrade(DocumentNo: Code[20]; EUThirdPartyTrade: Boolean)
    var
        VATEntry: Record "VAT Entry";
    begin
        with VATEntry do begin
            SetRange("Document No.", DocumentNo);
            FindFirst();
            TestField("EU 3-Party Trade", EUThirdPartyTrade);
        end;
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure VATStatementPreviewPageHandler(var VATStatementPreview: TestPage "VAT Statement Preview")
    begin
        VATStatementPreview.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure SalesListModalPageHandler(var SalesList: TestPage "Sales List")
    begin
        SalesList.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure VATStatementTemplateListModalPageHandler(var VATStatementTemplateList: TestPage "VAT Statement Template List")
    var
        VATStatementTemplateName: Variant;
    begin
        LibraryVariableStorage.Dequeue(VATStatementTemplateName);
        VATStatementTemplateList.FILTER.SetFilter(Name, VATStatementTemplateName);
        VATStatementTemplateList.OK().Invoke();
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure VATStatementRequestPageHandler(var VATStatement: TestRequestPage "VAT Statement")
    var
        VATStatementName: Variant;
    begin
        LibraryVariableStorage.Dequeue(VATStatementName);
        VATStatement."VAT Statement Name".SetFilter(Name, VATStatementName);
        VATStatement.StartingDate.SetValue(WorkDate());
        VATStatement.EndingDate.SetValue(WorkDate());
        VATStatement.ShowAmtInAddCurrency.SetValue(true);
        VATStatement.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure VATVIESDeclarationTaxAuthRequestPageHandler(var VATVIESDeclarationTaxAuth: TestRequestPage "VAT- VIES Declaration Tax Auth")
    var
        VATRegistrationNoFilter: Variant;
    begin
        LibraryVariableStorage.Dequeue(VATRegistrationNoFilter);
        VATVIESDeclarationTaxAuth.ShowAmountsInAddReportingCurrency.SetValue(true);
        VATVIESDeclarationTaxAuth.StartingDate.SetValue(WorkDate());
        VATVIESDeclarationTaxAuth.EndingDate.SetValue(WorkDate());
        VATVIESDeclarationTaxAuth.VATRegistrationNoFilter.SetValue(VATRegistrationNoFilter);
        VATVIESDeclarationTaxAuth.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    local procedure DisableCheckDocTotalAmount()
    var
        PurchasesPayablesSetupRecRef: RecordRef;
        CheckDocTotalAmountsFieldRef: FieldRef;
    begin
        PurchasesPayablesSetupRecRef.Open(Database::"Purchases & Payables Setup", false, CompanyName);
        if PurchasesPayablesSetupRecRef.FieldExist(11320) then begin //Check Doc. Total Amounts (11320, Boolean)
            PurchasesPayablesSetupRecRef.FindFirst();
            CheckDocTotalAmountsFieldRef := PurchasesPayablesSetupRecRef.Field(11320);
            CheckDocTotalAmountsFieldRef.Value := false;
            PurchasesPayablesSetupRecRef.Modify();
        end;
        PurchasesPayablesSetupRecRef.Close();
    end;

    local procedure EnableEU3PartyTradePurchase();
    var
        VATSetup: Record "VAT Setup";
    begin
        VATSetup.Get();
        VATSetup."Enable EU 3-Party Purchase" := true;
        VATSetup.Modify(true);
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerTrue(Message: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerFalse(Message: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;
}

