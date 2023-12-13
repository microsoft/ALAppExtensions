codeunit 18917 "TCS On Sales Documents"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItem()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354569] Check if the program is calculating TCS in case of creating Sales Invoice for the customer with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice with Item
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItem()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354570] Check if the program is calculating TCS in case of creating Sales Order for the customer with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order with Item
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithoutAccountingPeriod()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [354580] Check if the program is allowing the posting of Invoice with Item using the Sales Order with TCS information where Accounting Period has not been specified.
        // [SCENARIO] [355136] Check if the program is allowing the posting of Invoice with Item using the Sales Order with TCS information where Accounting Period has been specified but Quarter for the period is not specified.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());
        // [WHEN] Created and Posted Sales Invoice with item
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()),
            SalesLine.Type::Item,
            false);

        // [THEN] Assert Error Verified.
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemWithoutAccountingPeriod()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [354581] Check if the program is allowing the posting of Invoice with Item using the Sales Invoice with TCS information where Accounting Period has not been specified.
        // [SCENARIO] [354583] Check if the program is allowing the posting of Invoice with Item using the Sales Invoice with TCS information where Accounting Period has been specified but Quarter for the period is not specified.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice with Item
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()),
            SalesLine.Type::Item,
            false);

        // [THEN] Assert Error Verified
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithoutTCAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [354584] Check if the program is allowing the posting of Invoice with Item using the Sales Order with TCS information where  TCAN No. has not been defined.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Item
        LibraryTCS.RemoveTCANOnCompInfo();
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] Assert Error Verified
        Assert.ExpectedError(TCANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemWithoutTCAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [354585] Check if the program is allowing the posting of Invoice with Item using the Sales Invoice with TCS information where  TCAN No. has not been defined.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales Order with Item
        LibraryTCS.RemoveTCANOnCompInfo();
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] Assert Error Verified
        Assert.ExpectedError(TCANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAcc()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354651] Check if the program is calculating TCS in case of creating Sales Order for the customer with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales order with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN]Assert Error Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLAcc()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354652] Check if the program is calculating TCS in case of creating Sales Invoice for the customer with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithoutAccountingPeriod()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [354664] Check if the program is allowing the posting of Invoice with G/L Account using the Sales Order with TCS information where Accounting Period has not been specified.
        // [SCENARIO] [355418] Check if the program is allowing the posting of Invoice with G/L Account using the Sales Order with TCS information where Accounting Period has been specified but Quarter for the period is not specified.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with G/L Account
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN]Assert Error Verified
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLAccWithoutAccountingPeriod()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [354665] Check if the program is allowing the posting of Invoice with G/L Account using the Sales Invoice with TCS information where Accounting Period has not been specified.
        // [SCENARIO] [355419] Check if the program is allowing the posting of Invoice with G/L Account using the Sales Invoice with TCS information where Accounting Period has been specified but Quarter for the period is not specified.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice with G/L Account
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] Assert Error Verified
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithoutTCAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [355420] Check if the program is allowing the posting of Invoice with G/L Account using the Sales Order with TCS information where  TCAN No. has not been defined.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales Order with G/L Account
        LibraryTCS.RemoveTCANOnCompInfo();
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN]Assert Error Verified
        Assert.ExpectedError(TCANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLAccWithoutTCAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [355421] Check if the program is allowing the posting of Invoice with G/L Account using the Sales Invoice with TCS information where  TCAN No. has not been defined.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales Invoice with G/L Account
        LibraryTCS.RemoveTCANOnCompInfo();
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN]Assert Error Verified
        Assert.ExpectedError(TCANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAWithoutTCAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [355422] Check if the program is allowing the posting of Invoice with Fixed Assets using the Sales Invoice with TCS information where  TCAN No. has not been defined.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales Invoice with Fixed Asset.
        LibraryTCS.RemoveTCANOnCompInfo();
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN]Assert Error Verified
        Assert.ExpectedError(TCANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAWithoutTCAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [355423] Check if the program is allowing the posting of Invoice with Fixed Assets using the Sales Order with TCS information where TCAN No. has not been defined.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Fixed Asset
        LibraryTCS.RemoveTCANOnCompInfo();
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN] Expected error: TCAN no. must have a value.
        Assert.ExpectedError(TCANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceWithoutTCAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [355425] Check if the program is allowing the posting of Invoice with Resources using the Sales Invoice with TCS information where TCAN No. has not been defined.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales Invoice with Resource
        LibraryTCS.RemoveTCANOnCompInfo();
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] Expected error: TCAN no. must have a value.
        Assert.ExpectedError(TCANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceWithoutTCAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [355424] Check if the program is allowing the posting of Invoice with Resources using the Sales Order with TCS information where  TCAN No. has not been defined.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales Order with Resource
        LibraryTCS.RemoveTCANOnCompInfo();
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Resource,
            false);

        // [THEN] Expected error: TCAN no. must have a value.
        Assert.ExpectedError(TCANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemWithoutTCAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        SalesDocumentType: Enum "Sales Document Type";
    begin
        // [SCENARIO] [355426] Check if the program is allowing the posting of Invoice with Charge Items using the Sales Order with TCS information where TCAN No. has not been defined.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and Company information without TCAN No.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());
        LibraryTCS.RemoveTCANOnCompInfo();

        // [WHEN] Sales Order with Charge Item created and Posted
        asserterror CreateandPostSalesDocumentWithChargeItem(SalesDocumentType::Order, Customer."No.", WorkDate());

        // [THEN] Expected error: TCAN no. must have a value.
        Assert.ExpectedError(TCANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemWithoutTCAN()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        SalesDocumentType: Enum "Sales Document Type";
    begin
        // [SCENARIO] [355427] Check if the program is allowing the posting of Invoice with Charge Items using the Sales Invoice with TCS information where TCAN No. has not been defined.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and Company information without TCAN No.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());
        LibraryTCS.RemoveTCANOnCompInfo();

        // [WHEN] Sales Invoice with Charge Item created and Posted
        asserterror CreateandPostSalesDocumentWithChargeItem(SalesDocumentType::Invoice, Customer."No.", WorkDate());

        // [THEN]Assert Error Verified
        Assert.ExpectedError(TCANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAWithoutAccountingPeriod()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [354716] Check if the program is allowing the posting of Invoice with Fixed Assets using the Sales Order with TCS information where Accounting Period has not been specified.
        // [SCENARIO] [354718] Check if the program is allowing the posting of Invoice with Fixed Assets using the Sales Order with TCS information where Accounting Period has been specified but Quarter for the period is not specified.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and Company information without TCAN No.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        //Created and Posted Sales Order with Fixed Asset
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()),
            SalesLine.Type::"Fixed Asset",
            false);

        // [THEN]Assert Error Verified
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoicerWithFAWithoutAccountingPeriod()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [354717] Check if the program is allowing the posting of Invoice with Fixed Assets using the Sales Invoice with TCS information where Accounting Period has not been specified.
        // [SCENARIO] [354719] Check if the program is allowing the posting of Invoice with Fixed Assets using the Sales Invoice with TCS information where Accounting Period has been specified but Quarter for the period is not specified.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and Company information without TCAN No.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [THEN]Created and Posted Sales Invoice with Fixed Asset
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()),
            SalesLine.Type::"Fixed Asset",
            false);

        // [WHEN]Assert Error Verified
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemWithoutAccountingPeriod()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        SalesDocumentType: Enum "Sales Document Type";
    begin
        // [SCENARIO] [354720] Check if the program is allowing the posting of Invoice with Charge Items using the Sales Order with TCS information where Accounting Period has not been specified.
        // [SCENARIO] [354722] Check if the program is allowing the posting of Invoice with Charge Items using the Sales Order with TCS information where Accounting Period has been specified but Quarter for the period is not specified.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and Company information without TCAN No.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Sales Order with charge item created and Posted
        asserterror CreateandPostSalesDocumentWithChargeItem(SalesDocumentType::Order, Customer."No.", calcdate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()));

        // [THEN] Expected Error: Posting date not defined
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemWithoutAccountingPeriod()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        SalesDocumentType: Enum "Sales Document Type";
    begin
        // [SCENARIO] [354721] Check if the program is allowing the posting of Invoice with Charge Items using the Sales Invoice with TCS information where Accounting Period has not been specified.
        // [SCENARIO] [354723] Check if the program is allowing the posting of Invoice with Charge Items using the Sales Invoice with TCS information where Accounting Period has been specified but Quarter for the period is not specified.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and Company information without TCAN No.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Sales Order with charge item created and Posted
        asserterror CreateandPostSalesDocumentWithChargeItem(SalesDocumentType::Invoice, Customer."No.", CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()));

        // [THEN] Expected Error: Posting date not defined
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceWithoutAccountingPeriod()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [354724] Check if the program is allowing the posting of Invoice with Resources using the Sales Order with TCS information where Accounting Period has been specified but Quarter for the period is not specified.
        // [SCENARIO] [354726] Check if the program is allowing the posting of Invoice with Resources using the Sales Order with TCS information where Accounting Period has not been specified.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and Company information without TCAN No.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales Order with Resource
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()),
            SalesLine.Type::Resource,
            false);

        // [THEN] Expected Error: Posting date not defined
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceWithoutAccountingPeriod()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [354725] Check if the program is allowing the posting of Invoice with Resources using the Sales Invoice with TCS information where Accounting Period has been specified but Quarter for the period is not specified.
        // [SCENARIO] [354727] Check if the program is allowing the posting of Invoice with Resources using the Sales Invoice with TCS information where Accounting Period has not been specified.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and Company information without TCAN No.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales Invoice with Resource
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            CalcDate('<-1Y>', TCSSalesLibrary.FindStartDateOnAccountingPeriod()),
            SalesLine.Type::Resource,
            false);

        // [THEN] Expected Error: Posting date not defined
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItem()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        SalesDocumentType: Enum "Sales Document Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354728] Check if the program is calculating TCS in case of creating Sales Order for the customer with Charge Items.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Sales order created and Posted
        DocumentNo := CreateandPostSalesDocumentWithChargeItem(SalesDocumentType::Order, Customer."No.", WorkDate());

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 4);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItem()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine1: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354729] Check if the program is calculating TCS in case of creating Sales Invoice for the customer with Charge Items.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Sales Invoice with Charge item created and Posted
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::Item, false);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine1, SalesLine.Type::"Charge (Item)", false);
        TCSSalesLibrary.CreateItemChargeAssignment(
            ItemChargeAssignmentSales, SalesLine1, SalesHeader."Document Type"::Order,
            SalesHeader."No.", SalesLine."Line No.", SalesLine."No.");
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 4);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithSurchargeAndThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354779] Check if the program is calculating TCS using the Sales Order with threshold and surcharge overlook for NOC lines of a particular customer with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales Order with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354780] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Order and Threshold Overlook is selected with G/L Account.
        // [GIVEN] Created Setup for NOC with Threshold overlook, Assessee Code, Customer with PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales Order with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLAccWithThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354781] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Invoice and Threshold Overlook is selected with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN]Created and Posted Sales Invoice with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithoutThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354782] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Order and Threshold Overlook is not selected with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());


        // [WHEN]Created and Posted Sales Order with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLAccWithoutThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354783] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Invoice and Threshold Overlook is not selected with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithoutThresholdandSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354784] Check if the program is calculating TCS in Sales Order with no threshold and surcharge overlook for NOD lines of a particular Customer with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLAccWithoutThresholdandSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354785] Check if the program is calculating TCS in Sales Invoice with no threshold and surcharge overlook for NOD lines of a particular Customer with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, false)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354790] Check if the program is calculating TCS using Sales Order with concessional codes with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Created and Posted Sales Order with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLAccWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354791] Check if the program is calculating TCS using Sales Invoice with concessional codes with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Created and Posted Sales Invoice with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithSurchargeandThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354812] Check if the program is calculating TCS using the Sales Order with threshold and surcharge overlook for NOC lines of a particular customer with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Item
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354813] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Order and Threshold Overlook is selected with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Item
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemWithThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354814] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Invoice and Threshold Overlook is selected with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, false)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithoutThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354815] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Order and Threshold Overlook is not selected with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Item
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, false)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemWithoutThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354816] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Invoice and Threshold Overlook is not selected with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified.
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, false)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithoutThresholdandSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354817] Check if the program is calculating TCS in Sales Order with no threshold and surcharge overlook for NOD lines of a particular Customer with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Item
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemWithoutThresholdandSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354818] Check if the program is calculating TCS in Sales Invoice with no threshold and surcharge overlook for NOD lines of a particular Customer with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, false)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354821] Check if the program is calculating TCS using Sales Order/Invoice with concessional codes with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [THEN] Created and Posted Sales Order with Item
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354821] Check if the program is calculating TCS using Sales Order/Invoice with concessional codes with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Created and Posted Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithoutPANNo()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354915] Check if the program is calculating TCS on higher rate in case an invoice with G/L Account is raised to the Customer which is not having PAN No. using Sales Order
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, false, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLAccWithoutPANNo()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354916] Check if the program is calculating TCS on higher rate in case an invoice with G/L Account is raised to the Customer which is not having PAN No. using Sales Invoice.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/LEntries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, false, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithoutPANNo()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354917] Check if the program is calculating TCS on higher rate in case an invoice with Item is raised to the Customer which is not having PAN No. using Sales Order
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Item
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, false, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemWithoutPANNo()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354918] Check if the program is calculating TCS on higher rate in case an invoice with Item is raised to the Customer which is not having PAN No. using Sales Invoice.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice with Item
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, false, true, true)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithCertificate()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354925] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice with G/L Account is raised to the Customer is having a certificate using Sales Order
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.code, WorkDate());

        // [WHEN] Created and Posted Sales Order with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, false, true, true)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLAccWithCertificate()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354926] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice with G/L Account is raised to the Customer is having a certificate using Sales Invoice
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.code, WorkDate());

        // [WHEN] Created and Posted Sales Invoice with G/L Account
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, false, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithCertificate()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354927] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice with Item is raised to the Customer is having a certificate using Sales Order.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.code, WorkDate());

        // [WHEN] Created and Posted Sales Order with Item
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, false, true, true)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemWithCertificate()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354928] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice with Item is raised to the Customer is having a certificate using Sales Invoice
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithoutPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.code, WorkDate());

        // [WHEN] Created and Posted Sales Invoice with Item
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, false, true, true)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderMultiLineWithItemAndNOCSelected()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355112] Check if the program is calculating TCS using Sales Order with Item where TCS is applicable only on selected lines.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Item
        DocumentNo := CreateAndPostMultiLineSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCSand G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceMultiLineWithItemAndNOCSelected()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355113] Check if the program is calculating TCS using Sales Invoice with Item where TCS is applicable only on selected lines.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales invoice with Item
        DocumentNo := CreateAndPostMultiLineSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceMultiLineWithGLAccAndNOCSelected()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355114] Check if the program is calculating TCS using Sales Invoice with G/L Account where TCS is applicable only on selected lines.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice with G/L Account
        DocumentNo := CreateAndPostMultiLineSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderMultiLineWithGLAccAndNOCSelected()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355115] Check if the program is calculating TCS using Sales Order with G/L Account where TCS is applicable only on selected lines.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with G/L Account
        DocumentNo := CreateAndPostMultiLineSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,StatisticsPageHandler')]
    procedure SalesOrderWithGLAccountVerifyStatistics()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [SCENARIO] [355124] Check if the program is showing TCS amount should be shown in Statistics while creating Sales Order with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created Sales Order with G/L Account
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] Statistics Verified
        VerifyStatisticsForTCS(SalesHeader);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,StatisticsPageHandler')]
    procedure SalesOrderWithItemVerifyStatistics()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [SCENARIO] [355126] Check if the program is showing TCS amount should be shown in Statistics while creating Sales Order with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created Sales Order with Item
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] Statistics Verified
        VerifyStatisticsForTCS(SalesHeader);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,InvoiceStatisticsPageHandler')]
    procedure SalesInvoiceWithGLAccountVerifyStatistics()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [SCENARIO] [355125] Check if the program is showing TCS amount should be shown in Statistics while creating Sales Invoice with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created Sales Invoice with G/L Account
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] Statistics Verified
        VerifyStatisticsForTCSWithInvoice(SalesHeader);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,InvoiceStatisticsPageHandler')]
    procedure SalesInvoiceWithItemVerifyStatistics()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [SCENARIO] [355127] Check if the program is showing TCS amount should be shown in Statistics while creating Sales Invoice with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created Sales Invoice with Item
        TCSSalesLibrary.CreateSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] Statistics Verified
        VerifyStatisticsForTCSWithInvoice(SalesHeader);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderMultiLineWithGLAccAndMultiNOC()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355198] Check if the program is calculating TCS while creating Invoice with G/L Account using the Sales Order with multiple NOC.
        // [GIVEN] Created Setup for Assessee Code, Customer without PAN, TCS Setup and Tax Accounting Period with different Nature of collections
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created Sales Invoice with GL Account
        DocumentNo := CreateAndPostMultiLineSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS and G/L Entries Verified
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithGLAccWithRounding()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354663] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while raising invoice or receiving advance from the customer using Sales Invoice with G/L Account
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer and TCS Setup without Threshold and Surcharge Overlook.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithRounding()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354661] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while raising invoice or receiving advance from the customer using Sales Order with G/L Account
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer and TCS Setup without Threshold and Surcharge Overlook.
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::"G/L Account",
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithPartialShipment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [Scneraio [354575] Check if the program is calculating TCS in case of creating Sales Order for partial shipments with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer and TCS Setup 
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with partial Shipment
        DocumentNo := CreateAndPostSalesDocumentWithPartialShipment(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLine.Type::Item,
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 0);
        VerifyTCSEntryCount(DocumentNo, 0)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithPartialInvoice()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [Scneraio [354577] Check if the program is calculating TCS  in case of creating Sales Order for partial invoicing with Item.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer and TCS Setup 
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Partial Invoicing
        DocumentNo := CreateAndPostSalesDocumentWithPartialInvoicing(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::Item,
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyTCSEntryCount(DocumentNo, 1);
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithRounding()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [Scenairo [354578] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while raising invoice or receiving advance from the customer using Sales Order with Item
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::Item,
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithItemWithRounding()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [Scenairo [354579] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while raising invoice or receiving advance from the customer using Sales Invoice with Item
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::Item,
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithPartialShipment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [Scneraio [354657] Check if the program is calculating TCS in case of creating Sales Order for partial shipments with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Tax Accounting period 
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with partial Shipment
        DocumentNo := CreateAndPostSalesDocumentWithPartialShipment(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"G/L Account",
            false);

        // [THEN] No TCS and GL Entry has been created
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 0);
        VerifyTCSEntryCount(DocumentNo, 0);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithGLAccWithPartialInvoice()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [Scneraio [354659] Check if the program is calculating TCS  in case of creating Sales Order for partial invoicing with G/L Account.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Partial Invoicing
        DocumentNo := CreateAndPostSalesDocumentWithPartialInvoicing(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"G/L Account",
            false);

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        VerifyTCSEntryCount(DocumentNo, 1);
        VerifyTCSEntry(DocumentNo, true, true, true)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemWithPartialShipment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [Scneraio [354733] Check if the program is calculating TCS in case of creating Sales Order/Invoice for partial shipments with Charge Items.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Tax Accounting period 
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with partial Shipment
        DocumentNo := CreateAndPostSalesDocumentWithPartialShipment(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Charge (Item)",
            false);

        // [THEN] No TCS and GL Entry has been created
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 0);
        VerifyTCSEntryCount(DocumentNo, 0)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemWithPartialInvoice()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
    begin
        // [Scneraio [354734] Check if the program is calculating TCS  in case of creating Sales Order for partial invoicing with Charge Items.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Partial Invoicing
        DocumentNo := CreateandPostSalesDocumentWithChargeItemWithPartialInvoice(
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate());

        // [THEN] TCS Entry has been created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 4);
        VerifyTCSEntryCount(DocumentNo, 1);
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithItemWithShipmentOnly()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [Scneraio [354738] Check if the program is calculating TCS using Sales Order with Item in case of shipment only
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Tax Accounting period 
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Shipment
        DocumentNo := CreateAndPostSalesDocumentWithShipmentOnly(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::Item,
            false);

        // [THEN] No TCS and GL Entry has been created
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 0);
        VerifyTCSEntryCount(DocumentNo, 0)
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithoutCompanyPANNo()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
    begin
        // [Scenairo [354663] Check if the program is allowing the posting of Invoice using the General Journal/Sales Journal/Sales Invoice/Sales Order with TDS information where deductee PAN is not specified.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and PAN No. removed on Company information
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());
        RemovePANNoOnCompInfo();

        // [WHEN] Created and Posted Sales Order
        asserterror TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::Item,
            false);

        // [THEN] Expected Error : PAN No. is not defined
        Assert.ExpectedError(CompanyInfoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemWithoutAssigning()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354705] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while raising invoice or receiving advance from the customer using Sales Order with Charge Items
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemWithoutAssigning()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354706] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while raising invoice or receiving advance from the customer using Sales Invoice with Charge Items
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemWithoutAssigningWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354864] Check if the program is calculating TCS using Sales Order with concessional codes with Charge Items.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer with Concessional Code, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemWithoutAssigningWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354865] Check if the program is calculating TCS using Sales Invoice with concessional codes with Charge Items.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer with Concessional Code, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemWithSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354867] Check if the program is calculating TCS in case an invoice is raised to the foreign Customer using Sales Order and Surcharge Overlook is selected with Charge Items
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Order with Currency
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Currency Code", CreateCurrencyCode());
        SalesHeader.Modify(true);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemWithSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354868] Check if the program is calculating TCS in case an invoice is raised to the foreign Customer using Sales Invoice and Surcharge Overlook is selected with Charge Items
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Sales Invoice with Currency
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader.Validate("Currency Code", CreateCurrencyCode());
        SalesHeader.Modify(true);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemWithThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354870] Check if the program is calculating TCS in Sales Invoice with no threshold and surcharge overlook for NOD lines of a particular Customer with Charge Items.
        // [GIVEN] Created Setup for NOC with threshold overlook, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and and Post Sales Invoice
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemWithoutThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354871] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Order and Threshold Overlook is not selected with Charge Items.
        // [GIVEN] Created Setup for NOC without threshold overlook, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceChargeItemWithoutThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354872] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Invoice and Threshold Overlook is not selected with Charge Items.
        // [GIVEN] Created Setup for NOC with threshold overlook, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and and Post Sales Invoice
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemWithThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354874] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Order and Threshold Overlook is selected with Charge Items.
        // [GIVEN] Created Setup for NOC with threshold overlook, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemAndThresholdOverlookSelected()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354875] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Invoice and Threshold Overlook is selected with Charge Items.
        // [GIVEN] Created Setup for NOC with threshold overlook, Assessee Code, Customer, TCS Setup and Tax Accounting Period
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and and Post Sales Invoice
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemWithDifferentEffectiveDate()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354880] Check if the program is calculating TCS using Sales Order in case of different rates for same NOC with different effective dates with Charge Items.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates with different Effective Date
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', CalcDate('<1Y>', WorkDate()));

        // [WHEN] Create and and Post Sales Order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemWithDifferentEffectiveDate()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354881] Check if the program is calculating TCS using Sales Invoice in case of different rates for same NOC with different effective dates with Charge Items.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates with different Effective Date
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithoutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', CalcDate('<1Y>', WorkDate()));

        // [WHEN] Create and and Post Sales Invoice
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithChargeItemWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scneraio [354935] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice Charge Items is raised to the Customer is having a certificate using Sales Invoice.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and and Post Sales Invoice
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::"Charge (Item)", false);
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, SalesLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithChargeItemWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
    begin
        // [Scneraio [354936] Check if the program is calculating TCS on Lower rate/zero rate in case an invoice Charge Items is raised to the Customer is having a certificate using Sales Order
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and and Post Sales Order
        DocumentNo := CreateandPostSalesDocumentWithChargeItem(SalesHeader."Document Type"::Order, Customer."No.", WorkDate());

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 4);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResource()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354736] Check if the program is calculating TCS in case of creating Sales Order for the customer with Resources.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResource()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354742] Check if the program is calculating TCS in case of creating Sales Invoice for the customer with Resources.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourcePartialShipment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354747] Check if the program is calculating TCS in case of creating Sales Order/Invoice for partial shipments with Resources.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales order With Partial Shipment
        DocumentNo := CreateAndPostSalesDocumentWithPartialShipment(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 0);
        VerifyTCSEntryCount(DocumentNo, 0);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourcePartialInvoice()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354748] Check if the program is calculating TCS  in case of creating Sales Order for partial invoicing with Resources.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales order With Partial Invoice
        DocumentNo := CreateAndPostSalesDocumentWithPartialInvoicing(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        VerifyTCSEntryCount(DocumentNo, 1);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFCYSalesOrderWithGLAccAndSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354788] Check if the program is calculating TCS in case an invoice is raised to the foreign Customer using Sales Order and Surcharge Overlook is selected with G/L Account
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales order With Currency
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFCYSalesInvoiceWithGLAccAndSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354789] Check if the program is calculating TCS in case an invoice is raised to the foreign Customer using Sales Invoice and Surcharge Overlook is selected with G/L Account
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice With Currency
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::"G/L Account",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFCYSalesOrderWithItemAndSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354819] Check if the program is calculating TCS in case an invoice is raised to the foreign Customer using Sales Order and Surcharge Overlook is selected with Item
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales order With Currency
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::Item,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFCYSalesInvoiceWithItemAndSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354820] Check if the program is calculating TCS in case an invoice is raised to the foreign Customer using Sales Invoice and Surcharge Overlook is selected with Item
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice With Currency
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::Item,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        VerifyTCSEntry(DocumentNo, true, false, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354850] Check if the program is calculating TCS using Sales Order with concessional codes with Resources.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceWithConcessional()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354851] Check if the program is calculating TCS using Sales Invoice with concessional codes with Resources.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFCYSalesOrderWithResourceAndSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354853] Check if the program is calculating TCS in case an invoice is raised to the foreign Customer using Sales Order and Surcharge Overlook is selected with Resources
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithOutPANWithOutConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales order With Currency
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFCYSalesinvoceWithResourceAndSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354854] Check if the program is calculating TCS in case an invoice is raised to the foreign Customer using Sales Invoice and Surcharge Overlook is selected with Resources
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithOutPANWithOutConcessional(Customer, false, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales order With Currency
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFCYSalesOrderWithResourceWithoutSurchargeOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354857] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Order and Threshold Overlook is not selected with Resources.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithOutPANWithOutConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales order With Currency
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFCYSalesinvoceWithResourceWithThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354858] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Invoice and Threshold Overlook is not selected with Resources.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithOutPANWithOutConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales order With Currency
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentWithFCY(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAWithRoundOff()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354701] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while raising invoice or receiving advance from the customer using Sales Order with Fixed Assets
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales order With Fixed Asset
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAWithRoundOff()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354702] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while raising invoice or receiving advance from the customer using Sales Invoice with Fixed Assets
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice With Fixed Asset
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithResourceWithRoundOff()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354703] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while raising invoice or receiving advance from the customer using Sales Order with Resources
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithResourceAndRoundOff()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354704] Check if the system is calculating TCS rounded off on each component (TCS amount, surcharge amount, eCess amount) while raising invoice or receiving advance from the customer using Sales Invoice with Resources
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::Resource,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 2);
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFA()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354707] Check if the program is calculating TCS in case of creating Sales Order for the customer with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales order With Fixed Asset
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFA()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354708] Check if the program is calculating TCS in case of creating Sales Invoice for the customer with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice With Fixed Asset
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAAgaintAdvancePayment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        GenJournalLine: Record "Gen. Journal Line";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
        PaymentDocNo: Code[20];
    begin
        // [SCENARIO] [354709] Check if the program is calculating TCS  in case of creating Sales Order against an advance payment with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post General journal
        PaymentDocNo := CreateGenJnlLinePaymentWithTCS(GenJournalLine, Customer);

        // [WHEN] Create and Post Sales order against advance payment
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentAgainstAdvancePayment(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            PaymentDocNo,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAAgaintAdvancePayment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        GenJournalLine: Record "Gen. Journal Line";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
        PaymentDocNo: Code[20];
    begin
        // [SCENARIO] [354710] Check if the program is calculating TCS  in case of creating Sales Invoice against an advance payment with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post general journal With advance payment
        PaymentDocNo := CreateGenJnlLinePaymentWithTCS(GenJournalLine, Customer);

        // [WHEN] Create and Post Sales Invoice against advance payment
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentAgainstAdvancePayment(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            PaymentDocNo,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAAgaintPartialAdvancePayment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        GenJournalLine: Record "Gen. Journal Line";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
        PaymentDocNo: Code[20];
    begin
        // [SCENARIO] [354711] Check if the program is calculating TCS in case of creating Sales Order against partial advance payment with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Genral journal with payment
        PaymentDocNo := CreateGenJnlLinePaymentWithTCS(GenJournalLine, Customer);

        // [WHEN] Create and Post Sales order against advance payment
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentAgainstPartialAdvancePayment(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            PaymentDocNo,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAAgaintPartialAdvancePayment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        GenJournalLine: Record "Gen. Journal Line";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
        PaymentDocNo: Code[20];
    begin
        // [SCENARIO] [354712] Check if the program is calculating TCS in case of creating Sales Invoice against partial advance payment with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Genral journal with payment
        PaymentDocNo := CreateGenJnlLinePaymentWithTCS(GenJournalLine, Customer);

        // [WHEN] Create and Post Sales Invoice against advance payment
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocumentAgainstPartialAdvancePayment(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            PaymentDocNo,
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAPartialShipment()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354713] Check if the program is calculating TCS in case of creating Sales Order for partial shipments with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order with Partial Shipment
        DocumentNo := CreateAndPostSalesDocumentWithPartialShipment(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 0);
        VerifyTCSEntryCount(DocumentNo, 0);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAPartialInvoice()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354714] Check if the program is calculating TCS  in case of creating Sales Order for partial invoicing with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period and TCS Rates
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order with Partial invoicing
        DocumentNo := CreateAndPostSalesDocumentWithPartialInvoicing(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAWithThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354829] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Order and Threshold Overlook is selected with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period, TCS Rates and threshold overlook
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAWithThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354830] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Invoice and Threshold Overlook is selected with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period, TCS Rates and threshold overlook
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, true, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesOrderWithFAWithoutThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354831] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Order and Threshold Overlook is not selected with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period, TCS Rates and threshold overlook not Selected
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesInvoiceWithFAWithOutThresholdOverlook()
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [354832] Check if the program is calculating TCS in case an invoice is raised to the Customer using Sales Invoice and Threshold Overlook is not selected with Fixed Assets.
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup, Tax Accounting Period, TCS Rates and threshold overlook not Selected
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithOutConcessional(Customer, false, false);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Invoice
        DocumentNo := TCSSalesLibrary.CreateAndPostSalesDocument(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.",
            WorkDate(),
            SalesLineType::"Fixed Asset",
            false);

        // [THEN] TCS and G/L Entry Created and Verified
        TCSSalesLibrary.VerifyTCSEntryForFAandResource(DocumentNo);
    end;

    local procedure CreateGenJnlLinePaymentWithTCS(var GenJournalLine: Record "Gen. Journal Line"; Customer: Record Customer): Code[20]
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
        DocumentNo: Code[20];
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
        GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Customer, Customer."No.",
        GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNoWithDirectPosting(), LibraryRandom.RandDec(10000, 2));
        GenJournalLine.Validate(Amount, -5000);
        GenJournalLine.Modify();
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        exit(DocumentNo);
    end;

    local procedure CreateCurrencyCode(): Code[10]
    var
        Currency: Record Currency;
    begin
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, WorkDate(), 100, LibraryRandom.RandDecInDecimalRange(70, 80, 2));
        exit(Currency.Code);
    end;

    local procedure RemovePANNoOnCompInfo()
    var
        CompInfo: Record "Company Information";
    begin
        CompInfo.Get();
        CompInfo.Validate("P.A.N. No.", '');
        CompInfo.Modify(true);
    end;

    local procedure GetBaseAmountForSales(DocumentNo: Code[20]): Decimal
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetRange("Document No.", DocumentNo);
        SalesInvoiceLine.SetFilter("TCS Nature of Collection", '<>%1', '');
        SalesInvoiceLine.CalcSums(Amount);
        exit(SalesInvoiceLine.Amount);
    end;

    local procedure GetCurrencyFactorForSales(DocumentNo: Code[20]): Decimal
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.SetRange("No.", DocumentNo);
        if SalesInvoiceHeader.FindFirst() then
            exit(SalesInvoiceHeader."Currency Factor");
    end;

    local procedure VerifyStatisticsForTCS(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesOrders: TestPage "Sales Order List";
        ExpectedTCSAmount, ActualAmount, TCSPercentage, SurchargePercentage, eCessPercentage, SHECessPercentage : Decimal;
    begin
        Evaluate(TCSPercentage, Storage.Get(TCSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindSet();
        repeat
            ExpectedTCSAmount += SalesLine."Amount" * TCSPercentage / 100;
        until SalesLine.Next() = 0;
        ExpectedTCSAmount += ExpectedTCSAmount * SurchargePercentage / 100;
        ExpectedTCSAmount += ExpectedTCSAmount * eCessPercentage / 100 + ExpectedTCSAmount * SHECessPercentage / 100;
        ExpectedTCSAmount := LibraryTCS.RoundTCSAmount(ExpectedTCSAmount);

        SalesOrders.OpenEdit();
        SalesOrders.GoToRecord(SalesHeader);
        SalesOrders.Statistics.Invoke();

        Evaluate(ActualAmount, Storage.Get(StatsTCSAmountLbl));

        Assert.AreNearlyEqual(ExpectedTCSAmount, ActualAmount, LibraryTCS.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, ActualAmount, ExpectedTCSAmount));
    end;

    local procedure VerifyStatisticsForTCSWithInvoice(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesOrders: TestPage "Sales Invoice List";
        ExpectedTCSAmount, ActualAmount, TCSPercentage, SurchargePercentage, eCessPercentage, SHECessPercentage : Decimal;
    begin
        Evaluate(TCSPercentage, Storage.Get(TCSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindSet();
        repeat
            ExpectedTCSAmount += SalesLine."Amount" * TCSPercentage / 100;
        until SalesLine.Next() = 0;
        ExpectedTCSAmount += ExpectedTCSAmount * SurchargePercentage / 100;
        ExpectedTCSAmount += ExpectedTCSAmount * eCessPercentage / 100 + ExpectedTCSAmount * SHECessPercentage / 100;
        ExpectedTCSAmount := LibraryTCS.RoundTCSAmount(ExpectedTCSAmount);

        SalesOrders.OpenEdit();
        SalesOrders.GoToRecord(SalesHeader);
        SalesOrders.Statistics.Invoke();

        Evaluate(ActualAmount, Storage.Get(StatsTCSAmountLbl));

        Assert.AreNearlyEqual(ExpectedTCSAmount, ActualAmount, LibraryTCS.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, ActualAmount, ExpectedTCSAmount));
    end;

    local procedure CreateAndPostSalesDocumentWithShipmentOnly(
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
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, false));
    end;

    local procedure CreateAndPostSalesDocumentWithPartialShipment(
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

        CreateSalesLineWithPartialShipment(SalesHeader, SalesLine, LineType, LineDiscount);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, false));
    end;

    local procedure CreateAndPostSalesDocumentWithPartialInvoicing(
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

        CreateSalesLineWithPartialInvoicing(SalesHeader, SalesLine, LineType, LineDiscount);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure VerifyTCSEntryCount(DocumentNo: Code[20]; ExpectedCount: Integer)
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordCount(TCSEntry, ExpectedCount);
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
        SalesLine1: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);

        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, LineType, LineDiscount);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine1, LineType, LineDiscount);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateSalesLineWithPartialInvoicing(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        Type: Enum "Sales Line Type";
        LineDiscount: Boolean)
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Type,
        TCSSalesLibrary.GetLineTypeNo(Type, SalesHeader."Posting Date"), LibraryRandom.RandDec(3, 2));
        SalesLine.Validate("Qty. to Invoice", SalesLine.Quantity / 2);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(10000, 20000, 2));
        if LineDiscount then
            SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2))
        else
            SalesLine.Validate("Line Discount %", 0);
        SalesLine.Modify(true);
    end;

    local procedure CreateSalesLineWithPartialShipment(
            var SalesHeader: Record "Sales Header";
            var SalesLine: Record "Sales Line";
            Type: Enum "Sales Line Type";
            LineDiscount: Boolean)
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Type,
        TCSSalesLibrary.GetLineTypeNo(Type, SalesHeader."Posting Date"), LibraryRandom.RandDec(3, 2));
        SalesLine.Validate("Qty. to Ship", SalesLine.Quantity / 2);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(10000, 20000, 2));
        if LineDiscount then
            SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2))
        else
            SalesLine.Validate("Line Discount %", 0);
        SalesLine.Modify(true);
    end;

    local procedure CreateandPostSalesDocumentWithChargeItem(DocumentType: Enum "Sales Document Type"; CustomerNo: Code[20]; PostingDate: Date): Code[20]
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine1: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::Item, false);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine1, SalesLine.Type::"Charge (Item)", false);
        TCSSalesLibrary.CreateItemChargeAssignment(
            ItemChargeAssignmentSales, SalesLine1, DocumentType,
            SalesHeader."No.", SalesLine."Line No.", SalesLine."No.");
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateandPostSalesDocumentWithChargeItemWithPartialInvoice(DocumentType: Enum "Sales Document Type"; CustomerNo: Code[20]; PostingDate: Date): Code[20]
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine1: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine, SalesLine.Type::Item, false);
        SalesLine.validate("Qty. to Invoice", SalesLine.Quantity / 2);
        SalesLine.Modify();
        TCSSalesLibrary.CreateSalesLine(SalesHeader, SalesLine1, SalesLine.Type::"Charge (Item)", false);
        TCSSalesLibrary.CreateItemChargeAssignment(
            ItemChargeAssignmentSales, SalesLine1, DocumentType,
            SalesHeader."No.", SalesLine."Line No.", SalesLine."No.");
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure VerifyTCSEntry(DocumentNo: Code[20]; WithPAN: Boolean; TCSThresholdOverlook: Boolean; SurchargeOverlook: Boolean)
    var
        TCSEntry: Record "TCS Entry";
        ExpectedTCSAmount, ExpectedSurchargeAmount, ExpectedEcessAmount, ExpectedSHEcessAmount : Decimal;
        TCSPercentage, NonPANTCSPercentage, SurchargePercentage, eCessPercentage, SHECessPercentage : Decimal;
        TCSThresholdAmount, SurchargeThresholdAmount, TCSBaseAmount, CurrencyFactor : Decimal;
    begin
        Evaluate(TCSPercentage, Storage.Get(TCSPercentageLbl));
        Evaluate(NonPANTCSPercentage, Storage.Get(NonPANTCSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TCSThresholdAmount, Storage.Get(TCSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        TCSBaseAmount := GetBaseAmountForSales(DocumentNo);
        CurrencyFactor := GetCurrencyFactorForSales(DocumentNo);

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
            TCSBaseAmount / CurrencyFactor, TCSEntry."TCS Base Amount", LibraryTCS.GetTCSRoundingPrecision(),
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
            ExpectedTCSAmount, TCSEntry."TCS Amount", LibraryTCS.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("TCS Amount"), TCSEntry.TableCaption()));
        Assert.AreEqual(
            SurchargePercentage, TCSEntry."Surcharge %",
            StrSubstNo(AmountErr, TCSEntry.FieldName("Surcharge %"), TCSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedSurchargeAmount, TCSEntry."Surcharge Amount", LibraryTCS.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("Surcharge Amount"), TCSEntry.TableCaption()));
        Assert.AreEqual(
            eCessPercentage, TCSEntry."eCESS %",
            StrSubstNo(AmountErr, TCSEntry.FieldName("eCESS %"), TCSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedEcessAmount, TCSEntry."eCESS Amount", LibraryTCS.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("eCESS Amount"), TCSEntry.TableCaption()));
        Assert.AreEqual(
            SHECessPercentage, TCSEntry."SHE Cess %",
            StrSubstNo(AmountErr, TCSEntry.FieldName("SHE Cess %"), TCSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedSHEcessAmount, TCSEntry."SHE Cess Amount", LibraryTCS.GetTCSRoundingPrecision(),
            StrSubstNo(AmountErr, TCSEntry.FieldName("SHE Cess Amount"), TCSEntry.TableCaption()));
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

    [ModalPageHandler]
    procedure InvoiceStatisticsPageHandler(var SalesStatistics: TestPage "Sales Statistics");
    var
        Amount: Text;
    begin
        Amount := SalesStatistics."TCS Amount".Value;
        Storage.Set(StatsTCSAmountLbl, Amount);
    end;

    [ModalPageHandler]
    procedure StatisticsPageHandler(var SalesStatistics: TestPage "Sales Order Statistics")
    var
        Amount: Text;
    begin
        Amount := SalesStatistics."TCS Amount".Value;
        Storage.Set(StatsTCSAmountLbl, Amount);
    end;

    var
        LibraryTCS: Codeunit "TCS - Library";
        LibrarySales: Codeunit "Library - Sales";
        TCSSalesLibrary: Codeunit "TCS Sales - Library";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
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
        StatsTCSAmountLbl: Label 'StatsTCSAmount', locked = true;
        IncomeTaxAccountingErr: Label 'Posting Date doesn''t lie in Tax Accounting Period', Locked = true;
        TCANNoErr: Label 'T.C.A.N. No. must have a value in Gen. Journal Line: Journal Template Name=, Journal Batch Name=, Line No.=0. It cannot be zero or empty.', Locked = true;
        CompanyInfoErr: Label 'P.A.N. No. must have a value in Company Information: Primary Key=. It cannot be zero or empty.';
        ChargeItemErr: Label 'You must assign item charge %1 if you want to invoice it.', Comment = '%1= No.';
        AmountErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = TCS Amount and TCS field Caption';

}