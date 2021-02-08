#pragma warning disable AL0432
codeunit 31161 "Sync.Dep.Fld-UserSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertUserSetup(var Rec: Record "User Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyUserSetup(var Rec: Record "User Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "User Setup")
    var
        PreviousRecord: Record "User Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Allow VAT Posting From", Rec."Allow VAT Posting From CZL", PreviousRecord."Allow VAT Posting From", PreviousRecord."Allow VAT Posting From CZL");
        SyncDepFldUtilities.SyncFields(Rec."Allow VAT Posting To", Rec."Allow VAT Posting To CZL", PreviousRecord."Allow VAT Posting To", PreviousRecord."Allow VAT Posting To CZL");
    end;
}
