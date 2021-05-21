#if not CLEAN17
#pragma warning disable AL0432
codeunit 31183 "Sync.Dep.Fld-GLAccount CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGLAccount(var Rec: Record "G/L Account")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGLAccount(var Rec: Record "G/L Account")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "G/L Account")
    var
        PreviousRecord: Record "G/L Account";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldInt, NewFieldInt : Integer;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldInt := Rec."G/L Account Group";
        NewFieldInt := Rec."G/L Account Group CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."G/L Account Group", PreviousRecord."G/L Account Group CZL".AsInteger());
        Rec."G/L Account Group" := DepFieldInt;
        evaluate(Rec."G/L Account Group CZL", format(NewFieldInt));
    end;
}
#endif