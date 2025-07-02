// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Deposit;
using Microsoft.Bank.Reports;
using Microsoft.Bank.Ledger;
using Microsoft.Bank.Reconciliation;
codeunit 10154 "Bank Recon. - Test Subscribers"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Report, Report::"Bank Acc. Recon. - Test", 'OnBeforeCopyFromBankAccLedgerEntryOnRemainingAmt', '', false, false)]
    local procedure OnBeforeCopyFromBankAccLedgerEntryOnRemainingAmt(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; var OutstandingBankTransaction: Record "Outstanding Bank Transaction"; var TempOutstandingBankTransaction: Record "Outstanding Bank Transaction" temporary)
    begin
        OutstandingBankTransaction.CreateBankDepositHeaderLine(OutstandingBankTransaction, TempOutstandingBankTransaction, BankAccountLedgerEntry);
    end;
}