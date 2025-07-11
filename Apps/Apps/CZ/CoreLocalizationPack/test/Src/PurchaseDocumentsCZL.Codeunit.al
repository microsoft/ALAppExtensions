codeunit 148095 "Purchase Documents CZL"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        GLAccMustBeSameErr: Label 'G/L Accounts must be the same.';
        OppositeSignErr: Label 'Amounts must have the opposite sign.';

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Purchase Documents CZL");

        LibraryRandom.SetSeed(1);  // Use Random Number Generator to generate the seed for RANDOM function.
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Purchase Documents CZL");

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Purchase Documents CZL");
    end;

    [Test]
    procedure RedEntriesFromPurchaseCorrectionDocuments()
    var
        GLEntry1: Record "G/L Entry";
        GLEntry2: Record "G/L Entry";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchInvHeader: Record "Purch. Inv. Header";
        PostedDocumentNo: array[2] of Code[20];
    begin
        Initialize();

        // [GIVEN] The purchase invoice has been created.
        CreatePurchaseDocument(PurchaseHeader, PurchaseLine, PurchaseHeader."Document Type"::Invoice);

        // [GIVEN] The purchase invoice has been posted.
        PostedDocumentNo[1] := PostPurchaseDocument(PurchaseHeader);

        // [GIVEN] The purchase credit memo has been created from posted sales invoice.
        Clear(PurchaseHeader);
        PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseHeader.Insert(true);
        LibraryPurchase.CopyPurchaseDocument(PurchaseHeader, Enum::"Purchase Document Type From"::"Posted Invoice", PostedDocumentNo[1], true, false);
        PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Validate(Correction, true);
        PurchaseHeader.Modify(true);

        // [WHEN] Post purchase created credit memo
        PostedDocumentNo[2] := PostPurchaseDocument(PurchaseHeader);

        // [THEN] The sum of amounts in g/l entries of invoice and credit memo will be zero
        PurchInvHeader.Get(PostedDocumentNo[1]);
        PurchCrMemoHdr.Get(PostedDocumentNo[2]);

        GetGLEntry(GLEntry1, PurchInvHeader."No.", PurchInvHeader."Posting Date");
        GetGLEntry(GLEntry2, PurchCrMemoHdr."No.", PurchCrMemoHdr."Posting Date");

        Assert.IsTrue(
          GLEntry1."G/L Account No." = GLEntry2."G/L Account No.", GLAccMustBeSameErr);
        Assert.IsTrue(
          GLEntry1.Amount + GLEntry2.Amount = 0, OppositeSignErr);
    end;

    local procedure CreatePurchaseDocument(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type")
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate(Description, PurchaseHeader."No.");
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(10000, 2));
        PurchaseLine.Modify(true);
    end;

    local procedure GetGLEntry(var GLEntry: Record "G/L Entry"; DocumentNo: Code[20]; PostingDate: Date)
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.FindFirst();
    end;

    local procedure PostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;
}
