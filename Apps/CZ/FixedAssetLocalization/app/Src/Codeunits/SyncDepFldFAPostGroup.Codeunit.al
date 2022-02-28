#if not CLEAN18
#pragma warning disable AL0432,AA0072
codeunit 31226 "Sync.Dep.Fld-FAPostGroup CZF"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertFAPostingGroup(var Rec: Record "FA Posting Group")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyFAPostingGroup(var Rec: Record "FA Posting Group")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "FA Posting Group")
    var
        PreviousRecord: Record "FA Posting Group";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Acq. Cost Bal. Acc. on Disp.";
        NewFieldTxt := Rec."Acq. Cost Bal. Acc. Disp. CZF";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Acq. Cost Bal. Acc. on Disp.", PreviousRecord."Acq. Cost Bal. Acc. Disp. CZF");
        Rec."Acq. Cost Bal. Acc. on Disp." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Acq. Cost Bal. Acc. on Disp."));
        Rec."Acq. Cost Bal. Acc. Disp. CZF" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Acq. Cost Bal. Acc. Disp. CZF"));
        DepFieldTxt := Rec."Book Value Bal. Acc. on Disp.";
        NewFieldTxt := Rec."Book Value Bal. Acc. Disp. CZF";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Book Value Bal. Acc. on Disp.", PreviousRecord."Book Value Bal. Acc. Disp. CZF");
        Rec."Book Value Bal. Acc. on Disp." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Book Value Bal. Acc. on Disp."));
        Rec."Book Value Bal. Acc. Disp. CZF" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Book Value Bal. Acc. Disp. CZF"));
    end;
}
#endif
