// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Setup;

codeunit 31142 "Purch. Adv. Letter-Post CZZ"
{
    Permissions = tabledata "Purch. Adv. Letter Entry CZZ" = im;

    var
        CurrencyGlob: Record Currency;
        TempPurchAdvLetterEntryCZZGlob: Record "Purch. Adv. Letter Entry CZZ" temporary;
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
        ExceededAmountErr: Label 'Amount has been exceeded.';
        ExceededAmountToPayErr: Label 'The amount cannot be higher than to pay on advance letter.';
        ExceededRemainingAmountErr: Label 'The amount cannot be higher than remaining amount on ledger entry.';
        ReverseAmountErr: Label 'Reverse amount %1 is not posible on entry %2.', Comment = '%1 = Reverse Amount, %2 = Purchase Advance Entry No.';
        NothingToPostErr: Label 'Nothing to Post.';
        TemporaryRecordErr: Label 'The record of "Purch. Adv. Letter Entry CZZ" must be temporary.';
        UnlinkIsNotPossibleErr: Label 'Unlink is not possible, because %1 entry exists.', Comment = '%1 = Entry type';
        UnapplyIsNotPossibleErr: Label 'Unapply is not possible.';
        UnapplyLastInvoicesErr: Label 'First you must unapply invoces that were applied to advance last time.';

    procedure PostAdvancePayment(
        var VendorLedgerEntry: Record "Vendor Ledger Entry";
        PostedGenJournalLine: Record "Gen. Journal Line";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VendorLedgerEntryPayment: Record "Vendor Ledger Entry";
        Amount, AmountLCY : Decimal;
        EntryNo, GLEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePayment(VendorLedgerEntry, PostedGenJournalLine, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        VendorLedgerEntry.TestField("Advance Letter No. CZZ", '');
        PurchAdvLetterHeaderCZZ.Get(PostedGenJournalLine."Advance Letter No. CZZ");
        PurchAdvLetterHeaderCZZ.CheckPurchaseAdvanceLetterPostRestrictions();
        PurchAdvLetterHeaderCZZ.TestField("Currency Code", VendorLedgerEntry."Currency Code");
        PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", VendorLedgerEntry."Vendor No.");

        VendorLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
        if AdvancePostingParametersCZZ."Amount to Link" = 0 then begin
            Amount := VendorLedgerEntry."Remaining Amount";
            AmountLCY := VendorLedgerEntry."Remaining Amt. (LCY)";
        end else begin
            if AdvancePostingParametersCZZ."Amount to Link" > VendorLedgerEntry."Remaining Amount" then
                Error(ExceededRemainingAmountErr);

            Amount := AdvancePostingParametersCZZ."Amount to Link";
            AmountLCY := Round(Amount / VendorLedgerEntry."Original Currency Factor");
        end;

        PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
        if Amount > PurchAdvLetterHeaderCZZ."To Pay" then
            Error(ExceededAmountToPayErr);

        // Post payment application
        InitGenJournalLine(VendorLedgerEntry, GenJournalLine);
        GenJournalLine."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine.Amount := -Amount;
        GenJournalLine."Amount (LCY)" := -AmountLCY;
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            VendorLedgerEntry.SetApplication(PurchAdvLetterHeaderCZZ."Advance Letter Code", '');
            GenJournalLine."Applies-to ID" := VendorLedgerEntry."Applies-to ID";
            OnPostAdvancePaymentOnBeforePostPaymentApplication(
                PurchAdvLetterHeaderCZZ, PostedGenJournalLine, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvancePaymentOnAfterPostPaymentApplication(PurchAdvLetterHeaderCZZ, PostedGenJournalLine,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        // Post advance payment
        InitGenJournalLine(VendorLedgerEntry, GenJournalLine);
        GenJournalLine."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterHeaderCZZ."No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.Amount := Amount;
        GenJournalLine."Amount (LCY)" := AmountLCY;
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            OnPostAdvancePaymentOnBeforePostAdvancePayment(PurchAdvLetterHeaderCZZ, PostedGenJournalLine, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvancePaymentOnAfterPostAdvancePayment(PurchAdvLetterHeaderCZZ, PostedGenJournalLine,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        VendorLedgerEntryPayment.FindLast();

        TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
        TempPurchAdvLetterEntryCZZGlob.InitVendorLedgerEntry(VendorLedgerEntryPayment);
        TempPurchAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
        TempPurchAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::Payment;
        EntryNo := TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        if not AdvancePostingParametersCZZ."Temporary Entries Only" then
            PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::"To Use");

        OnAfterPostAdvancePayment(PurchAdvLetterHeaderCZZ, VendorLedgerEntry, PostedGenJournalLine, EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvancePaymentUnlinking(
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryAdv: Record "Vendor Ledger Entry";
        VendorLedgerEntryPay: Record "Vendor Ledger Entry";
        GLEntryNo: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePaymentUnlinking(PurchAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetFilter("Entry Type", '<>%1', PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if PurchAdvLetterEntryCZZ2.FindFirst() then
            Error(UnlinkIsNotPossibleErr, PurchAdvLetterEntryCZZ2."Entry Type");

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");

        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if PurchAdvLetterEntryCZZ2.FindSet() then
            repeat
                Clear(AdvancePostingBufferCZZ);
                AdvancePostingBufferCZZ.PrepareForPurchAdvLetterEntry(PurchAdvLetterEntryCZZ2);
                Clear(AdvancePostingParametersCZZ2);
                AdvancePostingParametersCZZ2.CopyFromPurchAdvLetterEntry(PurchAdvLetterEntryCZZ2);
                AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::Invoice;
                PostAdvancePaymentVATUnlinking(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ2);
            until PurchAdvLetterEntryCZZ2.Next() = 0;

        VendorLedgerEntryAdv.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
        VendorLedgerEntryPay := VendorLedgerEntryAdv;
#pragma warning disable AA0181
        VendorLedgerEntryPay.Next(-1);
#pragma warning restore AA0181
        UnapplyVendLedgEntry(VendorLedgerEntryPay, GenJnlPostLine);

        // Post advance payment application
        InitGenJournalLine(VendorLedgerEntryAdv, GenJournalLine);
        GenJournalLine."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterHeaderCZZ."No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.Correction := true;
        GenJournalLine.SetCurrencyFactor(
            PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := -PurchAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ."Amount (LCY)";
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            VendorLedgerEntryAdv.SetApplication('', PurchAdvLetterHeaderCZZ."No.");
            GenJournalLine."Applies-to ID" := VendorLedgerEntryAdv."Applies-to ID";
            OnPostAdvancePaymentUnlinkingOnBeforePostAdvancePaymentApplication(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvancePaymentUnlinkingOnAfterPostAdvancePaymentApplication(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        VendorLedgerEntry.FindLast();

        TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
        TempPurchAdvLetterEntryCZZGlob.InitVendorLedgerEntry(VendorLedgerEntry);
        TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(PurchAdvLetterEntryCZZ);
        TempPurchAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
        TempPurchAdvLetterEntryCZZGlob."Entry Type" := PurchAdvLetterEntryCZZ."Entry Type";
        TempPurchAdvLetterEntryCZZGlob.Cancelled := true;
        TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        // Post payment application balance
        InitGenJournalLine(VendorLedgerEntryAdv, GenJournalLine);
        GenJournalLine."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.SetCurrencyFactor(
            PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := PurchAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := PurchAdvLetterEntryCZZ."Amount (LCY)";
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            VendorLedgerEntryPay.SetApplication('', '');
            GenJournalLine."Applies-to ID" := VendorLedgerEntryPay."Applies-to ID";
            OnPostAdvancePaymentUnlinkingOnBeforePostPaymentApplication(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvancePaymentUnlinkingOnAfterPostPaymentApplication(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);

            PurchAdvLetterEntryCZZ.Cancelled := true;
            PurchAdvLetterEntryCZZ.Modify();

            PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::"To Pay");
        end;

        OnAfterPostAdvancePaymentUnlinking(PurchAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvancePaymentVAT(
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        EntryNo, GLEntryNo, VATEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePaymentVAT(PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        AdvancePostingParametersCZZ.CheckPurchaseDates();
        AdvancePostingParametersCZZ.CheckDocumentNo();

        PurchasesPayablesSetup.Get();
        if PurchasesPayablesSetup."Ext. Doc. No. Mandatory" then
            AdvancePostingParametersCZZ.CheckExternalDocumentNo();

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        if PurchAdvLetterHeaderCZZ."Amount Including VAT" = 0 then
            exit;

        AdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
        if AdvancePostingBufferCZZ.IsEmpty() then
            Error(NothingToPostErr);

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ2.CalcSums(Amount);
        AdvancePostingBufferCZZ.CalcSums(Amount);
        if Abs(PurchAdvLetterEntryCZZ.Amount - PurchAdvLetterEntryCZZ2.Amount) < Abs(AdvancePostingBufferCZZ.Amount) then
            Error(ExceededAmountErr);

        if AdvancePostingParametersCZZ."Source Code" = '' then begin
            VendorLedgerEntry.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
            AdvancePostingParametersCZZ."Source Code" := VendorLedgerEntry."Source Code";
        end;

        if AdvancePostingBufferCZZ.FindSet() then
            repeat
                GLEntryNo := 0;
                VATEntryNo := 0;

                VATPostingSetup.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");

                // Post VAT amount and VAT base of VAT document
                InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
                GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
                GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
                GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
                if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                    OnPostAdvancePaymentVATOnBeforePost(
                        PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                        AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                    GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
                    VATEntryNo := GenJnlPostLine.GetNextVATEntryNo() - 1;
                    OnPostAdvancePaymentVATOnAfterPost(
                        PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                        AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
                end;

                TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
                TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(PurchAdvLetterEntryCZZ);
                TempPurchAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
                TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
                TempPurchAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::"VAT Payment";
                TempPurchAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
                TempPurchAdvLetterEntryCZZGlob."VAT Identifier" := VATPostingSetup."VAT Identifier";
                TempPurchAdvLetterEntryCZZGlob."Auxiliary Entry" := AdvancePostingBufferCZZ."Auxiliary Entry";
                EntryNo := TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

                // Post balance of VAT document
                AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
                AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
                InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ2, GenJournalLine);
                GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
                AdvancePostingBufferCZZ.ReverseAmounts();
                GenJournalLine.CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
                if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                    OnPostAdvancePaymentVATOnBeforePostBalance(
                        PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                        AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                    GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                    OnPostAdvancePaymentVATOnAfterPostBalance(
                        PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                        AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
                end;

                // Post non-deductible VAT
                if (not AdvancePostingParametersCZZ."Temporary Entries Only") and
                   (AdvancePostingBufferCZZ."Non-Deductible VAT %" <> 0)
                then begin
                    PurchAdvLetterEntryCZZ2.Get(EntryNo); // VAT payment entry
                    PostNonDeductibleVAT(
                        PurchAdvLetterEntryCZZ2, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
                    PurchAdvLetterEntryCZZ2."Non-Deductible VAT %" := AdvancePostingBufferCZZ."Non-Deductible VAT %";
                    PurchAdvLetterEntryCZZ2.Modify();
                end;
            until AdvancePostingBufferCZZ.Next() = 0;

        OnAfterPostAdvancePaymentVAT(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure PostAdvancePaymentVATUnlinking(
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        EntryNo, GLEntryNo, VATEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePaymentVATUnlinking(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        VATPostingSetup.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");

        GLEntryNo := 0;
        VATEntryNo := 0;

        // Post advance payment VAT unlinking
        InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
        GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
        AdvancePostingBufferCZZ.ReverseAmounts();
        GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
        if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
            OnPostAdvancePaymentVATUnlinkingOnBeforePost(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
            VATEntryNo := GenJnlPostLine.GetNextVATEntryNo() - 1;
            OnPostAdvancePaymentVATUnlinkingOnAfterPost(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
        TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(PurchAdvLetterEntryCZZ."Related Entry");
        TempPurchAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
        TempPurchAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::"VAT Payment";
        TempPurchAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
        TempPurchAdvLetterEntryCZZGlob."VAT Identifier" := VATPostingSetup."VAT Identifier";
        TempPurchAdvLetterEntryCZZGlob."Auxiliary Entry" := AdvancePostingBufferCZZ."Auxiliary Entry";
        TempPurchAdvLetterEntryCZZGlob.Cancelled := true;
        EntryNo := TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        // Post balance of advance payment VAT unlinking
        AdvancePostingBufferCZZ.ReverseAmounts();
        AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
        InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ2, GenJournalLine);
        GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
        GenJournalLine.CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
        if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
            OnPostAdvancePaymentVATUnlinkingOnBeforePostBalance(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvancePaymentVATUnlinkingOnAfterPostBalance(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);

            PurchAdvLetterEntryCZZ.Cancelled := true;
            PurchAdvLetterEntryCZZ.Modify(true);
        end;

        OnAfterPostAdvancePaymentVATUnlinking(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvancePaymentUsage(
        var PurchInvHeader: Record "Purch. Inv. Header";
        var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParameters: Record "Advance Posting Parameters CZZ")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        TempPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ" temporary;
        AmountToUse, UseAmount, UseAmountLCY : Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePaymentUsage(PurchInvHeader, AdvanceLetterApplicationCZZ, GenJnlPostLine, AdvancePostingParameters, IsHandled);
        if IsHandled then
            exit;

        if PurchInvHeader."Remaining Amount" = 0 then
            PurchInvHeader.CalcFields("Remaining Amount");

        AmountToUse := PurchInvHeader."Remaining Amount";
        if AmountToUse = 0 then
            exit;

        if AdvanceLetterApplicationCZZ.IsEmpty() then
            exit;

        AdvanceLetterApplicationCZZ.FindSet();
        repeat
            PurchAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
            PurchAdvLetterHeaderCZZ.TestField("Currency Code", PurchInvHeader."Currency Code");
            PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", PurchInvHeader."Pay-to Vendor No.");

            PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", AdvanceLetterApplicationCZZ."Advance Letter No.");
            PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
            PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
            PurchAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', PurchInvHeader."Posting Date");
            OnPostAdvancePaymentUsageOnAfterSetPurchAdvLetterEntryFilter(AdvanceLetterApplicationCZZ, PurchAdvLetterEntryCZZ);
            if PurchAdvLetterEntryCZZ.FindSet() then
                repeat
                    TempPurchAdvLetterEntryCZZ.Init();
                    TempPurchAdvLetterEntryCZZ := PurchAdvLetterEntryCZZ;
                    TempPurchAdvLetterEntryCZZ.Amount := PurchAdvLetterEntryCZZ.GetRemainingAmount();
                    TempPurchAdvLetterEntryCZZ."Amount (LCY)" := PurchAdvLetterEntryCZZ.GetRemainingAmountLCY();
                    if TempPurchAdvLetterEntryCZZ.Amount <> 0 then
                        TempPurchAdvLetterEntryCZZ.Insert();
                until PurchAdvLetterEntryCZZ.Next() = 0;

            TempAdvanceLetterApplicationCZZ.Add(AdvanceLetterApplicationCZZ);
        until AdvanceLetterApplicationCZZ.Next() = 0;

        TempPurchAdvLetterEntryCZZ.Reset();
        TempPurchAdvLetterEntryCZZ.SetCurrentKey("Posting Date");
        if TempPurchAdvLetterEntryCZZ.FindSet() then begin
            repeat
                TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", TempPurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                TempAdvanceLetterApplicationCZZ.FindFirst();
                if TempAdvanceLetterApplicationCZZ.Amount < TempPurchAdvLetterEntryCZZ.Amount then
                    TempPurchAdvLetterEntryCZZ.Amount := TempAdvanceLetterApplicationCZZ.Amount;

                if AmountToUse > TempPurchAdvLetterEntryCZZ.Amount then
                    UseAmount := TempPurchAdvLetterEntryCZZ.Amount
                else
                    UseAmount := AmountToUse;

                if UseAmount <> 0 then begin
                    UseAmountLCY := Round(UseAmount / TempPurchAdvLetterEntryCZZ.GetAdjustedCurrencyFactor());
                    ReverseAdvancePayment(TempPurchAdvLetterEntryCZZ, PurchInvHeader, UseAmount, UseAmountLCY, GenJnlPostLine, AdvancePostingParameters);
                    AmountToUse -= UseAmount;
                    TempAdvanceLetterApplicationCZZ.Amount -= UseAmount;
                    TempAdvanceLetterApplicationCZZ."Amount (LCY)" -= UseAmountLCY;
                    TempAdvanceLetterApplicationCZZ.Modify();
                end;
            until (TempPurchAdvLetterEntryCZZ.Next() = 0) or (AmountToUse = 0);

            if not AdvancePostingParameters."Temporary Entries Only" then begin
                TempAdvanceLetterApplicationCZZ.Reset();
                if TempAdvanceLetterApplicationCZZ.FindSet() then
                    repeat
                        TempAdvanceLetterApplicationCZZ.ApplyChanges();
                    until TempAdvanceLetterApplicationCZZ.Next() = 0;
            end;
        end;

        OnAfterPostAdvancePaymentUsage(PurchInvHeader, AdvanceLetterApplicationCZZ, GenJnlPostLine, AdvancePostingParameters);
    end;

    internal procedure PostAdvancePaymentUsageForStatistics(
        var PurchaseHeader: Record "Purchase Header";
        Amount: Decimal;
        AmountLCY: Decimal;
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        PurchInvHeader: Record "Purch. Inv. Header";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        if not PurchAdvLetterEntryCZZ.IsTemporary then
            Error(TemporaryRecordErr);

        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.DeleteAll();

        if not TempPurchAdvLetterEntryCZZGlob.IsEmpty() then
            TempPurchAdvLetterEntryCZZGlob.DeleteAll();

        if not PurchaseHeader.IsAdvanceLetterDocTypeCZZ() then
            exit;

        PurchInvHeader.TransferFields(PurchaseHeader);
        PurchInvHeader."Remaining Amount" := Amount;

        AdvancePostingParametersCZZ."Temporary Entries Only" := true;
        AdvanceLetterApplicationCZZ.SetRange("Document Type", PurchaseHeader.GetAdvLetterUsageDocTypeCZZ());
        AdvanceLetterApplicationCZZ.SetRange("Document No.", PurchaseHeader."No.");
        PostAdvancePaymentUsage(PurchInvHeader, AdvanceLetterApplicationCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);

        if TempPurchAdvLetterEntryCZZGlob.FindSet() then begin
            repeat
                PurchAdvLetterEntryCZZ := TempPurchAdvLetterEntryCZZGlob;
                PurchAdvLetterEntryCZZ.Insert();
            until TempPurchAdvLetterEntryCZZGlob.Next() = 0;

            TempPurchAdvLetterEntryCZZGlob.DeleteAll();
        end;
    end;

    procedure PostAdvancePaymentUsageVAT(
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        RelatedPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePaymentUsageVAT(
            PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Usage then
            exit;
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        RelatedPurchAdvLetterEntryCZZ.Get(PurchAdvLetterEntryCZZ."Related Entry");
        if RelatedPurchAdvLetterEntryCZZ."Entry Type" <> RelatedPurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        ReverseAdvancePaymentVAT(
            RelatedPurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, PurchAdvLetterEntryCZZ."Entry No.",
            "Advance Letter Entry Type CZZ"::"VAT Usage", GenJnlPostLine, AdvancePostingParametersCZZ);

        OnAfterPostAdvancePaymentUsageVAT(
            PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvancePaymentUsageVATCancellation(
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GLEntryNo, VATEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePaymentUsageVATCancellation(
            PurchAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");

        PurchAdvLetterEntryCZZ2.Reset();
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ2.SetRange("Document No.", PurchAdvLetterEntryCZZ."Document No.");
        PurchAdvLetterEntryCZZ2.SetFilter("Entry Type", '%1|%2|%3',
            PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Adjustment",
            PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Rate",
            PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.Find('+');
        PurchAdvLetterEntryCZZ2.SetFilter("Entry No.", '..%1', PurchAdvLetterEntryCZZ2."Entry No.");
        VATPostingSetup.Get(PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
        repeat
            case PurchAdvLetterEntryCZZ2."Entry Type" of
                PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Adjustment":
                    PostUnrealizedExchangeRate(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, VATPostingSetup,
                        -PurchAdvLetterEntryCZZ2."Amount (LCY)", -PurchAdvLetterEntryCZZ2."VAT Amount (LCY)",
                        PurchAdvLetterEntryCZZ2."Related Entry", 0, true, PurchAdvLetterEntryCZZ2."Auxiliary Entry",
                        GenJnlPostLine, AdvancePostingParametersCZZ);
                PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Rate":
                    PostExchangeRate(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, VATPostingSetup,
                        -PurchAdvLetterEntryCZZ2."Amount (LCY)", -PurchAdvLetterEntryCZZ2."VAT Amount (LCY)",
                        PurchAdvLetterEntryCZZ2."Related Entry", true, PurchAdvLetterEntryCZZ2."Auxiliary Entry",
                        GenJnlPostLine, AdvancePostingParametersCZZ);
                PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage":
                    begin
                        AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
                        AdvancePostingParametersCZZ2."Currency Code" := PurchAdvLetterEntryCZZ2."Currency Code";
                        AdvancePostingParametersCZZ2."Currency Factor" := PurchAdvLetterEntryCZZ2."Currency Factor";

                        AdvancePostingBufferCZZ.PrepareForPurchAdvLetterEntry(PurchAdvLetterEntryCZZ2);

                        // Post advance payment VAT cancellation
                        InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, AdvancePostingParametersCZZ2, GenJournalLine);
                        GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
                        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
                        GenJournalLine.Correction := true;
                        AdvancePostingBufferCZZ.ReverseAmounts();
                        GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
                        if not AdvancePostingParametersCZZ2."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                            OnPostAdvancePaymentUsageVATCancellationOnBeforePost(
                                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, AdvancePostingBufferCZZ,
                                AdvancePostingParametersCZZ2, GenJnlPostLine, GenJournalLine);
                            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, false, false);
                            VATEntryNo := GenJnlPostLine.GetNextVATEntryNo() - 1;
                            OnPostAdvancePaymentUsageVATCancellationOnAfterPost(
                                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, AdvancePostingBufferCZZ,
                                AdvancePostingParametersCZZ2, GLEntryNo, GenJnlPostLine, GenJournalLine);
                        end;

                        TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
                        TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(PurchAdvLetterEntryCZZ2."Related Entry");
                        TempPurchAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
                        TempPurchAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::"VAT Usage";
                        TempPurchAdvLetterEntryCZZGlob."Purch. Adv. Letter No." := PurchAdvLetterHeaderCZZ."No.";
                        TempPurchAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
                        TempPurchAdvLetterEntryCZZGlob."VAT Identifier" := VATPostingSetup."VAT Identifier";
                        TempPurchAdvLetterEntryCZZGlob."Auxiliary Entry" := PurchAdvLetterEntryCZZ2."Auxiliary Entry";
                        TempPurchAdvLetterEntryCZZGlob.Cancelled := true;
                        TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(true);

                        // Post balance of advance payment VAT cancellation
                        AdvancePostingBufferCZZ.ReverseAmounts();
                        InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ2, GenJournalLine);
                        GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
                        GenJournalLine.Correction := true;
                        GenJournalLine.CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
                        if not AdvancePostingParametersCZZ2."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                            OnPostAdvancePaymentUsageVATCancellationOnBeforePostBalance(
                                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, AdvancePostingBufferCZZ,
                                AdvancePostingParametersCZZ2, GenJnlPostLine, GenJournalLine);
                            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                            OnPostAdvancePaymentUsageVATCancellationOnAfterPostBalance(
                                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, AdvancePostingBufferCZZ,
                                AdvancePostingParametersCZZ2, GLEntryNo, GenJnlPostLine, GenJournalLine);
                        end;
                    end;
            end;
        until PurchAdvLetterEntryCZZ2.Next(-1) = 0;

        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            PurchAdvLetterEntryCZZ2.ModifyAll(Cancelled, true);
            PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::"To Use");
        end;

        OnAfterPostAdvancePaymentUsageVATCancellation(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvanceCreditMemoVAT(
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        RelatedPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        VATDocumentPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        ExchRateAmount, ExchRateVATAmount : Decimal;
        EntryNo, GLEntryNo, VATEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceCreditMemoVAT(
            PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");

        AdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
        if AdvancePostingBufferCZZ.IsEmpty() then
            Error(NothingToPostErr);

        if PurchAdvLetterEntryCZZ."Currency Code" <> '' then begin
            RelatedPurchAdvLetterEntryCZZ.Get(PurchAdvLetterEntryCZZ."Related Entry");
            BufferAdvanceVATLines(RelatedPurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, 0D);
        end;

        AdvancePostingBufferCZZ.FindSet();
        repeat
            GLEntryNo := 0;
            VATEntryNo := 0;

            VATPostingSetup.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");

            // Post credit memo VAT
            InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
            GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
            AdvancePostingBufferCZZ.ReverseAmounts();
            GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                OnPostAdvanceCreditMemoVATOnBeforePost(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
                VATEntryNo := GenJnlPostLine.GetNextVATEntryNo() - 1;
                OnPostAdvanceCreditMemoVATOnAfterPost(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
            TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(PurchAdvLetterEntryCZZ."Related Entry");
            TempPurchAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
            TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
            TempPurchAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::"VAT Payment";
            TempPurchAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
            TempPurchAdvLetterEntryCZZGlob."VAT Identifier" := VATPostingSetup."VAT Identifier";
            TempPurchAdvLetterEntryCZZGlob."Auxiliary Entry" := AdvancePostingBufferCZZ."Auxiliary Entry";
            TempPurchAdvLetterEntryCZZGlob.Cancelled := true;
            EntryNo := TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

            AdvancePostingBufferCZZ.ReverseAmounts();
            if GenJournalLine."Currency Code" <> '' then
                if TempAdvancePostingBufferCZZ.Get(
                    AdvancePostingBufferCZZ."VAT Bus. Posting Group",
                    AdvancePostingBufferCZZ."VAT Prod. Posting Group")
                then begin
                    AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
                    AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
                    AdvancePostingParametersCZZ2."External Document No." := '';
                    AdvancePostingParametersCZZ2."Source Code" := '';
                    AdvancePostingParametersCZZ2."Currency Code" := '';
                    AdvancePostingParametersCZZ2."Currency Factor" := 0;

                    VATDocumentPurchAdvLetterEntryCZZ.Reset();
                    VATDocumentPurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                    VATDocumentPurchAdvLetterEntryCZZ.SetRange("Document No.", PurchAdvLetterEntryCZZ."Document No.");
                    VATDocumentPurchAdvLetterEntryCZZ.SetRange("Entry Type", "Advance Letter Entry Type CZZ"::"VAT Payment");
                    VATDocumentPurchAdvLetterEntryCZZ.SetRange("VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Bus. Posting Group");
                    VATDocumentPurchAdvLetterEntryCZZ.SetRange("VAT Prod. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");
                    VATDocumentPurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    VATDocumentPurchAdvLetterEntryCZZ.CalcSums("Amount (LCY)", "VAT Amount (LCY)");

                    ExchRateAmount := VATDocumentPurchAdvLetterEntryCZZ."Amount (LCY)" + GenJournalLine."Amount (LCY)";
                    ExchRateVATAmount := VATDocumentPurchAdvLetterEntryCZZ."VAT Amount (LCY)" + GenJournalLine."VAT Amount (LCY)";
                    if (ExchRateAmount <> 0) or (ExchRateVATAmount <> 0) then
                        PostExchangeRate(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                            -ExchRateAmount, -ExchRateVATAmount, PurchAdvLetterEntryCZZ."Related Entry",
                            true, AdvancePostingBufferCZZ."Auxiliary Entry", GenJnlPostLine, AdvancePostingParametersCZZ2);

                    ReverseUnrealizedExchangeRate(
                        RelatedPurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup,
                        AdvancePostingBufferCZZ.Amount / TempAdvancePostingBufferCZZ.Amount,
                        RelatedPurchAdvLetterEntryCZZ."Entry No.", AdvancePostingBufferCZZ."Auxiliary Entry",
                        GenJnlPostLine, AdvancePostingParametersCZZ2);
                end;

            // Post balance of credit memo VAT
            AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
            AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
            InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ2, GenJournalLine);
            GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
            GenJournalLine.CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                OnPostAdvanceCreditMemoVATOnBeforePostBalance(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostAdvanceCreditMemoVATOnAfterPostBalance(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            // Post non-deductible VAT
            if (not AdvancePostingParametersCZZ."Temporary Entries Only") and
               (AdvancePostingBufferCZZ."Non-Deductible VAT %" <> 0)
            then begin
                VATDocumentPurchAdvLetterEntryCZZ.Get(EntryNo); // VAT payment entry
                PostNonDeductibleVAT(
                    VATDocumentPurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
            end;
        until AdvancePostingBufferCZZ.Next() = 0;

        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            VATDocumentPurchAdvLetterEntryCZZ.Reset();
            VATDocumentPurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
            VATDocumentPurchAdvLetterEntryCZZ.SetRange("Document No.", PurchAdvLetterEntryCZZ."Document No.");
            VATDocumentPurchAdvLetterEntryCZZ.SetRange("Entry Type", "Advance Letter Entry Type CZZ"::"VAT Payment");
            VATDocumentPurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
            VATDocumentPurchAdvLetterEntryCZZ.ModifyAll(Cancelled, true);
        end;

        OnAfterPostAdvanceCreditMemoVAT(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvanceLetterApplying(
        var PurchInvHeader: Record "Purch. Inv. Header";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterApplying(PurchInvHeader, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        AdvanceLetterApplication.SetRange("Document Type", AdvanceLetterApplication."Document Type"::"Posted Purchase Invoice");
        AdvanceLetterApplication.SetRange("Document No.", PurchInvHeader."No.");
        if AdvanceLetterApplication.IsEmpty() then
            exit;

        PostAdvancePaymentUsage(PurchInvHeader, AdvanceLetterApplication, GenJnlPostLine, AdvancePostingParametersCZZ);

        OnAfterPostAdvanceLetterApplying(PurchInvHeader, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvanceLetterUnapplying(
        var PurchInvHeader: Record "Purch. Inv. Header";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterUnapplying(PurchInvHeader, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PurchInvHeader."No.");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if not PurchAdvLetterEntryCZZ.FindLast() then
            exit;

        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PurchInvHeader."No.");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ.Find('+');
        PurchAdvLetterEntryCZZ.SetFilter("Entry No.", '..%1', PurchAdvLetterEntryCZZ."Entry No.");
        repeat
            AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
            AdvancePostingParametersCZZ2."Posting Date" := PurchAdvLetterEntryCZZ."Posting Date";
            AdvancePostingParametersCZZ2."VAT Date" := PurchAdvLetterEntryCZZ."VAT Date";
            AdvancePostingParametersCZZ2."Posting Description" := PurchInvHeader."Posting Description";

            PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
            case PurchAdvLetterEntryCZZ."Entry Type" of
                PurchAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        PostUnrealizedExchangeRate(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                            -PurchAdvLetterEntryCZZ."Amount (LCY)", -PurchAdvLetterEntryCZZ."VAT Amount (LCY)",
                            PurchAdvLetterEntryCZZ."Related Entry", 0, true, PurchAdvLetterEntryCZZ."Auxiliary Entry",
                            GenJnlPostLine, AdvancePostingParametersCZZ2);
                    end;
                PurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate":
                    begin
                        AdvancePostingParametersCZZ2."Source Code" := PurchInvHeader."Source Code";

                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        PostExchangeRate(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                            -PurchAdvLetterEntryCZZ."Amount (LCY)", -PurchAdvLetterEntryCZZ."VAT Amount (LCY)",
                            PurchAdvLetterEntryCZZ."Related Entry", true, PurchAdvLetterEntryCZZ."Auxiliary Entry",
                            GenJnlPostLine, AdvancePostingParametersCZZ2);
                    end;
                PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage":
                    begin
                        AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::Invoice;
                        AdvancePostingParametersCZZ2."External Document No." := PurchAdvLetterEntryCZZ."External Document No.";
                        AdvancePostingParametersCZZ2."Source Code" := PurchInvHeader."Source Code";
                        AdvancePostingParametersCZZ2."VAT Date" := PurchInvHeader."VAT Reporting Date";
                        AdvancePostingParametersCZZ2."Original Document VAT Date" := PurchInvHeader."Original Doc. VAT Date CZL";
                        AdvancePostingParametersCZZ2."Currency Code" := PurchAdvLetterEntryCZZ."Currency Code";

                        Clear(AdvancePostingBufferCZZ);
                        AdvancePostingBufferCZZ.PrepareForPurchAdvLetterEntry(PurchAdvLetterEntryCZZ);

                        PostAdvanceLetterEntryVATUsageUnapplying(
                            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ2)
                    end;
                PurchAdvLetterEntryCZZ."Entry Type"::Usage:
                    begin
                        AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);

                        PostAdvanceLetterEntryUsageUnapplying(
                           PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ2);
                    end;
                else
                    Error(UnapplyIsNotPossibleErr);
            end;
        until PurchAdvLetterEntryCZZ.Next(-1) = 0;

        PurchAdvLetterEntryCZZ.ModifyAll(Cancelled, true);

        OnAfterPostAdvanceLetterUnapplying(PurchInvHeader, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure PostAdvanceLetterEntryVATUsageUnapplying(
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        VATEntry: Record "VAT Entry";
        EntryNo, GLEntryNo, VATEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterEntryVATUsageUnapplying(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        GLEntryNo := 0;
        VATEntryNo := 0;

        VATPostingSetup.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");

        InitGenJournalLine(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
        GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
        GenJournalLine.Correction := true;
        AdvancePostingBufferCZZ.ReverseAmounts();
        GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
        if (GenJournalLine."Currency Code" <> '') and
           (GenJournalLine."VAT Calculation Type" = GenJournalLine."VAT Calculation Type"::"Reverse Charge VAT")
        then
            if VATEntry.Get(PurchAdvLetterEntryCZZ."VAT Entry No.") then begin
                GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
                GenJournalLine."VAT Amount (LCY)" := -VATEntry.Amount;
            end;
        if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
            OnPostAdvanceLetterEntryVATUsageUnapplyingOnBeforePost(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
            VATEntryNo := GenJnlPostLine.GetNextVATEntryNo() - 1;
            OnPostAdvanceLetterEntryVATUsageUnapplyingOnAfterPost(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
        TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(PurchAdvLetterEntryCZZ."Related Entry");
        TempPurchAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
        TempPurchAdvLetterEntryCZZGlob."Entry Type" := PurchAdvLetterEntryCZZ."Entry Type";
        TempPurchAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
        TempPurchAdvLetterEntryCZZGlob."VAT Identifier" := VATPostingSetup."VAT Identifier";
        TempPurchAdvLetterEntryCZZGlob."Auxiliary Entry" := AdvancePostingBufferCZZ."Auxiliary Entry";
        TempPurchAdvLetterEntryCZZGlob.Cancelled := true;
        EntryNo := TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        AdvancePostingBufferCZZ.ReverseAmounts();

        AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
        InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ2, GenJournalLine);
        GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
        GenJournalLine.Correction := true;
        GenJournalLine.CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
        if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
            OnPostAdvanceLetterEntryVATUsageUnapplyingOnBeforePostBalance(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvanceLetterEntryVATUsageUnapplyingOnAfterPostBalance(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        OnAfterPostAdvanceLetterEntryVATUsageUnapplying(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ)
    end;

    local procedure PostAdvanceLetterEntryUsageUnapplying(
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryInv: Record "Vendor Ledger Entry";
        EntryNo, GLEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterEntryUsageUnapplying(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        VendorLedgerEntry.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
        VendorLedgerEntryInv := VendorLedgerEntry;
#pragma warning disable AA0181
        VendorLedgerEntryInv.Next(-1);
#pragma warning restore AA0181
        UnapplyVendLedgEntry(VendorLedgerEntry, GenJnlPostLine);

        InitGenJournalLine(VendorLedgerEntry, GenJournalLine);
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterHeaderCZZ."No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.SetCurrencyFactor(
            PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := -PurchAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ."Amount (LCY)";
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            VendorLedgerEntry.SetApplication('', '');
            GenJournalLine."Applies-to ID" := VendorLedgerEntry."Applies-to ID";
            OnPostAdvanceLetterEntryUsageUnapplyingOnBeforePostAdvancePaymentApplication(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, true);
            OnPostAdvanceLetterEntryUsageUnapplyingOnAfterPostAdvancePaymentApplication(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        VendorLedgerEntry.FindLast();

        TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
        TempPurchAdvLetterEntryCZZGlob.InitVendorLedgerEntry(VendorLedgerEntry);
        TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(PurchAdvLetterEntryCZZ);
        TempPurchAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
        TempPurchAdvLetterEntryCZZGlob."Entry Type" := PurchAdvLetterEntryCZZ."Entry Type";
        TempPurchAdvLetterEntryCZZGlob.Cancelled := true;
        EntryNo := TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        InitGenJournalLine(VendorLedgerEntry, GenJournalLine);
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine.SetCurrencyFactor(
            PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := PurchAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := PurchAdvLetterEntryCZZ."Amount (LCY)";
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            VendorLedgerEntryInv."Advance Letter No. CZZ" := '';
            VendorLedgerEntryInv.SetApplication('', '');
            GenJournalLine."Applies-to ID" := VendorLedgerEntryInv."Applies-to ID";
            OnPostAdvanceLetterEntryUsageUnapplyingOnBeforePostInvoiceApplication(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, true);
            OnPostAdvanceLetterEntryUsageUnapplyingOnAfterPostInvoiceApplication(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::"To Use");

        OnAfterPostAdvanceLetterEntryUsageUnapplying(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ)
    end;

    procedure PostAdvanceLetterClosing(
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        NextEntryNo: Integer;
        GetDocNoFromNoSeries: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterClosing(PurchAdvLetterHeaderCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::Closed then
            exit;

        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::New then begin
            PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::Closed);
            exit;
        end;

        GetDocNoFromNoSeries := AdvancePostingParametersCZZ."Document No." = '';

        if GetDocNoFromNoSeries then begin
            AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
            AdvanceLetterTemplateCZZ.TestField("Advance Letter Cr. Memo Nos.");
            AdvancePostingParametersCZZ."Document No." :=
                NoSeriesBatch.GetNextNo(
                    AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos.", AdvancePostingParametersCZZ."Posting Date");
            NextEntryNo := GenJnlPostLine.GetNextEntryNo();
        end;

        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        OnPostAdvanceLetterClosingOnAfterSetPurchAdvLetterEntryFilter(PurchAdvLetterEntryCZZ);
        if PurchAdvLetterEntryCZZ.FindSet() then
            repeat
                PostAdvanceLetterEntryClosing(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
            until PurchAdvLetterEntryCZZ.Next() = 0;

        if GetDocNoFromNoSeries and (NextEntryNo <> GenJnlPostLine.GetNextEntryNo()) then
            NoSeriesBatch.SaveState();

        PurchAdvLetterManagementCZZ.CancelInitEntry(PurchAdvLetterHeaderCZZ, AdvancePostingParametersCZZ."Posting Date", false);
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::Closed);

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase);
        AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", PurchAdvLetterHeaderCZZ."No.");
        AdvanceLetterApplicationCZZ.DeleteAll(true);

        OnAfterPostAdvanceLetterClosing(PurchAdvLetterHeaderCZZ, GenJnlPostLine, AdvancePostingParametersCZZ)
    end;

    local procedure PostAdvanceLetterEntryClosing(
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
        RemainingAmount, RemainingAmountLCY : Decimal;
        EntryNo, GLEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterEntryClosing(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        RemainingAmount := PurchAdvLetterEntryCZZ.GetRemainingAmount();
        RemainingAmountLCY := PurchAdvLetterEntryCZZ.GetRemainingAmountLCY();

        VendorLedgerEntry.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
        if RemainingAmount <> 0 then begin
            InitGenJournalLine(VendorLedgerEntry, GenJournalLine);
            GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
            GenJournalLine.Correction := true;
            GenJournalLine."Document Type" := AdvancePostingParametersCZZ."Document Type";
            GenJournalLine."Document No." := AdvancePostingParametersCZZ."Document No.";
            GenJournalLine."External Document No." := AdvancePostingParametersCZZ."External Document No.";
            GenJournalLine."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
            GenJournalLine."Document Date" := AdvancePostingParametersCZZ."Document Date";
            GenJournalLine."VAT Reporting Date" := AdvancePostingParametersCZZ."VAT Date";
            GenJournalLine."Original Doc. VAT Date CZL" := AdvancePostingParametersCZZ."Original Document VAT Date";
            GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
            GenJournalLine."Use Advance G/L Account CZZ" := true;
            GenJournalLine.SetCurrencyFactor(
                AdvancePostingParametersCZZ."Currency Code", AdvancePostingParametersCZZ."Currency Factor");
            GenJournalLine.Amount := -RemainingAmount;
            GenJournalLine."Amount (LCY)" := -Round(RemainingAmount / GenJournalLine."Currency Factor");
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                VendorLedgerEntry.SetApplication('', PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                GenJournalLine."Applies-to ID" := VendorLedgerEntry."Applies-to ID";
                OnPostAdvanceLetterEntryClosingOnBeforePost(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VendorLedgerEntry,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostAdvanceLetterEntryClosingOnAfterPost(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VendorLedgerEntry,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            VendorLedgerEntry2.FindLast();

            TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
            TempPurchAdvLetterEntryCZZGlob.InitVendorLedgerEntry(VendorLedgerEntry2);
            TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(PurchAdvLetterEntryCZZ);
            TempPurchAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
            TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
            TempPurchAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::Close;
            TempPurchAdvLetterEntryCZZGlob."Amount (LCY)" := -RemainingAmountLCY;
            EntryNo := TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");
        end;

        AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::"Credit Memo";

        BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, 0D);
        SuggestUsageVAT(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, VendorLedgerEntry."Document No.",
            0, AdvancePostingParametersCZZ."Currency Factor", AdvancePostingParametersCZZ2."Temporary Entries Only");

        ReverseAdvancePaymentVAT(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, EntryNo,
            "Advance Letter Entry Type CZZ"::"VAT Close", GenJnlPostLine, AdvancePostingParametersCZZ2);

        if RemainingAmount <> 0 then begin
            InitGenJournalLine(VendorLedgerEntry, GenJournalLine);
            GenJournalLine."Document Type" := GenJournalLine."Document Type"::Payment;
            GenJournalLine.Correction := true;
            GenJournalLine."Document No." := AdvancePostingParametersCZZ."Document No.";
            GenJournalLine."External Document No." := AdvancePostingParametersCZZ."External Document No.";
            GenJournalLine."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
            GenJournalLine."Document Date" := AdvancePostingParametersCZZ."Document Date";
            GenJournalLine."VAT Reporting Date" := AdvancePostingParametersCZZ."VAT Date";
            GenJournalLine."Original Doc. VAT Date CZL" := AdvancePostingParametersCZZ."Original Document VAT Date";
            GenJournalLine.SetCurrencyFactor(
                AdvancePostingParametersCZZ."Currency Code", AdvancePostingParametersCZZ."Currency Factor");
            GenJournalLine.Amount := RemainingAmount;
            GenJournalLine."Amount (LCY)" := Round(RemainingAmount / GenJournalLine."Currency Factor");
            GenJournalLine."Variable Symbol CZL" := PurchAdvLetterHeaderCZZ."Variable Symbol";
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostAdvanceLetterEntryClosingOnBeforePostBalance(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VendorLedgerEntry,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostAdvanceLetterEntryClosingOnAfterPostBalance(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VendorLedgerEntry,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;
        end;

        OnAfterPostAdvanceLetterEntryClosing(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure ReverseAdvancePayment(
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchInvHeader: Record "Purch. Inv. Header";
        ReverseAmount: Decimal;
        ReverseAmountLCY: Decimal;
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
        EntryNo, GLEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReverseAdvancePayment(
            PurchAdvLetterEntryCZZ, PurchInvHeader, ReverseAmount, ReverseAmountLCY,
            GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if ReverseAmount <> 0 then begin
            if ReverseAmount > PurchAdvLetterEntryCZZ.Amount then
                Error(ReverseAmountErr, ReverseAmount, PurchAdvLetterEntryCZZ."Entry No.");
        end else begin
            ReverseAmount := PurchAdvLetterEntryCZZ.Amount;
            ReverseAmountLCY := PurchAdvLetterEntryCZZ."Amount (LCY)";
        end;

        if not AdvancePostingParametersCZZ."Temporary Entries Only" then
            VendorLedgerEntry.Get(PurchInvHeader."Vendor Ledger Entry No.")
        else
            InitVendorLedgerEntryFromPurchInvHeader(PurchInvHeader, VendorLedgerEntry);

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");

        // Post invoice application
        InitGenJournalLine(VendorLedgerEntry, GenJournalLine);
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine.Amount := ReverseAmount;
        GenJournalLine."Amount (LCY)" := ReverseAmountLCY;
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            VendorLedgerEntry.SetApplication(PurchAdvLetterHeaderCZZ."Advance Letter Code", '');
            GenJournalLine."Applies-to ID" := VendorLedgerEntry."Applies-to ID";

            OnReverseAdvancePaymentOnBeforePostInvoiceApplication(
                PurchAdvLetterHeaderCZZ, VendorLedgerEntry, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, true);
            OnReverseAdvancePaymentOnAfterPostInvoiceApplication(PurchAdvLetterHeaderCZZ, VendorLedgerEntry,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        // Post advance payment usage
        InitGenJournalLine(VendorLedgerEntry, GenJournalLine);
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.Amount := -ReverseAmount;
        GenJournalLine."Amount (LCY)" := -ReverseAmountLCY;

        VendorLedgerEntry2.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            VendorLedgerEntry2.SetApplication('', PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
            GenJournalLine."Applies-to ID" := VendorLedgerEntry2."Applies-to ID";

            OnReverseAdvancePaymentOnBeforePostAdvancePaymentUsage(
                PurchAdvLetterHeaderCZZ, VendorLedgerEntry, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, true, true);
            OnReverseAdvancePaymentOnAfterPostAdvancePaymentUsage(PurchAdvLetterHeaderCZZ, VendorLedgerEntry,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);

            VendorLedgerEntry2.FindLast();
        end;

        TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
        TempPurchAdvLetterEntryCZZGlob.InitVendorLedgerEntry(VendorLedgerEntry2);
        TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(PurchAdvLetterEntryCZZ);
        TempPurchAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
        TempPurchAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::Usage;
        TempPurchAdvLetterEntryCZZGlob."Amount (LCY)" :=
            Round(TempPurchAdvLetterEntryCZZGlob.Amount / PurchAdvLetterEntryCZZ."Currency Factor");
        EntryNo := TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        if PurchAdvLetterHeaderCZZ."Automatic Post VAT Usage" then begin
            Clear(AdvancePostingParametersCZZ2);
            AdvancePostingParametersCZZ2.CopyFromVendorLedgerEntry(VendorLedgerEntry);
            AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::Invoice;
            if PurchInvHeader."Original Doc. VAT Date CZL" <> 0D then
                AdvancePostingParametersCZZ2."Original Document VAT Date" := PurchInvHeader."Original Doc. VAT Date CZL";
            AdvancePostingParametersCZZ2."Currency Code" := PurchAdvLetterEntryCZZ."Currency Code";
            AdvancePostingParametersCZZ2."Currency Factor" := PurchInvHeader."VAT Currency Factor CZL";
            AdvancePostingParametersCZZ2."Temporary Entries Only" := AdvancePostingParametersCZZ."Temporary Entries Only";

            BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, 0D);
            SuggestUsageVAT(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, VendorLedgerEntry."Document No.",
                ReverseAmount, PurchInvHeader."VAT Currency Factor CZL", AdvancePostingParametersCZZ2."Temporary Entries Only");

            ReverseAdvancePaymentVAT(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, EntryNo,
                "Advance Letter Entry Type CZZ"::"VAT Usage", GenJnlPostLine, AdvancePostingParametersCZZ2);
        end;

        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
            PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::Closed);
        end;

        OnAfterReverseAdvancePayment(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ,
            PurchInvHeader, EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure ReverseAdvancePaymentVAT(
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        RelatedEntryNo: Integer;
        EntryType: Enum "Advance Letter Entry Type CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        VATDocumentPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        NonDeductibleVATCZZ: Codeunit "Non-Deductible VAT CZZ";
        CalcVATAmountLCY, CalcAmountLCY, ExchRateAmount, ExchRateVATAmount, AmountToUse : Decimal;
        EntryNo, GLEntryNo, VATEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReverseAdvancePaymentVAT(
            PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, RelatedEntryNo, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        VATDocumentPurchAdvLetterEntryCZZ.Reset();
        VATDocumentPurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        VATDocumentPurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        VATDocumentPurchAdvLetterEntryCZZ.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        VATDocumentPurchAdvLetterEntryCZZ.SetRange("Entry Type", VATDocumentPurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        if VATDocumentPurchAdvLetterEntryCZZ.IsEmpty() then
            exit;

        AdvancePostingBufferCZZ.FilterGroup(-1);
        AdvancePostingBufferCZZ.SetFilter("VAT Base Amount", '<>0');
        AdvancePostingBufferCZZ.SetFilter("VAT Amount", '<>0');
        AdvancePostingBufferCZZ.FilterGroup(0);
        if AdvancePostingBufferCZZ.IsEmpty() then
            exit;

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");

        if PurchAdvLetterEntryCZZ."Currency Code" <> '' then begin
            BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, 0D);
            TempAdvancePostingBufferCZZ.CalcSums(Amount);
            AmountToUse := TempAdvancePostingBufferCZZ.Amount;
        end;

        CalculateVATAmountInBuffer(
            AdvancePostingParametersCZZ."Posting Date", AdvancePostingParametersCZZ."Currency Code",
            AdvancePostingParametersCZZ."Currency Factor", AdvancePostingBufferCZZ);

        AdvancePostingBufferCZZ.FindSet();
        repeat
            GLEntryNo := 0;
            VATEntryNo := 0;

            VATPostingSetup.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");

            // Post reverse advance payment VAT
            InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
            GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
            AdvancePostingBufferCZZ.ReverseAmounts();
            GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
            if GenJournalLine."VAT Calculation Type" = GenJournalLine."VAT Calculation Type"::"Reverse Charge VAT" then
                GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
            if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                OnReverseAdvancePaymentVATOnBeforePost(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                    AdvancePostingBufferCZZ, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
                VATEntryNo := GenJnlPostLine.GetNextVATEntryNo() - 1;
                OnReverseAdvancePaymentVATOnAfterPost(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            if AdvancePostingBufferCZZ."VAT Calculation Type" = AdvancePostingBufferCZZ."VAT Calculation Type"::"Reverse Charge VAT" then begin
                GenJournalLine."VAT Amount" := 0;
                GenJournalLine."VAT Amount (LCY)" := 0;
            end;

            TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
            TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(RelatedEntryNo);
            TempPurchAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
            TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
            TempPurchAdvLetterEntryCZZGlob."Entry Type" := EntryType;
            TempPurchAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
            TempPurchAdvLetterEntryCZZGlob."VAT Identifier" := VATPostingSetup."VAT Identifier";
            TempPurchAdvLetterEntryCZZGlob."Auxiliary Entry" := AdvancePostingBufferCZZ."Auxiliary Entry";
            EntryNo := TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

            AdvancePostingBufferCZZ.ReverseAmounts();
            if GenJournalLine."Currency Code" <> '' then
                if TempAdvancePostingBufferCZZ.Get(
                    AdvancePostingBufferCZZ."VAT Bus. Posting Group",
                    AdvancePostingBufferCZZ."VAT Prod. Posting Group")
                then begin
                    AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
                    AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
                    AdvancePostingParametersCZZ2."External Document No." := '';
                    AdvancePostingParametersCZZ2."Currency Code" := '';
                    AdvancePostingParametersCZZ2."Currency Factor" := 0;

                    CalcAmountLCY := Round(TempAdvancePostingBufferCZZ."Amount (ACY)" * AdvancePostingBufferCZZ.Amount / TempAdvancePostingBufferCZZ.Amount);
                    CalcVATAmountLCY := Round(TempAdvancePostingBufferCZZ."VAT Amount (ACY)" * AdvancePostingBufferCZZ.Amount / TempAdvancePostingBufferCZZ.Amount);

                    ExchRateAmount := CalcAmountLCY + GenJournalLine."Amount (LCY)";
                    ExchRateVATAmount := CalcVATAmountLCY + GenJournalLine."VAT Amount (LCY)";
                    if (ExchRateAmount <> 0) or (ExchRateVATAmount <> 0) then
                        PostExchangeRate(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, -ExchRateAmount, -ExchRateVATAmount,
                            RelatedEntryNo, false, AdvancePostingBufferCZZ."Auxiliary Entry", GenJnlPostLine, AdvancePostingParametersCZZ2);

                    AdvancePostingParametersCZZ2."Source Code" := '';
                    ReverseUnrealizedExchangeRate(
                        PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, AdvancePostingBufferCZZ.Amount / AmountToUse,
                        RelatedEntryNo, AdvancePostingBufferCZZ."Auxiliary Entry", GenJnlPostLine, AdvancePostingParametersCZZ2);
                end;

            // Post balance of reverse advance payment VAT
            AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
            AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
            InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ2, GenJournalLine);
            GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
            GenJournalLine.CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                OnReverseAdvancePaymentVATOnBeforePostBalance(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                    AdvancePostingBufferCZZ, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnReverseAdvancePaymentVATOnAfterPostBalance(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            // Post non-deductible VAT
            if (not AdvancePostingParametersCZZ."Temporary Entries Only") and
               (AdvancePostingBufferCZZ."Non-Deductible VAT %" <> 0)
            then begin
                VATDocumentPurchAdvLetterEntryCZZ.Get(EntryNo); // VAT usage or VAT close entry
                AdvancePostingBufferCZZ."Non-Deductible VAT %" :=
                    NonDeductibleVATCZZ.GetNonDeductibleVATPct(
                        AdvancePostingBufferCZZ, VATDocumentPurchAdvLetterEntryCZZ."VAT Date");
                PostNonDeductibleVAT(
                    VATDocumentPurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
                VATDocumentPurchAdvLetterEntryCZZ."Non-Deductible VAT %" := AdvancePostingBufferCZZ."Non-Deductible VAT %";
                VATDocumentPurchAdvLetterEntryCZZ.Modify();
            end;
        until AdvancePostingBufferCZZ.Next() = 0;

        if not AdvancePostingParametersCZZ."Temporary Entries Only" then
            PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::Closed);

        OnAfterReverseAdvancePaymentVAT(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ,
            AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure ReverseUnrealizedExchangeRate(
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        Coef: Decimal;
        RelatedEntryNo: Integer;
        AuxiliaryEntry: Boolean;
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AmountLCY, VATAmountLCY : Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReverseUnrealizedExchangeRate(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Coef,
            RelatedEntryNo, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        PurchAdvLetterManagementCZZ.GetRemAmtLCYVATAdjust(
            AmountLCY, VATAmountLCY, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ."Posting Date",
            VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        if (AmountLCY = 0) and (VATAmountLCY = 0) then
            exit;

        AmountLCY := Round(AmountLCY * Coef);
        VATAmountLCY := Round(VATAmountLCY * Coef);

        PostUnrealizedExchangeRate(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, -AmountLCY, -VATAmountLCY,
            RelatedEntryNo, 0, false, AuxiliaryEntry, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    internal procedure PostExchangeRate(
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        Amount: Decimal;
        VATAmount: Decimal;
        RelatedEntryNo: Integer;
        Correction: Boolean;
        AuxiliaryEntry: Boolean;
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        GenJournalLine: Record "Gen. Journal Line";
        EntryNo, GLEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostExchangeRate(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
            RelatedEntryNo, Correction, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if (Amount = 0) and (VATAmount = 0) then
            exit;

        if VATAmount <> 0 then begin
            GetCurrency(PurchAdvLetterHeaderCZZ."Currency Code");

            // Post exchange rate of VAT Base
            InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine.Correction := Correction;
            GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
            GenJournalLine.Validate(Amount, Amount - VATAmount);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostExchangeRateOnBeforePostVATBase(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostExchangeRateOnAfterPostVATBase(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            // Post exchange rate of VAT Amount
            InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine."Shortcut Dimension 1 Code" := PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code";
            GenJournalLine."Shortcut Dimension 2 Code" := PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code";
            GenJournalLine."Dimension Set ID" := PurchAdvLetterHeaderCZZ."Dimension Set ID";
            GenJournalLine.Correction := true;
            if VATAmount < 0 then
                GenJournalLine."Account No." := CurrencyGlob.GetRealizedLossesAccount()
            else
                GenJournalLine."Account No." := CurrencyGlob.GetRealizedGainsAccount();
            GenJournalLine.Validate(Amount, VATAmount);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostExchangeRateOnBeforePostVATAmount(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostExchangeRateOnAfterPostVATAmount(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            // Post balance of exchange rate
            InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine.Correction := Correction;
            GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
            GenJournalLine.Validate(Amount, -Amount);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostExchangeRateOnBeforePostBalance(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostExchangeRateOnAfterPostBalance(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;
        end;

        TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
        TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(RelatedEntryNo);
        TempPurchAdvLetterEntryCZZGlob.CopyFromVATPostingSetup(VATPostingSetup);
        TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
        TempPurchAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::"VAT Rate";
        TempPurchAdvLetterEntryCZZGlob."Document No." := AdvancePostingParametersCZZ."Document No.";
        TempPurchAdvLetterEntryCZZGlob."External Document No." := AdvancePostingParametersCZZ."External Document No.";
        TempPurchAdvLetterEntryCZZGlob."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        TempPurchAdvLetterEntryCZZGlob."VAT Date" := AdvancePostingParametersCZZ."VAT Date";
        TempPurchAdvLetterEntryCZZGlob."Original Document VAT Date" := AdvancePostingParametersCZZ."Original Document VAT Date";
        TempPurchAdvLetterEntryCZZGlob."Amount (LCY)" := Amount;
        TempPurchAdvLetterEntryCZZGlob."VAT Amount (LCY)" := VATAmount;
        TempPurchAdvLetterEntryCZZGlob."VAT Base Amount (LCY)" := Amount - VATAmount;
        TempPurchAdvLetterEntryCZZGlob."Global Dimension 1 Code" := PurchAdvLetterEntryCZZ."Global Dimension 1 Code";
        TempPurchAdvLetterEntryCZZGlob."Global Dimension 2 Code" := PurchAdvLetterEntryCZZ."Global Dimension 2 Code";
        TempPurchAdvLetterEntryCZZGlob."Dimension Set ID" := PurchAdvLetterEntryCZZ."Dimension Set ID";
        TempPurchAdvLetterEntryCZZGlob.Cancelled := Correction;
        TempPurchAdvLetterEntryCZZGlob."Auxiliary Entry" := AuxiliaryEntry;
        OnPostExchangeRateOnBeforeInsertEntry(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
            AdvancePostingParametersCZZ, TempPurchAdvLetterEntryCZZGlob);
        EntryNo := TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        OnAfterPostExchangeRate(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
            EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ, TempPurchAdvLetterEntryCZZGlob);
    end;

    internal procedure PostUnrealizedExchangeRate(
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        Amount: Decimal;
        VATAmount: Decimal;
        RelatedEntryNo: Integer;
        RelatedDetEntryNo: Integer;
        Correction: Boolean;
        AuxiliaryEntry: Boolean;
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        EntryNo, GLEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostUnrealizedExchangeRate(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
            RelatedEntryNo, RelatedDetEntryNo, Correction, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if AdvancePostingParametersCZZ."Source Code" = '' then begin
            SourceCodeSetup.Get();
            AdvancePostingParametersCZZ."Source Code" := SourceCodeSetup."Exchange Rate Adjmt.";
        end;

        if VATAmount <> 0 then begin
            GetCurrency(PurchAdvLetterHeaderCZZ."Currency Code");

            // Post unrealized exchange rate
            InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine."Shortcut Dimension 1 Code" := PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code";
            GenJournalLine."Shortcut Dimension 2 Code" := PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code";
            GenJournalLine."Dimension Set ID" := PurchAdvLetterHeaderCZZ."Dimension Set ID";
            if VATAmount > 0 then
                GenJournalLine."Account No." := CurrencyGlob.GetUnrealizedLossesAccount()
            else
                GenJournalLine."Account No." := CurrencyGlob.GetUnrealizedGainsAccount();
            GenJournalLine.Validate(Amount, VATAmount);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostUnrealizedExchangeRateOnBeforePost(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostUnrealizedExchangeRateOnAfterPost(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            // Post unrealized exchange rate balance
            InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
            GenJournalLine.Validate(Amount, -VATAmount);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostUnrealizedExchangeRateOnBeforePostBalance(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostUnrealizedExchangeRateOnAfterPostBalance(
                    PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;
        end;

        TempPurchAdvLetterEntryCZZGlob.InitNewEntry();
        TempPurchAdvLetterEntryCZZGlob.InitRelatedEntry(RelatedEntryNo);
        TempPurchAdvLetterEntryCZZGlob.InitDetailedVendorLedgerEntry(RelatedDetEntryNo);
        TempPurchAdvLetterEntryCZZGlob.CopyFromVATPostingSetup(VATPostingSetup);
        TempPurchAdvLetterEntryCZZGlob.CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ);
        TempPurchAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::"VAT Adjustment";
        TempPurchAdvLetterEntryCZZGlob."Document No." := AdvancePostingParametersCZZ."Document No.";
        TempPurchAdvLetterEntryCZZGlob."External Document No." := AdvancePostingParametersCZZ."External Document No.";
        TempPurchAdvLetterEntryCZZGlob."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        TempPurchAdvLetterEntryCZZGlob."VAT Date" := AdvancePostingParametersCZZ."VAT Date";
        TempPurchAdvLetterEntryCZZGlob."Original Document VAT Date" := AdvancePostingParametersCZZ."Original Document VAT Date";
        TempPurchAdvLetterEntryCZZGlob."Amount (LCY)" := Amount;
        TempPurchAdvLetterEntryCZZGlob."VAT Amount (LCY)" := VATAmount;
        TempPurchAdvLetterEntryCZZGlob."VAT Base Amount (LCY)" := Amount - VATAmount;
        TempPurchAdvLetterEntryCZZGlob."Global Dimension 1 Code" := PurchAdvLetterEntryCZZ."Global Dimension 1 Code";
        TempPurchAdvLetterEntryCZZGlob."Global Dimension 2 Code" := PurchAdvLetterEntryCZZ."Global Dimension 2 Code";
        TempPurchAdvLetterEntryCZZGlob."Dimension Set ID" := PurchAdvLetterEntryCZZ."Dimension Set ID";
        TempPurchAdvLetterEntryCZZGlob.Cancelled := Correction;
        TempPurchAdvLetterEntryCZZGlob."Auxiliary Entry" := AuxiliaryEntry;
        OnPostUnrealizedExchangeRateOnBeforeInsertEntry(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
            AdvancePostingParametersCZZ, TempPurchAdvLetterEntryCZZGlob);
        EntryNo := TempPurchAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        OnAfterPostUnrealizedExchangeRate(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
            EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ, TempPurchAdvLetterEntryCZZGlob);
    end;

    internal procedure PostNonDeductibleVAT(
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        NonDeductibleVATCZZ: Codeunit "Non-Deductible VAT CZZ";
        GLEntryNo: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostNonDeductibleVAT(
            PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if AdvancePostingBufferCZZ."Non-Deductible VAT %" = 0 then
            exit;

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        VATPostingSetup.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");

        InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
        GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterAccountCZZ();
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
        GenJournalLine.Correction := true;
        GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
        if (AdvancePostingBufferCZZ."VAT Calculation Type" = AdvancePostingBufferCZZ."VAT Calculation Type"::"Reverse Charge VAT") and
           (AdvancePostingBufferCZZ."VAT Amount (ACY)" <> 0)
        then
            GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            OnPostNonDeductibleVATOnBeforePost(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                AdvancePostingBufferCZZ, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
            OnPostNonDeductibleVATOnAfterPost(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        InitGenJournalLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
        GenJournalLine."Account No." := VATPostingSetup.GetPurchAdvLetterNDVATAccountCZZ();
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
        AdvancePostingBufferCZZ.ReverseAmounts();
        GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
        if (AdvancePostingBufferCZZ."VAT Calculation Type" = AdvancePostingBufferCZZ."VAT Calculation Type"::"Reverse Charge VAT") and
           (AdvancePostingBufferCZZ."VAT Amount (ACY)" <> 0)
        then begin
            NonDeductibleVATCZZ.Calculate(AdvancePostingBufferCZZ);
            NonDeductibleVATCZZ.Copy(GenJournalLine, AdvancePostingBufferCZZ);
            GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        end else
            GenJournalLine.Validate("Non-Deductible VAT %", AdvancePostingBufferCZZ."Non-Deductible VAT %");
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            OnPostNonDeductibleVATOnBeforePostBalance(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                AdvancePostingBufferCZZ, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
            OnPostNonDeductibleVATOnAfterPostBalance(
                PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        OnAfterPostNonDeductibleVAT(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ,
            AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    internal procedure BufferAdvanceVATLines(
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        BalanceAtDate: Date)
    begin
        BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, BalanceAtDate, true);
    end;

    local procedure BufferAdvanceVATLines(
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        BalanceAtDate: Date;
        ResetBuffer: Boolean)
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
    begin
        if ResetBuffer then begin
            AdvancePostingBufferCZZ.Reset();
            AdvancePostingBufferCZZ.DeleteAll();
        end;

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetFilter("Entry Type", '<>%1', PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Adjustment");
        if BalanceAtDate <> 0D then
            PurchAdvLetterEntryCZZ2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        if PurchAdvLetterEntryCZZ2.FindSet() then
            repeat
                if PurchAdvLetterEntryCZZ2."Entry Type" in
                  [PurchAdvLetterEntryCZZ2."Entry Type"::Payment,
                   PurchAdvLetterEntryCZZ2."Entry Type"::Usage,
                   PurchAdvLetterEntryCZZ2."Entry Type"::Close]
                then
                    BufferAdvanceVATLines(PurchAdvLetterEntryCZZ2, AdvancePostingBufferCZZ, BalanceAtDate, false)
                else begin
                    TempAdvancePostingBufferCZZ.PrepareForPurchAdvLetterEntry(PurchAdvLetterentryCZZ2);
                    AdvancePostingBufferCZZ.Update(TempAdvancePostingBufferCZZ);
                end;
            until PurchAdvLetterEntryCZZ2.Next() = 0;
    end;

    local procedure CalculateVATAmountInBuffer(
        PostingDate: Date;
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        var TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        CurrExchRate: Record "Currency Exchange Rate";
        VATAmount: Decimal;
        VATAmountRemainder: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalculateVATAmountInBuffer(PostingDate, CurrencyCode, CurrencyFactor, TempAdvancePostingBufferCZZ, IsHandled);
        if IsHandled then
            exit;

        VATAmountRemainder := 0;

        GetCurrency(CurrencyCode);

        if TempAdvancePostingBufferCZZ.FindSet() then
            repeat
                if TempAdvancePostingBufferCZZ."VAT Calculation Type" = TempAdvancePostingBufferCZZ."VAT Calculation Type"::"Reverse Charge VAT" then begin
                    VATPostingSetup.Get(TempAdvancePostingBufferCZZ."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ."VAT Prod. Posting Group");

                    VATAmount := TempAdvancePostingBufferCZZ."VAT Base Amount" * VATPostingSetup."VAT %" / 100;

                    VATAmountRemainder += VATAmount;
                    TempAdvancePostingBufferCZZ."VAT Amount" := Round(VATAmountRemainder, CurrencyGlob."Amount Rounding Precision");
                    TempAdvancePostingBufferCZZ."VAT Amount (ACY)" := TempAdvancePostingBufferCZZ."VAT Amount";
                    VATAmountRemainder -= TempAdvancePostingBufferCZZ."VAT Amount";

                    if CurrencyCode <> '' then
                        TempAdvancePostingBufferCZZ."VAT Amount (ACY)" :=
                            Round(
                                CurrExchRate.ExchangeAmtFCYToLCY(
                                    PostingDate, CurrencyCode, TempAdvancePostingBufferCZZ."VAT Amount", CurrencyFactor));
                    TempAdvancePostingBufferCZZ.Modify();
                end
            until TempAdvancePostingBufferCZZ.Next() = 0;
    end;

    internal procedure SuggestUsageVAT(
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        InvoiceNo: Code[20];
        UsedAmount: Decimal;
        CurrencyFactor: Decimal;
        TemporaryEntriesOnly: Boolean)
    var
        PurchInvLine: Record "Purch. Inv. Line";
        PurchaseLine: Record "Purchase Line";
        TempAdvancePostingBufferCZZ1: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ2: Record "Advance Posting Buffer CZZ" temporary;
        TotalAmount: Decimal;
        UseAmount: Decimal;
        UseBaseAmount: Decimal;
        i: Integer;
        Continue: Boolean;
    begin
        AdvancePostingBufferCZZ.CalcSums(Amount);
        TotalAmount := AdvancePostingBufferCZZ.Amount;
        if (UsedAmount <> 0) and (TotalAmount > UsedAmount) then begin
            Continue := InvoiceNo <> '';
            if Continue then
                if TemporaryEntriesOnly then begin
                    PurchaseLine.SetFilter("Document Type", '%1|%2',
                        PurchaseLine."Document Type"::Order,
                        PurchaseLine."Document Type"::Invoice);
                    PurchaseLine.SetRange("Document No.", InvoiceNo);
                    Continue := PurchaseLine.FindSet();
                end else begin
                    PurchInvLine.SetRange("Document No.", InvoiceNo);
                    Continue := PurchInvLine.FindSet();
                end;

            if Continue then begin
                BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ2, 0D);

                if TemporaryEntriesOnly then
                    repeat
                        TempAdvancePostingBufferCZZ1.Init();
                        TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group" := PurchaseLine."VAT Bus. Posting Group";
                        TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group" := PurchaseLine."VAT Prod. Posting Group";
                        if TempAdvancePostingBufferCZZ1.Find() then begin
                            TempAdvancePostingBufferCZZ1.Amount += PurchaseLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" += PurchaseLine.Amount;
                            TempAdvancePostingBufferCZZ1.Modify();
                        end else begin
                            TempAdvancePostingBufferCZZ1."VAT Calculation Type" := PurchaseLine."VAT Calculation Type";
                            TempAdvancePostingBufferCZZ1."VAT %" := PurchaseLine."VAT %";
                            TempAdvancePostingBufferCZZ1.Amount := PurchaseLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" := PurchaseLine.Amount;
                            TempAdvancePostingBufferCZZ1.Insert();
                        end;
                    until PurchaseLine.Next() = 0
                else
                    repeat
                        TempAdvancePostingBufferCZZ1.Init();
                        TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group" := PurchInvLine."VAT Bus. Posting Group";
                        TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group" := PurchInvLine."VAT Prod. Posting Group";
                        if TempAdvancePostingBufferCZZ1.Find() then begin
                            TempAdvancePostingBufferCZZ1.Amount += PurchInvLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" += PurchInvLine.Amount;
                            TempAdvancePostingBufferCZZ1.Modify();
                        end else begin
                            TempAdvancePostingBufferCZZ1."VAT Calculation Type" := PurchInvLine."VAT Calculation Type";
                            TempAdvancePostingBufferCZZ1."VAT %" := PurchInvLine."VAT %";
                            TempAdvancePostingBufferCZZ1.Amount := PurchInvLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" := PurchInvLine.Amount;
                            TempAdvancePostingBufferCZZ1.Insert();
                        end;
                    until PurchInvLine.Next() = 0;

                GetCurrency(PurchAdvLetterEntryCZZ."Currency Code");

                for i := 1 to 3 do begin
                    TempAdvancePostingBufferCZZ1.FindSet();
                    repeat
                        case i of
                            1:
                                begin
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT Bus. Posting Group", TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group");
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT Prod. Posting Group", TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group");
                                end;
                            2:
                                begin
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT Calculation Type", TempAdvancePostingBufferCZZ1."VAT Calculation Type");
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT %", TempAdvancePostingBufferCZZ1."VAT %");
                                end;
                        end;
                        TempAdvancePostingBufferCZZ2.SetFilter(Amount, '<>%1', 0);
                        if TempAdvancePostingBufferCZZ2.FindSet() then
                            repeat
                                UseAmount := TempAdvancePostingBufferCZZ1.Amount;
                                UseBaseAmount := TempAdvancePostingBufferCZZ1."VAT Base Amount";
                                if Abs(TempAdvancePostingBufferCZZ2.Amount) < Abs(UseAmount) then begin
                                    UseAmount := TempAdvancePostingBufferCZZ2.Amount;
                                    UseBaseAmount := TempAdvancePostingBufferCZZ2."VAT Base Amount";
                                end;
                                if Abs(UsedAmount) < Abs(UseAmount) then begin
                                    UseAmount := UsedAmount;
                                    UseBaseAmount :=
                                        Round(TempAdvancePostingBufferCZZ2."VAT Base Amount" * UseAmount /
                                            TempAdvancePostingBufferCZZ2.Amount,
                                            CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                                end;
                                if TempAdvancePostingBufferCZZ1."VAT %" <> TempAdvancePostingBufferCZZ2."VAT %" then
                                    UseBaseAmount :=
                                        Round(TempAdvancePostingBufferCZZ2."VAT Base Amount" * UseAmount /
                                            TempAdvancePostingBufferCZZ2.Amount,
                                            CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());

                                TempAdvancePostingBufferCZZ2.Amount -= UseAmount;
                                TempAdvancePostingBufferCZZ2."VAT Base Amount" -= UseBaseAmount;
                                TempAdvancePostingBufferCZZ2.Modify();
                                TempAdvancePostingBufferCZZ1.Amount -= UseAmount;
                                TempAdvancePostingBufferCZZ1."VAT Base Amount" -= UseBaseAmount;
                                TempAdvancePostingBufferCZZ1.Modify();
                                UsedAmount -= UseAmount;
                            until (TempAdvancePostingBufferCZZ2.Next() = 0) or (UsedAmount = 0);
                        TempAdvancePostingBufferCZZ2.Reset();
                    until TempAdvancePostingBufferCZZ1.Next() = 0;
                end;

                if AdvancePostingBufferCZZ.FindSet() then
                    repeat
                        TempAdvancePostingBufferCZZ2.Get(
                            AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");
                        case true of
                            TempAdvancePostingBufferCZZ2.Amount = 0:
                                ;
                            TempAdvancePostingBufferCZZ2.Amount <> AdvancePostingBufferCZZ.Amount:
                                begin
                                    AdvancePostingBufferCZZ.Amount :=
                                        AdvancePostingBufferCZZ.Amount - TempAdvancePostingBufferCZZ2.Amount;
                                    AdvancePostingBufferCZZ."VAT Base Amount" :=
                                        AdvancePostingBufferCZZ."VAT Base Amount" - TempAdvancePostingBufferCZZ2."VAT Base Amount";
                                    AdvancePostingBufferCZZ."VAT Amount" :=
                                        AdvancePostingBufferCZZ.Amount - AdvancePostingBufferCZZ."VAT Base Amount";
                                    AdvancePostingBufferCZZ.Modify();
                                end;
                            TempAdvancePostingBufferCZZ2.Amount = AdvancePostingBufferCZZ.Amount:
                                begin
                                    AdvancePostingBufferCZZ.Amount := 0;
                                    AdvancePostingBufferCZZ."VAT Base Amount" := 0;
                                    AdvancePostingBufferCZZ."VAT Amount" := 0;
                                    AdvancePostingBufferCZZ.Modify();
                                end;
                        end;
                    until AdvancePostingBufferCZZ.Next() = 0;
            end else begin
                AdvancePostingBufferCZZ.FindSet();
                repeat
                    AdvancePostingBufferCZZ.Amount :=
                        Round(AdvancePostingBufferCZZ.Amount * UsedAmount / TotalAmount,
                            CurrencyGlob."Amount Rounding Precision");
                    AdvancePostingBufferCZZ."VAT Amount" :=
                        Round(AdvancePostingBufferCZZ."VAT Amount" * UsedAmount / TotalAmount,
                            CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                    AdvancePostingBufferCZZ."VAT Base Amount" :=
                        AdvancePostingBufferCZZ.Amount - AdvancePostingBufferCZZ."VAT Amount";
                    AdvancePostingBufferCZZ.Modify();
                until AdvancePostingBufferCZZ.Next() = 0;
            end;
        end;

        if AdvancePostingBufferCZZ.FindSet() then
            repeat
                AdvancePostingBufferCZZ.UpdateLCYAmounts(PurchAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
                AdvancePostingBufferCZZ.Modify();
            until AdvancePostingBufferCZZ.Next() = 0;
    end;

    local procedure UnapplyVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        DetailedVendorLedgEntry1: Record "Detailed Vendor Ledg. Entry";
        DetailedVendorLedgEntry2: Record "Detailed Vendor Ledg. Entry";
        DetailedVendorLedgEntry3: Record "Detailed Vendor Ledg. Entry";
        GenJournalLine: Record "Gen. Journal Line";
        Succes: Boolean;
    begin
        DetailedVendorLedgEntry1.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type");
        DetailedVendorLedgEntry1.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
        DetailedVendorLedgEntry1.SetRange("Entry Type", DetailedVendorLedgEntry1."Entry Type"::Application);
        DetailedVendorLedgEntry1.SetRange(Unapplied, false);
        Succes := false;
        repeat
            if DetailedVendorLedgEntry1.FindLast() then begin
                DetailedVendorLedgEntry2.Reset();
                DetailedVendorLedgEntry2.SetCurrentKey("Transaction No.", "Vendor No.", "Entry Type");
                DetailedVendorLedgEntry2.SetRange("Transaction No.", DetailedVendorLedgEntry1."Transaction No.");
                DetailedVendorLedgEntry2.SetRange("Vendor No.", DetailedVendorLedgEntry1."Vendor No.");
                if DetailedVendorLedgEntry2.FindSet() then
                    repeat
                        if (DetailedVendorLedgEntry2."Entry Type" <> DetailedVendorLedgEntry2."Entry Type"::"Initial Entry") and
                           not DetailedVendorLedgEntry2.Unapplied
                        then begin
                            DetailedVendorLedgEntry3.Reset();
                            DetailedVendorLedgEntry3.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type");
                            DetailedVendorLedgEntry3.SetRange("Vendor Ledger Entry No.", DetailedVendorLedgEntry2."Vendor Ledger Entry No.");
                            DetailedVendorLedgEntry3.SetRange(Unapplied, false);
                            if DetailedVendorLedgEntry3.FindLast() and
                               (DetailedVendorLedgEntry3."Transaction No." > DetailedVendorLedgEntry2."Transaction No.")
                            then
                                Error(UnapplyLastInvoicesErr);
                        end;
                    until DetailedVendorLedgEntry2.Next() = 0;

                GenJournalLine.Init();
                GenJournalLine."Document No." := DetailedVendorLedgEntry1."Document No.";
                GenJournalLine."Posting Date" := DetailedVendorLedgEntry1."Posting Date";
                GenJournalLine.Validate("VAT Reporting Date", VendorLedgerEntry."VAT Date CZL");
                GenJournalLine.Validate("Original Doc. VAT Date CZL", VendorLedgerEntry."VAT Date CZL");
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                GenJournalLine."Account No." := DetailedVendorLedgEntry1."Vendor No.";
                GenJournalLine.Correction := true;
                GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
                GenJournalLine.Description := VendorLedgerEntry.Description;
                GenJournalLine."Shortcut Dimension 1 Code" := VendorLedgerEntry."Global Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := VendorLedgerEntry."Global Dimension 2 Code";
                GenJournalLine."Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
                GenJournalLine."Posting Group" := VendorLedgerEntry."Vendor Posting Group";
                GenJournalLine."Source Currency Code" := DetailedVendorLedgEntry1."Currency Code";
                GenJournalLine."System-Created Entry" := true;
                OnUnapplyVendLedgEntryOnBeforeUnapplyVendLedgEntry(VendorLedgerEntry, DetailedVendorLedgEntry1, GenJournalLine);
#if not CLEAN25
#pragma warning disable AL0432
                OnUnapplyVendLedgEntryOnBeforePostUnapplyVendLedgEntry(VendorLedgerEntry, DetailedVendorLedgEntry1, GenJournalLine);
#pragma warning restore AL0432
#endif
                GenJnlPostLine.UnapplyVendLedgEntry(GenJournalLine, DetailedVendorLedgEntry1);
            end else
                Succes := true;
        until Succes;
    end;

    local procedure InitGenJournalLine(
        var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.InitNewLineCZZ(
            AdvancePostingParametersCZZ."Posting Date", AdvancePostingParametersCZZ."Document Date",
            AdvancePostingParametersCZZ."VAT Date", AdvancePostingParametersCZZ."Original Document VAT Date",
            AdvancePostingParametersCZZ."Posting Description");
        GenJournalLine.CopyDocumentFields(
            AdvancePostingParametersCZZ."Document Type", AdvancePostingParametersCZZ."Document No.",
            AdvancePostingParametersCZZ."External Document No.", AdvancePostingParametersCZZ."Source Code", '');
        GenJournalLine.CopyFromPurchAdvLetterHeaderCZZ(PurchAdvLetterHeaderCZZ);
        GenJournalLine.CopyFromPurchAdvLetterEntryCZZ(PurchAdvLetterEntryCZZ);
        GenJournalLine.SetCurrencyFactor(
            AdvancePostingParametersCZZ."Currency Code", AdvancePostingParametersCZZ."Currency Factor");
        OnAfterInitGenJournalLine(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
    end;

    local procedure InitGenJournalLine(
        var VendorLedgerEntry: Record "Vendor Ledger Entry";
        var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.InitNewLineCZZ(VendorLedgerEntry);
        GenJournalLine.CopyFromVendorLedgerEntryCZZ(VendorLedgerEntry);
        OnAfterInitGenJournalLineFromVendorLedgerEntry(VendorLedgerEntry, GenJournalLine);
    end;

    local procedure RunGenJnlPostLine(
        var GenJnlLine: Record "Gen. Journal Line";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        UseAdvLetterVATAccounts: Boolean;
        UseEmptyDocumentType: Boolean;
        ActivateGenJnlCheckLnHandler: Boolean) GLEntryNo: Integer
    var
        DocumentTypeHandlerCZZ: Codeunit "Document Type Handler CZZ";
        GenJnlCheckLnHandlerCZZ: Codeunit "Gen.Jnl.-Check Ln. Handler CZZ";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRunGenJnlPostLine(GenJnlLine, GenJnlPostLine, GLEntryNo, IsHandled);
        if IsHandled then
            exit;

        if UseAdvLetterVATAccounts then
            BindSubscription(VATPostingSetupHandlerCZZ);
        if UseEmptyDocumentType then
            BindSubscription(DocumentTypeHandlerCZZ);
        if ActivateGenJnlCheckLnHandler then
            BindSubscription(GenJnlCheckLnHandlerCZZ);
        GLEntryNo := GenJnlPostLine.RunWithCheck(GenJnlLine);
        if UseAdvLetterVATAccounts then
            UnbindSubscription(VATPostingSetupHandlerCZZ);
        if UseEmptyDocumentType then
            UnbindSubscription(DocumentTypeHandlerCZZ);
        if ActivateGenJnlCheckLnHandler then
            UnbindSubscription(GenJnlCheckLnHandlerCZZ);
        OnAfterRunGenJnlPostLine(GenJnlLine, GenJnlPostLine, GLEntryNo);
    end;

    local procedure GetCurrency(CurrencyCode: Code[10])
    begin
        CurrencyGlob.Initialize(CurrencyCode, true);
    end;

    local procedure InitVendorLedgerEntryFromPurchInvHeader(PurchInvHeader: Record "Purch. Inv. Header"; var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        VendorLedgerEntry.Init();
        VendorLedgerEntry."Vendor No." := PurchInvHeader."Pay-to Vendor No.";
        VendorLedgerEntry."Posting Date" := PurchInvHeader."Posting Date";
        VendorLedgerEntry."Document Date" := PurchInvHeader."Document Date";
        VendorLedgerEntry."Document Type" := VendorLedgerEntry."Document Type"::Invoice;
        VendorLedgerEntry."Document No." := PurchInvHeader."No.";
        VendorLedgerEntry."External Document No." := PurchInvHeader."Vendor Order No.";
        VendorLedgerEntry.Description := PurchInvHeader."Posting Description";
        VendorLedgerEntry."Currency Code" := PurchInvHeader."Currency Code";
        VendorLedgerEntry."Buy-from Vendor No." := PurchInvHeader."Buy-from Vendor No.";
        VendorLedgerEntry."Vendor Posting Group" := PurchInvHeader."Vendor Posting Group";
        VendorLedgerEntry."Global Dimension 1 Code" := PurchInvHeader."Shortcut Dimension 1 Code";
        VendorLedgerEntry."Global Dimension 2 Code" := PurchInvHeader."Shortcut Dimension 2 Code";
        VendorLedgerEntry."Dimension Set ID" := PurchInvHeader."Dimension Set ID";
        VendorLedgerEntry."Purchaser Code" := PurchInvHeader."Purchaser Code";
        VendorLedgerEntry."Due Date" := PurchInvHeader."Due Date";
        VendorLedgerEntry."Payment Method Code" := PurchInvHeader."Payment Method Code";
        VendorLedgerEntry."VAT Date CZL" := PurchInvHeader."VAT Reporting Date";
        VendorLedgerEntry."Original Currency Factor" := PurchInvHeader."Currency Factor";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePayment(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PostedGenJournalLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePayment(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry"; PostedGenJournalLine: Record "Gen. Journal Line"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePaymentUnlinking(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentUnlinking(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUnlinkingOnBeforePostAdvancePaymentApplication(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUnlinkingOnAfterPostAdvancePaymentApplication(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUnlinkingOnBeforePostPaymentApplication(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUnlinkingOnAfterPostPaymentApplication(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentOnBeforePostPaymentApplication(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentOnAfterPostPaymentApplication(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentOnBeforePostAdvancePayment(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentOnAfterPostAdvancePayment(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATOnBeforePost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATOnAfterPost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATOnBeforePostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATOnAfterPostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentVAT(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePaymentVATUnlinking(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentVATUnlinking(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATUnlinkingOnBeforePost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATUnlinkingOnAfterPost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATUnlinkingOnBeforePostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATUnlinkingOnAfterPostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GLEntryNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePaymentUsage(var PurchInvHeader: Record "Purch. Inv. Header"; var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentUsage(PurchInvHeader: Record "Purch. Inv. Header"; var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUsageOnAfterSetPurchAdvLetterEntryFilter(AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePaymentUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePaymentUsageVATCancellation(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentUsageVATCancellation(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUsageVATCancellationOnBeforePost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUsageVATCancellationOnAfterPost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUsageVATCancellationOnBeforePostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUsageVATCancellationOnAfterPostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceCreditMemoVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceCreditMemoVAT(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceCreditMemoVATOnBeforePost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceCreditMemoVATOnAfterPost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceCreditMemoVATOnBeforePostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceCreditMemoVATOnAfterPostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterApplying(var PurchInvHeader: Record "Purch. Inv. Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterApplying(PurchInvHeader: Record "Purch. Inv. Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterUnapplying(var PurchInvHeader: Record "Purch. Inv. Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterUnapplying(PurchInvHeader: Record "Purch. Inv. Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterEntryVATUsageUnapplying(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterEntryVATUsageUnapplying(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryVATUsageUnapplyingOnBeforePost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryVATUsageUnapplyingOnAfterPost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryVATUsageUnapplyingOnBeforePostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryVATUsageUnapplyingOnAfterPostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterEntryUsageUnapplying(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterEntryUsageUnapplying(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryUsageUnapplyingOnBeforePostAdvancePaymentApplication(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryUsageUnapplyingOnAfterPostAdvancePaymentApplication(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryUsageUnapplyingOnBeforePostInvoiceApplication(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryUsageUnapplyingOnAfterPostInvoiceApplication(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterClosing(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterClosing(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterEntryClosing(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterEntryClosing(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryClosingOnBeforePost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryClosingOnAfterPost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryClosingOnBeforePostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryClosingOnAfterPostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReverseAdvancePayment(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PurchInvHeader: Record "Purch. Inv. Header"; var ReverseAmount: Decimal; var ReverseAmountLCY: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReverseAdvancePayment(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PurchInvHeader: Record "Purch. Inv. Header"; CreatedEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentOnBeforePostInvoiceApplication(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentOnAfterPostInvoiceApplication(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentOnBeforePostAdvancePaymentUsage(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentOnAfterPostAdvancePaymentUsage(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReverseAdvancePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var RelatedEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReverseAdvancePaymentVAT(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentVATOnBeforePost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentVATOnAfterPost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentVATOnBeforePostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentVATOnAfterPostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateVATAmountInBuffer(var PostingDate: Date; var CurrencyCode: Code[10]; var CurrencyFactor: Decimal; var TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReverseUnrealizedExchangeRate(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var Coef: Decimal; var RelatedEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostExchangeRate(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; ExchRateAmount: Decimal; ExchRateVATAmount: Decimal; UsageEntryNo: Integer; Correction: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostExchangeRate(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; TempPurchAdvLetterEntryCZZGlob: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnBeforePostVATBase(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnAfterPostVATBase(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnBeforePostVATAmount(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnAfterPostVATAmount(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnBeforePostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnAfterPostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostUnrealizedExchangeRate(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var Amount: Decimal; var VATAmount: Decimal; var RelatedEntryNo: Integer; var RelatedDetEntryNo: Integer; var Correction: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostUnrealizedExchangeRate(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; TempPurchAdvLetterEntryCZZGlob: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostNonDeductibleVAT(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostNonDeductibleVATOnBeforePost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostNonDeductibleVATOnAfterPost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostNonDeductibleVATOnBeforePostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostNonDeductibleVATOnAfterPostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostNonDeductibleVAT(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUnrealizedExchangeRateOnBeforePost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUnrealizedExchangeRateOnAfterPost(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUnrealizedExchangeRateOnBeforePostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUnrealizedExchangeRateOnAfterPostBalance(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnBeforeInsertEntry(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var TempPurchAdvLetterEntryCZZGlob: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUnrealizedExchangeRateOnBeforeInsertEntry(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var TempPurchAdvLetterEntryCZZGlob: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GLEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitGenJournalLine(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitGenJournalLineFromVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
#if not CLEAN25
    [Obsolete('Replaced by OnUnapplyVendLedgEntryOnBeforeUnapplyVendLedgEntry event.', '25.0')]
    [IntegrationEvent(false, false)]
    local procedure OnUnapplyVendLedgEntryOnBeforePostUnapplyVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; DetailedVendorLedgEntry1: Record "Detailed Vendor Ledg. Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnUnapplyVendLedgEntryOnBeforeUnapplyVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterClosingOnAfterSetPurchAdvLetterEntryFilter(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;
}