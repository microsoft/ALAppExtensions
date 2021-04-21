#if not CLEAN17
#pragma warning disable AL0432,AL0603
codeunit 31188 "Sync.Dep.Fld-AccSchedName CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Name", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGLAccount(var Rec: Record "Acc. Schedule Name")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Name", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGLAccount(var Rec: Record "Acc. Schedule Name")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Acc. Schedule Name")
    var
        PreviousRecord: Record "Acc. Schedule Name";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldInt, NewFieldInt : Integer;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldInt := Rec."Acc. Schedule Type";
        NewFieldInt := Rec."Acc. Schedule Type CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Acc. Schedule Type", PreviousRecord."Acc. Schedule Type CZL".AsInteger());
        Rec."Acc. Schedule Type" := DepFieldInt;
        Rec."Acc. Schedule Type CZL" := NewFieldInt;
    end;
}
#endif