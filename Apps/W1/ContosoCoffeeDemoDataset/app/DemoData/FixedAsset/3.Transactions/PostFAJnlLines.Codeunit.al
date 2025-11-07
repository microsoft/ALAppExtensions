// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 5214 "Post FA Jnl. Lines"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    var
        GenJournalLine: Record "Gen. Journal Line";
        CreateFAJnlTemplate: Codeunit "Create FA Jnl. Template";
        FAJournalTemplateName: Code[10];
        FAJournalBatchName: Code[10];
    begin
        FAJournalTemplateName := CreateFAJnlTemplate.Assets();
        FAJournalBatchName := CreateFAJnlTemplate.Default();

        GenJournalLine.SetRange("Journal Template Name", FAJournalTemplateName);
        GenJournalLine.SetRange("Journal Batch Name", FAJournalBatchName);
        if GenJournalLine.FindFirst() then begin
            BindSubscription(this);
            Codeunit.Run(Codeunit::"Gen. Jnl.-Post", GenJournalLine);
            UnbindSubscription(this);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", OnCodeOnBeforeConfirmPostJournalLinesResponse, '', true, true)]
    local procedure ConfirmPostJournalLinesResponse(var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean; var ShouldExit: Boolean)
    begin
        IsHandled := true;
    end;
}