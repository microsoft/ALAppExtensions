// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Reversal;

codeunit 30311 "Shpfy Suggest Payments"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitCustLedgEntry', '', false, false)]
    local procedure TransferTransactionIdOnAfterInitCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."Shpfy Transaction Id" := GenJournalLine."Shpfy Transaction Id";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Reverse", 'OnReverseCustLedgEntryOnBeforeModifyCustLedgerEntry', '', false, false)]
    local procedure ResetTransactionIdOnReverseCustLedgEntryOnBeforeModifyCustLedgerEntry(NewCustLedgerEntry: Record "Cust. Ledger Entry"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry."Shpfy Transaction Id" := 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Reverse", 'OnReverseCustLedgEntryOnBeforeInsertCustLedgEntry', '', false, false)]
    local procedure ResetTransactionIdOnReverseCustLedgEntryOnBeforeInsertCustLedgEntry(var NewCustLedgerEntry: Record "Cust. Ledger Entry"; CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        NewCustLedgerEntry."Shpfy Transaction Id" := 0;
    end;
}