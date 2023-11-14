// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.Ledger;

codeunit 31367 "FA Ledger Entry Handler CZF"
{
    [EventSubscriber(ObjectType::Table, Database::"FA Ledger Entry", 'OnAfterMoveToGenJnlLine', '', false, false)]
    local procedure OnAfterMoveToGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; FALedgerEntry: Record "FA Ledger Entry")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := FALedgerEntry."Posting Date";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := FALedgerEntry."Posting Date";
    end;
}
