#if not CLEAN22
#pragma warning disable AL0432
codeunit 31290 "Sync.Dep.Fld-IntDeliveryGr CZ"
{
    Access = Internal;
    Permissions = tabledata "Intrastat Delivery Group CZL" = rimd,
                  tabledata "Intrastat Delivery Group CZ" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIntrastatDeliveryGroupCZL(var Rec: Record "Intrastat Delivery Group CZL"; var xRec: Record "Intrastat Delivery Group CZL")
    var
        IntrastatDeliveryGroupCZ: Record "Intrastat Delivery Group CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group CZ");
        IntrastatDeliveryGroupCZ.ChangeCompany(Rec.CurrentCompany);
        if IntrastatDeliveryGroupCZ.Get(xRec.Code) then
            IntrastatDeliveryGroupCZ.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIntrastatDeliveryGroupCZL(var Rec: Record "Intrastat Delivery Group CZL")
    var
        IntrastatDeliveryGroupCZ: Record "Intrastat Delivery Group CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group CZ");
        IntrastatDeliveryGroupCZ.ChangeCompany(Rec.CurrentCompany);
        if not IntrastatDeliveryGroupCZ.Get(Rec.Code) then begin
            IntrastatDeliveryGroupCZ.Init();
            IntrastatDeliveryGroupCZ.Code := Rec.Code;
            IntrastatDeliveryGroupCZ.Description := Rec.Description;
            IntrastatDeliveryGroupCZ.SystemId := Rec.SystemId;
            IntrastatDeliveryGroupCZ.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIntrastatDeliveryGroupCZL(var Rec: Record "Intrastat Delivery Group CZL")
    var
        IntrastatDeliveryGroupCZ: Record "Intrastat Delivery Group CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group CZ");
        IntrastatDeliveryGroupCZ.ChangeCompany(Rec.CurrentCompany);
        if not IntrastatDeliveryGroupCZ.Get(Rec.Code) then begin
            IntrastatDeliveryGroupCZ.Init();
            IntrastatDeliveryGroupCZ.Code := Rec.Code;
            IntrastatDeliveryGroupCZ.SystemId := Rec.SystemId;
            IntrastatDeliveryGroupCZ.Insert(false, true);
        end;
        IntrastatDeliveryGroupCZ.Description := Rec.Description;
        IntrastatDeliveryGroupCZ.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIntrastatDeliveryGroupCZL(var Rec: Record "Intrastat Delivery Group CZL")
    var
        IntrastatDeliveryGroupCZ: Record "Intrastat Delivery Group CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group CZ");
        IntrastatDeliveryGroupCZ.ChangeCompany(Rec.CurrentCompany);
        if IntrastatDeliveryGroupCZ.Get(Rec.Code) then
            IntrastatDeliveryGroupCZ.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZ", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIntrastatDeliveryGroupCZ(var Rec: Record "Intrastat Delivery Group CZ"; var xRec: Record "Intrastat Delivery Group CZ")
    var
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group CZ") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group CZL");
        IntrastatDeliveryGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if IntrastatDeliveryGroupCZL.Get(xRec.Code) then
            IntrastatDeliveryGroupCZL.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZ", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIntrastatDeliveryGroupCZ(var Rec: Record "Intrastat Delivery Group CZ")
    var
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group CZ") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group CZL");
        IntrastatDeliveryGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if not IntrastatDeliveryGroupCZL.Get(Rec.Code) then begin
            IntrastatDeliveryGroupCZL.Init();
            IntrastatDeliveryGroupCZL.Code := Rec.Code;
            IntrastatDeliveryGroupCZL.Description := Rec.Description;
            IntrastatDeliveryGroupCZL.SystemId := Rec.SystemId;
            IntrastatDeliveryGroupCZL.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZ", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIntrastatDeliveryGroupCZ(var Rec: Record "Intrastat Delivery Group CZ")
    var
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group CZ") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group CZL");
        IntrastatDeliveryGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if not IntrastatDeliveryGroupCZL.Get(Rec.Code) then begin
            IntrastatDeliveryGroupCZL.Init();
            IntrastatDeliveryGroupCZL.Code := Rec.Code;
            IntrastatDeliveryGroupCZL.SystemId := Rec.SystemId;
            IntrastatDeliveryGroupCZL.Insert(false, true);
        end;
        IntrastatDeliveryGroupCZL.Description := Rec.Description;
        IntrastatDeliveryGroupCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZ", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIntrastatDeliveryGroupCZ(var Rec: Record "Intrastat Delivery Group CZ")
    var
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group CZ") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group CZL");
        IntrastatDeliveryGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if IntrastatDeliveryGroupCZL.Get(Rec.Code) then
            IntrastatDeliveryGroupCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group CZL");
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