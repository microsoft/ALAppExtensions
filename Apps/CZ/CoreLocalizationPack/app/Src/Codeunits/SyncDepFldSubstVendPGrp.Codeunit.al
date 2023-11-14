// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Utilities;

using Microsoft.Purchases.Vendor;

#pragma warning disable AL0432
codeunit 31202 "Sync.Dep.Fld-SubstVendPGrp CZL"
{
    Access = Internal;
    Permissions = tabledata "Subst. Vend. Posting Group CZL" = rimd,
                  tabledata "Alt. Vendor Posting Group" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Vend. Posting Group CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameSubstVendPostingGroupCZL(var Rec: Record "Subst. Vend. Posting Group CZL"; var xRec: Record "Subst. Vend. Posting Group CZL")
    var
        AltVendorPostingGroup: Record "Alt. Vendor Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Vend. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Alt. Vendor Posting Group");
        AltVendorPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if AltVendorPostingGroup.Get(xRec."Parent Vendor Posting Group", xRec."Vendor Posting Group") then
            AltVendorPostingGroup.Rename(Rec."Parent Vendor Posting Group", Rec."Vendor Posting Group");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Alt. Vendor Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Vend. Posting Group CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSubstVendPostingGroupCZL(var Rec: Record "Subst. Vend. Posting Group CZL")
    var
        AltVendorPostingGroup: Record "Alt. Vendor Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Vend. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Alt. Vendor Posting Group");
        AltVendorPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if not AltVendorPostingGroup.Get(Rec."Parent Vendor Posting Group", Rec."Vendor Posting Group") then begin
            AltVendorPostingGroup.Init();
            AltVendorPostingGroup."Vendor Posting Group" := Rec."Parent Vendor Posting Group";
            AltVendorPostingGroup."Alt. Vendor Posting Group" := Rec."Vendor Posting Group";
            AltVendorPostingGroup.SystemId := Rec.SystemId;
            AltVendorPostingGroup.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Alt. Vendor Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Vend. Posting Group CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteSubstVendPostingGroupCZL(var Rec: Record "Subst. Vend. Posting Group CZL")
    var
        AltVendorPostingGroup: Record "Alt. Vendor Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Vend. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Alt. Vendor Posting Group");
        AltVendorPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if AltVendorPostingGroup.Get(Rec."Parent Vendor Posting Group", Rec."Vendor Posting Group") then
            AltVendorPostingGroup.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Alt. Vendor Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alt. Vendor Posting Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameAltVendorPostingGroup(var Rec: Record "Alt. Vendor Posting Group"; var xRec: Record "Alt. Vendor Posting Group")
    var
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Alt. Vendor Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Vend. Posting Group CZL");
        SubstVendPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if SubstVendPostingGroupCZL.Get(xRec."Vendor Posting Group", xRec."Alt. Vendor Posting Group") then
            SubstVendPostingGroupCZL.Rename(Rec."Vendor Posting Group", Rec."Alt. Vendor Posting Group");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Vend. Posting Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alt. Vendor Posting Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertAltVendorPostingGroup(var Rec: Record "Alt. Vendor Posting Group")
    var
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Alt. Vendor Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Vend. Posting Group CZL");
        SubstVendPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if not SubstVendPostingGroupCZL.Get(Rec."Vendor Posting Group", Rec."Alt. Vendor Posting Group") then begin
            SubstVendPostingGroupCZL.Init();
            SubstVendPostingGroupCZL."Parent Vendor Posting Group" := Rec."Vendor Posting Group";
            SubstVendPostingGroupCZL."Vendor Posting Group" := Rec."Alt. Vendor Posting Group";
            SubstVendPostingGroupCZL.SystemId := Rec.SystemId;
            SubstVendPostingGroupCZL.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Vend. Posting Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alt. Vendor Posting Group", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteAltVendorPostingGroup(var Rec: Record "Alt. Vendor Posting Group")
    var
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Alt. Vendor Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Vend. Posting Group CZL");
        SubstVendPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if SubstVendPostingGroupCZL.Get(Rec."Vendor Posting Group", Rec."Alt. Vendor Posting Group") then
            SubstVendPostingGroupCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Vend. Posting Group CZL");
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
