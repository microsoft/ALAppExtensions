codeunit 148090 "Compensations CZC"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Compensations]
        isInitialized := false;
    end;

    var
        CompensationsSetupCZC: Record "Compensations Setup CZC";
        Assert: Codeunit Assert;
        LibraryCompensationCZC: Codeunit "Library - Compensation CZC";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        CompensationSourceTypeCZC: Enum "Compensation Source Type CZC";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Compensations CZC");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Compensations CZC");

        CompensationsSetupCZC.Get();
        CompensationsSetupCZC."Compensation Nos." := LibraryERM.CreateNoSeriesCode();
        CompensationsSetupCZC."Compensation Bal. Account No." := LibraryERM.CreateGLAccountNo();
        CompensationsSetupCZC."Compensation Proposal Method" := CompensationsSetupCZC."Compensation Proposal Method"::"Registration No.";
        CompensationsSetupCZC."Max. Rounding Amount" := 1;
        CompensationsSetupCZC."Debit Rounding Account" := LibraryERM.CreateGLAccountNo();
        CompensationsSetupCZC."Credit Rounding Account" := LibraryERM.CreateGLAccountNo();
        CompensationsSetupCZC.Modify();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Compensations CZC");
    end;

    [Test]
    procedure ReleasingCompensationWithCustLedgEntries()
    begin
        ReleasingCompensation(CompensationSourceTypeCZC::Customer);
    end;

    [Test]
    procedure ReleasingCompensationWithVendLedgEntries()
    begin
        ReleasingCompensation(CompensationSourceTypeCZC::Vendor);
    end;

    local procedure ReleasingCompensation(CompensationSourceTypeCZC: Enum "Compensation Source Type CZC")
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        CompensationLineCZC1: Record "Compensation Line CZC";
        CompensationLineCZC2: Record "Compensation Line CZC";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        // [SCENARIO] Compensations Release
        Initialize();

        // [GIVEN] New compensation header has been created
        CreateCompensationHeader(CompensationHeaderCZC, CompensationSourceTypeCZC);

        // [GIVEN] New compensation lines has been created
        case CompensationSourceTypeCZC of
            CompensationLineCZC1."Source Type"::Customer:
                begin
                    FindCustomerLedgerEntryForInvoice(CustLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC1, CompensationHeaderCZC, CompensationSourceTypeCZC, CustLedgerEntry."Entry No.");
                    FindCustomerLedgerEntryForCrMemo(CustLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC2, CompensationHeaderCZC, CompensationSourceTypeCZC, CustLedgerEntry."Entry No.");
                end;
            CompensationLineCZC1."Source Type"::Vendor:
                begin
                    FindVendorLedgerEntryForInvoice(VendorLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC1, CompensationHeaderCZC, CompensationSourceTypeCZC, VendorLedgerEntry."Entry No.");
                    FindVendorLedgerEntryForCrMemo(VendorLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC2, CompensationHeaderCZC, CompensationSourceTypeCZC, VendorLedgerEntry."Entry No.");
                end;
        end;

        // [GIVEN] Compensation lines has been balanced
        if Abs(CompensationLineCZC1."Amount (LCY)") > Abs(CompensationLineCZC2."Amount (LCY)") then
            LibraryCompensationCZC.UpdateCompensationLine(CompensationLineCZC1, -CompensationLineCZC2."Amount (LCY)")
        else
            LibraryCompensationCZC.UpdateCompensationLine(CompensationLineCZC2, -CompensationLineCZC1."Amount (LCY)");

        // [WHEN] Release compensation
        ReleaseCompensation(CompensationHeaderCZC);

        // [THEN] Compensation will be released
        CompensationHeaderCZC.Get(CompensationHeaderCZC."No.");
        CompensationHeaderCZC.TestField(Status, CompensationHeaderCZC.Status::Released);

        // [WHEN] Reopen compensation
        Reopen(CompensationHeaderCZC);

        // [THEN] Compensation will be open
        CompensationHeaderCZC.TestField(Status, CompensationHeaderCZC.Status::Open);
    end;

    [Test]
    procedure PostingCompensationWithCustLedgEntries()
    begin
        PostingCompensation(CompensationSourceTypeCZC::Customer);
    end;

    [Test]
    procedure PostingCompensationWithVendLedgEntries()
    begin
        PostingCompensation(CompensationSourceTypeCZC::Vendor);
    end;

    local procedure PostingCompensation(CompensationSourceTypeCZC: Enum "Compensation Source Type CZC")
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        CompensationLineCZC1: Record "Compensation Line CZC";
        CompensationLineCZC2: Record "Compensation Line CZC";
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        // [SCENARIO] Compensations Posting
        Initialize();

        // [GIVEN] New compensation header has been created
        CreateCompensationHeader(CompensationHeaderCZC, CompensationSourceTypeCZC);

        // [GIVEN] New compensation lines has been created
        case CompensationSourceTypeCZC of
            CompensationLineCZC1."Source Type"::Customer:
                begin
                    FindCustomerLedgerEntryForInvoice(CustLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC1, CompensationHeaderCZC, CompensationSourceTypeCZC, CustLedgerEntry."Entry No.");
                    FindCustomerLedgerEntryForCrMemo(CustLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC2, CompensationHeaderCZC, CompensationSourceTypeCZC, CustLedgerEntry."Entry No.");
                end;
            CompensationLineCZC1."Source Type"::Vendor:
                begin
                    FindVendorLedgerEntryForInvoice(VendorLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC1, CompensationHeaderCZC, CompensationSourceTypeCZC, VendorLedgerEntry."Entry No.");
                    FindVendorLedgerEntryForCrMemo(VendorLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC2, CompensationHeaderCZC, CompensationSourceTypeCZC, VendorLedgerEntry."Entry No.");
                end;
        end;

        // [GIVEN] Compensation lines has been balanced
        if Abs(CompensationLineCZC1."Amount (LCY)") > Abs(CompensationLineCZC2."Amount (LCY)") then
            LibraryCompensationCZC.UpdateCompensationLine(CompensationLineCZC1, -CompensationLineCZC2."Amount (LCY)")
        else
            LibraryCompensationCZC.UpdateCompensationLine(CompensationLineCZC2, -CompensationLineCZC1."Amount (LCY)");

        // [GIVEN] Post compensation
        PostCompensation(CompensationHeaderCZC);

        // [THEN] Posted compensation will exists
        PostedCompensationHeaderCZC.Get(CompensationHeaderCZC."No.");
    end;

    [Test]
    [HandlerFunctions('ModalPageCompensationProposalHandler')]
    procedure AutomaticSuggestCompensationLines()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        CompensationLineCZC: Record "Compensation Line CZC";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedDocNo: array[2] of Code[20];
        Amount: array[2] of Decimal;
    begin
        // [SCENARIO] Suggest Compensation
        Initialize();

        // [GIVEN] New compensation header has been created
        CreateCompensationHeader(CompensationHeaderCZC, CompensationSourceTypeCZC::Customer);

        // [GIVEN] Sales Invoice has been created and posted
        CreateSalesInvoice(SalesHeader, SalesLine, CompensationHeaderCZC."Company No.");
        Amount[1] := SalesLine."Amount Including VAT";
        PostedDocNo[1] := PostSalesDocument(SalesHeader);

        // [GIVEN] Sales Credit Memo has been created and posted
        CreateSalesCreditMemo(SalesHeader, SalesLine, CompensationHeaderCZC."Company No.");
        Amount[2] := SalesLine."Amount Including VAT";
        PostedDocNo[2] := PostSalesDocument(SalesHeader);

        // [WHEN] Suggest compensation lines
        LibraryCompensationCZC.RunSuggestCompensationLines(CompensationHeaderCZC);

        // [THEN] Compensation line to sales credit memo will exist
        CompensationLineCZC.SetRange("Compensation No.", CompensationHeaderCZC."No.");
        CompensationLineCZC.FindSet();
        CompensationLineCZC.TestField("Document Type", CompensationLineCZC."Document Type"::"Credit Memo");
        CompensationLineCZC.TestField("Document No.", PostedDocNo[2]);
        CompensationLineCZC.TestField(Amount, -Amount[2]);

        // [THEN] Compensation line to sales invoice will exists
        CompensationLineCZC.Next();
        CompensationLineCZC.TestField("Document Type", CompensationLineCZC."Document Type"::Invoice);
        CompensationLineCZC.TestField("Document No.", PostedDocNo[1]);
        CompensationLineCZC.TestField(Amount, Amount[1]);
    end;

    [Test]
    [HandlerFunctions('ModalPageCompensationProposalHandler')]
    procedure BlockingEntriesOnReleasedCompensations()
    var
        CompensationHeaderCZC1: Record "Compensation Header CZC";
        CompensationHeaderCZC2: Record "Compensation Header CZC";
        CompensationLineCZC1: Record "Compensation Line CZC";
        CompensationLineCZC2: Record "Compensation Line CZC";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [SCENARIO] Compensations Blocking entries
        Initialize();

        // [GIVEN] Compensation header has been created
        CreateCompensationHeader(CompensationHeaderCZC1, CompensationSourceTypeCZC::Customer);

        // [GIVEN] Sales invoice has been created and posted
        CreateSalesInvoice(SalesHeader, SalesLine, CompensationHeaderCZC1."Company No.");
        PostSalesDocument(SalesHeader);

        // [GIVEN] Sales invoice has been created and posted
        CreateSalesCreditMemo(SalesHeader, SalesLine, CompensationHeaderCZC1."Company No.");
        PostSalesDocument(SalesHeader);

        // [GIVEN] Compensation lines has been suggested
        LibraryCompensationCZC.RunSuggestCompensationLines(CompensationHeaderCZC1);
        CompensationLineCZC1.Get(CompensationHeaderCZC1."No.", 10000);
        CompensationLineCZC2.Get(CompensationHeaderCZC1."No.", 20000);

        // [GIVEN] Compensation lines has been balanced
        if Abs(CompensationLineCZC1."Amount (LCY)") > Abs(CompensationLineCZC2."Amount (LCY)") then
            LibraryCompensationCZC.UpdateCompensationLine(CompensationLineCZC1, -CompensationLineCZC2."Amount (LCY)")
        else
            LibraryCompensationCZC.UpdateCompensationLine(CompensationLineCZC2, -CompensationLineCZC1."Amount (LCY)");

        // [GIVEN] Compensation document has been released
        ReleaseCompensation(CompensationHeaderCZC1);

        // [GIVEN] Compensation header has been created with the same customer
        CreateCompensationHeader(CompensationHeaderCZC2, CompensationSourceTypeCZC::Customer);
        CompensationHeaderCZC2.Validate("Company No.", CompensationHeaderCZC1."Company No.");
        CompensationHeaderCZC2.Modify(false);

        // [WHEN] Suggest compensation lines
        LibraryCompensationCZC.RunSuggestCompensationLines(CompensationHeaderCZC2);

        // [THEN] No compensation line will exist
        CompensationLineCZC2.SetRange("Compensation No.", CompensationHeaderCZC2."No.");
        Assert.AreEqual(0, CompensationLineCZC2.Count(), 'No compensation line was expected for this compensation.');
    end;

    local procedure CreateCompensationHeader(var CompensationHeaderCZC: Record "Compensation Header CZC"; CompensationSourceTypeCZC: Enum "Compensation Source Type CZC")
    begin
        case CompensationSourceTypeCZC of
            CompensationSourceTypeCZC::Customer:
                LibraryCompensationCZC.CreateCompensationHeader(CompensationHeaderCZC, CompensationSourceTypeCZC, LibrarySales.CreateCustomerNo());
            CompensationSourceTypeCZC::Vendor:
                LibraryCompensationCZC.CreateCompensationHeader(CompensationHeaderCZC, CompensationSourceTypeCZC, LibraryPurchase.CreateVendorNo());
        end;
    end;

    local procedure CreateCompensationLine(var CompensationLineCZC: Record "Compensation Line CZC"; CompensationHeaderCZC: Record "Compensation Header CZC";
                                           CompensationSourceTypeCZC: Enum "Compensation Source Type CZC"; SourceEntryNo: Integer)
    begin
        LibraryCompensationCZC.CreateCompensationLine(CompensationLineCZC, CompensationHeaderCZC, CompensationSourceTypeCZC, SourceEntryNo);
    end;

    local procedure CreateGLAccount(var GLAccount: Record "G/L Account"; WithVATPostingSetup: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        GLAccountNo: Code[20];
    begin
        if not WithVATPostingSetup then
            LibraryERM.CreateGLAccount(GLAccount)
        else begin
            LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
            GLAccountNo := LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GLAccount."Gen. Posting Type"::Purchase);
            GLAccount.Get(GLAccountNo);
        end;
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line";
                                        SalesDocumentType: Enum "Sales Document Type"; CustomerNo: Code[20])
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesDocumentType, CustomerNo);
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::"G/L Account", GetNewGLAccountNo(true), 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10000, 2));
        SalesLine.Modify(true);
    end;

    local procedure CreateSalesCreditMemo(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CustomerNo: Code[20])
    begin
        CreateSalesDocument(SalesHeader, SalesLine, SalesHeader."Document Type"::"Credit Memo", CustomerNo);
    end;

    local procedure CreateSalesInvoice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CustomerNo: Code[20])
    begin
        CreateSalesDocument(SalesHeader, SalesLine, SalesHeader."Document Type"::Invoice, CustomerNo);
    end;

    local procedure GetNewGLAccountNo(WithVATPostingSetup: Boolean): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        CreateGLAccount(GLAccount, WithVATPostingSetup);
        exit(GLAccount."No.");
    end;

    local procedure FindCustomerLedgerEntryForInvoice(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        LibraryCompensationCZC.FindCustomerLedgerEntry(CustLedgerEntry, CustLedgerEntry."Document Type"::Invoice);
    end;

    local procedure FindCustomerLedgerEntryForCrMemo(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        LibraryCompensationCZC.FindCustomerLedgerEntry(CustLedgerEntry, CustLedgerEntry."Document Type"::"Credit Memo");
    end;

    local procedure FindVendorLedgerEntryForInvoice(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        LibraryCompensationCZC.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice);
    end;

    local procedure FindVendorLedgerEntryForCrMemo(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        LibraryCompensationCZC.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::"Credit Memo");
    end;

    local procedure PostCompensation(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        LibraryCompensationCZC.RunPostCompensation(CompensationHeaderCZC);
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure ReleaseCompensation(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        LibraryCompensationCZC.RunReleaseCompensation(CompensationHeaderCZC);
    end;

    local procedure Reopen(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        LibraryCompensationCZC.RunReopenCompensation(CompensationHeaderCZC);
    end;

    [ModalPageHandler]
    procedure ModalPageCompensationProposalHandler(var CompensationProposalCZC: TestPage "Compensation Proposal CZC")
    begin
        CompensationProposalCZC.CustLedgEntries.First();
        CompensationProposalCZC.CustLedgEntries.SetMark.Invoke();
        CompensationProposalCZC.CustLedgEntries.Next();
        CompensationProposalCZC.CustLedgEntries.SetMark.Invoke();
        CompensationProposalCZC.OK().Invoke();
    end;
}
