#if not CLEAN17
#pragma warning disable AL0432
codeunit 31197 "Sync.Dep.Fld-Commodity CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::Commodity, 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCommodity(var Rec: Record Commodity; var xRec: Record Commodity)
    var
        CommodityCZL: Record "Commodity CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::Commodity) then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Commodity CZL");
        CommodityCZL.ChangeCompany(Rec.CurrentCompany);
        if CommodityCZL.Get(xRec.Code) then
            CommodityCZL.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Commodity CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::Commodity, 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCommodity(var Rec: Record Commodity)
    begin
        SyncCommodity(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Commodity, 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCommodity(var Rec: Record Commodity)
    begin
        SyncCommodity(Rec);
    end;

    local procedure SyncCommodity(var Rec: Record Commodity)
    var
        CommodityCZL: Record "Commodity CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::Commodity) then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Commodity CZL");
        CommodityCZL.ChangeCompany(Rec.CurrentCompany);
        if not CommodityCZL.Get(Rec.Code) then begin
            CommodityCZL.Init();
            CommodityCZL.Code := Rec.Code;
            CommodityCZL.SystemId := Rec.SystemId;
            CommodityCZL.Insert(false, true);
        end;
        CommodityCZL.Description := Rec.Description;
        CommodityCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Commodity CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::Commodity, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCommodity(var Rec: Record Commodity)
    var
        CommodityCZL: Record "Commodity CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::Commodity) then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Commodity CZL");
        CommodityCZL.ChangeCompany(Rec.CurrentCompany);
        if CommodityCZL.Get(Rec.Code) then
            CommodityCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Commodity CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Commodity CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCommodityCZL(var Rec: Record "Commodity CZL"; var xRec: Record "Commodity CZL")
    var
        Commodity: Record Commodity;
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Commodity CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::Commodity);
        Commodity.ChangeCompany(Rec.CurrentCompany);
        if Commodity.Get(xRec.Code) then
            Commodity.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::Commodity);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Commodity CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCommodityCZL(var Rec: Record "Commodity CZL")
    begin
        SyncCommodityCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Commodity CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCommodityCZL(var Rec: Record "Commodity CZL")
    begin
        SyncCommodityCZL(Rec);
    end;

    local procedure SyncCommodityCZL(var Rec: Record "Commodity CZL")
    var
        Commodity: Record Commodity;
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Commodity CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::Commodity);
        Commodity.ChangeCompany(Rec.CurrentCompany);
        if not Commodity.Get(Rec.Code) then begin
            Commodity.Init();
            Commodity.Code := Rec.Code;
            Commodity.SystemId := Rec.SystemId;
            Commodity.Insert(false, true);
        end;
        Commodity.Description := Rec.Description;
        Commodity.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::Commodity);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Commodity CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCommodityCZL(var Rec: Record "Commodity CZL")
    var
        Commodity: Record Commodity;
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Commodity CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::Commodity);
        Commodity.ChangeCompany(Rec.CurrentCompany);
        if Commodity.Get(Rec.Code) then
            Commodity.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::Commodity);
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif