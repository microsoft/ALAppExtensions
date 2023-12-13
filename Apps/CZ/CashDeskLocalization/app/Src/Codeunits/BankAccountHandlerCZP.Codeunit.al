// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.Currency;

#pragma warning disable AL0432
codeunit 11793 "Bank Account Handler CZP"
{
    var
        CashDeskSingleInstanceCZP: Codeunit "Cash Desk Single Instance CZP";

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameBankAccount(var Rec: Record "Bank Account"; RunTrigger: Boolean)
    begin
        CashDeskChangeAction(Rec, RunTrigger);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertBankAccount(var Rec: Record "Bank Account"; RunTrigger: Boolean)
    begin
        CashDeskChangeAction(Rec, RunTrigger);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyBankAccount(var Rec: Record "Bank Account"; RunTrigger: Boolean)
    begin
        CashDeskChangeAction(Rec, RunTrigger);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteBankAccount(var Rec: Record "Bank Account"; RunTrigger: Boolean)
    begin
        CashDeskChangeAction(Rec, RunTrigger);
    end;

    local procedure CashDeskChangeAction(var BankAccount: Record "Bank Account"; RunTrigger: Boolean)
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        if NavApp.IsInstalling() then
            exit;
        if BankAccount.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccount."No.");
        if BankAccountLedgerEntry.IsEmpty() then
            exit;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Adjust Exchange Rates CZL", 'OnBeforeOnInitReport', '', false, false)]
    local procedure ShowCashDesksOnBeforeOnInitReport()
    begin
        CashDeskSingleInstanceCZP.SetShowAllBankAccountType(true);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Adjust Exchange Rates CZL", 'OnCloseRequestPage', '', false, false)]
    local procedure HideCashDesksOnCloseRequestPage()
    begin
        CashDeskSingleInstanceCZP.SetShowAllBankAccountType(false);
    end;
}
