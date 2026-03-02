// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Tests.WithholdingTax;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.WithholdingTax;

codeunit 148326 "ERM Withholding VAT For SEA"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = Uncategorized;

    trigger OnRun()
    begin
        // [FEATURE] [VAT] [WHT]
    end;

    var
        Assert: Codeunit Assert;
        LibraryWithholdingTax: Codeunit "Library - Withholding Tax";
        LibraryERM: Codeunit "Library - ERM";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        ValueMatchMsg: Label 'Value must be same.';
        WHTCertErr: Label 'Withholding Tax Certificate Nos. must have a value in Purchases & Payables Setup';

    [Test]
    [HandlerFunctions('ConfirmHandler,RecallNotificationHandler')]
    [Scope('OnPrem')]
    procedure ApplyPaymentAfterPostPOWithDiffPayToVendNo()
    var
        GeneralPostingSetup: Record "General Posting Setup";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        // [SCENARIO 285194] Amount after create and post Purchase Order and apply Payments with different Pay to Vendor No.

        // [GIVEN] Create General Posting Setup and WHT Posting Setup. Find VAT Posting Setup.
        Initialize();
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateGeneralPostingSetup(GeneralPostingSetup, VATPostingSetup);
        CreateWHTPostingSetup(WHTPostingSetup, GeneralPostingSetup);

        // Exercise & Verify.
        PostPurchaseInvoiceAndApplyPayment(
          CreateVendor(GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group"),
          CreateVendor(GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group"), CreateGLAccount(
            GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"),
          PurchaseLine."Document Type"::Order, WHTPostingSetup."Withholding Tax %", VATPostingSetup."VAT %");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure ApplyPaymentAfterPostPurchaseInvoice()
    var
        GeneralPostingSetup: Record "General Posting Setup";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        VendorNo: Code[20];
    begin
        // [SCENARIO 285194] Amount after create and post Purchase Invoice and apply Payments.

        // [GIVEN] Create General Posting Setup and WHT Posting Setup. Find VAT Posting Setup.
        Initialize();
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateGeneralPostingSetup(GeneralPostingSetup, VATPostingSetup);
        CreateWHTPostingSetup(WHTPostingSetup, GeneralPostingSetup);
        VendorNo := CreateVendor(GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");

        // Exercise & Verify.
        PostPurchaseInvoiceAndApplyPayment(
          VendorNo, VendorNo, CreateGLAccount(GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"),
          PurchaseLine."Document Type"::Invoice, WHTPostingSetup."Withholding Tax %", VATPostingSetup."VAT %");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure ApplyRefundAfterPostPurchaseCreditMemo()
    var
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
        VendorNo: Code[20];
        Amount: Decimal;
        VATAmount: Decimal;
    begin
        // [SCENARIO 285194] after create and post a Purchase Credit Memo and apply partial refund.

        // [GIVEN] Create and post Purchase Credit Memo and partially post Gen. Journal Line.
        Initialize();
        UpdatePurchasesPayableSetup();
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateGeneralPostingSetup(GeneralPostingSetup, VATPostingSetup);
        CreateWHTPostingSetup(WHTPostingSetup, GeneralPostingSetup);
        VendorNo := CreateVendor(GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");
        CreateAndPostPurchaseDocument(
          PurchaseLine, PurchaseLine."Document Type"::"Credit Memo", PurchaseLine.Type::Item, VendorNo, CreateItem(
            GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group",
            VATPostingSetup."VAT Prod. Posting Group"), VendorNo);
        Amount := PurchaseLine."Amount Including VAT" - (PurchaseLine.Amount * WHTPostingSetup."Withholding Tax %" / 100);  // Calculate Amount excluding WHT Amount.
        VATAmount := (PurchaseLine.Amount / 2) + (PurchaseLine.Amount * VATPostingSetup."VAT %" / 200);  // Calculate Partial Amount including VAT.
        DocumentNo :=
          CreateAndPostGeneralJournalLine(
            PurchaseLine."Buy-from Vendor No.", FindPostedPurchaseCreditMemo(PurchaseLine."No."),
            -PurchaseLine."Amount Including VAT" / 2, GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Refund,
            GenJournalLine."Applies-to Doc. Type"::"Credit Memo", GenJournalTemplate.Type::Payments);

        // Exercise.
        DocumentNo2 :=
          CreateAndPostGeneralJournalLine(
            PurchaseLine."Buy-from Vendor No.", FindPostedPurchaseCreditMemo(PurchaseLine."No."), VATAmount - Amount,
            GenJournalLine."Account Type"::Vendor, GenJournalLine."Document Type"::Refund,
            GenJournalLine."Applies-to Doc. Type"::"Credit Memo", GenJournalTemplate.Type::Payments);

        // Verify.
        VerifyVATEntry(
          GenJournalLine."Document Type"::"Credit Memo", FindPostedPurchaseCreditMemo(
            PurchaseLine."No."), -PurchaseLine.Amount * VATPostingSetup."VAT %" / 100, -PurchaseLine.Amount);
        VerifyWHTEntry(
          GenJournalLine."Document Type"::"Credit Memo", FindPostedPurchaseCreditMemo(
            PurchaseLine."No."), -PurchaseLine.Amount * WHTPostingSetup."Withholding Tax %" / 100, -PurchaseLine.Amount);
        VerifyGLEntry(GenJournalLine."Document Type"::Refund, DocumentNo, VATAmount);
        VerifyGLEntry(GenJournalLine."Document Type"::Refund, DocumentNo2, Amount - VATAmount);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostWHTEntryWithoutAnyError()
    var
        GeneralPostingSetup: Record "General Posting Setup";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        VendorNo: Code[20];
    begin
        // [SCENARIO 285194] No Error message is displayed when a Purchase Invoice with WHT calculation is posted - AU
        Initialize();

        // [GIVEN] Find VAT Posting Setup.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");

        //[GIVEN] Create General Posting Setup 
        CreateGeneralPostingSetup(GeneralPostingSetup, VATPostingSetup);

        // [GIVEN] Create WHT Posting Setup
        CreateWHTPostingSetup(WHTPostingSetup, GeneralPostingSetup);

        // [GIVEN] Create Vendor
        VendorNo := CreateVendor(GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");

        // [VERIFY] Post and Verify the WHT Entry created successfully
        PostPurchaseInvoiceAndVerifyWHTEntry(
        VendorNo, VendorNo, CreateGLAccount(GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group"),
          PurchaseLine."Document Type"::Invoice, WHTPostingSetup."Withholding Tax %");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifyErrorOnWHTCertificateNoSeries()
    var
        GeneralPostingSetup: Record "General Posting Setup";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        VendorNo: Code[20];
        GLAccountNo: Code[20];
    begin
        // [SCENARIO 285194] No Error message is displayed when a Purchase Invoice with WHT calculation is posted - AU
        Initialize();

        // [GIVEN] Find VAT Posting Setup.
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");

        //[GIVEN] Create General Posting Setup 
        CreateGeneralPostingSetup(GeneralPostingSetup, VATPostingSetup);

        // [GIVEN] Create WHT Posting Setup
        CreateWHTPostingSetup(WHTPostingSetup, GeneralPostingSetup);

        // [GIVEN] Update WHT Certificate No. Series as blank on Purchase & Payable Setup
        UpdateWHTCertificateNoSerOnPurchSetup();

        // [GIVEN] Create Vendor
        VendorNo := CreateVendor(GeneralPostingSetup."Gen. Bus. Posting Group", WHTPostingSetup."Wthldg. Tax Bus. Post. Group");

        // [GIVEN] Create G/l Account
        GLAccountNo := CreateGLAccount(GeneralPostingSetup."Gen. Prod. Posting Group", WHTPostingSetup."Wthldg. Tax Prod. Post. Group");

        // [VERIFY] Create and Post the Purchase Invoice
        asserterror CreateAndPostPurchaseDocument(PurchaseLine, PurchaseLine."Document Type"::Invoice, PurchaseLine.Type::"G/L Account", VendorNo, GLAccountNo, VendorNo);

        // [GIVEN] Verify the WHT Certificate No. series error
        Assert.IsSubstring(GetLastErrorText(), WHTCertErr);
    end;

    local procedure Initialize()
    begin
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);

        UpdateGeneralLedgerSetup();
    end;

    local procedure CreateAndPostGeneralJournalLine(AccountNo: Code[20]; AppliesToDocNo: Code[20]; Amount: Decimal; AccountType: Enum "Gen. Journal Account Type"; DocumentType: Enum "Gen. Journal Document Type"; AppliesToDocType: Enum "Gen. Journal Document Type"; Type: Enum "Gen. Journal Template Type"): Code[20]
    var
        BankAccount: Record "Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryERM.FindBankAccount(BankAccount);
        CreateGeneralJournalBatch(GenJournalBatch, Type);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, DocumentType, AccountType, AccountNo, Amount);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine.Validate("Applies-to Doc. Type", AppliesToDocType);
        GenJournalLine.Validate("Applies-to Doc. No.", AppliesToDocNo);
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        exit(GenJournalLine."Document No.");
    end;

    local procedure CreateAndPostPurchaseDocument(var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; Type: Enum "Purchase Line Type"; BuyFromVendorNo: Code[20]; No: Code[20]; PayToVendorNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, BuyFromVendorNo);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Validate("Pay-to Vendor No.", PayToVendorNo);
        PurchaseHeader.Modify(true);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Type, No, LibraryRandom.RandDec(10, 2)); // Take random Quantity.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));
        PurchaseLine.Modify(true);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);  // Post as Invoice.
    end;

    local procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; Type: Enum "Gen. Journal Template Type")
    var
        BankAccount: Record "Bank Account";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, Type);
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.FindBankAccount(BankAccount);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateGenBusPostingGroup(DefVATBusPostingGroup: Code[20]): Code[20]
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
    begin
        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        GenBusinessPostingGroup.Validate("Def. VAT Bus. Posting Group", DefVATBusPostingGroup);
        GenBusinessPostingGroup.Modify(true);
        exit(GenBusinessPostingGroup.Code)
    end;

    local procedure CreateGenProdPostingGroup(DefVATProdPostingGroup: Code[20]): Code[20]
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
    begin
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", DefVATProdPostingGroup);
        GenProductPostingGroup.Modify(true);
        exit(GenProductPostingGroup.Code);
    end;

    local procedure CreateGLAccount(GenProdPostingGroup: Code[20]; WHTProductPostingGroup: Code[20]): Code[20]
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        GLAccount: Record "G/L Account";
    begin
        GenProductPostingGroup.Get(GenProdPostingGroup);
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Wthldg. Tax Prod. Post. Group", WHTProductPostingGroup);
        GLAccount.Validate("VAT Prod. Posting Group", GenProductPostingGroup."Def. VAT Prod. Posting Group");
        GLAccount.Validate("Gen. Prod. Posting Group", GenProductPostingGroup.Code);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    local procedure CreateItem(GenProdPostingGroup: Code[20]; WHTProductPostingGroup: Code[20]; VATProdPostingGroup: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Wthldg. Tax Prod. Post. Group", WHTProductPostingGroup);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        Item.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        Item.Modify(true);
        exit(Item."No.");
    end;

    local procedure CreateVendor(GenBusPostingGroup: Code[20]; WHTBusinessPostingGroup: Code[20]): Code[20]
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        Vendor: Record Vendor;
    begin
        GenBusinessPostingGroup.Get(GenBusPostingGroup);
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Withholding Tax Liable", true);
        Vendor.Validate("Wthldg. Tax Bus. Post. Group", WHTBusinessPostingGroup);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup.Code);
        Vendor.Validate("VAT Bus. Posting Group", GenBusinessPostingGroup."Def. VAT Bus. Posting Group");
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure CreateWHTPostingSetup(var WHTPostingSetup: Record "Withholding Tax Posting Setup"; GeneralPostingSetup: Record "General Posting Setup")
    var
        WHTBusinessPostingGroup: Record "Wthldg. Tax Bus. Post. Group";
        WHTProductPostingGroup: Record "Wthldg. Tax Prod. Post. Group";
        WHTRevenueTypes: Record "Withholding Tax Revenue Types";
    begin
        LibraryWithholdingTax.CreateWHTBusinessPostingGroup(WHTBusinessPostingGroup);
        LibraryWithholdingTax.CreateWHTProductPostingGroup(WHTProductPostingGroup);
        LibraryWithholdingTax.CreateWHTPostingSetup(WHTPostingSetup, WHTBusinessPostingGroup.Code, WHTProductPostingGroup.Code);
        LibraryWithholdingTax.CreateWHTRevenueTypes(WHTRevenueTypes);
        WHTPostingSetup.Validate("Revenue Type", WHTRevenueTypes.Code);
        WHTPostingSetup.Validate("Withholding Tax %", LibraryRandom.RandInt(5));
        WHTPostingSetup.Validate("Realized Withholding Tax Type", WHTPostingSetup."Realized Withholding Tax Type"::Invoice);
        WHTPostingSetup.Validate("Prepaid Wthldg. Tax Acc. Code", CreateGLAccount(GeneralPostingSetup."Gen. Prod. Posting Group", ''));   // WHT Prod. Posting Group as blank.
        WHTPostingSetup.Validate("Payable Wthldg. Tax Acc. Code", WHTPostingSetup."Prepaid Wthldg. Tax Acc. Code");
        WHTPostingSetup.Modify(true);
    end;

    local procedure CreateGeneralPostingSetup(var GeneralPostingSetup: Record "General Posting Setup"; VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryERM.CreateGeneralPostingSetup(
          GeneralPostingSetup, CreateGenBusPostingGroup(VATPostingSetup."VAT Bus. Posting Group"),
          CreateGenProdPostingGroup(VATPostingSetup."VAT Prod. Posting Group"));
        GeneralPostingSetup.Validate("Direct Cost Applied Account", CreateGLAccount(GeneralPostingSetup."Gen. Prod. Posting Group", ''));  // WHT Prod. Posting Group as blank.
        GeneralPostingSetup.Validate("Purch. Credit Memo Account", GeneralPostingSetup."Direct Cost Applied Account");
        GeneralPostingSetup.Modify(true);
    end;

    local procedure FindPostedPurchaseCreditMemo(No: Code[20]): Code[20]
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        PurchCrMemoLine.SetRange(Type, PurchCrMemoLine.Type::Item);
        PurchCrMemoLine.SetRange("No.", No);
        PurchCrMemoLine.FindFirst();
        exit(PurchCrMemoLine."Document No.");
    end;

    local procedure FindPostedPurchaseInvoice(No: Code[20]): Code[20]
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange(Type, PurchInvLine.Type::"G/L Account");
        PurchInvLine.SetRange("No.", No);
        PurchInvLine.FindFirst();
        exit(PurchInvLine."Document No.");
    end;

    local procedure PostPurchaseInvoiceAndApplyPayment(BuyFromVendorNo: Code[20]; PayToVendorNo: Code[20]; No: Code[20]; DocumentType: Enum "Purchase Document Type"; WHTPct: Decimal; VATPct: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        Amount: Decimal;
    begin
        // Create and post Purchase Document.
        UpdatePurchasesPayableSetup();
        CreateAndPostPurchaseDocument(PurchaseLine, DocumentType, PurchaseLine.Type::"G/L Account", BuyFromVendorNo, No, PayToVendorNo);
        Amount := PurchaseLine."Amount Including VAT" - (PurchaseLine.Amount * WHTPct / 100);  // Calculate Amount excluding WHT Amount.

        // Exercise.
        DocumentNo :=
          CreateAndPostGeneralJournalLine(
            PurchaseLine."Pay-to Vendor No.", FindPostedPurchaseInvoice(No), Amount, GenJournalLine."Account Type"::Vendor,
            GenJournalLine."Document Type"::Payment, GenJournalLine."Applies-to Doc. Type"::Invoice, GenJournalTemplate.Type::Payments);

        // Verify.
        VerifyVATEntry(
          GenJournalLine."Document Type"::Invoice, FindPostedPurchaseInvoice(No), PurchaseLine.Amount * VATPct / 100, PurchaseLine.Amount);
        VerifyWHTEntry(
          GenJournalLine."Document Type"::Invoice, FindPostedPurchaseInvoice(No), PurchaseLine.Amount * WHTPct / 100, PurchaseLine.Amount);
        VerifyGLEntry(GenJournalLine."Document Type"::Payment, DocumentNo, -Amount);
    end;

    local procedure PostPurchaseInvoiceAndVerifyWHTEntry(BuyFromVendorNo: Code[20]; PayToVendorNo: Code[20]; No: Code[20]; DocumentType: Enum "Purchase Document Type"; WHTPct: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseLine: Record "Purchase Line";
        Amount: Decimal;
        WHTAmount: Decimal;
    begin
        // Create and post Purchase Document.
        UpdatePurchasesPayableSetup();
        CreateAndPostPurchaseDocument(PurchaseLine, DocumentType, PurchaseLine.Type::"G/L Account", BuyFromVendorNo, No, PayToVendorNo);
        WHTAmount := PurchaseLine.Amount * WHTPct / 100;
        Amount := PurchaseLine."Amount Including VAT" - WHTAmount;  // Calculate Amount excluding WHT Amount.

        // Verify.
        VerifyWHTEntry(
         GenJournalLine."Document Type"::Invoice, FindPostedPurchaseInvoice(No), PurchaseLine.Amount * WHTPct / 100, PurchaseLine.Amount);
    end;

    local procedure UpdateGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Enable Withholding Tax", true);
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure UpdatePurchasesPayableSetup()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Wthldg. Tax Certificate Nos.", LibraryERM.CreateNoSeriesCode());
        PurchasesPayablesSetup.Modify(true);
    end;

    local procedure VerifyGLEntry(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; Amount: Decimal)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document Type", DocumentType);
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.FindFirst();
        Assert.AreNearlyEqual(GLEntry.Amount, Amount, LibraryERM.GetAmountRoundingPrecision(), ValueMatchMsg);
    end;

    local procedure VerifyVATEntry(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; Amount: Decimal; Base: Decimal)
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetRange("Document Type", DocumentType);
        VATEntry.SetRange("Document No.", DocumentNo);
        VATEntry.FindFirst();
        Assert.AreNearlyEqual(VATEntry.Amount, Amount, LibraryERM.GetAmountRoundingPrecision(), ValueMatchMsg);
        Assert.AreNearlyEqual(VATEntry.Base, Base, LibraryERM.GetAmountRoundingPrecision(), ValueMatchMsg);
    end;

    local procedure VerifyWHTEntry(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; Amount: Decimal; Base: Decimal)
    var
        WHTEntry: Record "Withholding Tax Entry";
    begin
        WHTEntry.SetRange("Document Type", DocumentType);
        WHTEntry.SetRange("Document No.", DocumentNo);
        WHTEntry.FindFirst();
        Assert.AreNearlyEqual(WHTEntry.Amount, Amount, LibraryERM.GetAmountRoundingPrecision(), ValueMatchMsg);
        Assert.AreNearlyEqual(WHTEntry.Base, Base, LibraryERM.GetAmountRoundingPrecision(), ValueMatchMsg);
    end;

    local procedure UpdateWHTCertificateNoSerOnPurchSetup()
    var
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        PurchSetup.Get();
        PurchSetup.Validate("Wthldg. Tax Certificate Nos.", '');
        PurchSetup.Modify(true);
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [RecallNotificationHandler]
    [Scope('OnPrem')]
    procedure RecallNotificationHandler(var Notification: Notification): Boolean
    begin
    end;
}