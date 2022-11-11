codeunit 31448 "Gen. Journal Batch Handler CZL"
{
    Access = Internal;

#if not CLEAN21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeCheckCorrection', '', false, false)]
    local procedure AllowHybridDocumentOnBeforeCheckCorrection(var GenJnlBatch: Record "Gen. Journal Batch"; var CheckCorrection: Boolean)
    begin
        if not GenJnlBatch."Allow Hybrid Document CZL" then
            exit;

        CheckCorrection := false;
    end;
#else
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
#endif
}