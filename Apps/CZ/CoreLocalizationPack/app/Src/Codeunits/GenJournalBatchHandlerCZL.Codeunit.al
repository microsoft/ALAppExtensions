// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Posting;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31448 "Gen. Journal Batch Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeCheckCorrection', '', false, false)]
    local procedure AllowHybridDocumentOnBeforeCheckCorrection(GenJournalLine: Record "Gen. Journal Line"; var LastDate: Date; var LastDocType: Enum "Gen. Journal Document Type"; var LastDocNo: Code[20]; var IsHandled: Boolean)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        if (GenJournalLine."Posting Date" <> LastDate) or (GenJournalLine."Document Type" <> LastDocType) or (GenJournalLine."Document No." <> LastDocNo) then
            exit;

        GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        IsHandled := GenJournalBatch."Allow Hybrid Document CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeIfCheckBalance', '', false, false)]
    local procedure OnBeforeIfCheckBalance(GenJnlTemplate: Record "Gen. Journal Template"; GenJnlLine: Record "Gen. Journal Line"; var LastDocType: Option; var LastDocNo: Code[20]; var LastDate: Date; var CheckIfBalance: Boolean; CommitIsSuppressed: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        if CheckIfBalance then
            exit;
        if (GenJnlLine."Posting Date" <> LastDate) then
            exit;
        if not GenJnlTemplate."Force Doc. Balance" then
            exit;
        if ((GenJnlLine."Document Type" <> "Gen. Journal Document Type".FromInteger(LastDocType)) and (GenJnlTemplate."Not Check Doc. Type CZL")) then
            IsHandled := true;
    end;
}
