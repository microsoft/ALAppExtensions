// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

codeunit 31156 "Pstd.Gen.Jnl.Line Handler CZL"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Posted Gen. Journal Line", 'OnAfterInsertFromGenJournalLine', '', false, false)]
    local procedure UpdateVATDateOnAfterInsertFromGenJournalLine(GenJournalLine: Record "Gen. Journal Line"; sender: Record "Posted Gen. Journal Line")
    begin
        sender."VAT Date CZL" := GenJournalLine."VAT Reporting Date";
        sender.Modify();
    end;
}