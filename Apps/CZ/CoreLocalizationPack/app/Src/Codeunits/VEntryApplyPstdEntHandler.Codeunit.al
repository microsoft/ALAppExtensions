// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Payables;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;

codeunit 31137 "VEntryApplyPstdEnt Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnBeforePostApplyVendLedgEntry', '', false, false)]
    local procedure UpdateVATDateOnBeforePostApplyVendLedgEntry(var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
#pragma warning restore AL0432
#endif
        GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnBeforePostUnapplyVendLedgEntry', '', false, false)]
    local procedure UpdateVATDateOnBeforePostUnapplyVendLedgEntry(var GenJournalLine: Record "Gen. Journal Line"; VendorLedgerEntry: Record "Vendor Ledger Entry"; DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
#pragma warning restore AL0432
#endif
        GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Reporting Date";
    end;
}