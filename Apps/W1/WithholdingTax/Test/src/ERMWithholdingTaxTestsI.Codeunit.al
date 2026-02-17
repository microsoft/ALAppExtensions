// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Tests.WithholdingTax;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.WithholdingTax;

codeunit 148321 "ERM Withholding Tax Tests I"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = Uncategorized;

    trigger OnRun()
    begin
        // [FEATURE] [Withholding Tax]
        IsInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryWithholdingTax: Codeunit "Library - Withholding Tax";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        AmountErr: Label '%1 must be %2.', Comment = '%1 = Field Caption, %2 = Field Value';
        GreaterThanErr: Label '>%1', Comment = '%1 = Field Value';
        LesserThanErr: Label '<%1', Comment = '%1 = Field Value';
        WithoutAppliedIdErr: Label 'Cannot post the payment journal because one or more journal lines must be applied to an invoice line when the Withholding Tax Realized Type Payment';
        IncorrectFieldValueErr: Label 'Incorrect value of %1 in WHT Entry.', Comment = '%1 = Field Caption';
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTPaymentJournalWithoutAppliedIdPostingErr()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 285194] Test to verify Error While Posting WHT Cash Receipt Journal Without Applied to Id.
        Initialize();

        // [GIVEN] Create Vendor.
        WHTGeneralJournalLineWithoutAppliedIdPostingErr(
          GenJournalLine."Account Type"::Vendor, LibraryRandom.RandDec(10, 2));  // Blank VAT Business Posting Group, Random as Amount.
    end;

    local procedure WHTGeneralJournalLineWithoutAppliedIdPostingErr(AccountType: Enum "Gen. Journal Account Type"; Amount: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        VendorNo: Code[20];
    begin
        UpdateGeneralLedgerSetup(true, false);  //  Round Amount for WHT Calc and True as Enable WHT.
        CreateWHTPostingSetup(WHTPostingSetup);
        VendorNo := CreateVendorWithPostingGroup('', WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        CreateGeneralJournalLineWithCurrency(
          GenJournalLine, WHTPostingSetup, AccountType, GenJournalLine."Document Type"::Payment, VendorNo, '', '', Amount);  // Blank as Applies To Doc No and Currency Code.

        // [WHEN] Post Payment Journal with WHT.
        asserterror LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify Error While Posting WHT General Journal Without Applied to Id.
        Assert.ExpectedError(WithoutAppliedIdErr);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTEntryOnPostedPurchaseInvoiceWithWHT()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO 285194] Test to verify after Posting Purchase Invoice with WHT, WHT Entry - Unrealized Amount, Unrealized Base and G/L Entry - Amount correctly calculated.
        Initialize();
        WHTEntryOnPostedPurchaseDocumentWithWHT(PurchaseHeader."Document Type"::Invoice);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTEntryOnPostedPurchaseCreditMemoWithWHT()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO 285194] Test to verify after Posting Purchase Credit Memo with WHT, WHT Entry - Unrealized Amount, Unrealized Base and G/L Entry - Amount correctly calculated.
        Initialize();
        WHTEntryOnPostedPurchaseDocumentWithWHT(PurchaseHeader."Document Type"::"Credit Memo");
    end;

    local procedure WHTEntryOnPostedPurchaseDocumentWithWHT(DocumentType: Enum "Purchase Document Type")
    var
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Create G/L Account and WHT Posting Setup.
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);

        // [WHEN] Create and Post Purchase Document with WHT.
        DocumentNo :=
          CreateAndPostPurchaseDocumentWithWHT(PurchaseLine, WHTPostingSetup, DocumentType,
            CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group"),
            CreateGLAccount(VATPostingSetup."VAT Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), '');  // Blank Currency Code.

        // [THEN] Verify WHT Entry - Unrealized Amount, Unrealized Base and G/L Entry - Amount.
        VerifyWHTEntriesAndGLEntry(
          DocumentNo, VATPostingSetup."Purchase VAT Account", FindLineAmount(DocumentType, -PurchaseLine."Line Amount"),
          WHTPostingSetup."Withholding Tax %", VATPostingSetup."VAT %", 0);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTEntryOnPostedPurchasePaymentJournalWithWHT()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        VendorNo: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 285194] Test to verify after Posting Payment Journal with WHT, WHT Entry - Amount,Base and G/L Entry - Amount correctly calculated.
        Initialize();

        // [GIVEN] Create Payment Journal with WHT and apply Posted Purchase Invoice.
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        VendorNo := CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        PostedInvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHT(PurchaseLine, WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccount(VATPostingSetup."VAT Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), '');  // Blank Currency Code.
        CreateGeneralJournalLineWithCurrency(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, PostedInvoiceNo, '', PurchaseLine."Amount Including VAT" + 1);

        // [WHEN] Post Payment Journal with WHT.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify WHT Entry - Amount, Base And G/L Entry - Amount.
        VerifyGeneralLedgerAndWHTEntry(
          PurchaseHeader."Document Type"::Invoice, GenJournalLine."Document No.", WHTPostingSetup."Payable Wthldg. Tax Acc. Code",
          -PurchaseLine."Line Amount", WHTPostingSetup."Withholding Tax %");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure PaymentJournalAppliedWithCurrencyAndWHT()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        BankAccountLEAmount: Decimal;
        CurrencyCode: Code[10];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 285194] Test to verify after Posting Payment Journal with Currency and WHT, Bank Ledger Entry - Amount and Bank Account Number correctly calculated.
        Initialize();

        // [GIVEN] Create Payment Journal with Currency Code and WHT and apply Posted Purchase Invoice.
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        CurrencyCode := CreateCurrencyWithExchangeRate();
        PostedInvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHT(
            PurchaseLine, WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group"),
            CreateGLAccount(VATPostingSetup."VAT Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), CurrencyCode);

        BankAccountLEAmount := PurchaseLine."Line Amount" *
          (1 - (GetWHTEntryAmount(PostedInvoiceNo) / PurchaseLine."Amount Including VAT") * WHTPostingSetup."Withholding Tax %" / 100);

        CreateGeneralJournalLineWithCurrency(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          PurchaseLine."Buy-from Vendor No.", PostedInvoiceNo, CurrencyCode, PurchaseLine."Line Amount");

        // [WHEN] Post Payment Journal with WHT.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify Bank Account Ledger Entry - Amount, Bank Account Number.
        VerifyAmountOnBankLedgerEntry(GenJournalLine."Document No.", -BankAccountLEAmount, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostedPurchaseUnrealizedAmountAndBaseOnWHTEntry()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        WHTAmount: Decimal;
        DocumentNo: Code[20];
    begin
        // [SCENARIO 285194] To verify after Posting Purchase Invoice with WHT, WHT Entry - Unrealized Amount and Unrealized Base correctly calculated.
        Initialize();

        // [GIVEN] Create Purchase Invoice with WHT.
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        CreatePurchaseDocument(
          PurchaseLine, WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
          CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group"),
          CreateGLAccount(VATPostingSetup."VAT Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), '');  // Blank Currency Code.
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        WHTAmount := PurchaseLine.Amount * WHTPostingSetup."Withholding Tax %" / 100;

        // [WHEN] Post Purchase Invoice.
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify WHT Entry - Unrealized Amount, Unrealized Base.
        VerifyUnrealizedAmountAndBaseOnWHTEntry(DocumentNo, WHTAmount, PurchaseLine.Amount, WHTAmount, PurchaseLine.Amount, false);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostedPaymentJournalAmountOnGLEntry()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        WHTAmount: Decimal;
        VendorNo: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 285194] after Posting Payment Journal with WHT, G/L Entry - Amount on Post Payment Journal correctly calculated.
        Initialize();

        // [GIVEN] Create Payment Journal with WHT and apply Posted Purchase Invoice.
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        VendorNo := CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        PostedInvoiceNo :=
          PostedPurchaseInvoiceLCY(PurchaseLine, VATPostingSetup, WHTPostingSetup, VendorNo);

        CreateGeneralJournalLineWithCurrency(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment, VendorNo,
          PostedInvoiceNo, '', PurchaseLine."Amount Including VAT" + 1);

        // [WHEN] Post Payment Journal.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify G/L Entry - Amount on Posted Payment Journal.
        WHTAmount := Round(WHTPostingSetup."Withholding Tax %" * PurchaseLine."Line Amount" / 100, 0.01, '=');  // Rounded down to nearest value.
        VerifyAmountOnGLEntry(GenJournalLine."Document No.", WHTPostingSetup."Payable Wthldg. Tax Acc. Code", -WHTAmount);
        VerifyPostedGenJournalLineAmountOnGLEntry(
          GenJournalLine."Document No.", GenJournalLine."Account Type"::Vendor, GenJournalLine."Account No.", LesserThanErr,
          -(GenJournalLine.Amount - WHTAmount));
    end;

    local procedure UnapplyVendorLedgerEntryAmount(CurrencyCode: Code[10])
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        WHTAmount: Decimal;
        PostedInvoiceNo, VendorNo : Code[20];
    begin
        // [GIVEN] Create Payment Journal with WHT and apply Posted Purchase Invoice.
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        PostedInvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHT(
            PurchaseLine, WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo,
            CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), CurrencyCode);
        CreateGeneralJournalLineWithCurrency(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          PurchaseLine."Buy-from Vendor No.", PostedInvoiceNo, CurrencyCode, PurchaseLine."Amount Including VAT");  // Random as Amount.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        UnapplyVendorLedgerEntry(GenJournalLine."Document No.");

        // [WHEN] Reapply Vendor Ledger Entry.
        ApplyAndPostVendorEntryApplication(GenJournalLine."Document Type"::Payment, GenJournalLine."Document No.");

        // [THEN] Verify Unapplied Vendor Ledger Entry Amount on G/L Entry.
        WHTAmount := Round((PurchaseLine."Line Amount" / FindCurrencyFactor(CurrencyCode)) * WHTPostingSetup."Withholding Tax %" / 100, 0.01, '=');
        VerifyPostedGenJournalLineAmountOnGLEntry(
          GenJournalLine."Document No.", GenJournalLine."Bal. Account Type"::"G/L Account", '', GreaterThanErr, WHTAmount);  // Blank - Bal. Account No.
        VerifyPostedGenJournalLineAmountOnGLEntry(
          GenJournalLine."Document No.", GenJournalLine."Bal. Account Type"::"G/L Account", '', LesserThanErr, -WHTAmount);  // Blank - Bal. Account No.
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure MultipleGenJournalWithDiffAccountTypeAmountOnGLEntry()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        Amount: Decimal;
        Amount2: Decimal;
        CurrencyCode: Code[10];
        GLAccountNo: Code[20];
        VendorNo: Code[20];
    begin
        // [SCENARIO 285194] Test to verify after Running Additional Currency Report, Posted multiple Payment Journal with different Account Type and WHT, currency. Posted General Journal Line Amount on G/L Entry correctly calculated.
        Initialize();
        // [GIVEN] Create multiple Payment Journal with different Account Type.
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        CurrencyCode := CreateCurrencyWithExchangeRate();
        UpdateAdditionalCurrency(CurrencyCode);
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup, LibraryRandom.RandIntInRange(10, 20));
        GLAccountNo := CreateGLAccount(VATPostingSetup."VAT Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");
        UpdateVATBusPostingGroupOnGLAccount(GLAccountNo, VATPostingSetup."VAT Bus. Posting Group");
        VendorNo := CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        CreateGeneralJournalLineWithCurrency(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Invoice,
          VendorNo, '', CurrencyCode, -LibraryRandom.RandDecInRange(1, 10, 2));  // Random as Amount and Blank Applies To Doc No.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        Amount := LibraryRandom.RandDecInRange(10, 50, 2);
        Amount2 := -LibraryRandom.RandDecInRange(100, 500, 2);
        CreateMultipleGeneralJnlLine(
          GenJournalLine2, WHTPostingSetup, VendorNo, GenJournalLine."Bal. Account No.", GenJournalLine."Document No.",
          GLAccountNo, CurrencyCode, -GenJournalLine.Amount, Amount, Amount2);

        // [WHEN] Post General Journal Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine2);

        // [THEN] Verify Posted General Journal Line Amount on multiple G/L Entries.
        VerifyAmountOnGLEntries(GenJournalLine, GenJournalLine2."Document No.", GLAccountNo, Amount, Amount2);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure PaymentJournalWithCurrency()
    var
        GenJournalLine: Record "Gen. Journal Line";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        BankAccount: Record "Bank Account";
        CurrencyCode: Code[10];
    begin
        // [SCENARIO 285194] Post Gen. Jnl Line in FCY with WHT Enabled. Check Bank Account Ledger entries not influenced by WHT.
        Initialize();
        // [GIVEN] Enabled WHT
        UpdateGeneralLedgerSetup(true, false);
        CreateWHTPostingSetup(WHTPostingSetup);
        // [GIVEN] Bank Account with Currency
        CurrencyCode := CreateCurrencyWithExchangeRate();
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Currency Code", CurrencyCode);
        // [GIVEN] Gen. Jnl Line from FCY Bank Account to LCY Bank Account
        CreateGeneralJournalLineWithCurrency(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::"Bank Account", GenJournalLine."Document Type"::" ",
          BankAccount."No.", '', CurrencyCode, LibraryRandom.RandDec(100, 2));

        // [WHEN] User posts Gen. Journal Line
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] 2 Bank Account Ledger entries created (FCY & LCY). WHT is not taken into account.
        VerifyAmountOnBankLedgerEntry(
          GenJournalLine."Document No.",
          LibraryERM.ConvertCurrency(GenJournalLine.Amount, CurrencyCode, '', WorkDate()),
          GenJournalLine."Account No.");
        VerifyAmountOnBankLedgerEntry(GenJournalLine."Document No.", -GenJournalLine.Amount, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTEntriesPartialPurchAppliesToID()
    var
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorNo: Code[20];
        GLAccountNo: Code[20];
        CrMemoNo: Code[20];
        InvoiceNo: Code[20];
        Index: Decimal;
        WHTAmount: Decimal;
        CrMemoWHTAmount: Decimal;
    begin
        // [SCENARIO 285194] Remaining Unrealized WHT Amount decreased by applying partial Purchase Credit Memo with "Applies-to ID"
        Initialize();

        // [GIVEN] Initial setting with WHT enabled
        InitScenarioForWHTApplication(WHTPostingSetup, VendorNo, GLAccountNo);

        // [GIVEN] Posted Purchase Invoice with WHT Amount = "X"
        InvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHT(
            PurchaseLine, WHTPostingSetup, PurchaseLine."Document Type"::Order, VendorNo, GLAccountNo, '');

        // [GIVEN] Credit Memo with WHT and partial Amount "Y" = "X" / 2. Set "Applies-to ID" to Invoice and Credit Memo
        Index := 1 / LibraryRandom.RandIntInRange(2, 4);
        CreatePurchaseDocumentWithWHTWithAppliesToID(PurchaseHeader,
          WHTPostingSetup, PurchaseLine."Document Type"::"Credit Memo", VendorNo, GLAccountNo, '', InvoiceNo,
          PurchaseLine.Quantity, PurchaseLine."Direct Unit Cost" * Index);

        WHTAmount := PurchaseLine.Amount * WHTPostingSetup."Withholding Tax %" / 100;
        CrMemoWHTAmount := -WHTAmount * Index;

        // [WHEN] Post Purchase Credit Memo
        CrMemoNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Invoice WHT Entry is Opened: "Remaining Unrealized Amount", "Remaining Unrealized Base" are descreased by Cr.Memo Amount/Base
        VerifyUnrealizedAmountAndBaseOnWHTEntry(
          InvoiceNo, WHTAmount, PurchaseLine.Amount, WHTAmount * (1 - Index), PurchaseLine.Amount * (1 - Index), false);
        // [THEN] Cr.Memo WHT Entry is Closed: Remaining Amounts = 0.
        VerifyUnrealizedAmountAndBaseOnWHTEntry(
          CrMemoNo, CrMemoWHTAmount, -PurchaseLine.Amount * Index, 0, 0, true);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTEntriesPartialPurchAppliesToDocNo()
    var
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        GLAccountNo: Code[20];
        InvoiceNo: Code[20];
        CrMemoNo: Code[20];
        Index: Decimal;
        WHTAmount: Decimal;
        CrMemoWHTAmount: Decimal;
        InvoiceAmount: Decimal;
    begin
        // [SCENARIO 285194] Remaining Unrealized WHT Amount decreased by applying partial Purchase Credit Memo with "Applies-to Doc. No."
        Initialize();

        // [GIVEN] Initial setting with WHT enabled
        InitScenarioForWHTApplication(WHTPostingSetup, VendorNo, GLAccountNo);

        // [GIVEN] Posted Purchase Invoice with WHT Amount = "X"
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        InvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHTAndAmount(
            WHTPostingSetup, PurchaseHeader."Document Type"::Order, VendorNo, GLAccountNo, InvoiceAmount);

        // [GIVEN] Purchase Credit Memo with WHT and partial Amount "Y" = "X" / 2. Posted Invoice is set as "Applies-to Doc. No.".
        // [WHEN] Post Purchase Credit Memo.
        Index := 1 / LibraryRandom.RandIntInRange(2, 4);
        CrMemoNo :=
          CreateAndPostPurchaseDocumentWithWHTAndAppliesToDocNo(
            WHTPostingSetup, PurchaseHeader."Document Type"::"Credit Memo", VendorNo, GLAccountNo, InvoiceNo, 1, InvoiceAmount * Index);

        WHTAmount := InvoiceAmount * WHTPostingSetup."Withholding Tax %" / 100;
        CrMemoWHTAmount := -WHTAmount * Index;

        // [THEN] Invoice WHT Entry is Opened: "Remaining Unrealized Amount", "Remaining Unrealized Base" are descreased by Cr.Memo Amount/Base
        VerifyUnrealizedAmountAndBaseOnWHTEntry(
          InvoiceNo, WHTAmount, InvoiceAmount, WHTAmount * (1 - Index), InvoiceAmount * (1 - Index), false);
        // [THEN] Cr.Memo WHT Entry is Closed: Remaining Amounts = 0.
        VerifyUnrealizedAmountAndBaseOnWHTEntry(
          CrMemoNo, CrMemoWHTAmount, -InvoiceAmount * Index, 0, 0, true);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure PurchaseCrMemoMultiplePartialAppln()
    var
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        PurchaseLine: Record "Purchase Line";
        VendorNo: Code[20];
        GLAccountNo: Code[20];
        CrMemoNo: Code[20];
        InvoiceNo: array[2] of Code[20];
        Index: Decimal;
        CrMemoWHTAmount: Decimal;
        InvAmounts: array[2, 2] of Decimal;
        WHTAmount: array[2] of Decimal;
    begin
        // [SCENARIO 285194] Remaining Unrealized WHT Amounts for several Inoices decreased by applying partial Purchase Credit Memo with "Applies-to ID"
        Initialize();
        Index := 1 / LibraryRandom.RandIntInRange(2, 4);
        // [GIVEN] Initial setting with WHT enabled
        InitScenarioForWHTApplication(WHTPostingSetup, VendorNo, GLAccountNo);
        // [GIVEN] Posted Purchase Invoice PI1
        InvoiceNo[1] :=
          CreateAndPostPurchaseDocumentWithWHT(
            PurchaseLine, WHTPostingSetup, PurchaseLine."Document Type"::Invoice, VendorNo, GLAccountNo, '');
        InvAmounts[1] [1] := PurchaseLine.Amount;
        InvAmounts[1] [2] := PurchaseLine."Amount Including VAT";
        WHTAmount[1] := Round(InvAmounts[1] [1] * WHTPostingSetup."Withholding Tax %" / 100);
        // [GIVEN] Posted Purchase Invoice PI2
        InvoiceNo[2] :=
          CreateAndPostPurchaseDocumentWithWHT(
            PurchaseLine, WHTPostingSetup, PurchaseLine."Document Type"::Invoice, VendorNo, GLAccountNo, '');
        InvAmounts[2] [1] := PurchaseLine.Amount;
        InvAmounts[2] [2] := PurchaseLine."Amount Including VAT";
        WHTAmount[2] := Round(InvAmounts[2] [1] * WHTPostingSetup."Withholding Tax %" / 100);
        // [WHEN] Post Purchase Credit Memo with amount less than
        CrMemoNo :=
          CreateAndPostPurchCrMemoWithMultiplePartialAppln(
            PurchaseLine, WHTPostingSetup, VendorNo, GLAccountNo, InvoiceNo, InvAmounts, Index);
        CrMemoWHTAmount := Round(PurchaseLine.Amount * WHTPostingSetup."Withholding Tax %" / 100);
        // [THEN] Credit Memo WHT Entry Closed = TRUE, Remaining Amounts = 0
        // don't check Credit Memo WHT Entry is Closed due to rounding issues
        VerifyCrMemoUnrealizedAmountAndBaseOnWHTEntry(CrMemoNo, -CrMemoWHTAmount, -PurchaseLine.Amount, 0, 0);
        // [THEN] PI1 WHT Entry Closed = FALSE, Remaining Amounts decreased at Credit Memo amounts in index proportion
        VerifyUnrealizedAmountAndBaseOnWHTEntry(
          InvoiceNo[1], WHTAmount[1], InvAmounts[1] [1], WHTAmount[1] * (1 - Index), InvAmounts[1] [1] * (1 - Index), false);
        // [THEN] PI2 WHT Entry Closed = FALSE, Remaining Amounts decreased at Credit Memo amounts in index proportion
        VerifyUnrealizedAmountAndBaseOnWHTEntry(
          InvoiceNo[2], WHTAmount[2], InvAmounts[2] [1], WHTAmount[2] * (1 - Index), InvAmounts[2] [1] * (1 - Index), false);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure TFS376116_Inconsistent()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        VendorNo: Code[20];
        InvoiceNo: array[3] of Code[20];
        PaymentNo: Code[20];
        AppliedAmount: array[3] of Decimal;
    begin
        // [FEATURE] [Purchase] [Apply]
        // [SCENARIO 285194] WHT Entries should be aligned with G/l Entries on partial application one to many.
        Initialize();
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        WHTPostingSetup."Withholding Tax %" := 3;
        WHTPostingSetup.Modify();
        VendorNo := CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");

        // [GIVEN] Posted "Invoice[1]" with Amount = 279729.45
        InvoiceNo[1] := PostInvoice(VendorNo, -279729.45, WHTPostingSetup);

        // [GIVEN] Posted "Invoice[2]" with Amount = 279729.45
        InvoiceNo[2] := PostInvoice(VendorNo, -279729.45, WHTPostingSetup);

        // [GIVEN] Posted "Invoice[3]" with Amount = 479688
        InvoiceNo[3] := PostInvoice(VendorNo, -479688, WHTPostingSetup);

        // [GIVEN] Payment[1] applied to Invoices. Amounts to apply are: -84766.5, -84766.5, -145360.0
        AppliedAmount[1] := 84766.5;
        AppliedAmount[2] := 84766.5;
        AppliedAmount[3] := 145360;
        PaymentNo := PostAppliedPaymentToInvoices(VendorNo, InvoiceNo, AppliedAmount, WHTPostingSetup, ArrayLen(InvoiceNo));
        VerifyPaymentWHTEntries(PaymentNo, WHTPostingSetup."Payable Wthldg. Tax Acc. Code");

        // [GIVEN] Payment[2] applied to Invoices. Amounts to apply are: -97481.48, -64987.65, -167164
        AppliedAmount[1] := 97481.48;
        AppliedAmount[2] := 64987.65;
        AppliedAmount[3] := 167164;
        PaymentNo := PostAppliedPaymentToInvoices(VendorNo, InvoiceNo, AppliedAmount, WHTPostingSetup, ArrayLen(InvoiceNo));
        VerifyPaymentWHTEntries(PaymentNo, WHTPostingSetup."Payable Wthldg. Tax Acc. Code");

        // [WHEN] Post final Payment[3] applied to Invoices. Amounts to apply are: -97481.47, -129975.3, -167164
        AppliedAmount[1] := 97481.47;
        AppliedAmount[2] := 129975.3;
        AppliedAmount[3] := 167164.0;
        PaymentNo := PostAppliedPaymentToInvoices(VendorNo, InvoiceNo, AppliedAmount, WHTPostingSetup, ArrayLen(InvoiceNo));

        // [THEN] All WHT entries aligned with GL Entries.
        VerifyPaymentWHTEntries(PaymentNo, WHTPostingSetup."Payable Wthldg. Tax Acc. Code");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure TFS376796_Inconsistent()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        VendorNo: Code[20];
        InvoiceNo: array[2] of Code[20];
        PaymentNo: Code[20];
        AppliedAmount: array[2] of Decimal;
    begin
        // [FEATURE] [Purchase] [Apply]
        // [SCENARIO 285194] Apply 3 equal payments to 2 equal invoices with certain amounts
        Initialize();
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        WHTPostingSetup."Withholding Tax %" := 3;
        WHTPostingSetup.Modify();
        VendorNo := CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");

        // [GIVEN] Posted "Invoice[1]" with Amount = 254299.5
        InvoiceNo[1] := PostInvoice(VendorNo, -254299.5, WHTPostingSetup);

        // [GIVEN] Posted "Invoice[2]" with Amount = 254299.5
        InvoiceNo[2] := PostInvoice(VendorNo, -254299.5, WHTPostingSetup);

        // [GIVEN] Payment[1] applied to Invoices. Amounts to apply are: -84766.5, -84766.5
        AppliedAmount[1] := 84766.5;
        AppliedAmount[2] := 84766.5;
        PaymentNo := PostAppliedPaymentToInvoices(VendorNo, InvoiceNo, AppliedAmount, WHTPostingSetup, ArrayLen(InvoiceNo));
        VerifyPaymentWHTEntries(PaymentNo, WHTPostingSetup."Payable Wthldg. Tax Acc. Code");

        // [GIVEN] Payment[2] applied to Invoices. Amounts to apply are: -84766.5, -84766.5
        AppliedAmount[1] := 84766.5;
        AppliedAmount[2] := 84766.5;
        PaymentNo := PostAppliedPaymentToInvoices(VendorNo, InvoiceNo, AppliedAmount, WHTPostingSetup, ArrayLen(InvoiceNo));
        VerifyPaymentWHTEntries(PaymentNo, WHTPostingSetup."Payable Wthldg. Tax Acc. Code");

        // [WHEN] Post final Payment[3] applied to Invoices. Amounts to apply are: -84766.5, -84766.5
        AppliedAmount[1] := 84766.5;
        AppliedAmount[2] := 84766.5;
        PaymentNo := PostAppliedPaymentToInvoices(VendorNo, InvoiceNo, AppliedAmount, WHTPostingSetup, ArrayLen(InvoiceNo));

        // [THEN] All WHT entries aligned with GL Entries.
        VerifyPaymentWHTEntries(PaymentNo, WHTPostingSetup."Payable Wthldg. Tax Acc. Code");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure ApplyPaymentToExceedingInvoices()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
        InvoiceNo: array[2] of Code[20];
        PaymentNo: Code[20];
        AppliedAmount: array[2] of Decimal;
    begin
        // [FEATURE] [Purchase] [Apply]
        // [SCENARIO 285194] Apply payment to invioces when payment amount less then summary amount of invoices
        Initialize();
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        WHTPostingSetup."Withholding Tax %" := 3;
        WHTPostingSetup.Modify();
        VendorNo := CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");

        AppliedAmount[1] := LibraryRandom.RandIntInRange(100, 200);
        AppliedAmount[2] := LibraryRandom.RandIntInRange(100, 200);
        // [GIVEN] Posted "Invoice[1]" with Amount = 100
        InvoiceNo[1] := PostInvoice(VendorNo, -AppliedAmount[1], WHTPostingSetup);

        // [GIVEN] Posted "Invoice[2]" with Amount = 200
        InvoiceNo[2] := PostInvoice(VendorNo, -AppliedAmount[2], WHTPostingSetup);

        // [GIVEN] Payment applied to Invoices. Amounts to apply are: -100 and -200
        CreateAppliedPaymentToInvoices(GenJournalLine, VendorNo, InvoiceNo, AppliedAmount, WHTPostingSetup, ArrayLen(InvoiceNo));

        // [GIVEN] Payment Amount corrected 250
        GenJournalLine.Validate(Amount, AppliedAmount[1] + AppliedAmount[2] - LibraryRandom.RandInt(100));
        GenJournalLine.Modify(true);

        // [WHEN] Post payment
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        PaymentNo := GenJournalLine."Document No.";

        // [THEN] All WHT entries aligned with GL Entries.
        VerifyPaymentWHTEntries(PaymentNo, WHTPostingSetup."Payable Wthldg. Tax Acc. Code");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure TFS377165_Inconsistent()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        VendorNo: Code[20];
        InvoiceNo: array[5] of Code[20];
        PaymentNo: Code[20];
        AppliedAmount: array[5] of Decimal;
        Index: Integer;
    begin
        // [FEATURE] [Purchase] [Apply]
        // [SCENARIO 285194] Apply 5 equal partial payments to 5 equal invoices with certain amounts
        Initialize();
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        WHTPostingSetup."Withholding Tax %" := 3;
        WHTPostingSetup.Modify();
        VendorNo := CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");

        // [GIVEN] Posted 5 Invoice with Amount = 254299.5 each
        for Index := 1 to ArrayLen(InvoiceNo) do begin
            InvoiceNo[Index] := PostInvoice(VendorNo, -254299.5, WHTPostingSetup);
            AppliedAmount[Index] := 84766.5;
        end;

        // [WHEN] 5 Payments applied to Invoices. Amount to apply is -84766.5 in each payment
        PaymentNo := PostAppliedPaymentToInvoices(VendorNo, InvoiceNo, AppliedAmount, WHTPostingSetup, ArrayLen(InvoiceNo));

        // [THEN] All WHT entries aligned with GL Entries.
        VerifyPaymentWHTEntries(PaymentNo, WHTPostingSetup."Payable Wthldg. Tax Acc. Code");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPaymentApplToPurchDocEmptyTypeNegativeAmtAndPurchInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GeneralPostingSetup: Record "General Posting Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        WHTTaxManagement: Codeunit "Withholding Tax Mgmt.";
        VendorNo: Code[20];
        InvoiceNo: Code[20];
        AppliesToID: Code[50];
        GenJnlLineAmount: Decimal;
        WHTAmount: Decimal;
        InvoiceAmount: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of Payment applies to Purhase Doc. "D1" with empty type and to Purchase Invoice "D2".
        // [SCENARIO 285194] "D1" has negative Amount, "D2" is posted after the "D1".
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Gen. Journal Line "D1" with Vendor "V", empty "Document Type" and negative Amount.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        GenJnlLineAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CreateAndPostGenJnlLineVendorAndSetAppliesToID(
          VendorLedgerEntry, WHTPostingSetup, GenJournalLine."Document Type"::" ", VendorNo, -GenJnlLineAmount);

        // [GIVEN] Posted Purchase Invoice "D2" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        InvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount);
        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, InvoiceNo);

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is between ABS("D2".Amount) and ABS("D1".Amount + "D2".Amount).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, GenJnlLineAmount + InvoiceAmount - LibraryRandom.RandDecInRange(100, 200, 2));

        // [WHEN] Calculate WHT Amount for "D3".
        WHTAmount := WHTTaxManagement.WithholdingAmountJournal(GenJournalLine, false);

        // [THEN] WHT Amount of "D3" is equal to WHT Amount of Invoice "D2".
        Assert.AreEqual(Round(InvoiceAmount * WHTPostingSetup."Withholding Tax %" / 100), WHTAmount, '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPaymentApplToPurchDocEmptyTypePositiveAmtAndPurchInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        WHTTaxManagement: Codeunit "Withholding Tax Mgmt.";
        VendorNo: Code[20];
        InvoiceNo: Code[20];
        AppliesToID: Code[50];
        GenJnlLineAmount: Decimal;
        WHTAmount: Decimal;
        InvoiceAmount: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of Payment applies to Purhase Doc. "D1" with empty type and to Purchase Invoice "D2".
        // [SCENARIO 285194] "D1" has positive Amount, "D2" is posted after the "D1".
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Gen. Journal Line "D1" with Vendor "V", empty "Document Type" and positive Amount.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        GenJnlLineAmount := LibraryRandom.RandDecInRange(100, 200, 2);
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CreateAndPostGenJnlLineVendorAndSetAppliesToID(
          VendorLedgerEntry, WHTPostingSetup, GenJournalLine."Document Type"::" ", VendorNo, GenJnlLineAmount);

        // [GIVEN] Posted Purchase Invoice "D2" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        InvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount);
        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, InvoiceNo);

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is between ABS("D2".Amount - "D1".Amount) and ABS("D2".Amount).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, InvoiceAmount - GenJnlLineAmount + LibraryRandom.RandDecInRange(10, 20, 2));

        // [WHEN] Calculate WHT Amount for "D3".
        WHTAmount := WHTTaxManagement.WithholdingAmountJournal(GenJournalLine, false);

        // [THEN] WHT Amount of "D3" is equal to Payment Amount * WHT%.
        Assert.AreEqual(Round(GenJournalLine.Amount * WHTPostingSetup."Withholding Tax %" / 100), WHTAmount, '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPaymentApplToPurchInvoiceWHTWithAppliedPurchCrMemoWHT()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        WHTTaxManagement: Codeunit "Withholding Tax Mgmt.";
        VendorNo: Code[20];
        InvoiceNo: Code[20];
        AppliesToID: Code[50];
        WHTAmount: Decimal;
        InvoiceAmount: Decimal;
        CrMemoAmount: Decimal;
        ExpectedWHTAmt: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of Payment applies to Purchase Invoice "D1" and to Purchase Cr.Memo "D2".
        // [SCENARIO 285194] Both "D1" and "D2" have related WHT Entry. "D2" is applied to "D1".
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Purchase Invoice "D1" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] Posted Purchase Cr. Memo "D2" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] "D2" is applied to "D1".
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CrMemoAmount := LibraryRandom.RandDecInRange(100, 200, 2);
        InvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount);
        CreateAndPostPurchaseDocumentWithWHTAndAppliesToDocNo(WHTPostingSetup, PurchaseHeader."Document Type"::"Credit Memo",
          VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceNo, 1, CrMemoAmount);

        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, InvoiceNo);

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is between ABS(InvoiceAmount - CrMemoAmount) and ABS(InvoiceAmount).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, Abs(InvoiceAmount - CrMemoAmount + LibraryRandom.RandDecInRange(10, 20, 2)));

        // [WHEN] Calculate WHT Amount for "D3".
        WHTAmount := WHTTaxManagement.WithholdingAmountJournal(GenJournalLine, false);

        // [THEN] WHT Amount of "D3" is equal to (InvoiceAmount - CrMemoAmount) * WHT%.
        ExpectedWHTAmt := Round((InvoiceAmount - CrMemoAmount) * WHTPostingSetup."Withholding Tax %" / 100);
        Assert.AreEqual(ExpectedWHTAmt, WHTAmount, '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPaymentApplToPurchInvoiceWHTAndPurchCrMemoWHT()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GeneralPostingSetup: Record "General Posting Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        WHTTaxManagement: Codeunit "Withholding Tax Mgmt.";
        VendorNo: Code[20];
        DocumentNo: List of [Code[20]];
        AppliesToID: Code[50];
        WHTAmount: Decimal;
        InvoiceAmount: Decimal;
        CrMemoAmount: Decimal;
        ExpectedWHTAmt: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of Payment applies to Purchase Invoice "D1" and to Purchase Cr.Memo "D2".
        // [SCENARIO 285194] Both "D1" and "D2" have related WHT Entry.
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Purchase Invoice "D1" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] Posted Purchase Cr. Memo "D2" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CrMemoAmount := LibraryRandom.RandDecInRange(100, 200, 2);
        DocumentNo.Add(
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount));
        DocumentNo.Add(
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::"Credit Memo",
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), CrMemoAmount));

        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, DocumentNo.Get(1));
        SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::"Credit Memo", DocumentNo.Get(2));

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is between ABS(InvoiceAmount - CrMemoAmount) and ABS(InvoiceAmont).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, Abs(InvoiceAmount - CrMemoAmount + LibraryRandom.RandDecInRange(10, 20, 2)));

        // [WHEN] Calculate WHT Amount for "D3".
        WHTAmount := WHTTaxManagement.WithholdingAmountJournal(GenJournalLine, false);

        // [THEN] WHT Amount of "D3" is equal to (InvoiceAmount - CrMemoAmount) * WHT%.
        ExpectedWHTAmt := Round(InvoiceAmount * WHTPostingSetup."Withholding Tax %" / 100) - Round(CrMemoAmount * WHTPostingSetup."Withholding Tax %" / 100);
        Assert.AreEqual(ExpectedWHTAmt, WHTAmount, '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPaymentApplToPurchInvoiceWHTWithAppliedPurchCrMemoNonWHT()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        WHTTaxManagement: Codeunit "Withholding Tax Mgmt.";
        VendorNo: Code[20];
        InvoiceNo: Code[20];
        AppliesToID: Code[50];
        WHTAmount: Decimal;
        InvoiceAmount: Decimal;
        CrMemoAmount: Decimal;
        ExpectedWHTAmt: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of Payment applies to Purchase Invoice "D1" and to Purchase Cr.Memo "D2".
        // [SCENARIO 285194] Only "D1" has related WHT Entry. "D2" is applied to "D1".
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Purchase Invoice "D1" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] Posted Purchase Cr. Memo "D2" for Vendor "V". Amount is less than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] "D2" is applied to "D1".
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CrMemoAmount := LibraryRandom.RandDecInRange(10, 20, 2);
        InvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount);
        CreateAndPostPurchaseDocumentWithWHTAndAppliesToDocNo(
          WHTPostingSetup, PurchaseHeader."Document Type"::"Credit Memo",
          VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceNo, 1, CrMemoAmount);

        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, InvoiceNo);

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is between ABS(InvoiceAmount - CrMemoAmount) and ABS(InvoiceAmont).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, Abs(InvoiceAmount - CrMemoAmount + LibraryRandom.RandDecInRange(4, 6, 2)));

        // [WHEN] Calculate WHT Amount for "D3".
        WHTAmount := WHTTaxManagement.WithholdingAmountJournal(GenJournalLine, false);

        // [THEN] WHT Amount of "D3" is equal to (InvoiceAmount - CrMemoAmount) * WHT%.
        ExpectedWHTAmt := Round((InvoiceAmount - CrMemoAmount) * WHTPostingSetup."Withholding Tax %" / 100);
        Assert.AreEqual(ExpectedWHTAmt, WHTAmount, '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPaymentApplToPurchInvoiceWHTAndPurchCrMemoNonWHT()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GeneralPostingSetup: Record "General Posting Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        WHTTaxManagement: Codeunit "Withholding Tax Mgmt.";
        VendorNo: Code[20];
        DocumentNo: List of [Code[20]];
        AppliesToID: Code[50];
        WHTAmount: Decimal;
        InvoiceAmount: Decimal;
        CrMemoAmount: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of Payment applies to Purchase Invoice "D1" and to Purchase Cr.Memo "D2".
        // [SCENARIO 285194] Only "D1" has related WHT Entry.
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Purchase Invoice "D1" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] Posted Purchase Cr. Memo "D2" for Vendor "V". Amount is less than WHTSetup's Minimum Invoice Amount.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CrMemoAmount := LibraryRandom.RandDecInRange(10, 20, 2);
        DocumentNo.Add(
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount));
        DocumentNo.Add(
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::"Credit Memo",
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), CrMemoAmount));

        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, DocumentNo.Get(1));
        SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::"Credit Memo", DocumentNo.Get(2));

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is between ABS(InvoiceAmount - CrMemoAmount) and ABS(InvoiceAmont).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, Abs(InvoiceAmount - CrMemoAmount + LibraryRandom.RandDecInRange(4, 6, 2)));

        // [WHEN] Calculate WHT Amount for "D3".
        WHTAmount := WHTTaxManagement.WithholdingAmountJournal(GenJournalLine, false);

        // [THEN] WHT Amount of "D3" is equal to InvoiceAmount * WHT%.
        Assert.AreEqual(Round(InvoiceAmount * WHTPostingSetup."Withholding Tax %" / 100), WHTAmount, '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPaymentWithLessAmountApplToMultipleInvoiceAndCrMemo()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        WHTTaxManagement: Codeunit "Withholding Tax Mgmt.";
        AppliesToID: Code[50];
        VendorNo: Code[20];
        DocAmount: List of [Decimal];
        TotalDocAmount: Decimal;
        DiffAmount: Decimal;
        WHTAmount: Decimal;
        ExpectedWHTAmt: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of Payment applies to two Purchase Invoices and to two Purchase Cr.Memos.
        // [SCENARIO 285194] All Purchase documents have related WHT Entry. Payment amount is less than summ of Purchase document amounts.
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Two Posted Purchase Invoices for Vendor "V". Amounts are 1000 and 800.
        // [GIVEN] Two Posted Purchase Cr. Memos for Vendor "V" with Amounts > InvoiceAmount / 2. Amounts are 900 and 700.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        DiffAmount := LibraryRandom.RandDecInRange(10, 20, 2);

        CreateMultiplePostedPurchDocumentsWithAppliesToID(
          AppliesToID, DocAmount, TotalDocAmount, WHTPostingSetup, VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"));
        CalcWHTAmountOnInvoiceCrMemoAmounts(ExpectedWHTAmt, DocAmount, DiffAmount, WHTPostingSetup."Withholding Tax %");

        // [GIVEN] Gen. Journal Line "D" with Vendor "V", "Document Type" = Payment, Amount is between ABS(InvoiceAmounts - CrMemoAmounts) and ABS(InvoiceAmont).
        // [GIVEN] "D" applies to all Posted Purchase documents by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, TotalDocAmount - DiffAmount);

        // [WHEN] Calculate WHT Amount for "D".
        WHTAmount := WHTTaxManagement.WithholdingAmountJournal(GenJournalLine, false);

        // [THEN] WHT Amount of "D" is equal to Payment Amount * WHT%, i.e. to (1000 + 800 - 900 - 700 - 10) * WHT%.
        Assert.AreEqual(ExpectedWHTAmt, WHTAmount, '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPaymentWithEqualAmountApplToMultipleInvoiceAndCrMemo()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        WHTTaxManagement: Codeunit "Withholding Tax Mgmt.";
        AppliesToID: Code[50];
        VendorNo: Code[20];
        DocAmount: List of [Decimal];
        TotalDocAmount: Decimal;
        WHTAmount: Decimal;
        ExpectedWHTAmt: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of Payment applies to two Purchase Invoices and to two Purchase Cr.Memos.
        // [SCENARIO 285194] All Purchase documents have related WHT Entry. Payment amount is equal to summ of Purchase document amounts.
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Two Posted Purchase Invoices for Vendor "V". Amounts are 1000 and 800.
        // [GIVEN] Two Posted Purchase Cr. Memos for Vendor "V" with Amounts > InvoiceAmount / 2. Amounts are 900 and 700.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");

        CreateMultiplePostedPurchDocumentsWithAppliesToID(
          AppliesToID, DocAmount, TotalDocAmount, WHTPostingSetup, VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"));
        CalcWHTAmountOnInvoiceCrMemoAmounts(ExpectedWHTAmt, DocAmount, 0, WHTPostingSetup."Withholding Tax %");

        // [GIVEN] Gen. Journal Line "D" with Vendor "V", "Document Type" = Payment, Amount is equal to ABS(InvoiceAmounts - CrMemoAmounts).
        // [GIVEN] "D" applies to all Posted Purchase documents by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, TotalDocAmount);

        // [WHEN] Calculate WHT Amount for "D".
        WHTAmount := WHTTaxManagement.WithholdingAmountJournal(GenJournalLine, false);

        // [THEN] WHT Amount of "D" is equal to (1000 + 800 - 900 - 700) * WHT%.
        Assert.AreEqual(ExpectedWHTAmt, WHTAmount, '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPaymentWithGreaterAmountApplToMultipleInvoiceAndCrMemo()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        WHTTaxManagement: Codeunit "Withholding Tax Mgmt.";
        AppliesToID: Code[50];
        VendorNo: Code[20];
        DocAmount: List of [Decimal];
        TotalDocAmount: Decimal;
        DiffAmount: Decimal;
        WHTAmount: Decimal;
        ExpectedWHTAmt: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of Payment applies to two Purchase Invoices and to two Purchase Cr.Memos.
        // [SCENARIO 285194] All Purchase documents have related WHT Entry. Payment amount is greater than summ of Purchase document amounts.
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Two Posted Purchase Invoices for Vendor "V". Amounts are 1000 and 800.
        // [GIVEN] Two Posted Purchase Cr. Memos for Vendor "V" with Amounts > InvoiceAmount / 2. Amounts are 900 and 700.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        DiffAmount := LibraryRandom.RandDecInRange(10, 20, 2);

        CreateMultiplePostedPurchDocumentsWithAppliesToID(
          AppliesToID, DocAmount, TotalDocAmount, WHTPostingSetup, VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"));
        CalcWHTAmountOnInvoiceCrMemoAmounts(ExpectedWHTAmt, DocAmount, 0, WHTPostingSetup."Withholding Tax %");

        // [GIVEN] Gen. Journal Line "D" with Vendor "V", "Document Type" = Payment, Amount is larger than ABS(InvoiceAmounts - CrMemoAmounts).
        // [GIVEN] "D" applies to all Posted Purchase documents by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, Abs(TotalDocAmount) + DiffAmount);

        // [WHEN] Calculate WHT Amount for "D".
        WHTAmount := WHTTaxManagement.WithholdingAmountJournal(GenJournalLine, false);

        // [THEN] WHT Amount of "D" is equal to (1000 + 800 - 900 - 700) * WHT%.
        Assert.AreEqual(ExpectedWHTAmt, WHTAmount, '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPostPaymentApplToPurchDocEmptyTypeNegativeAmtAndPurchInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
        InvoiceNo: Code[20];
        AppliesToID: Code[50];
        GenJnlLineAmount: Decimal;
        InvoiceAmount: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of posting Payment, that applies to Purhase Doc. "D1" with empty type and to Purchase Invoice "D2".
        // [SCENARIO 285194] "D1" has negative Amount, "D2" is posted after the "D1".
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Gen. Journal Line "D1" with Vendor "V", empty "Document Type" and negative Amount.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        GenJnlLineAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CreateAndPostGenJnlLineVendorAndSetAppliesToID(
          VendorLedgerEntry, WHTPostingSetup, GenJournalLine."Document Type"::" ", VendorNo, -GenJnlLineAmount);

        // [GIVEN] Posted Purchase Invoice "D2" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        InvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount);
        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, InvoiceNo);

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is equal to ABS("D1".Amount + "D2".Amount).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, GenJnlLineAmount + InvoiceAmount);
        SetCheckPrinted(GenJournalLine);

        // [WHEN] Post Gen. Journal Line "D3".
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Amount of G/L Entry for WHT Payable account is equal to WHT Amount of Invoice "D2".
        VerifyAmountOnGLEntry(
          GenJournalLine."Document No.", WHTPostingSetup."Payable Wthldg. Tax Acc. Code",
          -Round(InvoiceAmount * WHTPostingSetup."Withholding Tax %" / 100));
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPostPaymentApplToPurchDocEmptyTypePositiveAmtAndPurchInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
        InvoiceNo: Code[20];
        AppliesToID: Code[50];
        GenJnlLineAmount: Decimal;
        InvoiceAmount: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of posting Payment, that applies to Purhase Doc. "D1" with empty type and to Purchase Invoice "D2".
        // [SCENARIO 285194] "D1" has positive Amount, "D2" is posted after the "D1".
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Gen. Journal Line "D1" with Vendor "V", empty "Document Type" and positive Amount.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        GenJnlLineAmount := LibraryRandom.RandDecInRange(100, 200, 2);
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CreateAndPostGenJnlLineVendorAndSetAppliesToID(
          VendorLedgerEntry, WHTPostingSetup, GenJournalLine."Document Type"::" ", VendorNo, GenJnlLineAmount);

        // [GIVEN] Posted Purchase Invoice "D2" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        InvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount);
        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, InvoiceNo);

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is equal to ABS("D2".Amount - "D1".Amount).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, InvoiceAmount - GenJnlLineAmount);
        SetCheckPrinted(GenJournalLine);

        // [WHEN] Post Gen. Journal Line "D3".
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Amount of G/L Entry for WHT Payable account is equal to Payment Amount * WHT%.
        VerifyAmountOnGLEntry(
          GenJournalLine."Document No.", WHTPostingSetup."Payable Wthldg. Tax Acc. Code",
          -Round(GenJournalLine.Amount * WHTPostingSetup."Withholding Tax %" / 100));
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPostPaymentApplToPurchInvoiceWHTWithAppliedPurchCrMemoWHT()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
        InvoiceNo: Code[20];
        AppliesToID: Code[50];
        InvoiceAmount: Decimal;
        CrMemoAmount: Decimal;
        ExpectedWHTAmt: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of posting Payment, that applies to Purchase Invoice "D1" and to Purchase Cr.Memo "D2".
        // [SCENARIO 285194] Both "D1" and "D2" have related WHT Entry. "D2" is applied to "D1".
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Purchase Invoice "D1" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] Posted Purchase Cr. Memo "D2" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] "D2" is applied to "D1".
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CrMemoAmount := LibraryRandom.RandDecInRange(100, 200, 2);
        InvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount);
        CreateAndPostPurchaseDocumentWithWHTAndAppliesToDocNo(
          WHTPostingSetup, PurchaseHeader."Document Type"::"Credit Memo",
          VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceNo, 1, CrMemoAmount);

        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, InvoiceNo);

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is equal to ABS(InvoiceAmount - CrMemoAmount).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, Abs(InvoiceAmount - CrMemoAmount));
        SetCheckPrinted(GenJournalLine);

        // [WHEN] Post Gen. Journal Line "D3".
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Amount of G/L Entry for WHT Payable account is equal to (InvoiceAmount - CrMemoAmount) * WHT%.
        ExpectedWHTAmt := -Round((InvoiceAmount - CrMemoAmount) * WHTPostingSetup."Withholding Tax %" / 100);
        VerifyAmountOnGLEntry(GenJournalLine."Document No.", WHTPostingSetup."Payable Wthldg. Tax Acc. Code", ExpectedWHTAmt);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPostPaymentApplToPurchInvoiceWHTAndPurchCrMemoWHT()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
        DocumentNo: List of [Code[20]];
        AppliesToID: Code[50];
        InvoiceAmount: Decimal;
        CrMemoAmount: Decimal;
        ExpectedWHTAmounts: List of [Decimal];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of posting Payment, that applies to Purchase Invoice "D1" and to Purchase Cr.Memo "D2".
        // [SCENARIO 285194] Both "D1" and "D2" have related WHT Entry.
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Purchase Invoice "D1" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] Posted Purchase Cr. Memo "D2" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CrMemoAmount := LibraryRandom.RandDecInRange(100, 200, 2);
        DocumentNo.Add(
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount));
        DocumentNo.Add(
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::"Credit Memo",
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), CrMemoAmount));

        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, DocumentNo.Get(1));
        SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::"Credit Memo", DocumentNo.Get(2));

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is equal to ABS(InvoiceAmount - CrMemoAmount).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, Abs(InvoiceAmount - CrMemoAmount));
        SetCheckPrinted(GenJournalLine);

        // [WHEN] Post Gen. Journal Line "D3".
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Amounts of G/L Entries for WHT Payable account are equal to CrMemoAmount * WHT% and InvoiceAmount * WHT%.
        ExpectedWHTAmounts.Add(Round(CrMemoAmount * WHTPostingSetup."Withholding Tax %" / 100));
        ExpectedWHTAmounts.Add(-Round(InvoiceAmount * WHTPostingSetup."Withholding Tax %" / 100));
        VerifyAmountOnMultipleGLEntries(
          GenJournalLine."Document No.", WHTPostingSetup."Payable Wthldg. Tax Acc. Code", ExpectedWHTAmounts);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPostPaymentApplToPurchInvoiceWHTWithAppliedPurchCrMemoNonWHT()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
        InvoiceNo: Code[20];
        AppliesToID: Code[50];
        InvoiceAmount: Decimal;
        CrMemoAmount: Decimal;
        ExpectedWHTAmt: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of posting Payment, that applies to Purchase Invoice "D1" and to Purchase Cr.Memo "D2".
        // [SCENARIO 285194] Only "D1" has related WHT Entry. "D2" is applied to "D1".
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Purchase Invoice "D1" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] Posted Purchase Cr. Memo "D2" for Vendor "V". Amount is less than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] "D2" is applied to "D1".
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CrMemoAmount := LibraryRandom.RandDecInRange(10, 20, 2);
        InvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount);
        CreateAndPostPurchaseDocumentWithWHTAndAppliesToDocNo(
          WHTPostingSetup, PurchaseHeader."Document Type"::"Credit Memo",
          VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceNo, 1, CrMemoAmount);

        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, InvoiceNo);

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is equal to ABS(InvoiceAmount - CrMemoAmount).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, Abs(InvoiceAmount - CrMemoAmount));
        SetCheckPrinted(GenJournalLine);

        // [WHEN] Post Gen. Journal Line "D3".
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Amount of G/L Entry for WHT Payable account is equal to (InvoiceAmount - CrMemoAmount) * WHT%.
        ExpectedWHTAmt := -Round((InvoiceAmount - CrMemoAmount) * WHTPostingSetup."Withholding Tax %" / 100);
        VerifyAmountOnGLEntry(GenJournalLine."Document No.", WHTPostingSetup."Payable Wthldg. Tax Acc. Code", ExpectedWHTAmt);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPostPaymentApplToPurchInvoiceWHTAndPurchCrMemoNonWHT()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
        DocumentNo: array[2] of Code[20];
        AppliesToID: Code[50];
        InvoiceAmount: Decimal;
        CrMemoAmount: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of posting Payment, that applies to Purchase Invoice "D1" and to Purchase Cr.Memo "D2".
        // [SCENARIO 285194] Only "D1" has related WHT Entry.
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Posted Purchase Invoice "D1" for Vendor "V". Amount is greater than WHTSetup's Minimum Invoice Amount.
        // [GIVEN] Posted Purchase Cr. Memo "D2" for Vendor "V". Amount is less than WHTSetup's Minimum Invoice Amount.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        InvoiceAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        CrMemoAmount := LibraryRandom.RandDecInRange(10, 20, 2);
        DocumentNo[1] :=
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), InvoiceAmount);
        DocumentNo[2] :=
          CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup, PurchaseHeader."Document Type"::"Credit Memo",
            VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), CrMemoAmount);

        AppliesToID := SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::Invoice, DocumentNo[1]);
        SetAppliesToIDVendorDocument(VendorLedgerEntry."Document Type"::"Credit Memo", DocumentNo[2]);

        // [GIVEN] Gen. Journal Line "D3" with Vendor "V", "Document Type" = Payment, Amount is equal to ABS(InvoiceAmount - CrMemoAmount).
        // [GIVEN] "D3" applies to "D1" and "D2" by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, Abs(InvoiceAmount - CrMemoAmount));
        SetCheckPrinted(GenJournalLine);

        // [WHEN] Post Gen. Journal Line "D3".
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Amount of G/L Entry for WHT Payable account is equal to InvoiceAmount * WHT%.
        VerifyAmountOnGLEntry(
          GenJournalLine."Document No.", WHTPostingSetup."Payable Wthldg. Tax Acc. Code",
          -Round(InvoiceAmount * WHTPostingSetup."Withholding Tax %" / 100));
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPostPaymentWithLessAmountApplToMultipleInvoiceAndCrMemo()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        AppliesToID: Code[50];
        VendorNo: Code[20];
        DocAmount: List of [Decimal];
        TotalDocAmount: Decimal;
        DiffAmount: Decimal;
        ExpectedWHTAmt: Decimal;
        ExpectedWHTAmounts: List of [Decimal];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of posting Payment, that applies to two Purchase Invoices and to two Purchase Cr.Memos.
        // [SCENARIO 285194] All Purchase documents have related WHT Entry. Payment amount is less than summ of Purchase document amounts.
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Two Posted Purchase Invoices for Vendor "V". Amounts are 1000 and 800.
        // [GIVEN] Two Posted Purchase Cr. Memos for Vendor "V" with Amounts > InvoiceAmount / 2. Amounts are 900 and 700.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        DiffAmount := LibraryRandom.RandDecInRange(10, 20, 2);

        CreateMultiplePostedPurchDocumentsWithAppliesToID(
          AppliesToID, DocAmount, TotalDocAmount, WHTPostingSetup, VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"));
        CalcWHTAmountOnInvoiceCrMemoAmounts(ExpectedWHTAmt, DocAmount, DiffAmount, WHTPostingSetup."Withholding Tax %");

        // [GIVEN] Gen. Journal Line "D" with Vendor "V", "Document Type" = Payment, Amount is between ABS(InvoiceAmounts - CrMemoAmounts) and ABS(InvoiceAmont).
        // [GIVEN] "D" applies to all Posted Purchase documents by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, TotalDocAmount - DiffAmount);
        SetCheckPrinted(GenJournalLine);

        // [WHEN] Post Gen. Journal Line "D".
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Amounts of G/L Entries for WHT Payable account are equal to 900 * WHT%, 700 * WHT%, 1000 * WHT%, (800 - DiffAmount) * WHT%.
        DocAmount.Set(3, DocAmount.Get(3) - DiffAmount);
        CalcWHTAmountsForMultipleWHTGLEntries(ExpectedWHTAmounts, DocAmount, WHTPostingSetup."Withholding Tax %");
        VerifyAmountOnMultipleGLEntries(
          GenJournalLine."Document No.", WHTPostingSetup."Payable Wthldg. Tax Acc. Code", ExpectedWHTAmounts);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTAmtPostPaymentWithEqualAmountApplToMultipleInvoiceAndCrMemo()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        AppliesToID: Code[50];
        VendorNo: Code[20];
        DocAmount: List of [Decimal];
        TotalDocAmount: Decimal;
        ExpectedWHTAmt: Decimal;
        ExpectedWHTAmounts: List of [Decimal];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] WHT Amount calculation in case of posting Payment, that applies to two Purchase Invoices and to two Purchase Cr.Memos.
        // [SCENARIO 285194] All Purchase documents have related WHT Entry. Payment amount is equal to summ of Purchase document amounts.
        Initialize();
        FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(VATPostingSetup, WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Two Posted Purchase Invoices for Vendor "V". Amounts are 1000 and 800.
        // [GIVEN] Two Posted Purchase Cr. Memos for Vendor "V" with Amounts > InvoiceAmount / 2. Amounts are 900 and 700.
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");

        CreateMultiplePostedPurchDocumentsWithAppliesToID(
          AppliesToID, DocAmount, TotalDocAmount, WHTPostingSetup, VendorNo, CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"));
        CalcWHTAmountOnInvoiceCrMemoAmounts(ExpectedWHTAmt, DocAmount, 0, WHTPostingSetup."Withholding Tax %");

        // [GIVEN] Gen. Journal Line "D" with Vendor "V", "Document Type" = Payment, Amount is equal to ABS(InvoiceAmounts - CrMemoAmounts).
        // [GIVEN] "D" applies to all Posted Purchase documents by setting the same "Applies-to ID".
        CreateGenJnlLineWithAppliesToID(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Payment,
          VendorNo, AppliesToID, TotalDocAmount);
        SetCheckPrinted(GenJournalLine);

        // [WHEN] Post Gen. Journal Line "D".
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Amounts of G/L Entries for WHT Payable account are equal to 900 * WHT%, 700 * WHT%, 1000 * WHT%, 800 * WHT%.
        CalcWHTAmountsForMultipleWHTGLEntries(ExpectedWHTAmounts, DocAmount, WHTPostingSetup."Withholding Tax %");
        VerifyAmountOnMultipleGLEntries(
          GenJournalLine."Document No.", WHTPostingSetup."Payable Wthldg. Tax Acc. Code", ExpectedWHTAmounts);
    end;

    [Test]
    [HandlerFunctions('UnapplyVendorEntriesPageHandler,ConfirmHandler,MessageHandler')]
    procedure InvoiceToCreditMemoApplyUnapply()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        LastWHTEntry: Record "Withholding Tax Entry";
        InvoiceWHTEntry: Record "Withholding Tax Entry";
        CrMemoWHTEntry: Record "Withholding Tax Entry";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
        PostedInvoiceNo, VendorNo : Code[20];
    begin
        // [FEATURE] [Unapply]
        // [SCENARIO 285194] There is no new WHT Entry is created after unapply invocie to credit memo application
        Initialize();
        UpdateGeneralLedgerSetup(true, false);
        LastWHTEntry.FindLast();

        // [GIVEN] Posted purchase invoice with WHT Entry "No." =  "X"
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);
        VendorNo := CreateVendorNoWithoutABN(VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        PostedInvoiceNo :=
          CreateAndPostPurchaseDocumentWithWHT(
            PurchaseLine, WHTPostingSetup, PurchaseHeader."Document Type"::Invoice,
            VendorNo,
            CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), '');
        InvoiceWHTEntry.FindLast();
        InvoiceWHTEntry.TestField("Entry No.", LastWHTEntry."Entry No." + 1);
        InvoiceWHTEntry.TestField("Remaining Unrealized Base");
        InvoiceWHTEntry.TestField("Remaining Unrealized Amount");

        // [GIVEN] Posted purchase credit memo with WHT Entry "No." = "Y"
        CreateAndPostPurchaseDocumentWithWHT(
          PurchaseLine, WHTPostingSetup, PurchaseHeader."Document Type"::"Credit Memo",
          PurchaseLine."Buy-from Vendor No.", PurchaseLine."No.", '');
        CrMemoWHTEntry.FindLast();
        CrMemoWHTEntry.TestField("Entry No.", LastWHTEntry."Entry No." + 2);
        CrMemoWHTEntry.TestField("Remaining Unrealized Base");
        CrMemoWHTEntry.TestField("Remaining Unrealized Amount");

        // [GIVEN] Apply post invoice to credit memo vendor ledger entry
        ApplyAndPostVendorEntryApplication(GenJournalLine."Document Type"::Invoice, PostedInvoiceNo);

        // [WHEN] Unapply the application
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, PostedInvoiceNo);
        VendEntryApplyPostedEntries.UnApplyVendLedgEntry(VendorLedgerEntry."Entry No.");

        // [THEN] There is no new WHT Entry is created (with Entry No. > "Y") and invoice and credit memo WHT entries remains unchanged
        InvoiceWHTEntry.Find();
        InvoiceWHTEntry.TestField("Remaining Unrealized Base", InvoiceWHTEntry."Unrealized Base");
        InvoiceWHTEntry.TestField("Remaining Unrealized Amount", InvoiceWHTEntry."Unrealized Amount");

        CrMemoWHTEntry.Find();
        CrMemoWHTEntry.TestField("Remaining Unrealized Base", CrMemoWHTEntry."Unrealized Base");
        CrMemoWHTEntry.TestField("Remaining Unrealized Amount", CrMemoWHTEntry."Unrealized Amount");

        LastWHTEntry.SetFilter("Entry No.", '>%1', CrMemoWHTEntry."Entry No.");
        Assert.RecordIsEmpty(LastWHTEntry);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostMultipleWHTInvoiceWithPayment()
    var
        GenJournalLine: array[3] of Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        VendorNo: array[3] of Code[20];
        PostedInvoiceNo: array[3] of Code[20];
        PostedCreditMemoNo: Code[20];
        GLAccountNo: Code[20];
        Amount: array[3] of Decimal;
        WHTAmount: array[3] of Decimal;
    begin
        // [SCENARIO 285194] Stan has posted multiple Withholding tax invoices for different vendors and post credit memo for one of the invoices and when
        // posting payment journal for all of the invoices, WHT calculation should be correct.
        Initialize();

        // [GIVEN] Enable WHT
        UpdateGeneralLedgerSetup(true, false);  // False - Enable GST, Round Amount for WHT Calc and True as Enable WHT.

        // [GIVEN] Find VATPosting setup and WHT posting setup
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);

        // [GIVEN] Create multiple vendors
        CreateMultipleVendors(VendorNo, VATPostingSetup, GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");

        // [GIVEN] Create G/L Account
        GLAccountNo := CreateGLAccountWithPostingSetup(VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");

        // [GIVEN] Create multiple purchase invoices for multiples Vendors
        PostMultiplePurchaseInvoice(VendorNo, PostedInvoiceNo, WHTAmount, WHTPostingSetup, GLAccountNo);

        // [GIVEN] Create and post partial Purchase Credit Memo for second invoice posted with WHT
        PostedCreditMemoNo := PostPurchaseCreditMemoWithWHT(WHTPostingSetup, VendorNo[2], GLAccountNo, PostedInvoiceNo[2]);

        // [GIVEN] Update WHTAmount of second invoice after posting Purchase Credit Memo
        WHTAmount[2] := WHTAmount[2] + GetWHTEntryUnrealizedAmount(PostedCreditMemoNo);

        // [GIVEN] Get Remaining Amount from Vendor Ledger Entry for all invoices
        GetRemainingAmountFromVendorLedgerEntry(PostedInvoiceNo, Amount);

        // [WHEN] Create and Post Payment Journal with WHT
        CreateAndPostMultipleGeneralJournalLineWithCurrency(
          GenJournalLine, WHTPostingSetup, GenJournalLine[1]."Account Type"::Vendor, GenJournalLine[1]."Document Type"::Payment,
          VendorNo, PostedInvoiceNo, '', Amount);

        // [THEN] Verify WHT Amount on G/L Entry
        VerifyWHTAmountOnGlEntry(GenJournalLine, WHTAmount, WHTPostingSetup."Payable Wthldg. Tax Acc. Code");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTEntryOnPostedPurchaseInvoiceJournalWithWHT()
    var
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        VATEntry: Record "VAT Entry";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        WHTEntry: Record "Withholding Tax Entry";
        VendorNo: Code[20];
    begin
        // [SCENARIO 285194] -Test to verify after Posting Purchase Invoice Journal with WHT, WHT Entry - Unrealized Base Amount is correctly calculated.
        Initialize();

        // [GIVEN] WHT Posting Setup has been created
        LibraryWithholdingTax.CreateWHTPostingSetupWithPayableGLAccounts(WHTPostingSetup);

        // [GIVEN] Create Purchase Invoice Journal with WHT .
        UpdateGeneralLedgerSetup(true, false);  // Round Amount for WHT Calc and True as Enable WHT.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        VendorNo := CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        CreateGeneralJournalLineWithCurrency(
         GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Invoice,
         VendorNo, '', '', -1000);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.validate("Bal. Account No.", CreateGLAccount(VATPostingSetup."VAT Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"));
        GenJournalLine.validate("Bal. VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GenJournalLine.validate("Bal. VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GenJournalLine.validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Purchase);
        GenJournalLine.Modify();

        // [WHEN] Post Purchase Invoice Journal with WHT.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify WHT Entry - Unrealized Base, VAT Entry - Base.
        VATEntry.SetRange("Document Type", VATEntry."Document Type"::Invoice);
        VATEntry.SetRange("Document No.", GenJournalLine."Document No.");
        VATEntry.Findlast();
        WHTEntry.SetRange("Document No.", GenJournalLine."Document No.");
        WHTEntry.Findlast();
        Assert.AreEqual(VATEntry.Base, WHTEntry."Unrealized Base", 'Not equal');
    end;

    [Test]
    [HandlerFunctions('UnapplyVendorEntriesPageHandler,ConfirmHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure UnapplyVendorLedgerEntryAmountOnGLEntry()
    begin
        // [SCENARIO 285194] after Unapplied Vendor Ledger Entry on Posted Payment Journal with WHT, G/L Entry - Amount correctly calculated.
        Initialize();
        UnapplyVendorLedgerEntryAmount('');  // Currency as blank.
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibrarySetupStorage.Restore();

        if IsInitialized then
            exit;

        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);

        IsInitialized := true;
        LibrarySetupStorage.Save(Database::"General Ledger Setup");
    end;

    local procedure ApplyVendorLedgerEntry(var ApplyingVendorLedgerEntry: Record "Vendor Ledger Entry"; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(ApplyingVendorLedgerEntry, DocumentType, DocumentNo);
        ApplyingVendorLedgerEntry.CalcFields("Remaining Amount");
        LibraryERM.SetApplyVendorEntry(ApplyingVendorLedgerEntry, ApplyingVendorLedgerEntry."Remaining Amount");

        // Find Posted Vendor Ledger Entries.
        VendorLedgerEntry.SetRange("Vendor No.", ApplyingVendorLedgerEntry."Vendor No.");
        VendorLedgerEntry.SetRange("Applying Entry", false);
        VendorLedgerEntry.FindFirst();

        // Set Applies-to ID.
        LibraryERM.SetAppliestoIdVendor(VendorLedgerEntry);
    end;

    local procedure ApplyAndPostVendorEntryApplication(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        ApplyVendorLedgerEntry(VendorLedgerEntry, DocumentType, DocumentNo);
        LibraryERM.PostVendLedgerApplication(VendorLedgerEntry);
    end;

    local procedure ApplyPurchCrMemoToInvCustomAmount(InvNo: Code[20]; CrMemoNo: Code[20]; ApplnAmount: Decimal)
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendLedgEntry, VendLedgEntry."Document Type"::Invoice, InvNo);
        VendLedgEntry.Validate("Applies-to ID", CrMemoNo);
        VendLedgEntry.Validate("Amount to Apply", ApplnAmount);
        VendLedgEntry.Modify(true);
    end;

    local procedure CalcWHTAmountOnInvoiceCrMemoAmounts(var TotalWHTAmount: Decimal; DocAmount: List of [Decimal]; DiffAmount: Decimal; WHTPercent: Decimal)
    begin
        TotalWHTAmount :=
          Round(DocAmount.Get(1) * WHTPercent / 100) - Round(DocAmount.Get(2) * WHTPercent / 100) +
          Round((DocAmount.Get(3) - DiffAmount) * WHTPercent / 100) - Round(DocAmount.Get(4) * WHTPercent / 100);
    end;

    local procedure CalcWHTAmountsForMultipleWHTGLEntries(var WHTAmounts: List of [Decimal]; DocumentAmounts: List of [Decimal]; WHTPercent: Decimal)
    begin
        WHTAmounts.Add(Round(DocumentAmounts.Get(2) * WHTPercent / 100));
        WHTAmounts.Add(Round(DocumentAmounts.Get(4) * WHTPercent / 100));
        WHTAmounts.Add(-Round(DocumentAmounts.Get(1) * WHTPercent / 100));
        WHTAmounts.Add(-Round(DocumentAmounts.Get(3) * WHTPercent / 100));
    end;

    local procedure CreateAppliedPaymentToInvoices(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20]; InvoiceNo: array[20] of Code[20]; AppliedAmount: array[20] of Decimal; WHTPostingSetup: Record "Withholding Tax Posting Setup"; InvoiceCount: Integer)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Index: Integer;
        PaymentAmount: Decimal;
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
          GenJournalLine, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, VendorNo, 0);

        PaymentAmount := 0;
        for Index := 1 to InvoiceCount do begin
            LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, InvoiceNo[Index]);
            LibraryERM.SetAppliestoIdVendor(VendorLedgerEntry);
            VendorLedgerEntry."Applies-to ID" := GenJournalLine."Document No.";
            VendorLedgerEntry.Validate("Amount to Apply", -AppliedAmount[Index]);
            VendorLedgerEntry.Modify(true);
            PaymentAmount += AppliedAmount[Index];
        end;

        GenJournalLine."Skip Withholding Tax" := false;
        GenJournalLine.Validate("Applies-to ID", GenJournalLine."Document No.");
        GenJournalLine.Validate(Amount, PaymentAmount);
        GenJournalLine.Validate("Wthldg. Tax Bus. Post. Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        GenJournalLine.Validate("Wthldg. Tax Prod. Post. Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");
        GenJournalLine.Modify(true);
    end;

    local procedure CreateAndPostPurchCrMemoWithMultiplePartialAppln(var PurchaseLine: Record "Purchase Line"; WHTPostingSetup: Record "Withholding Tax Posting Setup"; VendorNo: Code[20]; GLAccountNo: Code[20]; InvoiceNo: array[2] of Code[20]; InvAmounts: array[2, 2] of Decimal; Index: Decimal): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", VendorNo);
        PurchaseHeader.Validate("Applies-to ID", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccountNo, 1);
        PurchaseLine.Validate("Wthldg. Tax Bus. Post. Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        PurchaseLine.Validate("Wthldg. Tax Prod. Post. Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");
        PurchaseLine.Validate("Direct Unit Cost", (InvAmounts[1] [1] + InvAmounts[2] [1]) * Index);
        PurchaseLine.Modify(true);

        PurchaseHeader.CalcFields(Amount, "Amount Including VAT");
        PurchaseHeader."Doc. Amount Incl. VAT" := PurchaseHeader."Amount Including VAT";
        PurchaseHeader."Doc. Amount VAT" := PurchaseHeader."Amount Including VAT" - PurchaseHeader.Amount;
        PurchaseHeader.Modify(true);

        ApplyPurchCrMemoToInvCustomAmount(InvoiceNo[1], PurchaseHeader."No.", -InvAmounts[1] [2] * Index);
        ApplyPurchCrMemoToInvCustomAmount(InvoiceNo[2], PurchaseHeader."No.", -InvAmounts[2] [2] * Index);

        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure CreateAndPostPurchaseDocumentWithWHT(var PurchaseLine: Record "Purchase Line"; WHTPostingSetup: Record "Withholding Tax Posting Setup"; DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; GLAccountNo: Code[20]; CurrencyCode: Code[10]) DocumentNo: Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        CreatePurchaseDocument(PurchaseLine, WHTPostingSetup, DocumentType, VendorNo, GLAccountNo, CurrencyCode);
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup: Record "Withholding Tax Posting Setup"; DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; GLAccountNo: Code[20]; Amount: Decimal) DocumentNo: Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, VendorNo, '');
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccountNo, 1);
        PurchaseLine.Validate("Direct Unit Cost", Amount);
        PurchaseLine.Validate("Wthldg. Tax Bus. Post. Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        PurchaseLine.Validate("Wthldg. Tax Prod. Post. Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");
        PurchaseLine.Modify(true);
        PurchaseHeader.CalcFields(Amount, "Amount Including VAT");
        PurchaseHeader."Doc. Amount Incl. VAT" := PurchaseHeader."Amount Including VAT";
        PurchaseHeader."Doc. Amount VAT" := PurchaseHeader."Amount Including VAT" - PurchaseHeader.Amount;
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure CreatePurchaseDocumentWithWHTWithAppliesToID(var PurchaseHeader: Record "Purchase Header"; WHTPostingSetup: Record "Withholding Tax Posting Setup"; DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; GLAccountNo: Code[20]; CurrencyCode: Code[10]; ApplyToDocNo: Code[20]; Qty: Decimal; ApplnAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, VendorNo, CurrencyCode);
        PurchaseHeader."Applies-to ID" := PurchaseHeader."No.";
        PurchaseHeader.Modify();
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, WHTPostingSetup, GLAccountNo);
        PurchaseLine.Validate(Quantity, Qty);
        PurchaseLine.Validate("Direct Unit Cost", ApplnAmount);
        PurchaseLine.Modify(true);

        PurchaseHeader.CalcFields(Amount, "Amount Including VAT");
        PurchaseHeader."Doc. Amount Incl. VAT" := PurchaseHeader."Amount Including VAT";
        PurchaseHeader."Doc. Amount VAT" := PurchaseHeader."Amount Including VAT" - PurchaseHeader.Amount;
        PurchaseHeader.Modify(true);

        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, ApplyToDocNo);
        VendorLedgerEntry.CalcFields(Amount);
        VendorLedgerEntry."Applies-to ID" := PurchaseHeader."No.";
        VendorLedgerEntry."Amount to Apply" := VendorLedgerEntry.Amount;
        VendorLedgerEntry.Modify();
    end;

    local procedure CreateAndPostPurchaseDocumentWithWHTAndAppliesToDocNo(WHTPostingSetup: Record "Withholding Tax Posting Setup"; DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; GLAccountNo: Code[20]; ApplyToDocNo: Code[20]; Qty: Decimal; ApplnAmount: Decimal) DocumentNo: Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, VendorNo, '');
        PurchaseHeader.Validate("Applies-to Doc. Type", PurchaseHeader."Applies-to Doc. Type"::Invoice);
        PurchaseHeader.Validate("Applies-to Doc. No.", ApplyToDocNo);
        PurchaseHeader.Modify();
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, WHTPostingSetup, GLAccountNo);
        PurchaseLine.Validate(Quantity, Qty);
        PurchaseLine.Validate("Direct Unit Cost", ApplnAmount);
        PurchaseLine.Modify(true);
        PurchaseHeader.CalcFields(Amount, "Amount Including VAT");
        PurchaseHeader."Doc. Amount Incl. VAT" := PurchaseHeader."Amount Including VAT";
        PurchaseHeader."Doc. Amount VAT" := PurchaseHeader."Amount Including VAT" - PurchaseHeader.Amount;
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure CreateMultiplePostedPurchDocumentsWithAppliesToID(var AppliesToID: Code[50]; var DocAmount: List of [Decimal]; var TotalDocAmount: Decimal; WHTPostingSetup: Record "Withholding Tax Posting Setup"; VendorNo: Code[20]; GLAccountNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchaseHeader: Record "Purchase Header";
        DocumentType: List of [Integer];
        DocumentNo: Code[20];
        i: Integer;
    begin
        DocAmount.Add(LibraryRandom.RandDecInRange(1000, 2000, 2));
        DocAmount.Add(DocAmount.Get(1) - LibraryRandom.RandDecInRange(100, 200, 2));
        DocAmount.Add(DocAmount.Get(2) - LibraryRandom.RandDecInRange(100, 200, 2));
        DocAmount.Add(DocAmount.Get(3) - LibraryRandom.RandDecInRange(100, 200, 2));

        DocumentType.Add(PurchaseHeader."Document Type"::Invoice.AsInteger());
        DocumentType.Add(PurchaseHeader."Document Type"::"Credit Memo".AsInteger());
        DocumentType.Add(PurchaseHeader."Document Type"::Invoice.AsInteger());
        DocumentType.Add(PurchaseHeader."Document Type"::"Credit Memo".AsInteger());

        for i := 1 to DocumentType.Count do begin
            DocumentNo :=
              CreateAndPostPurchaseDocumentWithWHTAndAmount(
                WHTPostingSetup, "Purchase Document Type".FromInteger(DocumentType.Get(i)), VendorNo, GLAccountNo, DocAmount.Get(i));
            LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, "Gen. Journal Document Type".FromInteger(DocumentType.Get(i)), DocumentNo);
            LibraryERM.SetAppliestoIdVendor(VendorLedgerEntry);
        end;

        AppliesToID := VendorLedgerEntry."Applies-to ID";
        TotalDocAmount := DocAmount.Get(1) - DocAmount.Get(2) + DocAmount.Get(3) - DocAmount.Get(4);
    end;

    local procedure CreateBankAccount(CurrencyCode: Code[10]): Code[20]
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Currency Code", CurrencyCode);
        BankAccount.Modify(true);
        exit(BankAccount."No.");
    end;

    local procedure CreateVendorNoWithoutABN(VATBusPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; WHTBusPostingGroup: Code[20]) VendorNo: Code[20]
    begin
        VendorNo := LibraryPurchase.CreateVendorWithVATBusPostingGroup(VATBusPostingGroup);
        UpdateVendor(VendorNo, false, '', GenBusPostingGroup, WHTBusPostingGroup);
    end;

    local procedure CreateCurrencyWithExchangeRate(): Code[10]
    var
        Currency: Record Currency;
    begin
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.SetCurrencyGainLossAccounts(Currency);
        Currency.Validate("Invoice Rounding Precision", LibraryERM.GetInvoiceRoundingPrecisionLCY());
        Currency.Validate("Residual Gains Account", Currency."Realized Gains Acc.");
        Currency.Validate("Residual Losses Account", Currency."Realized Losses Acc.");
        Currency.Modify(true);

        // Create Currency Exchange Rate.
        LibraryERM.CreateRandomExchangeRate(Currency.Code);
        exit(Currency.Code);
    end;

    local procedure CreateGeneralJournalLineWithCurrency(var GenJournalLine: Record "Gen. Journal Line"; WHTPostingSetup: Record "Withholding Tax Posting Setup"; AccountType: Enum "Gen. Journal Account Type"; DocumentType: Enum "Gen. Journal Document Type"; AccountNo: Code[20]; AppliesToDocNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch, WHTPostingSetup, DocumentType, AccountType, AccountNo, AppliesToDocNo, CurrencyCode, Amount);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", CreateBankAccount(CurrencyCode));
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGenJnlLineWithAppliesToID(var GenJournalLine: Record "Gen. Journal Line"; WHTPostingSetup: Record "Withholding Tax Posting Setup"; AccountType: Enum "Gen. Journal Account Type"; DocumentType: Enum "Gen. Journal Document Type"; AccountNo: Code[20]; AppliesToID: Code[50]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch, WHTPostingSetup, DocumentType, AccountType, AccountNo, '', '', Amount);
        GenJournalLine.Validate("Document No.", LibraryRandom.RandText(10));
        GenJournalLine.Validate("Applies-to ID", AppliesToID);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", LibraryERM.CreateBankAccountNo());
        GenJournalLine.Validate("Bank Payment Type", GenJournalLine."Bank Payment Type"::"Computer Check");
        GenJournalLine.Modify(true);
    end;

    local procedure CreateAndPostGenJnlLineVendorAndSetAppliesToID(var VendorLedgerEntry: Record "Vendor Ledger Entry"; WHTPostingSetup: Record "Withholding Tax Posting Setup"; DocumentType: Enum "Gen. Journal Document Type"; AccountNo: Code[20]; Amount: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        CreateGeneralJournalLineWithCurrency(
          GenJournalLine, WHTPostingSetup, GenJournalLine."Account Type"::Vendor, DocumentType, AccountNo, '', '', Amount);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, DocumentType, GenJournalLine."Document No.");
        LibraryERM.SetAppliestoIdVendor(VendorLedgerEntry);
    end;

    local procedure CreateGeneralJnlLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; WHTPostingSetup: Record "Withholding Tax Posting Setup"; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; AppliesToDocNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal)
    begin
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, DocumentType, AccountType, AccountNo, Amount);
        GenJournalLine.Validate("Currency Code", CurrencyCode);
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Document Type"::Invoice);
        GenJournalLine.Validate("Applies-to Doc. No.", AppliesToDocNo);
        GenJournalLine.Validate("Wthldg. Tax Bus. Post. Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        GenJournalLine.Validate("Wthldg. Tax Prod. Post. Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");
        GenJournalLine.Validate("Skip Withholding Tax", false);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGLAccount(VATProdPostingGroup: Code[20]; WHTProdPostingGroup: Code[20]): Code[20]
    var
        GLAccount: Record "G/L Account";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
    begin
        LibraryERM.FindGenProductPostingGroup(GenProductPostingGroup);
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Gen. Prod. Posting Group", GenProductPostingGroup.Code);
        GLAccount.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        GLAccount.Validate("Wthldg. Tax Prod. Post. Group", WHTProdPostingGroup);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    local procedure CreateGLAccountWithPostingSetup(VATProdPostingGroup: Code[20]; GenProductPostingGroup: Code[20]; WHTProdPostingGroup: Code[20]): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Gen. Prod. Posting Group", GenProductPostingGroup);
        GLAccount.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        GLAccount.Validate("Wthldg. Tax Prod. Post. Group", WHTProdPostingGroup);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    local procedure CreatePurchaseDocument(var PurchaseLine: Record "Purchase Line"; WHTPostingSetup: Record "Withholding Tax Posting Setup"; DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; GLAccountNo: Code[20]; CurrencyCode: Code[10])
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, VendorNo, CurrencyCode);
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, WHTPostingSetup, GLAccountNo);
        PurchaseHeader.CalcFields(Amount, "Amount Including VAT");
        PurchaseHeader."Doc. Amount Incl. VAT" := PurchaseHeader."Amount Including VAT";
        PurchaseHeader."Doc. Amount VAT" := PurchaseHeader."Amount Including VAT" - PurchaseHeader.Amount;
        PurchaseHeader.Modify(true);
    end;

    local procedure CreatePurchaseLine(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; WHTPostingSetup: Record "Withholding Tax Posting Setup"; GLAccountNo: Code[20])
    begin
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccountNo,
          LibraryRandom.RandDecInRange(10, 20, 2));  // Random as Quantity.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(100, 200, 2));
        PurchaseLine.Validate("Wthldg. Tax Bus. Post. Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        PurchaseLine.Validate("Wthldg. Tax Prod. Post. Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");
        PurchaseLine.Modify(true);
    end;

    local procedure CreatePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; Currencycode: Code[10])
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Validate("Currency Code", Currencycode);
        PurchaseHeader.Modify(true);
    end;

    local procedure CreateMultipleGeneralJnlLine(var GenJournalLine: Record "Gen. Journal Line"; WHTPostingSetup: Record "Withholding Tax Posting Setup"; AccountNo: Code[20]; AccountNo2: Code[20]; AppliesToDocNo: Code[20]; GLAccountNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal; Amount2: Decimal; Amount3: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch, WHTPostingSetup, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor,
          AccountNo, AppliesToDocNo, CurrencyCode, Amount);
        CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch, WHTPostingSetup, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::"Bank Account", AccountNo2, '', CurrencyCode, Amount2);
        CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch, WHTPostingSetup, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::"G/L Account", GLAccountNo, '', CurrencyCode, Amount3);
    end;

    local procedure CreateWHTPostingSetup(var WHTPostingSetup: Record "Withholding Tax Posting Setup"; WHTPct: Decimal)
    var
        WHTBusinessPostingGroup: Record "Wthldg. Tax Bus. Post. Group";
        WHTProductPostingGroup: Record "Wthldg. Tax Prod. Post. Group";
    begin
        LibraryWithholdingTax.CreateWHTBusinessPostingGroup(WHTBusinessPostingGroup);
        LibraryWithholdingTax.CreateWHTProductPostingGroup(WHTProductPostingGroup);
        CreateWHTPostingSetupWithRealizedWHTType(
          WHTPostingSetup, WHTBusinessPostingGroup.Code, WHTProductPostingGroup.Code,
          WHTPostingSetup."Realized Withholding Tax Type"::Invoice, WHTPct);
    end;

    local procedure CreateWHTPostingSetupWithRealizedWHTType(var WHTPostingSetup: Record "Withholding Tax Posting Setup"; WHTBusinessPostingGroup: Code[20]; WHTProductPostingGroup: Code[20]; RealizedWHTType: Option; WHTPct: Decimal)
    var
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        LibraryWithholdingTax.CreateWHTPostingSetup(WHTPostingSetup, WHTBusinessPostingGroup, WHTProductPostingGroup);
        LibraryERM.CreateGLAccount(GLAccount);
        WHTPostingSetup.Validate("Withholding Tax %", WHTPct);
        WHTPostingSetup.Validate("Realized Withholding Tax Type", RealizedWHTType);
        WHTPostingSetup.Validate("Prepaid Wthldg. Tax Acc. Code", GLAccount."No.");
        WHTPostingSetup.Validate("Payable Wthldg. Tax Acc. Code", WHTPostingSetup."Prepaid Wthldg. Tax Acc. Code");
        WHTPostingSetup.Validate("Wthldg. Tax Min. Inv. Amount", LibraryRandom.RandDecInRange(60, 90, 2));
        WHTPostingSetup.Validate("Bal. Payable Account No.", BankAccount."No.");
        WHTPostingSetup.Modify(true);
    end;

    local procedure InitScenarioForWHTApplication(var WHTPostingSetup: Record "Withholding Tax Posting Setup"; var VendorNo: Code[20]; var GLAccountNo: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        UpdateGeneralLedgerSetup(true, false);
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
        VendorNo := CreateVendorWithPostingGroup(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        GLAccountNo := CreateGLAccount(VATPostingSetup."VAT Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");
    end;

    local procedure FindCurrencyFactor(CurrencyCode: Code[10]): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        if CurrencyCode = '' then
            exit(1);  // If Blank Currency Code, use Currency factor 1.
        CurrencyExchangeRate.SetRange("Currency Code", CurrencyCode);
        CurrencyExchangeRate.FindFirst();
        exit(CurrencyExchangeRate."Exchange Rate Amount" / CurrencyExchangeRate."Relational Exch. Rate Amount");
    end;

    local procedure FindLineAmount(DocumentType: Enum "Gen. Journal Document Type"; Amount: Decimal): Decimal
    begin
        if DocumentType = "Gen. Journal Document Type"::Invoice then
            exit(-Amount);
        exit(Amount);
    end;

    local procedure CreateWHTPostingSetup(var WHTPostingSetup: Record "Withholding Tax Posting Setup")
    var
        WHTBusinessPostingGroup: Record "Wthldg. Tax Bus. Post. Group";
        WHTProductPostingGroup: Record "Wthldg. Tax Prod. Post. Group";
    begin
        LibraryWithholdingTax.CreateWHTBusinessPostingGroup(WHTBusinessPostingGroup);
        LibraryWithholdingTax.CreateWHTProductPostingGroup(WHTProductPostingGroup);
        CreateWHTPostingSetupWithRealizedWHTType(
        WHTPostingSetup, WHTBusinessPostingGroup.Code, WHTProductPostingGroup.Code, WHTPostingSetup."Realized Withholding Tax Type"::Payment, LibraryRandom.RandIntInRange(30, 40));
    end;

    local procedure FindAndUpdateSetupsWithGSTAndWHTAndZeroVAT(var VATPostingSetup: Record "VAT Posting Setup"; var WHTPostingSetup: Record "Withholding Tax Posting Setup")
    begin
        UpdateGeneralLedgerSetup(true, false);
        LibraryERM.FindZeroVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateWHTPostingSetup(WHTPostingSetup);
    end;

    local procedure GetWHTEntryAmount(DocumentNo: Code[20]): Decimal
    var
        WHTEntry: Record "Withholding Tax Entry";
    begin
        WHTEntry.SetRange("Document No.", DocumentNo);
        WHTEntry.FindFirst();
        exit(WHTEntry."Unrealized Base");
    end;

    local procedure PostInvoice(VendorNo: Code[20]; InvoiceAmount: Decimal; WHTPostingSetup: Record "Withholding Tax Posting Setup"): Code[20]
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
          GenJournalLine, GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Vendor, VendorNo, InvoiceAmount);
        GenJournalLine.Validate("Wthldg. Tax Bus. Post. Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        GenJournalLine.Validate("Wthldg. Tax Prod. Post. Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        exit(GenJournalLine."Document No.");
    end;

    local procedure PostedPurchaseInvoiceLCY(var PurchaseLine: Record "Purchase Line"; VATPostingSetup: Record "VAT Posting Setup"; WHTPostingSetup: Record "Withholding Tax Posting Setup"; VendorNo: Code[20]): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(
          CreateAndPostPurchaseDocumentWithWHT(
            PurchaseLine, WHTPostingSetup, PurchaseHeader."Document Type"::Invoice, VendorNo,
            CreateGLAccount(VATPostingSetup."VAT Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"), ''));
    end;

    local procedure PostAppliedPaymentToInvoices(VendorNo: Code[20]; InvoiceNo: array[20] of Code[20]; AppliedAmount: array[20] of Decimal; WHTPostingSetup: Record "Withholding Tax Posting Setup"; InvoiceCount: Integer): Code[20]
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        CreateAppliedPaymentToInvoices(GenJournalLine, VendorNo, InvoiceNo, AppliedAmount, WHTPostingSetup, InvoiceCount);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        exit(GenJournalLine."Document No.");
    end;

    local procedure SetCheckPrinted(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."Check Printed" := true;
        GenJournalLine.Modify();
    end;

    local procedure SetAppliesToIDVendorDocument(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]) AppliesToID: Code[50]
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, DocumentType, DocumentNo);
        LibraryERM.SetAppliestoIdVendor(VendorLedgerEntry);
        AppliesToID := VendorLedgerEntry."Applies-to ID";
    end;

    local procedure UnapplyVendorLedgerEntry(DocumentNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Payment, DocumentNo);
        VendEntryApplyPostedEntries.UnApplyVendLedgEntry(VendorLedgerEntry."Entry No.");
    end;

    local procedure UpdateGeneralLedgerSetup(EnableWHT: Boolean; RoundAmountForWHTCalc: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Enable Withholding Tax", EnableWHT);
        GeneralLedgerSetup.Validate("Round Amount Wthldg. Tax Calc", RoundAmountForWHTCalc);
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure UpdateAdditionalCurrency(CurrencyCode: Code[10])
    var
        GLAccount: Record "G/L Account";
    begin
        // Call the Adjust Add. Reporting Currency Report.
        UpdateGLSetupAdditionalReportingCurrency(CurrencyCode);
        LibraryERM.FindGLAccount(GLAccount);
        LibraryERM.RunAddnlReportingCurrency(CurrencyCode, CurrencyCode, GLAccount."No.");
    end;

    local procedure UpdateGLSetupAdditionalReportingCurrency(AdditionalReportingCurrency: Code[10])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Additional Reporting Currency" := AdditionalReportingCurrency;
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure UpdateVATBusPostingGroupOnGLAccount(No: Code[20]; VATBusPostingGroup: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(No);
        GLAccount.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        GLAccount.Validate("Gen. Posting Type", GLAccount."Gen. Posting Type"::Purchase);
        GLAccount.Modify(true);
    end;

    local procedure UpdateVendor(VendorNo: Code[20]; Registered: Boolean; ABN: Text[11]; GenBusPostingGroup: Code[20]; WHTBusPostingGroup: Code[20])
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(VendorNo);
        Vendor."Gen. Bus. Posting Group" := GenBusPostingGroup;
        Vendor."Withholding Tax Liable" := true;
        Vendor."Wthldg. Tax Bus. Post. Group" := WHTBusPostingGroup;
        Vendor."WHT Registered" := Registered;
        Vendor."WHT ABN" := ABN;
        Vendor.Modify();
    end;

    local procedure VerifyAmountAndBaseOnWHTEntry(DocumentNo: Code[20]; Amount: Decimal; Base: Decimal)
    var
        WHTEntry: Record "Withholding Tax Entry";
    begin
        WHTEntry.SetRange("Original Document No.", DocumentNo);
        WHTEntry.FindFirst();
        Assert.AreNearlyEqual(
          Amount, WHTEntry.Amount, LibraryERM.GetAmountRoundingPrecision(), StrSubstNo(AmountErr, WHTEntry.FieldCaption(Amount), Amount));
        Assert.AreNearlyEqual(
          Base, WHTEntry.Base, LibraryERM.GetAmountRoundingPrecision(), StrSubstNo(AmountErr, WHTEntry.FieldCaption(Base), Base));
    end;

    local procedure VerifyAmountOnBankLedgerEntry(DocumentNo: Code[20]; Amount: Decimal; BankAccountNo: Code[20])
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccountLedgerEntry.SetRange("Document No.", DocumentNo);
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccountNo);
        BankAccountLedgerEntry.FindFirst();
        Assert.AreNearlyEqual(
          Amount, BankAccountLedgerEntry.Amount, LibraryERM.GetAmountRoundingPrecision(),
          StrSubstNo(AmountErr, Amount, BankAccountLedgerEntry.FieldCaption(Amount)));
    end;

    local procedure VerifyAmountOnGLEntry(DocumentNo: Code[20]; GLAccountNo: Code[20]; Amount: Decimal)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.FindFirst();
        Assert.AreNearlyEqual(
          Amount, GLEntry.Amount, LibraryERM.GetAmountRoundingPrecision(), StrSubstNo(AmountErr, GLEntry.FieldCaption(Amount), Amount));
    end;

    local procedure VerifyAmountOnMultipleGLEntries(DocumentNo: Code[20]; GLAccountNo: Code[20]; Amounts: List of [Decimal])
    var
        GLEntry: Record "G/L Entry";
        i: Integer;
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.FindSet();
        repeat
            i += 1;
            Assert.AreNearlyEqual(
              Amounts.Get(i), GLEntry.Amount, LibraryERM.GetAmountRoundingPrecision(), StrSubstNo(AmountErr, GLEntry.FieldCaption(Amount), Amounts.Get(i)));
        until GLEntry.Next() = 0;
    end;

    local procedure VerifyAmountOnGLEntries(GenJournalLine: Record "Gen. Journal Line"; DocumentNo: Code[20]; GLAccountNo: Code[20]; Amount: Decimal; Amount2: Decimal)
    begin
        VerifyPostedGenJournalLineAmountOnGLEntry(
          DocumentNo, GenJournalLine."Bal. Account Type"::Vendor, GenJournalLine."Account No.", LesserThanErr,
          GenJournalLine.Amount / FindCurrencyFactor(GenJournalLine."Currency Code"));
        VerifyPostedGenJournalLineAmountOnGLEntry(
          DocumentNo, GenJournalLine."Bal. Account Type"::"Bank Account", GenJournalLine."Bal. Account No.", LesserThanErr,
          -Amount / FindCurrencyFactor(GenJournalLine."Currency Code"));
        VerifyPostedGenJournalLineAmountOnGLEntry(
          DocumentNo, GenJournalLine."Bal. Account Type"::"G/L Account", GLAccountNo, GreaterThanErr,
          -Amount2 / FindCurrencyFactor(GenJournalLine."Currency Code"));
    end;

    local procedure VerifyGeneralLedgerAndWHTEntry(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; GLAccountNo: Code[20]; LineAmount: Decimal; WHTPct: Decimal)
    var
        Amount: Decimal;
    begin
        LineAmount := FindLineAmount(DocumentType, LineAmount);
        Amount := WHTPct * LineAmount / 100;
        VerifyAmountOnGLEntry(DocumentNo, GLAccountNo, -Amount);
        VerifyAmountAndBaseOnWHTEntry(DocumentNo, Amount, LineAmount);
    end;

    local procedure VerifyWHTEntriesAndGLEntry(DocumentNo: Code[20]; GLAccountNo: Code[20]; LineAmount: Decimal; WHTPct: Decimal; VATPct: Decimal; Index: Decimal)
    var
        Amount: Decimal;
        GLEntryAmount: Decimal;
    begin
        Amount := LineAmount * WHTPct / 100;
        GLEntryAmount := LineAmount * VATPct / 100;
        VerifyAmountOnGLEntry(DocumentNo, GLAccountNo, GLEntryAmount);
        VerifyUnrealizedAmountAndBaseOnWHTEntry(DocumentNo, Amount, LineAmount, Amount * (1 - Index), LineAmount * (1 - Index), false);
    end;

    local procedure VerifyPostedGenJournalLineAmountOnGLEntry(DocumentNo: Code[20]; BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; AmountFilter: Text[10]; Amount: Decimal)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Bal. Account Type", BalAccountType);
        GLEntry.SetRange("Bal. Account No.", BalAccountNo);
        GLEntry.SetFilter(Amount, AmountFilter, 0);
        GLEntry.FindFirst();
        Assert.AreNearlyEqual(
          Amount, GLEntry.Amount, LibraryERM.GetAmountRoundingPrecision(), StrSubstNo(AmountErr, GLEntry.FieldCaption(Amount), Amount));
    end;

    local procedure VerifyUnrealizedAmountAndBaseOnWHTEntry(DocumentNo: Code[20]; UnrealizedAmount: Decimal; UnrealizedBase: Decimal; RemainingUnrAmount: Decimal; RemainingUnrBase: Decimal; IsClosed: Boolean)
    var
        WHTEntry: Record "Withholding Tax Entry";
    begin
        WHTEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordCount(WHTEntry, 1);
        WHTEntry.FindFirst();

        Assert.AreNearlyEqual(
          UnrealizedAmount, WHTEntry."Unrealized Amount", LibraryERM.GetAmountRoundingPrecision(),
          StrSubstNo(AmountErr, WHTEntry.FieldCaption("Unrealized Amount"), UnrealizedAmount));
        Assert.AreNearlyEqual(
          UnrealizedBase, WHTEntry."Unrealized Base", LibraryERM.GetAmountRoundingPrecision(),
          StrSubstNo(AmountErr, WHTEntry.FieldCaption("Unrealized Base"), UnrealizedBase));

        Assert.AreNearlyEqual(
          RemainingUnrAmount, WHTEntry."Remaining Unrealized Amount", LibraryERM.GetAmountRoundingPrecision(),
          StrSubstNo(AmountErr, WHTEntry.FieldCaption("Remaining Unrealized Amount"), RemainingUnrAmount));
        Assert.AreNearlyEqual(
          RemainingUnrBase, WHTEntry."Remaining Unrealized Base", LibraryERM.GetAmountRoundingPrecision(),
          StrSubstNo(AmountErr, WHTEntry.FieldCaption("Remaining Unrealized Base"), RemainingUnrBase));

        Assert.AreNearlyEqual(
          RemainingUnrAmount, WHTEntry."Rem Unrealized Amount (LCY)",
          LibraryERM.GetAmountRoundingPrecision(), WHTEntry.FieldCaption("Rem Unrealized Amount (LCY)"));
        Assert.AreNearlyEqual(
          RemainingUnrBase, WHTEntry."Rem Unrealized Base (LCY)",
          LibraryERM.GetAmountRoundingPrecision(), WHTEntry.FieldCaption("Rem Unrealized Base (LCY)"));

        Assert.AreEqual(IsClosed, WHTEntry.Closed,
          StrSubstNo(IncorrectFieldValueErr, WHTEntry.FieldCaption(Closed)));
    end;

    local procedure VerifyCrMemoUnrealizedAmountAndBaseOnWHTEntry(DocumentNo: Code[20]; UnrealizedAmount: Decimal; UnrealizedBase: Decimal; RemainingUnrAmount: Decimal; RemainingUnrBase: Decimal)
    var
        WHTEntry: Record "Withholding Tax Entry";
    begin
        WHTEntry.SetRange("Document No.", DocumentNo);
        WHTEntry.FindFirst();

        Assert.AreNearlyEqual(
          UnrealizedAmount, WHTEntry."Unrealized Amount", LibraryERM.GetAmountRoundingPrecision(),
          StrSubstNo(AmountErr, WHTEntry.FieldCaption("Unrealized Amount"), UnrealizedAmount));
        Assert.AreNearlyEqual(
          UnrealizedBase, WHTEntry."Unrealized Base", LibraryERM.GetAmountRoundingPrecision(),
          StrSubstNo(AmountErr, WHTEntry.FieldCaption("Unrealized Base"), UnrealizedBase));

        Assert.AreNearlyEqual(
          RemainingUnrAmount, WHTEntry."Remaining Unrealized Amount", LibraryERM.GetAmountRoundingPrecision(),
          StrSubstNo(AmountErr, WHTEntry.FieldCaption("Remaining Unrealized Amount"), RemainingUnrAmount));
        Assert.AreNearlyEqual(
          RemainingUnrBase, WHTEntry."Remaining Unrealized Base", LibraryERM.GetAmountRoundingPrecision(),
          StrSubstNo(AmountErr, WHTEntry.FieldCaption("Remaining Unrealized Base"), RemainingUnrBase));

        Assert.AreNearlyEqual(
          RemainingUnrAmount, WHTEntry."Rem Unrealized Amount (LCY)",
          LibraryERM.GetAmountRoundingPrecision(), WHTEntry.FieldCaption("Rem Unrealized Amount (LCY)"));
        Assert.AreNearlyEqual(
          RemainingUnrBase, WHTEntry."Rem Unrealized Base (LCY)",
          LibraryERM.GetAmountRoundingPrecision(), WHTEntry.FieldCaption("Rem Unrealized Base (LCY)"));
    end;

    local procedure VerifyPaymentWHTEntries(PaymentNo: Code[20]; WHTPayableGLAccountNo: Code[20])
    var
        WHTEntry: Record "Withholding Tax Entry";
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Payment);
        GLEntry.SetRange("G/L Account No.", WHTPayableGLAccountNo);
        GLEntry.SetRange("Document No.", PaymentNo);
        GLEntry.SetCurrentKey(Amount);
        GLEntry.SetAscending(Amount, false);
        GLEntry.FindSet();

        WHTEntry.SetRange("External Document No.", PaymentNo);
        WHTEntry.SetRange("Document Type", WHTEntry."Document Type"::Payment);
        WHTEntry.SetCurrentKey(Amount);
        WHTEntry.FindSet();

        repeat
            WHTEntry.TestField(Amount, -GLEntry.Amount);
            WHTEntry.Next();
        until GLEntry.Next() = 0;
    end;

    local procedure CreateMultipleVendors(var VendorNo: array[3] of Code[20]; VATPostingSetup: Record "VAT Posting Setup"; GenBusPostingGroup: Code[20]; WHTBusPostingGroup: Code[20])
    var
        Vendor: Record Vendor;
        i: Integer;
    begin
        for i := 1 to ArrayLen(VendorNo) do begin
            VendorNo[i] := LibraryPurchase.CreateVendorWithVATBusPostingGroup(VATPostingSetup."VAT Bus. Posting Group");
            Vendor.Get(VendorNo[i]);
            Vendor."Gen. Bus. Posting Group" := GenBusPostingGroup;
            Vendor."Withholding Tax Liable" := true;
            Vendor."Wthldg. Tax Bus. Post. Group" := WHTBusPostingGroup;
            Vendor.Modify(true);
        end;
    end;

    local procedure PostMultiplePurchaseInvoice(VendorNo: array[3] of Code[20]; var PostedInvoiceNo: array[3] of Code[20]; var WHTAmount: array[3] of Decimal; WHTPostingSetup: Record "Withholding Tax Posting Setup"; GLAccountNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        i: Integer;
    begin
        for i := 1 to 3 do begin
            PostedInvoiceNo[i] := CreateAndPostPurchaseDocumentWithWHTAndAmount(WHTPostingSetup,
             PurchaseHeader."Document Type"::Invoice, VendorNo[i], GLAccountNo, LibraryRandom.RandIntInRange(i * 1000, i * 1000 + 1000));
            WHTAmount[i] := GetWHTEntryUnrealizedAmount(PostedInvoiceNo[i]);
        end;
    end;

    local procedure PostPurchaseCreditMemoWithWHT(WHTPostingSetup: Record "Withholding Tax Posting Setup"; VendorNo: Code[20]; GLAccountNo: Code[20]; PostedInvoiceNo: Code[20]) PostedCreditMemoNo: Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchaseDocument(PurchaseLine, WHTPostingSetup, PurchaseHeader."Document Type"::"Credit Memo", VendorNo, GLAccountNo, '');
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Applies-to Doc. Type", PurchaseHeader."Applies-to Doc. Type"::Invoice);
        PurchaseHeader.Validate("Applies-to Doc. No.", PostedInvoiceNo);
        PurchaseHeader.Modify(true);

        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(500, 1000));
        PurchaseLine.Modify(true);
        PurchaseHeader.CalcFields(Amount, "Amount Including VAT");
        PurchaseHeader."Doc. Amount Incl. VAT" := PurchaseHeader."Amount Including VAT";
        PurchaseHeader."Doc. Amount VAT" := PurchaseHeader."Amount Including VAT" - PurchaseHeader.Amount;
        PurchaseHeader.Modify(true);
        PostedCreditMemoNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local Procedure GetRemainingAmountFromVendorLedgerEntry(PostedInvoiceNo: array[3] of Code[20]; var Amount: array[3] of Decimal)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        i: Integer;
    begin
        for i := 1 to ArrayLen(PostedInvoiceNo) do begin
            LibraryERM.FindVendorLedgerEntry(
                VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, PostedInvoiceNo[i]);
            VendorLedgerEntry.CalcFields("Remaining Amount");
            Amount[i] := Abs(VendorLedgerEntry."Remaining Amount");
        end;
    end;

    local procedure VerifyWHTAmountOnGlEntry(GenJournalLine: array[3] of Record "Gen. Journal Line"; WHTAmount: array[3] of Decimal; PayableWHTAccountCode: Code[20])
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(GenJournalLine) do
            VerifyAmountOnGLEntry(GenJournalLine[i]."Document No.", PayableWHTAccountCode, -Round(WHTAmount[i]));
    end;

    local procedure CreateAndPostMultipleGeneralJournalLineWithCurrency(
      var GenJournalLine: array[3] of Record "Gen. Journal Line";
      WHTPostingSetup: Record "Withholding Tax Posting Setup";
      AccountType: Enum "Gen. Journal Account Type";
      DocumentType: Enum "Gen. Journal Document Type";
      AccountNo: array[3] of Code[20];
      AppliesToDocNo: array[3] of Code[20];
      CurrencyCode: Code[10];
      Amount: array[3] of Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        BankAccountCode: Code[20];
        i: Integer;
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        BankAccountCode := CreateBankAccount(CurrencyCode);
        for i := 1 to ArrayLen(GenJournalLine) do begin
            CreateGeneralJnlLine(
                     GenJournalLine[i], GenJournalBatch, WHTPostingSetup, DocumentType, AccountType, AccountNo[i], AppliesToDocNo[i], CurrencyCode, Amount[i]);
            GenJournalLine[i].Validate("Document No.", NoSeriesBatch.GetNextNo(GenJournalBatch."No. Series"));
            GenJournalLine[i].Validate("Bal. Account Type", GenJournalLine[i]."Bal. Account Type"::"Bank Account");
            GenJournalLine[i].Validate("Bal. Account No.", BankAccountCode);
            GenJournalLine[i].Modify(true);
        end;

        LibraryERM.PostGeneralJnlLine(GenJournalLine[1]);
    end;

    local procedure GetWHTEntryUnrealizedAmount(DocumentNo: Code[20]): Decimal
    var
        WHTEntry: Record "Withholding Tax Entry";
    begin
        WHTEntry.SetRange("Document No.", DocumentNo);
        WHTEntry.FindFirst();
        exit(WHTEntry."Unrealized Amount");
    end;

    local procedure CreateVendorWithPostingGroup(VendorBusPostingGroup: Code[20]; WHTBusPostingGroup: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
        VendorNo: Code[20];
    begin
        VendorNo := LibraryPurchase.CreateVendorWithVATBusPostingGroup(VendorBusPostingGroup);
        Vendor.Get(VendorNo);
        Vendor.Validate("Withholding Tax Liable", true);
        Vendor.Validate("Wthldg. Tax Bus. Post. Group", WHTBusPostingGroup);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure UnapplyVendorEntriesPageHandler(var UnapplyVendorEntries: TestPage "Unapply Vendor Entries")
    begin
        UnapplyVendorEntries.Unapply.Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}