#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31290 "Sync.Dep.Fld-SrcCodeSetup CZC"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Source Code Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertSourceCodeSetup(var Rec: Record "Source Code Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Source Code Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifySourceCodeSetup(var Rec: Record "Source Code Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Source Code Setup")
    var
        PreviousRecord: Record "Source Code Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec.Credit;
        NewFieldTxt := Rec."Compensation CZC";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord.Credit, PreviousRecord."Compensation CZC");
        Rec.Credit := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec.Credit));
        Rec."Compensation CZC" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Compensation CZC"));
    end;
}
#endif