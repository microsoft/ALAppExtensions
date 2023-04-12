#if not CLEAN22
#pragma warning disable AL0432
codeunit 31467 "Sync.Dep.Fld-PurchInvHdr CZL"
{
    Access = Internal;
    Permissions = tabledata "Purch. Inv. Header" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPurchInvHeader(var Rec: Record "Purch. Inv. Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPurchInvHeader(var Rec: Record "Purch. Inv. Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Purch. Inv. Header")
    var
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Purch. Inv. Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Purch. Inv. Header");
        if not IsReplaceVATDateEnabled() then
            Rec."VAT Reporting Date" := Rec."VAT Date CZL"
        else
            Rec."VAT Date CZL" := Rec."VAT Reporting Date";
        Rec.Modify();
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Purch. Inv. Header");
    end;

    local procedure IsReplaceVATDateEnabled(): Boolean
    var
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
    begin
        exit(ReplaceVATDateMgtCZL.IsEnabled());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterValidateEvent', 'VAT Date CZL', false, false)]
    local procedure SyncOnAfterValidateVatDate(var Rec: Record "Purch. Inv. Header")
    begin
        if not IsReplaceVATDateEnabled() then
            Rec."VAT Reporting Date" := Rec."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterValidateEvent', 'VAT Reporting Date', false, false)]
    local procedure SyncOnAfterValidateVatReportingDate(var Rec: Record "Purch. Inv. Header")
    begin
        if IsReplaceVATDateEnabled() then
            Rec."VAT Date CZL" := Rec."VAT Reporting Date";
    end;
}
#endif