#if not CLEAN18
#pragma warning disable AL0432,AA0072
codeunit 31307 "Sync.Dep.Fld-FAExtPostGr CZF"
{
    Access = Internal;
    Permissions = tabledata "FA Extended Posting Group" = rimd,
                  tabledata "FA Extended Posting Group CZF" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"FA Extended Posting Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameFAExtendedPostingGroup(var Rec: Record "FA Extended Posting Group"; var xRec: Record "FA Extended Posting Group")
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"FA Extended Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"FA Extended Posting Group CZF");
        FAExtendedPostingGroupCZF.ChangeCompany(Rec.CurrentCompany);
        if FAExtendedPostingGroupCZF.Get(xRec."FA Posting Group Code", xRec."FA Posting Type", xRec.Code) then
            FAExtendedPostingGroupCZF.Rename(Rec."FA Posting Group Code", Rec."FA Posting Type", Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"FA Extended Posting Group CZF");
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Extended Posting Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertFAExtendedPostingGroup(var Rec: Record "FA Extended Posting Group")
    begin
        SyncFAExtendedPostingGroup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Extended Posting Group", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyFAExtendedPostingGroup(var Rec: Record "FA Extended Posting Group")
    begin
        SyncFAExtendedPostingGroup(Rec);
    end;

    local procedure SyncFAExtendedPostingGroup(var Rec: Record "FA Extended Posting Group")
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"FA Extended Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"FA Extended Posting Group CZF");
        FAExtendedPostingGroupCZF.ChangeCompany(Rec.CurrentCompany);
        if not FAExtendedPostingGroupCZF.Get(Rec."FA Posting Group Code", Rec."FA Posting Type", Rec.Code) then begin
            FAExtendedPostingGroupCZF.Init();
            FAExtendedPostingGroupCZF."FA Posting Group Code" := Rec."FA Posting Group Code";
#pragma warning disable AL0603
            FAExtendedPostingGroupCZF."FA Posting Type" := Rec."FA Posting Type";
#pragma warning restore AL0603
            FAExtendedPostingGroupCZF.Code := Rec.Code;
            FAExtendedPostingGroupCZF.SystemId := Rec.SystemId;
            FAExtendedPostingGroupCZF.Insert(false, true);
        end;
        FAExtendedPostingGroupCZF."Book Val. Acc. on Disp. (Gain)" := Rec."Book Val. Acc. on Disp. (Gain)";
        FAExtendedPostingGroupCZF."Book Val. Acc. on Disp. (Loss)" := Rec."Book Val. Acc. on Disp. (Loss)";
        FAExtendedPostingGroupCZF."Maintenance Expense Account" := Rec."Maintenance Expense Account";
        FAExtendedPostingGroupCZF."Maintenance Balance Account" := Rec."Maintenance Bal. Acc.";
        FAExtendedPostingGroupCZF."Sales Acc. On Disp. (Gain)" := Rec."Sales Acc. On Disp. (Gain)";
        FAExtendedPostingGroupCZF."Sales Acc. On Disp. (Loss)" := Rec."Sales Acc. On Disp. (Loss)";
        FAExtendedPostingGroupCZF.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"FA Extended Posting Group CZF");
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Extended Posting Group", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteFAExtendedPostingGroup(var Rec: Record "FA Extended Posting Group")
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"FA Extended Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"FA Extended Posting Group CZF");
        FAExtendedPostingGroupCZF.ChangeCompany(Rec.CurrentCompany);
        if FAExtendedPostingGroupCZF.Get(Rec."FA Posting Group Code", Rec."FA Posting Type", Rec.Code) then
            FAExtendedPostingGroupCZF.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"FA Extended Posting Group CZF");
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Extended Posting Group CZF", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameFAExtendedPostingGroupCZF(var Rec: Record "FA Extended Posting Group CZF"; var xRec: Record "FA Extended Posting Group CZF")
    var
        FAExtendedPostingGroup: Record "FA Extended Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"FA Extended Posting Group CZF") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"FA Extended Posting Group");
        FAExtendedPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if FAExtendedPostingGroup.Get(xRec."FA Posting Group Code", xRec."FA Posting Type", xRec.Code) then
            FAExtendedPostingGroup.Rename(Rec."FA Posting Group Code", Rec."FA Posting Type", Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"FA Extended Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Extended Posting Group CZF", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertFAExtendedPostingGroupCZF(var Rec: Record "FA Extended Posting Group CZF")
    begin
        SyncFAExtendedPostingGroupCZF(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Extended Posting Group CZF", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyFAExtendedPostingGroupCZF(var Rec: Record "FA Extended Posting Group CZF")
    begin
        SyncFAExtendedPostingGroupCZF(Rec);
    end;

    local procedure SyncFAExtendedPostingGroupCZF(var Rec: Record "FA Extended Posting Group CZF")
    var
        FAExtendedPostingGroup: Record "FA Extended Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if DataUpgradeMgt.IsUpgradeInProgress() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"FA Extended Posting Group CZF") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"FA Extended Posting Group");
        FAExtendedPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if not FAExtendedPostingGroup.Get(Rec."FA Posting Group Code", Rec."FA Posting Type", Rec.Code) then begin
            FAExtendedPostingGroup.Init();
            FAExtendedPostingGroup."FA Posting Group Code" := Rec."FA Posting Group Code";
            FAExtendedPostingGroup."FA Posting Type" := Rec."FA Posting Type".AsInteger();
            FAExtendedPostingGroup.Code := Rec.Code;
            FAExtendedPostingGroup.SystemId := Rec.SystemId;
            FAExtendedPostingGroup.Insert(false, true);
        end;
        FAExtendedPostingGroup."Book Val. Acc. on Disp. (Gain)" := Rec."Book Val. Acc. on Disp. (Gain)";
        FAExtendedPostingGroup."Book Val. Acc. on Disp. (Loss)" := Rec."Book Val. Acc. on Disp. (Loss)";
        FAExtendedPostingGroup."Maintenance Expense Account" := Rec."Maintenance Expense Account";
        FAExtendedPostingGroup."Maintenance Bal. Acc." := Rec."Maintenance Balance Account";
        FAExtendedPostingGroup."Sales Acc. On Disp. (Gain)" := Rec."Sales Acc. On Disp. (Gain)";
        FAExtendedPostingGroup."Sales Acc. On Disp. (Loss)" := Rec."Sales Acc. On Disp. (Loss)";
        FAExtendedPostingGroup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"FA Extended Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Extended Posting Group CZF", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeletelassificationCodeCZF(var Rec: Record "FA Extended Posting Group CZF")
    var
        FAExtendedPostingGroup: Record "FA Extended Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"FA Extended Posting Group CZF") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"FA Extended Posting Group");
        FAExtendedPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if FAExtendedPostingGroup.Get(Rec."FA Posting Group Code", Rec."FA Posting Type", Rec.Code) then
            FAExtendedPostingGroup.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"FA Extended Posting Group");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif
