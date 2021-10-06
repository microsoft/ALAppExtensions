#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31285 "Sync.Dep.Fld-ItemJnlLine CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertItemJnlLine(var Rec: Record "Item Journal Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyItemJnlLine(var Rec: Record "Item Journal Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Item Journal Line")
    var
        PreviousRecord: Record "Item Journal Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Source No. 3";
        NewFieldTxt := Rec."Delivery-to Source No. CZA";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Source No. 3", PreviousRecord."Delivery-to Source No. CZA");
        Rec."Source No. 3" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Source No. 3"));
        Rec."Delivery-to Source No. CZA" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Delivery-to Source No. CZA"));
        DepFieldTxt := Rec."Currency Code";
        NewFieldTxt := Rec."Currency Code CZA";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Currency Code", PreviousRecord."Currency Code CZA");
        Rec."Currency Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Currency Code"));
        Rec."Currency Code CZA" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Currency Code CZA"));
        SyncDepFldUtilities.SyncFields(Rec."Currency Factor", Rec."Currency Factor CZA", PreviousRecord."Currency Factor", PreviousRecord."Currency Factor CZA");
    end;
}
#endif