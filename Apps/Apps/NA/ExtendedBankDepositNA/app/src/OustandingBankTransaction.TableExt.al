// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Deposit;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.Ledger;
tableextension 10154 "Oustanding Bank Transaction" extends "Outstanding Bank Transaction"
{
    internal procedure CreateBankDepositHeaderLine(var TempOutstandingBankTransaction: Record "Outstanding Bank Transaction" temporary; var TempOutstandingBankTransactionCopy: Record "Outstanding Bank Transaction" temporary; BankAccountLedgerEntry: Record "Bank Account Ledger Entry")
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
    begin
        PostedBankDepositLine.SetRange("Document Type", BankAccountLedgerEntry."Document Type");
        PostedBankDepositLine.SetRange("Document No.", BankAccountLedgerEntry."Document No.");
        if PostedBankDepositLine.FindFirst() then begin
            PostedBankDepositHeader.Get(PostedBankDepositLine."Bank Deposit No.");
            TempOutstandingBankTransaction.Init();
            TempOutstandingBankTransactionCopy.SetRange("External Document No.", BankAccountLedgerEntry."External Document No.");
            if not TempOutstandingBankTransactionCopy.FindFirst() then begin
                TempOutstandingBankTransaction."Posting Date" := PostedBankDepositHeader."Posting Date";
                TempOutstandingBankTransaction."Document No." := PostedBankDepositHeader."No.";
                TempOutstandingBankTransaction."Document Type" := TempOutstandingBankTransaction."Document Type"::Deposit;
                TempOutstandingBankTransaction."Bank Account No." := PostedBankDepositHeader."Bank Account No.";
                TempOutstandingBankTransaction.Description := PostedBankDepositHeader."Posting Description";
                TempOutstandingBankTransaction.Amount := PostedBankDepositHeader."Total Deposit Amount";
                TempOutstandingBankTransaction.Indentation := 0;
                TempOutstandingBankTransaction."Entry No." := 0;
                TempOutstandingBankTransaction."External Document No." := BankAccountLedgerEntry."External Document No.";
                TempOutstandingBankTransaction.Insert();
                TempOutstandingBankTransactionCopy.Copy(TempOutstandingBankTransaction);
                TempOutstandingBankTransactionCopy.Insert();
            end;
            TempOutstandingBankTransaction.Indentation := 1;
        end else
            TempOutstandingBankTransaction.Indentation := 0;
    end;

}