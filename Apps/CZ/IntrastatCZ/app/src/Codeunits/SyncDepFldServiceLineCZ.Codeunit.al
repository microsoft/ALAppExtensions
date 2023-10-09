#if not CLEAN22
#pragma warning disable AL0432
codeunit 31288 "Sync.Dep.Fld-Service Line CZ"
{
    Access = Internal;
    Permissions = tabledata "Service Line" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertServiceLine(var Rec: Record "Service Line")
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
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        DepFieldTxt := Rec."Statistic Indication CZL";
        NewFieldTxt := Rec."Statistic Indication CZ";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Statistic Indication CZL", PreviousRecord."Statistic Indication CZ");
        Rec."Statistic Indication CZL" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Statistic Indication CZL"));
        Rec."Statistic Indication CZ" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Statistic Indication CZ"));
        SyncDepFldUtilities.SyncFields(Rec."Physical Transfer CZL", Rec."Physical Transfer CZ", PreviousRecord."Physical Transfer CZL", PreviousRecord."Physical Transfer CZ");
    end;
}
#endif