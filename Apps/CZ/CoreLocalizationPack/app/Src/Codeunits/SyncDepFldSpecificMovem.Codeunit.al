#if not CLEAN18
#pragma warning disable AL0432
codeunit 31214 "Sync.Dep.Fld-SpecificMovem CZL"
{
    Permissions = tabledata "Specific Movement" = rimd,
                  tabledata "Specific Movement CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameSpecificMovement(var Rec: Record "Specific Movement"; var xRec: Record "Specific Movement")
    var
        SpecificMovementCZL: Record "Specific Movement CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement CZL");
        SpecificMovementCZL.ChangeCompany(Rec.CurrentCompany);
        if SpecificMovementCZL.Get(xRec.Code) then
            SpecificMovementCZL.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSpecificMovement(var Rec: Record "Specific Movement")
    begin
        SyncSpecificMovement(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifySpecificMovement(var Rec: Record "Specific Movement")
    begin
        SyncSpecificMovement(Rec);
    end;

    local procedure SyncSpecificMovement(var Rec: Record "Specific Movement")
    var
        SpecificMovementCZL: Record "Specific Movement CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement CZL");
        SpecificMovementCZL.ChangeCompany(Rec.CurrentCompany);
        if not SpecificMovementCZL.Get(Rec.Code) then begin
            SpecificMovementCZL.Init();
            SpecificMovementCZL.Code := Rec.Code;
            SpecificMovementCZL.SystemId := Rec.SystemId;
            SpecificMovementCZL.Insert(false, true);
        end;
        SpecificMovementCZL.Description := Rec.Description;
        SpecificMovementCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteSpecificMovement(var Rec: Record "Specific Movement")
    var
        SpecificMovementCZL: Record "Specific Movement CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement CZL");
        SpecificMovementCZL.ChangeCompany(Rec.CurrentCompany);
        if SpecificMovementCZL.Get(Rec.Code) then
            SpecificMovementCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameSpecificMovementCZL(var Rec: Record "Specific Movement CZL"; var xRec: Record "Specific Movement CZL")
    var
        SpecificMovement: Record "Specific Movement";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement");
        SpecificMovement.ChangeCompany(Rec.CurrentCompany);
        if SpecificMovement.Get(xRec.Code) then
            SpecificMovement.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSpecificMovementCZL(var Rec: Record "Specific Movement CZL")
    begin
        SyncSpecificMovementCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifySpecificMovementCZL(var Rec: Record "Specific Movement CZL")
    begin
        SyncSpecificMovementCZL(Rec);
    end;

    local procedure SyncSpecificMovementCZL(var Rec: Record "Specific Movement CZL")
    var
        SpecificMovement: Record "Specific Movement";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement");
        SpecificMovement.ChangeCompany(Rec.CurrentCompany);
        if not SpecificMovement.Get(Rec.Code) then begin
            SpecificMovement.Init();
            SpecificMovement.Code := CopyStr(Rec.Code, 1, MaxStrLen(SpecificMovement.Code));
            SpecificMovement.SystemId := Rec.SystemId;
            SpecificMovement.Insert(false, true);
        end;
        SpecificMovement.Description := CopyStr(Rec.Description, 1, MaxStrLen(SpecificMovement.Description));
        SpecificMovement.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteSpecificMovementCZL(var Rec: Record "Specific Movement CZL")
    var
        SpecificMovement: Record "Specific Movement";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement");
        SpecificMovement.ChangeCompany(Rec.CurrentCompany);
        if SpecificMovement.Get(Rec.Code) then
            SpecificMovement.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif