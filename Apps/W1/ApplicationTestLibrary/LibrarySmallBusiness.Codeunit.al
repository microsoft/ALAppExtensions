/// <summary>
/// Provides utility functions for small business scenarios in test cases, including simplified setup and common operations.
/// </summary>
codeunit 132213 "Library - Small Business"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryJob: Codeunit "Library - Job";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRapidStart: Codeunit "Library - Rapid Start";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryDimension: Codeunit "Library - Dimension";

    procedure CreateCommentLine(var CommentLine: Record "Comment Line"; TableName: Enum "Comment Line Table Name"; No: Code[20])
    var
        RecRef: RecordRef;
    begin
        Clear(CommentLine);
        CommentLine.Validate("Table Name", TableName);
        CommentLine.Validate("No.", No);
        RecRef.GetTable(CommentLine);
        CommentLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, CommentLine.FieldNo("Line No.")));
        CommentLine.Insert(true);
    end;

    procedure CreateSalesCommentLine(var SalesCommentLine: Record "Sales Comment Line"; SalesLine: Record "Sales Line")
    var
        NextLineNo: Integer;
    begin
        Clear(SalesCommentLine);
        SalesCommentLine.SetRange("Document Type", SalesLine."Document Type".AsInteger());
        SalesCommentLine.SetRange("No.", SalesLine."No.");
        SalesCommentLine.SetRange("Document Line No.", SalesLine."Line No.");
        if SalesCommentLine.FindLast() then
            NextLineNo := SalesCommentLine."Line No." + 10000
        else
            NextLineNo := 10000;

        Clear(SalesCommentLine);
        SalesCommentLine.Init();
        SalesCommentLine."Document Type" := SalesLine."Document Type";
        SalesCommentLine."No." := SalesLine."Document No.";
        SalesCommentLine."Document Line No." := SalesLine."Line No.";
        SalesCommentLine."Line No." := NextLineNo;
        SalesCommentLine.Date := LibraryUtility.GenerateRandomDate(WorkDate() + 10, WorkDate() + 20);
        SalesCommentLine.Comment := LibraryUtility.GenerateRandomCode(SalesCommentLine.FieldNo(Comment), DATABASE::"Sales Comment Line");
        SalesCommentLine.Insert(true);
    end;

    procedure CreateCustomer(var Customer: Record Customer)
    begin
        LibrarySales.CreateCustomer(Customer);
    end;

    procedure CreateCustomerSalesCode(var StandardCustomerSalesCode: Record "Standard Customer Sales Code"; CustomerNo: Code[20]; "Code": Code[10])
    begin
        StandardCustomerSalesCode.Init();
        StandardCustomerSalesCode.Validate("Customer No.", CustomerNo);
        StandardCustomerSalesCode.Validate(Code, Code);
        StandardCustomerSalesCode.Insert(true);
    end;

    procedure CreateCustomerTemplateLine(ConfigTemplateHeader: Record "Config. Template Header"; FieldNo: Integer; FieldName: Text[30]; DefaultValue: Text[50])
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        LibraryRapidStart.CreateConfigTemplateLine(ConfigTemplateLine, ConfigTemplateHeader.Code);
        ConfigTemplateLine.Validate("Field ID", FieldNo);
        ConfigTemplateLine.Validate("Field Name", FieldName);
        if DefaultValue <> '' then
            ConfigTemplateLine.Validate("Default Value", DefaultValue)
        else
            ConfigTemplateLine.Validate("Default Value", Format(LibraryRandom.RandIntInRange(100000000, 999999999)));
        ConfigTemplateLine.Validate("Skip Relation Check", false);
        ConfigTemplateLine.Modify(true);
    end;

    procedure CreateCustomerTemplate(var ConfigTemplateHeader: Record "Config. Template Header")
    var
        Customer: Record Customer;
    begin
        LibraryRapidStart.CreateConfigTemplateHeader(ConfigTemplateHeader);
        ConfigTemplateHeader.Validate("Table ID", DATABASE::Customer);
        ConfigTemplateHeader.Modify(true);

        CreateCustomerTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Phone No."),
          Customer.FieldName("Phone No."), '');
        CreateCustomerTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Our Account No."),
          Customer.FieldName("Our Account No."), '');
        CreateCustomerTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Gen. Bus. Posting Group"),
          Customer.FieldName("Gen. Bus. Posting Group"), FindGenBusPostingGroup());
        CreateCustomerTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Customer Posting Group"),
          Customer.FieldName("Customer Posting Group"), LibrarySales.FindCustomerPostingGroup());
    end;

    procedure CreateCurrencyExchangeRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; CurrencyCode: Code[10]; StartingDate: Date)
    begin
        Clear(CurrencyExchangeRate);
        CurrencyExchangeRate.Validate("Currency Code", CurrencyCode);
        CurrencyExchangeRate.Validate("Starting Date", StartingDate);
        CurrencyExchangeRate.Validate("Exchange Rate Amount", LibraryRandom.RandDec(10, 2));
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount",
          CurrencyExchangeRate."Exchange Rate Amount" * LibraryRandom.RandDec(10, 2));

        CurrencyExchangeRate.Insert(true);
    end;

    procedure CreateExtendedTextHeader(var ExtendedTextHeader: Record "Extended Text Header"; TableNameOption: Enum "Extended Text Table Name"; No: Code[20])
    begin
        Clear(ExtendedTextHeader);
        ExtendedTextHeader.Validate("Table Name", TableNameOption);
        ExtendedTextHeader.Validate("No.", No);
        ExtendedTextHeader.Validate("Sales Invoice", true);
        ExtendedTextHeader.Validate("Sales Quote", true);
        ExtendedTextHeader.Insert(true);
    end;

    procedure CreateExtendedTextLine(var ExtendedTextLine: Record "Extended Text Line"; ExtendedTextHeader: Record "Extended Text Header")
    var
        RecRef: RecordRef;
    begin
        Clear(ExtendedTextLine);
        ExtendedTextLine.Validate("Table Name", ExtendedTextHeader."Table Name");
        ExtendedTextLine.Validate("No.", ExtendedTextHeader."No.");
        ExtendedTextLine.Validate("Language Code", ExtendedTextHeader."Language Code");
        ExtendedTextLine.Validate("Text No.", ExtendedTextHeader."Text No.");
        RecRef.GetTable(ExtendedTextLine);
        ExtendedTextLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ExtendedTextLine.FieldNo("Line No.")));
        ExtendedTextLine.Validate(Text, LibraryUtility.GenerateRandomCode(ExtendedTextLine.FieldNo(Text),
            DATABASE::"Extended Text Line"));
        ExtendedTextLine.Insert(true);
    end;

    procedure CreateItem(var Item: Record Item)
    begin
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item, LibraryRandom.RandDecInDecimalRange(1, 10000, 2), 0);
    end;

    procedure CreateItemAsService(var Item: Record Item)
    var
        ItemNew: Record Item;
        Item2: Record Item;
    begin
        LibraryInventory.CreateItem(Item2);
        ItemNew.Init();
        ItemNew.Insert(true);
        ItemNew.Validate("Base Unit of Measure", FindUnitOfMeasure());
        ItemNew.Validate("Unit Price", LibraryRandom.RandDecInDecimalRange(1.0, 10000.0, 2));
        ItemNew.Validate(Type, Item.Type::Service);
        ItemNew.Validate("Gen. Prod. Posting Group", Item2."Gen. Prod. Posting Group");
        if ItemNew."VAT Prod. Posting Group" = '' then
            ItemNew.Validate("VAT Prod. Posting Group", Item2."VAT Prod. Posting Group");
        ItemNew.Description := ItemNew."No.";
        ItemNew.Modify();
        OnBeforeCreateItemAsServiceItemGet(ItemNew);
        Item.Get(ItemNew."No.");
    end;

    procedure CreateJob(var Job: Record Job)
    begin
        LibraryJob.CreateJob(Job);
    end;

    procedure CreateResponsabilityCenter(var ResponsibilityCenter: Record "Responsibility Center")
    begin
        Clear(ResponsibilityCenter);
        ResponsibilityCenter.Validate(Code, LibraryUtility.GenerateRandomCode(ResponsibilityCenter.FieldNo(Code),
            DATABASE::"Responsibility Center"));
        ResponsibilityCenter.Insert();
    end;

    procedure CreateSalesInvoiceHeader(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
    end;

    procedure CreateSalesCrMemoHeader(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", Customer."No.");
    end;

    procedure CreateSalesQuoteHeaderWithLines(var SalesHeader: Record "Sales Header"; Customer: Record Customer; Item: Record Item; NumberOfLines: Integer; ItemQuantity: Integer)
    var
        SalesLine: Record "Sales Line";
        I: Integer;
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");

        for I := 1 to NumberOfLines do
            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", ItemQuantity);
    end;

    procedure CreateSalesQuoteHeader(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
    end;

    procedure CreateSalesOrderHeader(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
    end;

    procedure CreateSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Item: Record Item; Quantity: Decimal)
    begin
        // unable to use the page testability to perform this action because of following reason
        // PageTestability can't handle modal dialogs such as availability warnings when creating a sales invoice line.
        // Also, it can currently not return the Sales Line record (we need additional GetRecord or GetKey capability in PageTestability)
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", Quantity);
    end;

    procedure CreatePurchaseInvoiceHeader(var PurchHeader: Record "Purchase Header"; Vend: Record Vendor)
    begin
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, Vend."No.");
    end;

    procedure CreatePurchaseLine(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; Item: Record Item; Qty: Decimal)
    begin
        // unable to use the page testability to perform this action because of following reason
        // PageTestability can't handle modal dialogs such as availability warnings when creating a sales invoice line.
        // Also, it can currently not return the Sales Line record (we need additional GetRecord or GetKey capability in PageTestability)
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", Qty);
    end;

    procedure CreatePurchaseCrMemoHeader(var PurchHeader: Record "Purchase Header"; Vend: Record Vendor)
    begin
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::"Credit Memo", Vend."No.");
    end;

    procedure CreateStandardSalesCode(var StandardSalesCode: Record "Standard Sales Code")
    begin
        StandardSalesCode.Init();
        StandardSalesCode.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(StandardSalesCode.FieldNo(Code), DATABASE::"Standard Sales Code"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Standard Sales Code", StandardSalesCode.FieldNo(Code))));
        StandardSalesCode.Validate(Description, StandardSalesCode.Code);
        StandardSalesCode.Insert(true);
    end;

    procedure CreateStandardSalesLine(var StandardSalesLine: Record "Standard Sales Line"; StandardSalesCode: Code[10])
    var
        RecRef: RecordRef;
    begin
        StandardSalesLine.Init();
        StandardSalesLine.Validate("Standard Sales Code", StandardSalesCode);
        RecRef.GetTable(StandardSalesLine);
        StandardSalesLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, StandardSalesLine.FieldNo("Line No.")));
        StandardSalesLine.Insert(true);
    end;

    procedure CreateStandardPurchaseCode(var StandardPurchaseCode: Record "Standard Purchase Code")
    begin
        StandardPurchaseCode.Init();
        StandardPurchaseCode.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(StandardPurchaseCode.FieldNo(Code), DATABASE::"Standard Purchase Code"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Standard Purchase Code", StandardPurchaseCode.FieldNo(Code))));
        StandardPurchaseCode.Validate(Description, StandardPurchaseCode.Code);
        StandardPurchaseCode.Insert(true);
    end;

    procedure CreateStandardPurchaseLine(var StandardPurchaseLine: Record "Standard Purchase Line"; StandardPurchaseCode: Code[10])
    var
        RecRef: RecordRef;
    begin
        StandardPurchaseLine.Init();
        StandardPurchaseLine.Validate("Standard Purchase Code", StandardPurchaseCode);
        RecRef.GetTable(StandardPurchaseLine);
        StandardPurchaseLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, StandardPurchaseLine.FieldNo("Line No.")));
        StandardPurchaseLine.Insert(true);
    end;

    procedure CreateVendor(var Vendor: Record Vendor)
    begin
        LibraryPurchase.CreateVendor(Vendor);
    end;

    procedure CreateVendorPurchaseCode(var StandardVendorPurchaseCode: Record "Standard Vendor Purchase Code"; VendorNo: Code[20]; "Code": Code[10])
    begin
        StandardVendorPurchaseCode.Init();
        StandardVendorPurchaseCode.Validate("Vendor No.", VendorNo);
        StandardVendorPurchaseCode.Validate(Code, Code);
        StandardVendorPurchaseCode.Insert(true);
    end;

    procedure CreateVendorTemplate(var ConfigTemplateHeader: Record "Config. Template Header")
    var
        Vend: Record Vendor;
    begin
        LibraryRapidStart.CreateConfigTemplateHeader(ConfigTemplateHeader);
        ConfigTemplateHeader.Validate("Table ID", DATABASE::Vendor);
        ConfigTemplateHeader.Modify(true);

        CreateVendorTemplateLine(ConfigTemplateHeader, Vend.FieldNo("Phone No."),
          Vend.FieldName("Phone No."), '');
        CreateVendorTemplateLine(ConfigTemplateHeader, Vend.FieldNo("Our Account No."),
          Vend.FieldName("Our Account No."), '');
        CreateVendorTemplateLine(ConfigTemplateHeader, Vend.FieldNo("Gen. Bus. Posting Group"),
          Vend.FieldName("Gen. Bus. Posting Group"), FindGenBusPostingGroup());
        CreateVendorTemplateLine(ConfigTemplateHeader, Vend.FieldNo("Vendor Posting Group"),
          Vend.FieldName("Vendor Posting Group"), LibraryPurchase.FindVendorPostingGroup());
    end;

    procedure CreateVendorTemplateLine(ConfigTemplateHeader: Record "Config. Template Header"; FieldNo: Integer; FieldName: Text[30]; DefaultValue: Text[50])
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        LibraryRapidStart.CreateConfigTemplateLine(ConfigTemplateLine, ConfigTemplateHeader.Code);
        ConfigTemplateLine.Validate("Field ID", FieldNo);
        ConfigTemplateLine.Validate("Field Name", FieldName);
        if DefaultValue <> '' then
            ConfigTemplateLine.Validate("Default Value", DefaultValue)
        else
            ConfigTemplateLine.Validate("Default Value", Format(LibraryRandom.RandIntInRange(100000000, 999999999)));
        ConfigTemplateLine.Validate("Skip Relation Check", false);
        ConfigTemplateLine.Modify(true);
    end;

    local procedure FindGenBusPostingGroup(): Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GeneralPostingSetup.FindLast();
        exit(GeneralPostingSetup."Gen. Bus. Posting Group");
    end;

    local procedure FindUnitOfMeasure(): Code[10]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        UnitOfMeasure.FindFirst();
        exit(UnitOfMeasure.Code);
    end;

    procedure FindVATBusPostingGroupZeroVAT(VATProdPostingGroupCode: Code[20]): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetFilter("VAT Bus. Posting Group", '<>%1', '');
        VATPostingSetup.SetRange("VAT Prod. Posting Group", VATProdPostingGroupCode);
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.SetRange("VAT %", 0);
        if not VATPostingSetup.FindLast() then
            CreateZeroVATPostingSetupByProdGroupCode(VATPostingSetup, VATProdPostingGroupCode);
        exit(VATPostingSetup."VAT Bus. Posting Group");
    end;

    procedure PostSalesInvoice(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, false, true));
    end;

    procedure PostPurchaseInvoice(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true));
    end;

    procedure SetInvoiceDiscountToCustomer(var Customer: Record Customer; DiscPct: Decimal; MinimumAmount: Decimal; CurrencyCode: Code[10])
    var
        CustInvoiceDisc: Record "Cust. Invoice Disc.";
    begin
        LibraryERM.CreateInvDiscForCustomer(CustInvoiceDisc, Customer."No.", CurrencyCode, MinimumAmount);
        CustInvoiceDisc.Validate("Discount %", DiscPct);
        CustInvoiceDisc.Modify(true);
    end;

    procedure SetInvoiceDiscountToVendor(var Vendor: Record Vendor; DiscPct: Decimal; MinimumAmount: Decimal; CurrencyCode: Code[10])
    var
        VendorInvoiceDisc: Record "Vendor Invoice Disc.";
    begin
        LibraryERM.CreateInvDiscForVendor(VendorInvoiceDisc, Vendor."No.", CurrencyCode, MinimumAmount);
        VendorInvoiceDisc.Validate("Discount %", DiscPct);
        VendorInvoiceDisc.Modify(true);
    end;

    procedure SetVATBusPostingGrPriceSetup(VATProdPostingGroupCode: Code[20]; PricesIncludingVAT: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if not PricesIncludingVAT then
            exit;

        SalesSetup.Get();
        if not VATPostingSetup.Get(SalesSetup."VAT Bus. Posting Gr. (Price)", VATProdPostingGroupCode) then begin
            VATPostingSetup.Init();
            VATPostingSetup.Validate("VAT Bus. Posting Group", SalesSetup."VAT Bus. Posting Gr. (Price)");
            VATPostingSetup.Validate("VAT Prod. Posting Group", VATProdPostingGroupCode);
            VATPostingSetup.Insert();
        end;
    end;

    procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryERM.CreateVATPostingSetupWithAccounts(
          VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandIntInRange(1, 25));
    end;

    procedure CreateGLAccount(): Code[20]
    begin
        exit(LibraryERM.CreateGLAccountNo());
    end;

    procedure FindVATProdPostingGroupZeroVAT(VATBusPostingGroupCode: Code[20]): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetFilter("VAT Bus. Posting Group", VATBusPostingGroupCode);
        VATPostingSetup.SetFilter("VAT Prod. Posting Group", '<>%1', '');
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.SetRange("VAT %", 0);
        if not VATPostingSetup.FindLast() then
            CreateZeroVATPostingSetupByBusGroupCode(VATPostingSetup, VATBusPostingGroupCode);
        exit(VATPostingSetup."VAT Prod. Posting Group");
    end;

    procedure CreateGLAccountWithPostingSetup(var GLAccount: Record "G/L Account")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
        if not VATPostingSetup.FindLast() then
            CreateVATPostingSetup(VATPostingSetup);

        GLAccount.Get(CreateGLAccount());
        GLAccount.Validate(Name, GLAccount."No.");
        GLAccount.Validate("Direct Posting", true);
        GLAccount.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify();
    end;

    local procedure CreateZeroVATPostingSetupByProdGroupCode(var VATPostingSetup: Record "VAT Posting Setup"; VATProdPostingGroupCode: Code[20])
    var
        VATBusPostingGroup: Record "VAT Business Posting Group";
    begin
        VATBusPostingGroup.Init();
        VATBusPostingGroup.Validate(
          Code,
          LibraryUtility.GenerateRandomCode(
            VATBusPostingGroup.FieldNo(Code), DATABASE::"VAT Business Posting Group"));
        VATBusPostingGroup.Insert();

        CreateZeroVATPostingSetup(VATPostingSetup, VATBusPostingGroup.Code, VATProdPostingGroupCode);
    end;

    local procedure CreateZeroVATPostingSetupByBusGroupCode(var VATPostingSetup: Record "VAT Posting Setup"; VATBusPostingGroupCode: Code[20])
    var
        VATProdPostingGroup: Record "VAT Product Posting Group";
    begin
        VATProdPostingGroup.Init();
        VATProdPostingGroup.Validate(
          Code,
          LibraryUtility.GenerateRandomCode(
            VATProdPostingGroup.FieldNo(Code), DATABASE::"VAT Product Posting Group"));
        VATProdPostingGroup.Insert();

        CreateZeroVATPostingSetup(VATPostingSetup, VATBusPostingGroupCode, VATProdPostingGroup.Code);
    end;

    local procedure CreateZeroVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20])
    begin
        VATPostingSetup.Init();
        VATPostingSetup.Validate("VAT Bus. Posting Group", VATBusPostingGroupCode);
        VATPostingSetup.Validate("VAT Prod. Posting Group", VATProdPostingGroupCode);
        VATPostingSetup.Validate(
          "VAT Identifier",
          LibraryUtility.GenerateRandomCode(
            VATPostingSetup.FieldNo("VAT Identifier"), DATABASE::"VAT Posting Setup"));
        VATPostingSetup.Validate("VAT %", 0);
        VATPostingSetup.Validate("Sales VAT Account", CreateGLAccount());
        VATPostingSetup.Validate("Purchase VAT Account", CreateGLAccount());
        VATPostingSetup.Insert();
    end;

    procedure InitGlobalDimCodeValue(var DimValue: Record "Dimension Value"; DimNumber: Integer): Code[20]
    var
        GLSetup: Record "General Ledger Setup";
        Dimension: Record Dimension;
        RecRef: RecordRef;
        GlobalDimCodeFieldRef: FieldRef;
    begin
        RecRef.Open(DATABASE::"General Ledger Setup");
        RecRef.Find();
        case DimNumber of
            1:
                GlobalDimCodeFieldRef := RecRef.Field(GLSetup.FieldNo("Global Dimension 1 Code"));
            2:
                GlobalDimCodeFieldRef := RecRef.Field(GLSetup.FieldNo("Global Dimension 2 Code"));
            else
                exit;
        end;

        if Format(GlobalDimCodeFieldRef.Value) = '' then begin
            LibraryDimension.CreateDimension(Dimension);
            GlobalDimCodeFieldRef.Validate(Dimension.Code);
            RecRef.Modify(true);
            LibraryDimension.CreateDimensionValue(DimValue, Dimension.Code);
        end else begin
            DimValue.SetRange("Dimension Code", Format(GlobalDimCodeFieldRef.Value));
            DimValue.SetRange(Blocked, false);
            DimValue.FindFirst();
        end;
        exit(DimValue.Code);
    end;

    procedure FindSalesCorrectiveInvoice(var SalesInvHeader: Record "Sales Invoice Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        CancelledDocument: Record "Cancelled Document";
    begin
        CancelledDocument.FindSalesCancelledCrMemo(SalesCrMemoHeader."No.");
        SalesInvHeader.Get(CancelledDocument."Cancelled By Doc. No.");
    end;

    procedure FindSalesCorrectiveCrMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesInvHeader: Record "Sales Invoice Header")
    var
        CancelledDocument: Record "Cancelled Document";
    begin
        CancelledDocument.FindSalesCancelledInvoice(SalesInvHeader."No.");
        SalesCrMemoHeader.Get(CancelledDocument."Cancelled By Doc. No.");
    end;

    procedure FindPurchCorrectiveInvoice(var PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        CancelledDocument: Record "Cancelled Document";
    begin
        CancelledDocument.FindPurchCancelledCrMemo(PurchCrMemoHdr."No.");
        PurchInvHeader.Get(CancelledDocument."Cancelled By Doc. No.");
    end;

    procedure FindPurchCorrectiveCrMemo(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchInvHeader: Record "Purch. Inv. Header")
    var
        CancelledDocument: Record "Cancelled Document";
    begin
        CancelledDocument.FindPurchCancelledInvoice(PurchInvHeader."No.");
        PurchCrMemoHdr.Get(CancelledDocument."Cancelled By Doc. No.");
    end;

    procedure MockCancelledDocument(TableId: Integer; DocumentNo: code[20]; CancelledByDocNo: code[20])
    var
        CancelledDocument: Record "Cancelled Document";
    begin
        CancelledDocument.Init();
        CancelledDocument."Source ID" := TableId;
        CancelledDocument."Cancelled Doc. No." := DocumentNo;
        CancelledDocument."Cancelled By Doc. No." := CancelledByDocNo;
        CancelledDocument.Insert();
    end;

    procedure UpdateInvRoundingAccountWithSalesSetup(CustomerPostingGroupCode: Code[20]; GenBusPostGroupCode: Code[20])
    var
        GenPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(
          LibrarySales.GetInvRoundingAccountOfCustPostGroup(CustomerPostingGroupCode));
        GenPostingSetup.Get(GenBusPostGroupCode, GLAccount."Gen. Prod. Posting Group");
        GenPostingSetup.Validate("Sales Account", LibraryERM.CreateGLAccountNo());
        GenPostingSetup.Validate("Sales Credit Memo Account", LibraryERM.CreateGLAccountNo());
        GenPostingSetup.Modify(true);
    end;

    procedure UpdateInvRoundingAccountWithPurchSetup(CustomerPostingGroupCode: Code[20]; GenBusPostGroupCode: Code[20])
    var
        GenPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(
          LibrarySales.GetInvRoundingAccountOfCustPostGroup(CustomerPostingGroupCode));
        GenPostingSetup.Get(GenBusPostGroupCode, GLAccount."Gen. Prod. Posting Group");
        GenPostingSetup.Validate("Purch. Account", LibraryERM.CreateGLAccountNo());
        GenPostingSetup.Validate("Purch. Credit Memo Account", LibraryERM.CreateGLAccountNo());
        GenPostingSetup.Modify(true);
    end;

    procedure GetAvgDaysToPayLabel(): Text
    var
        CustomerCardCalculations: Codeunit "Customer Card Calculations";
    begin
        exit(CustomerCardCalculations.GetAvgDaysToPayLabel())
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateItemAsServiceItemGet(var Item: Record Item)
    begin
    end;
}
