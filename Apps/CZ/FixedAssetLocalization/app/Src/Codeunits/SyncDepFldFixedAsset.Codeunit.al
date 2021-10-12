#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31297 "Sync.Dep.Fld-Fixed Asset CZF"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Fixed Asset", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertFixedAsset(var Rec: Record "Fixed Asset")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Fixed Asset", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyFixedAsset(var Rec: Record "Fixed Asset")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Fixed Asset")
    var
        PreviousRecord: Record "Fixed Asset";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Clasification Code";
        NewFieldTxt := Rec."Classification Code CZF";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Clasification Code", PreviousRecord."Classification Code CZF");
        Rec."Clasification Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Clasification Code"));
        Rec."Classification Code CZF" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Classification Code CZF"));
        DepFieldTxt := Rec."Tax Depreciation Group Code";
        NewFieldTxt := Rec."Tax Deprec. Group Code CZF";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Tax Depreciation Group Code", PreviousRecord."Tax Deprec. Group Code CZF");
        Rec."Tax Depreciation Group Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Tax Depreciation Group Code"));
        Rec."Tax Deprec. Group Code CZF" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Tax Deprec. Group Code CZF"));
    end;
}
#endif