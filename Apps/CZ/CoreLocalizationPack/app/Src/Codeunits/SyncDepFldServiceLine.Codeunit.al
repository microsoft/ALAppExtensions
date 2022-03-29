#if not CLEAN18
#pragma warning disable AL0432
codeunit 31147 "Sync.Dep.Fld-ServiceLine CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertServiceLIne(var Rec: Record "Service Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyServiceLine(var Rec: Record "Service Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Service Line")
    var
        PreviousRecord: Record "Service Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Physical Transfer", Rec."Physical Transfer CZL", PreviousRecord."Physical Transfer", PreviousRecord."Physical Transfer CZL");
        DepFieldTxt := Rec."Country/Region of Origin Code";
        NewFieldTxt := Rec."Country/Reg. of Orig. Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Country/Region of Origin Code", PreviousRecord."Country/Reg. of Orig. Code CZL");
        Rec."Country/Region of Origin Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Country/Region of Origin Code"));
        Rec."Country/Reg. of Orig. Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Country/Reg. of Orig. Code CZL"));
    end;
}
#endif