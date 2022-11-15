codeunit 148009 "Library - Sales Advances CZZ"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";

    procedure CreateSalesAdvanceLetterTemplate(var AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ")
    begin
        AdvanceLetterTemplateCZZ.Init();
        AdvanceLetterTemplateCZZ.Validate(Code, CopyStr(LibraryUtility.GenerateRandomCode(
                                          AdvanceLetterTemplateCZZ.FieldNo(Code), Database::"Advance Letter Template CZZ"), 1, MaxStrLen(AdvanceLetterTemplateCZZ.Code)));
        AdvanceLetterTemplateCZZ.Validate("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Sales);
        AdvanceLetterTemplateCZZ.Validate(Description, AdvanceLetterTemplateCZZ.Code);
        AdvanceLetterTemplateCZZ.Validate("Advance Letter G/L Account", GetNewGLAccountNo());
        AdvanceLetterTemplateCZZ.Validate("Automatic Post VAT Document", true);
        AdvanceLetterTemplateCZZ.Validate("Advance Letter Document Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        AdvanceLetterTemplateCZZ.Validate("Advance Letter Invoice Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        AdvanceLetterTemplateCZZ.Validate("Advance Letter Cr. Memo Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        AdvanceLetterTemplateCZZ.Insert(true);
    end;

    procedure CreateSalesAdvLetterHeader(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; AdvanceLetterCode: Code[20]; CustomerNo: Code[20]; CurrencyCode: Code[10])
    begin
        SalesAdvLetterHeaderCZZ.Init();
        SalesAdvLetterHeaderCZZ.Validate("Advance Letter Code", AdvanceLetterCode);
        SalesAdvLetterHeaderCZZ.Insert(true);

        SalesAdvLetterHeaderCZZ.Validate("Bill-to Customer No.", CustomerNo);
        SalesAdvLetterHeaderCZZ.Validate("Posting Date", WorkDate());
        SalesAdvLetterHeaderCZZ.Validate("Document Date", WorkDate());
        if CurrencyCode <> '' then
            SalesAdvLetterHeaderCZZ.Validate("Currency Code", CurrencyCode);
        SalesAdvLetterHeaderCZZ.Modify(true);
    end;

    procedure CreateSalesAdvLetterLine(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; VATProdPostingGroupCode: Code[20]; AmountIncludingVAT: Decimal)
    var
        RecordRef: RecordRef;
    begin
        SalesAdvLetterLineCZZ.Init();
        SalesAdvLetterLineCZZ.Validate("Document No.", SalesAdvLetterHeaderCZZ."No.");
        RecordRef.GetTable(SalesAdvLetterLineCZZ);
        SalesAdvLetterLineCZZ.Validate("Line No.", LibraryUtility.GetNewLineNo(RecordRef, SalesAdvLetterLineCZZ.FieldNo("Line No.")));
        SalesAdvLetterLineCZZ.Insert(true);

        SalesAdvLetterLineCZZ.Validate("VAT Prod. Posting Group", VATProdPostingGroupCode);
        SalesAdvLetterLineCZZ.Validate("Amount Including VAT", AmountIncludingVAT);
        SalesAdvLetterLineCZZ.Modify(true);
    end;

    procedure CreateSalesOrder(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        FindVATPostingSetup(VATPostingSetup);

        CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Modify(true);

        CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify(true);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Prepayment %", 100);
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::"G/L Account", GLAccount."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(1000, 2));
        SalesLine.Modify(true);
    end;

    procedure CreateSalesInvoice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CustomerNo: Code[20]; PostingDate: Date; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; CurrencyCode: Code[10]; ExchangeRate: Decimal; PricesIncVAT: Boolean; Amount: Decimal)
    var
        GLAccount: Record "G/L Account";
    begin
        CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", VATBusPostingGroupCode);
        GLAccount.Validate("VAT Prod. Posting Group", VATProdPostingGroupCode);
        GLAccount.Modify(true);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("Prepayment %", 100);
        SalesHeader.Validate("Prices Including VAT", PricesIncVAT);
        if CurrencyCode <> '' then
            SalesHeader.Validate("Currency Code", CurrencyCode);
        if ExchangeRate <> 0 then
            SalesHeader.Validate("Currency Factor", SalesHeader."Currency Factor" * ExchangeRate);
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", GLAccount."No.", 1);
        SalesLine.Validate("Unit Price", Amount);
        SalesLine.Modify(true);
    end;

    procedure CreateCustomer(var Customer: Record Customer)
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        CreateCustomerPostingGroup(CustomerPostingGroup);
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Customer Posting Group", CustomerPostingGroup.Code);
        Customer.Modify(true);
    end;

    procedure CreateCustomerPostingGroup(var CustomerPostingGroup: Record "Customer Posting Group")
    begin
        CustomerPostingGroup.Init();
        CustomerPostingGroup.Validate(Code, CopyStr(
            LibraryUtility.GenerateRandomCode(CustomerPostingGroup.FieldNo(Code), DATABASE::"Customer Posting Group"),
            1, MaxStrLen(CustomerPostingGroup.Code)));
        CustomerPostingGroup.Insert(true);

        CustomerPostingGroup.Validate("Receivables Account", GetNewGLAccountNo());
        CustomerPostingGroup.Validate("Invoice Rounding Account", GetNewGLAccountNo());
        CustomerPostingGroup.Validate("Debit Rounding Account", GetNewGLAccountNo());
        CustomerPostingGroup.Validate("Credit Rounding Account", GetNewGLAccountNo());
        CustomerPostingGroup.Modify(true);
    end;

    local procedure CreateGLAccount(var GLAccount: Record "G/L Account")
    var
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryERM.FindGeneralPostingSetup(GeneralPostingSetup);
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Gen. Posting Type", GLAccount."Gen. Posting Type"::Sale);
        GLAccount.Validate("Gen. Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group");
        GLAccount.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        GLAccount.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify(true);
    end;

    local procedure GetNewGLAccountNo(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        CreateGLAccount(GLAccount);
        exit(GLAccount."No.");
    end;

    procedure FindVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        AddAdvLetterAccounsToVATPostingSetup(VATPostingSetup);
    end;

    procedure FindVATPostingSetupEU(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
        AddAdvLetterAccounsToVATPostingSetup(VATPostingSetup);
    end;

    local procedure AddAdvLetterAccounsToVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
        VATPostingSetup.Validate("Sales Adv. Letter Account CZZ", GetNewGLAccountNo());
        VATPostingSetup.Validate("Sales Adv. Letter VAT Acc. CZZ", GetNewGLAccountNo());
        VATPostingSetup.Modify(true);
    end;

    procedure CreateSalesAdvancePayment(var GenJournalLine: Record "Gen. Journal Line"; CustomerNo: Code[20]; Amount: Decimal; CurrencyCode: Code[10]; AdvanceLetterNo: Code[20]; ExchangeRate: Decimal)
    begin
        GenJournalLine.Init();
        GenJournalLine.Validate("Posting Date", WorkDate());
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Customer);
        GenJournalLine.Validate("Account No.", CustomerNo);
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLine.Validate("Document No.", LibraryRandom.RandText(20));
        GenJournalLine.Validate(Amount, Amount);
        if CurrencyCode <> '' then
            GenJournalLine.Validate("Currency Code", CurrencyCode);
        if ExchangeRate <> 0 then
            GenJournalLine.Validate("Currency Factor", GenJournalLine."Currency Factor" * ExchangeRate);
        GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
        GenJournalLine."Bal. Account No." := LibraryERM.CreateGLAccountNoWithDirectPosting();
        GenJournalLine.Validate("Advance Letter No. CZZ", AdvanceLetterNo);
    end;
}
