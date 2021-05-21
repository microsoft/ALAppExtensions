#if not CLEAN17
#pragma warning disable AL0432
codeunit 31148 "Sync.Dep.Fld-Resource CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertInvtSetup(var Rec: Record Resource)
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyInvtSetup(var Rec: Record Resource)
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record Resource)
    var
        PreviousRecord: Record Resource;
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Tariff No.";
        NewFieldTxt := Rec."Tariff No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Tariff No.", PreviousRecord."Tariff No. CZL");
        Rec."Tariff No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Tariff No."));
        Rec."Tariff No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Tariff No. CZL"));
    end;
}
#endif