codeunit 31329 "Gen. Jnl. Template Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnBeforeValidateEvent', 'Force Doc. Balance', false, false)]
    local procedure TestNotCheckDocTypeCZLOnBeforeValidateForceDocBalance(var Rec: Record "Gen. Journal Template")
    begin
        if not Rec."Force Doc. Balance" then
            Rec.TestField("Not Check Doc. Type CZL", false);
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

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnGetDocumentBalanceOnBeforeCalcBalance', '', false, false)]
    local procedure TestNotCheckDocTypeCZLOnGetDocumentBalanceOnBeforeCalcBalance(var GenJournalLine: Record "Gen. Journal Line"; GenJnlTemplate: Record "Gen. Journal Template")
    begin
        if GenJnlTemplate."Not Check Doc. Type CZL" then
            GenJournalLine.SetRange("Document Type");
    end;
}