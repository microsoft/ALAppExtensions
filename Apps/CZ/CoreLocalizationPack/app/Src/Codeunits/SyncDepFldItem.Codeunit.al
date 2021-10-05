#if not CLEAN18
#pragma warning disable AL0432
codeunit 31199 "Sync.Dep.Fld-Item CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertInvtSetup(var Rec: Record Item)
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyInvtSetup(var Rec: Record Item)
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
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

#if not CLEAN17
        DepFieldTxt := Rec."Statistic Indication";
        NewFieldTxt := Rec."Statistic Indication CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Statistic Indication", PreviousRecord."Statistic Indication CZL");
        Rec."Statistic Indication" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Statistic Indication"));
        Rec."Statistic Indication CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Statistic Indication CZL"));
#endif
        DepFieldTxt := Rec."Specific Movement";
        NewFieldTxt := Rec."Specific Movement CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Specific Movement", PreviousRecord."Specific Movement CZL");
        Rec."Specific Movement" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Specific Movement"));
        Rec."Specific Movement CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Specific Movement CZL"));
    end;
}
#endif