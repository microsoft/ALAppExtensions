codeunit 31308 "Res.Jnl.Check Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Res. Jnl.-Check Line", 'OnAfterRunCheck', '', false, false)]
    local procedure UserChecksAllowedOnAfterRunCheck(var ResJournalLine: Record "Res. Journal Line")
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckResJournalLine(ResJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Res. Journal Line", 'OnCheckResJournalTemplateUserRestrictions', '', false, false)]
    local procedure CheckResJournalTemplateUserRestrictions(JournalTemplateName: Code[10])
    var
        DummyUserSetupLineCZL: Record "User Setup Line CZL";
    begin
        UserSetupAdvManagementCZL.CheckJournalTemplate(DummyUserSetupLineCZL.Type::"Resource Journal", JournalTemplateName);
    end;

    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
}