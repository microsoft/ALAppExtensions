#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31282 "Sync.Dep.Fld-AssemblySetup CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertAssemblySetup(var Rec: Record "Assembly Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyAssemblySetup(var Rec: Record "Assembly Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Assembly Setup")
    var
        PreviousRecord: Record "Assembly Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Gen. Bus. Posting Group";
        NewFieldTxt := Rec."Default Gen.Bus.Post. Grp. CZA";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Gen. Bus. Posting Group", PreviousRecord."Default Gen.Bus.Post. Grp. CZA");
        Rec."Gen. Bus. Posting Group" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Gen. Bus. Posting Group"));
        Rec."Default Gen.Bus.Post. Grp. CZA" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Default Gen.Bus.Post. Grp. CZA"));
    end;
}
#endif