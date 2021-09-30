#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31280 "Sync.Dep.Fld-InvtSetup CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertInventorySetup(var Rec: Record "Inventory Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyInventorySetup(var Rec: Record "Inventory Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Inventory Setup")
    var
        PreviousRecord: Record "Inventory Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Use GPPG from SKU", Rec."Use GPPG from SKU CZA", PreviousRecord."Use GPPG from SKU", PreviousRecord."Use GPPG from SKU CZA");
        SyncDepFldUtilities.SyncFields(Rec."Skip Update SKU on Posting", Rec."Skip Update SKU on Posting CZA", PreviousRecord."Skip Update SKU on Posting", PreviousRecord."Skip Update SKU on Posting CZA");
        SyncDepFldUtilities.SyncFields(Rec."Exact Cost Reversing Mandatory", Rec."Exact Cost Revers. Mandat. CZA", PreviousRecord."Exact Cost Reversing Mandatory", PreviousRecord."Exact Cost Revers. Mandat. CZA");
    end;
}
#endif