#if not CLEAN19
#pragma warning disable AL0432
codeunit 31345 "Sync.Dep.Fld-UserSetup CZB"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertUserSetup(var Rec: Record "User Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyUserSetup(var Rec: Record "User Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var UserSetup: Record "User Setup")
    var
        PreviousUserSetup: Record "User Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(UserSetup, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousUserSetup);
        SyncDepFldUtilities.SyncFields(UserSetup."Check Payment Orders", UserSetup."Check Payment Orders CZB", PreviousUserSetup."Check Payment Orders", PreviousUserSetup."Check Payment Orders CZB");
        SyncDepFldUtilities.SyncFields(UserSetup."Check Bank Statements", UserSetup."Check Bank Statements CZB", PreviousUserSetup."Check Bank Statements", PreviousUserSetup."Check Bank Statements CZB");
        SyncDepFldUtilities.SyncFields(UserSetup."Bank Amount Approval Limit", UserSetup."Bank Amount Approval Limit CZB", PreviousUserSetup."Bank Amount Approval Limit", PreviousUserSetup."Bank Amount Approval Limit CZB");
        SyncDepFldUtilities.SyncFields(UserSetup."Unlimited Bank Approval", UserSetup."Unlimited Bank Approval CZB", PreviousUserSetup."Unlimited Bank Approval", PreviousUserSetup."Unlimited Bank Approval CZB");
    end;
}
#endif
