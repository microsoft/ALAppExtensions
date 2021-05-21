codeunit 31324 "Job Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Job, 'OnBeforeChangeJobCompletionStatus', '', false, false)]
    local procedure CheckCompleteJobOnBeforeChangeJobCompletionStatus()
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckCompleteJob();
    end;

    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
}