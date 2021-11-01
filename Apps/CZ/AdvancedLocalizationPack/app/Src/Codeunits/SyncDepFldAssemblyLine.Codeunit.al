#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31284 "Sync.Dep.Fld-AssemblyLine CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertAssemblyLine(var Rec: Record "Assembly Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyAssemblyLine(var Rec: Record "Assembly Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Assembly Line")
    var
        PreviousRecord: Record "Assembly Line";
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