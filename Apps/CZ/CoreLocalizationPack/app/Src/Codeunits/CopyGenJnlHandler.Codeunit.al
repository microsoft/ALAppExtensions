codeunit 31063 "Copy Gen. Jnl. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Gen. Journal Mgt.", 'OnAfterInsertGenJournalLine', '', false, false)]
    local procedure ReplaceVATDateOnAfterInsertGenJournalLine(PostedGenJournalLine: Record "Posted Gen. Journal Line"; CopyGenJournalParameters: Record "Copy Gen. Journal Parameters"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        if CopyGenJournalParameters."Replace VAT Date CZL" <> 0D then begin
            GenJournalLine."VAT Date CZL" := CopyGenJournalParameters."Replace VAT Date CZL";
            GenJournalLine.Modify();
        end
    end;
}