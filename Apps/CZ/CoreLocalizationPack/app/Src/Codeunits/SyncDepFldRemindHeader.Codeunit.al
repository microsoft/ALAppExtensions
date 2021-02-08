#pragma warning disable AL0432
codeunit 31181 "Sync.Dep.Fld-RemindHeader CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Reminder Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertReminderHeader(var Rec: Record "Reminder Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reminder Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyReminderHeader(var Rec: Record "Reminder Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Reminder Header")
    var
        PreviousRecord: Record "Reminder Header";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Registration No.";
        NewFieldTxt := Rec."Registration No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Registration No.", PreviousRecord."Registration No. CZL");
        Rec."Registration No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Registration No."));
        Rec."Registration No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Registration No. CZL"));
        DepFieldTxt := Rec."Tax Registration No.";
        NewFieldTxt := Rec."Tax Registration No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Tax Registration No.", PreviousRecord."Tax Registration No. CZL");
        Rec."Tax Registration No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Tax Registration No."));
        Rec."Tax Registration No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Tax Registration No. CZL"));
    end;
}
