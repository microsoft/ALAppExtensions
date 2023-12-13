codeunit 18916 "TCS On Sales"
{
    Subtype = Test;

    // [SCENARIO] [355200] Check if the program is calculating TCS while creating Invoice with Item using the Sales Order with multiple NOC.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithMultilineItem()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := CreateAndPostMultiLineSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(), SalesLine.Type::Item,
            true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    end;

    // [SCENARIO] [355201] Check if the program is calculating TCS while creating Invoice with Item using the Sales Invoice with multiple NOC.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithMultilineItem()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := CreateAndPostMultiLineSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    end;

    // [SCENARIO] [355206] Check if the program is calculating TCS while creating Invoice with Charge Items using the Sales Order with multiple NOC.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemAndMultipleNOC()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", true);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Show expected error
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));
    end;

    // [SCENARIO] [355207] Check if the program is calculating TCS while creating Invoice with Charge Items using the Sales Invoice with multiple NOC.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemAndMultipleNOC()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", true);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Show expected error
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));
    end;

    // [SCENARIO] [355108] Check if the program is calculating TCS using Sales Order with G/L Account Invoice in case of shipment only.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure PostFromSalesOrderTCSVerifyAndGLShipment()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L verified
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 0);
        TCSLibrary.VerifyTCSEntryCount(DocumentNo, false, 0, 0);
    end;

    // [SCENARIO] [355109] Check if the program is calculating TCS using Sales Order with Item in case of shipment only.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure PostFromSalesOrderTCSVerifyAndItemShipment()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entry Verified
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 0);
        TCSLibrary.VerifyTCSEntryCount(DocumentNo, false, 0, 0);
    end;

    // [SCENARIO] [355208] Check if the program is showing TCS amount should be shown in Statistics while creating Sales Credit Memo.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesStatisticsPageHandler')]
    procedure SalesCreditMemoWithItemAndStatsVerify()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Credit Memo
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] Verify Statistics   
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
    end;

    // [SCENARIO] [355209] Check if the program is showing TCS amount should be shown in Statistics while creating Sales Return Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure SalesReturmOrderWithItemStatsVerify()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Return Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] Verify Statistics   
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
    End;

    // [SCENARIO] [355210] Check if the program is calculating TCS using Credit Memo in case of Line Discount
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoTCSWithLineDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Credit Memo
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355211] Check if the program is calculating TCS using Return Order in case of Line Discount
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderTCSWithLineDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Return Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            true);

        // [THEN] TCS and G/L Entry Created and Verified   
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355214] Check if the program is calculating TCS using Credit Memo in case of G/L Account
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoTCSWithGLAcc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Credit Memo
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355215] Check if the program is calculating TCS using Sales Return Order in case of G/L Account
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderTCSWithGLAcc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales return orderg
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355222] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while preparing Credit Memo
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoTCSWithGLAccRounding()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        BaseAmount: Decimal;
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Credit Memo
        TCSSalesLibrary.CreateSalesDocument(SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        BaseAmount := SalesLine."Line Amount";
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, TCSLibrary.RoundTCSAmount(BaseAmount), SalesHeader."Currency Factor", true, false, false);
    End;

    // [SCENARIO] [355223] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while preparing Return Order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderTCSWithGLAccRounding()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        BaseAmount: Decimal;
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales return Order
        TCSSalesLibrary.CreateSalesDocument(SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        BaseAmount := SalesLine."Line Amount";
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, TCSLibrary.RoundTCSAmount(BaseAmount), SalesHeader."Currency Factor", true, false, false);
    End;

    // [SCENARIO] [355228] Check if the program is allowing the posting using the Credit Memo with TCS information where  TCAN No. has not been defined.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoWithoutCompanyTCANNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        TCSLibrary.RemoveTCANOnCompInfo();

        // [WHEN] Create and Post Sales Credit Memo
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] Show expected error    
        Assert.ExpectedError(TCANNoErr);
    End;


    // [SCENARIO] [355229] Check if the program is allowing the posting using the Return Order with TCS information where TCAN No. has not been defined.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderWithoutCompanyTCANNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        TCSLibrary.RemoveTCANOnCompInfo();

        // [WHEN] Create and Post Sales return Order
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] Show expected error
        Assert.ExpectedError(TCANNoErr);
    End;

    // [SCENARIO] [355230] Check if the program is calculating TCS raised to the Customer using Credit Memo and Threshold Overlook is selected with G/L Account
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoWithThresholdOverlook()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales credit memo
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355232] Check if the program is calculating TCS raised to the Customer using Return Order and Threshold Overlook is selected with G/L Account
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderWithThresholdOverlook()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Return Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355223] Check if the program is calculating TCS  raised to the Customer using Credit Memo and Threshold Overlook is not selected with G/L Account.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoWithoutThresholdOverlook()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Credit memo
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [934] Check if the program is calculating TCS on higher rate in case an invoice Charge Items  is raised to the Customer which is not having PAN No. using Sales Order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderTCSWithoutCustPANNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine1: Record "Sales Line";
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithoutPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine1, SalesLine1.Type::"Charge (Item)", false);
        TCSSalesLibrary.CreateItemChargeAssignment(ItemChargeAssignmentSales, SalesLine1, SalesHeader."Document Type"::Order,
            SalesHeader."No.", SalesLine."Line No.", SalesLine."No.");
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [935] Check if the program is calculating TCS on higher rate in case an invoice Charge Items  is raised to the Customer which is not having PAN No. using Sales Invoice
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceTCSWithoutCustPANNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine1: Record "Sales Line";
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithoutPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales invoice
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine1, SalesLine1.Type::"Charge (Item)", false);
        TCSSalesLibrary.CreateItemChargeAssignment(ItemChargeAssignmentSales, SalesLine1, SalesHeader."Document Type"::Invoice,
            SalesHeader."No.", SalesLine."Line No.", SalesLine."No.");
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [354892] Check if the program is calculating TCS using Sales Order  with G/L Account in case of Foreign Currency
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355893] Check if the program is calculating TCS using Sales Invoice with G/L Account in case of Foreign Currency
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [354894] Check if the program is calculating TCS using Sales Invoice with Item in case of Foreign Currency
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [354895] Check if the program is calculating TCS using Sales Order with Item in case of Foreign Currency
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [354900] Check if the program is calculating TCS using Sales Order with Charge Item in case of Foreign Currency
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader.Validate("Currency Code", TCSSalesLibrary.CreateCurrencyCode());
        SalesHeader.Modify(true);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));
    End;

    // [SCENARIO] [354901] Check if the program is calculating TCS using Sales Invoice with Charge Item in case of Foreign Currency
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader.Validate("Currency Code", TCSSalesLibrary.CreateCurrencyCode());
        SalesHeader.Modify(true);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));
    End;

    // [SCENARIO] [355120] Check if the program is calculating TCS using Sales Order Charge Items where TCS is applicable only on selected lines.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure PostFromSalesOrderWithMultiLineItemChargeAndSingleNoc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        ItemNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Charge (Item)",
            false);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        SalesLine.Validate("TCS Nature of Collection", '');
        SalesLine.Modify(true);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            ItemNo := SalesLine."No.";
            LibraryVarStorage.Clear();
            LibraryVarStorage.Enqueue(SalesLine);
            VerifyStatisticsForTCS(SalesHeader);
        end;
        // [THEN] Show expected error
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, ItemNo));
    End;

    // [SCENARIO] [355121] Check if the program is calculating TCS using Sales Invoice Charge Items where TCS is applicable only on selected lines.
    // [SCENARIO] [355122] Check if the program is calculating TCS using Sales Invoice Charge Items in case of shipment only.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesStatisticsPageHandler')]
    procedure PostFromSalesInvoiceWithMultiLineItemChargeAndSingleNoc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        ItemNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Charge (Item)",
            false);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        SalesLine.Validate("TCS Nature of Collection", '');
        SalesLine.Modify(true);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            ItemNo := SalesLine."No.";
            LibraryVarStorage.Clear();
            LibraryVarStorage.Enqueue(SalesLine);
            VerifyStatisticsForTCS(SalesHeader);
        end;
        // [THEN] Show expected error
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, ItemNo));
    End;


    // [SCENARIO] [355131] Check if the program is showing TCS amount should be shown in Statistics while creating Sales Order/Invoice Charge Items.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure PostFromSalesOrderWithItemChargeStatsVerify()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Show expected error
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));
    End;

    // [SCENARIO] [355133] Check if the program is calculating TCS using Sales Order in case of Line Discount with G/L Account
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderTCSWithGLAndLineDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    end;

    // [SCENARIO] [355135] Check if the program is calculating TCS using Sales Order in case of Line Discount with Item
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderTCSWithItemAndLineDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    end;

    // [SCENARIO] [355134] Check if the program is calculating TCS using Sales Invoice in case of Line Discount with G/L Account
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceTCSWithGLAndLineDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
           SalesLine.Type::"G/L Account",
            true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    end;

    // [SCENARIO] [355136] Check if the program is calculating TCS using Sales Invoice in case of Line Discount with Item
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceTCSWithItemAndLineDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    end;

    // [SCENARIO] [355141] Check if the program is calculating TCS using Sales Order in case of Line Discount with Charge Items
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure PostFromSalesOrderTCSWithChargeItemAndLineDisc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Show expected error
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));
    end;

    // [SCENARIO] [355142] Check if the program is calculating TCS using Sales Invoice in case of Line Discount with Charge Item
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesStatisticsPageHandler')]
    procedure PostFromSalesInvoiceTCSWithChargeItemAndLineDisc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);

        // [THEN] Show expected error
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));
    end;

    // [SCENARIO] [355248] Check if the program is calculating TCS using Credit Memo in case of Foreign Currency.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoWithGLForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Credit Memo
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355249] Check if the program is calculating TCS using Return Order in case of Foreign Currency.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderWithGLForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Return Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
             SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355270] Check if the program is calculating TCS using Credit Memo where TCS is applicable only on selected lines
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoWithMultiLineItemAndSingleNoc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Credit Memo
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("TCS Nature of Collection", '');
            SalesLine.Validate("Unit Price");
            SalesLine.Modify(true);
        end;
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::Item, false);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355271] Check if the program is calculating TCS using Return Order where TCS is applicable only on selected lines
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderWithMultiLineItemAndSingleNoc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Return Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("TCS Nature of Collection", '');
            SalesLine.Validate("Unit Price");
            SalesLine.Modify(true);
        end;
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::Item, false);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [354896] Check if the program is calculating TCS using Sales Order with Fixed Assets in case of Foreign Currency.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354897] Check if the program is calculating TCS using Sales Invoice with Fixed Assets in case of Foreign Currency.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355137] Check if the program is calculating TCS using Sales Order in case of Line Discount with Fixed Assets
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAAndLineDiscountForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355138] Check if the program is calculating TCS using Sales Invoice in case of Line Discount with Fixed Assets
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAAndLineDiscountForFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
           SalesLine.Type::"Fixed Asset",
            true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354833] Check if the program is calculating TCS in Sales Order with no threshold and surcharge overlook for NOD lines of a particular Customer with Fixed Assets.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderFAWithoutThresholdAndSurchargeOverlook()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354834] Check if the program is calculating TCS in Sales Invoice with no threshold and surcharge overlook for NOD lines of a particular Customer with Fixed Assets.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceFAWithoutThresholdAndSurchargeOverlook()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354836] Check if the program is calculating TCS in case an invoice is raised to the foreign Customer using Sales Order and Surcharge Overlook is selected with Fixed Assets
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderFAWithFCYAndSurchargeOverlook()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
           SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354837] Check if the program is calculating TCS in case an invoice is raised to the foreign Customer using Sales Invoice and Surcharge Overlook is selected with Fixed Assets
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceFAWithFCYAndSurchargeOverlook()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354838] Check if the program is calculating TCS using Sales Order with concessional codes with Fixed Assets.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAAndConcessionalCode()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354839] Check if the program is calculating TCS using Sales Invoice with concessional codes with Fixed Assets.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAAndConcessionalCode()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354919] Check if the program is calculating TCS on higher rate in case an invoice with Fixed Assets is raised to the Customer which is not having PAN No. using Sales Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAAndWithoutPANNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithoutPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355224] Check if the program is allowing the posting of Invoice with G/L Account using the Credit Memo with TCS information where Accounting Period has not been specified.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoTCSWithoutTaxAccountingPeriod()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Credit Memo
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] Show expected error
        Assert.ExpectedError(IncomeTaxAccountingErr);
    End;

    // [SCENARIO] [355225] Check if the program is allowing the posting of Invoice with G/L Account using the return Order with TCS information where Accounting Period has not been specified.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderTCSWithoutTaxAccountingPeriod()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Return Order
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] Show expected error
        Assert.ExpectedError(IncomeTaxAccountingErr);
    End;


    // [SCENARIO] [354920] Check if the program is calculating TCS on higher rate in case an invoice with Fixed Assets is raised to the Customer which is not having PAN No. using Sales Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAAndWithoutPANNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithoutPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoce
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355143] Check if the program is calculating TCS using Sales Order in case of Invoice Discount with Item
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesOrderWithItemAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        BaseAmount: Decimal;
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateCustomerInvoiceDiscount(Customer."No.");

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        //TCSLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::Item, false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("Allow Invoice Disc.", true);
            SalesLine.Modify(true);
            SalesCalcDiscount.Run(SalesLine);
            SalesLine.Validate("Unit Price");
            BaseAmount := SalesLine."Line Amount";
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, BaseAmount, SalesHeader."Currency Factor", true, false, false);
    End;

    // [SCENARIO] [355144] Check if the program is calculating TCS using Sales Invoice in case of Invoice Discount with Item
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesInvoiceWithItemAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateCustomerInvoiceDiscount(Customer."No.");

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("Allow Invoice Disc.", true);
            SalesLine.Modify(true);
            SalesCalcDiscount.Run(SalesLine);
            SalesLine.Validate("Unit Price");
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355149] Check if the program is calculating TCS using Sales Order in case of Invoice Discount with G/L Account
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesOrderWithGLAccAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        CreateCustomerInvoiceDiscount(Customer."No.");
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("Allow Invoice Disc.", true);
            SalesLine.Modify(true);
            SalesCalcDiscount.Run(SalesLine);
            SalesLine.Validate("Unit Price");
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355150] Check if the program is calculating TCS using Sales Invoice in case of Invoice Discount with G/L Account
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesInvoiceWithGLAccAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateCustomerInvoiceDiscount(Customer."No.");

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("Allow Invoice Disc.", true);
            SalesLine.Modify(true);
            SalesCalcDiscount.Run(SalesLine);
            SalesLine.Validate("Unit Price");
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355212] Check if the program is calculating TCS using Credit Memo  in case of Invoice Discount
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesCrMemoWithItemAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateCustomerInvoiceDiscount(Customer."No.");

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("Allow Invoice Disc.", true);
            SalesLine.Modify(true);
            SalesCalcDiscount.Run(SalesLine);
            SalesLine.Validate("Unit Price");
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355213] Check if the program is calculating TCS using Return Order  in case of Invoice Discount
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesReturnOrderWithItemAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        CreateCustomerInvoiceDiscount(Customer."No.");
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("Allow Invoice Disc.", true);
            SalesLine.Modify(true);
            SalesCalcDiscount.Run(SalesLine);
            SalesLine.Validate("Unit Price");
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 4);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
    End;

    // [SCENARIO] [355146] Check if the program is calculating TCS using Sales Order in case of Invoice Discount with Charge Items
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesOrderWithChargeItemAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateCustomerInvoiceDiscount(Customer."No.");

        // [WHEN] Create and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        SalesLine.Validate("Allow Invoice Disc.", true);
        SalesLine.Modify(true);
        SalesCalcDiscount.Run(SalesLine);
        SalesLine.Validate("Unit Price");
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Check TCS Amount Show expected error
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));
    End;

    // [SCENARIO] [355145] Check if the program is calculating TCS using Sales Invoice in case of Invoice Discount with Charge Items
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesStatisticsPageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateCustomerInvoiceDiscount(Customer."No.");

        // [WHEN] Create and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        SalesLine.Validate("Allow Invoice Disc.", true);
        SalesLine.Modify(true);
        SalesCalcDiscount.Run(SalesLine);
        SalesLine.Validate("Unit Price");
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Show expected error   
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));
    End;

    // [SCENARIO] [355220] Check if the program is calculating TCS using Credit Memo in case of Charge Items
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoWithMultipleChargeItemLine()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSNatureOfCollection2: Record "TCS Nature Of Collection";
        TCSPostingSetup: Record "TCS Posting Setup";
        TCSPostingSetup2: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        ItemNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup2, TCSNatureOfCollection2);
        TCSLibrary.AttachNOCWithCustomer(TCSNatureOfCollection2.Code, Customer."No.", false, false, false);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup2."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Charge (Item)",
            true);

        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        SalesLine.Validate("TCS Nature of Collection", TCSNatureOfCollection2.Code);
        SalesLine.Validate("Unit Price");
        SalesLine.Modify(true);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then
            ItemNo := SalesLine."No.";
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Show expected error
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, ItemNo));
    end;

    // [SCENARIO] [355221] Check if the program is calculating TCS using Return Order in case of Charge Items
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderWithMultipleChargeItemLine()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSNatureOfCollection2: Record "TCS Nature Of Collection";
        TCSPostingSetup: Record "TCS Posting Setup";
        TCSPostingSetup2: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        ItemNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup2, TCSNatureOfCollection2);
        TCSLibrary.AttachNOCWithCustomer(TCSNatureOfCollection2.Code, Customer."No.", false, false, false);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup2."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Charge (Item)",
            true);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        SalesLine.Validate("TCS Nature of Collection", TCSNatureOfCollection2.Code);
        SalesLine.validate("Unit Price");
        SalesLine.Modify(true);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then
            ItemNo := SalesLine."No.";
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Show expected error
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, ItemNo));
    end;

    // [SCENARIO] [354792] Check if the program is calculating TCS using Sales Order in case of different rates for same NOC with different effective dates with G/L Account.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLForDifferentTCSNocEffectiveDate()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        BaseAmount: Decimal;
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, CalcDate('<1D>', WorkDate()));
        TCSLibrary.CreateTCSPostingSetupWithDifferentEffectiveDate(TCSPostingSetup."TCS Nature of Collection", CalcDate('<1D>', WorkDate()), TCSPostingSetup."TCS Account No.");

        // [WHEN] Create and Post Sales Order with Tax Rate Setup with different posting date
        TCSSalesLibrary.CreateSalesDocument(SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            CalcDate('<1D>', WorkDate()),
            SalesLine.Type::"G/L Account",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        BaseAmount := SalesLine."Line Amount";
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, TCSLibrary.RoundTCSAmount(BaseAmount), SalesHeader."Currency Factor", true, true, true);
    End;

    // [SCENARIO] [354793] Check if the program is calculating TCS using Sales Invoice in case of different rates for same NOC with different effective dates with G/L Account.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLForDifferentTCSNocEffectiveDate()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        BaseAmount: Decimal;
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, CalcDate('<1D>', WorkDate()));
        TCSLibrary.CreateTCSPostingSetupWithDifferentEffectiveDate(TCSPostingSetup."TCS Nature of Collection", CalcDate('<1D>', WorkDate()), TCSPostingSetup."TCS Account No.");

        // [WHEN] Create and Post Sales Order with Tax Rate Setup with different posting date
        TCSSalesLibrary.CreateSalesDocument(SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            CalcDate('<1D>', WorkDate()),
            SalesLine.Type::"G/L Account",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        BaseAmount := SalesLine."Line Amount";
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, TCSLibrary.RoundTCSAmount(BaseAmount), SalesHeader."Currency Factor", true, true, true);
    End;

    // [SCENARIO] [354822] Check if the program is calculating TCS using Sales Order in case of different rates for same NOC with different effective dates with Item.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemForDifferentTCSNocEffectiveDate()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        BaseAmount: Decimal;
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, CalcDate('<1D>', WorkDate()));
        TCSLibrary.CreateTCSPostingSetupWithDifferentEffectiveDate(TCSPostingSetup."TCS Nature of Collection", CalcDate('<1D>', WorkDate()), TCSPostingSetup."TCS Account No.");

        // [WHEN] Create and Post Sales Order with Tax Rate Setup with different posting date
        TCSSalesLibrary.CreateSalesDocument(SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            CalcDate('<1D>', WorkDate()),
            SalesLine.Type::Item,
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        BaseAmount := SalesLine."Line Amount";
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, TCSLibrary.RoundTCSAmount(BaseAmount), SalesHeader."Currency Factor", true, true, true);
    End;

    // [SCENARIO] [354823] Check if the program is calculating TCS using Sales Invoice in case of different rates for same NOC with different effective dates with Item.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemForDifferentTCSNocEffectiveDate()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        BaseAmount: Decimal;
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, CalcDate('<1D>', WorkDate()));
        TCSLibrary.CreateTCSPostingSetupWithDifferentEffectiveDate(TCSPostingSetup."TCS Nature of Collection", CalcDate('<1D>', WorkDate()), TCSPostingSetup."TCS Account No.");

        // [WHEN] Create and Post Sales Order with Tax Rate Setup with different posting date
        TCSSalesLibrary.CreateSalesDocument(SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            CalcDate('<1D>', WorkDate()),
            SalesLine.Type::Item,
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        BaseAmount := SalesLine."Line Amount";
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, TCSLibrary.RoundTCSAmount(BaseAmount), SalesHeader."Currency Factor", true, true, true);
    End;

    // [SCENARIO] [354840] Check if the program is calculating TCS using Sales Order in case of different rates for same NOC with different effective dates with Fixed Assets.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAForDifferentTCSNocEffectiveDate()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, CalcDate('<1D>', WorkDate()));
        TCSLibrary.CreateTCSPostingSetupWithDifferentEffectiveDate(TCSPostingSetup."TCS Nature of Collection", CalcDate('<1D>', WorkDate()), TCSPostingSetup."TCS Account No.");

        // [WHEN] Create and Post Sales Order with Tax Rate Setup with different posting date
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            CalcDate('<1D>', WorkDate()),
           SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354841] Check if the program is calculating TCS using Sales Invoice in case of different rates for same NOC with different effective dates with Fixed Assets.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAForDifferentTCSNocEffectiveDate()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, CalcDate('<1D>', WorkDate()));
        TCSLibrary.CreateTCSPostingSetupWithDifferentEffectiveDate(TCSPostingSetup."TCS Nature of Collection", CalcDate('<1D>', WorkDate()), TCSPostingSetup."TCS Account No.");

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            CalcDate('<1D>', WorkDate()),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355244] Check if the program is calculating TCS using Credit Memo in case of different rates for same NOC with different effective dates with G/L Account.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoWithItemForDifferentTCSNocEffectiveDate()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        BaseAmount: Decimal;
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, CalcDate('<1D>', WorkDate()));
        TCSLibrary.CreateTCSPostingSetupWithDifferentEffectiveDate(TCSPostingSetup."TCS Nature of Collection", CalcDate('<1D>', WorkDate()), TCSPostingSetup."TCS Account No.");

        // [WHEN] Create and Post Sales Credit Memo
        TCSSalesLibrary.CreateSalesDocument(SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            CalcDate('<1D>', WorkDate()),
            SalesLine.Type::"G/L Account",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        BaseAmount := SalesLine."Line Amount";
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, TCSLibrary.RoundTCSAmount(BaseAmount), SalesHeader."Currency Factor", true, true, true);
    End;

    // [SCENARIO] [355245] Check if the program is calculating TCS using Return Order in case of different rates for same NOC with different effective dates with G/L Account.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderWithItemForDifferentTCSNocEffectiveDate()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        BaseAmount: Decimal;
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, CalcDate('<1D>', WorkDate()));
        TCSLibrary.CreateTCSPostingSetupWithDifferentEffectiveDate(TCSPostingSetup."TCS Nature of Collection", CalcDate('<1D>', WorkDate()), TCSPostingSetup."TCS Account No.");

        // [WHEN] Create and Post Sales Return Order
        TCSSalesLibrary.CreateSalesDocument(SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            CalcDate('<1D>', WorkDate()),
            SalesLine.Type::"G/L Account",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        BaseAmount := SalesLine."Line Amount";
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, TCSLibrary.RoundTCSAmount(BaseAmount), SalesHeader."Currency Factor", true, true, true);
    End;

    // [SCENARIO] [354828] Check if the program is calculating TCS with threshold and surcharge overlook for NOC lines of a particular customer with Fixed Assets.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAForThreshholdOverlookAndDifferentCustomer()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354929] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice with Fixed Assets is raised to the Customer is having a certificate using Sales Order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAWithoutPANNoWithConcessionalCode()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithoutPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order  for Fixed Asset
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354930] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice with Fixed Assets is raised to the Customer is having a certificate using Sales Invoice
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAWithoutPANNoWithConcessionalCode()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Check if the program is calculating TCS on higher rate in case an invoice with Fixed Assets is raised to the Customer which is not having PAN No. using Sales Invoice.
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithoutPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoce for Fixed Asset
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354931] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice with Resources is raised to the Customer is having a certificate using Sales Order

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceWithoutPANNoWithConcessionalCode()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithoutPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order  for Resource
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354921] Check if the program is calculating TCS on higher rate in case an invoice with Resources is raised to the Customer which is not having PAN No. using Sales Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceWithoutPANNoWithConcessionalCode()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithoutPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoce for Resource
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [932] Check if the program is calculating TCS on higher rate in case an invoice with Resources is raised to the Customer which is not having PAN No. using Sales Invoice.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceAndWithoutPANNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithoutPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354922] Check if the program is calculating TCS on higher rate in case an invoice with Resources is raised to the Customer which is not having PAN No. using Sales Order.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceAndWithoutPANNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithoutPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354898] Check if the program is calculating TCS using Sales Invoice with Resources in case of Foreign Currency.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceAndFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithoutPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354899] Check if the program is calculating TCS using Sales Order with Resources in case of Foreign Currency.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceAndFCY()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
           SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355116] Check if the program is calculating TCS using Sales Order with Fixed Assets where TCS is applicable only on selected lines.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithMultiLineFAAndSingleNoc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("TCS Nature of Collection", '');
            SalesLine.validate("Unit Price");
            SalesLine.Modify(true);
        end;
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Fixed Asset", false);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355117] Check if the program is calculating TCS using Sales Invoice with Fixed Assets where TCS is applicable only on selected lines.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithMultiLineFAAndSingleNoc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("TCS Nature of Collection", '');
            SalesLine.validate("Unit Price");
            SalesLine.Modify(true);
        end;
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Fixed Asset", false);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355118] Check if the program is calculating TCS using Sales Invoice with Resources where TCS is applicable only on selected lines.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithMultiLineResourceAndSingleNoc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("TCS Nature of Collection", '');
            SalesLine.validate("Unit Price");
            SalesLine.Modify(true);
        end;
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::Resource, false);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355119] Check if the program is calculating TCS using Sales Order with Resources where TCS is applicable only on selected lines.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithMultiLineResourceAndSingleNoc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("TCS Nature of Collection", '');
            SalesLine.validate("Unit Price");
            SalesLine.Modify(true);
        end;
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::Resource, false);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354855/354869] Check if the program is calculating TCS in Sales Order with no threshold and surcharge overlook for NOD lines of a particular Customer with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceWithoutThresholdSurcharge()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354856] Check if the program is calculating TCS in Sales Invoice with no threshold and surcharge overlook for NOD lines of a particular Customer with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceWithoutThresholdSurcharge()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354859] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Order and Threshold Overlook is selected with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceWithThresholdSurcharge()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354860] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Invoice and Threshold Overlook is selected with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceWithThresholdSurcharge()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354878] Check if the program is calculating TCS with threshold and surcharge overlook for NOC lines of a particular customer with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceForThreshholdOverlookAndDifferentCustomer()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(), SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354879] Check if the program is calculating TCS with threshold and surcharge overlook for NOC lines of a particular customer with Charge Items.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemForThreshholdOverlookAndDifferentCustomer()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Show expected error    
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));
    End;

    // [SCENARIO] [355202] Check if the program is calculating TCS while creating Invoice with Fixed Assets using the Sales Order with multiple NOC.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAAndMultipleNOC()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSNatureOfCollection2: Record "TCS Nature Of Collection";
        TCSPostingSetup: Record "TCS Posting Setup";
        TCSPostingSetup2: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup2, TCSNatureOfCollection2);
        TCSLibrary.AttachNOCWithCustomer(TCSNatureOfCollection2.Code, Customer."No.", false, false, false);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup2."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("TCS Nature of Collection", TCSNatureOfCollection2.Code);
            SalesLine.validate("Unit Price");
            SalesLine.Modify(true);
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355203] Check if the program is calculating TCS while creating Invoice with Fixed Assets using the Sales Invoice  with multiple NOC.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAAndMultipleNOC()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSNatureOfCollection2: Record "TCS Nature Of Collection";
        TCSPostingSetup: Record "TCS Posting Setup";
        TCSPostingSetup2: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup2, TCSNatureOfCollection2);
        TCSLibrary.AttachNOCWithCustomer(TCSNatureOfCollection2.Code, Customer."No.", false, false, false);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup2."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("TCS Nature of Collection", TCSNatureOfCollection2.Code);
            SalesLine.validate("Unit Price");
            SalesLine.Modify(true);
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355110] Check if the program is calculating TCS using Sales Order/Invoice with Fixed Assets in case of shipment only.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure PostFromSalesOrderTCSVerifyAndFAShipment()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L verified
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 0);
        TCSLibrary.VerifyTCSEntryCount(DocumentNo, false, 0, 0);
    end;


    // [SCENARIO] [354848] Check if the program is calculating TCS using Sales Order in case of different rates for same NOC with different effective dates with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceForDifferentTCSNocEffectiveDate()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, CalcDate('<1D>', WorkDate()));

        // [WHEN] Create and Post Sales Order with Tax Rate Setup with different posting date
        TCSLibrary.CreateTCSPostingSetupWithDifferentEffectiveDate(TCSPostingSetup."TCS Nature of Collection", CalcDate('<1D>', WorkDate()), TCSPostingSetup."TCS Account No.");
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            CalcDate('<1D>', WorkDate()),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [354849] Check if the program is calculating TCS using Sales Invoice in case of different rates for same NOC with different effective dates with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceForDifferentTCSNocEffectiveDate()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, CalcDate('<1D>', WorkDate()));

        // [WHEN] Create and Post Sales Order with Tax Rate Setup with different posting date
        TCSLibrary.CreateTCSPostingSetupWithDifferentEffectiveDate(TCSPostingSetup."TCS Nature of Collection", CalcDate('<1D>', WorkDate()), TCSPostingSetup."TCS Account No.");
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            CalcDate('<1D>', WorkDate()),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355139] Check if the program is calculating TCS using Sales Order in case of Line Discount with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceAndLineDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Order with resource and line discount
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355140] Check if the program is calculating TCS using Sales Invoice in case of Line Discount with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceAndLineDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Order with resource and line discount
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355147/355154] Check if the program is calculating TCS using Sales Order in case of Invoice Discount with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesOrderWithResourceAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        CreateCustomerInvoiceDiscount(Customer."No.");
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("Allow Invoice Disc.", true);
            SalesLine.Modify(true);
            SalesCalcDiscount.Run(SalesLine);
            SalesLine.Validate("Unit Price");
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355148/355153] Check if the program is calculating TCS using Sales Invoice in case of Invoice Discount with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesInvoiceWithResourceAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        CreateCustomerInvoiceDiscount(Customer."No.");
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("Allow Invoice Disc.", true);
            SalesLine.Modify(true);
            SalesCalcDiscount.Run(SalesLine);
            SalesLine.Validate("Unit Price");
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355151] Check if the program is calculating TCS using Sales Order in case of Invoice Discount with Fixed Assets
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesOrderWithFAAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        CreateCustomerInvoiceDiscount(Customer."No.");
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("Allow Invoice Disc.", true);
            SalesLine.Modify(true);
            SalesCalcDiscount.Run(SalesLine);
            SalesLine.Validate("Unit Price");
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355152] Check if the program is calculating TCS using Sales Invoice in case of Invoice Discount with Fixed Assets
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerInvoiceDiscountPageHandler')]
    procedure PostFromSalesInvoiceWithFAAndInvoiceDiscount()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        CreateCustomerInvoiceDiscount(Customer."No.");
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("Allow Invoice Disc.", true);
            SalesLine.Modify(true);
            SalesCalcDiscount.Run(SalesLine);
            SalesLine.Validate("Unit Price");
        end;
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355204] Check if the program is calculating TCS while creating Invoice with Resources using the Sales Order with multiple NOC
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourcesAndMultipleNOC()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSNatureOfCollection2: Record "TCS Nature Of Collection";
        TCSPostingSetup: Record "TCS Posting Setup";
        TCSPostingSetup2: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup2, TCSNatureOfCollection2);
        TCSLibrary.AttachNOCWithCustomer(TCSNatureOfCollection2.Code, Customer."No.", false, false, false);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup2."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            true);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::Resource, false);
        SalesLine.Validate("TCS Nature of Collection", TCSNatureOfCollection2.Code);
        SalesLine.Validate("Unit Price");
        SalesLine.Modify(true);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    // [SCENARIO] [355205] Check if the program is calculating TCS while creating Invoice with Resources using the Sales Invoice with multiple NOC
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSaleslInvoiceWithResourcesAndMultipleNOC()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSNatureOfCollection2: Record "TCS Nature Of Collection";
        TCSPostingSetup: Record "TCS Posting Setup";
        TCSPostingSetup2: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup2, TCSNatureOfCollection2);
        TCSLibrary.AttachNOCWithCustomer(TCSNatureOfCollection2.Code, Customer."No.", false, false, false);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TCSPostingSetup2."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            true);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::Resource, false);
        SalesLine.Validate("TCS Nature of Collection", TCSNatureOfCollection2.Code);
        SalesLine.Validate("Unit Price");
        SalesLine.Modify(true);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified    
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 3);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    // [SCENARIO] [354795] Check if the program is calculating TCS using Sales Order in case of different rates for same NOC with different assessee codes with G/L Account.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAndDifferentAssesseeCode()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseeCode: Record "Assessee Code";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with first Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for first Assessee Code
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        //Create Tax rate with second Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for second Assessee Code
        DocumentNo2 := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer2."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] Verified TCS entries for different Assessee Codes
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo, AssesseeCode.Code);
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo2, AssesseeCode2.Code);
    end;

    // [SCENARIO] [354799] Check if the program is calculating TCS using Sales Invoice in case of different rates for same NOC with different assessee codes with G/L Account.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLAndDifferentAssesseeCode()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseeCode: Record "Assessee Code";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with first Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice for first Assessee Code
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        //Create Tax rate with second Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice for second Assessee Code
        DocumentNo2 := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer2."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] Verified TCS entries for different Assessee Codes
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo, AssesseeCode.Code);
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo2, AssesseeCode2.Code);
    end;

    // [SCENARIO] [354824] Check if the program is calculating TCS using Sales Order in case of different rates for same NOC with different assessee codes with Item.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemAndDifferentAssesseeCode()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCode: Record "Assessee Code";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with first Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for first Assessee Code
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        //Create Tax rate with second Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for second Assessee Code
        DocumentNo2 := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer2."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] Verified TCS entries for different Assessee Codes
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo, AssesseeCode.Code);
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo2, AssesseeCode2.Code);
    end;

    // [SCENARIO] [354825] Check if the program is calculating TCS using Sales Invoice in case of different rates for same NOC with different assessee codes with Item.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemAndDifferentAssesseeCode()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCode: Record "Assessee Code";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with first Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice for first Assessee Code
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        //Create Tax rate with second Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice for second Assessee Code
        DocumentNo2 := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer2."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] Verified TCS entries for different Assessee Codes
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo, AssesseeCode.Code);
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo2, AssesseeCode2.Code);
    end;

    // [SCENARIO] [354842] Check if the program is calculating TCS using Sales Invoice in case of different rates for same NOC with different assessee codes with Fixed Assets.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAAndDifferentAssesseeCode()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCode: Record "Assessee Code";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with first Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice for first Assessee Code
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        //Create Tax rate with second Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice for second Assessee Code
        DocumentNo2 := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer2."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] Verified TCS entries for different Assessee Codes
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo, AssesseeCode.Code);
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo2, AssesseeCode2.Code);
    end;

    // [SCENARIO] [354843] Check if the program is calculating TCS using Sales Order in case of different rates for same NOC with different assessee codes with Fixed Assets.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAAndDifferentAssesseeCode()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCode: Record "Assessee Code";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with first Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for first Assessee Code
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        //Create Tax rate with second Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for second Assessee Code
        DocumentNo2 := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer2."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] Verified TCS entries for different Assessee Codes
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo, AssesseeCode.Code);
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo2, AssesseeCode2.Code);
    end;

    // [SCENARIO] [354846] Check if the program is calculating TCS using Sales Order in case of different rates for same NOC with different assessee codes with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceAndDifferentAssesseeCode()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCode: Record "Assessee Code";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with first Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for first Assessee Code
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        //Create Tax rate with second Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for second Assessee Code
        DocumentNo2 := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer2."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] Verified TCS entries for different Assessee Codes
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo, AssesseeCode.Code);
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo2, AssesseeCode2.Code);
    end;

    // [SCENARIO] [354847] Check if the program is calculating TCS using Sales Invoice in case of different rates for same NOC with different assessee codes with Fixed Assets.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceAndDifferentAssesseeCode()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCode: Record "Assessee Code";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with first Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice for first Assessee Code
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        //Create Tax rate with second Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice for second Assessee Code
        DocumentNo2 := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer2."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] Verified TCS entries for different Assessee Codes
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo, AssesseeCode.Code);
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo2, AssesseeCode2.Code);
    end;

    // [SCENARIO] [354882] Check if the program is calculating TCS using Sales Order in case of different rates for same NOC with different assessee codes with Charge Items.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure PostFromSalesOrderWithChargeItemAndDifferentAssesseeCode()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCode: Record "Assessee Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with first Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice for first Assessee Code
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Show expected error
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));

        //Create Tax rate with second Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice for second Assessee Code
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer2."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Show expected error
        Assert.ExpectedError(StrSubstNo(ItemChargePostingErr, SalesLine."No."));
    end;

    // [SCENARIO] [355111] Check if the program is calculating TCS using Sales Order with Resources in case of shipment only.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure PostFromSalesOrderTCSVerifyAndResourceShipment()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L verified
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 0);
        TCSLibrary.VerifyTCSEntryCount(DocumentNo, false, 0, 0);
    end;

    // [SCENARIO] [1126] Check if the program is calculating TCS while creating Invoice with Item using the Sales Order with multiple NOC.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemAndAdditionalCurrency()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for Additional Currency, NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.UpdateGenLedSetupForAddReportingCurrency();
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        TCSLibrary.VerifyGLEntryAdditionalCurrencyAmt('', DocumentNo);
    end;

    // [SCENARIO] [355128] Check if the program is calculating TCS using Credit Memo in case of Fixed Assets
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesStatisticsPageHandler')]
    procedure SalesInvoiceTCSWithFAAndStatsVerify()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Return Order
        TCSSalesLibrary.CreateSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
    End;

    // [SCENARIO] [355129] Check if the program is showing TCS amount should be shown in Statistics while creating Sales Order with Fixed Assets.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure SalesOrderTCSWithFAAndStatsVerify()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for Fixed Asset
        TCSSalesLibrary.CreateSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
    End;

    // [SCENARIO] [355130] Check if the program is showing TCS amount should be shown in Statistics while creating Sales Order/Invoice with Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure SalesOrderTCSWithResourceAndStatsVerify()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for Fixed Asset
        TCSSalesLibrary.CreateSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
    End;

    // [SCENARIO] [355216] Check if the program is calculating TCS using Credit Memo in case of Fixed Assets
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesStatisticsPageHandler')]
    procedure SalesCreditMemoTCSWithFAAndStatsVerify()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Return Order
        TCSSalesLibrary.CreateSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
           SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
    End;

    // [SCENARIO] [355217] Check if the program is calculating TCS using Return Order in case of Fixed Assets
    [Test]
    [HandlerFunctions('TaxRatePageHandler,SalesOrderStatisticsPageHandler')]
    procedure SalesReturnOrderTCSWithFAAndSatsVerify()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Return Order
        TCSSalesLibrary.CreateSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibraryVarStorage.Clear();
        LibraryVarStorage.Enqueue(SalesLine);
        VerifyStatisticsForTCS(SalesHeader);
    End;

    // [SCENARIO] [355218] Check if the program is calculating TCS using Credit Memo in case of Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoTCSWithResource()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Credit Memo
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355218] Check if the program is calculating TCS using return Order in case of Resources.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderTCSWithResource()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        TCSLibrary.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Credit Memo
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSLibrary.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    End;

    // [SCENARIO] [355246] Check if the program is calculating TCS using Credit Memo in case of different rates for same NOC with different assessee codes with G/L Account.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesCrMemoWithGLAndDifferentAssesseeCode()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCode: Record "Assessee Code";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with first Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for first Assessee Code
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        //Create Tax rate with second Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for second Assessee Code
        DocumentNo2 := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer2."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] Verified TCS entries for different Assessee Codes
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo, AssesseeCode.Code);
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo2, AssesseeCode2.Code);
    end;

    // [SCENARIO] [355247] Check if the program is calculating TCS using Return Order in case of different rates for same NOC with different assessee codes with G/L Account.
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesReturnOrderWithGLAndDifferentAssesseeCode()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseeCode2: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCode: Record "Assessee Code";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);

        //Create Tax rate with first Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for first Assessee Code
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        //Create Tax rate with second Assessee Code
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer2);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer2, AssesseeCode2, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer2."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for second Assessee Code
        DocumentNo2 := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer2."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);
        // [THEN] Verified TCS entries for different Assessee Codes
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo, AssesseeCode.Code);
        TCSLibrary.VerifyTCSEntryForAssesseeCode(DocumentNo2, AssesseeCode2.Code);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,TCSNOCHandler')]
    procedure PostFromSalesInvoiceWithTCSNOCSelection()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCode: Record "Assessee Code";
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        TCSLibrary.CreateAccPeriodAndFillCompInfo();
        TCSLibrary.CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);
        Storage.Set(TCSNOCTypeLbl, TCSNatureOfCollection.Code);
        TCSLibrary.CreateNOCWithCustomer(TCSPostingSetup."TCS Nature of Collection", Customer);
        TCSLibrary.UpdateCustomerAssesseeAndConcessionalCode(Customer, AssesseeCode, ConcessionalCode, TCSPostingSetup."TCS Nature of Collection");
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Order for first Assessee Code
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);
        UpdateTCSNOCSection(SalesHeader);

        // [THEN] Verified TDS Section selected on Purchase line
        Assert.AreEqual(TCSNatureOfCollection.Code, TCSPostingSetup."TCS Nature of Collection",
            StrSubstNo(VerifyErr, SalesLine.FieldCaption("TCS Nature of Collection"), SalesLine.TableCaption));
    end;

    local procedure UpdateTCSNOCSection(SalesHeader: Record "Sales Header")
    var
        SalesInvoice: TestPage "Sales Invoice";
    begin
        SalesInvoice.OpenEdit();
        SalesInvoice.Filter.SetFilter("No.", SalesHeader."No.");
        SalesInvoice.SalesLines."TCS Nature of Collection".Lookup();
    end;

    local procedure CreateCustomerInvoiceDiscount(CustomerNo: Code[20])
    var
        PageCustomer: TestPage "Customer Card";
    begin
        PageCustomer.OpenEdit();
        PageCustomer.Filter.SetFilter("No.", CustomerNo);
        PageCustomer."Invoice &Discounts".Invoke();
    end;

    local procedure VerifyTCSEntry(DocumentNo: Code[20]; TCSBaseAmount: Decimal; CurrencyFactor: Decimal;
             WithPAN: Boolean; SurchargeOverlook: Boolean; TCSThresholdOverlook: Boolean)
    var
        TCSEntry: Record "TCS Entry";
        ExpectedTCSAmount: Decimal;
        ExpectedSurchargeAmount: Decimal;
        ExpectedEcessAmount: Decimal;
        ExpectedSHEcessAmount: Decimal;
        TCSPercentage: Decimal;
        NonPANTCSPercentage: Decimal;
        SurchargePercentage: Decimal;
        eCessPercentage: Decimal;
        SHECessPercentage: Decimal;
        TCSThresholdAmount: Decimal;
        SurchargeThresholdAmount: Decimal;
        AmountErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = TCS Amount and TCS field Caption';
    begin
        Evaluate(TCSPercentage, Storage.Get(TCSPercentageLbl));
        Evaluate(NonPANTCSPercentage, Storage.Get(NonPANTCSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TCSThresholdAmount, Storage.Get(TCSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        if CurrencyFactor = 0 then
            CurrencyFactor := 1;
        if (TCSBaseAmount < TCSThresholdAmount) and (TCSThresholdOverlook = false) then
            ExpectedTCSAmount := 0
        else
            if WithPAN then
                ExpectedTCSAmount := TCSBaseAmount * TCSPercentage / 100 / CurrencyFactor
            else
                ExpectedTCSAmount := TCSBaseAmount * NonPANTCSPercentage / 100 / CurrencyFactor;

        if (TCSBaseAmount < SurchargeThresholdAmount) and (SurchargeOverlook = false) then
            ExpectedSurchargeAmount := 0
        else
            ExpectedSurchargeAmount := ExpectedTCSAmount * SurchargePercentage / 100;
        ExpectedEcessAmount := (ExpectedTCSAmount + ExpectedSurchargeAmount) * eCessPercentage / 100;
        ExpectedSHEcessAmount := (ExpectedTCSAmount + ExpectedSurchargeAmount) * SHECessPercentage / 100;
        TCSEntry.SetRange("Document No.", DocumentNo);
        TCSEntry.FindFirst();
        Assert.AreNearlyEqual(
            TCSBaseAmount / CurrencyFactor, TCSEntry."TCS Base Amount", TCSLibrary.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("TCS Base Amount"), TCSEntry.TableCaption()));
        if WithPAN then
            Assert.AreEqual(
                TCSPercentage, TCSEntry."TCS %",
                StrSubstNo(AmountErr, TCSEntry.FieldName("TCS %"), TCSEntry.TableCaption()))
        else
            Assert.AreEqual(
                NonPANTCSPercentage, TCSEntry."TCS %",
                StrSubstNo(AmountErr, TCSEntry.FieldName("TCS %"), TCSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedTCSAmount, TCSEntry."TCS Amount", TCSLibrary.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("TCS Amount"), TCSEntry.TableCaption()));
        Assert.AreEqual(
            SurchargePercentage, TCSEntry."Surcharge %",
            StrSubstNo(AmountErr, TCSEntry.FieldName("Surcharge %"), TCSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedSurchargeAmount, TCSEntry."Surcharge Amount", TCSLibrary.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("Surcharge Amount"), TCSEntry.TableCaption()));
        Assert.AreEqual(
            eCessPercentage, TCSEntry."eCESS %",
            StrSubstNo(AmountErr, TCSEntry.FieldName("eCESS %"), TCSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedEcessAmount, TCSEntry."eCESS Amount", TCSLibrary.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("eCESS Amount"), TCSEntry.TableCaption()));
        Assert.AreEqual(
            SHECessPercentage, TCSEntry."SHE Cess %",
            StrSubstNo(AmountErr, TCSEntry.FieldName("SHE Cess %"), TCSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedSHEcessAmount, TCSEntry."SHE Cess Amount", TCSLibrary.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("SHE Cess Amount"), TCSEntry.TableCaption()));
    end;

    local procedure VerifyGLEntryWithTCS(DocumentNo: Code[20]; TCSAccountNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        TCSLibrary.FindGLEntry(GLEntry, DocumentNo, TCSAccountNo);
        GLEntry.TestField(Amount, -TCSLibrary.GetTCSAmount(DocumentNo));
    end;

    local procedure CreateTaxRate()
    var
        TCSSetup: Record "TCS Setup";
        PageTaxtype: TestPage "Tax Types";
    begin
        TCSSetup.Get();
        PageTaxtype.OpenEdit();
        PageTaxtype.Filter.SetFilter(Code, TCSSetup."Tax Type");
        PageTaxtype.TaxRates.Invoke();
    end;

    local procedure CreateTaxRateSetup(TCSNOC: Code[10]; AssesseeCode: Code[10]; ConcessionalCode: Code[10]; EffectiveDate: Date)
    begin
        Storage.Set(TCSNOCTypeLbl, TCSNOC);
        Storage.Set(TCSAssesseeCodeLbl, AssesseeCode);
        Storage.Set(TCSConcessionalCodeLbl, ConcessionalCode);
        Storage.Set(EffectiveDateLbl, Format(EffectiveDate, 0, 9));
        GenerateTaxComponentsPercentage();
        CreateTaxRate();
    end;

    local procedure GenerateTaxComponentsPercentage()
    begin
        Storage.Set(TCSPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(NonPANTCSPercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(SurchargePercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(ECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(TCSThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
        Storage.Set(SurchargeThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
    end;

    local procedure CreateAndPostMultiLineSalesDocument(
        var SalesHeader: Record "Sales Header";
        DocumentType: Enum "Sales Document Type";
        CustomerNo: Code[20];
        PostingDate: Date;
        LineType: Enum "Sales Line Type";
        LineDiscount: Boolean): Code[20]
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);

        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, LineType, LineDiscount);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, LineType, LineDiscount);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    [ModalPageHandler]
    procedure TCSNOCHandler(var TCSNatureOfCollections: TestPage "TCS Nature Of Collections")
    begin
        TCSNatureOfCollections.Filter.SetFilter(Code, Storage.Get(TCSNOCTypeLbl));
    end;

    local procedure VerifyStatisticsForTCS(var Salesheader: Record "Sales Header")
    var
        PageSalesOrder: TestPage "Sales Order list";
        PageSalesInvoiceList: TestPage "Sales Invoice List";
        PageSalesCreditMemo: TestPage "Sales Credit Memos";
        PageSalesReturnOrder: TestPage "Sales Return Order List";
    begin
        case Salesheader."Document Type" of
            Salesheader."Document Type"::Order:
                begin
                    PageSalesOrder.OpenView();
                    PageSalesOrder.Filter.SetFilter("No.", Salesheader."No.");
                    PageSalesOrder.Statistics.Invoke();
                end;
            Salesheader."Document Type"::Invoice:
                begin
                    PageSalesInvoiceList.OpenView();
                    PageSalesInvoiceList.Filter.SetFilter("No.", Salesheader."No.");
                    PageSalesInvoiceList.Statistics.Invoke();
                end;
            Salesheader."Document Type"::"Credit Memo":
                begin
                    PageSalesCreditMemo.OpenView();
                    PageSalesCreditMemo.Filter.SetFilter("No.", Salesheader."No.");
                    PageSalesCreditMemo.Statistics.Invoke();
                end;
            Salesheader."Document Type"::"Return Order":
                begin
                    PageSalesReturnOrder.OpenView();
                    PageSalesReturnOrder.Filter.SetFilter("No.", Salesheader."No.");
                    PageSalesReturnOrder.Statistics.Invoke();
                end;
        end;
    End;

    [ModalPageHandler]
    procedure SalesStatisticsPageHandler(var SalesStatistics: TestPage "Sales Statistics")
    var
        SalesLine: Record "Sales Line";
        TCSAmount: Decimal;
        Record: Variant;
    begin
        LibraryVarStorage.Dequeue(Record);
        SalesLine := Record;
        case SalesLine.Type of
            SalesLine.Type::"Fixed Asset", SalesLine.Type::Resource:
                begin
                    TCSAmount := SalesStatistics."TCS Amount".AsDecimal();
                    Assert.Equal(TCSAmount, 0);
                end;
            SalesLine.Type::Item, SalesLine.Type::"G/L Account", SalesLine.Type::"Charge (Item)":
                begin
                    TCSAmount := SalesStatistics."TCS Amount".AsDecimal();
                    Assert.AreNotEqual(TCSAmount, 0, 'TCS Calculated');
                end;
        end;
    end;

    [ModalPageHandler]
    procedure SalesOrderStatisticsPageHandler(var SalesOrderStatistics: TestPage "Sales Order Statistics")
    var
        SalesLine: Record "Sales Line";
        TCSAmount: Decimal;
        Record: Variant;
    begin
        LibraryVarStorage.Dequeue(Record);
        SalesLine := Record;
        case SalesLine.Type of
            SalesLine.Type::"Fixed Asset", SalesLine.Type::Resource:
                begin
                    TCSAmount := SalesOrderStatistics."TCS Amount".AsDecimal();
                    Assert.Equal(TCSAmount, 0);
                end;
            SalesLine.Type::Item, SalesLine.Type::"G/L Account", SalesLine.Type::"Charge (Item)":
                begin
                    TCSAmount := SalesOrderStatistics."TCS Amount".AsDecimal();
                    Assert.AreNotEqual(TCSAmount, 0, 'TCS Calculated');
                end;
        end;
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRate: TestPage "Tax Rates");
    var
        TCSPercentage: Decimal;
        NonPANTCSPercentage: Decimal;
        SurchargePercentage: Decimal;
        eCessPercentage: Decimal;
        SHECessPercentage: Decimal;
        EffectiveDate: Date;
        TCSThresholdAmount: Decimal;
        SurchargeThresholdAmount: Decimal;
    begin
        Evaluate(EffectiveDate, Storage.Get(EffectiveDateLbl), 9);
        Evaluate(TCSPercentage, Storage.Get(TCSPercentageLbl));
        Evaluate(NonPANTCSPercentage, Storage.Get(NonPANTCSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TCSThresholdAmount, Storage.Get(TCSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        TaxRate.New();
        TaxRate.AttributeValue1.SetValue(Storage.Get(TCSNOCTypeLbl));
        TaxRate.AttributeValue2.SetValue(Storage.Get(TCSAssesseeCodeLbl));
        TaxRate.AttributeValue3.SetValue(Storage.Get(TCSConcessionalCodeLbl));
        TaxRate.AttributeValue4.SetValue(EffectiveDate);
        TaxRate.AttributeValue5.SetValue(TCSPercentage);
        TaxRate.AttributeValue6.SetValue(SurchargePercentage);
        TaxRate.AttributeValue7.SetValue(NonPANTCSPercentage);
        TaxRate.AttributeValue8.SetValue(eCessPercentage);
        TaxRate.AttributeValue9.SetValue(SHECessPercentage);
        TaxRate.AttributeValue10.SetValue(TCSThresholdAmount);
        TaxRate.AttributeValue11.SetValue(SurchargeThresholdAmount);
        TaxRate.OK().Invoke();
    end;

    [PageHandler]
    procedure CustomerInvoiceDiscountPageHandler(var CustInvDisc: TestPage "Cust. Invoice Discounts");
    begin
        CustInvDisc."Discount %".SetValue(LibraryRandom.RandIntInRange(1, 4));
        CustInvDisc.OK().Invoke();
    end;

    var
        LibraryVarStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        TCSLibrary: Codeunit "TCS - Library";
        LibrarySales: Codeunit "Library - Sales";
        TCSSalesLibrary: Codeunit "TCS Sales - Library";
        SalesCalcDiscount: Codeunit "Sales-Calc. Discount";
        Assert: Codeunit Assert;
        Storage: Dictionary of [Text, Text];
        EffectiveDateLbl: Label 'EffectiveDate', locked = true;
        TCSNOCTypeLbl: Label 'TCSNOCType', locked = true;
        TCSAssesseeCodeLbl: Label 'TCSAssesseeCode', locked = true;
        TCSConcessionalCodeLbl: Label 'TCSConcessionalCode', locked = true;
        TCSPercentageLbl: Label 'TCSPercentage', locked = true;
        NonPANTCSPercentageLbl: Label 'NonPANTCSPercentage', locked = true;
        SurchargePercentageLbl: Label 'SurchargePercentage', locked = true;
        ECessPercentageLbl: Label 'ECessPercentage', Locked = true;
        SHECessPercentageLbl: Label 'SHECessPercentage', locked = true;
        TCSThresholdAmountLbl: Label 'TCSThresholdAmount', locked = true;
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount', locked = true;
        ItemChargePostingErr: Label 'You must assign item charge %1 if you want to invoice it.', Comment = '%1= No.';
        TCANNoErr: Label 'T.C.A.N. No. must have a value in Gen. Journal Line: Journal Template Name=, Journal Batch Name=, Line No.=0. It cannot be zero or empty.', Locked = true;
        IncomeTaxAccountingErr: Label 'Posting Date doesn''t lie in Tax Accounting Period', Locked = true;
        VerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
}