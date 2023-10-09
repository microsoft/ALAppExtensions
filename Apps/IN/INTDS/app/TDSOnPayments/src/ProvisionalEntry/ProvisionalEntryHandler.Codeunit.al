// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPayments;

using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.Navigate;
using Microsoft.Finance.GeneralLedger.Reversal;
using System.Utilities;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.Currency;

codeunit 18768 "Provisional Entry Handler"
{
    procedure ReverseProvisionalEntries(Number: Integer)
    var
        ReversalPost: Codeunit "Reversal-Post";
        ProvEntReversalMgt: Codeunit "Provisional Entry Reversal Mgt";
    begin
        ProvEntReversalMgt.SetReverseProvEntWithoutTDS(true);
        InsertReversalProvisionalEntry(Number);
        TempReversalEntry.SetCurrentKey("Document No.", "Posting Date", "Entry Type", "Entry No.");
        if not HideDialog then
            Page.RunModal(Page::"Reverse Transaction Entries", TempReversalEntry)
        else begin
            ReversalPost.SetPrint(false);
            ReversalPost.Run(TempReversalEntry);
        end;

        TempReversalEntry.DeleteAll();
        ProvEntReversalMgt.SetReverseProvEntWithoutTDS(false);
    end;

    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := NewHideDialog;
    end;

    local procedure InsertReversalProvisionalEntry(Number: Integer)
    var
        TempRevertTransactionNo: Record Integer temporary;
        GeneralLedgerSetup: Record "General Ledger Setup";
        NextLineNo: Integer;
    begin
        GeneralLedgerSetup.Get();
        TempReversalEntry.DeleteAll();
        NextLineNo := 1;
        TempRevertTransactionNo.Number := Number;
        TempRevertTransactionNo.Insert();
        SetReverseFilterProvisionalEntry(Number);

        InsertFromGLEntryProvisional(TempRevertTransactionNo, NextLineNo);
    end;

    local procedure SetReverseFilterProvisionalEntry(Number: Integer)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetCurrentKey("Transaction No.");
        GLEntry.SetRange("Transaction No.", Number);
    end;

    local procedure InsertFromGLEntryProvisional(var TempRevertTransactionNo: Record Integer temporary; var NextLineNo: Integer)
    var
        GLEntry: Record "G/L Entry";
        GLAccount: Record "G/L Account";
    begin
        TempRevertTransactionNo.FindSet();
        repeat
            GLEntry.SetRange("Transaction No.", TempRevertTransactionNo.Number);
            GLEntry.SetFilter("Bal. Account No.", '<>%1', '');
            if GLEntry.FindSet() then
                repeat
                    CheckTDSPaid(GLEntry);
                    Clear(TempReversalEntry);
                    TempReversalEntry."Reversal Type" := TempReversalEntry."Reversal Type"::Transaction;
                    TempReversalEntry."Entry Type" := TempReversalEntry."Entry Type"::"G/L Account";
                    TempReversalEntry."Entry No." := GLEntry."Entry No.";
                    if not GLAccount.GET(GLEntry."G/L Account No.") then
                        Error(TransReverseErr, GLEntry.TableCaption, GLAccount.TableCaption);

                    TempReversalEntry."Account No." := GLAccount."No.";
                    TempReversalEntry."Account Name" := GLAccount.Name;
                    TempReversalEntry."Posting Date" := GLEntry."Posting Date";
                    TempReversalEntry."Source Code" := GLEntry."Source Code";
                    TempReversalEntry."Journal Batch Name" := GLEntry."Journal Batch Name";
                    TempReversalEntry."Transaction No." := GLEntry."Transaction No.";
                    TempReversalEntry."Source Type" := GLEntry."Source Type";
                    TempReversalEntry."Source No." := GLEntry."Source No.";
                    TempReversalEntry.Description := GLEntry.Description;
                    TempReversalEntry."Amount (LCY)" := GLEntry.Amount;
                    TempReversalEntry."Debit Amount (LCY)" := GLEntry."Debit Amount";
                    TempReversalEntry."Credit Amount (LCY)" := GLEntry."Credit Amount";
                    TempReversalEntry."VAT Amount" := GLEntry."VAT Amount";
                    TempReversalEntry."Document Type" := GLEntry."Document Type";
                    TempReversalEntry."Document No." := GLEntry."Document No.";
                    TempReversalEntry."Bal. Account Type" := GLEntry."Bal. Account Type";
                    TempReversalEntry."Bal. Account No." := GLEntry."Bal. Account No.";
                    TempReversalEntry."Line No." := NextLineNo;
                    NextLineNo := NextLineNo + 1;
                    TempReversalEntry.Insert();
                until GLEntry.Next() = 0;
        until TempRevertTransactionNo.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithoutCheck', '', false, false)]
    local procedure PostVendorEntry(var GenJnlLine: Record "Gen. Journal Line"; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        Vendor: Record Vendor;
        TDSEntityManagement: Codeunit "TDS Entity Management";
        TDSAmount, TDSAmountLCY : Decimal;
    begin
        TaxTransactionValue.SetRange("Tax Record ID", GenJnlLine.RecordId);
        if TaxTransactionValue.IsEmpty() then
            exit;

        if (GenJnlLine."TDS Section Code" = '') or (GenJnlLine."Provisional Entry" = false) then
            exit;

        GenJnlLine.testfield("Party Type", GenJnlLine."Party Type"::Vendor);
        GenJnlLine.TestField("Party Code");
        Vendor.GET(GenJnlLine."Party Code");
        Vendor.TestField("Vendor Posting Group");
        GenJnlLine.TestField("Document Type", GenJnlLine."Document Type"::Invoice);
        GenJnlLine.TestField("Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.TestField("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
        GenJnlLine.TestField("Party Code");
        GenJnlLine.TestField("Party Type", GenJnlLine."Party Type"::Vendor);
        GenJnlLine.TestField("TDS Section Code");
        if GenJnlLine.Amount <= 0 THEN
            Error(AmtNegativeErr);

        TDSAmount := TDSEntityManagement.RoundTDSAmount(GetTDSAmount(GenJnlLine));
        if GenJnlLine."Currency Code" <> '' then
            TDSAmountLCY := GetTDSAmountLCY(GenJnlLine, TDSAmount)
        else
            TDSAmountLCY := TDSAmount;

        GenJournalLine := GenJnlLine;
        Clear(GenJournalLine."Tax ID");
        Clear(GenJournalLine."Line No.");
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
        GenJournalLine."System-Created Entry" := true;
        Clear(GenJournalLine."Bal. Account Type");
        GenJournalLine."Bal. Account No." := '';
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
        GenJournalLine."Account No." := GenJnlLine."Party Code";
        GenJournalLine.Validate(Amount, TDSAmount);
        GenJournalLine.Validate("Amount (LCY)", TDSAmountLCY);
        InsertProvisionalEntry(GenJnlLine, sender);
        sender.RunWithCheck(GenJournalLine);
    end;

    local procedure InsertProvisionalEntry(var GenJnlLine: Record "Gen. Journal Line"; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        ProvisionalEntry: Record "Provisional Entry";
    begin
        if (GenJnlLine."Party Code" = '') or (GenJnlLine."TDS Section Code" = '') then
            exit;

        ProvisionalEntry.Init();
        ProvisionalEntry."Journal Batch Name" := GenJnlLine."Journal Batch Name";
        ProvisionalEntry."Journal Template Name" := GenJnlLine."Journal Template Name";
        ProvisionalEntry."Document Type" := GenJnlLine."Document Type"::Invoice;
        ProvisionalEntry."Posted Document No." := GenJnlLine."Document No.";
        ProvisionalEntry."Document Date" := GenJnlLine."Document Date";
        ProvisionalEntry."Posting Date" := GenJnlLine."Posting Date";
        ProvisionalEntry."Party Type" := GenJnlLine."Party Type";
        ProvisionalEntry."Party Code" := GenJnlLine."Party Code";
        ProvisionalEntry."Account Type" := GenJnlLine."Account Type";
        ProvisionalEntry."Account No." := GenJnlLine."Bal. Account No.";
        ProvisionalEntry."TDS Section Code" := GenJnlLine."TDS Section Code";
        ProvisionalEntry.Amount := -GenJnlLine.Amount;
        ProvisionalEntry."Amount LCY" := -GenJnlLine."Amount (LCY)";
        if ProvisionalEntry.Amount > 0 then
            ProvisionalEntry."Debit Amount" := Abs(ProvisionalEntry.Amount)
        else
            ProvisionalEntry."Credit Amount" := Abs(ProvisionalEntry.Amount);

        ProvisionalEntry."Bal. Account Type" := GenJnlLine."Bal. Account Type";
        ProvisionalEntry."Bal. Account No." := GenJnlLine."Account No.";
        ProvisionalEntry."Location Code" := GenJnlLine."Location Code";
        ProvisionalEntry."Externl Document No." := GenJnlLine."External Document No.";
        ProvisionalEntry."Currency Code" := GenJnlLine."Currency Code";
        ProvisionalEntry."User ID" := CopyStr(UserId, 1, 50);
        ProvisionalEntry.Open := true;
        ProvisionalEntry."Transaction No." := sender.GetNextTransactionNo();
        ProvisionalEntry.Insert(true)
    end;

    local procedure GetTDSAmount(GenJnlLine: Record "Gen. Journal Line"): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TDSSetup: Record "TDS Setup";
        TaxComponent: Record "Tax Component";
        TDSAmount: Decimal;
    begin
        if not TDSSetup.Get() then
            exit;

        TDSSetup.TestField("Tax Type");

        TaxComponent.SetRange("Tax Type", TDSSetup."Tax Type");
        TaxComponent.SetRange("Skip Posting", false);
        if TaxComponent.FindSet() then
            repeat
                TaxTransactionValue.SetRange("Tax Record ID", GenJnlLine.RecordId);
                TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
                TaxTransactionValue.SetRange("Value ID", TaxComponent.ID);
                if TaxTransactionValue.FindSet() then
                    repeat
                        TDSAmount += TaxTransactionValue.Amount;
                    until TaxTransactionValue.Next() = 0;
            until TaxComponent.Next() = 0;
        exit(TDSAmount);
    end;

    local procedure GetTDSAmountLCY(GenJnlLine: Record "Gen. Journal Line"; TDSAmount: Decimal): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        TDSEntityManagement: Codeunit "TDS Entity Management";
        TDSAmt: Decimal;
    begin
        TDSAmt := CurrencyExchangeRate.ExchangeAmtFCYToLCY(GenJnlLine."Posting Date", GenJnlLine."Currency Code", TDSAmount, GenJnlLine."Currency Factor");
        exit(TDSEntityManagement.RoundTDSAmount(TDSAmt));
    end;


    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', false, false)]
    local procedure FindTCSEntries(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        ProvisionalEntry: Record "Provisional Entry";
        Navigate: page Navigate;
    begin
        if ProvisionalEntry.ReadPermission() then begin
            ProvisionalEntry.Reset();
            ProvisionalEntry.SetCurrentKey("Posted Document No.", "Posting Date");
            ProvisionalEntry.SetFilter("Posted Document No.", DocNoFilter);
            ProvisionalEntry.SetFilter("Posting Date", PostingDateFilter);
            Navigate.InsertIntoDocEntry(DocumentEntry, Database::"Provisional Entry", 0, Copystr(ProvisionalEntry.TableCaption(), 1, 1024), ProvisionalEntry.Count());
        end;
    end;

    [EventSubscriber(ObjectType::Page, page::Navigate, 'OnAfterNavigateShowRecords', '', false, false)]
    local procedure ShowEntries(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; var TempDocumentEntry: Record "Document Entry")
    var
        ProvisionalEntry: Record "Provisional Entry";
    begin
        ProvisionalEntry.Reset();
        ProvisionalEntry.SetFilter("Posted Document No.", DocNoFilter);
        ProvisionalEntry.SetFilter("Posting Date", PostingDateFilter);
        if TableID = Database::"Provisional Entry" then
            Page.Run(Page::"Provisional Entries Preview", ProvisionalEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithoutCheck', '', false, false)]
    local procedure CreateReverseProvisionalEntry(var GenJnlLine: Record "Gen. Journal Line"; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        ProvisionalEntry: Record "Provisional Entry";
        ProvGenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        VendLedgerEntryNo: Integer;
    begin
        if GenJnlLine."Applied Provisional Entry" = 0 then
            exit;

        CheckMultiLineProvisionalEntry(GenJnlLine);
        VendLedgerEntryNo := sender.GetNextEntryNo();

        ProvisionalEntry.Get(GenJnlLine."Applied Provisional Entry");
        ProvisionalEntry.TestField(Reversed, false);
        ProvisionalEntry.TestField(Open, true);
        ProvisionalEntry.TestField("Reversed After TDS Paid", false);
        ProvisionalEntry."Actual Invoice Posting Date" := GenJnlLine."Posting Date";

        GLEntry.SetRange("Posting Date", ProvisionalEntry."Posting Date");
        GLEntry.SetRange("Document No.", ProvisionalEntry."Posted Document No.");
        GLEntry.SetFilter("Bal. Account No.", '<>%1', '');
        GLEntry.FindFirst();

        ProvGenJournalLine."Posting Date" := GenJnlLine."Posting Date";
        ProvGenJournalLine."Journal Template Name" := GenJnlLine."Journal Template Name";
        ProvGenJournalLine."Journal Batch Name" := GenJnlLine."Journal Batch Name";
        ProvGenJournalLine."Document Date" := GenJnlLine."Document Date";
        ProvGenJournalLine."Document Type" := ProvGenJournalLine."Document Type"::Invoice;
        ProvGenJournalLine."Document No." := GenJnlLine."Document No.";
        ProvGenJournalLine."External Document No." := GenJnlLine."External Document No.";
        ProvGenJournalLine.Validate("Account Type", ProvGenJournalLine."Account Type"::"G/L Account");
        ProvGenJournalLine."Account No." := GLEntry."G/L Account No.";
        ProvGenJournalLine.Validate("Bal. Account Type", ProvGenJournalLine."Bal. Account Type"::"G/L Account");
        ProvGenJournalLine."Bal. Account No." := GLEntry."Bal. Account No.";
        ProvGenJournalLine.Validate("Currency Code", GenJnlLine."Currency Code");
        ProvGenJournalLine.Validate(Amount, -GLEntry.Amount);
        ProvGenJournalLine.Validate("Amount (LCY)", -GLEntry.Amount);
        ProvGenJournalLine."Currency Factor" := 1;
        ProvGenJournalLine."Source Currency Code" := GenJnlLine."Source Currency Code";
        ProvGenJournalLine."Gen. Posting Type" := GLEntry."Gen. Posting Type";
        ProvGenJournalLine."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
        ProvGenJournalLine."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
        ProvGenJournalLine."Shortcut Dimension 1 Code" := GLEntry."Global Dimension 1 Code";
        ProvGenJournalLine."Shortcut Dimension 2 Code" := GLEntry."Global Dimension 2 Code";
        ProvGenJournalLine.Validate("Dimension Set ID", GLEntry."Dimension Set ID");
        ProvGenJournalLine."Posting No. Series" := GenJnlLine."Posting No. Series";
        ProvGenJournalLine."Location Code" := GenJnlLine."Location Code";
        ProvGenJournalLine."Source Code" := GenJnlLine."Source Code";
        ProvGenJournalLine."Reason Code" := GenJnlLine."Reason Code";
        ProvGenJournalLine."Provisional Entry" := GenJnlLine."Provisional Entry";
        ProvGenJournalLine."System-Created Entry" := true;
        sender.RunWithCheck(ProvGenJournalLine);

        ProvisionalEntry.Open := false;
        ProvisionalEntry."Purchase Invoice No." := '';
        ProvisionalEntry."Applied User ID" := '';
        ProvisionalEntry."Invoice Jnl Batch Name" := '';
        ProvisionalEntry."Invoice Jnl Template Name" := '';
        ProvisionalEntry."Applied Invoice No." := GenJnlLine."Document No.";
        ProvisionalEntry."Original Invoice Posted" := true;
        ProvisionalEntry."Applied by Vendor Ledger Entry" := VendLedgerEntryNo;
        ProvisionalEntry."Original Invoice Reversed" := false;
        ProvisionalEntry.Modify();
    end;

    local procedure CheckMultiLineProvisionalEntry(GenJournalLine: Record "Gen. Journal Line")
    var
        LineCount: Integer;
        ProvEntryMultiLineErr: Label 'Multi Line transactions are not allowed for Provisional Entries.';
    begin
        LineCount := GetTotalDocLinesProvisionalEntry(GenJournalLine);
        if LineCount > 1 then
            Error(ProvEntryMultiLineErr);
    end;

    local procedure GetTotalDocLinesProvisionalEntry(GenJournalLine: Record "Gen. Journal Line"): Integer
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Document No.", "Line No.");
        GenJnlLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJnlLine.SetRange("System-Created Entry", false);
        if GenJournalLine."Document No." = GenJournalLine."Old Document No." then
            GenJnlLine.SetRange("Document No.", GenJournalLine."Document No.")
        else
            GenJnlLine.SetRange("Document No.", GenJournalLine."Old Document No.");

        exit(GenJnlLine.Count);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Reverse", 'OnAfterReverseGLEntry', '', false, false)]
    local procedure CheckAndUpdateProvisionalEntry(var GLEntry: Record "G/L Entry")
    begin
        CheckProvisionalEntryIfApplied(GLEntry);
        CheckProvisionalEntryOpenAndReversed(GLEntry);
        UpdateProvisionalEntry(GLEntry);
        UpdateProvisionalEntryOnActualInvReversal(GLEntry);
    end;

    local procedure UpdateProvisionalEntry(GLEntry: Record "G/L Entry")
    var
        ProvisionalEntry: Record "Provisional Entry";
    Begin
        ProvisionalEntry.SetRange("Posted Document No.", GLEntry."Document No.");
        ProvisionalEntry.SetRange("Posting Date", GLEntry."Posting Date");
        ProvisionalEntry.SetRange("Account No.", GLEntry."G/L Account No.");
        ProvisionalEntry.SetRange("Bal. Account No.", GLEntry."Bal. Account No.");
        ProvisionalEntry.SetRange(Reversed, false);
        if ProvisionalEntry.FindFirst() then begin
            ProvisionalEntry.Reversed := true;
            ProvisionalEntry.Open := false;
            ProvisionalEntry."Original Invoice Reversed" := false;
            ProvisionalEntry.Modify();
        end;
    end;

    local procedure UpdateProvisionalEntryOnActualInvReversal(GLEntry: Record "G/L Entry")
    var
        ProvisionalEntry: Record "Provisional Entry";
    begin
        ProvisionalEntry.SetRange("Applied Invoice No.", GLEntry."Document No.");
        ProvisionalEntry.SetRange("Actual Invoice Posting Date", GLEntry."Posting Date");
        ProvisionalEntry.SetRange("Original Invoice Posted", true);
        if ProvisionalEntry.FindFirst() then begin
            ProvisionalEntry."Applied Invoice No." := '';
            ProvisionalEntry."Original Invoice Posted" := false;
            ProvisionalEntry."Original Invoice Reversed" := true;
            ProvisionalEntry."Applied by Vendor Ledger Entry" := 0;
            ProvisionalEntry."Purchase Invoice No." := '';
            ProvisionalEntry."Applied User ID" := '';
            ProvisionalEntry."Invoice Jnl Batch Name" := '';
            ProvisionalEntry."Invoice Jnl Template Name" := '';
            ProvisionalEntry.Open := true;
            ProvisionalEntry.Modify();
        end;
    end;

    local procedure CheckProvisionalEntryIfApplied(GLEntry: Record "G/L Entry")
    var
        ProvisionalEntry: Record "Provisional Entry";
        ProvisionalEntryAlreadyAppliedErr: Label 'Provisional Entry is already applied against Document No. %1 on purchase journals.', Comment = '%1= Purchase Invoice No.';
    begin
        ProvisionalEntry.SetRange("Posted Document No.", GLEntry."Document No.");
        ProvisionalEntry.SetRange("Posting Date", GLEntry."Posting Date");
        ProvisionalEntry.SetRange("Account No.", GLEntry."G/L Account No.");
        ProvisionalEntry.SetRange("Bal. Account No.", GLEntry."Bal. Account No.");
        ProvisionalEntry.SetFilter("Purchase Invoice No.", '<>%1', '');
        if ProvisionalEntry.FindFirst() then
            Error(ProvisionalEntryAlreadyAppliedErr, ProvisionalEntry."Purchase Invoice No.");
    end;

    local procedure CheckProvisionalEntryOpenAndReversed(GLEntry: Record "G/L Entry")
    var
        ProvisionalEntry: Record "Provisional Entry";
    begin
        ProvisionalEntry.SetRange("Posted Document No.", GLEntry."Document No.");
        ProvisionalEntry.SetRange("Posting Date", GLEntry."Posting Date");
        ProvisionalEntry.SetRange("Account No.", GLEntry."G/L Account No.");
        ProvisionalEntry.SetRange("Bal. Account No.", GLEntry."Bal. Account No.");
        ProvisionalEntry.SetRange(Open, false);
        if ProvisionalEntry.FindFirst() then
            Error(ProvisionalEntryOpenErr, ProvisionalEntry."Entry No.");

        ProvisionalEntry.SetRange(Open);
        ProvisionalEntry.SetRange(Reversed, true);
        if ProvisionalEntry.FindFirst() then
            Error(ProvisionalEntryReversedErr, ProvisionalEntry."Entry No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnNextTransactionNoNeeded', '', false, false)]
    local procedure OnNextTransactionNoNeeded(GenJnlLine: Record "Gen. Journal Line"; var NewTransaction: Boolean)
    begin
        if GenJnlLine."Provisional Entry" and GenJnlLine."System-Created Entry" then
            NewTransaction := false;
    end;

    local procedure CheckTDSPaid(GLEntry: Record "G/L Entry")
    var
        TDSEntry: Record "TDS Entry";
    begin
        TDSEntry.SetRange("Document No.", GLEntry."Document No.");
        TDSEntry.SetRange("Posting Date", GLEntry."Posting Date");
        TDSEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
        TDSEntry.SetRange("TDS Paid", false);
        if not TDSEntry.IsEmpty then
            Error(ReverseTDSProvisionalErr);
    end;

    var
        TempReversalEntry: Record "Reversal Entry" temporary;
        HideDialog: Boolean;
        ProvisionalEntryOpenErr: Label 'You cannot reverse Provisional Entry No. %1 because the entry is applied to an entry.', Comment = '%1 = Provisional Entry No.';
        ProvisionalEntryReversedErr: Label 'You cannot reverse Provisional Entry No. %1 because the entry has already been involved in a reversal.', Comment = '%1= Provisional Entry No.';
        ReverseTDSProvisionalErr: Label 'Reversal without TDS is allowed where TDS of selected transaction is paid.';
        AmtNegativeErr: Label 'Amount must be negative.';
        TransReverseErr: Label 'The transaction cannot be reversed, because the %1 has been compressed or a %2 has been deleted.', Comment = '%1= GL Entry Table Name,%2=G/L Account Table Name';
}
