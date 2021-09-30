#if not CLEAN18
#pragma warning disable AL0432
codeunit 31216 "Sync.Dep.Fld-TransferHdr CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertTransferHeader(var Rec: Record "Transfer Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyTransferHeader(var Rec: Record "Transfer Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Transfer Header")
    var
        PreviousRecord: Record "Transfer Header";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Intrastat Exclude", Rec."Intrastat Exclude CZL", PreviousRecord."Intrastat Exclude", PreviousRecord."Intrastat Exclude CZL");
    end;
}
#endif