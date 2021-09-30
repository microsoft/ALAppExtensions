#if not CLEAN18
#pragma warning disable AL0432
codeunit 31213 "Sync.Dep.Fld-IntrsDelivGrp CZL"
{
    Permissions = tabledata "Intrastat Delivery Group" = rimd,
                  tabledata "Intrastat Delivery Group CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIntrastatDeliveryGroup(var Rec: Record "Intrastat Delivery Group"; var xRec: Record "Intrastat Delivery Group")
    var
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group CZL");
        IntrastatDeliveryGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if IntrastatDeliveryGroupCZL.Get(xRec.Code) then
            IntrastatDeliveryGroupCZL.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIntrastatDeliveryGroup(var Rec: Record "Intrastat Delivery Group")
    begin
        SyncIntrastatDeliveryGroup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIntrastatDeliveryGroup(var Rec: Record "Intrastat Delivery Group")
    begin
        SyncIntrastatDeliveryGroup(Rec);
    end;

    local procedure SyncIntrastatDeliveryGroup(var Rec: Record "Intrastat Delivery Group")
    var
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group") then
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

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIntrastatDeliveryGroup(var Rec: Record "Intrastat Delivery Group")
    var
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group CZL");
        IntrastatDeliveryGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if IntrastatDeliveryGroupCZL.Get(Rec.Code) then
            IntrastatDeliveryGroupCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIntrastatDeliveryGroupCZL(var Rec: Record "Intrastat Delivery Group CZL"; var xRec: Record "Intrastat Delivery Group CZL")
    var
        IntrastatDeliveryGroup: Record "Intrastat Delivery Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group");
        IntrastatDeliveryGroup.ChangeCompany(Rec.CurrentCompany);
        if IntrastatDeliveryGroup.Get(xRec.Code) then
            IntrastatDeliveryGroup.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIntrastatDeliveryGroupCZL(var Rec: Record "Intrastat Delivery Group CZL")
    begin
        SyncIntrastatDeliveryGroupCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIntrastatDeliveryGroupCZL(var Rec: Record "Intrastat Delivery Group CZL")
    begin
        SyncIntrastatDeliveryGroupCZL(Rec);
    end;

    local procedure SyncIntrastatDeliveryGroupCZL(var Rec: Record "Intrastat Delivery Group CZL")
    var
        IntrastatDeliveryGroup: Record "Intrastat Delivery Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group");
        IntrastatDeliveryGroup.ChangeCompany(Rec.CurrentCompany);
        if not IntrastatDeliveryGroup.Get(Rec.Code) then begin
            IntrastatDeliveryGroup.Init();
            IntrastatDeliveryGroup.Code := CopyStr(Rec.Code, 1, MaxStrLen(IntrastatDeliveryGroup.Code));
            IntrastatDeliveryGroup.SystemId := Rec.SystemId;
            IntrastatDeliveryGroup.Insert(false, true);
        end;
        IntrastatDeliveryGroup.Description := CopyStr(Rec.Description, 1, MaxStrLen(IntrastatDeliveryGroup.Description));
        IntrastatDeliveryGroup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Delivery Group CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIntrastatDeliveryGroupCZL(var Rec: Record "Intrastat Delivery Group CZL")
    var
        IntrastatDeliveryGroup: Record "Intrastat Delivery Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Delivery Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Delivery Group");
        IntrastatDeliveryGroup.ChangeCompany(Rec.CurrentCompany);
        if IntrastatDeliveryGroup.Get(Rec.Code) then
            IntrastatDeliveryGroup.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Delivery Group");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif