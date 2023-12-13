codeunit 139643 "IS IRS - Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurch: Codeunit "Library - Purchase";
        LibraryInvt: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        Initialized: Boolean;

    local procedure Initialize()
    var
        PurchasesSetup: Record "Purchases & Payables Setup";
        InvtSetup: Record "Inventory Setup";
#if not CLEAN24
        ISCoreAppSetup: Record "IS Core App Setup";
#endif
    begin
        if Initialized then
            exit;

        Initialized := true;
        LibrarySales.SetStockoutWarning(false);
        LibrarySales.SetCreditWarningsToNoWarnings();

        PurchasesSetup.Get();
        PurchasesSetup.Validate("Ext. Doc. No. Mandatory", false);
        PurchasesSetup.Modify();

#if not CLEAN24
        if not ISCoreAppSetup.Get() then begin
            ISCoreAppSetup.Init();
            ISCoreAppSetup.Insert();
        end;
        ISCoreAppSetup.Enabled := true;
        ISCoreAppSetup.Modify(false);
#endif
        LibraryInvt.NoSeriesSetup(InvtSetup);

        Commit();
    end;

    [Test]
    [HandlerFunctions('IRSDetailsHandler')]
    [Scope('OnPrem')]
    procedure SalesInvoice_IRSDetails()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempIRS_GLAcc: Record "G/L Account" temporary;
        ISIRSNumbers: Record "IS IRS Numbers";
    begin
        Initialize();

        CreateSalesInvWithMultipleVATAndPost(SalesInvoiceHeader);
        GetSalesInvoiceHeaderIRS_VATAmt(TempIRS_GLAcc, SalesInvoiceHeader);

        // Exercise
        ISIRSNumbers.SetFilter("IRS Number", GetGLAccFilter(TempIRS_GLAcc, TempIRS_GLAcc."IRS No."));
        REPORT.Run(REPORT::"IS IRS Details", true, false, ISIRSNumbers);

        // Verify
        VerifyIRSVAT(TempIRS_GLAcc);
    end;

    [Test]
    [HandlerFunctions('IRSDetailsHandler')]
    [Scope('OnPrem')]
    procedure PurchInvoice_IRSDetails()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        TempIRS_GLAcc: Record "G/L Account" temporary;
        ISIRSNumbers: Record "IS IRS Numbers";
    begin
        Initialize();

        CreatePurchInvWithMultipleVATAndPost(PurchInvHeader);
        GetPurchInvoiceHeaderIRS_VATAmt(TempIRS_GLAcc, PurchInvHeader);

        // Exercise
        ISIRSNumbers.SetFilter("IRS Number", GetGLAccFilter(TempIRS_GLAcc, TempIRS_GLAcc."IRS No."));
        REPORT.Run(REPORT::"IS IRS Details", true, false, ISIRSNumbers);

        // Verify
        VerifyIRSVAT(TempIRS_GLAcc);
    end;

    [Test]
    [HandlerFunctions('TrialBalanceIRSNumberHandler')]
    [Scope('OnPrem')]
    procedure SalesInvoice_TrialBalanceIRSNumber()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempIRS_GLAcc: Record "G/L Account" temporary;
        IRS_GLAcc: Record "G/L Account";
    begin
        Initialize();

        CreateSalesInvWithMultipleVATAndPost(SalesInvoiceHeader);
        GetSalesInvoiceHeaderIRS_VATAmt(TempIRS_GLAcc, SalesInvoiceHeader);

        // Exercise
        IRS_GLAcc.SetFilter("No.", GetGLAccFilter(TempIRS_GLAcc, TempIRS_GLAcc."No."));
        REPORT.Run(REPORT::"IS Trial Balance - IRS Number", true, false, IRS_GLAcc);

        // Verify
        VerifyIRSTrialBalance(TempIRS_GLAcc);
    end;

    [Test]
    [HandlerFunctions('TrialBalanceIRSNumberHandler')]
    [Scope('OnPrem')]
    procedure PurchInvoice_TrialBalanceIRSNumber()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        TempIRS_GLAcc: Record "G/L Account" temporary;
        IRS_GLAcc: Record "G/L Account";
    begin
        Initialize();

        CreatePurchInvWithMultipleVATAndPost(PurchInvHeader);
        GetPurchInvoiceHeaderIRS_VATAmt(TempIRS_GLAcc, PurchInvHeader);

        // Exercise
        IRS_GLAcc.SetFilter("No.", GetGLAccFilter(TempIRS_GLAcc, TempIRS_GLAcc."No."));
        REPORT.Run(REPORT::"IS Trial Balance - IRS Number", true, false, IRS_GLAcc);

        // Verify
        VerifyIRSTrialBalance(TempIRS_GLAcc);
    end;

    [Test]
    [HandlerFunctions('IRSNotificationHandler')]
    [Scope('OnPrem')]
    procedure IRSNotification()
    var
        CompanyInfo: Record "Company Information";
    begin
        REPORT.Run(REPORT::"IS IRS notification", true, false);

        LibraryReportDataset.LoadDataSetFile();
        while LibraryReportDataset.GetNextRow() do begin
            // Contain the company info
            CompanyInfo.Get();
            LibraryReportDataset.AssertCurrentRowValueEquals('CompanyInfoName', CompanyInfo.Name);
            LibraryReportDataset.AssertCurrentRowValueEquals('CompanyInfoAddress', CompanyInfo.Address);
            LibraryReportDataset.AssertCurrentRowValueEquals('CompanyInfoPostCodeAndCity', CompanyInfo."Post Code" + ' ' + CompanyInfo.City);
            LibraryReportDataset.AssertCurrentRowValueEquals('CompanyInfoRegNo', 'Kt. ' + CompanyInfo."Registration No.");

            // Describe intent to use single copy invoices
            LibraryReportDataset.AssertCurrentRowValueEquals(
              'InvInAccordanceCaption',
              'intents to utilize the possibility to issue single copy invoices in accordance with IS regulation no. 598/1999');
            LibraryReportDataset.AssertCurrentRowValueEquals(
              'VersionOfNavisionCaption',
              'It is also confirmed that the company uses a version of Navision that complies with the regulation.');
        end;
    end;

    local procedure VerifyIRSVAT(var IRS_GLAcc: Record "G/L Account")
    begin
        LibraryReportDataset.LoadDataSetFile();
        IRS_GLAcc.FindFirst();
        while LibraryReportDataset.GetNextRow() do begin
            LibraryReportDataset.AssertCurrentRowValueEquals('IRSNumber_IRSNumbers', IRS_GLAcc."IRS No.");
            LibraryReportDataset.AssertCurrentRowValueEquals('No_GLAcc', IRS_GLAcc."No.");

            IRS_GLAcc.CalcFields("Balance at Date");
            LibraryReportDataset.AssertCurrentRowValueEquals('BalanceAtDate_GLAcc', IRS_GLAcc."Balance at Date");

            IRS_GLAcc.Next();
        end;

        Assert.IsTrue(IRS_GLAcc.Next() = 0, '');
    end;

    local procedure VerifyIRSTrialBalance(var IRS_GLAcc: Record "G/L Account")
    begin
        with LibraryReportDataset do begin
            LoadDataSetFile();
            IRS_GLAcc.FindFirst();
            while GetNextRow() do begin
                GetNextRow(); // This report outputs alternating empty lines
                AssertCurrentRowValueEquals('No_GLAcc', IRS_GLAcc."No.");
                AssertCurrentRowValueEquals('IRSNumber_GLAcc', IRS_GLAcc."IRS No.");

                IRS_GLAcc.CalcFields("Balance at Date");
                AssertCurrentRowValueEquals('BalanceAtDate_GLAcc', IRS_GLAcc."Balance at Date");

                IRS_GLAcc.Next();
            end;

            Assert.IsTrue(IRS_GLAcc.Next() = 0, '');
        end;
    end;

    local procedure CreateSalesDocWithMultipleVAT(var SalesHeader: Record "Sales Header"; DocType: Option)
    var
        SalesLine: Record "Sales Line";
        Cust: Record Customer;
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Lines: Integer;
    begin
        LibrarySales.CreateCustomer(Cust);
        LibrarySales.CreateSalesHeader(SalesHeader, DocType, Cust."No.");

        for Lines := 1 to 2 do begin
            Clear(Item);
            Clear(VATPostingSetup);
            CreateVATPostingSetup(VATPostingSetup, Cust."VAT Bus. Posting Group");

            LibraryInvt.CreateItem(Item);
            Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
            Item.Modify(true);

            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
            SalesLine.Validate("Unit Price", 10);
            SalesLine.Modify(true);
        end;

        Commit();
    end;

    local procedure CreateSalesInvWithMultipleVATAndPost(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesDocWithMultipleVAT(SalesHeader, SalesHeader."Document Type"::Invoice);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreatePurchDocWithMultipleVAT(var PurchHeader: Record "Purchase Header"; DocType: Option)
    var
        PurchLine: Record "Purchase Line";
        Vend: Record Vendor;
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Lines: Integer;
    begin
        LibraryPurch.CreateVendor(Vend);
        LibraryPurch.CreatePurchHeader(PurchHeader, DocType, Vend."No.");

        for Lines := 1 to 2 do begin
            Clear(Item);
            Clear(VATPostingSetup);
            CreateVATPostingSetup(VATPostingSetup, Vend."VAT Bus. Posting Group");

            LibraryInvt.CreateItem(Item);
            Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
            Item.Modify(true);

            LibraryPurch.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, Item."No.", 1);
            PurchLine.Validate("Direct Unit Cost", 10);
            PurchLine.Modify(true);
        end;

        Commit();
    end;

    local procedure CreatePurchInvWithMultipleVATAndPost(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchHeader: Record "Purchase Header";
    begin
        CreatePurchDocWithMultipleVAT(PurchHeader, PurchHeader."Document Type"::Invoice);
        PurchInvHeader.Get(LibraryPurch.PostPurchaseDocument(PurchHeader, true, true));
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATBusPostingGrCode: Code[20])
    var
        VAT_GLAcc: Record "G/L Account";
        VATProdPostingGr: Record "VAT Product Posting Group";
        ISIRSNumbers: Record "IS IRS Numbers";
    begin
        ISIRSNumbers.Init();
        ISIRSNumbers."IRS Number" := LibraryUtility.GenerateRandomCode(ISIRSNumbers.FieldNo("IRS Number"), DATABASE::"IS IRS Numbers");
        ISIRSNumbers.Insert();

        LibraryERM.CreateGLAccount(VAT_GLAcc);
        VAT_GLAcc."IRS No." := ISIRSNumbers."IRS Number";
        VAT_GLAcc.Modify();

        LibraryERM.CreateVATProductPostingGroup(VATProdPostingGr);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusPostingGrCode, VATProdPostingGr.Code);
        VATPostingSetup.Validate("VAT Identifier", VATPostingSetup."VAT Prod. Posting Group");
        VATPostingSetup.Validate("VAT %", 10);
        VATPostingSetup.Validate("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.Validate("Purchase VAT Account", VAT_GLAcc."No.");
        VATPostingSetup.Validate("Purch. VAT Unreal. Account", VAT_GLAcc."No.");
        VATPostingSetup.Validate("Sales VAT Account", VAT_GLAcc."No.");
        VATPostingSetup.Validate("Sales VAT Unreal. Account", VAT_GLAcc."No.");
        VATPostingSetup.Modify(true);
    end;

    local procedure GetSalesInvoiceHeaderIRS_VATAmt(var IRS_GLAcc: Record "G/L Account"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        VATPostingSetup: Record "VAT Posting Setup";
        GLAcc: Record "G/L Account";
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                VATPostingSetup.Get(SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group");
                GLAcc.Get(VATPostingSetup."Sales VAT Account");
                if GLAcc."IRS No." <> '' then begin
                    IRS_GLAcc := GLAcc;
                    IRS_GLAcc.Insert();
                end;
            until SalesInvoiceLine.Next() = 0;
    end;

    local procedure GetPurchInvoiceHeaderIRS_VATAmt(var IRS_GLAcc: Record "G/L Account"; PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchInvLine: Record "Purch. Inv. Line";
        VATPostingSetup: Record "VAT Posting Setup";
        GLAcc: Record "G/L Account";
    begin
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        if PurchInvLine.FindSet() then
            repeat
                VATPostingSetup.Get(PurchInvLine."VAT Bus. Posting Group", PurchInvLine."VAT Prod. Posting Group");
                GLAcc.Get(VATPostingSetup."Sales VAT Account");
                if GLAcc."IRS No." <> '' then begin
                    IRS_GLAcc := GLAcc;
                    IRS_GLAcc.Insert();
                end;
            until PurchInvLine.Next() = 0;
    end;

    local procedure GetGLAccFilter(var GLAcc: Record "G/L Account"; var FilterField: Code[20]) FilterText: Text
    begin
        FilterField := '';
        if GLAcc.FindSet() then
            repeat
                if FilterText = '' then
                    FilterText := FilterField
                else
                    FilterText := StrSubstNo('%1|%2', FilterText, FilterField);
            until GLAcc.Next() = 0;
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure IRSDetailsHandler(var ISIRSDetails: TestRequestPage "IS IRS Details")
    begin
        ISIRSDetails.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure TrialBalanceIRSNumberHandler(var ISTrialBalanceIRSNumber: TestRequestPage "IS Trial Balance - IRS Number")
    begin
        ISTrialBalanceIRSNumber.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure IRSNotificationHandler(var ISIRSNotification: TestRequestPage "IS IRS notification")
    begin
        ISIRSNotification.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}

