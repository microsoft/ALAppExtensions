// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.DemoData.Finance;

codeunit 17163 "Create AU Gen. Journal Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateGeneralJournalLine();
    end;

    local procedure UpdateGeneralJournalLine()
    var
        GenJournalLine: Record "Gen. Journal Line";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateBankJnlBatch: Codeunit "Create Bank Jnl. Batches";
    begin
        GenJournalLine.SetRange("Journal Template Name", CreateGenJournalTemplate.General());
        GenJournalLine.SetRange("Journal Batch Name", CreateBankJnlBatch.Daily());
        if GenJournalLine.FindSet() then
            repeat
                case GenJournalLine."Line No." of
                    10000:
                        GenJournalLine.Validate(Amount, -5190.55);
                    20000:
                        GenJournalLine.Validate(Amount, -7785.82);
                    30000:
                        GenJournalLine.Validate(Amount, -10381.1);
                    40000:
                        GenJournalLine.Validate(Amount, -10381.1);
                end;

                GenJournalLine.Validate("Skip WHT", true);
                GenJournalLine.Modify();
            until GenJournalLine.Next() = 0;
    end;
}
