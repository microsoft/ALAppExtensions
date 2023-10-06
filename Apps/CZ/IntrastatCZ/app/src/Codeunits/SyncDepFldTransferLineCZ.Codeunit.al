#if not CLEAN22
#pragma warning disable AL0432
codeunit 31289 "Sync.Dep.Fld-Transfer Line CZ"
{
    Access = Internal;
    Permissions = tabledata "Transfer Line" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertTransferLine(var Rec: Record "Transfer Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyTransferLine(var Rec: Record "Transfer Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Transfer Line")
    var
        PreviousRecord: Record "Transfer Line";
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