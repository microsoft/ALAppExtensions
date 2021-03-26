codeunit 31315 "Gen.Jnl. Post Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGlobalGLEntry', '', false, false)]
    local procedure UserChecksAllowedOnBeforeInsertGlobalGLEntry(var GlobalGLEntry: Record "G/L Entry")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckFiscalYear(GlobalGLEntry);
    end;
}