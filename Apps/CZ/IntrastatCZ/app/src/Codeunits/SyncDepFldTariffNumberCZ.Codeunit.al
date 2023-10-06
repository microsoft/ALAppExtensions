#if not CLEAN22
#pragma warning disable AL0432
codeunit 31296 "Sync.Dep.Fld-TariffNumber CZ"
{
    Access = Internal;
    Permissions = tabledata "Tariff Number" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Tariff Number", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertTariffNumber(var Rec: Record "Tariff Number")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tariff Number", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyTariffNumber(var Rec: Record "Tariff Number")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Tariff Number")
    var
        PreviousRecord: Record "Tariff Number";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        DepFieldTxt := Rec."Suppl. Unit of Meas. Code CZL";
        NewFieldTxt := Rec."Suppl. Unit of Measure";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Suppl. Unit of Meas. Code CZL", PreviousRecord."Suppl. Unit of Measure");
        Rec."Suppl. Unit of Meas. Code CZL" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Suppl. Unit of Meas. Code CZL"));
        Rec."Suppl. Unit of Measure" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Suppl. Unit of Measure"));
    end;
}
#endif