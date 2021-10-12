#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31296 "Sync.Dep.Fld-FA Depr.Book CZF"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertFADepreciationBook(var Rec: Record "FA Depreciation Book")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyFADepreciationBook(var Rec: Record "FA Depreciation Book")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "FA Depreciation Book")
    var
        PreviousRecord: Record "FA Depreciation Book";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Depreciation Interupt up to", Rec."Deprec. Interrupted up to CZF", PreviousRecord."Depreciation Interupt up to", PreviousRecord."Deprec. Interrupted up to CZF");
        DepFieldTxt := Rec."Depreciation Group Code";
        NewFieldTxt := Rec."Tax Deprec. Group Code CZF";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Depreciation Group Code", PreviousRecord."Tax Deprec. Group Code CZF");
        Rec."Depreciation Group Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Depreciation Group Code"));
        Rec."Tax Deprec. Group Code CZF" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Tax Deprec. Group Code CZF"));
        SyncDepFldUtilities.SyncFields(Rec."Keep Depr. Ending Date", Rec."Keep Deprec. Ending Date CZF", PreviousRecord."Keep Depr. Ending Date", PreviousRecord."Keep Deprec. Ending Date CZF");
        DepFieldTxt := Rec."Summarize Depr. Entries From";
        NewFieldTxt := Rec."Sum. Deprec. Entries From CZF";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Summarize Depr. Entries From", PreviousRecord."Sum. Deprec. Entries From CZF");
        Rec."Summarize Depr. Entries From" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Summarize Depr. Entries From"));
        Rec."Sum. Deprec. Entries From CZF" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Sum. Deprec. Entries From CZF"));
        SyncDepFldUtilities.SyncFields(Rec.Prorated, Rec."Prorated CZF", PreviousRecord.Prorated, PreviousRecord."Prorated CZF");
    end;
}
#endif