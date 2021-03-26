codeunit 31314 "Ins. Jnl.CheckLine Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Insurance Jnl.-Check Line", 'OnRunCheckOnBeforeCheckDimIDComb', '', false, false)]
    local procedure UserChecksAllowedOnRunCheckOnBeforeCheckDimIDComb(var InsuranceJnlLine: Record "Insurance Journal Line")
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckInsuranceJournalLine(InsuranceJnlLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Insurance Journal Line", 'OnCheckInsuranceJournalTemplateUserRestrictions', '', false, false)]
    local procedure CheckInsuranceJournallTemplateUserRestrictions(JournalTemplateName: Code[10])
    var
        DummyUserSetupLineCZL: Record "User Setup Line CZL";
    begin
        UserSetupAdvManagementCZL.CheckJournalTemplate(DummyUserSetupLineCZL.Type::"Insurance Journal", JournalTemplateName);
    end;

    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
}