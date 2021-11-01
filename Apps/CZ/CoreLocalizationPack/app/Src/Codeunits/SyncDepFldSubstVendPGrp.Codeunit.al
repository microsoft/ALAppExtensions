#if not CLEAN18
#pragma warning disable AL0432
codeunit 31202 "Sync.Dep.Fld-SubstVendPGrp CZL"
{
    Permissions = tabledata "Subst. Vendor Posting Group" = rimd,
                  tabledata "Subst. Vend. Posting Group CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Subst. Vendor Posting Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameSubstVendorPostingGroup(var Rec: Record "Subst. Vendor Posting Group"; var xRec: Record "Subst. Vendor Posting Group")
    var
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Vendor Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Vend. Posting Group CZL");
        SubstVendPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if SubstVendPostingGroupCZL.Get(xRec."Parent Vend. Posting Group", xRec."Vendor Posting Group") then
            SubstVendPostingGroupCZL.Rename(Rec."Parent Vend. Posting Group", Rec."Vendor Posting Group");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Vend. Posting Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Vendor Posting Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSubstVendorPostingGroup(var Rec: Record "Subst. Vendor Posting Group")
    begin
        SyncSubstVendorPostingGroup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Vendor Posting Group", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifySubstVendorPostingGroup(var Rec: Record "Subst. Vendor Posting Group")
    begin
        SyncSubstVendorPostingGroup(Rec);
    end;

    local procedure SyncSubstVendorPostingGroup(var Rec: Record "Subst. Vendor Posting Group")
    var
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Vendor Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Vend. Posting Group CZL");
        SubstVendPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if not SubstVendPostingGroupCZL.Get(Rec."Parent Vend. Posting Group", Rec."Vendor Posting Group") then begin
            SubstVendPostingGroupCZL.Init();
            SubstVendPostingGroupCZL."Parent Vendor Posting Group" := Rec."Parent Vend. Posting Group";
            SubstVendPostingGroupCZL."Vendor Posting Group" := Rec."Vendor Posting Group";
            SubstVendPostingGroupCZL.SystemId := Rec.SystemId;
            SubstVendPostingGroupCZL.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Vend. Posting Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Vendor Posting Group", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteSubstVendorPostingGroup(var Rec: Record "Subst. Vendor Posting Group")
    var
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Vendor Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Vend. Posting Group CZL");
        SubstVendPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if SubstVendPostingGroupCZL.Get(Rec."Parent Vend. Posting Group", Rec."Vendor Posting Group") then
            SubstVendPostingGroupCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Vend. Posting Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Vend. Posting Group CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameSubstVendPostingGroupCZL(var Rec: Record "Subst. Vend. Posting Group CZL"; var xRec: Record "Subst. Vend. Posting Group CZL")
    var
        SubstVendorPostingGroup: Record "Subst. Vendor Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Vend. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Vendor Posting Group");
        SubstVendorPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if SubstVendorPostingGroup.Get(xRec."Parent Vendor Posting Group", xRec."Vendor Posting Group") then
            SubstVendorPostingGroup.Rename(Rec."Parent Vendor Posting Group", Rec."Vendor Posting Group");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Vendor Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Vend. Posting Group CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSubstVendPostingGroupCZL(var Rec: Record "Subst. Vend. Posting Group CZL")
    begin
        SyncSubstVendPostingGroupCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Vend. Posting Group CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifySubstVendPostingGroupCZL(var Rec: Record "Subst. Vend. Posting Group CZL")
    begin
        SyncSubstVendPostingGroupCZL(Rec);
    end;

    local procedure SyncSubstVendPostingGroupCZL(var Rec: Record "Subst. Vend. Posting Group CZL")
    var
        SubstVendorPostingGroup: Record "Subst. Vendor Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Vend. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Vendor Posting Group");
        SubstVendorPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if not SubstVendorPostingGroup.Get(Rec."Parent Vendor Posting Group", Rec."Vendor Posting Group") then begin
            SubstVendorPostingGroup.Init();
            SubstVendorPostingGroup."Parent Vend. Posting Group" := Rec."Parent Vendor Posting Group";
            SubstVendorPostingGroup."Vendor Posting Group" := Rec."Vendor Posting Group";
            SubstVendorPostingGroup.SystemId := Rec.SystemId;
            SubstVendorPostingGroup.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Vendor Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Vend. Posting Group CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteSubstVendPostingGroupCZL(var Rec: Record "Subst. Vend. Posting Group CZL")
    var
        SubstVendorPostingGroup: Record "Subst. Vendor Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Vend. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Vendor Posting Group");
        SubstVendorPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if SubstVendorPostingGroup.Get(Rec."Parent Vendor Posting Group", Rec."Vendor Posting Group") then
            SubstVendorPostingGroup.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Vendor Posting Group");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif