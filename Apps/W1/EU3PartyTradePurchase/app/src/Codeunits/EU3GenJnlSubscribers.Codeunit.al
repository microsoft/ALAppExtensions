
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Document;

codeunit 4883 "EU3 Gen. Jnl. Subscribers"
{
    Access = Internal;
    Permissions = tabledata "Purchase Header" = r,
                  tabledata "Gen. Journal Line" = rm;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure OnAfterCopyGenJnlLineFromPurchHeader(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line")
    var
    begin
        GenJournalLine."EU 3-Party Trade" := PurchaseHeader."EU 3 Party Trade";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeaderPrepmt', '', false, false)]
    local procedure OnAfterCopyGenJnlLineFromPurchHeaderPrepmt(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line")
    var
    begin
        GenJournalLine."EU 3-Party Trade" := PurchaseHeader."EU 3 Party Trade";
    end;
}
