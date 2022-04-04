#if not CLEAN18
#pragma warning disable AL0432, AL0603
codeunit 31165 "Sync.Dep.Fld-ServiceSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Service Mgt. Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertServiceSetup(var Rec: Record "Service Mgt. Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Mgt. Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyServiceSetup(var Rec: Record "Service Mgt. Setup")
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

        SyncDepFldUtilities.SyncFields(Rec."Allow Alter Cust. Post. Groups", Rec."Allow Alter Posting Groups CZL", PreviousRecord."Allow Alter Cust. Post. Groups", PreviousRecord."Allow Alter Posting Groups CZL");
    end;
}
#endif