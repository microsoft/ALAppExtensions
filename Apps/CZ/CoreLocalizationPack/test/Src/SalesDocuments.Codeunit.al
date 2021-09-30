codeunit 148098 "Sales Documents CZL"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        GLAccMustBeSameErr: Label 'G/L Accounts must be the same.';
        OppositeSignErr: Label 'Amounts must have the opposite sign.';

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sales Documents CZL");

        LibraryRandom.SetSeed(1);  // Use Random Number Generator to generate the seed for RANDOM function.
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sales Documents CZL");

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sales Documents CZL");
    end;

    [Test]
    procedure RedEntriesFromSalesCorrectionDocuments()
    var
        GLEntry1: Record "G/L Entry";
        GLEntry2: Record "G/L Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedDocumentNo: array[2] of Code[20];
    begin
        Initialize();

        // [GIVEN] The sales invoice has been created.
        CreateSalesDocument(SalesHeader, SalesLine, SalesHeader."Document Type"::Invoice);

        // [GIVEN] The sales invoice has been posted.
        PostedDocumentNo[1] := PostSalesDocument(SalesHeader);

        // [GIVEN] The sales credit memo has been created from posted sales invoice.
        Clear(SalesHeader);
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.Insert(true);
        LibrarySales.CopySalesDocument(SalesHeader, Enum::"Sales Document Type From"::"Posted Invoice", PostedDocumentNo[1], true, false);
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        SalesHeader.Validate("Credit Memo Type CZL", SalesHeader."Credit Memo Type CZL"::"Internal Correction");
        SalesHeader.Validate(Correction, true);
        SalesHeader.Modify(true);

        // [WHEN] Post sales credit memo.
        PostedDocumentNo[2] := PostSalesDocument(SalesHeader);

        // [THEN] The sum of amounts in g/l entries of invoice and credit memo will be zero
        SalesInvoiceHeader.Get(PostedDocumentNo[1]);
        SalesCrMemoHeader.Get(PostedDocumentNo[2]);

        GetGLEntry(GLEntry1, SalesInvoiceHeader."No.", SalesInvoiceHeader."Posting Date");
        GetGLEntry(GLEntry2, SalesCrMemoHeader."No.", SalesCrMemoHeader."Posting Date");

        Assert.IsTrue(
          GLEntry1."G/L Account No." = GLEntry2."G/L Account No.", GLAccMustBeSameErr);
        Assert.IsTrue(
          GLEntry1.Amount + GLEntry2.Amount = 0, OppositeSignErr);
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type")
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup(), 1);
        SalesLine.Validate(Description, SalesHeader."No.");
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10000, 2));
        SalesLine.Modify(true);
    end;

    local procedure GetGLEntry(var GLEntry: Record "G/L Entry"; DocumentNo: Code[20]; PostingDate: Date)
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.FindFirst();
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;
}
