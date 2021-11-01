#if not CLEAN18
#pragma warning disable AL0432,AA0072
codeunit 31301 "Sync.Dep.Fld-Classif. Code CZF"
{
    Access = Internal;
    Permissions = tabledata "Classification Code" = rimd,
                  tabledata "Classification Code CZF" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Classification Code", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameClassificationCode(var Rec: Record "Classification Code"; var xRec: Record "Classification Code")
    var
        ClassificationCodeCZF: Record "Classification Code CZF";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Classification Code") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Classification Code CZF");
        ClassificationCodeCZF.ChangeCompany(Rec.CurrentCompany);
        if ClassificationCodeCZF.Get(xRec.Code) then
            ClassificationCodeCZF.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Classification Code CZF");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Classification Code", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertClassificationCode(var Rec: Record "Classification Code")
    begin
        SyncClassificationCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Classification Code", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyClassificationCode(var Rec: Record "Classification Code")
    begin
        SyncClassificationCode(Rec);
    end;

    local procedure SyncClassificationCode(var Rec: Record "Classification Code")
    var
        ClassificationCodeCZF: Record "Classification Code CZF";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Classification Code") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Classification Code CZF");
        ClassificationCodeCZF.ChangeCompany(Rec.CurrentCompany);
        if not ClassificationCodeCZF.Get(Rec.Code) then begin
            ClassificationCodeCZF.Init();
            ClassificationCodeCZF.Code := Rec.Code;
            ClassificationCodeCZF.SystemId := Rec.SystemId;
            ClassificationCodeCZF.Insert(false, true);
        end;
        ClassificationCodeCZF.Description := Rec.Description;
#pragma warning disable AL0603
        ClassificationCodeCZF."Classification Type" := Rec."Classification Type";
#pragma warning restore AL0603
        ClassificationCodeCZF.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Classification Code CZF");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Classification Code", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteClassificationCode(var Rec: Record "Classification Code")
    var
        ClassificationCodeCZF: Record "Classification Code CZF";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Classification Code") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Classification Code CZF");
        ClassificationCodeCZF.ChangeCompany(Rec.CurrentCompany);
        if ClassificationCodeCZF.Get(Rec.Code) then
            ClassificationCodeCZF.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Classification Code CZF");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Classification Code CZF", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameClassificationCodeCZF(var Rec: Record "Classification Code CZF"; var xRec: Record "Classification Code CZF")
    var
        ClassificationCode: Record "Classification Code";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Classification Code CZF") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Classification Code");
        ClassificationCode.ChangeCompany(Rec.CurrentCompany);
        if ClassificationCode.Get(xRec.Code) then
            ClassificationCode.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Classification Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Classification Code CZF", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertClassificationCodeCZF(var Rec: Record "Classification Code CZF")
    begin
        SyncClassificationCodeCZF(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Classification Code CZF", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyClassificationCodeCZF(var Rec: Record "Classification Code CZF")
    begin
        SyncClassificationCodeCZF(Rec);
    end;

    local procedure SyncClassificationCodeCZF(var Rec: Record "Classification Code CZF")
    var
        ClassificationCode: Record "Classification Code";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if DataUpgradeMgt.IsUpgradeInProgress() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Classification Code CZF") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Classification Code");
        ClassificationCode.ChangeCompany(Rec.CurrentCompany);
        if not ClassificationCode.Get(Rec.Code) then begin
            ClassificationCode.Init();
            ClassificationCode.Code := Rec.Code;
            ClassificationCode.SystemId := Rec.SystemId;
            ClassificationCode.Insert(false, true);
        end;
        ClassificationCode.Description := Rec.Description;
        ClassificationCode."Classification Type" := Rec."Classification Type".AsInteger();
        ClassificationCode.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Classification Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Classification Code CZF", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeletelassificationCodeCZF(var Rec: Record "Classification Code CZF")
    var
        ClassificationCode: Record "Classification Code";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Classification Code CZF") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Classification Code");
        ClassificationCode.ChangeCompany(Rec.CurrentCompany);
        if ClassificationCode.Get(Rec.Code) then
            ClassificationCode.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Classification Code");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif
