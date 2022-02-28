#if not CLEAN18
#pragma warning disable AL0432,AA0072
codeunit 31300 "Sync.Dep.Fld-Deprec. Book CZF"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Book", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertFixedAsset(var Rec: Record "Depreciation Book")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Book", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyFixedAsset(var Rec: Record "Depreciation Book")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Depreciation Book")
    var
        PreviousRecord: Record "Depreciation Book";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Acqui.,Appr.before Depr. Check", Rec."Check Acq. Appr. bef. Dep. CZF", PreviousRecord."Acqui.,Appr.before Depr. Check", PreviousRecord."Check Acq. Appr. bef. Dep. CZF");
        SyncDepFldUtilities.SyncFields(Rec."All Acquil. in same Year", Rec."All Acquisit. in same Year CZF", PreviousRecord."All Acquil. in same Year", PreviousRecord."All Acquisit. in same Year CZF");
        SyncDepFldUtilities.SyncFields(Rec."Check Deprication on Disposal", Rec."Check Deprec. on Disposal CZF", PreviousRecord."Check Deprication on Disposal", PreviousRecord."Check Deprec. on Disposal CZF");
        SyncDepFldUtilities.SyncFields(Rec."Deprication from 1st Year Day", Rec."Deprec. from 1st Year Day CZF", PreviousRecord."Deprication from 1st Year Day", PreviousRecord."Deprec. from 1st Year Day CZF");
        SyncDepFldUtilities.SyncFields(Rec."Deprication from 1st Month Day", Rec."Deprec. from 1st Month Day CZF", PreviousRecord."Deprication from 1st Month Day", PreviousRecord."Deprec. from 1st Month Day CZF");

        SyncDepFldUtilities.SyncFields(Rec."Corresp. G/L Entries on Disp.", Rec."Corresp. G/L Entries Disp. CZF", PreviousRecord."Corresp. G/L Entries on Disp.", PreviousRecord."Corresp. G/L Entries Disp. CZF");
        SyncDepFldUtilities.SyncFields(Rec."Corresp. FA Entries on Disp.", Rec."Corresp. FA Entries Disp. CZF", PreviousRecord."Corresp. FA Entries on Disp.", PreviousRecord."Corresp. FA Entries Disp. CZF");
    end;
}
#endif
