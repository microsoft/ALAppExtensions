// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;

codeunit 31143 "Sales Adv. Letter-Post CZZ"
{
    Permissions = tabledata "Sales Adv. Letter Entry CZZ" = im;

    var
        CurrencyGlob: Record Currency;
        TempSalesAdvLetterEntryCZZGlob: Record "Sales Adv. Letter Entry CZZ" temporary;
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
        ExceededAmountErr: Label 'Amount has been exceeded.';
        ExceededAmountToPayErr: Label 'The amount cannot be higher than to pay on advance letter.';
        ExceededRemainingAmountErr: Label 'The amount cannot be higher than remaining amount on ledger entry.';
        NothingToPostErr: Label 'Nothing to Post.';
        ReverseAmountErr: Label 'Reverse amount %1 is not posible on entry %2.', Comment = '%1 = Reverse Amount, %2 = Sales Advance Entry No.';
        TemporaryRecordErr: Label 'The record of "Sales Adv. Letter Entry CZZ" must be temporary.';
        UnlinkIsNotPossibleErr: Label 'Unlink is not possible, because %1 entry exists.', Comment = '%1 = Entry type';
        UnapplyIsNotPossibleErr: Label 'Unapply is not possible.';
        UnapplyLastInvoicesErr: Label 'First you must unapply invoces that were applied to advance last time.';

    procedure PostAdvancePayment(
        var CustLedgerEntry: Record "Cust. Ledger Entry";
        PostedGenJournalLine: Record "Gen. Journal Line";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ") EntryNo: Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        CustLedgerEntryPayment: Record "Cust. Ledger Entry";
        Amount, AmountLCY : Decimal;
        GLEntryNo: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePayment(CustLedgerEntry, PostedGenJournalLine, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        CustLedgerEntry.TestField("Advance Letter No. CZZ", '');
        SalesAdvLetterHeaderCZZ.Get(PostedGenJournalLine."Advance Letter No. CZZ");
        SalesAdvLetterHeaderCZZ.CheckSalesAdvanceLetterPostRestrictions();
        SalesAdvLetterHeaderCZZ.TestField("Currency Code", CustLedgerEntry."Currency Code");
        SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.", CustLedgerEntry."Customer No.");

        CustLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
        if AdvancePostingParametersCZZ."Amount to Link" = 0 then begin
            Amount := CustLedgerEntry."Remaining Amount";
            AmountLCY := CustLedgerEntry."Remaining Amt. (LCY)";
        end else begin
            if AdvancePostingParametersCZZ."Amount to Link" > -CustLedgerEntry."Remaining Amount" then
                Error(ExceededRemainingAmountErr);

            Amount := -AdvancePostingParametersCZZ."Amount to Link";
            AmountLCY := Round(Amount / CustLedgerEntry."Original Currency Factor");
        end;

        SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
        if -Amount > SalesAdvLetterHeaderCZZ."To Pay" then
            Error(ExceededAmountToPayErr);

        // Post payment application
        InitGenJournalLine(CustLedgerEntry, GenJournalLine);
        GenJournalLine."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine.Amount := -Amount;
        GenJournalLine."Amount (LCY)" := -AmountLCY;
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            CustLedgerEntry.SetApplication(SalesAdvLetterHeaderCZZ."Advance Letter Code", '');
            GenJournalLine."Applies-to ID" := CustLedgerEntry."Applies-to ID";
            OnPostAdvancePaymentOnBeforePostPaymentApplication(
                SalesAdvLetterHeaderCZZ, PostedGenJournalLine, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvancePaymentOnAfterPostPaymentApplication(SalesAdvLetterHeaderCZZ, PostedGenJournalLine,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        // Post advance payment
        InitGenJournalLine(CustLedgerEntry, GenJournalLine);
        GenJournalLine."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := SalesAdvLetterHeaderCZZ."No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.Amount := Amount;
        GenJournalLine."Amount (LCY)" := AmountLCY;
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            OnPostAdvancePaymentOnBeforePostAdvancePayment(SalesAdvLetterHeaderCZZ, PostedGenJournalLine, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvancePaymentOnAfterPostAdvancePayment(SalesAdvLetterHeaderCZZ, PostedGenJournalLine,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        CustLedgerEntryPayment.FindLast();

        TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
        TempSalesAdvLetterEntryCZZGlob.InitCustLedgerEntry(CustLedgerEntryPayment);
        TempSalesAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
        TempSalesAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::Payment;
        EntryNo := TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        if not AdvancePostingParametersCZZ."Temporary Entries Only" then
            SalesAdvLetterHeaderCZZ.UpdateStatus(SalesAdvLetterHeaderCZZ.Status::"To Use");

        OnAfterPostAdvancePayment(SalesAdvLetterHeaderCZZ, CustLedgerEntry, PostedGenJournalLine, EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvancePaymentUnlinking(
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntryAdv: Record "Cust. Ledger Entry";
        CustLedgerEntryPay: Record "Cust. Ledger Entry";
        GLEntryNo: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePaymentUnlinking(SalesAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        SalesAdvLetterEntryCZZ.TestField("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetFilter("Entry Type", '<>%1', SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if SalesAdvLetterEntryCZZ2.FindFirst() then
            Error(UnlinkIsNotPossibleErr, SalesAdvLetterEntryCZZ2."Entry Type");

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");

        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if SalesAdvLetterEntryCZZ2.FindSet() then
            repeat
                Clear(AdvancePostingBufferCZZ);
                AdvancePostingBufferCZZ.PrepareForSalesAdvLetterEntry(SalesAdvLetterEntryCZZ2);
                Clear(AdvancePostingParametersCZZ2);
                AdvancePostingParametersCZZ2.CopyFromSalesAdvLetterEntry(SalesAdvLetterEntryCZZ2);
                AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::Invoice;
                PostAdvancePaymentVATUnlinking(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ2, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ2);
            until SalesAdvLetterEntryCZZ2.Next() = 0;

        CustLedgerEntryAdv.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
        CustLedgerEntryPay := CustLedgerEntryAdv;
#pragma warning disable AA0181
        CustLedgerEntryPay.Next(-1);
#pragma warning restore AA0181
        UnapplyCustLedgEntry(CustLedgerEntryPay, GenJnlPostLine);

        // Post advance payment application
        InitGenJournalLine(CustLedgerEntryAdv, GenJournalLine);
        GenJournalLine."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := SalesAdvLetterHeaderCZZ."No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.Correction := true;
        GenJournalLine.SetCurrencyFactor(
            SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := -SalesAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := -SalesAdvLetterEntryCZZ."Amount (LCY)";
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            CustLedgerEntryAdv.SetApplication('', SalesAdvLetterHeaderCZZ."No.");
            GenJournalLine."Applies-to ID" := CustLedgerEntryAdv."Applies-to ID";
            OnPostAdvancePaymentUnlinkingOnBeforePostAdvancePaymentApplication(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvancePaymentUnlinkingOnAfterPostAdvancePaymentApplication(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        CustLedgerEntry.FindLast();

        TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
        TempSalesAdvLetterEntryCZZGlob.InitCustLedgerEntry(CustLedgerEntry);
        TempSalesAdvLetterEntryCZZGlob.InitRelatedEntry(SalesAdvLetterEntryCZZ);
        TempSalesAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
        TempSalesAdvLetterEntryCZZGlob."Entry Type" := SalesAdvLetterEntryCZZ."Entry Type";
        TempSalesAdvLetterEntryCZZGlob.Cancelled := true;
        TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        // Post payment application balance
        InitGenJournalLine(CustLedgerEntryAdv, GenJournalLine);
        GenJournalLine."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.SetCurrencyFactor(
            SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := SalesAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := SalesAdvLetterEntryCZZ."Amount (LCY)";
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            CustLedgerEntryPay.SetApplication('', '');
            GenJournalLine."Applies-to ID" := CustLedgerEntryPay."Applies-to ID";
            OnPostAdvancePaymentUnlinkingOnBeforePostPaymentApplication(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvancePaymentUnlinkingOnAfterPostPaymentApplication(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);

            SalesAdvLetterEntryCZZ.Cancelled := true;
            SalesAdvLetterEntryCZZ.Modify();

            SalesAdvLetterHeaderCZZ.UpdateStatus(SalesAdvLetterHeaderCZZ.Status::"To Pay");
        end;

        OnAfterPostAdvancePaymentUnlinking(SalesAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvancePaymentVAT(
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        GLEntryNo, VATEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePaymentVAT(SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);

        AdvancePostingParametersCZZ.CheckSalesDates();
        AdvancePostingParametersCZZ.CheckDocumentNo();

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        if SalesAdvLetterHeaderCZZ."Amount Including VAT" = 0 then
            exit;

        AdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
        if AdvancePostingBufferCZZ.IsEmpty() then
            Error(NothingToPostErr);

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ2.CalcSums(Amount);
        AdvancePostingBufferCZZ.CalcSums(Amount);
        if Abs(SalesAdvLetterEntryCZZ.Amount - SalesAdvLetterEntryCZZ2.Amount) < Abs(AdvancePostingBufferCZZ.Amount) then
            Error(ExceededAmountErr);

        if AdvancePostingParametersCZZ."Source Code" = '' then begin
            CustLedgerEntry.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
            AdvancePostingParametersCZZ."Source Code" := CustLedgerEntry."Source Code";
        end;

        if AdvancePostingBufferCZZ.FindSet() then
            repeat
                GLEntryNo := 0;
                VATEntryNo := 0;

                VATPostingSetup.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");

                // Post VAT amount and VAT base of VAT document
                InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
                GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
                GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
                GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
                if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                    OnPostAdvancePaymentVATOnBeforePost(
                        SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                        AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                    GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
                    VATEntryNo := GenJnlPostLine.GetNextVATEntryNo() - 1;
                    OnPostAdvancePaymentVATOnAfterPost(
                        SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                        AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
                end;

                TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
                TempSalesAdvLetterEntryCZZGlob.InitRelatedEntry(SalesAdvLetterEntryCZZ);
                TempSalesAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
                TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
                TempSalesAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::"VAT Payment";
                TempSalesAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
                TempSalesAdvLetterEntryCZZGlob."VAT Identifier" := VATPostingSetup."VAT Identifier";
                TempSalesAdvLetterEntryCZZGlob."Auxiliary Entry" := AdvancePostingBufferCZZ."Auxiliary Entry";
                TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

                // Post balance of VAT document
                AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
                AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
                InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ2, GenJournalLine);
                GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
                AdvancePostingBufferCZZ.ReverseAmounts();
                GenJournalLine.CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
                if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                    OnPostAdvancePaymentVATOnBeforePostBalance(
                        SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                        AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                    GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                    OnPostAdvancePaymentVATOnAfterPostBalance(
                        SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                        AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
                end;
            until AdvancePostingBufferCZZ.Next() = 0;

        OnAfterPostAdvancePaymentVAT(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure PostAdvancePaymentVATUnlinking(
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
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
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        SalesAdvLetterEntryCZZ.TestField("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);

        VATPostingSetup.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");

        GLEntryNo := 0;
        VATEntryNo := 0;

        // Post advance payment VAT unlinking
        InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
        GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
        AdvancePostingBufferCZZ.ReverseAmounts();
        GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
        if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
            OnPostAdvancePaymentVATUnlinkingOnBeforePost(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
            VATEntryNo := GenJnlPostLine.GetNextVATEntryNo() - 1;
            OnPostAdvancePaymentVATUnlinkingOnAfterPost(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
        TempSalesAdvLetterEntryCZZGlob.InitRelatedEntry(SalesAdvLetterEntryCZZ."Related Entry");
        TempSalesAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
        TempSalesAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::"VAT Payment";
        TempSalesAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
        TempSalesAdvLetterEntryCZZGlob."VAT Identifier" := VATPostingSetup."VAT Identifier";
        TempSalesAdvLetterEntryCZZGlob."Auxiliary Entry" := AdvancePostingBufferCZZ."Auxiliary Entry";
        TempSalesAdvLetterEntryCZZGlob.Cancelled := true;
        EntryNo := TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        // Post balance of advance payment VAT unlinking
        AdvancePostingBufferCZZ.ReverseAmounts();
        AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
        InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ2, GenJournalLine);
        GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
        GenJournalLine.CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
        if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
            OnPostAdvancePaymentVATUnlinkingOnBeforePostBalance(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvancePaymentVATUnlinkingOnAfterPostBalance(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);

            SalesAdvLetterEntryCZZ.Cancelled := true;
            SalesAdvLetterEntryCZZ.Modify(true);
        end;

        OnAfterPostAdvancePaymentVATUnlinking(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvancePaymentUsage(
        var SalesInvoiceHeader: Record "Sales Invoice Header";
        var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParameters: Record "Advance Posting Parameters CZZ")
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        AmountToUse, UseAmount, UseAmountLCY : Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePaymentUsage(SalesInvoiceHeader, AdvanceLetterApplicationCZZ, GenJnlPostLine, AdvancePostingParameters, IsHandled);
        if IsHandled then
            exit;

        if SalesInvoiceHeader."Remaining Amount" = 0 then
            SalesInvoiceHeader.CalcFields("Remaining Amount");

        AmountToUse := SalesInvoiceHeader."Remaining Amount";
        if AmountToUse = 0 then
            exit;

        if AdvanceLetterApplicationCZZ.IsEmpty() then
            exit;

        AdvanceLetterApplicationCZZ.FindSet();
        repeat
            SalesAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
            SalesAdvLetterHeaderCZZ.TestField("Currency Code", SalesInvoiceHeader."Currency Code");
            SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.", SalesInvoiceHeader."Bill-to Customer No.");

            SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", AdvanceLetterApplicationCZZ."Advance Letter No.");
            SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
            SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
            SalesAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', SalesInvoiceHeader."Posting Date");
            OnPostAdvancePaymentUsageOnAfterSetSalesAdvLetterEntryFilter(AdvanceLetterApplicationCZZ, SalesAdvLetterEntryCZZ);
            if SalesAdvLetterEntryCZZ.FindSet() then
                repeat
                    TempSalesAdvLetterEntryCZZ.Init();
                    TempSalesAdvLetterEntryCZZ := SalesAdvLetterEntryCZZ;
                    TempSalesAdvLetterEntryCZZ.Amount := SalesAdvLetterEntryCZZ.GetRemainingAmount();
                    TempSalesAdvLetterEntryCZZ."Amount (LCY)" := SalesAdvLetterEntryCZZ.GetRemainingAmountLCY();
                    if TempSalesAdvLetterEntryCZZ.Amount <> 0 then
                        TempSalesAdvLetterEntryCZZ.Insert();
                until SalesAdvLetterEntryCZZ.Next() = 0;

            TempAdvanceLetterApplicationCZZ.Add(AdvanceLetterApplicationCZZ);
        until AdvanceLetterApplicationCZZ.Next() = 0;

        TempSalesAdvLetterEntryCZZ.Reset();
        TempSalesAdvLetterEntryCZZ.SetCurrentKey("Posting Date");
        if TempSalesAdvLetterEntryCZZ.FindSet() then begin
            repeat
                TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", TempSalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                TempAdvanceLetterApplicationCZZ.FindFirst();
                if TempAdvanceLetterApplicationCZZ.Amount < TempSalesAdvLetterEntryCZZ.Amount then
                    TempSalesAdvLetterEntryCZZ.Amount := TempAdvanceLetterApplicationCZZ.Amount;

                if AmountToUse > TempSalesAdvLetterEntryCZZ.Amount then
                    UseAmount := TempSalesAdvLetterEntryCZZ.Amount
                else
                    UseAmount := AmountToUse;

                if UseAmount <> 0 then begin
                    UseAmountLCY := Round(UseAmount / TempSalesAdvLetterEntryCZZ.GetAdjustedCurrencyFactor());
                    ReverseAdvancePayment(TempSalesAdvLetterEntryCZZ, SalesInvoiceHeader, UseAmount, UseAmountLCY, GenJnlPostLine, AdvancePostingParameters);
                    AmountToUse -= UseAmount;
                    TempAdvanceLetterApplicationCZZ.Amount -= UseAmount;
                    TempAdvanceLetterApplicationCZZ."Amount (LCY)" -= UseAmountLCY;
                    TempAdvanceLetterApplicationCZZ.Modify();
                end;
            until (TempSalesAdvLetterEntryCZZ.Next() = 0) or (AmountToUse = 0);

            if not AdvancePostingParameters."Temporary Entries Only" then begin
                TempAdvanceLetterApplicationCZZ.Reset();
                if TempAdvanceLetterApplicationCZZ.FindSet() then
                    repeat
                        TempAdvanceLetterApplicationCZZ.ApplyChanges();
                    until TempAdvanceLetterApplicationCZZ.Next() = 0;
            end;
        end;

        OnAfterPostAdvancePaymentUsage(SalesInvoiceHeader, AdvanceLetterApplicationCZZ, GenJnlPostLine, AdvancePostingParameters);
    end;

    internal procedure PostAdvancePaymentUsageForStatistics(
        var SalesHeader: Record "Sales Header";
        Amount: Decimal;
        AmountLCY: Decimal;
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        if not SalesAdvLetterEntryCZZ.IsTemporary then
            Error(TemporaryRecordErr);

        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.DeleteAll();

        if not TempSalesAdvLetterEntryCZZGlob.IsEmpty() then
            TempSalesAdvLetterEntryCZZGlob.DeleteAll();

        if not SalesHeader.IsAdvanceLetterDocTypeCZZ() then
            exit;

        SalesInvoiceHeader.TransferFields(SalesHeader);
        SalesInvoiceHeader."Remaining Amount" := Amount;

        AdvancePostingParametersCZZ."Temporary Entries Only" := true;
        AdvanceLetterApplicationCZZ.SetRange("Document Type", SalesHeader.GetAdvLetterUsageDocTypeCZZ());
        AdvanceLetterApplicationCZZ.SetRange("Document No.", SalesHeader."No.");
        PostAdvancePaymentUsage(SalesInvoiceHeader, AdvanceLetterApplicationCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);

        if TempSalesAdvLetterEntryCZZGlob.FindSet() then begin
            repeat
                SalesAdvLetterEntryCZZ := TempSalesAdvLetterEntryCZZGlob;
                SalesAdvLetterEntryCZZ.Insert();
            until TempSalesAdvLetterEntryCZZGlob.Next() = 0;

            TempSalesAdvLetterEntryCZZGlob.DeleteAll();
        end;
    end;

    procedure PostAdvancePaymentUsageVAT(
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        RelatedSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvancePaymentUsageVAT(
            SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Usage then
            exit;
        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);

        RelatedSalesAdvLetterEntryCZZ.Get(SalesAdvLetterEntryCZZ."Related Entry");
        if RelatedSalesAdvLetterEntryCZZ."Entry Type" <> RelatedSalesAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        ReverseAdvancePaymentVAT(
            RelatedSalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ, SalesAdvLetterEntryCZZ."Entry No.",
            "Advance Letter Entry Type CZZ"::"VAT Usage", GenJnlPostLine, AdvancePostingParametersCZZ);

        OnAfterPostAdvancePaymentUsageVAT(
            SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvanceCreditMemoVAT(
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        RelatedSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        VATDocumentSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        ExchRateAmount, ExchRateVATAmount : Decimal;
        GLEntryNo, VATEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceCreditMemoVAT(
            SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        SalesAdvLetterEntryCZZ.TestField("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");

        AdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
        if AdvancePostingBufferCZZ.IsEmpty() then
            Error(NothingToPostErr);

        if SalesAdvLetterEntryCZZ."Currency Code" <> '' then begin
            RelatedSalesAdvLetterEntryCZZ.Get(SalesAdvLetterEntryCZZ."Related Entry");
            BufferAdvanceVATLines(RelatedSalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, 0D);
        end;

        AdvancePostingBufferCZZ.FindSet();
        repeat
            GLEntryNo := 0;
            VATEntryNo := 0;

            VATPostingSetup.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");

            // Post credit memo VAT
            InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
            GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
            AdvancePostingBufferCZZ.ReverseAmounts();
            GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                OnPostAdvanceCreditMemoVATOnBeforePost(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
                VATEntryNo := GenJnlPostLine.GetNextVATEntryNo() - 1;
                OnPostAdvanceCreditMemoVATOnAfterPost(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
            TempSalesAdvLetterEntryCZZGlob.InitRelatedEntry(SalesAdvLetterEntryCZZ."Related Entry");
            TempSalesAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
            TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
            TempSalesAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::"VAT Payment";
            TempSalesAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
            TempSalesAdvLetterEntryCZZGlob."VAT Identifier" := VATPostingSetup."VAT Identifier";
            TempSalesAdvLetterEntryCZZGlob."Auxiliary Entry" := AdvancePostingBufferCZZ."Auxiliary Entry";
            TempSalesAdvLetterEntryCZZGlob.Cancelled := true;
            TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

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

                    VATDocumentSalesAdvLetterEntryCZZ.Reset();
                    VATDocumentSalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                    VATDocumentSalesAdvLetterEntryCZZ.SetRange("Document No.", SalesAdvLetterEntryCZZ."Document No.");
                    VATDocumentSalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type");
                    VATDocumentSalesAdvLetterEntryCZZ.SetRange("VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Bus. Posting Group");
                    VATDocumentSalesAdvLetterEntryCZZ.SetRange("VAT Prod. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");
                    VATDocumentSalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    VATDocumentSalesAdvLetterEntryCZZ.CalcSums("Amount (LCY)", "VAT Amount (LCY)");

                    ExchRateAmount := -VATDocumentSalesAdvLetterEntryCZZ."Amount (LCY)" - GenJournalLine."Amount (LCY)";
                    ExchRateVATAmount := -VATDocumentSalesAdvLetterEntryCZZ."VAT Amount (LCY)" - GenJournalLine."VAT Amount (LCY)";
                    if (ExchRateAmount <> 0) or (ExchRateVATAmount <> 0) then
                        PostExchangeRate(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, ExchRateAmount, ExchRateVATAmount,
                                SalesAdvLetterEntryCZZ."Related Entry", true, AdvancePostingBufferCZZ."Auxiliary Entry",
                                GenJnlPostLine, AdvancePostingParametersCZZ2);

                    ReverseUnrealizedExchangeRate(
                        RelatedSalesAdvLetterEntryCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup,
                        AdvancePostingBufferCZZ.Amount / TempAdvancePostingBufferCZZ.Amount,
                        RelatedSalesAdvLetterEntryCZZ."Entry No.", AdvancePostingBufferCZZ."Auxiliary Entry",
                        GenJnlPostLine, AdvancePostingParametersCZZ2);
                end;

            // Post balance of credit memo VAT
            AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
            AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
            InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ2, GenJournalLine);
            GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
            GenJournalLine.CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                OnPostAdvanceCreditMemoVATOnBeforePostBalance(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostAdvanceCreditMemoVATOnAfterPostBalance(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;
        until AdvancePostingBufferCZZ.Next() = 0;

        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            VATDocumentSalesAdvLetterEntryCZZ.Reset();
            VATDocumentSalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            VATDocumentSalesAdvLetterEntryCZZ.SetRange("Document No.", SalesAdvLetterEntryCZZ."Document No.");
            VATDocumentSalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type");
            VATDocumentSalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
            VATDocumentSalesAdvLetterEntryCZZ.ModifyAll(Cancelled, true);
        end;

        OnAfterPostAdvanceCreditMemoVAT(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvanceLetterApplying(
        var SalesInvoiceHeader: Record "Sales Invoice Header";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterApplying(SalesInvoiceHeader, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        AdvanceLetterApplication.SetRange("Document Type", AdvanceLetterApplication."Document Type"::"Posted Sales Invoice");
        AdvanceLetterApplication.SetRange("Document No.", SalesInvoiceHeader."No.");
        if AdvanceLetterApplication.IsEmpty() then
            exit;

        PostAdvancePaymentUsage(SalesInvoiceHeader, AdvanceLetterApplication, GenJnlPostLine, AdvancePostingParametersCZZ);

        OnAfterPostAdvanceLetterApplying(SalesInvoiceHeader, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvanceLetterUnapplying(
        var SalesInvoiceHeader: Record "Sales Invoice Header";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterUnapplying(SalesInvoiceHeader, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        SalesAdvLetterEntryCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if not SalesAdvLetterEntryCZZ.FindLast() then
            exit;

        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ.Find('+');
        SalesAdvLetterEntryCZZ.SetFilter("Entry No.", '..%1', SalesAdvLetterEntryCZZ."Entry No.");
        repeat
            AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
            AdvancePostingParametersCZZ2."Posting Date" := SalesAdvLetterEntryCZZ."Posting Date";
            AdvancePostingParametersCZZ2."VAT Date" := SalesAdvLetterEntryCZZ."VAT Date";
            AdvancePostingParametersCZZ2."Posting Description" := SalesInvoiceHeader."Posting Description";

            SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            case SalesAdvLetterEntryCZZ."Entry Type" of
                SalesAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment":
                    begin
                        VATPostingSetup.Get(SalesAdvLetterEntryCZZ."VAT Bus. Posting Group", SalesAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        PostUnrealizedExchangeRate(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
                            -SalesAdvLetterEntryCZZ."Amount (LCY)", -SalesAdvLetterEntryCZZ."VAT Amount (LCY)",
                            SalesAdvLetterEntryCZZ."Related Entry", 0, true, SalesAdvLetterEntryCZZ."Auxiliary Entry",
                            GenJnlPostLine, AdvancePostingParametersCZZ2);
                    end;
                SalesAdvLetterEntryCZZ."Entry Type"::"VAT Rate":
                    begin
                        AdvancePostingParametersCZZ2."Source Code" := SalesInvoiceHeader."Source Code";

                        VATPostingSetup.Get(SalesAdvLetterEntryCZZ."VAT Bus. Posting Group", SalesAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        PostExchangeRate(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
                            -SalesAdvLetterEntryCZZ."Amount (LCY)", -SalesAdvLetterEntryCZZ."VAT Amount (LCY)",
                            SalesAdvLetterEntryCZZ."Related Entry", true, SalesAdvLetterEntryCZZ."Auxiliary Entry",
                            GenJnlPostLine, AdvancePostingParametersCZZ2);
                    end;
                SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage":
                    begin
                        AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::Invoice;
                        AdvancePostingParametersCZZ2."Source Code" := SalesInvoiceHeader."Source Code";
                        AdvancePostingParametersCZZ2."VAT Date" := SalesInvoiceHeader."VAT Reporting Date";
                        AdvancePostingParametersCZZ2."Currency Code" := SalesAdvLetterEntryCZZ."Currency Code";

                        Clear(AdvancePostingBufferCZZ);
                        AdvancePostingBufferCZZ.PrepareForSalesAdvLetterEntry(SalesAdvLetterEntryCZZ);

                        PostAdvanceLetterEntryVATUsageUnapplying(
                            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ2)
                    end;
                SalesAdvLetterEntryCZZ."Entry Type"::Usage:
                    begin
                        AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);

                        PostAdvanceLetterEntryUsageUnapplying(
                           SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ2);
                    end;
                else
                    Error(UnapplyIsNotPossibleErr);
            end;
        until SalesAdvLetterEntryCZZ.Next(-1) = 0;

        SalesAdvLetterEntryCZZ.ModifyAll(Cancelled, true);

        OnAfterPostAdvanceLetterUnapplying(SalesInvoiceHeader, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure PostAdvanceLetterEntryVATUsageUnapplying(
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        EntryNo, GLEntryNo, VATEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterEntryVATUsageUnapplying(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        GLEntryNo := 0;
        VATEntryNo := 0;

        VATPostingSetup.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");

        InitGenJournalLine(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
        GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
        GenJournalLine.Correction := true;
        AdvancePostingBufferCZZ.ReverseAmounts();
        GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
        if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
            OnPostAdvanceLetterEntryVATUsageUnapplyingOnBeforePost(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
            VATEntryNo := GenJnlPostLine.GetNextVATEntryNo() - 1;
            OnPostAdvanceLetterEntryVATUsageUnapplyingOnAfterPost(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
        TempSalesAdvLetterEntryCZZGlob.InitRelatedEntry(SalesAdvLetterEntryCZZ."Related Entry");
        TempSalesAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
        TempSalesAdvLetterEntryCZZGlob."Entry Type" := SalesAdvLetterEntryCZZ."Entry Type";
        TempSalesAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
        TempSalesAdvLetterEntryCZZGlob."VAT Identifier" := VATPostingSetup."VAT Identifier";
        TempSalesAdvLetterEntryCZZGlob."Auxiliary Entry" := AdvancePostingBufferCZZ."Auxiliary Entry";
        TempSalesAdvLetterEntryCZZGlob.Cancelled := true;
        EntryNo := TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        AdvancePostingBufferCZZ.ReverseAmounts();

        AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
        InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ2, GenJournalLine);
        GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
        GenJournalLine.Correction := true;
        GenJournalLine.CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
        if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
            OnPostAdvanceLetterEntryVATUsageUnapplyingOnBeforePostBalance(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
            OnPostAdvanceLetterEntryVATUsageUnapplyingOnAfterPostBalance(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        OnAfterPostAdvanceLetterEntryVATUsageUnapplying(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ)
    end;

    local procedure PostAdvanceLetterEntryUsageUnapplying(
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntryInv: Record "Cust. Ledger Entry";
        EntryNo, GLEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterEntryUsageUnapplying(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        CustLedgerEntry.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
        CustLedgerEntryInv := CustLedgerEntry;
#pragma warning disable AA0181
        CustLedgerEntryInv.Next(-1);
#pragma warning restore AA0181
        UnapplyCustLedgEntry(CustLedgerEntry, GenJnlPostLine);

        InitGenJournalLine(CustLedgerEntry, GenJournalLine);
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := SalesAdvLetterHeaderCZZ."No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.SetCurrencyFactor(
            SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := -SalesAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := -SalesAdvLetterEntryCZZ."Amount (LCY)";
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            CustLedgerEntry.SetApplication('', '');
            GenJournalLine."Applies-to ID" := CustLedgerEntry."Applies-to ID";
            OnPostAdvanceLetterEntryUsageUnapplyingOnBeforePostAdvancePaymentApplication(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, true);
            OnPostAdvanceLetterEntryUsageUnapplyingOnAfterPostAdvancePaymentApplication(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        CustLedgerEntry.FindLast();

        TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
        TempSalesAdvLetterEntryCZZGlob.InitCustLedgerEntry(CustLedgerEntry);
        TempSalesAdvLetterEntryCZZGlob.InitRelatedEntry(SalesAdvLetterEntryCZZ);
        TempSalesAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
        TempSalesAdvLetterEntryCZZGlob."Entry Type" := SalesAdvLetterEntryCZZ."Entry Type";
        TempSalesAdvLetterEntryCZZGlob.Cancelled := true;
        EntryNo := TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        InitGenJournalLine(CustLedgerEntry, GenJournalLine);
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine.SetCurrencyFactor(
            SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := SalesAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := SalesAdvLetterEntryCZZ."Amount (LCY)";
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            CustLedgerEntryInv."Advance Letter No. CZZ" := '';
            CustLedgerEntryInv.SetApplication('', '');
            GenJournalLine."Applies-to ID" := CustLedgerEntryInv."Applies-to ID";
            OnPostAdvanceLetterEntryUsageUnapplyingOnBeforePostInvoiceApplication(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, true);
            OnPostAdvanceLetterEntryUsageUnapplyingOnAfterPostInvoiceApplication(
                SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        SalesAdvLetterHeaderCZZ.UpdateStatus(SalesAdvLetterHeaderCZZ.Status::"To Use");

        OnAfterPostAdvanceLetterEntryUsageUnapplying(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ,
            EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ)
    end;

    procedure PostAdvanceLetterClosing(
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        NextEntryNo: Integer;
        GetDocNoFromNoSeries: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterClosing(SalesAdvLetterHeaderCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::Closed then
            exit;

        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::New then begin
            SalesAdvLetterHeaderCZZ.UpdateStatus(SalesAdvLetterHeaderCZZ.Status::Closed);
            exit;
        end;

        GetDocNoFromNoSeries := AdvancePostingParametersCZZ."Document No." = '';

        if GetDocNoFromNoSeries then begin
            AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");
            AdvanceLetterTemplateCZZ.TestField("Advance Letter Cr. Memo Nos.");
            AdvancePostingParametersCZZ."Document No." :=
                NoSeriesBatch.GetNextNo(
                    AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos.", AdvancePostingParametersCZZ."Posting Date");
            NextEntryNo := GenJnlPostLine.GetNextEntryNo();
        end;

        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        OnPostAdvanceLetterClosingOnAfterSetSalesAdvLetterEntryFilter(SalesAdvLetterEntryCZZ);
        if SalesAdvLetterEntryCZZ.FindSet() then
            repeat
                PostAdvanceLetterEntryClosing(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
            until SalesAdvLetterEntryCZZ.Next() = 0;

        if GetDocNoFromNoSeries and (NextEntryNo <> GenJnlPostLine.GetNextEntryNo()) then
            NoSeriesBatch.SaveState();

        SalesAdvLetterManagementCZZ.CancelInitEntry(SalesAdvLetterHeaderCZZ, AdvancePostingParametersCZZ."Posting Date", false);
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.UpdateStatus(SalesAdvLetterHeaderCZZ.Status::Closed);

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales);
        AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", SalesAdvLetterHeaderCZZ."No.");
        AdvanceLetterApplicationCZZ.DeleteAll(true);

        OnAfterPostAdvanceLetterClosing(SalesAdvLetterHeaderCZZ, GenJnlPostLine, AdvancePostingParametersCZZ)
    end;

    local procedure PostAdvanceLetterEntryClosing(
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry2: Record "Cust. Ledger Entry";
        RemainingAmount, RemainingAmountLCY : Decimal;
        EntryNo, GLEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAdvanceLetterEntryClosing(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        RemainingAmount := SalesAdvLetterEntryCZZ.GetRemainingAmount();
        RemainingAmountLCY := SalesAdvLetterEntryCZZ.GetRemainingAmountLCY();

        CustLedgerEntry.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
        if RemainingAmount <> 0 then begin
            InitGenJournalLine(CustLedgerEntry, GenJournalLine);
            GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
            GenJournalLine.Correction := true;
            GenJournalLine."Document Type" := AdvancePostingParametersCZZ."Document Type";
            GenJournalLine."Document No." := AdvancePostingParametersCZZ."Document No.";
            GenJournalLine."External Document No." := AdvancePostingParametersCZZ."External Document No.";
            GenJournalLine."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
            GenJournalLine."Document Date" := AdvancePostingParametersCZZ."Document Date";
            GenJournalLine."VAT Reporting Date" := AdvancePostingParametersCZZ."VAT Date";
            GenJournalLine."Original Doc. VAT Date CZL" := AdvancePostingParametersCZZ."Original Document VAT Date";
            GenJournalLine."Adv. Letter No. (Entry) CZZ" := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
            GenJournalLine."Use Advance G/L Account CZZ" := true;
            GenJournalLine.SetCurrencyFactor(
                AdvancePostingParametersCZZ."Currency Code", AdvancePostingParametersCZZ."Currency Factor");
            GenJournalLine.Amount := RemainingAmount;
            GenJournalLine."Amount (LCY)" := Round(RemainingAmount / GenJournalLine."Currency Factor");
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                CustLedgerEntry.SetApplication('', SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                GenJournalLine."Applies-to ID" := CustLedgerEntry."Applies-to ID";
                OnPostAdvanceLetterEntryClosingOnBeforePost(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, CustLedgerEntry,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostAdvanceLetterEntryClosingOnAfterPost(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, CustLedgerEntry,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            CustLedgerEntry2.FindLast();

            TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
            TempSalesAdvLetterEntryCZZGlob.InitCustLedgerEntry(CustLedgerEntry2);
            TempSalesAdvLetterEntryCZZGlob.InitRelatedEntry(SalesAdvLetterEntryCZZ);
            TempSalesAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
            TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
            TempSalesAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::Close;
            TempSalesAdvLetterEntryCZZGlob."Amount (LCY)" := RemainingAmountLCY;
            EntryNo := TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");
        end;

        AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::"Credit Memo";

        BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, 0D);
        SuggestUsageVAT(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, CustLedgerEntry."Document No.",
            0, AdvancePostingParametersCZZ."Currency Factor", AdvancePostingParametersCZZ2."Temporary Entries Only");

        ReverseAdvancePaymentVAT(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, EntryNo,
            "Advance Letter Entry Type CZZ"::"VAT Close", GenJnlPostLine, AdvancePostingParametersCZZ2);

        if RemainingAmount <> 0 then begin
            InitGenJournalLine(CustLedgerEntry, GenJournalLine);
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
            GenJournalLine.Amount := -RemainingAmount;
            GenJournalLine."Amount (LCY)" := -Round(RemainingAmount / GenJournalLine."Currency Factor");
            GenJournalLine."Variable Symbol CZL" := SalesAdvLetterHeaderCZZ."Variable Symbol";
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostAdvanceLetterEntryClosingOnBeforePostBalance(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, CustLedgerEntry,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostAdvanceLetterEntryClosingOnAfterPostBalance(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, CustLedgerEntry,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;
        end;

        OnAfterPostAdvanceLetterEntryClosing(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure ReverseAdvancePayment(
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ReverseAmount: Decimal;
        ReverseAmountLCY: Decimal;
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry2: Record "Cust. Ledger Entry";
        EntryNo, GLEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReverseAdvancePayment(
            SalesAdvLetterEntryCZZ, SalesInvoiceHeader, ReverseAmount, ReverseAmountLCY,
            GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if ReverseAmount <> 0 then begin
            if ReverseAmount > SalesAdvLetterEntryCZZ.Amount then
                Error(ReverseAmountErr, ReverseAmount, SalesAdvLetterEntryCZZ."Entry No.");
        end else begin
            ReverseAmount := SalesAdvLetterEntryCZZ.Amount;
            ReverseAmountLCY := SalesAdvLetterEntryCZZ."Amount (LCY)";
        end;

        if not AdvancePostingParametersCZZ."Temporary Entries Only" then
            CustLedgerEntry.Get(SalesInvoiceHeader."Cust. Ledger Entry No.")
        else
            InitCustLedgerEntryFromSalesInvoiceHeader(SalesInvoiceHeader, CustLedgerEntry);

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");

        // Post invoice application
        InitGenJournalLine(CustLedgerEntry, GenJournalLine);
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine.Amount := -ReverseAmount;
        GenJournalLine."Amount (LCY)" := -ReverseAmountLCY;
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            CustLedgerEntry.SetApplication(SalesAdvLetterHeaderCZZ."Advance Letter Code", '');
            GenJournalLine."Applies-to ID" := CustLedgerEntry."Applies-to ID";

            OnReverseAdvancePaymentOnBeforePostInvoiceApplication(
                SalesAdvLetterHeaderCZZ, CustLedgerEntry, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, true);
            OnReverseAdvancePaymentOnAfterPostInvoiceApplication(SalesAdvLetterHeaderCZZ, CustLedgerEntry,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
        end;

        // Post advance payment usage
        InitGenJournalLine(CustLedgerEntry, GenJournalLine);
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.Amount := ReverseAmount;
        GenJournalLine."Amount (LCY)" := ReverseAmountLCY;

        CustLedgerEntry2.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            CustLedgerEntry2.SetApplication('', SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            GenJournalLine."Applies-to ID" := CustLedgerEntry2."Applies-to ID";

            OnReverseAdvancePaymentOnBeforePostAdvancePaymentUsage(
                SalesAdvLetterHeaderCZZ, CustLedgerEntry, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
            GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, true, true);
            OnReverseAdvancePaymentOnAfterPostAdvancePaymentUsage(SalesAdvLetterHeaderCZZ, CustLedgerEntry,
                AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);

            CustLedgerEntry2.FindLast();
        end;

        TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
        TempSalesAdvLetterEntryCZZGlob.InitCustLedgerEntry(CustLedgerEntry2);
        TempSalesAdvLetterEntryCZZGlob.InitRelatedEntry(SalesAdvLetterEntryCZZ);
        TempSalesAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
        TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
        TempSalesAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::Usage;
        TempSalesAdvLetterEntryCZZGlob."Amount (LCY)" :=
            Round(TempSalesAdvLetterEntryCZZGlob.Amount / SalesAdvLetterEntryCZZ."Currency Factor");
        EntryNo := TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        if SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" then begin
            Clear(AdvancePostingParametersCZZ2);
            AdvancePostingParametersCZZ2.CopyFromCustLedgerEntry(CustLedgerEntry);
            AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::Invoice;
            AdvancePostingParametersCZZ2."Currency Code" := SalesAdvLetterEntryCZZ."Currency Code";
            AdvancePostingParametersCZZ2."Currency Factor" := SalesInvoiceHeader."VAT Currency Factor CZL";
            AdvancePostingParametersCZZ2."Temporary Entries Only" := AdvancePostingParametersCZZ."Temporary Entries Only";

            BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, 0D);
            SuggestUsageVAT(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, CustLedgerEntry."Document No.",
                ReverseAmount, SalesInvoiceHeader."VAT Currency Factor CZL", AdvancePostingParametersCZZ2."Temporary Entries Only");

            ReverseAdvancePaymentVAT(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, EntryNo,
                "Advance Letter Entry Type CZZ"::"VAT Usage", GenJnlPostLine, AdvancePostingParametersCZZ2);
        end;

        if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
            SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            SalesAdvLetterHeaderCZZ.UpdateStatus(SalesAdvLetterHeaderCZZ.Status::Closed);
        end;

        OnAfterReverseAdvancePayment(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ,
            SalesInvoiceHeader, EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure ReverseAdvancePaymentVAT(
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        RelatedEntryNo: Integer;
        EntryType: Enum "Advance Letter Entry Type CZZ";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    var
        AdvancePostingParametersCZZ2: Record "Advance Posting Parameters CZZ";
        VATDocumentSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        CalcVATAmountLCY, CalcAmountLCY, ExchRateAmount, ExchRateVATAmount, AmountToUse : Decimal;
        GLEntryNo, VATEntryNo : Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReverseAdvancePaymentVAT(
            SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ, RelatedEntryNo, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        VATDocumentSalesAdvLetterEntryCZZ.Reset();
        VATDocumentSalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        VATDocumentSalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        VATDocumentSalesAdvLetterEntryCZZ.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        VATDocumentSalesAdvLetterEntryCZZ.SetRange("Entry Type", VATDocumentSalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        if VATDocumentSalesAdvLetterEntryCZZ.IsEmpty() then
            exit;

        AdvancePostingBufferCZZ.FilterGroup(-1);
        AdvancePostingBufferCZZ.SetFilter("VAT Base Amount", '<>0');
        AdvancePostingBufferCZZ.SetFilter("VAT Amount", '<>0');
        AdvancePostingBufferCZZ.FilterGroup(0);
        if AdvancePostingBufferCZZ.IsEmpty() then
            exit;

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");

        if SalesAdvLetterEntryCZZ."Currency Code" <> '' then begin
            BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, 0D);
            TempAdvancePostingBufferCZZ.CalcSums(Amount);
            AmountToUse := TempAdvancePostingBufferCZZ.Amount;
        end;

        AdvancePostingBufferCZZ.FindSet();
        repeat
            GLEntryNo := 0;
            VATEntryNo := 0;

            VATPostingSetup.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");

            // Post reverse advance payment VAT
            InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
            GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
            AdvancePostingBufferCZZ.ReverseAmounts();
            GenJournalLine.CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                OnReverseAdvancePaymentVATOnBeforePost(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
                    AdvancePostingBufferCZZ, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, true, true, false);
                VATEntryNo := GenJnlPostLine.GetNextVATEntryNo() - 1;
                OnReverseAdvancePaymentVATOnAfterPost(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
            TempSalesAdvLetterEntryCZZGlob.InitRelatedEntry(RelatedEntryNo);
            TempSalesAdvLetterEntryCZZGlob.CopyFromGenJnlLine(GenJournalLine);
            TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
            TempSalesAdvLetterEntryCZZGlob."Entry Type" := EntryType;
            TempSalesAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
            TempSalesAdvLetterEntryCZZGlob."VAT Identifier" := VATPostingSetup."VAT Identifier";
            TempSalesAdvLetterEntryCZZGlob."Auxiliary Entry" := AdvancePostingBufferCZZ."Auxiliary Entry";
            TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

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

                    ExchRateAmount := -CalcAmountLCY - GenJournalLine."Amount (LCY)";
                    ExchRateVATAmount := -CalcVATAmountLCY - GenJournalLine."VAT Amount (LCY)";
                    if (ExchRateAmount <> 0) or (ExchRateVATAmount <> 0) then
                        PostExchangeRate(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, ExchRateAmount, ExchRateVATAmount,
                            RelatedEntryNo, false, AdvancePostingBufferCZZ."Auxiliary Entry", GenJnlPostLine, AdvancePostingParametersCZZ2);

                    AdvancePostingParametersCZZ2."Source Code" := '';
                    ReverseUnrealizedExchangeRate(
                        SalesAdvLetterEntryCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup, AdvancePostingBufferCZZ.Amount / AmountToUse,
                        RelatedEntryNo, AdvancePostingBufferCZZ."Auxiliary Entry", GenJnlPostLine, AdvancePostingParametersCZZ2);
                end;

            // Post balance of reverse advance payment VAT
            AdvancePostingParametersCZZ2.InitNew(AdvancePostingParametersCZZ);
            AdvancePostingParametersCZZ2."Document Type" := "Gen. Journal Document Type"::" ";
            InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ2, GenJournalLine);
            GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
            GenJournalLine.CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" and not AdvancePostingBufferCZZ."Auxiliary Entry" then begin
                OnReverseAdvancePaymentVATOnBeforePostBalance(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
                    AdvancePostingBufferCZZ, AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnReverseAdvancePaymentVATOnAfterPostBalance(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, AdvancePostingBufferCZZ,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;
        until AdvancePostingBufferCZZ.Next() = 0;

        if not AdvancePostingParametersCZZ."Temporary Entries Only" then
            SalesAdvLetterHeaderCZZ.UpdateStatus(SalesAdvLetterHeaderCZZ.Status::Closed);

        OnAfterReverseAdvancePaymentVAT(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ,
            AdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure ReverseUnrealizedExchangeRate(
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
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
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Coef,
            RelatedEntryNo, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        SalesAdvLetterManagementCZZ.GetRemAmtLCYVATAdjust(
            AmountLCY, VATAmountLCY, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ."Posting Date",
            VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        if (AmountLCY = 0) and (VATAmountLCY = 0) then
            exit;

        AmountLCY := Round(AmountLCY * Coef);
        VATAmountLCY := Round(VATAmountLCY * Coef);

        PostUnrealizedExchangeRate(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, -AmountLCY, -VATAmountLCY,
            RelatedEntryNo, 0, false, AuxiliaryEntry, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure PostExchangeRate(
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
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
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
            RelatedEntryNo, Correction, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if (Amount = 0) and (VATAmount = 0) then
            exit;

        if VATAmount <> 0 then begin
            GetCurrency(SalesAdvLetterHeaderCZZ."Currency Code");

            // Post exchange rate of VAT Base
            InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine.Correction := Correction;
            GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
            GenJournalLine.Validate(Amount, Amount - VATAmount);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostExchangeRateOnBeforePostVATBase(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostExchangeRateOnAfterPostVATBase(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            // Post exchange rate of VAT Amount
            InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine."Shortcut Dimension 1 Code" := SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code";
            GenJournalLine."Shortcut Dimension 2 Code" := SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code";
            GenJournalLine."Dimension Set ID" := SalesAdvLetterHeaderCZZ."Dimension Set ID";
            GenJournalLine.Correction := true;
            if VATAmount < 0 then
                GenJournalLine."Account No." := CurrencyGlob.GetRealizedLossesAccount()
            else
                GenJournalLine."Account No." := CurrencyGlob.GetRealizedGainsAccount();
            GenJournalLine.Validate(Amount, VATAmount);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostExchangeRateOnBeforePostVATAmount(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostExchangeRateOnAfterPostVATAmount(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            // Post balance of exchange rate
            InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine.Correction := Correction;
            GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
            GenJournalLine.Validate(Amount, -Amount);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostExchangeRateOnBeforePostBalance(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostExchangeRateOnAfterPostBalance(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;
        end;

        TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
        TempSalesAdvLetterEntryCZZGlob.InitRelatedEntry(RelatedEntryNo);
        TempSalesAdvLetterEntryCZZGlob.CopyFromVATPostingSetup(VATPostingSetup);
        TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
        TempSalesAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::"VAT Rate";
        TempSalesAdvLetterEntryCZZGlob."Document No." := AdvancePostingParametersCZZ."Document No.";
        TempSalesAdvLetterEntryCZZGlob."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        TempSalesAdvLetterEntryCZZGlob."VAT Date" := AdvancePostingParametersCZZ."VAT Date";
        TempSalesAdvLetterEntryCZZGlob."Amount (LCY)" := Amount;
        TempSalesAdvLetterEntryCZZGlob."VAT Amount (LCY)" := VATAmount;
        TempSalesAdvLetterEntryCZZGlob."VAT Base Amount (LCY)" := Amount - VATAmount;
        TempSalesAdvLetterEntryCZZGlob."Global Dimension 1 Code" := SalesAdvLetterEntryCZZ."Global Dimension 1 Code";
        TempSalesAdvLetterEntryCZZGlob."Global Dimension 2 Code" := SalesAdvLetterEntryCZZ."Global Dimension 2 Code";
        TempSalesAdvLetterEntryCZZGlob."Dimension Set ID" := SalesAdvLetterEntryCZZ."Dimension Set ID";
        TempSalesAdvLetterEntryCZZGlob.Cancelled := Correction;
        TempSalesAdvLetterEntryCZZGlob."Auxiliary Entry" := AuxiliaryEntry;
        OnPostExchangeRateOnBeforeInsertEntry(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
            AdvancePostingParametersCZZ, TempSalesAdvLetterEntryCZZGlob);
        EntryNo := TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        OnAfterPostExchangeRate(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
            EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ, TempSalesAdvLetterEntryCZZGlob);
    end;

    internal procedure PostUnrealizedExchangeRate(
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
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
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
            RelatedEntryNo, RelatedDetEntryNo, Correction, GenJnlPostLine, AdvancePostingParametersCZZ, IsHandled);
        if IsHandled then
            exit;

        if AdvancePostingParametersCZZ."Source Code" = '' then begin
            SourceCodeSetup.Get();
            AdvancePostingParametersCZZ."Source Code" := SourceCodeSetup."Exchange Rate Adjmt.";
        end;

        if VATAmount <> 0 then begin
            GetCurrency(SalesAdvLetterHeaderCZZ."Currency Code");

            // Post unrealized exchange rate
            InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine."Shortcut Dimension 1 Code" := SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code";
            GenJournalLine."Shortcut Dimension 2 Code" := SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code";
            GenJournalLine."Dimension Set ID" := SalesAdvLetterHeaderCZZ."Dimension Set ID";
            if VATAmount > 0 then
                GenJournalLine."Account No." := CurrencyGlob.GetUnrealizedLossesAccount()
            else
                GenJournalLine."Account No." := CurrencyGlob.GetUnrealizedGainsAccount();
            GenJournalLine.Validate(Amount, VATAmount);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostUnrealizedExchangeRateOnBeforePost(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostUnrealizedExchangeRateOnAfterPost(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;

            // Post unrealized exchange rate balance
            InitGenJournalLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
            GenJournalLine."Account No." := VATPostingSetup.GetSalesAdvLetterAccountCZZ();
            GenJournalLine.Validate(Amount, -VATAmount);
            if not AdvancePostingParametersCZZ."Temporary Entries Only" then begin
                OnPostUnrealizedExchangeRateOnBeforePostBalance(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GenJnlPostLine, GenJournalLine);
                GLEntryNo := RunGenJnlPostLine(GenJournalLine, GenJnlPostLine, false, false, false);
                OnPostUnrealizedExchangeRateOnAfterPostBalance(
                    SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
                    AdvancePostingParametersCZZ, GLEntryNo, GenJnlPostLine, GenJournalLine);
            end;
        end;

        TempSalesAdvLetterEntryCZZGlob.InitNewEntry();
        TempSalesAdvLetterEntryCZZGlob.InitRelatedEntry(RelatedEntryNo);
        TempSalesAdvLetterEntryCZZGlob.InitDetailedCustLedgerEntry(RelatedDetEntryNo);
        TempSalesAdvLetterEntryCZZGlob.CopyFromVATPostingSetup(VATPostingSetup);
        TempSalesAdvLetterEntryCZZGlob.CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
        TempSalesAdvLetterEntryCZZGlob."Entry Type" := "Advance Letter Entry Type CZZ"::"VAT Adjustment";
        TempSalesAdvLetterEntryCZZGlob."Document No." := AdvancePostingParametersCZZ."Document No.";
        TempSalesAdvLetterEntryCZZGlob."Posting Date" := AdvancePostingParametersCZZ."Posting Date";
        TempSalesAdvLetterEntryCZZGlob."VAT Date" := AdvancePostingParametersCZZ."VAT Date";
        TempSalesAdvLetterEntryCZZGlob."Amount (LCY)" := Amount;
        TempSalesAdvLetterEntryCZZGlob."VAT Amount (LCY)" := VATAmount;
        TempSalesAdvLetterEntryCZZGlob."VAT Base Amount (LCY)" := Amount - VATAmount;
        TempSalesAdvLetterEntryCZZGlob."Global Dimension 1 Code" := SalesAdvLetterEntryCZZ."Global Dimension 1 Code";
        TempSalesAdvLetterEntryCZZGlob."Global Dimension 2 Code" := SalesAdvLetterEntryCZZ."Global Dimension 2 Code";
        TempSalesAdvLetterEntryCZZGlob."Dimension Set ID" := SalesAdvLetterEntryCZZ."Dimension Set ID";
        TempSalesAdvLetterEntryCZZGlob.Cancelled := Correction;
        TempSalesAdvLetterEntryCZZGlob."Auxiliary Entry" := AuxiliaryEntry;
        OnPostUnrealizedExchangeRateOnBeforeInsertEntry(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
            AdvancePostingParametersCZZ, TempSalesAdvLetterEntryCZZGlob);
        EntryNo := TempSalesAdvLetterEntryCZZGlob.InsertNewEntry(not AdvancePostingParametersCZZ."Temporary Entries Only");

        OnAfterPostUnrealizedExchangeRate(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
            EntryNo, GenJnlPostLine, AdvancePostingParametersCZZ, TempSalesAdvLetterEntryCZZGlob);
    end;

    internal procedure BufferAdvanceVATLines(
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        BalanceAtDate: Date)
    begin
        BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, AdvancePostingBufferCZZ, BalanceAtDate, true);
    end;

    local procedure BufferAdvanceVATLines(
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        BalanceAtDate: Date;
        ResetBuffer: Boolean)
    var
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
    begin
        if ResetBuffer then begin
            AdvancePostingBufferCZZ.Reset();
            AdvancePostingBufferCZZ.DeleteAll();
        end;

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetFilter("Entry Type", '<>%1', SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Adjustment");
        if BalanceAtDate <> 0D then
            SalesAdvLetterEntryCZZ2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        if SalesAdvLetterEntryCZZ2.FindSet() then
            repeat
                if SalesAdvLetterEntryCZZ2."Entry Type" in
                  [SalesAdvLetterEntryCZZ2."Entry Type"::Payment,
                   SalesAdvLetterEntryCZZ2."Entry Type"::Usage,
                   SalesAdvLetterEntryCZZ2."Entry Type"::Close]
                then
                    BufferAdvanceVATLines(SalesAdvLetterEntryCZZ2, AdvancePostingBufferCZZ, BalanceAtDate, false)
                else begin
                    TempAdvancePostingBufferCZZ.PrepareForSalesAdvLetterEntry(SalesAdvLetterEntryCZZ2);
                    AdvancePostingBufferCZZ.Update(TempAdvancePostingBufferCZZ);
                end;
            until SalesAdvLetterEntryCZZ2.Next() = 0;
    end;

    internal procedure SuggestUsageVAT(
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ";
        InvoiceNo: Code[20];
        UsedAmount: Decimal;
        CurrencyFactor: Decimal;
        TemporaryEntriesOnly: Boolean)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        TempAdvancePostingBufferCZZ1: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ2: Record "Advance Posting Buffer CZZ" temporary;
        TotalAmount: Decimal;
        UseAmount: Decimal;
        UseBaseAmount: Decimal;
        i: Integer;
        Continue: Boolean;
    begin
        AdvancePostingBufferCZZ.CalcSums(Amount);
        TotalAmount := -AdvancePostingBufferCZZ.Amount;
        if (UsedAmount <> 0) and (TotalAmount > UsedAmount) then begin
            Continue := InvoiceNo <> '';
            if Continue then
                if TemporaryEntriesOnly then begin
                    SalesLine.SetFilter("Document Type", '%1|%2',
                        SalesLine."Document Type"::Order,
                        SalesLine."Document Type"::Invoice);
                    SalesLine.SetRange("Document No.", InvoiceNo);
                    Continue := SalesLine.FindSet();
                end else begin
                    SalesInvoiceLine.SetRange("Document No.", InvoiceNo);
                    Continue := SalesInvoiceLine.FindSet();
                end;

            if Continue then begin
                BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ2, 0D);

                if TemporaryEntriesOnly then
                    repeat
                        TempAdvancePostingBufferCZZ1.Init();
                        TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group" := SalesLine."VAT Bus. Posting Group";
                        TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group" := SalesLine."VAT Prod. Posting Group";
                        if TempAdvancePostingBufferCZZ1.Find() then begin
                            TempAdvancePostingBufferCZZ1.Amount -= SalesLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" -= SalesLine.Amount;
                            TempAdvancePostingBufferCZZ1.Modify();
                        end else begin
                            TempAdvancePostingBufferCZZ1."VAT Calculation Type" := SalesLine."VAT Calculation Type";
                            TempAdvancePostingBufferCZZ1."VAT %" := SalesLine."VAT %";
                            TempAdvancePostingBufferCZZ1.Amount := -SalesLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" := -SalesLine.Amount;
                            TempAdvancePostingBufferCZZ1.Insert();
                        end;
                    until SalesLine.Next() = 0
                else
                    repeat
                        TempAdvancePostingBufferCZZ1.Init();
                        TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group" := SalesInvoiceLine."VAT Bus. Posting Group";
                        TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group" := SalesInvoiceLine."VAT Prod. Posting Group";
                        if TempAdvancePostingBufferCZZ1.Find() then begin
                            TempAdvancePostingBufferCZZ1.Amount -= SalesInvoiceLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" -= SalesInvoiceLine.Amount;
                            TempAdvancePostingBufferCZZ1.Modify();
                        end else begin
                            TempAdvancePostingBufferCZZ1."VAT Calculation Type" := SalesInvoiceLine."VAT Calculation Type";
                            TempAdvancePostingBufferCZZ1."VAT %" := SalesInvoiceLine."VAT %";
                            TempAdvancePostingBufferCZZ1.Amount := -SalesInvoiceLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" := -SalesInvoiceLine.Amount;
                            TempAdvancePostingBufferCZZ1.Insert();
                        end;
                    until SalesInvoiceLine.Next() = 0;

                GetCurrency(SalesAdvLetterEntryCZZ."Currency Code");

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
                                    UseAmount := -UsedAmount;
                                    UseBaseAmount := Round(TempAdvancePostingBufferCZZ2."VAT Base Amount" * UseAmount / TempAdvancePostingBufferCZZ2.Amount, CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                                end;
                                if TempAdvancePostingBufferCZZ1."VAT %" <> TempAdvancePostingBufferCZZ2."VAT %" then
                                    UseBaseAmount := Round(TempAdvancePostingBufferCZZ2."VAT Base Amount" * UseAmount / TempAdvancePostingBufferCZZ2.Amount, CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());

                                TempAdvancePostingBufferCZZ2.Amount -= UseAmount;
                                TempAdvancePostingBufferCZZ2."VAT Base Amount" -= UseBaseAmount;
                                TempAdvancePostingBufferCZZ2.Modify();
                                TempAdvancePostingBufferCZZ1.Amount -= UseAmount;
                                TempAdvancePostingBufferCZZ1."VAT Base Amount" -= UseBaseAmount;
                                TempAdvancePostingBufferCZZ1.Modify();
                                UsedAmount += UseAmount;
                            until (TempAdvancePostingBufferCZZ2.Next() = 0) or (UsedAmount = 0);
                        TempAdvancePostingBufferCZZ2.Reset();
                    until TempAdvancePostingBufferCZZ1.Next() = 0;
                end;

                if AdvancePostingBufferCZZ.FindSet() then
                    repeat
                        TempAdvancePostingBufferCZZ2.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");
                        case true of
                            TempAdvancePostingBufferCZZ2.Amount = 0:
                                ;
                            TempAdvancePostingBufferCZZ2.Amount <> AdvancePostingBufferCZZ.Amount:
                                begin
                                    AdvancePostingBufferCZZ.Amount := AdvancePostingBufferCZZ.Amount - TempAdvancePostingBufferCZZ2.Amount;
                                    AdvancePostingBufferCZZ."VAT Base Amount" := AdvancePostingBufferCZZ."VAT Base Amount" - TempAdvancePostingBufferCZZ2."VAT Base Amount";
                                    AdvancePostingBufferCZZ."VAT Amount" := AdvancePostingBufferCZZ.Amount - AdvancePostingBufferCZZ."VAT Base Amount";
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
                    AdvancePostingBufferCZZ.Amount := Round(AdvancePostingBufferCZZ.Amount * UsedAmount / TotalAmount, CurrencyGlob."Amount Rounding Precision");
                    AdvancePostingBufferCZZ."VAT Amount" := Round(AdvancePostingBufferCZZ."VAT Amount" * UsedAmount / TotalAmount, CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                    AdvancePostingBufferCZZ."VAT Base Amount" := AdvancePostingBufferCZZ.Amount - AdvancePostingBufferCZZ."VAT Amount";
                    AdvancePostingBufferCZZ.Modify();
                until AdvancePostingBufferCZZ.Next() = 0;
            end;
        end;

        if AdvancePostingBufferCZZ.FindSet() then
            repeat
                AdvancePostingBufferCZZ.UpdateLCYAmounts(SalesAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
                AdvancePostingBufferCZZ.Modify();
            until AdvancePostingBufferCZZ.Next() = 0;
    end;

    local procedure UnapplyCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        DetailedCustLedgEntry1: Record "Detailed Cust. Ledg. Entry";
        DetailedCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
        DetailedCustLedgEntry3: Record "Detailed Cust. Ledg. Entry";
        GenJournalLine: Record "Gen. Journal Line";
        Succes: Boolean;
    begin
        DetailedCustLedgEntry1.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type");
        DetailedCustLedgEntry1.SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
        DetailedCustLedgEntry1.SetRange("Entry Type", DetailedCustLedgEntry1."Entry Type"::Application);
        DetailedCustLedgEntry1.SetRange(Unapplied, false);
        Succes := false;
        repeat
            if DetailedCustLedgEntry1.FindLast() then begin
                DetailedCustLedgEntry2.Reset();
                DetailedCustLedgEntry2.SetCurrentKey("Transaction No.", "Customer No.", "Entry Type");
                DetailedCustLedgEntry2.SetRange("Transaction No.", DetailedCustLedgEntry1."Transaction No.");
                DetailedCustLedgEntry2.SetRange("Customer No.", DetailedCustLedgEntry1."Customer No.");
                if DetailedCustLedgEntry2.FindSet() then
                    repeat
                        if (DetailedCustLedgEntry2."Entry Type" <> DetailedCustLedgEntry2."Entry Type"::"Initial Entry") and
                           not DetailedCustLedgEntry2.Unapplied
                        then begin
                            DetailedCustLedgEntry3.Reset();
                            DetailedCustLedgEntry3.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type");
                            DetailedCustLedgEntry3.SetRange("Cust. Ledger Entry No.", DetailedCustLedgEntry2."Cust. Ledger Entry No.");
                            DetailedCustLedgEntry3.SetRange(Unapplied, false);
                            if DetailedCustLedgEntry3.FindLast() and
                               (DetailedCustLedgEntry3."Transaction No." > DetailedCustLedgEntry2."Transaction No.")
                            then
                                Error(UnapplyLastInvoicesErr);
                        end;
                    until DetailedCustLedgEntry2.Next() = 0;

                GenJournalLine.Init();
                GenJournalLine."Document No." := DetailedCustLedgEntry1."Document No.";
                GenJournalLine."Posting Date" := DetailedCustLedgEntry1."Posting Date";
                GenJournalLine.Validate("VAT Reporting Date", CustLedgerEntry."VAT Date CZL");
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                GenJournalLine."Account No." := DetailedCustLedgEntry1."Customer No.";
                GenJournalLine.Correction := true;
                GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
                GenJournalLine.Description := CustLedgerEntry.Description;
                GenJournalLine."Shortcut Dimension 1 Code" := CustLedgerEntry."Global Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := CustLedgerEntry."Global Dimension 2 Code";
                GenJournalLine."Dimension Set ID" := CustLedgerEntry."Dimension Set ID";
                GenJournalLine."Posting Group" := CustLedgerEntry."Customer Posting Group";
                GenJournalLine."Source Currency Code" := DetailedCustLedgEntry1."Currency Code";
                GenJournalLine."System-Created Entry" := true;
                OnUnapplyCustLedgEntryOnBeforePostUnapplyCustLedgEntry(CustLedgerEntry, DetailedCustLedgEntry1, GenJournalLine);
                GenJnlPostLine.UnapplyCustLedgEntry(GenJournalLine, DetailedCustLedgEntry1);
            end else
                Succes := true;
        until Succes;
    end;

    local procedure InitGenJournalLine(
        var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
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
        GenJournalLine.CopyFromSalesAdvLetterHeaderCZZ(SalesAdvLetterHeaderCZZ);
        GenJournalLine.CopyFromSalesAdvLetterEntryCZZ(SalesAdvLetterEntryCZZ);
        GenJournalLine.SetCurrencyFactor(
            AdvancePostingParametersCZZ."Currency Code", AdvancePostingParametersCZZ."Currency Factor");
        OnAfterInitGenJournalLine(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, AdvancePostingParametersCZZ, GenJournalLine);
    end;

    local procedure InitGenJournalLine(
        var CustLedgerEntry: Record "Cust. Ledger Entry";
        var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.InitNewLineCZZ(CustLedgerEntry);
        GenJournalLine.CopyFromCustLedgerEntryCZZ(CustLedgerEntry);
        OnAfterInitGenJournalLineFromCustLedgerEntry(CustLedgerEntry, GenJournalLine);
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

    local procedure InitCustLedgerEntryFromSalesInvoiceHeader(SalesInvoiceHeader: Record "Sales Invoice Header"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry.Init();
        CustLedgerEntry."Customer No." := SalesInvoiceHeader."Bill-to Customer No.";
        CustLedgerEntry."Posting Date" := SalesInvoiceHeader."Posting Date";
        CustLedgerEntry."Document Date" := SalesInvoiceHeader."Document Date";
        CustLedgerEntry."Document Type" := CustLedgerEntry."Document Type"::Invoice;
        CustLedgerEntry."Document No." := SalesInvoiceHeader."No.";
        CustLedgerEntry.Description := SalesInvoiceHeader."Posting Description";
        CustLedgerEntry."Currency Code" := SalesInvoiceHeader."Currency Code";
        CustLedgerEntry."Sell-to Customer No." := SalesInvoiceHeader."Sell-to Customer No.";
        CustLedgerEntry."Customer Posting Group" := SalesInvoiceHeader."Customer Posting Group";
        CustLedgerEntry."Global Dimension 1 Code" := SalesInvoiceHeader."Shortcut Dimension 1 Code";
        CustLedgerEntry."Global Dimension 2 Code" := SalesInvoiceHeader."Shortcut Dimension 2 Code";
        CustLedgerEntry."Dimension Set ID" := SalesInvoiceHeader."Dimension Set ID";
        CustLedgerEntry."Salesperson Code" := SalesInvoiceHeader."Salesperson Code";
        CustLedgerEntry."Due Date" := SalesInvoiceHeader."Due Date";
        CustLedgerEntry."Payment Method Code" := SalesInvoiceHeader."Payment Method Code";
        CustLedgerEntry."VAT Date CZL" := SalesInvoiceHeader."VAT Reporting Date";
        CustLedgerEntry."Original Currency Factor" := SalesInvoiceHeader."Currency Factor";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry"; PostedGenJournalLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePayment(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; CustLedgerEntry: Record "Cust. Ledger Entry"; PostedGenJournalLine: Record "Gen. Journal Line"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentOnBeforePostPaymentApplication(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentOnAfterPostPaymentApplication(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentOnBeforePostAdvancePayment(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentOnAfterPostAdvancePayment(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePaymentUnlinking(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentUnlinking(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUnlinkingOnBeforePostAdvancePaymentApplication(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUnlinkingOnAfterPostAdvancePaymentApplication(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUnlinkingOnBeforePostPaymentApplication(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUnlinkingOnAfterPostPaymentApplication(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePaymentVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentVAT(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATOnBeforePost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATOnAfterPost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATOnBeforePostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATOnAfterPostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePaymentVATUnlinking(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentVATUnlinking(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATUnlinkingOnBeforePost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATUnlinkingOnAfterPost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATUnlinkingOnBeforePostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentVATUnlinkingOnAfterPostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePaymentUsage(var SalesInvoiceHeader: Record "Sales Invoice Header"; var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParameters: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentUsage(var SalesInvoiceHeader: Record "Sales Invoice Header"; var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParameters: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUsageOnAfterSetSalesAdvLetterEntryFilter(AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePaymentUsageVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentUsageVAT(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceCreditMemoVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceCreditMemoVAT(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceCreditMemoVATOnBeforePost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceCreditMemoVATOnAfterPost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceCreditMemoVATOnBeforePostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceCreditMemoVATOnAfterPostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterApplying(var SalesInvoiceHeader: Record "Sales Invoice Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterApplying(var SalesInvoiceHeader: Record "Sales Invoice Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterUnapplying(var SalesInvoiceHeader: Record "Sales Invoice Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterUnapplying(SalesInvoiceHeader: Record "Sales Invoice Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterEntryVATUsageUnapplying(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterEntryVATUsageUnapplying(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryVATUsageUnapplyingOnBeforePost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryVATUsageUnapplyingOnAfterPost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryVATUsageUnapplyingOnBeforePostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryVATUsageUnapplyingOnAfterPostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterEntryUsageUnapplying(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterEntryUsageUnapplying(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryUsageUnapplyingOnBeforePostAdvancePaymentApplication(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryUsageUnapplyingOnAfterPostAdvancePaymentApplication(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryUsageUnapplyingOnBeforePostInvoiceApplication(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryUsageUnapplyingOnAfterPostInvoiceApplication(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterClosing(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterClosing(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvanceLetterEntryClosing(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvanceLetterEntryClosing(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryClosingOnBeforePost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; CustLedgerEntry: Record "Cust. Ledger Entry"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryClosingOnAfterPost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; CustLedgerEntry: Record "Cust. Ledger Entry"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryClosingOnBeforePostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; CustLedgerEntry: Record "Cust. Ledger Entry"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterEntryClosingOnAfterPostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; CustLedgerEntry: Record "Cust. Ledger Entry"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReverseAdvancePayment(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; SalesInvoiceHeader: Record "Sales Invoice Header"; ReverseAmount: Decimal; ReverseAmountLCY: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReverseAdvancePayment(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; SalesInvoiceHeader: Record "Sales Invoice Header"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentOnBeforePostInvoiceApplication(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; CustLedgerEntry: Record "Cust. Ledger Entry"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentOnAfterPostInvoiceApplication(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; CustLedgerEntry: Record "Cust. Ledger Entry"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentOnBeforePostAdvancePaymentUsage(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; CustLedgerEntry: Record "Cust. Ledger Entry"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentOnAfterPostAdvancePaymentUsage(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; CustLedgerEntry: Record "Cust. Ledger Entry"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReverseAdvancePaymentVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; RelatedEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReverseAdvancePaymentVAT(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentVATOnBeforePost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentVATOnAfterPost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentVATOnBeforePostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseAdvancePaymentVATOnAfterPostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReverseUnrealizedExchangeRate(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Coef: Decimal; RelatedEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostExchangeRate(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; RelatedEntryNo: Integer; Correction: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostExchangeRate(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var CreatedSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnBeforePostVATBase(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnAfterPostVATBase(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnBeforePostVATAmount(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnAfterPostVATAmount(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnBeforePostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnAfterPostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostExchangeRateOnBeforeInsertEntry(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var CreatedSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostUnrealizedExchangeRate(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; RelatedEntryNo: Integer; RelatedDetEntryNo: Integer; Correction: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostUnrealizedExchangeRate(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; EntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var CreatedSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUnrealizedExchangeRateOnBeforePost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUnrealizedExchangeRateOnAfterPost(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUnrealizedExchangeRateOnBeforePostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUnrealizedExchangeRateOnAfterPostBalance(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; VATAmount: Decimal; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUnrealizedExchangeRateOnBeforeInsertEntry(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; VATPostingSetup: Record "VAT Posting Setup"; AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var CreatedSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUnapplyCustLedgEntryOnBeforePostUnapplyCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitGenJournalLine(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitGenJournalLineFromCustLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GLEntryNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GLEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvanceLetterClosingOnAfterSetSalesAdvLetterEntryFilter(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;
}