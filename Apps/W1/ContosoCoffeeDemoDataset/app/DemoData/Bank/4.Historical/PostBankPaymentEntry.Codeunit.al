// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.DemoData.Finance;

codeunit 5667 "Post Bank Payment Entry"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        GenJournalLine: Record "Gen. Journal Line";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateBankJnlBatch: Codeunit "Create Bank Jnl. Batches";
    begin
        GenJournalLine.SetRange("Journal Template Name", CreateGenJournalTemplate.General());
        GenJournalLine.SetRange("Journal Batch Name", CreateBankJnlBatch.Daily());
        if GenJournalLine.FindFirst() then
            CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJournalLine);
    end;
}
