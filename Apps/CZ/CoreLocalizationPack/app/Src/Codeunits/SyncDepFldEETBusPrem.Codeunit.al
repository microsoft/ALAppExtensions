#if not CLEAN18
#pragma warning disable AL0432
codeunit 31136 "Sync.Dep.Fld-EETBusPrem CZL"
{
    Permissions = tabledata "EET Business Premises" = rimd,
                  tabledata "EET Business Premises CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"EET Business Premises", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameEETBusinessPremises(var Rec: Record "EET Business Premises"; var xRec: Record "EET Business Premises")
    var
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Business Premises") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Business Premises CZL");
        EETBusinessPremisesCZL.ChangeCompany(Rec.CurrentCompany);
        if EETBusinessPremisesCZL.Get(xRec.Code) then
            EETBusinessPremisesCZL.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Business Premises CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Business Premises", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertEETBusinessPremises(var Rec: Record "EET Business Premises")
    begin
        SyncEETBusinessPremises(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Business Premises", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyEETBusinessPremises(var Rec: Record "EET Business Premises")
    begin
        SyncEETBusinessPremises(Rec);
    end;

    local procedure SyncEETBusinessPremises(var EETBusinessPremises: Record "EET Business Premises")
    var
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if EETBusinessPremises.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Business Premises") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Business Premises CZL");
        EETBusinessPremisesCZL.ChangeCompany(EETBusinessPremises.CurrentCompany);
        if not EETBusinessPremisesCZL.Get(EETBusinessPremises.Code) then begin
            EETBusinessPremisesCZL.Init();
            EETBusinessPremisesCZL.Code := EETBusinessPremises.Code;
            EETBusinessPremisesCZL.SystemId := EETBusinessPremises.SystemId;
            EETBusinessPremisesCZL.Insert(false, true);
        end;
        EETBusinessPremisesCZL.Description := EETBusinessPremises.Description;
        EETBusinessPremisesCZL.Identification := EETBusinessPremises.Identification;
        EETBusinessPremisesCZL."Certificate Code" := EETBusinessPremises."Certificate Code";
        EETBusinessPremisesCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Business Premises CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Business Premises", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteEETBusinessPremises(var Rec: Record "EET Business Premises")
    var
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Business Premises") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Business Premises CZL");
        EETBusinessPremisesCZL.ChangeCompany(Rec.CurrentCompany);
        if EETBusinessPremisesCZL.Get(Rec.Code) then
            EETBusinessPremisesCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Business Premises CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Business Premises CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameEETBusinessPremisesCZL(var Rec: Record "EET Business Premises CZL"; var xRec: Record "EET Business Premises CZL")
    var
        EETBusinessPremises: Record "EET Business Premises";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Business Premises CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Business Premises");
        EETBusinessPremises.ChangeCompany(Rec.CurrentCompany);
        if EETBusinessPremises.Get(xRec.Code) then
            EETBusinessPremises.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Business Premises");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Business Premises CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertEETBusinessPremisesCZL(var Rec: Record "EET Business Premises CZL")
    begin
        SyncEETBusinessPremisesCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Business Premises CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyEETBusinessPremisesCZL(var Rec: Record "EET Business Premises CZL")
    begin
        SyncEETBusinessPremisesCZL(Rec);
    end;

    local procedure SyncEETBusinessPremisesCZL(var EETBusinessPremisesCZL: Record "EET Business Premises CZL")
    var
        EETBusinessPremises: Record "EET Business Premises";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if EETBusinessPremisesCZL.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Business Premises CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Business Premises");
        EETBusinessPremises.ChangeCompany(EETBusinessPremisesCZL.CurrentCompany);
        if not EETBusinessPremises.Get(EETBusinessPremisesCZL.Code) then begin
            EETBusinessPremises.Init();
            EETBusinessPremises.Code := EETBusinessPremisesCZL.Code;
            EETBusinessPremises.SystemId := EETBusinessPremisesCZL.SystemId;
            EETBusinessPremises.Insert(false, true);
        end;
        EETBusinessPremises.Description := EETBusinessPremisesCZL.Description;
        EETBusinessPremises.Identification := EETBusinessPremisesCZL.Identification;
        EETBusinessPremises."Certificate Code" := EETBusinessPremisesCZL."Certificate Code";
        EETBusinessPremises.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Business Premises");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Business Premises CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteEETBusinessPremisesCZL(var Rec: Record "EET Business Premises CZL")
    var
        EETBusinessPremises: Record "EET Business Premises";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Business Premises CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Business Premises");
        EETBusinessPremises.ChangeCompany(Rec.CurrentCompany);
        if EETBusinessPremises.Get(Rec.Code) then
            EETBusinessPremises.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Business Premises");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif