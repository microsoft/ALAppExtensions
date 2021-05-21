#if not CLEAN17
#pragma warning disable AL0432
codeunit 31145 "Sync.Dep.Fld-ServCrMLine CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Service Cr.Memo Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertServiceLIne(var Rec: Record "Service Cr.Memo Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Cr.Memo Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyServiceLine(var Rec: Record "Service Cr.Memo Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Service Cr.Memo Line")
    var
        PreviousRecord: Record "Service Cr.Memo Line";
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
        DepFieldTxt := Rec."Statistic Indication";
        NewFieldTxt := Rec."Statistic Indication CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Statistic Indication", PreviousRecord."Statistic Indication CZL");
        Rec."Statistic Indication" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Statistic Indication"));
        Rec."Statistic Indication CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Statistic Indication CZL"));
    end;
}
#endif