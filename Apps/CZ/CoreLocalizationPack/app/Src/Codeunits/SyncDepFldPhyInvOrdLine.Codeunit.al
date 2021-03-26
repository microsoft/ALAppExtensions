#if not CLEAN17
#pragma warning disable AL0432
codeunit 31170 "Sync.Dep.Fld-PhyInvOrdLine CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Phys. Invt. Order Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertPhysInventoryOrderLine(var Rec: Record "Phys. Invt. Order Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Phys. Invt. Order Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyPhysInventoryOrderLine(var Rec: Record "Phys. Invt. Order Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Phys. Invt. Order Line")
    var
        PreviousRecord: Record "Phys. Invt. Order Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Whse. Net Change Template";
        NewFieldTxt := Rec."Invt. Movement Template CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Whse. Net Change Template", PreviousRecord."Invt. Movement Template CZL");
        Rec."Whse. Net Change Template" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Whse. Net Change Template"));
        Rec."Invt. Movement Template CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Invt. Movement Template CZL"));
    end;
}
#endif