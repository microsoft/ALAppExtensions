codeunit 139644 "IS VAT Reporting - Tests"
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
        Assert: Codeunit Assert;
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        Initialized: Boolean;

    local procedure Initialize()
    var
        PurchasesSetup: Record "Purchases & Payables Setup";
        InvtSetup: Record "Inventory Setup";
    begin
        if Initialized then
            exit;

        Initialized := true;
        LibrarySales.SetStockoutWarning(false);
        LibrarySales.SetCreditWarningsToNoWarnings();

        PurchasesSetup.Get();
        PurchasesSetup.Validate("Ext. Doc. No. Mandatory", false);
        PurchasesSetup.Modify();

        LibraryInvt.NoSeriesSetup(InvtSetup);

        Commit();
    end;

    [Test]
    [HandlerFunctions('VATReconciliationAHandler')]
    [Scope('OnPrem')]
    procedure SalesVATReconciliationA()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempVATAmtLine: Record "VAT Amount Line" temporary;
        Month: Integer;
        WD: Date;
    begin
        Initialize();

        WD := WorkDate();

        for Month := 1 to 12 do begin
            WorkDate := DMY2Date(1, Month);

            TempVATAmtLine.Reset();
            if Month in [1, 3, 5, 7, 9, 11] then
                TempVATAmtLine.DeleteAll();

            CreateSalesInvWithMultipleVATAndPost(SalesInvoiceHeader);
            GetSalesInvoiceHeaderVATAmt(TempVATAmtLine, SalesInvoiceHeader);

            SalesInvoiceHeader.SetRecFilter();
            REPORT.Run(REPORT::"IS VAT Reconciliation A", true, false);

            VerifyVATReconciliation(TempVATAmtLine, true);
        end;

        WorkDate := WD;
    end;

    [Test]
    [HandlerFunctions('VATReconciliationAHandler')]
    [Scope('OnPrem')]
    procedure PurchVATReconciliationA()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        TempVATAmtLine: Record "VAT Amount Line" temporary;
        Month: Integer;
        WD: Date;
    begin
        Initialize();

        WD := WorkDate();

        for Month := 1 to 12 do begin
            WorkDate := DMY2Date(1, Month);

            TempVATAmtLine.Reset();
            if Month in [1, 3, 5, 7, 9, 11] then
                TempVATAmtLine.DeleteAll();

            CreatePurchInvWithMultipleVATAndPost(PurchInvHeader);
            GetPurchInvoiceHeaderVATAmt(TempVATAmtLine, PurchInvHeader);

            PurchInvHeader.SetRecFilter();
            REPORT.Run(REPORT::"IS VAT Reconciliation A", true, false);

            VerifyVATReconciliation(TempVATAmtLine, false);
        end;

        WorkDate := WD;
    end;

    [Test]
    [HandlerFunctions('VATBalancingReportHandler')]
    [Scope('OnPrem')]
    procedure SalesVATBalancingReport()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempVATAmtLine: Record "VAT Amount Line" temporary;
        Month: Integer;
        WD: Date;
    begin
        Initialize();

        WD := WorkDate();

        for Month := 1 to 12 do begin
            WorkDate := DMY2Date(1, Month);

            TempVATAmtLine.Reset();
            if Month in [1, 3, 5, 7, 9, 11] then
                TempVATAmtLine.DeleteAll();

            CreateSalesInvWithMultipleVATAndPost(SalesInvoiceHeader);
            GetSalesInvoiceHeaderVATAmt(TempVATAmtLine, SalesInvoiceHeader);

            SalesInvoiceHeader.SetRecFilter();
            REPORT.Run(REPORT::"IS VAT Balancing Report", true, false);

            VerifyVATBalancingReport(TempVATAmtLine, true);
        end;

        WorkDate := WD;
    end;

    [Test]
    [HandlerFunctions('VATBalancingReportHandler')]
    [Scope('OnPrem')]
    procedure PurchVATBalancingReport()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        TempVATAmtLine: Record "VAT Amount Line" temporary;
        Month: Integer;
        WD: Date;
    begin
        Initialize();

        WD := WorkDate();

        for Month := 1 to 12 do begin
            WorkDate := DMY2Date(1, Month);

            TempVATAmtLine.Reset();
            if Month in [1, 3, 5, 7, 9, 11] then
                TempVATAmtLine.DeleteAll();

            CreatePurchInvWithMultipleVATAndPost(PurchInvHeader);
            GetPurchInvoiceHeaderVATAmt(TempVATAmtLine, PurchInvHeader);

            PurchInvHeader.SetRecFilter();
            REPORT.Run(REPORT::"IS VAT Balancing Report", true, false);

            VerifyVATBalancingReport(TempVATAmtLine, false);
        end;

        WorkDate := WD;
    end;

    local procedure VerifyVATReconciliation(var VATAmtLine: Record "VAT Amount Line"; IsSale: Boolean)
    begin
        LibraryReportDataset.LoadDataSetFile();
        VATAmtLine.FindFirst();
        repeat
            LibraryReportDataset.Reset();
            LibraryReportDataset.SetRange('VATProdPostingGrp_VATPostingSetup', VATAmtLine."VAT Identifier");
            Assert.IsTrue(LibraryReportDataset.GetNextRow(), '');
            if IsSale then begin
                LibraryReportDataset.AssertCurrentRowValueEquals('VatReceivable', -VATAmtLine."VAT Amount");
                LibraryReportDataset.AssertCurrentRowValueEquals('TurnoverReceivable', -VATAmtLine."VAT Base");
            end else begin
                LibraryReportDataset.AssertCurrentRowValueEquals('VATPayable', VATAmtLine."VAT Amount");
                LibraryReportDataset.AssertCurrentRowValueEquals('TurnoverPayable', VATAmtLine."VAT Base");
            end;
        until VATAmtLine.Next() = 0;
    end;

    local procedure VerifyVATBalancingReport(var VATAmtLine: Record "VAT Amount Line"; IsSale: Boolean)
    begin
        LibraryReportDataset.LoadDataSetFile();
        VATAmtLine.FindFirst();
        repeat
            LibraryReportDataset.Reset();
            LibraryReportDataset.SetRange('VATProdPostingGroup_VATPostingSetup', VATAmtLine."VAT Identifier");
            Assert.IsTrue(LibraryReportDataset.GetNextRow(), '');
            if IsSale then begin
                LibraryReportDataset.AssertCurrentRowValueEquals('VatReceivable', -VATAmtLine."VAT Amount");
                LibraryReportDataset.AssertCurrentRowValueEquals('TurnoverOut', -VATAmtLine."VAT Base");
            end else begin
                LibraryReportDataset.AssertCurrentRowValueEquals('VatPayableVariance', VATAmtLine."VAT Amount");
                LibraryReportDataset.AssertCurrentRowValueEquals('TurnoverIn', VATAmtLine."VAT Base");
            end;
        until VATAmtLine.Next() = 0;
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
        GLAcc: Record "G/L Account";
        GLAcc2: Record "G/L Account";
        VATProdPostingGr: Record "VAT Product Posting Group";
    begin
        LibraryERM.CreateGLAccount(GLAcc);
        LibraryERM.CreateGLAccount(GLAcc2);

        LibraryERM.CreateVATProductPostingGroup(VATProdPostingGr);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusPostingGrCode, VATProdPostingGr.Code);
        VATPostingSetup.Validate("VAT Identifier", VATPostingSetup."VAT Prod. Posting Group");
        VATPostingSetup.Validate("VAT %", 10);
        VATPostingSetup.Validate("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.Validate("Purchase VAT Account", GLAcc."No.");
        VATPostingSetup.Validate("Purch. VAT Unreal. Account", GLAcc."No.");
        VATPostingSetup.Validate("Sales VAT Account", GLAcc2."No.");
        VATPostingSetup.Validate("Sales VAT Unreal. Account", GLAcc2."No.");
        VATPostingSetup.Modify(true);
    end;

    local procedure GetSalesInvoiceHeaderVATAmt(var VATAmtLine: Record "VAT Amount Line"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                VATAmtLine.Init();
                VATAmtLine."VAT Identifier" := SalesInvoiceLine."VAT Identifier";
                VATAmtLine."VAT Calculation Type" := SalesInvoiceLine."VAT Calculation Type";
                VATAmtLine."Tax Group Code" := SalesInvoiceLine."Tax Group Code";
                VATAmtLine."VAT %" := SalesInvoiceLine."VAT %";
                VATAmtLine."VAT Base" := SalesInvoiceLine.Amount;
                VATAmtLine."Amount Including VAT" := SalesInvoiceLine."Amount Including VAT";
                VATAmtLine."Line Amount" := SalesInvoiceLine."Line Amount";

                VATAmtLine.InsertLine();
            until SalesInvoiceLine.Next() = 0;
    end;

    local procedure GetPurchInvoiceHeaderVATAmt(var VATAmtLine: Record "VAT Amount Line"; PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        if PurchInvLine.FindSet() then
            repeat
                with VATAmtLine do begin
                    Init();
                    "VAT Identifier" := PurchInvLine."VAT Identifier";
                    "VAT Calculation Type" := PurchInvLine."VAT Calculation Type";
                    "Tax Group Code" := PurchInvLine."Tax Group Code";
                    "Line Amount" := PurchInvLine."Line Amount";

                    "VAT %" := PurchInvLine."VAT %";
                    "VAT Base" := PurchInvLine.Amount;
                    "Amount Including VAT" := PurchInvLine."Amount Including VAT";
                    "Line Amount" := PurchInvLine."Line Amount";

                    InsertLine();
                end;
            until PurchInvLine.Next() = 0;
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure VATReconciliationAHandler(var VATReconciliationA: TestRequestPage "IS VAT Reconciliation A")
    var
        VATPeriod: Option Custom,"January-February","March-April","May-June","July-August","September-October","November-December";
    begin
        VATReconciliationA.Year.SetValue := Date2DMY(WorkDate(), 3);
        VATPeriod := GetVATReportPeriod();
        VATReconciliationA.Period.SetValue := Format(VATPeriod);
        VATReconciliationA.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure VATBalancingReportHandler(var VATBalancingReport: TestRequestPage "IS VAT Balancing Report")
    var
        VATPeriod: Option Custom,"January-February","March-April","May-June","July-August","September-October","November-December";
    begin
        VATBalancingReport.Year.SetValue := Date2DMY(WorkDate(), 3);
        VATPeriod := GetVATReportPeriod();
        VATBalancingReport.Period.SetValue := Format(VATPeriod);
        VATBalancingReport.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(QuestionTxt: Text; var Reply: Boolean)
    begin
        Reply := false;
    end;

    local procedure GetVATReportPeriod(): Integer
    var
        PeriodInt: Integer;
    begin
        PeriodInt := Date2DMY(WorkDate(), 2);
        if PeriodInt in [2, 4, 6, 8, 10, 12] then
            PeriodInt := PeriodInt / 2
        else
            PeriodInt := (PeriodInt + 1) / 2;

        exit(PeriodInt);
    end;
}