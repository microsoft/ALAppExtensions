codeunit 31319 "Whse. Journal Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Warehouse Journal Line", 'OnBeforeOpenJnl', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenJnl(var WarehouseJournalLine: Record "Warehouse Journal Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := WarehouseJournalLine.GetRangeMax("Journal Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"Whse. Journal";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);
    end;
}