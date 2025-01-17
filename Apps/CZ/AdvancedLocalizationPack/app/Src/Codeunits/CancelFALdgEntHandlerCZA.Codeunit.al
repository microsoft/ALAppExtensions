// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Ledger;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31439 "Cancel FA Ldg.Ent. Handler CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cancel FA Ledger Entries", 'OnBeforeGenJnlLineInsert', '', false, false)]
    local procedure OnBeforeGenJnlLineInsert(var GenJournalLine: Record "Gen. Journal Line"; FALedgerEntry: Record "FA Ledger Entry")
    begin
        GenJournalLine."Reason Code" := FALedgerEntry."Reason Code";
    end;
}
