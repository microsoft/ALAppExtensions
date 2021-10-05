#if not CLEAN18
#pragma warning disable AL0432
codeunit 31210 "Sync.Dep.Fld-UnrPaySvcSet CZL"
{
#if not CLEAN17
    Permissions = tabledata "Electronically Govern. Setup" = rimd,
                  tabledata "Unrel. Payer Service Setup CZL" = rimd;
#endif
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

#if not CLEAN17
    [EventSubscriber(ObjectType::Table, Database::"Electronically Govern. Setup", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameElectronicallyGovernSetup(var Rec: Record "Electronically Govern. Setup"; var xRec: Record "Electronically Govern. Setup")
    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Electronically Govern. Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Unrel. Payer Service Setup CZL");
        UnrelPayerServiceSetupCZL.ChangeCompany(Rec.CurrentCompany);
        if UnrelPayerServiceSetupCZL.Get(xRec."Primary Key") then
            UnrelPayerServiceSetupCZL.Rename(Rec."Primary Key");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Unrel. Payer Service Setup CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Electronically Govern. Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertElectronicallyGovernSetup(var Rec: Record "Electronically Govern. Setup")
    begin
        SyncElectronicallyGovernSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Electronically Govern. Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyElectronicallyGovernSetup(var Rec: Record "Electronically Govern. Setup")
    begin
        SyncElectronicallyGovernSetup(Rec);
    end;

    local procedure SyncElectronicallyGovernSetup(var Rec: Record "Electronically Govern. Setup")
    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Electronically Govern. Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Unrel. Payer Service Setup CZL");
        UnrelPayerServiceSetupCZL.ChangeCompany(Rec.CurrentCompany);
        if not UnrelPayerServiceSetupCZL.Get(Rec."Primary Key") then begin
            UnrelPayerServiceSetupCZL.Init();
            UnrelPayerServiceSetupCZL."Primary Key" := Rec."Primary Key";
            UnrelPayerServiceSetupCZL.SystemId := Rec.SystemId;
            UnrelPayerServiceSetupCZL.Insert(false, true);
        end;
        UnrelPayerServiceSetupCZL."Public Bank Acc.Chck.Star.Date" := Rec."Public Bank Acc.Chck.Star.Date";
        UnrelPayerServiceSetupCZL."Public Bank Acc.Check Limit" := Rec."Public Bank Acc.Check Limit";
        UnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit" := Rec."Unc.Payer Request Record Limit";
        UnrelPayerServiceSetupCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Unrel. Payer Service Setup CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Electronically Govern. Setup", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteElectronicallyGovernSetup(var Rec: Record "Electronically Govern. Setup")
    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Electronically Govern. Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Unrel. Payer Service Setup CZL");
        UnrelPayerServiceSetupCZL.ChangeCompany(Rec.CurrentCompany);
        if UnrelPayerServiceSetupCZL.Get(Rec."Primary Key") then
            UnrelPayerServiceSetupCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Unrel. Payer Service Setup CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unrel. Payer Service Setup CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameUnrelPayerServiceSetupCZL(var Rec: Record "Unrel. Payer Service Setup CZL"; var xRec: Record "Unrel. Payer Service Setup CZL")
    var
        ElectronicallyGovernSetup: Record "Electronically Govern. Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Unrel. Payer Service Setup CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Electronically Govern. Setup");
        ElectronicallyGovernSetup.ChangeCompany(Rec.CurrentCompany);
        if ElectronicallyGovernSetup.Get(xRec."Primary Key") then
            ElectronicallyGovernSetup.Rename(Rec."Primary Key");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Electronically Govern. Setup");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unrel. Payer Service Setup CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertUnrelPayerServiceSetupCZL(var Rec: Record "Unrel. Payer Service Setup CZL")
    begin
        SyncUnrelPayerServiceSetupCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unrel. Payer Service Setup CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyUnrelPayerServiceSetupCZL(var Rec: Record "Unrel. Payer Service Setup CZL")
    begin
        SyncUnrelPayerServiceSetupCZL(Rec);
    end;

    local procedure SyncUnrelPayerServiceSetupCZL(var Rec: Record "Unrel. Payer Service Setup CZL")
    var
        ElectronicallyGovernSetup: Record "Electronically Govern. Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Unrel. Payer Service Setup CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Electronically Govern. Setup");
        ElectronicallyGovernSetup.ChangeCompany(Rec.CurrentCompany);
        if not ElectronicallyGovernSetup.Get(Rec."Primary Key") then begin
            ElectronicallyGovernSetup.Init();
            ElectronicallyGovernSetup."Primary Key" := Rec."Primary Key";
            ElectronicallyGovernSetup.SystemId := Rec.SystemId;
            ElectronicallyGovernSetup.Insert(false, true);
        end;
        ElectronicallyGovernSetup."Public Bank Acc.Chck.Star.Date" := Rec."Public Bank Acc.Chck.Star.Date";
        ElectronicallyGovernSetup."Public Bank Acc.Check Limit" := Rec."Public Bank Acc.Check Limit";
        ElectronicallyGovernSetup."Unc.Payer Request Record Limit" := Rec."Unr.Payer Request Record Limit";
        ElectronicallyGovernSetup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Electronically Govern. Setup");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unrel. Payer Service Setup CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteUnrelPayerServiceSetupCZL(var Rec: Record "Unrel. Payer Service Setup CZL")
    var
        ElectronicallyGovernSetup: Record "Electronically Govern. Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Unrel. Payer Service Setup CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Electronically Govern. Setup");
        ElectronicallyGovernSetup.ChangeCompany(Rec.CurrentCompany);
        if ElectronicallyGovernSetup.Get(Rec."Primary Key") then
            ElectronicallyGovernSetup.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Electronically Govern. Setup");
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