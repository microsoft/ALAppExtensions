#if not CLEAN17
#pragma warning disable AL0432
codeunit 31184 "Sync.Dep.Fld-VatStmtTempl CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Template", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertVATStatementLine(var Rec: Record "VAT Statement Template")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Template", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyVATStatementLine(var Rec: Record "VAT Statement Template")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "VAT Statement Template")
    var
        PreviousRecord: Record "VAT Statement Template";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Allow Comments/Attachments", Rec."Allow Comments/Attachments CZL", PreviousRecord."Allow Comments/Attachments", PreviousRecord."Allow Comments/Attachments CZL");
    end;
}
#endif