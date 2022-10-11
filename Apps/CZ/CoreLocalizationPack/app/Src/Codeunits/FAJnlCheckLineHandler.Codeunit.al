codeunit 31317 "FA Jnl. Check Line Handler CZL"
{
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure UserChecksAllowedOnAfterCheckGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckGeneralJournalLine(GenJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::FAJnlManagement, 'OnBeforeOpenJournal', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenJournal(var FAJournalLine: Record "FA Journal Line")
    var
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := FAJournalLine.GetRangeMax("Journal Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"FA Journal";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);
    end;

    // temporary subscriber until correction of "FA Posting Type" in "Invoice Posting Buffer"
    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterCopyToGenJnlLineFA', '', false, false)]
    local procedure CopyCustom2OnAfterCopyToGenJnlLineFA(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostingBuffer: Record "Invoice Posting Buffer")
    begin
        if InvoicePostingBuffer."FA Posting Type".AsInteger() = 3 then
            GenJnlLine."FA Posting Type" := GenJnlLine."FA Posting Type"::"Custom 2";
    end;
}
