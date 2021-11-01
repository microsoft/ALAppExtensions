#if not CLEAN17
#pragma warning disable AL0432
codeunit 31195 "Sync.Dep.Fld-CommoditStp CZL"
{
    Permissions = tabledata "Commodity Setup" = rimd,
                  tabledata "Commodity Setup CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Commodity Setup", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCommoditySetup(var Rec: Record "Commodity Setup"; var xRec: Record "Commodity Setup")
    var
        CommoditySetupCZL: Record "Commodity Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Commodity Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Commodity Setup CZL");
        CommoditySetupCZL.ChangeCompany(Rec.CurrentCompany);
        if CommoditySetupCZL.Get(xRec."Commodity Code", xRec."Valid From") then
            CommoditySetupCZL.Rename(Rec."Commodity Code", Rec."Valid From");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Commodity Setup CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Commodity Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCommoditySetup(var Rec: Record "Commodity Setup")
    begin
        SyncCommoditySetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Commodity Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCommoditySetup(var Rec: Record "Commodity Setup")
    begin
        SyncCommoditySetup(Rec);
    end;

    local procedure SyncCommoditySetup(var Rec: Record "Commodity Setup")
    var
        CommoditySetupCZL: Record "Commodity Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Commodity Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Commodity Setup CZL");
        CommoditySetupCZL.ChangeCompany(Rec.CurrentCompany);
        if not CommoditySetupCZL.Get(Rec."Commodity Code", Rec."Valid From") then begin
            CommoditySetupCZL.Init();
            CommoditySetupCZL."Commodity Code" := Rec."Commodity Code";
            CommoditySetupCZL."Valid From" := Rec."Valid From";
            CommoditySetupCZL.SystemId := Rec.SystemId;
            CommoditySetupCZL.Insert(false, true);
        end;
        CommoditySetupCZL."Commodity Limit Amount LCY" := Rec."Commodity Limit Amount LCY";
        CommoditySetupCZL."Valid To" := Rec."Valid To";
        CommoditySetupCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Commodity Setup CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Commodity Setup", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCommoditySetup(var Rec: Record "Commodity Setup")
    var
        CommoditySetupCZL: Record "Commodity Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Commodity Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Commodity Setup CZL");
        CommoditySetupCZL.ChangeCompany(Rec.CurrentCompany);
        if CommoditySetupCZL.Get(Rec."Commodity Code", Rec."Valid From") then
            CommoditySetupCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Commodity Setup CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Commodity Setup CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCommoditySetupCZL(var Rec: Record "Commodity Setup CZL"; var xRec: Record "Commodity Setup CZL")
    var
        CommoditySetup: Record "Commodity Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Commodity Setup CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Commodity Setup");
        CommoditySetup.ChangeCompany(Rec.CurrentCompany);
        if CommoditySetup.Get(xRec."Commodity Code", xRec."Valid From") then
            CommoditySetup.Rename(Rec."Commodity Code", Rec."Valid From");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Commodity Setup");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Commodity Setup CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCommoditySetupCZL(var Rec: Record "Commodity Setup CZL")
    begin
        SyncCommoditySetupCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Commodity Setup CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCommoditySetupCZL(var Rec: Record "Commodity Setup CZL")
    begin
        SyncCommoditySetupCZL(Rec);
    end;

    local procedure SyncCommoditySetupCZL(var Rec: Record "Commodity Setup CZL")
    var
        CommoditySetup: Record "Commodity Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Commodity Setup CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Commodity Setup");
        CommoditySetup.ChangeCompany(Rec.CurrentCompany);
        if not CommoditySetup.Get(Rec."Commodity Code", Rec."Valid From") then begin
            CommoditySetup.Init();
            CommoditySetup."Commodity Code" := Rec."Commodity Code";
            CommoditySetup."Valid From" := Rec."Valid From";
            CommoditySetup.SystemId := Rec.SystemId;
            CommoditySetup.Insert(false, true);
        end;
        CommoditySetup."Commodity Limit Amount LCY" := Rec."Commodity Limit Amount LCY";
        CommoditySetup."Valid To" := Rec."Valid To";
        CommoditySetup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Commodity Setup");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Commodity Setup CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCommoditySetupCZL(var Rec: Record "Commodity Setup CZL")
    var
        CommoditySetup: Record "Commodity Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Commodity Setup CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Commodity Setup");
        CommoditySetup.ChangeCompany(Rec.CurrentCompany);
        if CommoditySetup.Get(Rec."Commodity Code", Rec."Valid From") then
            CommoditySetup.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Commodity Setup");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif