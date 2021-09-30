#if not CLEAN18
#pragma warning disable AL0432
codeunit 31137 "Sync.Dep.Fld-EETCashReg CZL"
{
    Permissions = tabledata "EET Cash Register" = rimd,
                  tabledata "EET Cash Register CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"EET Cash Register", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameEETCashRegister(var Rec: Record "EET Cash Register"; var xRec: Record "EET Cash Register")
    var
        EETCashRegisterCZL: Record "EET Cash Register CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Cash Register") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Cash Register CZL");
        EETCashRegisterCZL.ChangeCompany(Rec.CurrentCompany);
        if EETCashRegisterCZL.Get(xRec."Business Premises Code", xRec.Code) then
            EETCashRegisterCZL.Rename(Rec."Business Premises Code", Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Cash Register CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Cash Register", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertEETCashRegister(var Rec: Record "EET Cash Register")
    begin
        SyncEETCashRegister(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Cash Register", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyEETCashRegister(var Rec: Record "EET Cash Register")
    begin
        SyncEETCashRegister(Rec);
    end;

    local procedure SyncEETCashRegister(var EETCashRegister: Record "EET Cash Register")
    var
        EETCashRegisterCZL: Record "EET Cash Register CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if EETCashRegister.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Cash Register") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Cash Register CZL");
        EETCashRegisterCZL.ChangeCompany(EETCashRegister.CurrentCompany);
        if not EETCashRegisterCZL.Get(EETCashRegister."Business Premises Code", EETCashRegister.Code) then begin
            EETCashRegisterCZL.Init();
            EETCashRegisterCZL."Business Premises Code" := EETCashRegister."Business Premises Code";
            EETCashRegisterCZL.Code := EETCashRegister.Code;
            EETCashRegisterCZL.SystemId := EETCashRegister.SystemId;
            EETCashRegisterCZL.Insert(false, true);
        end;
        EETCashRegisterCZL."Cash Register Type" := "EET Cash Register Type CZL".FromInteger(EETCashRegister."Register Type");
        EETCashRegisterCZL."Cash Register No." := EETCashRegister."Register No.";
        EETCashRegisterCZL."Cash Register Name" := EETCashRegister."Register Name";
        EETCashRegisterCZL."Certificate Code" := EETCashRegister."Certificate Code";
        EETCashRegisterCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Cash Register CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Cash Register", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteEETCashRegister(var Rec: Record "EET Cash Register")
    var
        EETCashRegisterCZL: Record "EET Cash Register CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Cash Register") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Cash Register CZL");
        EETCashRegisterCZL.ChangeCompany(Rec.CurrentCompany);
        if EETCashRegisterCZL.Get(Rec."Business Premises Code", Rec.Code) then
            EETCashRegisterCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Cash Register CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Cash Register CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameEETCashRegisterCZL(var Rec: Record "EET Cash Register CZL"; var xRec: Record "EET Cash Register CZL")
    var
        EETCashRegister: Record "EET Cash Register";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Cash Register CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Cash Register");
        EETCashRegister.ChangeCompany(Rec.CurrentCompany);
        if EETCashRegister.Get(xRec."Business Premises Code", xRec.Code) then
            EETCashRegister.Rename(Rec."Business Premises Code", Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Cash Register");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Cash Register CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertEETCashRegisterCZL(var Rec: Record "EET Cash Register CZL")
    begin
        SyncEETCashRegisterCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Cash Register CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyEETCashRegisterCZL(var Rec: Record "EET Cash Register CZL")
    begin
        SyncEETCashRegisterCZL(Rec);
    end;

    local procedure SyncEETCashRegisterCZL(var EETCashRegisterCZL: Record "EET Cash Register CZL")
    var
        EETCashRegister: Record "EET Cash Register";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if EETCashRegisterCZL.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Cash Register CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Cash Register");
        EETCashRegister.ChangeCompany(EETCashRegisterCZL.CurrentCompany);
        if not EETCashRegister.Get(EETCashRegisterCZL."Business Premises Code", EETCashRegisterCZL.Code) then begin
            EETCashRegister.Init();
            EETCashRegister."Business Premises Code" := EETCashRegisterCZL."Business Premises Code";
            EETCashRegister.Code := EETCashRegisterCZL.Code;
            EETCashRegister.SystemId := EETCashRegisterCZL.SystemId;
            EETCashRegister.Insert(false, true);
        end;
        EETCashRegister."Register Type" := EETCashRegisterCZL."Cash Register Type".AsInteger();
        EETCashRegister."Register No." := EETCashRegisterCZL."Cash Register No.";
        EETCashRegister."Register Name" := CopyStr(EETCashRegisterCZL."Cash Register Name", 1, MaxStrLen(EETCashRegister."Register Name"));
        EETCashRegister."Certificate Code" := EETCashRegisterCZL."Certificate Code";
        EETCashRegister.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Cash Register");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Cash Register CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteEETCashRegisterCZL(var Rec: Record "EET Cash Register CZL")
    var
        EETCashRegister: Record "EET Cash Register";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Cash Register CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Cash Register");
        EETCashRegister.ChangeCompany(Rec.CurrentCompany);
        if EETCashRegister.Get(Rec."Business Premises Code", Rec.Code) then
            EETCashRegister.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Cash Register");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif