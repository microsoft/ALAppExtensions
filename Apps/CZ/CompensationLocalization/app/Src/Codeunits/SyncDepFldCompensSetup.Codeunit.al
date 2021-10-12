#if not CLEAN18
#pragma warning disable AL0603, AL0432, AA0072
codeunit 31291 "Sync.Dep.Fld-CompensSetup CZC"
{
    Access = Internal;
    Permissions = tabledata "Credits Setup" = rimd,
                  tabledata "Compensations Setup CZC" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Credits Setup", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCreditsSetup(var Rec: Record "Credits Setup"; var xRec: Record "Credits Setup")
    var
        CompensationSetupCZC: Record "Compensations Setup CZC";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Credits Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Compensations Setup CZC");
        CompensationSetupCZC.ChangeCompany(Rec.CurrentCompany);
        if CompensationSetupCZC.Get(xRec."Primary Key") then
            CompensationSetupCZC.Rename(Rec."Primary Key");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Compensations Setup CZC");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Credits Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCreditsSetup(var Rec: Record "Credits Setup")
    begin
        SyncCreditsSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Credits Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCreditsSetup(var Rec: Record "Credits Setup")
    begin
        SyncCreditsSetup(Rec);
    end;

    local procedure SyncCreditsSetup(var Rec: Record "Credits Setup")
    var
        CompensationSetupCZC: Record "Compensations Setup CZC";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Credits Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Compensations Setup CZC");
        CompensationSetupCZC.ChangeCompany(Rec.CurrentCompany);
        if not CompensationSetupCZC.Get(Rec."Primary Key") then begin
            CompensationSetupCZC.Init();
            CompensationSetupCZC."Primary Key" := Rec."Primary Key";
            CompensationSetupCZC.SystemId := Rec.SystemId;
            CompensationSetupCZC.Insert(false, true);
        end;
        CompensationSetupCZC."Compensation Nos." := Rec."Credit Nos.";
        CompensationSetupCZC."Compensation Bal. Account No." := Rec."Credit Bal. Account No.";
        CompensationSetupCZC."Max. Rounding Amount" := Rec."Max. Rounding Amount";
        CompensationSetupCZC."Debit Rounding Account" := Rec."Debit Rounding Account";
        CompensationSetupCZC."Credit Rounding Account" := Rec."Credit Rounding Account";
        CompensationSetupCZC."Compensation Proposal Method" := Rec."Credit Proposal By";
        CompensationSetupCZC."Show Empty when not Found" := Rec."Show Empty when not Found";
        CompensationSetupCZC.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Compensations Setup CZC");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Credits Setup", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCreditsSetup(var Rec: Record "Credits Setup")
    var
        CompensationSetupCZC: Record "Compensations Setup CZC";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Credits Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Compensations Setup CZC");
        CompensationSetupCZC.ChangeCompany(Rec.CurrentCompany);
        if CompensationSetupCZC.Get(Rec."Primary Key") then
            CompensationSetupCZC.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Compensations Setup CZC");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Compensations Setup CZC", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCompensationsSetupCZC(var Rec: Record "Compensations Setup CZC"; var xRec: Record "Compensations Setup CZC")
    var
        CreditsSetup: Record "Credits Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Compensations Setup CZC") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Credits Setup");
        CreditsSetup.ChangeCompany(Rec.CurrentCompany);
        if CreditsSetup.Get(xRec."Primary Key") then
            CreditsSetup.Rename(Rec."Primary Key");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Credits Setup");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Compensations Setup CZC", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCompensationsSetupCZC(var Rec: Record "Compensations Setup CZC")
    begin
        SyncCompensationSetupCZC(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Compensations Setup CZC", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCompensationsSetupCZC(var Rec: Record "Compensations Setup CZC")
    begin
        SyncCompensationSetupCZC(Rec);
    end;

    local procedure SyncCompensationSetupCZC(var Rec: Record "Compensations Setup CZC")
    var
        CreditsSetup: Record "Credits Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Compensations Setup CZC") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Credits Setup");
        CreditsSetup.ChangeCompany(Rec.CurrentCompany);
        if not CreditsSetup.Get(Rec."Primary Key") then begin
            CreditsSetup.Init();
            CreditsSetup."Primary Key" := Rec."Primary Key";
            CreditsSetup.SystemId := Rec.SystemId;
            CreditsSetup.Insert(false, true);
        end;
        CreditsSetup."Credit Nos." := Rec."Compensation Nos.";
        CreditsSetup."Credit Bal. Account No." := Rec."Compensation Bal. Account No.";
        CreditsSetup."Max. Rounding Amount" := Rec."Max. Rounding Amount";
        CreditsSetup."Debit Rounding Account" := Rec."Debit Rounding Account";
        CreditsSetup."Credit Rounding Account" := Rec."Credit Rounding Account";
        CreditsSetup."Credit Proposal By" := Rec."Compensation Proposal Method".AsInteger();
        CreditsSetup."Show Empty when not Found" := Rec."Show Empty when not Found";
        CreditsSetup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Credits Setup");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Compensations Setup CZC", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCompensationsSetupCZC(var Rec: Record "Compensations Setup CZC")
    var
        CreditsSetup: Record "Credits Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Compensations Setup CZC") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Credits Setup");
        CreditsSetup.ChangeCompany(Rec.CurrentCompany);
        if CreditsSetup.Get(Rec."Primary Key") then
            CreditsSetup.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Credits Setup");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif