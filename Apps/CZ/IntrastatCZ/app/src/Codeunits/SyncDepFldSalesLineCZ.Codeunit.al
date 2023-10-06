#if not CLEAN22
#pragma warning disable AL0432
codeunit 31286 "Sync.Dep.Fld-Sales Line CZ"
{
    Access = Internal;
    Permissions = tabledata "Sales Line" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertSalesLine(var Rec: Record "Sales Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifySalesLine(var Rec: Record "Sales Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Sales Line")
    var
        PreviousRecord: Record "Sales Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        DepFieldTxt := Rec."Statistic Indication CZL";
        NewFieldTxt := Rec."Statistic Indication CZ";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Statistic Indication CZL", PreviousRecord."Statistic Indication CZ");
        Rec."Statistic Indication CZL" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Statistic Indication CZL"));
        Rec."Statistic Indication CZ" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Statistic Indication CZ"));
        SyncDepFldUtilities.SyncFields(Rec."Physical Transfer CZL", Rec."Physical Transfer CZ", PreviousRecord."Physical Transfer CZL", PreviousRecord."Physical Transfer CZ");
    end;
}
#endif