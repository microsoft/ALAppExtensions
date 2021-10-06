codeunit 31323 "FA Recl. Jnl. Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::FAReclassJnlManagement, 'OnBeforeOpenJournal', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenJournal(var FAReclassJournalLine: Record "FA Reclass. Journal Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := FAReclassJournalLine.GetRangeMax("Journal Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"FA Reclass. Journal";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);
    end;
}