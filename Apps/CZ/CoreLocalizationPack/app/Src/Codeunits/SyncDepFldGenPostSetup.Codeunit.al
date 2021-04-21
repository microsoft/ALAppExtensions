#if not CLEAN18
#pragma warning disable AL0432
codeunit 31225 "Sync.Dep.Fld-GenPostSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"General Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGeneralPostingSetup(var Rec: Record "General Posting Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Posting Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGeneralPostingSetup(var Rec: Record "General Posting Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "General Posting Setup")
    var
        PreviousRecord: Record "General Posting Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Invt. Rounding Adj. Account";
        NewFieldTxt := Rec."Invt. Rounding Adj. Acc. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Invt. Rounding Adj. Account", PreviousRecord."Invt. Rounding Adj. Acc. CZL");
        Rec."Invt. Rounding Adj. Account" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Invt. Rounding Adj. Account"));
        Rec."Invt. Rounding Adj. Acc. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Invt. Rounding Adj. Acc. CZL"));
    end;
}
#endif