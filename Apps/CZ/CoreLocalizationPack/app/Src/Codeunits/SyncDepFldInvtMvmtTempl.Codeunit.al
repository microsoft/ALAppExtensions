#if not CLEAN17
#pragma warning disable AL0432
codeunit 31180 "Sync.Dep.Fld-InvtMvmtTempl CZL"
{
    Permissions = tabledata "Whse. Net Change Template" = rimd,
                  tabledata "Invt. Movement Template CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Whse. Net Change Template", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameWhseNetChangeTemplate(var Rec: Record "Whse. Net Change Template"; var xRec: Record "Whse. Net Change Template")
    var
        InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Whse. Net Change Template") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Invt. Movement Template CZL");
        InvtMovementTemplateCZL.ChangeCompany(Rec.CurrentCompany);
        if InvtMovementTemplateCZL.Get(xRec.Name) then
            InvtMovementTemplateCZL.Rename(Rec.Name);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Invt. Movement Template CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Whse. Net Change Template", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertWhseNetChangeTemplate(var Rec: Record "Whse. Net Change Template")
    begin
        SyncWhseNetChangeTemplate(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Whse. Net Change Template", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyWhseNetChangeTemplate(var Rec: Record "Whse. Net Change Template")
    begin
        SyncWhseNetChangeTemplate(Rec);
    end;

    local procedure SyncWhseNetChangeTemplate(var Rec: Record "Whse. Net Change Template")
    var
        InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Whse. Net Change Template") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Invt. Movement Template CZL");
        InvtMovementTemplateCZL.ChangeCompany(Rec.CurrentCompany);
        if not InvtMovementTemplateCZL.Get(Rec.Name) then begin
            InvtMovementTemplateCZL.Init();
            InvtMovementTemplateCZL.Name := Rec.Name;
            InvtMovementTemplateCZL.SystemId := Rec.SystemId;
            InvtMovementTemplateCZL.Insert(false, true);
        end;
        InvtMovementTemplateCZL.Description := Rec.Description;
        InvtMovementTemplateCZL."Entry Type" := Rec."Entry Type";
        InvtMovementTemplateCZL."Gen. Bus. Posting Group" := Rec."Gen. Bus. Posting Group";
        InvtMovementTemplateCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Invt. Movement Template CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Whse. Net Change Template", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteWhseNetChangeTemplate(var Rec: Record "Whse. Net Change Template")
    var
        InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Whse. Net Change Template") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Invt. Movement Template CZL");
        InvtMovementTemplateCZL.ChangeCompany(Rec.CurrentCompany);
        if InvtMovementTemplateCZL.Get(Rec.Name) then
            InvtMovementTemplateCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Invt. Movement Template CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invt. Movement Template CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameInvtMovementTemplateCZL(var Rec: Record "Invt. Movement Template CZL"; var xRec: Record "Invt. Movement Template CZL")
    var
        WhseNetChangeTemplate: Record "Whse. Net Change Template";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Invt. Movement Template CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Whse. Net Change Template");
        WhseNetChangeTemplate.ChangeCompany(Rec.CurrentCompany);
        if WhseNetChangeTemplate.Get(xRec.Name) then
            WhseNetChangeTemplate.Rename(Rec.Name);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Whse. Net Change Template");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invt. Movement Template CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertInvtMovementTemplateCZL(var Rec: Record "Invt. Movement Template CZL")
    begin
        SyncInvtMovementTemplateCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invt. Movement Template CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyInvtMovementTemplateCZL(var Rec: Record "Invt. Movement Template CZL")
    begin
        SyncInvtMovementTemplateCZL(Rec);
    end;

    local procedure SyncInvtMovementTemplateCZL(var Rec: Record "Invt. Movement Template CZL")
    var
        WhseNetChangeTemplate: Record "Whse. Net Change Template";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Invt. Movement Template CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Whse. Net Change Template");
        WhseNetChangeTemplate.ChangeCompany(Rec.CurrentCompany);
        if not WhseNetChangeTemplate.Get(Rec.Name) then begin
            WhseNetChangeTemplate.Init();
            WhseNetChangeTemplate.Name := Rec.Name;
            WhseNetChangeTemplate.SystemId := Rec.SystemId;
            WhseNetChangeTemplate.Insert(false, true);
        end;
        WhseNetChangeTemplate.Description := CopyStr(Rec.Description, 1, MaxStrLen(WhseNetChangeTemplate.Description));
        WhseNetChangeTemplate."Entry Type" := Rec."Entry Type";
        WhseNetChangeTemplate."Gen. Bus. Posting Group" := Rec."Gen. Bus. Posting Group";
        WhseNetChangeTemplate.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Whse. Net Change Template");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invt. Movement Template CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteInvtMovementTemplateCZL(var Rec: Record "Invt. Movement Template CZL")
    var
        WhseNetChangeTemplate: Record "Whse. Net Change Template";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Invt. Movement Template CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Whse. Net Change Template");
        WhseNetChangeTemplate.ChangeCompany(Rec.CurrentCompany);
        if WhseNetChangeTemplate.Get(Rec.Name) then
            WhseNetChangeTemplate.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Whse. Net Change Template");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif