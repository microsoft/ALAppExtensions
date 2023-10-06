#if not CLEAN22
#pragma warning disable AL0432
codeunit 31294 "Sync.Dep.Fld-DirectTransLineCZ"
{
    Access = Internal;
    Permissions = tabledata "Direct Trans. Line" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Direct Trans. Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertDirectTransLine(var Rec: Record "Direct Trans. Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Direct Trans. Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyDirectTransLine(var Rec: Record "Direct Trans. Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Direct Trans. Line")
    var
        PreviousRecord: Record "Direct Trans. Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        DepFieldTxt := Rec."Statistic Indication CZL";
        NewFieldTxt := Rec."Statistic Indication CZ";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Statistic Indication CZL", PreviousRecord."Statistic Indication CZ");
        Rec."Statistic Indication CZL" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Statistic Indication CZL"));
        Rec."Statistic Indication CZ" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Statistic Indication CZ"));
    end;
}
#endif