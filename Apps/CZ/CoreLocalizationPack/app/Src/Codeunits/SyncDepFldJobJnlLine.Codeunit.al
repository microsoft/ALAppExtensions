#pragma warning disable AL0432
codeunit 31169 "Sync.Dep.Fld-JobJnlLine CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertJobJnlLine(var Rec: Record "Job Journal Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyJobJnlLine(var Rec: Record "Job Journal Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Job Journal Line")
    var
        PreviousRecord: Record "Job Journal Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Whse. Net Change Template";
        NewFieldTxt := Rec."Invt. Movement Template CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Whse. Net Change Template", PreviousRecord."Invt. Movement Template CZL");
        Rec."Whse. Net Change Template" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Whse. Net Change Template"));
        Rec."Invt. Movement Template CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Invt. Movement Template CZL"));
    end;
}
