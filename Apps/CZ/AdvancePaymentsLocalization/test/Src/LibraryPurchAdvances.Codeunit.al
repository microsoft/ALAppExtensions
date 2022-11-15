codeunit 148008 "Library - Purch. Advances CZZ"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";

    procedure CreatePurchAdvanceLetterTemplate(var AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ")
    begin
        AdvanceLetterTemplateCZZ.Init();
        AdvanceLetterTemplateCZZ.Validate(Code, CopyStr(LibraryUtility.GenerateRandomCode(
                                          AdvanceLetterTemplateCZZ.FieldNo(Code), Database::"Advance Letter Template CZZ"), 1, MaxStrLen(AdvanceLetterTemplateCZZ.Code)));
        AdvanceLetterTemplateCZZ.Validate("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Purchase);
        AdvanceLetterTemplateCZZ.Validate(Description, AdvanceLetterTemplateCZZ.Code);
        AdvanceLetterTemplateCZZ.Validate("Advance Letter G/L Account", GetNewGLAccountNo());
        AdvanceLetterTemplateCZZ.Validate("Automatic Post VAT Document", true);
        AdvanceLetterTemplateCZZ.Validate("Advance Letter Document Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        AdvanceLetterTemplateCZZ.Validate("Advance Letter Invoice Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        AdvanceLetterTemplateCZZ.Validate("Advance Letter Cr. Memo Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        AdvanceLetterTemplateCZZ.Insert(true);
    end;

    procedure CreatePurchAdvLetterHeader(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; AdvanceLetterCode: Code[20]; VendorNo: Code[20]; CurrencyCode: Code[10])
    begin
        PurchAdvLetterHeaderCZZ.Init();
        PurchAdvLetterHeaderCZZ.Validate("Advance Letter Code", AdvanceLetterCode);
        PurchAdvLetterHeaderCZZ.Insert(true);

        PurchAdvLetterHeaderCZZ.Validate("Pay-to Vendor No.", VendorNo);
        PurchAdvLetterHeaderCZZ.Validate("Posting Date", WorkDate());
        PurchAdvLetterHeaderCZZ.Validate("Document Date", WorkDate());
        if CurrencyCode <> '' then
            PurchAdvLetterHeaderCZZ.Validate("Currency Code", CurrencyCode);
        PurchAdvLetterHeaderCZZ.Validate("Vendor Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.Modify(true);
    end;

    procedure CreatePurchAdvLetterLine(var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; VATProdPostingGroupCode: Code[20]; AmountIncludingVAT: Decimal)
    var
        RecordRef: RecordRef;
    begin
        PurchAdvLetterLineCZZ.Init();
        PurchAdvLetterLineCZZ.Validate("Document No.", PurchAdvLetterHeaderCZZ."No.");
        RecordRef.GetTable(PurchAdvLetterLineCZZ);
        PurchAdvLetterLineCZZ.Validate("Line No.", LibraryUtility.GetNewLineNo(RecordRef, PurchAdvLetterLineCZZ.FieldNo("Line No.")));
        PurchAdvLetterLineCZZ.Insert(true);

        PurchAdvLetterLineCZZ.Validate("VAT Prod. Posting Group", VATProdPostingGroupCode);
        PurchAdvLetterLineCZZ.Validate("Amount Including VAT", AmountIncludingVAT);
        PurchAdvLetterLineCZZ.Modify(true);
    end;

    procedure CreatePurchOrder(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    var
        Vendor: Record Vendor;
        VATPostingSetup: Record "VAT Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        FindVATPostingSetup(VATPostingSetup);

        CreateVendor(Vendor);
        Vendor.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Vendor.Modify(true);

        CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify(true);

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Prepayment %", 100);
        PurchaseHeader.Modify(true);

        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccount."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(1000, 2));
        PurchaseLine.Modify(true);
    end;

    procedure CreatePurchInvoice(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; VendorNo: Code[20]; PostingDate: Date; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; CurrencyCode: Code[10]; ExchangeRate: Decimal; PricesIncVAT: Boolean; Amount: Decimal)
    var
        GLAccount: Record "G/L Account";
    begin
        CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", VATBusPostingGroupCode);
        GLAccount.Validate("VAT Prod. Posting Group", VATProdPostingGroupCode);
        GLAccount.Modify(true);

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Prepayment %", 100);
        PurchaseHeader.Validate("Prices Including VAT", PricesIncVAT);
        if CurrencyCode <> '' then
            PurchaseHeader.Validate("Currency Code", CurrencyCode);
        if ExchangeRate <> 0 then
            PurchaseHeader.Validate("Currency Factor", PurchaseHeader."Currency Factor" * ExchangeRate);
        PurchaseHeader.Modify(true);

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccount."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", Amount);
        PurchaseLine.Modify(true);
    end;

    procedure CreateVendor(var Vendor: Record Vendor)
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        CreateVendorPostingGroup(VendorPostingGroup);
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup.Code);
        Vendor.Modify(true);
    end;

    procedure CreateVendorPostingGroup(var VendorPostingGroup: Record "Vendor Posting Group")
    begin
        VendorPostingGroup.Init();
        VendorPostingGroup.Validate(Code, CopyStr(
            LibraryUtility.GenerateRandomCode(VendorPostingGroup.FieldNo(Code), DATABASE::"Vendor Posting Group"),
            1, MaxStrLen(VendorPostingGroup.Code)));
        VendorPostingGroup.Insert(true);

        VendorPostingGroup.Validate("Payables Account", GetNewGLAccountNo());
        VendorPostingGroup.Validate("Invoice Rounding Account", GetNewGLAccountNo());
        VendorPostingGroup.Validate("Debit Rounding Account", GetNewGLAccountNo());
        VendorPostingGroup.Validate("Credit Rounding Account", GetNewGLAccountNo());
        VendorPostingGroup.Modify(true);
    end;

    local procedure CreateGLAccount(var GLAccount: Record "G/L Account")
    var
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryERM.FindGeneralPostingSetup(GeneralPostingSetup);
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Gen. Posting Type", GLAccount."Gen. Posting Type"::Purchase);
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
        VATPostingSetup.Validate("Purch. Adv. Letter Account CZZ", GetNewGLAccountNo());
        VATPostingSetup.Validate("Purch. Adv.Letter VAT Acc. CZZ", GetNewGLAccountNo());
        VATPostingSetup.Modify(true);
    end;

    procedure CreatePurchAdvancePayment(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20]; Amount: Decimal; CurrencyCode: Code[10]; AdvanceLetterNo: Code[20]; ExchangeRate: Decimal)
    begin
        GenJournalLine.Init();
        GenJournalLine.Validate("Posting Date", WorkDate());
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Vendor);
        GenJournalLine.Validate("Account No.", VendorNo);
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
