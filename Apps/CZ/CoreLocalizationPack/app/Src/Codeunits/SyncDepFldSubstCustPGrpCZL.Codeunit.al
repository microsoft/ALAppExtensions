// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Utilities;

using Microsoft.Sales.Customer;

#pragma warning disable AL0432
codeunit 31201 "Sync.Dep.Fld-SubstCustPGrp CZL"
{
    Access = Internal;
    Permissions = tabledata "Subst. Cust. Posting Group CZL" = rimd,
                  tabledata "Alt. Customer Posting Group" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Cust. Posting Group CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameSubstCustPostingGroupCZL(var Rec: Record "Subst. Cust. Posting Group CZL"; var xRec: Record "Subst. Cust. Posting Group CZL")
    var
        AltCustomerPostingGroup: Record "Alt. Customer Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Cust. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Alt. Customer Posting Group");
        AltCustomerPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if AltCustomerPostingGroup.Get(xRec."Parent Customer Posting Group", xRec."Customer Posting Group") then
            AltCustomerPostingGroup.Rename(Rec."Parent Customer Posting Group", Rec."Customer Posting Group");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Alt. Customer Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Cust. Posting Group CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSubstCustPostingGroupCZL(var Rec: Record "Subst. Cust. Posting Group CZL")
    var
        AltCustomerPostingGroup: Record "Alt. Customer Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Cust. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Alt. Customer Posting Group");
        AltCustomerPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if not AltCustomerPostingGroup.Get(Rec."Parent Customer Posting Group", Rec."Customer Posting Group") then begin
            AltCustomerPostingGroup.Init();
            AltCustomerPostingGroup."Customer Posting Group" := Rec."Parent Customer Posting Group";
            AltCustomerPostingGroup."Alt. Customer Posting Group" := Rec."Customer Posting Group";
            AltCustomerPostingGroup.SystemId := Rec.SystemId;
            AltCustomerPostingGroup.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Alt. Customer Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Cust. Posting Group CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteSubstCustPostingGroupCZL(var Rec: Record "Subst. Cust. Posting Group CZL")
    var
        AltCustomerPostingGroup: Record "Alt. Customer Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Cust. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Alt. Customer Posting Group");
        AltCustomerPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if AltCustomerPostingGroup.Get(Rec."Parent Customer Posting Group", Rec."Customer Posting Group") then
            AltCustomerPostingGroup.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Alt. Customer Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alt. Customer Posting Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameAltCustomerPostingGroup(var Rec: Record "Alt. Customer Posting Group"; var xRec: Record "Alt. Customer Posting Group")
    var
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Alt. Customer Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Cust. Posting Group CZL");
        SubstCustPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if SubstCustPostingGroupCZL.Get(xRec."Customer Posting Group", xRec."Alt. Customer Posting Group") then
            SubstCustPostingGroupCZL.Rename(Rec."Customer Posting Group", Rec."Alt. Customer Posting Group");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Cust. Posting Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alt. Customer Posting Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertAltCustomerPostingGroup(var Rec: Record "Alt. Customer Posting Group")
    var
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Alt. Customer Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Cust. Posting Group CZL");
        SubstCustPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if not SubstCustPostingGroupCZL.Get(Rec."Customer Posting Group", Rec."Alt. Customer Posting Group") then begin
            SubstCustPostingGroupCZL.Init();
            SubstCustPostingGroupCZL."Parent Customer Posting Group" := Rec."Customer Posting Group";
            SubstCustPostingGroupCZL."Customer Posting Group" := Rec."Alt. Customer Posting Group";
            SubstCustPostingGroupCZL.SystemId := Rec.SystemId;
            SubstCustPostingGroupCZL.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Cust. Posting Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alt. Customer Posting Group", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteAltCustomerPostingGroup(var Rec: Record "Alt. Customer Posting Group")
    var
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Alt. Customer Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Cust. Posting Group CZL");
        SubstCustPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if SubstCustPostingGroupCZL.Get(Rec."Customer Posting Group", Rec."Alt. Customer Posting Group") then
            SubstCustPostingGroupCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Cust. Posting Group CZL");
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
