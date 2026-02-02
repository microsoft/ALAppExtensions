// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Tests.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

codeunit 148327 "Withholding Tax Journals"
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
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('ApplyVendorEntriesModalPageHandler')]
    [Scope('OnPrem')]
    procedure PostPaymentJournalWithAppliedEntry()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Apply Entries]
        // [SCENARIO 285194] Payment Journal is posted successfully using Apply Entries functionality.

        // [GIVEN] Post Purchase Invoice and apply Payment.
        DocumentNo := CreateAndPostPurchaseInvoice();
        PurchInvHeader.Get(DocumentNo);
        PurchInvHeader.CalcFields("Amount Including VAT");
        CreateGenJournalLine(
          GenJournalLine, PurchInvHeader."Buy-from Vendor No.", GenJournalLine."Account Type"::Vendor,
          PurchInvHeader."Amount Including VAT");  // Using blank value for Customer/Vendor Bank.
        OpenPaymentJournalPageAndApplyPaymentToInvoice(GenJournalLine."Journal Batch Name");

        // Exercise.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Payment is fully applied to Invoice.
        VerifyVendorLedgerEntry(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('ApplyVendorEntriesModalPageHandler,ConfirmHandler')]
    [Scope('OnPrem')]
    procedure PostPaymentJournalWithAppliedEntryTwoVendors()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        PurchInvHeader: Record "Purch. Inv. Header";
        DocumentNo: array[2] of Code[20];
    begin
        // [FEATURE] [Purchase] [Apply Entries]
        // [SCENARIO 285194] Payment Journal is posted successfully using Apply Entries functionality with different Vendors but one GenJournalLine."Document No."

        // [GIVEN] Two posted purchase invoices with Vendors: V1, V2
        DocumentNo[1] := CreateAndPostPurchaseInvoice();
        DocumentNo[2] := CreateAndPostPurchaseInvoice();
        // [GIVEN] GL Setup has Enable Withholding Tax" = TRUE
        UpdateGLSetupWHT(true);
        // [GIVEN] GenJournalBatch
        CreatePaymentJournalBatch(GenJournalBatch);
        // [GIVEN] GenJournalLine for V1 with "Document No." = N
        PurchInvHeader.Get(DocumentNo[1]);
        PurchInvHeader.CalcFields("Amount Including VAT");
        CreateGenJournalLineWithJournalBatch(
          GenJournalLine, GenJournalBatch, PurchInvHeader."Buy-from Vendor No.", GenJournalLine."Account Type"::Vendor,
          PurchInvHeader."Amount Including VAT", '');
        // [GIVEN] GenJournalLine for V2 with "Document No." = N
        PurchInvHeader.Get(DocumentNo[2]);
        PurchInvHeader.CalcFields("Amount Including VAT");
        CreateGenJournalLineWithJournalBatch(
          GenJournalLine, GenJournalBatch, PurchInvHeader."Buy-from Vendor No.", GenJournalLine."Account Type"::Vendor,
          PurchInvHeader."Amount Including VAT", GenJournalLine."Document No.");

        // [WHEN] Apply payments and Post GenJournalBatch
        OpenPaymentJournalPageAndApplyPaymentToInvoiceOnEntries(GenJournalLine."Journal Batch Name");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Payment is fully applied to Invoice.
        VerifyVendorLedgerEntry(DocumentNo[1]);
        VerifyVendorLedgerEntry(DocumentNo[2]);

        UpdateGLSetupWHT(false);
    end;

    local procedure CreateAndPostPurchaseInvoice(): Code[20]
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItem(Item), LibraryRandom.RandDec(10, 2));  // Using random value for Quantity.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));
        PurchaseLine.Modify(true);
        PurchaseHeader.CalcFields(Amount, "Amount Including VAT");
        PurchaseHeader."Doc. Amount Incl. VAT" := PurchaseHeader."Amount Including VAT";
        PurchaseHeader."Doc. Amount VAT" := PurchaseHeader."Amount Including VAT" - PurchaseHeader.Amount;
        PurchaseHeader.Modify(true);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));  // Post as Receive and Invoice.
    end;

    local procedure CreateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; AccountNo: Code[20]; AccountType: Enum "Gen. Journal Account Type"; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        CreatePaymentJournalBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          AccountType, AccountNo, Amount);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", LibraryERM.CreateBankAccountNoWithNewPostingGroup(GLAccount));
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Modify(true);
    end;

    local procedure CreatePaymentJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Payments);
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateGenJournalLineWithJournalBatch(var GenJournalLine: Record "Gen. Journal Line"; var GenJournalBatch: Record "Gen. Journal Batch"; AccountNo: Code[20]; AccountType: Enum "Gen. Journal Account Type"; Amount: Decimal; DocumentNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          AccountType, AccountNo, Amount);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", LibraryERM.CreateBankAccountNoWithNewPostingGroup(GLAccount));
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Validate("Skip Withholding Tax", false);
        if DocumentNo <> '' then
            GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Modify(true);
    end;

    local procedure OpenPaymentJournalPageAndApplyPaymentToInvoice(CurrentJnlBatchName: Code[10])
    var
        PaymentJournal: TestPage "Payment Journal";
    begin
        PaymentJournal.OpenEdit();
        PaymentJournal.CurrentJnlBatchName.SetValue(CurrentJnlBatchName);
        PaymentJournal.ApplyEntries.Invoke();  // Opens ApplyVendorEntriesPageHandler and ApplyCustomerEntriesPageHandler.
        PaymentJournal.OK().Invoke();
    end;

    local procedure OpenPaymentJournalPageAndApplyPaymentToInvoiceOnEntries(CurrentJnlBatchName: Code[10])
    var
        PaymentJournal: TestPage "Payment Journal";
    begin
        PaymentJournal.OpenEdit();
        PaymentJournal.CurrentJnlBatchName.SetValue(CurrentJnlBatchName);
        PaymentJournal.ApplyEntries.Invoke();
        PaymentJournal.Next();
        PaymentJournal.ApplyEntries.Invoke();
        PaymentJournal.OK().Invoke();
    end;

    local procedure UpdateGLSetupWHT(EnableWHT: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Enable Withholding Tax", EnableWHT);
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure VerifyVendorLedgerEntry(DocumentNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, DocumentNo);
        VendorLedgerEntry.TestField(Open, false);
        VendorLedgerEntry.TestField("Remaining Amount", 0);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ApplyVendorEntriesModalPageHandler(var ApplyVendorEntries: TestPage "Apply Vendor Entries")
    begin
        ApplyVendorEntries.ActionSetAppliesToID.Invoke();
        ApplyVendorEntries.OK().Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}