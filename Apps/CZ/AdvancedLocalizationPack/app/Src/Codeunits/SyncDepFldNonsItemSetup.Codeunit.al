#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31286 "Sync.Dep.Fld-NonsItemSetup CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Nonstock Item Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertNonstockItemSetup(var Rec: Record "Nonstock Item Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Nonstock Item Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyNonstockItemSetup(var Rec: Record "Nonstock Item Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Nonstock Item Setup")
    var
        PreviousRecord: Record "Nonstock Item Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldBool, NewFieldBool : Boolean;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldBool := Rec."No. From No. Series";
        NewFieldBool := Rec."No. Format" = Rec."No. Format"::"Item No. Series CZA";
        SyncDepFldUtilities.SyncFields(DepFieldBool, NewFieldBool, PreviousRecord."No. From No. Series", PreviousRecord."No. Format" = PreviousRecord."No. Format"::"Item No. Series CZA");
        Rec."No. From No. Series" := DepFieldBool;
        if NewFieldBool then
            Rec."No. Format" := Rec."No. Format"::"Item No. Series CZA"
        else
            if Rec."No. Format" = Rec."No. Format"::"Item No. Series CZA" then
                Rec."No. Format" := Rec."No. Format"::"Vendor Item No.";
    end;
}
#endif