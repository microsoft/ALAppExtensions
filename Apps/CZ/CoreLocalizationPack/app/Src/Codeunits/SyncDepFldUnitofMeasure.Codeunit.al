#if not CLEAN18
#pragma warning disable AL0432
codeunit 31215 "Sync.Dep.Fld-UnitofMeasure CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Unit of Measure", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertUnitofMeasure(var Rec: Record "Unit of Measure")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unit of Measure", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyUnitofMeasure(var Rec: Record "Unit of Measure")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Unit of Measure")
    var
        PreviousRecord: Record "Unit of Measure";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Tariff Number UOM Code";
        NewFieldTxt := Rec."Tariff Number UOM Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Tariff Number UOM Code", PreviousRecord."Tariff Number UOM Code CZL");
        Rec."Tariff Number UOM Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Tariff Number UOM Code"));
        Rec."Tariff Number UOM Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Tariff Number UOM Code CZL"));
    end;
}
#endif