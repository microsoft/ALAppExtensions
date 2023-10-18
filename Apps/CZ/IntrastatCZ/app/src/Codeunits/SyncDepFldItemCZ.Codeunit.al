#if not CLEAN22
#pragma warning disable AL0432
codeunit 31280 "Sync.Dep.Fld-Item CZ"
{
    Access = Internal;
    Permissions = tabledata Item = rimd;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertItem(var Rec: Record Item)
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyItem(var Rec: Record Item)
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record Item)
    var
        PreviousRecord: Record Item;
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
        DepFieldTxt := Rec."Specific Movement CZL";
        NewFieldTxt := Rec."Specific Movement CZ";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Specific Movement CZL", PreviousRecord."Specific Movement CZ");
        Rec."Specific Movement CZL" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Specific Movement CZL"));
        Rec."Specific Movement CZ" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Specific Movement CZ"));
    end;
}
#endif