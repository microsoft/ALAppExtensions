codeunit 139904 "Service Declaration Posting"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [Service Declaration] [Posting]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryServiceDeclaration: Codeunit "Library - Service Declaration";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryService: Codeunit "Library - Service";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        TransactionTypeCodeNotSpecifiedInLineErr: Label 'A service transaction type code is not specified';

    [Test]
    procedure ReleaseSalesDocumentWithServTransTypeSpecifiedForAllServDeclApplicableLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] Stan can release a sales document if all lines with "Applicable For Serv. Decl." option have "Service Transaction Type" code specified

        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsCreate();
        LibraryServiceDeclaration.CreateSalesDocWithServTransTypeCode(SalesHeader, SalesLine);
        Codeunit.Run(Codeunit::"Release Sales Document", SalesHeader);
        SalesHeader.TestField(Status, SalesHeader.Status::Released);
    end;

    [Test]
    procedure CannotReleaseSalesDocumentWithServTransTypeNotSpecifiedForAllServDeclApplicableLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] Stan cannot release a sales document if not all lines with "Applicable For Serv. Decl." option have "Service Transaction Type" code specified

        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsCreate();
        LibraryServiceDeclaration.CreateSalesDocApplicableForServDecl(SalesHeader, SalesLine);
        asserterror Codeunit.Run(Codeunit::"Release Sales Document", SalesHeader);
        Assert.ExpectedError(TransactionTypeCodeNotSpecifiedInLineErr);
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure ReleaseServDocumentWithServTransTypeSpecifiedForAllServDeclApplicableLines()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
    begin
        // [FEATURE] [Service]
        // [SCENARIO 437878] Stan can release a service document if all lines with "Applicable For Serv. Decl." option have "Service Transaction Type" code specified

        Initialize();
        LibraryServiceDeclaration.CreateServDocWithServTransTypeCode(ServiceHeader, ServiceLine);
        Codeunit.Run(Codeunit::"Release Service Document", ServiceHeader);
        ServiceHeader.TestField("Release Status", ServiceHeader."Release Status"::"Released to Ship");
    end;

    [Test]
    procedure CannotReleaseServDocumentWithServTransTypeNotSpecifiedForAllServDeclApplicableLines()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
    begin
        // [FEATURE] [Service]
        // [SCENARIO 437878] Stan cannot release a service document if not all lines with "Applicable For Serv. Decl." option have "Service Transaction Type" code specified

        Initialize();
        LibraryServiceDeclaration.CreateServDocApplicableForServDecl(ServiceHeader, ServiceLine);
        asserterror Codeunit.Run(Codeunit::"Release Service Document", ServiceHeader);
        Assert.ExpectedError(TransactionTypeCodeNotSpecifiedInLineErr);
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure SalesDocApplicableForServDeclBasicPosting()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ValueEntry: Record "Value Entry";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] Posted entries have service declaration related data after posting sales document

        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsPost();
        LibraryServiceDeclaration.CreateSalesDocWithServTransTypeCode(SalesHeader, SalesLine);
        ValueEntry.SetRange("Item No.", SalesLine."No.");
        ValueEntry.SetRange("Document No.", LibrarySales.PostSalesDocument(SalesHeader, true, true));
        ValueEntry.FindFirst();
        ValueEntry.TestField("Applicable For Serv. Decl.");
        ValueEntry.TestField("Service Transaction Type Code", SalesLine."Service Transaction Type Code");
    end;

    [Test]
    procedure ServDocApplicableForServDeclBasicPosting()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ValueEntry: Record "Value Entry";
    begin
        // [FEATURE] [Service]
        // [SCENARIO 437878] Posted entries have service declaration related data after posting service document

        Initialize();
        LibraryServiceDeclaration.CreateServDocWithServTransTypeCode(ServiceHeader, ServiceLine);
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        ServiceInvoiceHeader.SetRange("Customer No.", ServiceHeader."Customer No.");
        ServiceInvoiceHeader.FindFirst();
        ValueEntry.SetRange("Item No.", ServiceLine."No.");
        ValueEntry.SetRange("Document No.", ServiceInvoiceHeader."No.");
        ValueEntry.FindFirst();
        ValueEntry.TestField("Applicable For Serv. Decl.");
        ValueEntry.TestField("Service Transaction Type Code", ServiceLine."Service Transaction Type Code");
    end;

    [Test]
    procedure SalesDocWithResApplicableForServDeclBasicPosting()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResLedgEntry: Record "Res. Ledger Entry";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 456284] Posted entries have service declaration related data after posting sales document with resource

        Initialize();
        LibraryServiceDeclaration.CreateResSalesDocWithServTransTypeCode(SalesHeader, SalesLine);
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsPost();
        ResLedgEntry.SetRange("Resource No.", SalesLine."No.");
        ResLedgEntry.SetRange("Document No.", LibrarySales.PostSalesDocument(SalesHeader, true, true));
        ResLedgEntry.FindFirst();
        ResLedgEntry.TestField("Applicable For Serv. Decl.");
        ResLedgEntry.TestField("Service Transaction Type Code", SalesLine."Service Transaction Type Code");
    end;

    [Test]
    procedure ReleasePurchDocumentWithServTransTypeSpecifiedForAllServDeclApplicableLines()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] Stan can release a purchase document if all lines with "Applicable For Serv. Decl." option have "Service Transaction Type" code specified

        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddPurchDocsCreate();
        LibraryServiceDeclaration.CreatePurchDocWithServTransTypeCode(PurchHeader, PurchLine);
        Codeunit.Run(Codeunit::"Release Purchase Document", PurchHeader);
        PurchHeader.TestField(Status, PurchHeader.Status::Released);
    end;

    [Test]
    procedure CannotReleasePurchDocumentWithServTransTypeNotSpecifiedForAllServDeclApplicableLines()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] Stan cannot release a purchase document if not all lines with "Applicable For Serv. Decl." option have "Service Transaction Type" code specified

        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddPurchDocsCreate();
        LibraryServiceDeclaration.CreatePurchDocApplicableForServDecl(PurchHeader, PurchLine);
        asserterror Codeunit.Run(Codeunit::"Release Purchase Document", PurchHeader);
        Assert.ExpectedError(TransactionTypeCodeNotSpecifiedInLineErr);
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure PurchDocApplicableForServDeclBasicPosting()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        ValueEntry: Record "Value Entry";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] Posted entries have service declaration related data after posting purchase document

        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddPurchDocsPost();
        LibraryServiceDeclaration.CreatePurchDocWithServTransTypeCode(PurchHeader, PurchLine);
        ValueEntry.SetRange("Item No.", PurchLine."No.");
        ValueEntry.SetRange("Document No.", LibraryPurchase.PostPurchaseDocument(PurchHeader, true, true));
        ValueEntry.FindFirst();
        ValueEntry.TestField("Applicable For Serv. Decl.");
        ValueEntry.TestField("Service Transaction Type Code", PurchLine."Service Transaction Type Code");
    end;

    [Test]
    procedure PurchDocWithResApplicableForServDeclBasicPosting()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        ResLedgEntry: Record "Res. Ledger Entry";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 456284] Posted entries have service declaration related data after posting purchase document with resource

        Initialize();
        LibraryServiceDeclaration.CreateResPurchDocWithServTransTypeCode(PurchHeader, PurchLine);
        ResLedgEntry.SetRange("Resource No.", PurchLine."No.");
        ResLedgEntry.SetRange("Document No.", LibraryPurchase.PostPurchaseDocument(PurchHeader, true, true));
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddPurchDocsPost();
        ResLedgEntry.FindFirst();
        ResLedgEntry.TestField("Applicable For Serv. Decl.");
        ResLedgEntry.TestField("Service Transaction Type Code", PurchLine."Service Transaction Type Code");
    end;

    [Test]
    [HandlerFunctions('ItemChargeAssignmentSalesModalPageHandler')]
    procedure SalesDocWithItemChargeApplicableForServDeclBasicPosting()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ValueEntry: Record "Value Entry";
    begin
        // [FEATURE] [Sales] [Item Charge]
        // [SCENARIO 456284] Posted entries have service declaration related data after posting sales document with item charge

        Initialize();
        LibraryServiceDeclaration.CreateItemChargeSalesDocWithServTransTypeCode(SalesHeader, SalesLine);
        Commit();
        LibraryVariableStorage.Enqueue(SalesLine.Quantity);
        SalesLine.ShowItemChargeAssgnt();
        SalesLine.Modify(true);
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsPost();
        ValueEntry.SetRange("Item Charge No.", SalesLine."No.");
        ValueEntry.SetRange("Document No.", LibrarySales.PostSalesDocument(SalesHeader, true, true));
        ValueEntry.FindFirst();
        ValueEntry.TestField("Applicable For Serv. Decl.");
        ValueEntry.TestField("Service Transaction Type Code", SalesLine."Service Transaction Type Code");
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ItemChargeAssignmentPurchModalPageHandler')]
    procedure PurchDocWithItemChargeApplicableForServDeclBasicPosting()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        ValueEntry: Record "Value Entry";
    begin
        // [FEATURE] [Purchase] [item Charge]
        // [SCENARIO 456284] Posted entries have service declaration related data after posting purchase document with item charge

        Initialize();
        LibraryServiceDeclaration.CreateItemChargePurchDocWithServTransTypeCode(PurchHeader, PurchLine);
        Commit();
        LibraryVariableStorage.Enqueue(PurchLine.Quantity);
        PurchLine.ShowItemChargeAssgnt();
        PurchLine.Modify(true);
        ValueEntry.SetRange("Item Charge No.", PurchLine."No.");
        ValueEntry.SetRange("Document No.", LibraryPurchase.PostPurchaseDocument(PurchHeader, true, true));
        ValueEntry.FindFirst();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddPurchDocsPost();
        ValueEntry.TestField("Applicable For Serv. Decl.");
        ValueEntry.TestField("Service Transaction Type Code", PurchLine."Service Transaction Type Code");
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Service Declaration Posting");
        LibrarySetupStorage.Restore();
        LibraryServiceDeclaration.InitServDeclSetup();
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Service Declaration Posting");
        LibrarySetupStorage.Save(Database::"Service Declaration Setup");
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Service Declaration Posting");
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ItemChargeAssignmentSalesModalPageHandler(var ItemChargeAssignmentSales: TestPage "Item Charge Assignment (Sales)")
    begin
        ItemChargeAssignmentSales."Qty. to Assign".SetValue(LibraryVariableStorage.DequeueDecimal());
        ItemChargeAssignmentSales.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ItemChargeAssignmentPurchModalPageHandler(var ItemChargeAssignmentPurchase: TestPage "Item Charge Assignment (Purch)")
    begin
        ItemChargeAssignmentPurchase."Qty. to Assign".SetValue(LibraryVariableStorage.DequeueDecimal());
        ItemChargeAssignmentPurchase.OK().Invoke();
    end;
}