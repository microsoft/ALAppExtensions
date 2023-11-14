#if not CLEAN22
#pragma warning disable AL0432
codeunit 31285 "Sync.Dep.Fld-Sales Header CZ"
{
    Access = Internal;
    Permissions = tabledata "Sales Header" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertSalesHeader(var Rec: Record "Sales Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifySalesHeader(var Rec: Record "Sales Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Sales Header")
    var
        PreviousRecord: Record "Sales Header";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        SyncDepFldUtilities.SyncFields(Rec."Physical Transfer CZL", Rec."Physical Transfer CZ", PreviousRecord."Physical Transfer CZL", PreviousRecord."Physical Transfer CZ");
        SyncDepFldUtilities.SyncFields(Rec."Intrastat Exclude CZL", Rec."Intrastat Exclude CZ", PreviousRecord."Intrastat Exclude CZL", PreviousRecord."Intrastat Exclude CZ");
    end;
}
#endif