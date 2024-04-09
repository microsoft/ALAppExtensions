codeunit 148008 "Library - Purch. Advances CZZ"
{
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";

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
        PurchaseHeader.Validate("Prices Including VAT", true);
        PurchaseHeader.Modify(true);

        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccount."No.", LibraryRandom.RandIntInRange(2, 10));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(1000, 2));
        PurchaseLine.Modify(true);
    end;

    procedure CreatePurchInvoice(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; VendorNo: Code[20]; PostingDate: Date; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; CurrencyCode: Code[10]; ExchangeRate: Decimal; PricesIncVAT: Boolean; Amount: Decimal)
    begin
        CreatePurchInvoice(PurchaseHeader, PurchaseLine, VendorNo, PostingDate, PostingDate, VATBusPostingGroupCode, VATProdPostingGroupCode, CurrencyCode, ExchangeRate, PricesIncVAT, Amount);
    end;

    procedure CreatePurchInvoice(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; VendorNo: Code[20]; PostingDate: Date; VATDate: Date; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; CurrencyCode: Code[10]; ExchangeRate: Decimal; PricesIncVAT: Boolean; Amount: Decimal)
    var
        GLAccount: Record "G/L Account";
#if not CLEAN22
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#endif
    begin
        CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", VATBusPostingGroupCode);
        GLAccount.Validate("VAT Prod. Posting Group", VATProdPostingGroupCode);
        GLAccount.Modify(true);

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
#if not CLEAN22
        if not ReplaceVATDateMgtCZL.IsEnabled() then
            PurchaseHeader.Validate("VAT Date CZL", VATDate)
        else
#endif
        PurchaseHeader.Validate("VAT Reporting Date", VATDate);
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

    procedure ReleasePurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        Codeunit.Run(Codeunit::"Rel. Purch.Adv.Letter Doc. CZZ", PurchAdvLetterHeaderCZZ);
    end;

    procedure LinkPurchAdvanceLetterToDocument(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; Amount: Decimal; AmountLCY: Decimal)
    var
        LibrarySalesAdvancesCZZ: Codeunit "Library - Sales Advances CZZ";
    begin
        LibrarySalesAdvancesCZZ.LinkAdvanceLetterToDocument(
            Enum::"Advance Letter Type CZZ"::Purchase, PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterHeaderCZZ."Posting Date",
            AdvLetterUsageDocTypeCZZ, DocumentNo, Amount, AmountLCY);
    end;

    procedure LinkPurchAdvancePayment(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        TempAdvanceLetterLinkBufferCZZ: Record "Advance Letter Link Buffer CZZ" temporary;
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        VendorLedgerEntry.CalcFields("Remaining Amount");
        TempAdvanceLetterLinkBufferCZZ.Init();
        TempAdvanceLetterLinkBufferCZZ."Advance Letter Type" := Enum::"Advance Letter Type CZZ"::Purchase;
        TempAdvanceLetterLinkBufferCZZ."CV Ledger Entry No." := VendorLedgerEntry."Entry No.";
        TempAdvanceLetterLinkBufferCZZ."Advance Letter No." := PurchAdvLetterHeaderCZZ."No.";
        TempAdvanceLetterLinkBufferCZZ.Amount := VendorLedgerEntry."Remaining Amount";
        TempAdvanceLetterLinkBufferCZZ.Insert();
        PurchAdvLetterManagementCZZ.LinkAdvancePayment(VendorLedgerEntry, TempAdvanceLetterLinkBufferCZZ, VendorLedgerEntry."Posting Date");
    end;

    procedure UnlinkPurchAdvancePayment(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        PurchAdvLetterManagementCZZ.UnlinkAdvancePayment(PurchAdvLetterEntryCZZ, WorkDate());
    end;

    procedure ApplyPurchAdvanceLetter(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Posted Purchase Invoice", PurchInvHeader."No.",
            PurchAdvLetterHeaderCZZ."Amount Including VAT", PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)");
        PurchAdvLetterManagementCZZ.ApplyAdvanceLetter(PurchInvHeader);
    end;

    procedure UnapplyAdvanceLetter(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        PurchAdvLetterManagementCZZ.UnapplyAdvanceLetter(PurchInvHeader);
    end;

    procedure UnApplyVendLedgEntry(VendLedgEntryNo: Integer)
    var
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
    begin
        VendEntryApplyPostedEntries.UnApplyVendLedgEntry(VendLedgEntryNo);
    end;

    procedure PostPurchAdvancePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        PurchAdvLetterManagementCZZ.PostAdvancePaymentVAT(PurchAdvLetterEntryCZZ, 0D);
    end;

    procedure PostPurchAdvancePaymentUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        PurchAdvLetterManagementCZZ.PostAdvancePaymentUsageVAT(PurchAdvLetterEntryCZZ);
    end;

    procedure ClosePurchAdvanceLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        ClosePurchAdvanceLetter(PurchAdvLetterHeaderCZZ, WorkDate(), WorkDate(), WorkDate(), 0, PurchAdvLetterHeaderCZZ."No.");
    end;

    procedure ClosePurchAdvanceLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostingDate: Date; VATDate: Date; OriginalDocumentVATDate: Date; CurrencyFactor: Decimal; ExternalDocumentNo: Code[35])
    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        PurchAdvLetterManagementCZZ.CloseAdvanceLetter(PurchAdvLetterHeaderCZZ, PostingDate, VATDate, OriginalDocumentVATDate, CurrencyFactor, PurchAdvLetterHeaderCZZ."No.");
    end;

    procedure CreateGLAccount(var GLAccount: Record "G/L Account")
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

    procedure AddAdvLetterAccounsToVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        VATPostingSetup.Validate("Purch. Adv. Letter Account CZZ", GetNewGLAccountNo());
        VATPostingSetup.Validate("Purch. Adv.Letter VAT Acc. CZZ", GetNewGLAccountNo());
        VATPostingSetup.Validate("Purch. VAT Curr. Exch. Acc CZL", GetNewGLAccountNo());
        VATPostingSetup.Modify(true);
    end;

    procedure CreatePurchAdvanceLetterFromOrder(var PurchaseHeader: Record "Purchase Header")
    var
        CreatePurchAdvLetterCZZ: Report "Create Purch. Adv. Letter CZZ";
    begin
        CreatePurchAdvLetterCZZ.SetPurchHeader(PurchaseHeader);
        CreatePurchAdvLetterCZZ.Run();
    end;

    procedure CreatePurchAdvancePayment(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20]; Amount: Decimal; CurrencyCode: Code[10]; AdvanceLetterNo: Code[20]; ExchangeRate: Decimal; PostingDate: Date)
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, VendorNO, Amount);
        if CurrencyCode <> '' then
            GenJournalLine.Validate("Currency Code", CurrencyCode);
        if ExchangeRate <> 0 then
            GenJournalLine.Validate("Currency Factor", GenJournalLine."Currency Factor" * ExchangeRate);
        if PostingDate <> 0D then
            GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Advance Letter No. CZZ", AdvanceLetterNo);
        GenJournalLine.Modify(true);
    end;

    procedure CreatePurchAdvancePayment(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20]; Amount: Decimal; CurrencyCode: Code[10]; AdvanceLetterNo: Code[20]; ExchangeRate: Decimal)
    begin
        CreatePurchAdvancePayment(GenJournalLine, VendorNo, Amount, CurrencyCode, AdvanceLetterNo, ExchangeRate, 0D);
    end;

    procedure PostPurchAdvancePayment(var GenJournalLine: Record "Gen. Journal Line")
    begin
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;
}
