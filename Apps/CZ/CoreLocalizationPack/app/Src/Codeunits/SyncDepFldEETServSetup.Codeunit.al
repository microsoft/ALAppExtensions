#if not CLEAN18
#pragma warning disable AL0432
codeunit 31135 "Sync.Dep.Fld-EETServSetup CZL"
{
    Permissions = tabledata "EET Service Setup" = rimd,
                  tabledata "EET Service Setup CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"EET Service Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertEETServiceSetup(var Rec: Record "EET Service Setup")
    begin
        SyncEETServiceSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Service Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyEETServiceSetup(var Rec: Record "EET Service Setup")
    begin
        SyncEETServiceSetup(Rec);
    end;

    local procedure SyncEETServiceSetup(var EETServiceSetup: Record "EET Service Setup")
    var
        EETServiceSetupCZL: Record "EET Service Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if EETServiceSetup.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Service Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Service Setup CZL");
        EETServiceSetupCZL.ChangeCompany(EETServiceSetup.CurrentCompany);
        if not EETServiceSetupCZL.Get() then begin
            EETServiceSetupCZL.Init();
            EETServiceSetupCZL.SystemId := EETServiceSetup.SystemId;
            EETServiceSetupCZL.Insert(false, true);
        end;
        EETServiceSetupCZL."Service URL" := EETServiceSetup."Service URL";
        EETServiceSetupCZL."Sales Regime" := "EET Sales Regime CZL".FromInteger(EETServiceSetup."Sales Regime");
        EETServiceSetupCZL."Limit Response Time" := EETServiceSetup."Limit Response Time";
        EETServiceSetupCZL."Appointing VAT Reg. No." := EETServiceSetup."Appointing VAT Reg. No.";
        EETServiceSetupCZL."Certificate Code" := EETServiceSetup."Certificate Code";
        EETServiceSetupCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Service Setup CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Service Setup", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteEETServiceSetup(var Rec: Record "EET Service Setup")
    var
        EETServiceSetupCZL: Record "EET Service Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Service Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Service Setup CZL");
        EETServiceSetupCZL.ChangeCompany(Rec.CurrentCompany);
        if EETServiceSetupCZL.Get() then
            EETServiceSetupCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Service Setup CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Service Setup CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertEETServiceSetupCZL(var Rec: Record "EET Service Setup CZL")
    begin
        SyncEETServiceSetupCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Service Setup CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyEETServiceSetupCZL(var Rec: Record "EET Service Setup CZL")
    begin
        SyncEETServiceSetupCZL(Rec);
    end;

    local procedure SyncEETServiceSetupCZL(var EETServiceSetupCZL: Record "EET Service Setup CZL")
    var
        EETServiceSetup: Record "EET Service Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if EETServiceSetupCZL.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Service Setup CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Service Setup");
        EETServiceSetup.ChangeCompany(EETServiceSetupCZL.CurrentCompany);
        if not EETServiceSetup.Get() then begin
            EETServiceSetup.Init();
            EETServiceSetup.SystemId := EETServiceSetupCZL.SystemId;
            EETServiceSetup.Insert(false, true);
        end;
        EETServiceSetup."Service URL" := EETServiceSetupCZL."Service URL";
        EETServiceSetup."Sales Regime" := EETServiceSetupCZL."Sales Regime".AsInteger();
        EETServiceSetup."Limit Response Time" := EETServiceSetupCZL."Limit Response Time";
        EETServiceSetup."Appointing VAT Reg. No." := EETServiceSetupCZL."Appointing VAT Reg. No.";
        EETServiceSetup."Certificate Code" := EETServiceSetupCZL."Certificate Code";
        EETServiceSetup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Service Setup");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Service Setup CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteEETServiceSetupCZL(var Rec: Record "EET Service Setup CZL")
    var
        EETServiceSetup: Record "EET Service Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Service Setup CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Service Setup");
        EETServiceSetup.ChangeCompany(Rec.CurrentCompany);
        if EETServiceSetup.Get() then
            EETServiceSetup.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Service Setup");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif