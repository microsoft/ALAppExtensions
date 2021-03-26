codeunit 31317 "FA Jnl. Check Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure UserChecksAllowedOnAfterCheckGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckGeneralJournalLine(GenJnlLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Journal Line", 'OnCheckFAJournalLineUserRestrictions', '', false, false)]
    local procedure CheckFAJournalTemplateUserRestrictions(JournalTemplateName: Code[10])
    var
        DummyUserSetupLineCZL: Record "User Setup Line CZL";
    begin
        UserSetupAdvManagementCZL.CheckJournalTemplate(DummyUserSetupLineCZL.Type::"FA Journal", JournalTemplateName);
    end;


    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
}