codeunit 31319 "Whse. Journal Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Warehouse Journal Line", 'OnCheckWhseJournalTemplateUserRestrictions', '', false, false)]
    local procedure CheckWhseJournalTemplateUserRestrictions(JournalTemplateName: Code[10])
    var
        DummyUserSetupLineCZL: Record "User Setup Line CZL";
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        UserSetupAdvManagementCZL.CheckJournalTemplate(DummyUserSetupLineCZL.Type::"Whse. Journal", JournalTemplateName);
    end;
}