// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Tests.WithholdingTax;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.WithholdingTax;
using System.TestLibraries.Utilities;

codeunit 148322 "ERM Withholding Tax Tests II"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = Uncategorized;

    trigger OnRun()
    begin
        // [FEATURE] [Withholding Tax]
    end;

    var
        Assert: Codeunit Assert;
        LibraryWithholdingTax: Codeunit "Library - Withholding Tax";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        ValueMustBeSameMsg: Label 'Value must be same.';
        WHTAccountCodeEmptyErr: Label '%1 must have a value in Withholding Tax Posting Setup: Withholding Tax Bus. Post. Group=%2, Withholding Tax Prod. Post. Group=%3. It cannot be zero or empty.',
                                Comment = '%1 = Field Caption, %2 = WHT Business Posting Group Code, %3 = WHT Product Posting Group Code';
        IsInitialized: Boolean;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTEntryOfPostedInvoiceJnlAndPaymentJnl()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTEntry: Record "Withholding Tax Entry";
        WHTBusPostingGroup: Record "Wthldg. Tax Bus. Post. Group";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        WHTProdPostingGroup: Record "Wthldg. Tax Prod. Post. Group";
        DocumentNo: Code[20];
        WHTAmount: Decimal;
    begin
        // [SCENARIO 285194] WHT Entry Amount after post a Purchase transaction through Purchase Journals then make payment.

        // [GIVEN] Create and Post Purchase Journal with Document Type - Invoice, Create and Post Payment Journal.
        Initialize();
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryWithholdingTax.CreateWHTBusinessPostingGroup(WHTBusPostingGroup);
        LibraryWithholdingTax.CreateWHTProductPostingGroup(WHTProdPostingGroup);
        CreateGeneralJournalLineWithBalAccountType(
          GenJournalLine, GenJournalLine."Document Type"::Invoice, CreateVendor(VATPostingSetup."VAT Bus. Posting Group", WHTBusPostingGroup.Code), '',
          '', GenJournalLine."Bal. Account Type"::"G/L Account", CreateGLAccountWithVATBusPostingGroup(VATPostingSetup, WHTProdPostingGroup.Code),
          -LibraryRandom.RandDecInRange(100, 200, 2));  // Blank - WHT Bus Posting Group, Applies To Doc. No, Currency, Random - Direct unit cost.
        UpdateGenJournalLineWHTAbsorbBase(GenJournalLine);
        FindWHTPostingSetup(WHTPostingSetup, GenJournalLine."Wthldg. Tax Bus. Post. Group", GenJournalLine."Wthldg. Tax Prod. Post. Group", '');  // Blank Currency Code.
        WHTAmount := GenJournalLine."Withholding Tax Absorb Base" * WHTPostingSetup."Withholding Tax %" / 100;
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        DocumentNo := FindVendorLedgerEntry(GenJournalLine."Account No.");
        LibraryERM.CreateBankAccount(BankAccount);
        CreateGeneralJournalLineWithBalAccountType(
          GenJournalLine2, GenJournalLine."Document Type"::Payment, GenJournalLine."Account No.", DocumentNo,
          '', GenJournalLine2."Bal. Account Type"::"Bank Account", BankAccount."No.", -FindVendorLedgerEntryAmount(DocumentNo));  // Currency - Blank.
        GenJournalLine2.Validate("Wthldg. Tax Prod. Post. Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");
        GenJournalLine2.Modify(true);

        // Exercise.
        LibraryERM.PostGeneralJnlLine(GenJournalLine2);

        // [THEN] Verify WHT Entry - Amount and Unrealized Amount.
        VerifyWHTEntry(WHTEntry."Document Type"::Payment, GenJournalLine."Account No.", -WHTAmount, 0);  // Unrealized Amount - 0.
        VerifyWHTEntry(WHTEntry."Document Type"::Invoice, GenJournalLine."Account No.", 0, -WHTAmount);  // Amount - 0.
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTEntryForPaymentWithManualApplication()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        WHTEntry: Record "Withholding Tax Entry";
        CurrencyCode: Code[10];
        DocumentNo: Code[20];
        WHTAmount: Decimal;
    begin
        // [SCENARIO 285194] Posting of payment without applying it to the invoice and manually apply the invoice and payment entries will create correct WHT Entries.

        // [GIVEN] Create and Post Purchase Order, Create and Post Payment.
        Initialize();
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", 0);
        CurrencyCode := CreateCurrencyWithExchangeRate();
        CreateWHTPostingSetupWithPayableAccount(WHTPostingSetup, CurrencyCode);
        DocumentNo :=
          CreateAndPostPurchaseOrder(
            PurchaseLine, CreateVendor(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group"),
            VATPostingSetup."VAT Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group", CurrencyCode,
            LibraryRandom.RandIntInRange(1000, 10000));  // Random - Direct unit cost.
        CreateGeneralJournalLineWithBalAccountType(
          GenJournalLine, GenJournalLine."Document Type"::Payment, PurchaseLine."Buy-from Vendor No.", '',
          CurrencyCode, GenJournalLine."Bal. Account Type"::"G/L Account", CreateGLAccountWithVATBusPostingGroup(VATPostingSetup, WHTPostingSetup."Wthldg. Tax Prod. Post. Group"),
          -FindVendorLedgerEntryAmount(DocumentNo));  // Blank - Balance Account No.
        GenJournalLine.Validate("Wthldg. Tax Prod. Post. Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        WHTAmount := -Round(GenJournalLine.Amount * WHTPostingSetup."Withholding Tax %" / 100);

        // Exercise: Apply Payment to Invoice.
        ApplyAndPostVendorEntryApplication(GenJournalLine."Document Type"::Payment, GenJournalLine."Document No.");

        // [THEN] Verify WHT Entires created for Payment and invoice.
        VerifyWHTEntry(WHTEntry."Document Type"::Payment, GenJournalLine."Account No.", -WHTAmount, 0);  // Unrealized Amount - 0.
        VerifyWHTEntry(WHTEntry."Document Type"::Invoice, GenJournalLine."Account No.", 0, -WHTAmount);  // Amount - 0.
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTEntryForPartialPaymentsWithDiffAccounts()
    var
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        CurrencyCode: Code[10];
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
        VendorNo: Code[20];
        GenJnlDocNo: array[4] of Code[20];
        Amount: Decimal;
        Amount2: Decimal;
        Amount3: Decimal;
    begin
        // [SCENARIO 285194] WHT Amount, GST Entry for multiple partial payments to the invoices in different months.

        // [GIVEN] Create and Post multiple Purchase Orders, Create and Post multiple Payment Journal for partial payment.
        Initialize();
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", 0);
        CurrencyCode := CreateCurrencyWithExchangeRate();
        VendorNo := CreateVendor(VATPostingSetup."VAT Bus. Posting Group", '');  // Blank WHT Business Posting Group.
        DocumentNo :=
          CreateAndPostPurchaseOrder(
            PurchaseLine, VendorNo, VATPostingSetup."VAT Prod. Posting Group", '',
            CurrencyCode, LibraryRandom.RandIntInRange(1000, 10000));  // Blank - WHT Prod. Posting Group, Random - Direct unit cost.
        Amount := 10 * LibraryRandom.RandInt(10);  // Taking random Amount in multiple of 10.
        Amount2 := -PurchaseLine.Amount + Amount;  // Partial Amount.
        DocumentNo2 :=
          CreateAndPostPurchaseOrder(
            PurchaseLine, VendorNo, VATPostingSetup."VAT Prod. Posting Group", '',
            CurrencyCode, PurchaseLine.Amount + LibraryRandom.RandIntInRange(1100, 10000));  // Blank - WHT Prod. Posting Group, Random - Direct unit cost.
        Amount3 := -PurchaseLine.Amount + Amount;  // Partial Amount.

        // Exercise: Apply multiple Partial Payments for different Accounts of same Vendor.
        CreateAndPostMultiplePartialPayments(GenJnlDocNo, VendorNo, CurrencyCode, DocumentNo, DocumentNo2, Amount, Amount2, Amount3);

        // [THEN] Verify WHT Amounts with Currency and Vendor Ledger Entry closed for all the partial payments.
        VerifyVendorLedgerEntryAndWHTAmount(GenJnlDocNo, VendorNo, CurrencyCode, Amount, Amount2, Amount3);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostApplyPaymentsToWHTAndNormalInvoices()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        NormalGenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        WHTBalAccountNo: Code[20];
        WHTPaymentNo: Code[20];
        TransactionNo: Integer;
    begin
        // [SCENARIO 285194] WHT Payment should be posted in one transaction if we have different Payment lines
        Initialize();

        // [GIVEN] Purchase WHT Invoice = "Inv1"
        UpdateGLSetupAndPurchasesPayablesSetup(VATPostingSetup);
        CreateWHTPostingSetup(WHTPostingSetup, '');
        CreateAndPostVendorWHTInvoice(GenJournalLine, CreateVendor(VATPostingSetup."VAT Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group"), VATPostingSetup, WHTPostingSetup);

        // [GIVEN] Normal Purchase Invoice = "Inv2"
        CreateAndPostVendorInvoice(NormalGenJournalLine, LibraryPurchase.CreateVendorWithVATBusPostingGroup(VATPostingSetup."VAT Bus. Posting Group"));

        // [GIVEN] Use General Journal Batch with No. Series defined
        LibraryJournals.CreateGenJournalBatch(GenJournalBatch);
        GenJournalBatch.Validate("No. Series", LibraryERM.CreateNoSeriesCode());
        GenJournalBatch.Modify(true);

        // [GIVEN] Payment lines within the Batch for "Inv1" and "Inv2"
        CreateApplnVendorWHTPayment(
          GenJournalLine, GenJournalBatch,
          GenJournalLine."Account Type", GenJournalLine."Account No.", -GenJournalLine.Amount,
          GenJournalLine."Applies-to Doc. Type"::Invoice, GenJournalLine."Document No.",
          NoSeriesBatch.GetNextNo(GenJournalBatch."No. Series"), WHTPostingSetup);
        WHTPaymentNo := GenJournalLine."Document No.";
        WHTBalAccountNo := GenJournalLine."Bal. Account No.";

        CreateApplnVendorPayment(
          GenJournalLine, GenJournalBatch,
          NormalGenJournalLine."Account Type", NormalGenJournalLine."Account No.", -NormalGenJournalLine.Amount,
          GenJournalLine."Applies-to Doc. Type"::Invoice, NormalGenJournalLine."Document No.",
          NoSeriesBatch.GetNextNo(GenJournalBatch."No. Series"));

        // [WHEN] Post Gen. Journal Lines
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Transaction No. for "Payable Withholding Acc. Code" is equal to the Transaction No. of WHT Payment for "Inv1"
        GLEntry.SetRange("Document No.", WHTPaymentNo);
        GLEntry.SetRange("G/L Account No.", WHTBalAccountNo);
        GLEntry.FindFirst();
        TransactionNo := GLEntry."Transaction No.";

        GLEntry.SetRange("G/L Account No.", WHTPostingSetup."Payable Wthldg. Tax Acc. Code");
        GLEntry.FindFirst();
        GLEntry.TestField("Transaction No.", TransactionNo);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure ConfirmErrorOnBlankWHTSetupPurchase()
    var
        PurchLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 285194] Meaningful error trying posting purchase invoice with blanked Payable WHT Account Code
        Initialize();
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);

        // [GIVEN] WHT Setup with a blank payable accountCreateWHTPostingSetupWithBlankAccounts(WHTPostingSetup);
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", 0);
        CreateWHTPostingSetupWithBlankAccounts(WHTPostingSetup);

        // [WHEN] Post a purchase invoice with given WHT setup
        asserterror CreateAndPostPurchaseOrder(PurchLine, CreateVendor(VATPostingSetup."VAT Bus. Posting Group", ''),
            VATPostingSetup."VAT Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group",
            '', LibraryRandom.RandDecInRange(1000, 2000, 2));

        // [THEN] 'Payable WHT Account Code must have a value in WHT Posting Setup' error appears
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(StrSubstNo(WHTAccountCodeEmptyErr,
            WHTPostingSetup.FieldCaption("Payable Wthldg. Tax Acc. Code"), '', WHTPostingSetup."Wthldg. Tax Prod. Post. Group"));
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTPostingSetupGetPrepaidWHTAccountUT()
    var
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        WHTBusPostingGroup: Record "Wthldg. Tax Bus. Post. Group";
        WHTProdPostingGroup: Record "Wthldg. Tax Prod. Post. Group";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 285194] WHT Posting Setup's functions GetPrepaidWithholdingAccount returns PrepaidWHTAccount or throws an error when empty
        Initialize();

        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        LibraryWithholdingTax.CreateWHTBusinessPostingGroup(WHTBusPostingGroup);
        LibraryWithholdingTax.CreateWHTProductPostingGroup(WHTProdPostingGroup);
        WHTPostingSetup.Init();
        WHTPostingSetup."Wthldg. Tax Bus. Post. Group" := WHTBusPostingGroup.Code;
        WHTPostingSetup."Wthldg. Tax Prod. Post. Group" := WHTProdPostingGroup.Code;
        asserterror WHTPostingSetup.GetPrepaidWithholdingTaxAccount();
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(StrSubstNo(WHTAccountCodeEmptyErr,
            WHTPostingSetup.FieldCaption("Prepaid Wthldg. Tax Acc. Code"), WHTPostingSetup."Wthldg. Tax Bus. Post. Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"));

        WHTPostingSetup.Init();
        WHTPostingSetup."Prepaid Wthldg. Tax Acc. Code" := LibraryUtility.GenerateGUID();
        WHTPostingSetup."Payable Wthldg. Tax Acc. Code" := LibraryUtility.GenerateGUID();
        Assert.AreEqual(WHTPostingSetup."Prepaid Wthldg. Tax Acc. Code",
          WHTPostingSetup.GetPrepaidWithholdingTaxAccount(), 'WHTPostingSetup.GetPrepaidWithholdingAccount returned wrong data');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure WHTPostingSetupGetPayableWHTAccountUT()
    var
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 285194] WHT Posting Setup's functions GetPayableWithholdingAccount returns PayableWHTAccount or throws an error when empty
        Initialize();

        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        WHTPostingSetup.Init();
        asserterror WHTPostingSetup.GetPayableWithholdingTaxAccount();
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(StrSubstNo(WHTAccountCodeEmptyErr,
            WHTPostingSetup.FieldCaption("Payable Wthldg. Tax Acc. Code"), '', WHTPostingSetup."Wthldg. Tax Prod. Post. Group"));

        WHTPostingSetup.Init();
        WHTPostingSetup."Prepaid Wthldg. Tax Acc. Code" := LibraryUtility.GenerateGUID();
        WHTPostingSetup."Payable Wthldg. Tax Acc. Code" := LibraryUtility.GenerateGUID();
        Assert.AreEqual(WHTPostingSetup."Payable Wthldg. Tax Acc. Code",
          WHTPostingSetup.GetPayableWithholdingTaxAccount(), 'WHTPostingSetup.GetPayableWithholdingAccount returned wrong data');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure JournalPostingNoSeriesLessThanNoSeriesOnePmtOneInv()
    var
        InvoiceGenJournalLine: Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        // [FEATURE] [No. Series] [Journal] [Payment] [Purchase]
        // [SCENARIO 285194] Posting of one payment applied to one invoice with WHT in case of
        // [SCENARIO 285194] journal Posting No Series ("A..") goes before No. Series ("B..")
        Initialize();

        // [GIVEN] Posted purchase invoice with WHT
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        FindWHTPostingSetup(WHTPostingSetup, '', '', '');
        CreateAndPostVendorInvoice(InvoiceGenJournalLine, CreateDefaultVendorNo());

        // [GIVEN] General Journal Batch with No. Series "B0..B9", Posting No. Series "A0..A9"
        CreateGenJournalBatchWithCustomNoSeries(GenJournalBatch, 'B0', 'B9', 'A0', 'A9');

        // [GIVEN] One payment applied to the posted invoice (journal Document No. = "B0")
        CreateOnePmtAppliedToOneInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine, 'B0');

        // [WHEN] Post the payment journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Payment posting produced 3 G/L entries including 1 WHT with Document No. = "A0"
        VerifyPostingNoSeriesOnePostedDoc('A0', 3, 1);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure JournalPostingNoSeriesMoreThanNoSeriesOnePmtOneInv()
    var
        InvoiceGenJournalLine: Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        // [FEATURE] [No. Series] [Journal] [Payment] [Purchase]
        // [SCENARIO 285194] Posting of one payment applied to one invoice with WHT in case of
        // [SCENARIO 285194] journal Posting No Series ("B..") goes after No. Series ("A..")
        Initialize();

        // [GIVEN] Posted purchase invoice with WHT
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        FindWHTPostingSetup(WHTPostingSetup, '', '', '');
        CreateAndPostVendorInvoice(InvoiceGenJournalLine, CreateDefaultVendorNo());

        // [GIVEN] General Journal Batch with No. Series "A0..A9", Posting No. Series "B0..B9"
        CreateGenJournalBatchWithCustomNoSeries(GenJournalBatch, 'A0', 'A9', 'B0', 'B9');

        // [GIVEN] One payment applied to the posted invoice (journal Document No. = "A0")
        CreateOnePmtAppliedToOneInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine, 'A0');

        // [WHEN] Post the payment journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Payment posting produced 3 G/L entries including 1 WHT with Document No. = "B0"
        VerifyPostingNoSeriesOnePostedDoc('B0', 3, 1);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure JournalPostingNoSeriesLessThanNoSeriesOnePmtTwoInv()
    var
        InvoiceGenJournalLine: array[2] of Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        VendorNo: Code[20];
    begin
        // [FEATURE] [No. Series] [Journal] [Payment] [Purchase]
        // [SCENARIO 285194] Posting of one payment applied to two invoices with WHT in case of
        // [SCENARIO 285194] journal Posting No Series ("A..") goes before No. Series ("B..")
        Initialize();

        // [GIVEN] Two posted purchase invoice with WHT
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        FindWHTPostingSetup(WHTPostingSetup, '', '', '');
        VendorNo := CreateDefaultVendorNo();
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[1], VendorNo);
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[2], VendorNo);

        // [GIVEN] General Journal Batch with No. Series "B0..B9", Posting No. Series "A0..A9"
        CreateGenJournalBatchWithCustomNoSeries(GenJournalBatch, 'B0', 'B9', 'A0', 'A9');

        // [GIVEN] One payment applied to the both posted invoices (journal Document No. = "B0")
        CreateOnePmtAppliedToTwoInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine, 'B0');

        // [WHEN] Post the payment journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Payment posting produced 4 G/L entries including 2 WHT with Document No. = "A0"
        VerifyPostingNoSeriesOnePostedDoc('A0', 4, 2);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure JournalPostingNoSeriesMoreThanNoSeriesOnePmtTwoInv()
    var
        InvoiceGenJournalLine: array[2] of Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        VendorNo: Code[20];
    begin
        // [FEATURE] [No. Series] [Journal] [Payment] [Purchase]
        // [SCENARIO 285194] Posting of one payment applied to two invoices with WHT in case of
        // [SCENARIO 285194] journal Posting No Series ("B..") goes after No. Series ("A..")
        Initialize();

        // [GIVEN] Two posted purchase invoices with WHT
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        FindWHTPostingSetup(WHTPostingSetup, '', '', '');
        VendorNo := CreateDefaultVendorNo();
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[1], VendorNo);
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[2], VendorNo);

        // [GIVEN] General Journal Batch with No. Series "A0..A9", Posting No. Series "B0..B9"
        CreateGenJournalBatchWithCustomNoSeries(GenJournalBatch, 'A0', 'A9', 'B0', 'B9');

        // [GIVEN] One payment applied to the both posted invoices (journal Document No. = "A0")
        CreateOnePmtAppliedToTwoInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine, 'A0');

        // [WHEN] Post the payment journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Payment posting produced 4 G/L entries including 2 WHT with Document No. = "B0"
        VerifyPostingNoSeriesOnePostedDoc('B0', 4, 2);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure JournalPostingNoSeriesLessThanNoSeriesTwoPmtTwoInvDiffDocNos()
    var
        InvoiceGenJournalLine: array[2] of Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        // [FEATURE] [No. Series] [Journal] [Payment] [Purchase]
        // [SCENARIO 285194] Posting of two payments each applied to one invoice with WHT in case of
        // [SCENARIO 285194] journal Posting No Series ("A..") goes before No. Series ("B..") and different payment document numbers
        Initialize();

        // [GIVEN] Two posted purchase invoices with WHT
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        FindWHTPostingSetup(WHTPostingSetup, '', '', '');
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[1], CreateDefaultVendorNo());
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[2], CreateDefaultVendorNo());

        // [GIVEN] General Journal Batch with No. Series "B0..B9", Posting No. Series "A0..A9"
        CreateGenJournalBatchWithCustomNoSeries(GenJournalBatch, 'B0', 'B9', 'C0', 'C9');

        // [GIVEN] Two payments each applied to one of the posted invoices (journal lines Document No. = "B0", "B1")
        CreateOnePmtAppliedToOneInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine[1], 'B0');
        CreateOnePmtAppliedToOneInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine[2], 'B1');

        // [WHEN] Post the payment journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Payment posting produced 6 G/L entries including 3 with Document No. = "A0", 3 with Document No. = "A1"
        VerifyPostingNoSeriesTwoPostedDocs(GenJournalBatch, 'C0', 'C1');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure JournalPostingNoSeriesMoreThanNoSeriesTwoPmtTwoInvDiffDocNos()
    var
        InvoiceGenJournalLine: array[2] of Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        // [FEATURE] [No. Series] [Journal] [Payment] [Purchase]
        // [SCENARIO 285194] Posting of two payments each applied to one invoice with WHT in case of
        // [SCENARIO 285194] journal Posting No Series ("B..") goes after No. Series ("A..") and different payment document numbers
        Initialize();

        // [GIVEN] Two posted purchase invoices with WHT
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        FindWHTPostingSetup(WHTPostingSetup, '', '', '');
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[1], CreateDefaultVendorNo());
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[2], CreateDefaultVendorNo());

        // [GIVEN] General Journal Batch with No. Series "A0..A9", Posting No. Series "B0..B9"
        CreateGenJournalBatchWithCustomNoSeries(GenJournalBatch, 'A0', 'A9', 'D0', 'D9');

        // [GIVEN] Two payments each applied to one of the posted invoices (journal lines Document No. = "A0", "A1")
        CreateOnePmtAppliedToOneInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine[1], 'A0');
        CreateOnePmtAppliedToOneInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine[2], 'A1');

        // [WHEN] Post the payment journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Payment posting produced 6 G/L entries including 3 with Document No. = "B0", 3 with Document No. = "B1"
        VerifyPostingNoSeriesTwoPostedDocs(GenJournalBatch, 'D0', 'D1');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure JournalPostingNoSeriesLessThanNoSeriesTwoPmtTwoInvSameDocNos()
    var
        InvoiceGenJournalLine: array[2] of Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        // [FEATURE] [No. Series] [Journal] [Payment] [Purchase]
        // [SCENARIO 285194] Posting of two payments each applied to one invoice with WHT in case of
        // [SCENARIO 285194] journal Posting No Series ("A..") goes before No. Series ("B..") and the same payment document numbers
        Initialize();

        // [GIVEN] Two posted purchase invoices with WHT
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        FindWHTPostingSetup(WHTPostingSetup, '', '', '');
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[1], CreateDefaultVendorNo());
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[2], CreateDefaultVendorNo());

        // [GIVEN] General Journal Batch with No. Series "B0..B9", Posting No. Series "A0..A9"
        CreateGenJournalBatchWithCustomNoSeries(GenJournalBatch, 'B0', 'B9', 'A0', 'A9');

        // [GIVEN] Two payments each applied to one of the posted invoices (journal lines Document No. = "B0", "B0")
        CreateOnePmtAppliedToOneInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine[1], 'B0');
        CreateOnePmtAppliedToOneInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine[2], 'B0');

        // [WHEN] Post the payment journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Payment posting produced 6 G/L entries including 2 WHT with Document No. = "A0"
        VerifyPostingNoSeriesOnePostedDoc('A0', 6, 2);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure JournalPostingNoSeriesMoreThanNoSeriesTwoPmtTwoInvSameDocNos()
    var
        InvoiceGenJournalLine: array[2] of Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        // [FEATURE] [No. Series] [Journal] [Payment] [Purchase]
        // [SCENARIO 285194] Posting of two payments each applied to one invoice with WHT in case of
        // [SCENARIO 285194] journal Posting No Series ("B..") goes after No. Series ("A..") and the same payment document numbers
        Initialize();

        // [GIVEN] Two posted purchase invoices with WHT
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        FindWHTPostingSetup(WHTPostingSetup, '', '', '');
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[1], CreateDefaultVendorNo());
        CreateAndPostVendorInvoice(InvoiceGenJournalLine[2], CreateDefaultVendorNo());

        // [GIVEN] General Journal Batch with No. Series "A0..A9", Posting No. Series "B0..B9"
        CreateGenJournalBatchWithCustomNoSeries(GenJournalBatch, 'A0', 'A9', 'B0', 'B9');

        // [GIVEN] Two payments each applied to one of the posted invoices (journal lines Document No. = "A0", "A0")
        CreateOnePmtAppliedToOneInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine[1], 'A0');
        CreateOnePmtAppliedToOneInv(GenJournalLine, GenJournalBatch, InvoiceGenJournalLine[2], 'A0');

        // [WHEN] Post the payment journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Payment posting produced 6 G/L entries including 2 WHT with Document No. = "B0"
        VerifyPostingNoSeriesOnePostedDoc('B0', 6, 2);
    end;

    local procedure Initialize()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryVariableStorage.Clear();
        LibrarySetupStorage.Restore();

        if IsInitialized then
            exit;


        IsInitialized := true;

        UpdateGLSetupAndPurchasesPayablesSetup(VATPostingSetup);
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);

        LibrarySetupStorage.SavePurchasesSetup();
        LibrarySetupStorage.SaveGeneralLedgerSetup();
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

    local procedure CreateAndPostGenJournalLine(AccountNo: Code[20]; CurrencyCode: Code[10]; AppliesToDocNo: Code[20]; PostingDate: Date; Amount: Decimal): Code[20]
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        CreateGeneralJournalLine(
          GenJournalLine, GenJournalLine."Document Type"::Payment, AccountNo, AppliesToDocNo, CurrencyCode, PostingDate, Amount);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        exit(GenJournalLine."Document No.");
    end;

    local procedure CreateAndPostPurchaseOrder(var PurchaseLine: Record "Purchase Line"; VendorNo: Code[20]; VATProdPostingGroup: Code[20]; WHTProductPostingGroup: Code[20]; CurrencyCode: Code[10]; DirectUnitCost: Decimal): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, VendorNo);
        PurchaseHeader.Validate("Currency Code", CurrencyCode);
        PurchaseHeader.Modify(true);
        CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", CreateGLAccount(VATProdPostingGroup), DirectUnitCost);
        PurchaseLine.Validate("Wthldg. Tax Prod. Post. Group", WHTProductPostingGroup);
        PurchaseLine.Modify(true);
        FindWHTPostingSetup(
          WHTPostingSetup, PurchaseLine."Wthldg. Tax Bus. Post. Group", PurchaseLine."Wthldg. Tax Prod. Post. Group", CurrencyCode);
        exit(PostPurchaseDocument(PurchaseLine."Document Type"::Order, PurchaseLine."Document No."));
    end;

    local procedure CreateGeneralJournalLineWithBalAccountType(var GenJournalLine: Record "Gen. Journal Line"; DocumentType: Enum "Gen. Journal Document Type"; AccountNo: Code[20]; AppliesToDocNo: Code[20]; CurrencyCode: Code[10]; BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; Amount: Decimal)
    begin
        CreateGeneralJournalLine(GenJournalLine, DocumentType, AccountNo, AppliesToDocNo, CurrencyCode, WorkDate(), Amount);
        GenJournalLine.Validate("Bal. Account Type", BalAccountType);
        GenJournalLine.Validate("Bal. Account No.", BalAccountNo);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; DocumentType: Enum "Gen. Journal Document Type"; AccountNo: Code[20]; AppliesToDocNo: Code[20]; CurrencyCode: Code[10]; PostingDate: Date; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Payments);
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalBatch.Modify(true);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          DocumentType, GenJournalLine."Account Type"::Vendor, AccountNo, Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Validate("Applies-to Doc. No.", AppliesToDocNo);
        GenJournalLine.Validate("Currency Code", CurrencyCode);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGLAccount(VATProdPostingGroup: Code[20]): Code[20]
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.FindGenProductPostingGroup(GenProductPostingGroup);
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Gen. Prod. Posting Group", GenProductPostingGroup.Code);
        GLAccount.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    local procedure CreateGLAccountWithVATBusPostingGroup(VATPostingSetup: Record "VAT Posting Setup"; WHTProdPostingGroup: Code[20]): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(CreateGLAccount(VATPostingSetup."VAT Prod. Posting Group"));
        GLAccount.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GLAccount.Validate("Wthldg. Tax Prod. Post. Group", WHTProdPostingGroup);
        GLAccount.Validate("Gen. Posting Type", GLAccount."Gen. Posting Type"::Purchase);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    local procedure CreateGLAccountForPayment(WHTProdPostingGroup: Code[20]): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(LibraryERM.CreateGLAccountNo());
        GLAccount.Validate("Wthldg. Tax Prod. Post. Group", WHTProdPostingGroup);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    local procedure CreateVendor(VATBusPostingGroup: Code[20]; WHTBusinessPostingGroup: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Vendor.Validate("Withholding Tax Liable", true);
        Vendor.Validate("Wthldg. Tax Bus. Post. Group", WHTBusinessPostingGroup);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure CreateDefaultVendorNo(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        exit(CreateVendor(VATPostingSetup."VAT Bus. Posting Group", ''));
    end;

    local procedure CreatePurchaseLine(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; Type: Enum "Purchase Line Type"; No: Code[20]; DirectUnitCost: Decimal)
    begin
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Type, No, LibraryRandom.RandInt(5));  // Random Quantity.
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Modify(true);
    end;

    local procedure CreateWHTPostingSetupWithPayableAccount(var WHTPostingSetup: Record "Withholding Tax Posting Setup"; CurrencyCode: Code[10])
    var
        WHTBusinessPostingGroup: Record "Wthldg. Tax Bus. Post. Group";
        WHTProductPostingGroup: Record "Wthldg. Tax Prod. Post. Group";
    begin
        LibraryWithholdingTax.CreateWHTBusinessPostingGroup(WHTBusinessPostingGroup);
        LibraryWithholdingTax.CreateWHTProductPostingGroup(WHTProductPostingGroup);
        CreateWHTPostingSetup(
          WHTPostingSetup, WHTBusinessPostingGroup.Code, WHTProductPostingGroup.Code,
          CurrencyCode, LibraryRandom.RandDecInRange(50, 100, 2));  // WHT Minimum Invoice Amount.
    end;

    local procedure CreateWHTPostingSetup(var WHTPostingSetup: Record "Withholding Tax Posting Setup"; WHTBusinessPostingGroup: Code[20]; WHTProductPostingGroup: Code[20]; CurrencyCode: Code[10]; WHTMinimumInvoiceAmount: Decimal)
    var
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
        WHTRevenueTypes: Record "Withholding Tax Revenue Types";
    begin
        LibraryWithholdingTax.CreateWHTPostingSetup(WHTPostingSetup, WHTBusinessPostingGroup, WHTProductPostingGroup);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Currency Code", CurrencyCode);
        BankAccount.Modify(true);
        LibraryWithholdingTax.CreateWHTRevenueTypes(WHTRevenueTypes);
        WHTPostingSetup.Validate("Revenue Type", WHTRevenueTypes.Code);
        WHTPostingSetup.Validate("Withholding Tax %", LibraryRandom.RandInt(10));
        WHTPostingSetup.Validate("Wthldg. Tax Min. Inv. Amount", WHTMinimumInvoiceAmount);
        WHTPostingSetup.Validate("Realized Withholding Tax Type", WHTPostingSetup."Realized Withholding Tax Type"::Payment);
        WHTPostingSetup.Validate("Prepaid Wthldg. Tax Acc. Code", GLAccount."No.");
        WHTPostingSetup.Validate("Payable Wthldg. Tax Acc. Code", WHTPostingSetup."Prepaid Wthldg. Tax Acc. Code");
        WHTPostingSetup.Validate("Purch. Wthldg. Tax Adj. Acc No", WHTPostingSetup."Prepaid Wthldg. Tax Acc. Code");
        WHTPostingSetup.Validate("Bal. Payable Account No.", BankAccount."No.");
        WHTPostingSetup.Modify(true);
    end;

    local procedure CreateWHTPostingSetupWithBlankAccounts(var WHTPostingSetup: Record "Withholding Tax Posting Setup")
    var
        WHTProdPostingGroup: Record "Wthldg. Tax Prod. Post. Group";
    begin
        LibraryWithholdingTax.CreateWHTProductPostingGroup(WHTProdPostingGroup);
        CreateWHTPostingSetup(WHTPostingSetup, '', WHTProdPostingGroup.Code, '', 0);
        WHTPostingSetup.Validate("Payable Wthldg. Tax Acc. Code", '');
        WHTPostingSetup.Validate("Prepaid Wthldg. Tax Acc. Code", '');
        WHTPostingSetup.Validate("Realized Withholding Tax Type", WHTPostingSetup."Realized Withholding Tax Type"::Invoice);
        WHTPostingSetup.Modify(true);
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

    local procedure CreateAndPostMultiplePartialPayments(var GenJnlDocNo: array[4] of Code[20]; VendorNo: Code[20]; CurrencyCode: Code[10]; DocumentNo: Code[20]; DocumentNo2: Code[20]; Amount: Decimal; Amount2: Decimal; Amount3: Decimal)
    begin
        // Create and Post multiple Payment Journal for partial payment on variation of Posting Date.
        GenJnlDocNo[1] := CreateAndPostGenJournalLine(VendorNo, CurrencyCode, DocumentNo, CalcDate('<1M>', WorkDate()), -Amount2);
        GenJnlDocNo[2] := CreateAndPostGenJournalLine(VendorNo, CurrencyCode, DocumentNo2, CalcDate('<2M>', WorkDate()), -Amount3);
        GenJnlDocNo[3] := CreateAndPostGenJournalLine(VendorNo, CurrencyCode, DocumentNo, CalcDate('<3M>', WorkDate()), Amount);
        GenJnlDocNo[4] := CreateAndPostGenJournalLine(VendorNo, CurrencyCode, DocumentNo2, CalcDate('<4M>', WorkDate()), Amount);
    end;

    local procedure CreateAndPostVendorInvoice(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20]): Code[20]
    begin
        CreateGeneralJournalLineWithBalAccountType(
          GenJournalLine, GenJournalLine."Document Type"::Invoice, VendorNo, '',
          '', GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(),
          -LibraryRandom.RandDecInRange(100, 200, 2));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        exit(GenJournalLine."Document No.");
    end;

    local procedure CreateAndPostVendorWHTInvoice(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20]; VATPostingSetup: Record "VAT Posting Setup"; WHTPostingSetup: Record "Withholding Tax Posting Setup"): Code[20]
    begin
        CreateGeneralJournalLineWithBalAccountType(
          GenJournalLine, GenJournalLine."Document Type"::Invoice, VendorNo, '',
          '', GenJournalLine."Bal. Account Type"::"G/L Account", CreateGLAccountWithVATBusPostingGroup(VATPostingSetup, WHTPostingSetup."Wthldg. Tax Prod. Post. Group"),
          -LibraryRandom.RandDecInRange(100, 200, 2));
        GenJournalLine.Validate("Wthldg. Tax Prod. Post. Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        exit(GenJournalLine."Document No.");
    end;

    local procedure CreateApplnVendorWHTPayment(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; ApplyAmount: Decimal; ApplyToDocType: Enum "Gen. Journal Account Type"; ApplyToDocNo: Code[20]; DocumentNo: Code[20]; WHTPostingSetup: Record "Withholding Tax Posting Setup")
    begin
        LibraryJournals.CreateGenJournalLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Payment, AccountType, AccountNo,
          GenJournalLine."Bal. Account Type"::"G/L Account", CreateGLAccountForPayment(WHTPostingSetup."Wthldg. Tax Prod. Post. Group"),
          ApplyAmount);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Applies-to Doc. Type", ApplyToDocType);
        GenJournalLine.Validate("Applies-to Doc. No.", ApplyToDocNo);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateApplnVendorPayment(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; ApplyAmount: Decimal; ApplyToDocType: Enum "Gen. Journal Account Type"; ApplyToDocNo: Code[20]; DocumentNo: Code[20])
    begin
        LibraryJournals.CreateGenJournalLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Payment, AccountType, AccountNo,
          GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(),
          ApplyAmount);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Applies-to Doc. Type", ApplyToDocType);
        GenJournalLine.Validate("Applies-to Doc. No.", ApplyToDocNo);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateOnePmtAppliedToOneInv(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; InvoiceJournalLine: Record "Gen. Journal Line"; DocumentNo: Code[20])
    begin
        LibraryJournals.CreateGenJournalLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Payment, InvoiceJournalLine."Account Type", InvoiceJournalLine."Account No.",
          GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(), -InvoiceJournalLine.Amount);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Applies-to Doc. Type", InvoiceJournalLine."Document Type");
        GenJournalLine.Validate("Applies-to Doc. No.", InvoiceJournalLine."Document No.");
        GenJournalLine.Modify(true);
    end;

    local procedure CreateOnePmtAppliedToTwoInv(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; InvoiceJournalLine: array[2] of Record "Gen. Journal Line"; DocumentNo: Code[20])
    begin
        LibraryJournals.CreateGenJournalLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, InvoiceJournalLine[1]."Account No.",
          GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(),
          -(InvoiceJournalLine[1].Amount + InvoiceJournalLine[2].Amount));
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Applies-to ID", LibraryUtility.GenerateGUID());
        GenJournalLine.Modify(true);

        SetAppliesToIDVendorLedgerEntry(InvoiceJournalLine[1]."Document No.", GenJournalLine."Applies-to ID");
        SetAppliesToIDVendorLedgerEntry(InvoiceJournalLine[2]."Document No.", GenJournalLine."Applies-to ID");
    end;

    local procedure CreateGenJournalBatchWithCustomNoSeries(var GenJournalBatch: Record "Gen. Journal Batch"; NoSeriesStartingNo: Code[20]; NoSeriesEndingNo: Code[20]; PostingNoSeriesStartingNo: Code[20]; PostingNoSeriesEndingNo: Code[20])
    begin
        LibraryJournals.CreateGenJournalBatch(GenJournalBatch);
        GenJournalBatch.Validate("No. Series", CreateCustomNoSeries(NoSeriesStartingNo, NoSeriesEndingNo));
        GenJournalBatch.Validate("Posting No. Series", CreateCustomNoSeries(PostingNoSeriesStartingNo, PostingNoSeriesEndingNo));
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateCustomNoSeries(StartingNo: Code[20]; EndingNo: Code[20]): Code[20];
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, true, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, StartingNo, EndingNo);
        exit(NoSeries.Code);
    end;

    local procedure SetAppliesToIDVendorLedgerEntry(DocumentNo: Code[20]; AppliesToID: Code[50])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, DocumentNo);
        VendorLedgerEntry.Validate("Applies-to ID", AppliesToID);
        VendorLedgerEntry.CalcFields("Remaining Amount");
        VendorLedgerEntry.Validate("Amount to Apply", VendorLedgerEntry."Remaining Amount");
        VendorLedgerEntry.Modify();
    end;

    local procedure FindWHTPostingSetup(var WHTPostingSetup: Record "Withholding Tax Posting Setup"; WHTBusinessPostingGroup: Code[20]; WHTProductPostingGroup: Code[20]; CurrencyCode: Code[10])
    begin
        // Enable test cases in NZ, create WHT Posting Setup.
        if not WHTPostingSetup.Get(WHTBusinessPostingGroup, WHTProductPostingGroup) then
            CreateWHTPostingSetup(WHTPostingSetup, WHTBusinessPostingGroup,
              WHTProductPostingGroup, CurrencyCode, LibraryRandom.RandDecInRange(50, 100, 2));  // WHT Minimum Invoice Amount.
    end;

    local procedure CreateWHTPostingSetup(var WHTPostingSetup: Record "Withholding Tax Posting Setup"; CurrencyCode: Code[10])
    var
        WHTBusinessPostingGroup: Record "Wthldg. Tax Bus. Post. Group";
        WHTProductPostingGroup: Record "Wthldg. Tax Prod. Post. Group";
    begin
        LibraryWithholdingTax.CreateWHTBusinessPostingGroup(WHTBusinessPostingGroup);
        LibraryWithholdingTax.CreateWHTProductPostingGroup(WHTProductPostingGroup);
        CreateWHTPostingSetup(WHTPostingSetup, WHTBusinessPostingGroup.Code,
              WHTProductPostingGroup.Code, CurrencyCode, LibraryRandom.RandDecInRange(50, 100, 2));  // WHT Minimum Invoice Amount.
    end;

    local procedure FindVendorLedgerEntry(VendorNo: Code[20]): Code[20]
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetRange("Vendor No.", VendorNo);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.FindFirst();
        exit(VendorLedgerEntry."Document No.");
    end;

    local procedure FindVendorLedgerEntryAmount(DocumentNo: Code[20]): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, DocumentNo);
        VendorLedgerEntry.CalcFields(Amount);
        exit(VendorLedgerEntry.Amount);
    end;

    local procedure PostPurchaseDocument(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(DocumentType, DocumentNo);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure UpdateGenJournalLineWHTAbsorbBase(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Validate("Withholding Tax Absorb Base", -LibraryRandom.RandDecInRange(10, 50, 2));
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Gen. Posting Type"::Purchase);
        GenJournalLine.Modify(true);
    end;

    local procedure UpdateLocalFunctionalitiesOnGeneralLedgerSetup(EnableWHT: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Enable Withholding Tax", EnableWHT);
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure UpdateGLSetupAndPurchasesPayablesSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        UpdateLocalFunctionalitiesOnGeneralLedgerSetup(true);
        LibraryERM.FindZeroVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
    end;

    local procedure VerifyWHTEntry(DocumentType: Enum "Gen. Journal Document Type"; BillToPayToNo: Code[20]; Amount: Decimal; UnrealizedAmount: Decimal)
    var
        WHTEntry: Record "Withholding Tax Entry";
    begin
        WHTEntry.SetRange("Document Type", DocumentType);
        WHTEntry.SetRange("Bill-to/Pay-to No.", BillToPayToNo);
        WHTEntry.FindFirst();
        Assert.AreNearlyEqual(Amount, WHTEntry.Amount, LibraryERM.GetAmountRoundingPrecision(), ValueMustBeSameMsg);
        Assert.AreNearlyEqual(UnrealizedAmount, WHTEntry."Unrealized Amount", LibraryERM.GetAmountRoundingPrecision(), ValueMustBeSameMsg);
    end;

    local procedure VerifyWHTAmountWithCurrency(BillToPayToNo: Code[20]; CurrencyCode: Code[10]; OriginalDocumentNo: Code[20]; Amount: Decimal)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        WHTEntry: Record "Withholding Tax Entry";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        WHTAmount: Decimal;
    begin
        WHTPostingSetup.Get('', '');  // Blank - WHT Product Posting Group, WHT Business Posting Group.
        CurrencyExchangeRate.SetRange("Currency Code", CurrencyCode);
        CurrencyExchangeRate.FindFirst();
        WHTEntry.SetRange("Document Type", WHTEntry."Document Type"::Payment);
        WHTEntry.SetRange("Bill-to/Pay-to No.", BillToPayToNo);
        WHTEntry.SetRange("Original Document No.", OriginalDocumentNo);
        WHTEntry.FindFirst();
        WHTAmount :=
          Round(
            (Amount * WHTPostingSetup."Withholding Tax %" / 100) /
            (CurrencyExchangeRate."Exchange Rate Amount" / CurrencyExchangeRate."Relational Exch. Rate Amount"));
        Assert.AreNearlyEqual(WHTAmount, WHTEntry."Amount (LCY)", LibraryERM.GetAmountRoundingPrecision(), ValueMustBeSameMsg);
    end;

    local procedure VerifyClosedVendorLedgerEntry(DocumentNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Payment, DocumentNo);
        VendorLedgerEntry.TestField(Open, false);
    end;

    local procedure VerifyVendorLedgerEntryAndWHTAmount(DcoumentNo: array[4] of Code[20]; VendorNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal; Amount2: Decimal; Amount3: Decimal)
    begin
        VerifyWHTAmountWithCurrency(VendorNo, CurrencyCode, DcoumentNo[1], -Amount2);
        VerifyWHTAmountWithCurrency(VendorNo, CurrencyCode, DcoumentNo[2], -Amount3);
        VerifyWHTAmountWithCurrency(VendorNo, CurrencyCode, DcoumentNo[3], Amount);
        VerifyWHTAmountWithCurrency(VendorNo, CurrencyCode, DcoumentNo[4], Amount);
        VerifyClosedVendorLedgerEntry(DcoumentNo[1]);
        VerifyClosedVendorLedgerEntry(DcoumentNo[2]);
        VerifyClosedVendorLedgerEntry(DcoumentNo[3]);
        VerifyClosedVendorLedgerEntry(DcoumentNo[4]);
    end;

    local procedure VerifyPostingNoSeriesOnePostedDoc(PostedNo: Code[20]; GLEntryCount: Integer; WHTEntryCount: Integer)
    var
        GLEntry: Record "G/L Entry";
        WHTEntry: Record "Withholding Tax Entry";
        GLRegister: Record "G/L Register";
    begin
        GLRegister.FindLast();
        GLRegister.TestField("To Entry No.", GLRegister."From Entry No." + GLEntryCount - 1);

        WHTEntry.SetRange("Entry No.", GLRegister."From Withholding Tax Entry No.", GLRegister."To Withholding Tax Entry No.");
        Assert.RecordCount(WHTEntry, WHTEntryCount);

        GLEntry.SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
        GLEntry.SetRange("Document No.", PostedNo);
        Assert.RecordCount(GLEntry, GLEntryCount);
    end;

    local procedure VerifyPostingNoSeriesTwoPostedDocs(GenJournalBatch: Record "Gen. Journal Batch"; PostedNo1: Code[20]; PostedNo2: Code[20])
    var
        GLEntry: Record "G/L Entry";
        WHTEntry: Record "Withholding Tax Entry";
        GLRegister: Record "G/L Register";
        FromEntryNo: Integer;
        FromWHTEntryNo: Integer;
    begin
        GLRegister.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GLRegister.FindFirst();
        FromEntryNo := GLRegister."From Entry No.";
        FromWHTEntryNo := GLRegister."From Withholding Tax Entry No.";

        GLRegister.FindLast();
        GLRegister.TestField("To Entry No.", FromEntryNo + 5);

        WHTEntry.SetRange("Entry No.", FromWHTEntryNo, GLRegister."To Withholding Tax Entry No.");
        Assert.RecordCount(WHTEntry, 2);

        GLEntry.SetRange("Document No.", PostedNo1);
        Assert.RecordCount(GLEntry, 3);

        GLEntry.SetRange("Document No.", PostedNo2);
        Assert.RecordCount(GLEntry, 3);
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}