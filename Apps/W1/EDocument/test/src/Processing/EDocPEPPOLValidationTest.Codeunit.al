codeunit 139502 "E-Doc. PEPPOL Validation Test"
{
    Subtype = Test;

    var
        Customer: Record Customer;
        EDocumentService: Record "E-Document Service";
        VATPostingSetup: Record "VAT Posting Setup";
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibrarySales: Codeunit "Library - Sales";
        EDocImplState: Codeunit "E-Doc. Impl. State";
        LibraryLowerPermission: Codeunit "Library - Lower Permissions";
        Any: Codeunit Any;
        IsInitialized: Boolean;


    [Test]
    procedure PostInvoiceWithZeroVatAmountCategoryAndNonZeroVat()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [FEATURE] [E-Document] [Processing]
        // [SCENARIO] Post invoice with zero VAT amount category and non-zero VAT %
        Initialize();

        // [GIVEN] VAT Posting Setup with zero VAT amount category and non-zero VAT %
        SetVatPostingSetupTaxCategory('Z', 10);

        // [WHEN] Posting invoice
        asserterror SalesInvoiceHeader := LibraryEDoc.PostInvoice(Customer);

        // [THEN] Error is raised
        Assert.ExpectedError('VAT % must be 0 for tax category code Z');
    end;

    [Test]
    procedure PostInvoiceWithZeroVatAmountCategoryAndZeroVat()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EDocument: Record "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing]
        // [SCENARIO] Post invoice with zero VAT amount category and zero VAT %
        Initialize();

        // [GIVEN] VAT Posting Setup with zero VAT amount category and zero VAT %
        SetVatPostingSetupTaxCategory('Z', 0);

        // [WHEN] Posting invoice
        SalesInvoiceHeader := LibraryEDoc.PostInvoice(Customer);

        // [THEN] Invoice is posted successfully
        Assert.RecordIsNotEmpty(SalesInvoiceHeader);
        // [THEN] E-Document is created
        EDocument.SetRange("Document Record ID", SalesInvoiceHeader.RecordId());
        Assert.IsFalse(EDocument.IsEmpty(), 'No E-Document created');
    end;

    [Test]
    procedure PostInvoiceWithStandardVatAmountCategoryAndNonZeroVat()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EDocument: Record "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing]
        // [SCENARIO] Post invoice with standard VAT amount category and non-zero VAT %
        Initialize();

        // [GIVEN] VAT Posting Setup with standard VAT amount category and non-zero VAT %
        SetVatPostingSetupTaxCategory('S', 25);

        // [WHEN] Posting invoice
        SalesInvoiceHeader := LibraryEDoc.PostInvoice(Customer);

        // [THEN] Invoice is posted successfully
        Assert.RecordIsNotEmpty(SalesInvoiceHeader);
        // [THEN] E-Document is created
        EDocument.SetRange("Document Record ID", SalesInvoiceHeader.RecordId());
        Assert.IsFalse(EDocument.IsEmpty(), 'No E-Document created');
    end;

    [Test]
    procedure TestPostInvoiceWithStandardVatAmountCategoryAndZeroVat()
    begin
        // [FEATURE] [E-Document] [Processing]
        // [SCENARIO] Attempt to post invoice with standard VAT category and 0% VAT should fail
        Initialize();

        // [GIVEN] VAT Posting Setup with standard VAT amount category and zero VAT %
        SetVatPostingSetupTaxCategory('S', 0);

        // [WHEN] Posting invoice
        asserterror LibraryEDoc.PostInvoice(Customer);

        // [THEN] Error is raised
        Assert.ExpectedError('Line should have greater VAT than 0% for tax category S');
    end;

    [Test]
    procedure PostInvoiceWithOutsideVatScopeAndTwoDifferentVatAmountLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        ItemWithTaxGroup: Record Item;
    begin
        // [FEATURE] [E-Document] [Processing]
        // [SCENARIO] Post invoice with outside VAT scope and two different VAT amount lines
        Initialize();

        // [GIVEN] VAT Posting Setup with outside VAT scope
        SetVatPostingSetupTaxCategory('O', 0);
        // [GIVEN] Item
        LibraryEDoc.GetGenericItem(Item);
        // [GIVEN] Second item with different Tax Group code than first item
        CreateItemWithTaxGroup(ItemWithTaxGroup, Any.AlphanumericText(20));
        // [GIVEN] Sales invoice with both items
        LibraryEDoc.CreateSalesHeaderWithItem(Customer, SalesHeader, Enum::"Sales Document Type"::Invoice);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, ItemWithTaxGroup."No.", 1);

        // [WHEN] Posting invoice
        asserterror LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [THEN] Error is raised
        Assert.ExpectedError('There can be only one tax subtotal present on invoice used with "Not subject to VAT" (O) tax category.');
    end;

    [Test]
    procedure PostInvoiceWithOutsideVatScopeAndTwoDifferentItemsNoCustomTaxGroup()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        SecondItem: Record Item;
        EDocument: Record "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing]
        // [SCENARIO] Post invoice with outside VAT scope and two items without different Tax Group
        Initialize();

        // [GIVEN] VAT Posting Setup with outside VAT scope
        SetVatPostingSetupTaxCategory('O', 0);
        // [GIVEN] First item
        LibraryEDoc.GetGenericItem(Item);
        // [GIVEN] Second item without custom Tax Group
        CreateItemWithTaxGroup(SecondItem, Item."Tax Group Code");
        // [GIVEN] Sales invoice with both items
        LibraryEDoc.CreateSalesHeaderWithItem(Customer, SalesHeader, Enum::"Sales Document Type"::Invoice);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, SecondItem."No.", 1);

        // [WHEN] Posting invoice
        SalesInvoiceHeader := LibraryEDoc.PostInvoice(Customer);

        // [THEN] Invoice is posted successfully and E-Document created
        Assert.RecordIsNotEmpty(SalesInvoiceHeader);
        EDocument.SetRange("Document Record ID", SalesInvoiceHeader.RecordId());
        Assert.IsFalse(EDocument.IsEmpty(), 'No E-Document created');
    end;

    local procedure Initialize()
    var
        TransformationRule: Record "Transformation Rule";
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        LibraryWorkflow: Codeunit "Library - Workflow";
    begin
        LibraryLowerPermission.SetOutsideO365Scope();
        LibraryVariableStorage.Clear();
        Clear(EDocImplState);

        if IsInitialized then
            exit;

        EDocument.DeleteAll();
        EDocumentServiceStatus.DeleteAll();
        EDocumentService.DeleteAll();

        LibraryEDoc.SetupStandardVAT();
        LibraryEDoc.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::"No Integration");
        VATPostingSetup := LibraryEDoc.GetVatPostingSetup();

        TransformationRule.DeleteAll();
        TransformationRule.CreateDefaultTransformations();
        LibraryWorkflow.SetUpEmailAccount();

        IsInitialized := true;
    end;

    local procedure CreateItemWithTaxGroup(var Item: Record Item; TaxGroupCode: Code[20])
    begin
        LibraryEDoc.CreateGenericItem(Item);
        Item."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        Item."Tax Group Code" := TaxGroupCode;
        Item.Modify(false);
    end;

    local procedure SetVatPostingSetupTaxCategory(TaxCategryCode: Code[10]; VATPercent: Decimal)
    begin
        VATPostingSetup."Tax Category" := TaxCategryCode;
        VATPostingSetup."VAT %" := VATPercent;
        VATPostingSetup.Modify(false);
    end;
}
