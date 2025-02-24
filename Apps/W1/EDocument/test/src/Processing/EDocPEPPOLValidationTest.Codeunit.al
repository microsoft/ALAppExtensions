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
        EDocImplState: Codeunit "E-Doc. Impl. State";
        LibraryLowerPermission: Codeunit "Library - Lower Permissions";
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
        VATPostingSetup."Tax Category" := 'Z';
        VATPostingSetup."VAT %" := 10;
        VATPostingSetup.Modify(false);

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
        VATPostingSetup."Tax Category" := 'Z';
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(false);

        // [WHEN] Posting invoice
        SalesInvoiceHeader := LibraryEDoc.PostInvoice(Customer);

        // [THEN] Invoice is posted successfully
        Assert.RecordIsNotEmpty(SalesInvoiceHeader);
        // [THEN] E-Document is created
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

}
