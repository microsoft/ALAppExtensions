#if not CLEAN19
#pragma warning disable AL0432,AL0603
codeunit 31189 "Sync.Dep.Fld-AccSchedLine CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '19.0';

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGLAccount(var Rec: Record "Acc. Schedule Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGLAccount(var Rec: Record "Acc. Schedule Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Acc. Schedule Line")
    var
        PreviousRecord: Record "Acc. Schedule Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldInt, NewFieldInt : Integer;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        DepFieldInt := Rec."Source Table";
        NewFieldInt := Rec."Source Table CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Source Table", PreviousRecord."Source Table CZL".AsInteger());
        Rec."Source Table" := DepFieldInt;
        Rec."Source Table CZL" := NewFieldInt;
    end;
}
#endif