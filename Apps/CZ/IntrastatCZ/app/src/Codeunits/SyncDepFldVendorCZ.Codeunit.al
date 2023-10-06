#if not CLEAN22
#pragma warning disable AL0432
codeunit 31298 "Sync.Dep.Fld-Vendor CZ"
{
    Access = Internal;
    Permissions = tabledata Vendor = rimd;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertVendor(var Rec: Record Vendor)
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyVendor(var Rec: Record Vendor)
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record Vendor)
    var
        PreviousRecord: Record Vendor;
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        DepFieldTxt := Rec."Transaction Type CZL";
        NewFieldTxt := Rec."Default Trans. Type";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Transaction Type CZL", PreviousRecord."Default Trans. Type");
        Rec."Transaction Type CZL" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Transaction Type CZL"));
        Rec."Default Trans. Type" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Default Trans. Type"));
        DepFieldTxt := Rec."Transport Method CZL";
        NewFieldTxt := Rec."Def. Transport Method";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Transport Method CZL", PreviousRecord."Def. Transport Method");
        Rec."Transport Method CZL" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Transport Method CZL"));
        Rec."Def. Transport Method" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Def. Transport Method"));
    end;
}
#endif