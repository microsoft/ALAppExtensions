#if not CLEAN18
#pragma warning disable AL0432
codeunit 31211 "Sync.Dep.Fld-RegNoSvcConf CZL"
{
#if not CLEAN17
    Permissions = tabledata "Reg. No. Srv Config" = rimd,
                  tabledata "Reg. No. Service Config CZL" = rimd;
#endif
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

#if not CLEAN17
    [EventSubscriber(ObjectType::Table, Database::"Reg. No. Srv Config", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameRegNoSrvConfig(var Rec: Record "Reg. No. Srv Config"; var xRec: Record "Reg. No. Srv Config")
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Reg. No. Srv Config") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Reg. No. Service Config CZL");
        RegNoServiceConfigCZL.ChangeCompany(Rec.CurrentCompany);
        if RegNoServiceConfigCZL.Get(xRec."Entry No.") then
            RegNoServiceConfigCZL.Rename(Rec."Entry No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Reg. No. Service Config CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reg. No. Srv Config", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertRegNoSrvConfig(var Rec: Record "Reg. No. Srv Config")
    begin
        SyncRegNoSrvConfig(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reg. No. Srv Config", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyRegNoSrvConfig(var Rec: Record "Reg. No. Srv Config")
    begin
        SyncRegNoSrvConfig(Rec);
    end;

    local procedure SyncRegNoSrvConfig(var Rec: Record "Reg. No. Srv Config")
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Reg. No. Srv Config") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Reg. No. Service Config CZL");
        RegNoServiceConfigCZL.ChangeCompany(Rec.CurrentCompany);
        if not RegNoServiceConfigCZL.Get(Rec."Entry No.") then begin
            RegNoServiceConfigCZL.Init();
            RegNoServiceConfigCZL."Entry No." := Rec."Entry No.";
            RegNoServiceConfigCZL.SystemId := Rec.SystemId;
            RegNoServiceConfigCZL.Insert(false, true);
        end;
        RegNoServiceConfigCZL."Service Endpoint" := Rec."Service Endpoint";
        RegNoServiceConfigCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Reg. No. Service Config CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reg. No. Srv Config", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteRegNoSrvConfig(var Rec: Record "Reg. No. Srv Config")
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Reg. No. Srv Config") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Reg. No. Service Config CZL");
        RegNoServiceConfigCZL.ChangeCompany(Rec.CurrentCompany);
        if RegNoServiceConfigCZL.Get(Rec."Entry No.") then
            RegNoServiceConfigCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Reg. No. Service Config CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reg. No. Service Config CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameRegNoServiceConfigCZL(var Rec: Record "Reg. No. Service Config CZL"; var xRec: Record "Reg. No. Service Config CZL")
    var
        RegNoSrvConfig: Record "Reg. No. Srv Config";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Reg. No. Service Config CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Reg. No. Srv Config");
        RegNoSrvConfig.ChangeCompany(Rec.CurrentCompany);
        if RegNoSrvConfig.Get(xRec."Entry No.") then
            RegNoSrvConfig.Rename(Rec."Entry No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Reg. No. Srv Config");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reg. No. Service Config CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertRegNoServiceConfigCZL(var Rec: Record "Reg. No. Service Config CZL")
    begin
        SyncRegNoServiceConfigCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reg. No. Service Config CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyRegNoServiceConfigCZL(var Rec: Record "Reg. No. Service Config CZL")
    begin
        SyncRegNoServiceConfigCZL(Rec);
    end;

    local procedure SyncRegNoServiceConfigCZL(var Rec: Record "Reg. No. Service Config CZL")
    var
        RegNoSrvConfig: Record "Reg. No. Srv Config";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Reg. No. Service Config CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Reg. No. Srv Config");
        RegNoSrvConfig.ChangeCompany(Rec.CurrentCompany);
        if not RegNoSrvConfig.Get(Rec."Entry No.") then begin
            RegNoSrvConfig.Init();
            RegNoSrvConfig."Entry No." := Rec."Entry No.";
            RegNoSrvConfig.SystemId := Rec.SystemId;
            RegNoSrvConfig.Insert(false, true);
        end;
        RegNoSrvConfig."Service Endpoint" := Rec."Service Endpoint";
        RegNoSrvConfig.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Reg. No. Srv Config");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reg. No. Service Config CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteRegNoServiceConfigCZL(var Rec: Record "Reg. No. Service Config CZL")
    var
        RegNoSrvConfig: Record "Reg. No. Srv Config";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Reg. No. Service Config CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Reg. No. Srv Config");
        RegNoSrvConfig.ChangeCompany(Rec.CurrentCompany);
        if RegNoSrvConfig.Get(Rec."Entry No.") then
            RegNoSrvConfig.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Reg. No. Srv Config");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
#endif
}
#endif