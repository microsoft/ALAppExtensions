codeunit 31313 "Item Jnl.CheckLine Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", 'OnAfterCheckItemJnlLine', '', false, false)]
    local procedure UserChecksAllowedOnAfterCheckItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean)
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() and not CalledFromAdjustment then
            UserSetupAdvManagementCZL.CheckItemJournalLine(ItemJnlLine);
    end;
}