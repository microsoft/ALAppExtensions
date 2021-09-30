#if not CLEAN18
#pragma warning disable AL0432
codeunit 31139 "Sync.Dep.Fld-EETEntryStat CZL"
{
    Permissions = tabledata "EET Entry Status" = rimd,
                  tabledata "EET Entry Status Log CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"EET Entry Status", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameEETEntryStatus(var Rec: Record "EET Entry Status"; var xRec: Record "EET Entry Status")
    var
        EETEntryStatusLogCZL: Record "EET Entry Status Log CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry Status") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry Status Log CZL");
        EETEntryStatusLogCZL.ChangeCompany(Rec.CurrentCompany);
        if EETEntryStatusLogCZL.Get(xRec."Entry No.") then
            EETEntryStatusLogCZL.Rename(Rec."Entry No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry Status Log CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry Status", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertEETEntryStatus(var Rec: Record "EET Entry Status")
    begin
        SyncEETEntryStatus(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry Status", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyEETEntryStatus(var Rec: Record "EET Entry Status")
    begin
        SyncEETEntryStatus(Rec);
    end;

    local procedure SyncEETEntryStatus(var EETEntryStatus: Record "EET Entry Status")
    var
        EETEntryStatusLogCZL: Record "EET Entry Status Log CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if EETEntryStatus.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry Status") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry Status Log CZL");
        EETEntryStatusLogCZL.ChangeCompany(EETEntryStatus.CurrentCompany);
        if not EETEntryStatusLogCZL.Get(EETEntryStatus."Entry No.") then begin
            EETEntryStatusLogCZL.Init();
            EETEntryStatusLogCZL."Entry No." := EETEntryStatus."Entry No.";
            EETEntryStatusLogCZL.SystemId := EETEntryStatus.SystemId;
            EETEntryStatusLogCZL.Insert(false, true);
        end;
        EETEntryStatusLogCZL."EET Entry No." := EETEntryStatus."EET Entry No.";
        EETEntryStatusLogCZL.Description := EETEntryStatus.Description;
        EETEntryStatusLogCZL.Status := "EET Status CZL".FromInteger(EETEntryStatus.Status);
        EETEntryStatusLogCZL."Changed At" := EETEntryStatus."Change Datetime";
        EETEntryStatusLogCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry Status Log CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry Status", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteEETEntryStatus(var Rec: Record "EET Entry Status")
    var
        EETEntryStatusLogCZL: Record "EET Entry Status Log CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry Status") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry Status Log CZL");
        EETEntryStatusLogCZL.ChangeCompany(Rec.CurrentCompany);
        if EETEntryStatusLogCZL.Get(Rec."Entry No.") then
            EETEntryStatusLogCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry Status Log CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry Status Log CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameEETEntryStatusLogCZL(var Rec: Record "EET Entry Status Log CZL"; var xRec: Record "EET Entry Status Log CZL")
    var
        EETEntryStatus: Record "EET Entry Status";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry Status Log CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry Status");
        EETEntryStatus.ChangeCompany(Rec.CurrentCompany);
        if EETEntryStatus.Get(xRec."Entry No.") then
            EETEntryStatus.Rename(Rec."Entry No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry Status");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry Status Log CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertEETEntryStatusLogCZL(var Rec: Record "EET Entry Status Log CZL")
    begin
        SyncEETEntryStatusLogCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry Status Log CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyEETEntryStatusLogCZL(var Rec: Record "EET Entry Status Log CZL")
    begin
        SyncEETEntryStatusLogCZL(Rec);
    end;

    local procedure SyncEETEntryStatusLogCZL(var EETEntryStatusLogCZL: Record "EET Entry Status Log CZL")
    var
        EETEntryStatus: Record "EET Entry Status";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if EETEntryStatusLogCZL.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry Status Log CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry Status");
        EETEntryStatus.ChangeCompany(EETEntryStatusLogCZL.CurrentCompany);
        if not EETEntryStatus.Get(EETEntryStatusLogCZL."Entry No.") then begin
            EETEntryStatus.Init();
            EETEntryStatus."Entry No." := EETEntryStatusLogCZL."Entry No.";
            EETEntryStatus.SystemId := EETEntryStatusLogCZL.SystemId;
            EETEntryStatus.Insert(false, true);
        end;
        EETEntryStatus."EET Entry No." := EETEntryStatusLogCZL."EET Entry No.";
        EETEntryStatus.Description := EETEntryStatusLogCZL.Description;
        EETEntryStatus.Status := EETEntryStatusLogCZL.Status.AsInteger();
        EETEntryStatus."Change Datetime" := EETEntryStatusLogCZL."Changed At";
        EETEntryStatus.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry Status");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry Status Log CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteEETEntryStatusLogCZL(var Rec: Record "EET Entry Status Log CZL")
    var
        EETEntryStatus: Record "EET Entry Status";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry Status Log CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry Status");
        EETEntryStatus.ChangeCompany(Rec.CurrentCompany);
        if EETEntryStatus.Get(Rec."Entry No.") then
            EETEntryStatus.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry Status");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif