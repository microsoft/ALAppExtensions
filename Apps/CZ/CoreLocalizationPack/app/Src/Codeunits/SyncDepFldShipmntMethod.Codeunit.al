#if not CLEAN18
//#pragma warning disable AL0432,AL0603
codeunit 31212 "Sync.Dep.Fld-ShipmntMethod CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Shipment Method", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertShipmentMethod(var Rec: Record "Shipment Method")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Shipment Method", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyShipmentMethod(var Rec: Record "Shipment Method")
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
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Include Item Charges (Amount)", Rec."Incl. Item Charges (Amt.) CZL", PreviousRecord."Include Item Charges (Amount)", PreviousRecord."Incl. Item Charges (Amt.) CZL");
        DepFieldTxt := Rec."Intrastat Delivery Group Code";
        NewFieldTxt := Rec."Intrastat Deliv. Grp. Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Intrastat Delivery Group Code", PreviousRecord."Intrastat Deliv. Grp. Code CZL");
        Rec."Intrastat Delivery Group Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Intrastat Delivery Group Code"));
        Rec."Intrastat Deliv. Grp. Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Intrastat Deliv. Grp. Code CZL"));
        SyncDepFldUtilities.SyncFields(Rec."Incl. Item Charges (Stat.Val.)", Rec."Incl. Item Charges (S.Val) CZL", PreviousRecord."Incl. Item Charges (Stat.Val.)", PreviousRecord."Incl. Item Charges (S.Val) CZL");
        SyncDepFldUtilities.SyncFields(Rec."Adjustment %", Rec."Adjustment % CZL", PreviousRecord."Adjustment %", PreviousRecord."Adjustment % CZL");
    end;
}
#endif