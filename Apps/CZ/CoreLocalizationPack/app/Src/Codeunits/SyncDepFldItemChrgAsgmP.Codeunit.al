#if not CLEAN18
#pragma warning disable AL0432
codeunit 31219 "Sync.Dep.Fld-ItemChrgAsgmP CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Item Charge Assignment (Purch)", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertItemChargeAssignmentPurch(var Rec: Record "Item Charge Assignment (Purch)")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge Assignment (Purch)", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyItemChargeAssignmentPurch(var Rec: Record "Item Charge Assignment (Purch)")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Item Charge Assignment (Purch)")
    var
        PreviousRecord: Record "Item Charge Assignment (Purch)";
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