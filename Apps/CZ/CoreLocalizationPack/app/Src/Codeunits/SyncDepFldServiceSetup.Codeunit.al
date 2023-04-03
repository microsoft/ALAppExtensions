#if not CLEAN22
#pragma warning disable AL0432
codeunit 31165 "Sync.Dep.Fld-ServiceSetup CZL"
{
    Access = Internal;
    Permissions = tabledata "Service Mgt. Setup" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Service Mgt. Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertServiceMgtSetup(var Rec: Record "Service Mgt. Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Mgt. Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyServiceMgtSetup(var Rec: Record "Service Mgt. Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Service Mgt. Setup")
    var
        PreviousRecord: Record "Service Mgt. Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        SyncDepFldUtilities.SyncFields(Rec."Allow Alter Posting Groups CZL", Rec."Allow Multiple Posting Groups", PreviousRecord."Allow Alter Posting Groups CZL", PreviousRecord."Allow Multiple Posting Groups");
    end;
}
#endif