// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Check;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 18931 "Gen. Jnl. Post Line Subscriber"
{
    procedure UpdtCheckLedgEnrtyComputerCheck(GenJournalLine: Record "Gen. Journal Line"; BankAccountLedgerEntry: Record "Bank Account Ledger Entry")
    var
        CheckLedgerEntry: Record "Check Ledger Entry";
        NewCheckLedgerEntry: Record "Check Ledger Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DocumentNo: Code[20];
    begin
        DocumentNo := '';
        GeneralLedgerSetup.Get();
        GenJournalLine.TestField("Check Printed", true);
        CheckLedgerEntry.LockTable();
        CheckLedgerEntry.Reset();
        CheckLedgerEntry.SetCurrentKey("Bank Account No.", "Entry Status", "Check No.");
        CheckLedgerEntry.SetRange("Bank Account No.", GenJournalLine."Account No.");
        CheckLedgerEntry.SetRange("Entry Status", CheckLedgerEntry."Entry Status"::Printed);
        if not GeneralLedgerSetup."Activate Cheque No." then
            CheckLedgerEntry.SetRange("Check No.", GenJournalLine."Document No.")
        else
            CheckLedgerEntry.SetRange("Check No.", GenJournalLine."Cheque No.");
        if CheckLedgerEntry.FindSet() then
            repeat
                NewCheckLedgerEntry := CheckLedgerEntry;
                NewCheckLedgerEntry."Entry Status" := NewCheckLedgerEntry."Entry Status"::Posted;
                NewCheckLedgerEntry."Bank Account Ledger Entry No." := BankAccountLedgerEntry."Entry No.";
                if GeneralLedgerSetup."Activate Cheque No." then
                    NewCheckLedgerEntry."Document No." := BankAccountLedgerEntry."Document No.";
                NewCheckLedgerEntry.Modify();
            until CheckLedgerEntry.Next() = 0;

        if GeneralLedgerSetup."Activate Cheque No." then begin
            CheckLedgerEntry.LockTable();
            CheckLedgerEntry.Reset();
            CheckLedgerEntry.SetCurrentKey("Bank Account No.", "Entry Status", "Check No.");
            CheckLedgerEntry.SetRange("Bank Account No.", GenJournalLine."Account No.");
            CheckLedgerEntry.SetFilter("Entry Status", '%1|%2|%3', CheckLedgerEntry."Entry Status"::Voided,
              CheckLedgerEntry."Entry Status"::"Financially Voided", CheckLedgerEntry."Entry Status"::"Test Print");
            CheckLedgerEntry.SetRange("Document No.", DocumentNo);
            if CheckLedgerEntry.FindSet() then
                repeat
                    NewCheckLedgerEntry := CheckLedgerEntry;
                    NewCheckLedgerEntry."Document No." := BankAccountLedgerEntry."Document No.";
                    NewCheckLedgerEntry.Modify();
                until CheckLedgerEntry.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnBeforeBankAccLedgEntryInsert', '', false, false)]
    local procedure UpdateChequeDetails(BankAccount: Record "Bank Account"; var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Activate Cheque No." then begin
            BankAccountLedgerEntry."Cheque No." := GenJournalLine."Cheque No.";
            BankAccountLedgerEntry."Cheque Date" := GenJournalLine."Cheque Date";
        end;

        if (not GeneralLedgerSetup."Activate Cheque No.") and
        (GenJournalLine."Bank Payment Type" in ["Bank Payment Type"::"Manual Check", "Bank Payment Type"::" ", "Bank Payment Type"::"Computer Check"]) then begin
            BankAccountLedgerEntry."Cheque No." := CopyStr((GenJournalLine."Document No."), 1, 10);
            BankAccountLedgerEntry."Cheque Date" := GenJournalLine."Posting Date";
        end;

        BankAccountLedgerEntry."Stale Cheque" := GenJournalLine."Stale Cheque";
        if BankAccountLedgerEntry."Stale Cheque" = true then
            BankAccountLedgerEntry."Cheque Stale Date" := WorkDate();
        if BankAccountLedgerEntry."Cheque Date" <> 0D then
            BankAccountLedgerEntry."Stale Cheque Expiry Date" := CalcDate(BankAccount."Stale Cheque Stipulated Period", BankAccountLedgerEntry."Cheque Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnAfterBankAccLedgEntryInsert', '', false, false)]
    local procedure UpdateComputerCheckLedgerEntry(BankAccount: Record "Bank Account"; var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        if (GenJournalLine.Amount <= 0) and GenJournalLine."Check Printed" and
            (GenJournalLine."Bank Payment Type" = GenJournalLine."Bank Payment Type"::"Computer Check")
        then
            UpdtCheckLedgEnrtyComputerCheck(GenJournalLine, BankAccountLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnBeforeCheckLedgEntryInsert', '', false, false)]
    local procedure UpdateManualCheckLedgerEntry(var GenJournalLine: Record "Gen. Journal Line"; var CheckLedgerEntry: Record "Check Ledger Entry"; BankAccount: Record "Bank Account")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."Activate Cheque No." then
            exit;

        if GenJournalLine."Bank Payment Type" <> GenJournalLine."Bank Payment Type"::"Manual Check" then
            exit;

        GenJournalLine.TestField("Cheque No.");
        GenJournalLine.TestField("Cheque Date");

        if GenJournalLine.Amount < 0 then begin
            CheckLedgerEntry."Check No." := GenJournalLine."Cheque No.";
            CheckLedgerEntry."Check Date" := GenJournalLine."Cheque Date";
        end;

        if CheckLedgerEntry."Check Date" <> 0D then
            CheckLedgerEntry."Stale Cheque Expiry Date" := CalcDate(BankAccount."Stale Cheque Stipulated Period", CheckLedgerEntry."Check Date");
    end;

    [EventSubscriber(ObjectType::Report, Report::Check, 'OnAfterAssignGenJnlLineDocNoAndAccountType', '', false, false)]
    local procedure OnAfterAssignGenJnlLineDocNoAndAccountType(var GenJnlLine: Record "Gen. Journal Line"; PreviousDocumentNo: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ChequeNo: Code[20];
    begin
        if not GeneralLedgerSetup.Get() then
            exit;

        if not GeneralLedgerSetup."Activate Cheque No." then
            exit;

        ChequeNo := GenJnlLine."Document No.";
        GenJnlLine."Document No." := PreviousDocumentNo;
        GenJnlLine."Cheque No." := CopyStr(ChequeNo, 1, 10);
        GenJnlLine."Cheque Date" := GenJnlLine."Posting Date";
    end;
}
