#if not CLEAN22
#pragma warning disable AL0432
codeunit 31297 "Sync.Dep.Fld-Customer CZ"
{
    Access = Internal;
    Permissions = tabledata Customer = rimd;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertCustomer(var Rec: Record Customer)
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyCustomer(var Rec: Record Customer)
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record Customer)
    var
        PreviousRecord: Record Customer;
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