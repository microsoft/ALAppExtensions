#if not CLEAN17
#pragma warning disable AL0432
codeunit 31143 "Sync.Dep.Fld-SKUTemplate CZL"
{
    Permissions = tabledata "Stockkeeping Unit Template" = rimd,
                  tabledata "Stockkeeping Unit Template CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit Template", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameStockkeepingUnitTemplate(var Rec: Record "Stockkeeping Unit Template"; var xRec: Record "Stockkeeping Unit Template")
    var
        StockkeepingUnitTemplateCZL: Record "Stockkeeping Unit Template CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Stockkeeping Unit Template") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Stockkeeping Unit Template CZL");
        StockkeepingUnitTemplateCZL.ChangeCompany(Rec.CurrentCompany);
        if StockkeepingUnitTemplateCZL.Get(xRec."Item Category Code", xRec."Location Code") then
            StockkeepingUnitTemplateCZL.Rename(Rec."Item Category Code", Rec."Location Code");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Stockkeeping Unit Template CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit Template", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertStockkeepingUnitTemplate(var Rec: Record "Stockkeeping Unit Template")
    begin
        SyncStockkeepingUnitTemplate(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit Template", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyStockkeepingUnitTemplate(var Rec: Record "Stockkeeping Unit Template")
    begin
        SyncStockkeepingUnitTemplate(Rec);
    end;

    local procedure SyncStockkeepingUnitTemplate(var Rec: Record "Stockkeeping Unit Template")
    var
        StockkeepingUnitTemplateCZL: Record "Stockkeeping Unit Template CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Stockkeeping Unit Template") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Stockkeeping Unit Template CZL");
        StockkeepingUnitTemplateCZL.ChangeCompany(Rec.CurrentCompany);
        if not StockkeepingUnitTemplateCZL.Get(Rec."Item Category Code", Rec."Location Code") then begin
            StockkeepingUnitTemplateCZL.Init();
            StockkeepingUnitTemplateCZL."Item Category Code" := Rec."Item Category Code";
            StockkeepingUnitTemplateCZL."Location Code" := Rec."Location Code";
            StockkeepingUnitTemplateCZL.SystemId := Rec.SystemId;
            StockkeepingUnitTemplateCZL.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Stockkeeping Unit Template CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit Template", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteStockkeepingUnitTemplate(var Rec: Record "Stockkeeping Unit Template")
    var
        StockkeepingUnitTemplateCZL: Record "Stockkeeping Unit Template CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Stockkeeping Unit Template") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Stockkeeping Unit Template CZL");
        StockkeepingUnitTemplateCZL.ChangeCompany(Rec.CurrentCompany);
        if StockkeepingUnitTemplateCZL.Get(Rec."Item Category Code", Rec."Location Code") then
            StockkeepingUnitTemplateCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Stockkeeping Unit Template CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit Template CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameStockkeepingUnitTemplateCZL(var Rec: Record "Stockkeeping Unit Template CZL"; var xRec: Record "Stockkeeping Unit Template CZL")
    var
        StockkeepingUnitTemplate: Record "Stockkeeping Unit Template";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Stockkeeping Unit Template CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Stockkeeping Unit Template");
        StockkeepingUnitTemplate.ChangeCompany(Rec.CurrentCompany);
        if StockkeepingUnitTemplate.Get(xRec."Item Category Code", xRec."Location Code") then
            StockkeepingUnitTemplate.Rename(Rec."Item Category Code", Rec."Location Code");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Stockkeeping Unit Template");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit Template CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertStockkeepingUnitTemplateCZL(var Rec: Record "Stockkeeping Unit Template CZL")
    begin
        SyncStockkeepingUnitTemplateCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit Template CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyStockkeepingUnitTemplateCZL(var Rec: Record "Stockkeeping Unit Template CZL")
    begin
        SyncStockkeepingUnitTemplateCZL(Rec);
    end;

    local procedure SyncStockkeepingUnitTemplateCZL(var Rec: Record "Stockkeeping Unit Template CZL")
    var
        StockkeepingUnitTemplate: Record "Stockkeeping Unit Template";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Stockkeeping Unit Template CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Stockkeeping Unit Template");
        StockkeepingUnitTemplate.ChangeCompany(Rec.CurrentCompany);
        if not StockkeepingUnitTemplate.Get(Rec."Item Category Code", Rec."Location Code") then begin
            StockkeepingUnitTemplate.Init();
            StockkeepingUnitTemplate."Item Category Code" := Rec."Item Category Code";
            StockkeepingUnitTemplate."Location Code" := Rec."Location Code";
            StockkeepingUnitTemplate.SystemId := Rec.SystemId;
            StockkeepingUnitTemplate.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Stockkeeping Unit Template");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit Template CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteStockkeepingUnitTemplateCZL(var Rec: Record "Stockkeeping Unit Template CZL")
    var
        StockkeepingUnitTemplate: Record "Stockkeeping Unit Template";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Stockkeeping Unit Template CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Stockkeeping Unit Template");
        StockkeepingUnitTemplate.ChangeCompany(Rec.CurrentCompany);
        if StockkeepingUnitTemplate.Get(Rec."Item Category Code", Rec."Location Code") then
            StockkeepingUnitTemplate.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Stockkeeping Unit Template");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif