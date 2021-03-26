codeunit 31320 "Whse. Worksht.Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Whse. Worksheet Line", 'OnCheckWhseWorksheetTemplateUserRestrictions', '', false, false)]
    local procedure CheckWhseWorksheetTemplateUserRestrictions(WorksheetTemplateName: Code[10])
    var
        DummyUserSetupLineCZL: Record "User Setup Line CZL";
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        UserSetupAdvManagementCZL.CheckJournalTemplate(DummyUserSetupLineCZL.Type::"Whse. Worksheet", WorksheetTemplateName);
    end;
}