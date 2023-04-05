#if not CLEAN22
#pragma warning disable AL0432
codeunit 31163 "Sync.Dep.Fld-SalesSetup CZL"
{
    Access = Internal;
    Permissions = tabledata "Sales & Receivables Setup" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSalesReceivablesSetup(var Rec: Record "Sales & Receivables Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifySalesReceivablesSetup(var Rec: Record "Sales & Receivables Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Sales & Receivables Setup")
    var
        PreviousRecord: Record "Sales & Receivables Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        SyncDepFldUtilities.SyncFields(Rec."Allow Alter Posting Groups CZL", Rec."Allow Multiple Posting Groups", PreviousRecord."Allow Alter Posting Groups CZL", PreviousRecord."Allow Multiple Posting Groups");
    end;
}
#endif