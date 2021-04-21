codeunit 31312 "Job Jnl.Check Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Jnl.-Check Line", 'OnAfterRunCheck', '', false, false)]
    local procedure UserChecksAllowedOnAfterRunCheck(var JobJnlLine: Record "Job Journal Line")
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckJobJournalLine(JobJnlLine);
    end;

    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
}