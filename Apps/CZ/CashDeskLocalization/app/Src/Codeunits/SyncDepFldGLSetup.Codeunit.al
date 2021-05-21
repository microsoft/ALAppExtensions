#if not CLEAN17
#pragma warning disable AL0432
codeunit 31124 "Sync.Dep.Fld-GLSetup CZP"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGLSetup(var Rec: Record "General Ledger Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGLSetup(var Rec: Record "General Ledger Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "General Ledger Setup")
    var
        PreviousRecord: Record "General Ledger Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Cash Desk Nos.";
        NewFieldTxt := Rec."Cash Desk Nos. CZP";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Cash Desk Nos.", PreviousRecord."Cash Desk Nos. CZP");
        Rec."Cash Desk Nos." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Cash Desk Nos."));
        Rec."Cash Desk Nos. CZP" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Cash Desk Nos. CZP"));
        SyncDepFldUtilities.SyncFields(Rec."Cash Payment Limit (LCY)", Rec."Cash Payment Limit (LCY) CZP", PreviousRecord."Cash Payment Limit (LCY)", PreviousRecord."Cash Payment Limit (LCY) CZP");
    end;
}
#endif