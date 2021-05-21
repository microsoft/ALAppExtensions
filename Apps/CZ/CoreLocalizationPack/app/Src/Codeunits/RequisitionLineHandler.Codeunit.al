codeunit 31321 "Requisition Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnCheckReqWorksheetTemplateUserRestrictions', '', false, false)]
    local procedure CheckReqJournalTemplateUserRestrictions(WorksheetTemplateName: Code[10])
    var
        DummyUserSetupLineCZL: Record "User Setup Line CZL";
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        UserSetupAdvManagementCZL.CheckJournalTemplate(DummyUserSetupLineCZL.Type::"Req. Worksheet", WorksheetTemplateName);
    end;
}