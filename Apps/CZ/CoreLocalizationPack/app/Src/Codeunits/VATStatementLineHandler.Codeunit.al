codeunit 31322 "VAT Statement Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnCheckVATStmtTemplateUserRestrictions', '', false, false)]
    local procedure CheckVATStmtTemplateUserRestrictions(StatementTemplateName: Code[10])
    var
        DummyUserSetupLineCZL: Record "User Setup Line CZL";
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        UserSetupAdvManagementCZL.CheckJournalTemplate(DummyUserSetupLineCZL.Type::"VAT Statement", StatementTemplateName);
    end;
}