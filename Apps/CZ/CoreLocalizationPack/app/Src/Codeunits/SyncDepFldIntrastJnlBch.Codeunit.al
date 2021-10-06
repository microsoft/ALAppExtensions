#if not CLEAN18
#pragma warning disable AL0432
codeunit 31222 "Sync.Dep.Fld-IntrastJnlBch CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Batch", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertIntrastatJnlBatch(var Rec: Record "Intrastat Jnl. Batch")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Batch", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyIntrastatJnlBatch(var Rec: Record "Intrastat Jnl. Batch")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Intrastat Jnl. Batch")
    var
        PreviousRecord: Record "Intrastat Jnl. Batch";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldInt, NewFieldInt : Integer;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Declaration No.";
        NewFieldTxt := Rec."Declaration No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Declaration No.", PreviousRecord."Declaration No. CZL");
        Rec."Declaration No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Declaration No."));
        Rec."Declaration No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Declaration No. CZL"));
        DepFieldInt := Rec."Statement Type";
        NewFieldInt := Rec."Statement Type CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Statement Type", PreviousRecord."Statement Type CZL".AsInteger());
        Rec."Statement Type" := DepFieldInt;
        Rec."Statement Type CZL" := "Intrastat Statement Type CZL".FromInteger(NewFieldInt);
    end;
}
#endif