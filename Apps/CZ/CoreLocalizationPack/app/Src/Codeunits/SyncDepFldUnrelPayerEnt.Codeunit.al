#if not CLEAN17
#pragma warning disable AL0432
codeunit 31156 "Sync.Dep.Fld-UnrelPayerEnt CZL"
{
    Permissions = tabledata "Uncertainty Payer Entry" = rimd,
                  tabledata "Unreliable Payer Entry CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Uncertainty Payer Entry", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameUncertaintyPayerEntry(var Rec: Record "Uncertainty Payer Entry"; var xRec: Record "Uncertainty Payer Entry")
    var
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Uncertainty Payer Entry") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Unreliable Payer Entry CZL");
        UnreliablePayerEntryCZL.ChangeCompany(Rec.CurrentCompany);
        if UnreliablePayerEntryCZL.Get(xRec."Entry No.") then
            UnreliablePayerEntryCZL.Rename(Rec."Entry No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Unreliable Payer Entry CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Uncertainty Payer Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertUncertaintyPayerEntry(var Rec: Record "Uncertainty Payer Entry")
    begin
        SyncUncertaintyPayerEntry(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Uncertainty Payer Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyUncertaintyPayerEntry(var Rec: Record "Uncertainty Payer Entry")
    begin
        SyncUncertaintyPayerEntry(Rec);
    end;

    local procedure SyncUncertaintyPayerEntry(var Rec: Record "Uncertainty Payer Entry")
    var
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Uncertainty Payer Entry") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Unreliable Payer Entry CZL");
        UnreliablePayerEntryCZL.ChangeCompany(Rec.CurrentCompany);
        if not UnreliablePayerEntryCZL.Get(Rec."Entry No.") then begin
            UnreliablePayerEntryCZL.Init();
            UnreliablePayerEntryCZL."Entry No." := Rec."Entry No.";
            UnreliablePayerEntryCZL.SystemId := Rec.SystemId;
            UnreliablePayerEntryCZL.Insert(false, true);
        end;
        UnreliablePayerEntryCZL."Vendor No." := Rec."Vendor No.";
        UnreliablePayerEntryCZL."Check Date" := Rec."Check Date";
        UnreliablePayerEntryCZL."Public Date" := Rec."Public Date";
        UnreliablePayerEntryCZL."End Public Date" := Rec."End Public Date";
        UnreliablePayerEntryCZL."Unreliable Payer" := Rec."Uncertainty Payer";
        UnreliablePayerEntryCZL."Entry Type" := Rec."Entry Type";
        UnreliablePayerEntryCZL."VAT Registration No." := Rec."VAT Registration No.";
        UnreliablePayerEntryCZL."Tax Office Number" := Rec."Tax Office Number";
        UnreliablePayerEntryCZL."Full Bank Account No." := Rec."Full Bank Account No.";
        UnreliablePayerEntryCZL."Bank Account No. Type" := Rec."Bank Account No. Type";
        UnreliablePayerEntryCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Unreliable Payer Entry CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Uncertainty Payer Entry", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteUncertaintyPayerEntry(var Rec: Record "Uncertainty Payer Entry")
    var
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Uncertainty Payer Entry") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Unreliable Payer Entry CZL");
        UnreliablePayerEntryCZL.ChangeCompany(Rec.CurrentCompany);
        if UnreliablePayerEntryCZL.Get(Rec."Entry No.") then
            UnreliablePayerEntryCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Unreliable Payer Entry CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unreliable Payer Entry CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameUnreliablePayerEntryCZL(var Rec: Record "Unreliable Payer Entry CZL"; var xRec: Record "Unreliable Payer Entry CZL")
    var
        UncertaintyPayerEntry: Record "Uncertainty Payer Entry";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Unreliable Payer Entry CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Uncertainty Payer Entry");
        UncertaintyPayerEntry.ChangeCompany(Rec.CurrentCompany);
        if UncertaintyPayerEntry.Get(xRec."Entry No.") then begin
            UncertaintyPayerEntry.Rename(Rec."Entry No.");
            SyncLoopingHelper.RestoreFieldSynchronization(Database::"Uncertainty Payer Entry");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unreliable Payer Entry CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertUnreliablePayerEntryCZL(var Rec: Record "Unreliable Payer Entry CZL")
    begin
        if NavApp.IsInstalling() then
            exit;
        SyncUnreliablePayerEntryCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unreliable Payer Entry CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyUnreliablePayerEntryCZL(var Rec: Record "Unreliable Payer Entry CZL")
    begin
        SyncUnreliablePayerEntryCZL(Rec);
    end;

    local procedure SyncUnreliablePayerEntryCZL(var Rec: Record "Unreliable Payer Entry CZL")
    var
        UncertaintyPayerEntry: Record "Uncertainty Payer Entry";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Unreliable Payer Entry CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Uncertainty Payer Entry");
        UncertaintyPayerEntry.ChangeCompany(Rec.CurrentCompany);
        if not UncertaintyPayerEntry.Get(Rec."Entry No.") then begin
            UncertaintyPayerEntry.Init();
            UncertaintyPayerEntry."Entry No." := Rec."Entry No.";
            UncertaintyPayerEntry.SystemId := Rec.SystemId;
            UncertaintyPayerEntry.Insert(false, true);
        end;
        UncertaintyPayerEntry."Vendor No." := Rec."Vendor No.";
        UncertaintyPayerEntry."Check Date" := Rec."Check Date";
        UncertaintyPayerEntry."Public Date" := Rec."Public Date";
        UncertaintyPayerEntry."End Public Date" := Rec."End Public Date";
        UncertaintyPayerEntry."Uncertainty Payer" := Rec."Unreliable Payer";
        UncertaintyPayerEntry."Entry Type" := Rec."Entry Type";
        UncertaintyPayerEntry."VAT Registration No." := Rec."VAT Registration No.";
        UncertaintyPayerEntry."Tax Office Number" := Rec."Tax Office Number";
        UncertaintyPayerEntry."Full Bank Account No." := Rec."Full Bank Account No.";
        UncertaintyPayerEntry."Bank Account No. Type" := Rec."Bank Account No. Type";
        UncertaintyPayerEntry.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Uncertainty Payer Entry");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unreliable Payer Entry CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteUnreliablePayerEntryCZL(var Rec: Record "Unreliable Payer Entry CZL")
    var
        UncertaintyPayerEntry: Record "Uncertainty Payer Entry";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Unreliable Payer Entry CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Uncertainty Payer Entry");
        UncertaintyPayerEntry.ChangeCompany(Rec.CurrentCompany);
        if UncertaintyPayerEntry.Get(Rec."Entry No.") then begin
            UncertaintyPayerEntry.Delete(false);
            SyncLoopingHelper.RestoreFieldSynchronization(Database::"Uncertainty Payer Entry");
        end;
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif