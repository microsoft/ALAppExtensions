#if not CLEAN22
#pragma warning disable AL0432
codeunit 31164 "Sync.Dep.Fld-PurchSetup CZL"
{
    Access = Internal;
    Permissions = tabledata "Purchases & Payables Setup" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPurchasesPayablesSetup(var Rec: Record "Purchases & Payables Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPurchasesPayablesSetup(var Rec: Record "Purchases & Payables Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Purchases & Payables Setup")
    var
        PreviousRecord: Record "Purchases & Payables Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        SyncDepFldUtilities.SyncFields(Rec."Allow Alter Posting Groups CZL", Rec."Allow Multiple Posting Groups", PreviousRecord."Allow Alter Posting Groups CZL", PreviousRecord."Allow Multiple Posting Groups");
    end;
}
#endif