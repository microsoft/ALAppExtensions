#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31283 "Sync.Dep.Fld-AssemblyHdr. CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertAssemblyHeader(var Rec: Record "Assembly Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyAssemblyHeader(var Rec: Record "Assembly Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Assembly Header")
    var
        PreviousRecord: Record "Assembly Header";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Gen. Bus. Posting Group";
        NewFieldTxt := Rec."Gen. Bus. Posting Group CZA";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Gen. Bus. Posting Group", PreviousRecord."Gen. Bus. Posting Group CZA");
        Rec."Gen. Bus. Posting Group" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Gen. Bus. Posting Group"));
        Rec."Gen. Bus. Posting Group CZA" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Gen. Bus. Posting Group CZA"));
    end;
}
#endif