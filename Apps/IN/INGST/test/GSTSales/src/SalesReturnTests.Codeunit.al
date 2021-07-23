codeunit 18193 "Sales Return Tests"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryGSTSales: Codeunit "Library GST Sales";
        ComponentPerArray: array[20] of Decimal;
        Storage: Dictionary of [Text, Text[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        LocationCodeLbl: Label 'LocationCode';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        LocationStateCodeLbl: Label 'LocationStateCode';
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        ExemptedLbl: Label 'Exempted';
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode';
        CustomerNoLbl: Label 'CustomerNo';
        ToStateCodeLbl: Label 'ToStateCode';
        PriceInclusiveOfTaxLbl: Label 'WithPIT';

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromSalesCreditMemoForRegCustInterStateWithPIT()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling Tax Value Calculation when Price is Inclusive of GST in case of Inter-state Sales of Goods through Sales Credit Memo.
        // [FEATURE] [Sales Credit Memo] [Inter-State GST,Registered Customer]

        // [GIVEN] Created GST Setup and Tax Rates for Registered Customer with Interstate Jurisdiction and Price Incusive of Tax Setup
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false);
        SalesWithPriceInclusiveOfTax(true);

        // [WHEN] Create and Post Sales Invoice and Sales Credit Memo
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Credit Memo",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST Ledger Entries and Detailed GST Ledger Entries
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl), Database::"Sales Cr.Memo Header");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromSalesCreditMemoForRegCustIntraStateWithPIT()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO] Check if the system is handling Tax Value Calculation when Price is Inclusive of GST in case of Intra-state Sales of Goods through Sale Credit Memo.
        // [FEATURE] [Sales Credit Memo] [Intra-State GST,Registered Customer]

        // [GIVEN] Created GST Setup and Tax Rates for Registered Customer with Intrastate Jurisdiction and Price Incusive of Tax Setup
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, false, false);
        InitializeShareStep(false, false);
        SalesWithPriceInclusiveOfTax(true);

        // [WHEN] Create and Post Sales Invoice and Sales Credit Memo
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Credit Memo",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST Ledger Entries and Detailed GST Ledger Entries
        VerifyGSTEntries(Storage.Get(ReverseDocumentNoLbl), Database::"Sales Cr.Memo Header");
    end;

    // [SCENARIO] [354276] Check if the system is calculating GST is case of Inter-State Sales Return of Goods from Registered Customer through Sale Return Orders
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromSalesReturnOrderForRegCustInterState()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Return Order",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
    end;

    // [SCENARIO] [354286] Check if the system is calculating GST is case of Inter-State Sales Return of Services from Registered Customer through Sale Return Orders
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromInterStateSalesReturnOrderOfServiceForRegCust()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, false, false);

        // [WHEN] Create and Return Order from posted invoice
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Return Order",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
    end;

    // [SCENARIO] [354310] Check if the system is calculating GST is case of Inter-State Sales Return of Goods from Registered Customer through Sale Credit Memos
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromInterStateSalesCreditMemoOfGoodsForRegCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Credit Memo",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
    end;

    // [SCENARIO] [354343] Check if the system is calculating GST is case of Inter-State Sales Return of Services from Registered Customer through Sale Credit Memos
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromInterStateSalesCreditMemoOfServiceForRegCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, false, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Credit Memo",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
    end;

    // [SCENARIO] [354278] Check if the system is calculating GST is case of Inter-State Sales Return of Goods from Unregistered Customer through Sale Return Orders
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromInterStateSalesReturnOrderForUnRegCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Goods, false, false);

        // [WHEN] Create and Post Sales Return Order
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Return Order",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
    end;

    // [SCENARIO] [354287] Check if the system is calculating GST is case of Inter-State Sales Return of Services from Unregistered Customer through Sale Return Orders
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromInterStateSalesReturnOrderOfServiceForUnRegCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Service, false, false);

        // [WHEN] Create and Post Sales Return Order from posted invoice
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Return Order",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
    end;

    // [SCENARIO] [354312] Check if the system is calculating GST is case of Inter-State Sales Return of Goods from Registered Customer through Sale Credit Memos
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromIntraStateSalesCreditMemoOfGoodsForUnRegCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Credit Memo",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [354344] Check if the system is calculating GST is case of Inter-State Sales Return of Services from Unregistered Customer through Sale Credit Memos
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromInterStateSalesCreditMemoOfServiceForUnRegCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Service, false, false);

        // [WHEN] Create and Post Sales Invoice
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Credit Memo",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 1);
    end;

    // [SCENARIO] [354272] Check if the system is calculating GST is case of Intra-State Sales Return of Goods from Registered Customer through Sale Return Orders.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromIntraStateSalesReturnOrderGoodsForRegCust()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Return Order",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [354275] Check if the system is calculating GST is case of Intra-State Sales Return of Goods from Unregistered Customer through Sale Return Orders.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromIntraStateSalesReturnOrderGoodsForUnRegCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Return Order",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [354283] Check if the system is calculating GST is case of Intra-State Sales Return of Services from Registered Customer through Sale Return Orders.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromIntraStateSalesReturnOrderServicesForRegCust()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Return Order",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [354284] Check if the system is calculating GST is case of Intra-State Sales Return of Services from Unregistered Customer through Sale Return Orders.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromIntraStateSalesReturnOrderServicesForUnRegCustomer()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Return Order",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [354296] Check if the system is calculating GST is case of Intra-State Sales Return of Goods from Registered Customer through Sale Credit Memos.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromIntraStateSalesCreditMemoGoodsForRegCust()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Credit Memo",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [354300] Check if the system is calculating GST is case of Intra-State Sales Return of Goods from Unregistered Customer through Sale Credit Memos.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromIntraStateSalesCreditMemoGoodsForUnRegCust()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Goods, true, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Credit Memo",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [354333] Check if the system is calculating GST is case of Intra-State Sales Return of Services from Registered Customer through Sale Credit Memos.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromIntraStateSalesCreditMemoServicesForRegCust()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Credit Memo",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    // [SCENARIO] [354334] Check if the system is calculating GST is case of Intra-State Sales Return of Services from Unregistered Customer through Sale Credit Memos.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure PostFromIntraStateSalesCreditMemoServicesForUnRegCust()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created GST Setup
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Sales Journal
        PostedInvoiceNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::"G/L Account",
            DocumentType::Invoice);
        Storage.Set(PostedDocumentNoLbl, PostedInvoiceNo);
        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            Storage.Get(CustomerNoLbl),
            DocumentType::"Credit Memo",
            CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        // [THEN] Verify GST ledger Entries
        LibraryGST.GSTLedgerEntryCount(Storage.Get(ReverseDocumentNoLbl), 2);
    end;

    local procedure CreateAndPostSalesDocumentFromCopyDocument(
        var SalesHeader: Record "Sales Header";
        CustomerNo: Code[20];
        DocumentType: Enum "Sales Document Type";
        LocationCode: Code[10])
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        ReverseDocumentNo: Code[20];
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Modify(true);
        CopyDocumentMgt.SetProperties(true, false, false, false, true, false, false);
        CopyDocumentMgt.CopySalesDocForInvoiceCancelling(Storage.Get(PostedDocumentNoLbl), SalesHeader);
        UpdateReferenceInvoiceNoAndVerify(SalesHeader);
        ReverseDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure UpdateSalesLine(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                SalesLine.Validate("Unit Price");
                SalesHeader.Modify(true);
            until SalesLine.Next() = 0;
    end;

    local procedure UpdateReferenceInvoiceNoAndVerify(var SalesHeader: Record "Sales Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        ReferenceInvoiceNoMgt: Codeunit "Reference Invoice No. Mgt.";
    begin
        UpdateSalesLine(SalesHeader);
        ReferenceInvoiceNo.Init();
        ReferenceInvoiceNo.Validate("Document No.", SalesHeader."No.");
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::"Credit Memo":
                ReferenceInvoiceNo.Validate("Document Type", ReferenceInvoiceNo."Document Type"::"Credit Memo");
            SalesHeader."Document Type"::"Return Order":
                ReferenceInvoiceNo.Validate("Document Type", ReferenceInvoiceNo."Document Type"::"Return Order");
        end;
        ReferenceInvoiceNo.Validate("Source Type", ReferenceInvoiceNo."Source Type"::Customer);
        ReferenceInvoiceNo.Validate("Source No.", SalesHeader."Sell-to Customer No.");
        ReferenceInvoiceNo.Validate("Reference Invoice Nos.", Storage.Get(PostedDocumentNoLbl));
        ReferenceInvoiceNo.Insert(true);
        ReferenceInvoiceNoMgt.UpdateReferenceInvoiceNoforCustomer(ReferenceInvoiceNo, ReferenceInvoiceNo."Document Type", ReferenceInvoiceNo."Document No.");
        ReferenceInvoiceNoMgt.VerifyReferenceNo(ReferenceInvoiceNo);
    end;

    local procedure CreateGSTSetup(
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean;
        ReverseCharge: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        CustomerStateCode: Code[10];
        LocPANNo: Code[20];
        GSTGroupCode: Code[20];
        HSNSACCode: Code[10];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentCode: Text[30];
    begin
        FillCompanyInformation();
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := LibraryGST.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPANNo := CompanyInformation."P.A.N. No.";
        LocationStateCode := LibraryGST.CreateInitialSetup();
        Storage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);

        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        Storage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", ReverseCharge);
        Storage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(HSNSACCodeLbl, HSNSACCode);

        if IntraState then begin
            CustomerNo := LibraryGST.CreateCustomerSetup();
            UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, LocationStateCode, LocPANNo);
            InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
        end else begin
            CustomerStateCode := LibraryGST.CreateGSTStateCode();

            CustomerNo := LibraryGST.CreateCustomerSetup();
            UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, CustomerStateCode, LocPANNo);

            if GSTCustomerType in [GSTCustomerType::Export, GSTCustomerType::"SEZ Development", GSTCustomerType::"SEZ Unit"] then
                InitializeTaxRateParameters(IntraState, '', LocationStateCode)
            else
                InitializeTaxRateParameters(IntraState, CustomerStateCode, LocationStateCode);
        end;
        Storage.Set(CustomerNoLbl, CustomerNo);

        CreateTaxRate();
        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);

    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentCode: Text[30])
    begin
        if not IntraState then begin
            GSTComponentCode := IGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentCode := CGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentCode := SGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    local procedure InitializeShareStep(
        Exempted: Boolean;
        LineDiscount: Boolean)
    begin
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure InitializeTaxRateParameters(
        IntraState: Boolean;
        FromState: Code[10];
        ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
    begin
        Storage.Set(FromStateCodeLbl, FromState);
        Storage.Set(ToStateCodeLbl, ToState);
        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);
        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
            ComponentPerArray[3] := 0.00;
        end else
            ComponentPerArray[4] := GSTTaxPercent;
    end;

    local procedure CreateTaxRate()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure UpdateCustomerSetupWithGST(
        CustomerNo: Code[20];
        GSTCustomerType: Enum "GST Customer Type";
        StateCode: Code[10];
        PANNo: Code[20])
    var
        Customer: Record Customer;
        State: Record State;
    begin
        Customer.Get(CustomerNo);
        if (GSTCustomerType <> GSTCustomerType::Export) then begin
            State.Get(StateCode);
            Customer.Validate("State Code", StateCode);
            Customer.Validate("P.A.N. No.", PANNo);
            if not ((GSTCustomerType = GSTCustomerType::" ") or (GSTCustomerType = GSTCustomerType::Unregistered)) then
                Customer.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end;
        Customer.Validate("GST Customer Type", GSTCustomerType);
        Customer.Modify(true);
    end;

    local procedure CreateAndPostSalesDocument(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
        DocumentType: Enum "Sales Document Type"): Code[20];
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        PostedDocumentNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        Evaluate(LocationCode, CopyStr(Storage.Get(LocationCodeLbl), 1, 10));

        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Generate E-Inv. on Sales Post" = false then begin
            GeneralLedgerSetup."Generate E-Inv. on Sales Post" := true;
            GeneralLedgerSetup.Modify();
        end;

        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        CanceleInvoice(PostedDocumentNo);

        exit(PostedDocumentNo);
    end;

    local procedure CanceleInvoice(DocumentNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        eInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
    begin
        SalesInvoiceHeader.Get(DocumentNo);

        SalesInvoiceHeader."Cancel Reason" := SalesInvoiceHeader."Cancel Reason"::"Data Entry Mistake";
        SalesInvoiceHeader.Modify();

        eInvoiceJsonHandler.SetSalesInvHeader(SalesInvoiceHeader);
        eInvoiceJsonHandler.GenerateCanceledInvoice();
    end;

    local procedure CreateSalesHeaderWithGST(
        var SalesHeader: Record "Sales Header";
        CustomerNo: Code[20];
        DocumentType: Enum "Sales Document Type";
        LocationCode: Code[10])
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Modify(true);
    end;

    local procedure CreateSalesLineWithGST(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
        Quantity: Decimal;
        Exempted: Boolean;
        LineDiscount: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
    begin
        case LineType of
            LineType::Item:
                LineTypeNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
            LineType::"G/L Account":
                LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, false);
            LineType::"Fixed Asset":
                LineTypeNo := LibraryGST.CreateFixedAssetWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
        end;

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, LineType, LineTypeno, Quantity);
        SalesLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
        if LineDiscount then begin
            SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
            LibraryGST.UpdateLineDiscAccInGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
        end;

        if StorageBoolean.ContainsKey(PriceInclusiveOfTaxLbl) then
            if StorageBoolean.Get(PriceInclusiveOfTaxLbl) = true then
                SalesLine.Validate("Price Inclusive of Tax", true);
        SalesLine.Validate("Unit Price Incl. of Tax", LibraryRandom.RandInt(10000));

        SalesLine.Validate("Unit Price", LibraryRandom.RandInt(10000));
        SalesLine.Modify(true);
    end;

    local procedure VerifyGSTEntries(DocumentNo: Code[20]; TableID: Integer)
    begin
        LibraryGSTSales.VerifyGSTEntries(DocumentNo, TableID, ComponentPerArray);
    end;

    local procedure SalesWithPriceInclusiveOfTax(WithPIT: Boolean)
    begin
        StorageBoolean.Set(PriceInclusiveOfTaxLbl, WithPIT);
    end;

    local procedure FillCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        if CompanyInformation."State Code" = '' then
            CompanyInformation.Validate("State Code", LibraryGST.CreateGSTStateCode());
        if CompanyInformation."P.A.N. No." = '' then
            CompanyInformation.Validate("P.A.N. No.", LibraryGST.CreatePANNos());
        CompanyInformation.Modify(true);
    end;

    [ModalPageHandler]
    procedure CustomerLedgerEntries(var CustomerLedgerEntries: TestPage "Customer Ledger Entries")
    begin
        CustomerLedgerEntries.OK().Invoke();
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(Storage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(Storage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(WorkDate());
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); // SGST
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); // CGST
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]); // IGST
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[3]); // KFloodCess
        TaxRates.OK().Invoke();
    end;
}