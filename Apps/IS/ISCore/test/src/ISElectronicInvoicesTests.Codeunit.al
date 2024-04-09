codeunit 139642 "IS Electronic Invoices - Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryInvt: Codeunit "Library - Inventory";
        Assert: Codeunit Assert;
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        Initialized: Boolean;

    local procedure Initialize()
#if not CLEAN24
        ISCoreAppSetup: Record "IS Core App Setup";
#endif
    begin
        if Initialized then
            exit;

        Initialized := true;
        LibrarySales.SetStockoutWarning(false);
        LibrarySales.SetCreditWarningsToNoWarnings();

#if not CLEAN24
        if not ISCoreAppSetup.Get() then begin
            ISCoreAppSetup.Init();
            ISCoreAppSetup.Insert();
        end;
        ISCoreAppSetup.Enabled := true;
        ISCoreAppSetup.Modify(false);
#endif
        Commit();
    end;

    [Test]
    [HandlerFunctions('MsgHandler')]
    [Scope('OnPrem')]
    procedure SalesSetup_ElectronicInvoicing()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        IsElectronicInvoicing: Boolean;
    begin
        Initialize();

        for IsElectronicInvoicing := false to true do begin
            // Exercise
            SetElectronicInvoicing(IsElectronicInvoicing);

            // Verify
            SalesSetup.Get();
            Assert.AreEqual(IsElectronicInvoicing, SalesSetup."Electronic Invoicing Reminder", '');
        end;
    end;

    [Test]
    [HandlerFunctions('MsgHandler,SalesQuoteRequestHandler')]
    [Scope('OnPrem')]
    procedure SalesQuote_ElectronicInvoicing()
    var
        SalesHeader: Record "Sales Header";
        IsElectronicInvoicing: Boolean;
    begin
        Initialize();

        CreateSalesDoc(SalesHeader, SalesHeader."Document Type"::Quote);

        for IsElectronicInvoicing := false to true do begin
            // Exercise
            SetElectronicInvoicing(IsElectronicInvoicing);
            REPORT.Run(REPORT::"Standard Sales - Quote", true, false, SalesHeader);

            // Verify
            asserterror VerifyElectronicInvInDataset(IsElectronicInvoicing);
            Assert.ExpectedError('ElectronicInvoicing');
        end;
    end;

    local procedure VerifyElectronicInvInDataset(IsOn: Boolean)
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.Reset();
        LibraryReportDataset.SetRange('ElectronicInvoicing', IsOn);
        Assert.IsTrue(LibraryReportDataset.GetNextRow(), '');
    end;

    local procedure CreateSalesDoc(var SalesHeader: Record "Sales Header"; DocType: Option)
    var
        SalesLine: Record "Sales Line";
        Cust: Record Customer;
        Item: Record Item;
    begin
        LibrarySales.CreateCustomer(Cust);
        LibrarySales.CreateSalesHeader(SalesHeader, DocType, Cust."No.");
        LibraryInvt.CreateItem(Item);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        Commit();
        SalesHeader.SetRange("No.", SalesHeader."No.");
    end;

    local procedure SetElectronicInvoicing(Value: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        SalesSetup.Validate("Electronic Invoicing Reminder", Value);
        SalesSetup.Modify();
        Commit();
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure SalesQuoteRequestHandler(var SalesQuote: TestRequestPage "Standard Sales - Quote")
    begin
        SalesQuote.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MsgHandler(MsgTxt: Text)
    begin
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(QuestionTxt: Text; var Reply: Boolean)
    begin
        Reply := false;
    end;
}

