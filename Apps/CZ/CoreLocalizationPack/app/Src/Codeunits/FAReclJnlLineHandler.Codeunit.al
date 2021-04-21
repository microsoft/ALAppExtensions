codeunit 31323 "FA Recl. Jnl. Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"FA Reclass. Journal Line", 'OnCheckFAReclassJournalTemplateUserRestrictions', '', false, false)]
    local procedure CheckFAReclasJournallTemplateUserRestrictions(JournalTemplateName: Code[10])
    var
        DummyUserSetupLineCZL: Record "User Setup Line CZL";
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        UserSetupAdvManagementCZL.CheckJournalTemplate(DummyUserSetupLineCZL.Type::"FA Reclass. Journal", JournalTemplateName);
    end;
}