#if not CLEAN18
#pragma warning disable AL0432,AL0603
codeunit 31303 "Sync.Dep.Fld-UserSetupLine CZL"
{
    Permissions = tabledata "User Setup Line" = rimd,
                  tabledata "User Setup Line CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"User Setup Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameUserSetupLine(var Rec: Record "User Setup Line"; var xRec: Record "User Setup Line")
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"User Setup Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"User Setup Line CZL");
        UserSetupLineCZL.ChangeCompany(Rec.CurrentCompany);
        if UserSetupLineCZL.Get(xRec."User ID", xRec.Type, xRec."Line No.") then
            UserSetupLineCZL.Rename(Rec."User ID", Rec.Type, Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"User Setup Line CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertUserSetupLine(var Rec: Record "User Setup Line")
    begin
        SyncUserSetupLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyUserSetupLine(var Rec: Record "User Setup Line")
    begin
        SyncUserSetupLine(Rec);
    end;

    local procedure SyncUserSetupLine(var Rec: Record "User Setup Line")
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"User Setup Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"User Setup Line CZL");
        UserSetupLineCZL.ChangeCompany(Rec.CurrentCompany);
        if not UserSetupLineCZL.Get(Rec."User ID", Rec.Type, Rec."Line No.") then begin
            UserSetupLineCZL.Init();
            UserSetupLineCZL."User ID" := Rec."User ID";
            UserSetupLineCZL.Type := Rec.Type;
            UserSetupLineCZL."Line No." := Rec."Line No.";
            UserSetupLineCZL.SystemId := Rec.SystemId;
            UserSetupLineCZL.Insert(false, true);
        end;
        UserSetupLineCZL."Code / Name" := Rec."Code / Name";
        UserSetupLineCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"User Setup Line CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteUserSetupLine(var Rec: Record "User Setup Line")
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"User Setup Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"User Setup Line CZL");
        UserSetupLineCZL.ChangeCompany(Rec.CurrentCompany);
        if UserSetupLineCZL.Get(Rec."User ID", Rec.Type, Rec."Line No.") then
            UserSetupLineCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"User Setup Line CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup Line CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameUserSetupLineCZL(var Rec: Record "User Setup Line CZL"; var xRec: Record "User Setup Line CZL")
    var
        UserSetupLine: Record "User Setup Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"User Setup Line CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"User Setup Line");
        UserSetupLine.ChangeCompany(Rec.CurrentCompany);
        if UserSetupLine.Get(xRec."User ID", xRec.Type, xRec."Line No.") then begin
            UserSetupLine.Rename(Rec."User ID", Rec.Type, Rec."Line No.");
            SyncLoopingHelper.RestoreFieldSynchronization(Database::"User Setup Line");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup Line CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertUserSetupLineCZL(var Rec: Record "User Setup Line CZL")
    begin
        if NavApp.IsInstalling() then
            exit;
        SyncUserSetupLineCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup Line CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyUserSetupLineCZL(var Rec: Record "User Setup Line CZL")
    begin
        SyncUserSetupLineCZL(Rec);
    end;

    local procedure SyncUserSetupLineCZL(var Rec: Record "User Setup Line CZL")
    var
        UserSetupLine: Record "User Setup Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"User Setup Line CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"User Setup Line");
        UserSetupLine.ChangeCompany(Rec.CurrentCompany);
        if not UserSetupLine.Get(Rec."User ID", Rec.Type, Rec."Line No.") then begin
            UserSetupLine.Init();
            UserSetupLine."User ID" := Rec."User ID";
            UserSetupLine.Type := Rec.Type;
            UserSetupLine."Line No." := Rec."Line No.";
            UserSetupLine.SystemId := Rec.SystemId;
            UserSetupLine.Insert(false, true);
        end;
        UserSetupLine."Code / Name" := Rec."Code / Name";
        UserSetupLine.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"User Setup Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup Line CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteUserSetupLineCZL(var Rec: Record "User Setup Line CZL")
    var
        UserSetupLine: Record "User Setup Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"User Setup Line CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"User Setup Line");
        UserSetupLine.ChangeCompany(Rec.CurrentCompany);
        if UserSetupLine.Get(Rec."User ID", Rec.Type, Rec."Line No.") then begin
            UserSetupLine.Delete(false);
            SyncLoopingHelper.RestoreFieldSynchronization(Database::"User Setup Line");
        end;
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif