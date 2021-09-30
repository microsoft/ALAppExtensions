#if not CLEAN18
#pragma warning disable AL0432
codeunit 31201 "Sync.Dep.Fld-SubstCustPGrp CZL"
{
    Permissions = tabledata "Subst. Customer Posting Group" = rimd,
                  tabledata "Subst. Cust. Posting Group CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Subst. Customer Posting Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameSubstCustomerPostingGroup(var Rec: Record "Subst. Customer Posting Group"; var xRec: Record "Subst. Customer Posting Group")
    var
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Customer Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Cust. Posting Group CZL");
        SubstCustPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if SubstCustPostingGroupCZL.Get(xRec."Parent Cust. Posting Group", xRec."Customer Posting Group") then
            SubstCustPostingGroupCZL.Rename(Rec."Parent Cust. Posting Group", Rec."Customer Posting Group");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Cust. Posting Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Customer Posting Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSubstCustomerPostingGroup(var Rec: Record "Subst. Customer Posting Group")
    begin
        SyncSubstCustomerPostingGroup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Customer Posting Group", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifySubstCustomerPostingGroup(var Rec: Record "Subst. Customer Posting Group")
    begin
        SyncSubstCustomerPostingGroup(Rec);
    end;

    local procedure SyncSubstCustomerPostingGroup(var Rec: Record "Subst. Customer Posting Group")
    var
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Customer Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Cust. Posting Group CZL");
        SubstCustPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if not SubstCustPostingGroupCZL.Get(Rec."Parent Cust. Posting Group", Rec."Customer Posting Group") then begin
            SubstCustPostingGroupCZL.Init();
            SubstCustPostingGroupCZL."Parent Customer Posting Group" := Rec."Parent Cust. Posting Group";
            SubstCustPostingGroupCZL."Customer Posting Group" := Rec."Customer Posting Group";
            SubstCustPostingGroupCZL.SystemId := Rec.SystemId;
            SubstCustPostingGroupCZL.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Cust. Posting Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Customer Posting Group", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteSubstCustomerPostingGroup(var Rec: Record "Subst. Customer Posting Group")
    var
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Customer Posting Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Cust. Posting Group CZL");
        SubstCustPostingGroupCZL.ChangeCompany(Rec.CurrentCompany);
        if SubstCustPostingGroupCZL.Get(Rec."Parent Cust. Posting Group", Rec."Customer Posting Group") then
            SubstCustPostingGroupCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Cust. Posting Group CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Cust. Posting Group CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameSubstCustPostingGroupCZL(var Rec: Record "Subst. Cust. Posting Group CZL"; var xRec: Record "Subst. Cust. Posting Group CZL")
    var
        SubstCustomerPostingGroup: Record "Subst. Customer Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Cust. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Customer Posting Group");
        SubstCustomerPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if SubstCustomerPostingGroup.Get(xRec."Parent Customer Posting Group", xRec."Customer Posting Group") then
            SubstCustomerPostingGroup.Rename(Rec."Parent Customer Posting Group", Rec."Customer Posting Group");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Customer Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Cust. Posting Group CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSubstCustPostingGroupCZL(var Rec: Record "Subst. Cust. Posting Group CZL")
    begin
        SyncSubstCustPostingGroupCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Cust. Posting Group CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifySubstCustPostingGroupCZL(var Rec: Record "Subst. Cust. Posting Group CZL")
    begin
        SyncSubstCustPostingGroupCZL(Rec);
    end;

    local procedure SyncSubstCustPostingGroupCZL(var Rec: Record "Subst. Cust. Posting Group CZL")
    var
        SubstCustomerPostingGroup: Record "Subst. Customer Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Cust. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Customer Posting Group");
        SubstCustomerPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if not SubstCustomerPostingGroup.Get(Rec."Parent Customer Posting Group", Rec."Customer Posting Group") then begin
            SubstCustomerPostingGroup.Init();
            SubstCustomerPostingGroup."Parent Cust. Posting Group" := Rec."Parent Customer Posting Group";
            SubstCustomerPostingGroup."Customer Posting Group" := Rec."Customer Posting Group";
            SubstCustomerPostingGroup.SystemId := Rec.SystemId;
            SubstCustomerPostingGroup.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Customer Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Subst. Cust. Posting Group CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteSubstCustPostingGroupCZL(var Rec: Record "Subst. Cust. Posting Group CZL")
    var
        SubstCustomerPostingGroup: Record "Subst. Customer Posting Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Subst. Cust. Posting Group CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Subst. Customer Posting Group");
        SubstCustomerPostingGroup.ChangeCompany(Rec.CurrentCompany);
        if SubstCustomerPostingGroup.Get(Rec."Parent Customer Posting Group", Rec."Customer Posting Group") then
            SubstCustomerPostingGroup.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Subst. Customer Posting Group");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif