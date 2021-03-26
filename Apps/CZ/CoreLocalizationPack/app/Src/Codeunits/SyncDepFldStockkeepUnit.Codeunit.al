#if not CLEAN17
#pragma warning disable AL0432
codeunit 31142 "Sync.Dep.Fld-StockkeepUnit CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertStockkeepingUnit(var Rec: Record "Stockkeeping Unit")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyStockkeepingUnit(var Rec: Record "Stockkeeping Unit")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Stockkeeping Unit")
    var
        PreviousRecord: Record "Stockkeeping Unit";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Gen. Prod. Posting Group";
        NewFieldTxt := Rec."Gen. Prod. Posting Group CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Gen. Prod. Posting Group", PreviousRecord."Gen. Prod. Posting Group CZL");
        Rec."Gen. Prod. Posting Group" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Gen. Prod. Posting Group"));
        Rec."Gen. Prod. Posting Group CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Gen. Prod. Posting Group CZL"));
    end;
}
#endif