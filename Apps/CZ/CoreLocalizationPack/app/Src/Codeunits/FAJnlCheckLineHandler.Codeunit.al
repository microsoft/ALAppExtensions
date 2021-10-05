codeunit 31317 "FA Jnl. Check Line Handler CZL"
{
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


    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
}