#if not CLEAN22
#pragma warning disable AL0432
codeunit 31293 "Sync.Dep.Fld-SpecMovement CZ"
{
    Access = Internal;
    Permissions = tabledata "Specific Movement CZL" = rimd,
                  tabledata "Specific Movement CZ" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameSpecificMovementCZL(var Rec: Record "Specific Movement CZL"; var xRec: Record "Specific Movement CZL")
    var
        SpecificMovementCZ: Record "Specific Movement CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement CZ");
        SpecificMovementCZ.ChangeCompany(Rec.CurrentCompany);
        if SpecificMovementCZ.Get(xRec.Code) then
            SpecificMovementCZ.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSpecificMovementCZL(var Rec: Record "Specific Movement CZL")
    var
        SpecificMovementCZ: Record "Specific Movement CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement CZ");
        SpecificMovementCZ.ChangeCompany(Rec.CurrentCompany);
        if not SpecificMovementCZ.Get(Rec.Code) then begin
            SpecificMovementCZ.Init();
            SpecificMovementCZ.Code := Rec.Code;
            SpecificMovementCZ.Description := Rec.Description;
            SpecificMovementCZ.SystemId := Rec.SystemId;
            SpecificMovementCZ.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifySpecificMovementCZL(var Rec: Record "Specific Movement CZL")
    var
        SpecificMovementCZ: Record "Specific Movement CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement CZ");
        SpecificMovementCZ.ChangeCompany(Rec.CurrentCompany);
        if not SpecificMovementCZ.Get(Rec.Code) then begin
            SpecificMovementCZ.Init();
            SpecificMovementCZ.Code := Rec.Code;
            SpecificMovementCZ.SystemId := Rec.SystemId;
            SpecificMovementCZ.Insert(false, true);
        end;
        SpecificMovementCZ.Description := Rec.Description;
        SpecificMovementCZ.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteSpecificMovementCZL(var Rec: Record "Specific Movement CZL")
    var
        SpecificMovementCZ: Record "Specific Movement CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement CZ");
        SpecificMovementCZ.ChangeCompany(Rec.CurrentCompany);
        if SpecificMovementCZ.Get(Rec.Code) then
            SpecificMovementCZ.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZ", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameSpecificMovementCZ(var Rec: Record "Specific Movement CZ"; var xRec: Record "Specific Movement CZ")
    var
        SpecificMovementCZL: Record "Specific Movement CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement CZ") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement CZL");
        SpecificMovementCZL.ChangeCompany(Rec.CurrentCompany);
        if SpecificMovementCZL.Get(xRec.Code) then
            SpecificMovementCZL.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZ", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSpecificMovementCZ(var Rec: Record "Specific Movement CZ")
    var
        SpecificMovementCZL: Record "Specific Movement CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement CZ") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement CZL");
        SpecificMovementCZL.ChangeCompany(Rec.CurrentCompany);
        if not SpecificMovementCZL.Get(Rec.Code) then begin
            SpecificMovementCZL.Init();
            SpecificMovementCZL.Code := Rec.Code;
            SpecificMovementCZL.Description := Rec.Description;
            SpecificMovementCZL.SystemId := Rec.SystemId;
            SpecificMovementCZL.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZ", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifySpecificMovementCZ(var Rec: Record "Specific Movement CZ")
    var
        SpecificMovementCZL: Record "Specific Movement CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement CZ") then
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

    [EventSubscriber(ObjectType::Table, Database::"Specific Movement CZ", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteSpecificMovementCZ(var Rec: Record "Specific Movement CZ")
    var
        SpecificMovementCZL: Record "Specific Movement CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Specific Movement CZ") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Specific Movement CZL");
        SpecificMovementCZL.ChangeCompany(Rec.CurrentCompany);
        if SpecificMovementCZL.Get(Rec.Code) then
            SpecificMovementCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Specific Movement CZL");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#pragma warning restore AL0432
#endif