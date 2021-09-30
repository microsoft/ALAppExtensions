#if not CLEAN18
#pragma warning disable AL0432
codeunit 31218 "Sync.Dep.Fld-ItemCharge CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertItemCharge(var Rec: Record "Item Charge")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyItemCharge(var Rec: Record "Item Charge")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Item Charge")
    var
        PreviousRecord: Record "Item Charge";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Incl. in Intrastat Amount", Rec."Incl. in Intrastat Amount CZL", PreviousRecord."Incl. in Intrastat Amount", PreviousRecord."Incl. in Intrastat Amount CZL");
        SyncDepFldUtilities.SyncFields(Rec."Incl. in Intrastat Stat. Value", Rec."Incl. in Intrastat S.Value CZL", PreviousRecord."Incl. in Intrastat Stat. Value", PreviousRecord."Incl. in Intrastat S.Value CZL");
    end;
}
#endif