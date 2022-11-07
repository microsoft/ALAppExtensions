codeunit 139904 "Service Declaration Posting"
{
    Subtype = Test;

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
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        Assert: Codeunit Assert;
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

    local procedure Initialize()
    var
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
}