#if not CLEAN19
#pragma warning disable AL0432
codeunit 31192 "Sync.Dep.Fld-SrcCodeSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Source Code Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertUserSetup(var Rec: Record "Source Code Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Source Code Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyUserSetup(var Rec: Record "Source Code Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Source Code Setup")
    var
        PreviousRecord: Record "Source Code Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

#if not CLEAN17
        DepFieldTxt := Rec."Sales VAT Delay";
        NewFieldTxt := Rec."Sales VAT Delay CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Sales VAT Delay", PreviousRecord."Sales VAT Delay CZL");
        Rec."Sales VAT Delay" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Sales VAT Delay"));
        Rec."Sales VAT Delay CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Sales VAT Delay CZL"));
        DepFieldTxt := Rec."Purchase VAT Delay";
        NewFieldTxt := Rec."Purchase VAT Delay CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Purchase VAT Delay", PreviousRecord."Purchase VAT Delay CZL");
        Rec."Purchase VAT Delay" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Purchase VAT Delay"));
        Rec."Purchase VAT Delay CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Purchase VAT Delay CZL"));
#endif
        DepFieldTxt := Rec."Close Balance Sheet";
        NewFieldTxt := Rec."Close Balance Sheet CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Close Balance Sheet", PreviousRecord."Close Balance Sheet CZL");
        Rec."Close Balance Sheet" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Close Balance Sheet"));
        Rec."Close Balance Sheet CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Close Balance Sheet CZL"));
        DepFieldTxt := Rec."Open Balance Sheet";
        NewFieldTxt := Rec."Open Balance Sheet CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Open Balance Sheet", PreviousRecord."Open Balance Sheet CZL");
        Rec."Open Balance Sheet" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Open Balance Sheet"));
        Rec."Open Balance Sheet CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Open Balance Sheet CZL"));
    end;
}
#endif