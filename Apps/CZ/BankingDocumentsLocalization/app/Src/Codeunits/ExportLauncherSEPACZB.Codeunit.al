// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.DirectDebit;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31351 "Export Launcher SEPA CZB"
{
    TableNo = "Iss. Payment Order Header CZB";

    trigger OnRun()
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        IssPaymentOrderHeaderCZB.Copy(Rec);

        BankAccount.Get(IssPaymentOrderHeaderCZB."Bank Account No.");
        BankAccount.TestField("Pmt.Jnl. Templ. Name Order CZB");
        BankAccount.TestField("Pmt. Jnl. Batch Name Order CZB");

        GenJournalLine.SetRange("Journal Template Name", BankAccount."Pmt.Jnl. Templ. Name Order CZB");
        GenJournalLine.SetRange("Journal Batch Name", BankAccount."Pmt. Jnl. Batch Name Order CZB");
        GenJournalLine.SetRange("Document No.", IssPaymentOrderHeaderCZB."No.");
        if not GenJournalLine.IsEmpty() then
            GenJournalLine.DeleteAll(true);

        IssPaymentOrderHeaderCZB.CreatePaymentJournal(BankAccount."Pmt.Jnl. Templ. Name Order CZB", BankAccount."Pmt. Jnl. Batch Name Order CZB");

        GenJournalLine.FindFirst();
        Commit();

        if not Codeunit.Run(Codeunit::"SEPA CT-Export File", GenJournalLine) then begin
            Page.Run(Page::"Payment Journal", GenJournalLine);
            Error(GetLastErrorText);
        end;

        GenJournalLine.DeleteAll(true);
    end;
}
