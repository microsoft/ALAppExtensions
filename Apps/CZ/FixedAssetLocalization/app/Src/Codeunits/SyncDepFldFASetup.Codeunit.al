#if not CLEAN18
#pragma warning disable AL0432,AA0072
codeunit 31298 "Sync.Dep.Fld-FA Setup CZF"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"FA Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertFASetup(var Rec: Record "FA Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyFASetup(var Rec: Record "FA Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "FA Setup")
    var
        PreviousRecord: Record "FA Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Tax Depr. Book";
        NewFieldTxt := Rec."Tax Depreciation Book CZF";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Tax Depr. Book", PreviousRecord."Tax Depreciation Book CZF");
        Rec."Tax Depr. Book" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Tax Depr. Book"));
        Rec."Tax Depreciation Book CZF" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Tax Depreciation Book CZF"));
        SyncDepFldUtilities.SyncFields(Rec."FA Acquisition As Custom 2", Rec."FA Acquisition As Custom 2 CZF", PreviousRecord."FA Acquisition As Custom 2", PreviousRecord."FA Acquisition As Custom 2 CZF");
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Setup", 'OnAfterValidateEvent', 'Fixed Asset History', false, false)]
    local procedure SyncOnAfterValidateFixedAssetHistory(var Rec: Record "FA Setup")
    begin
        if Rec."Fixed Asset History" then
            Rec."Fixed Asset History CZF" := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Setup", 'OnAfterValidateEvent', 'Fixed Asset History CZF', false, false)]
    local procedure SyncOnAfterValidateFixedAssetHistoryCZF(var Rec: Record "FA Setup")
    begin
        if Rec."Fixed Asset History CZF" then
            Rec."Fixed Asset History" := false;
    end;
}
#endif
