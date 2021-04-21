codeunit 31316 "Gen.Jnl.Check Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure UserChecksAllowedOnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() and (not GenJournalLine."From Adjustment CZL") then
            UserSetupAdvManagementCZL.CheckGeneralJournalLine(GenJournalLine);
    end;
}