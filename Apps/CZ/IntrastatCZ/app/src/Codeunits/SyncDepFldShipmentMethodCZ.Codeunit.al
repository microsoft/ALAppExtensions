#if not CLEAN22
#pragma warning disable AL0432
codeunit 31292 "Sync.Dep.Fld-ShipmentMethod CZ"
{
    Access = Internal;
    Permissions = tabledata "Shipment Method" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Shipment Method", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertItemCharge(var Rec: Record "Shipment Method")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Shipment Method", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyItemCharge(var Rec: Record "Shipment Method")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Shipment Method")
    var
        PreviousRecord: Record "Shipment Method";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        DepFieldTxt := Rec."Intrastat Deliv. Grp. Code CZL";
        NewFieldTxt := Rec."Intrastat Deliv. Grp. Code CZ";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Intrastat Deliv. Grp. Code CZL", PreviousRecord."Intrastat Deliv. Grp. Code CZ");
        Rec."Intrastat Deliv. Grp. Code CZL" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Intrastat Deliv. Grp. Code CZL"));
        Rec."Intrastat Deliv. Grp. Code CZ" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Intrastat Deliv. Grp. Code CZ"));
        SyncDepFldUtilities.SyncFields(Rec."Incl. Item Charges (Amt.) CZL", Rec."Incl. Item Charges (Amt.) CZ", PreviousRecord."Incl. Item Charges (Amt.) CZL", PreviousRecord."Incl. Item Charges (Amt.) CZ");
    end;
}
#endif