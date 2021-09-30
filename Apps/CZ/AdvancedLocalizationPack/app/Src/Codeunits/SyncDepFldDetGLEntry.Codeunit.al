#if not CLEAN19
#pragma warning disable AL0432
codeunit 31376 "Sync.Dep.Fld-DetGLEntry CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Detailed G/L Entry", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameDetailedGLEntry(var Rec: Record "Detailed G/L Entry"; var xRec: Record "Detailed G/L Entry")
    var
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Detailed G/L Entry") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Detailed G/L Entry CZA");
        DetailedGLEntryCZA.ChangeCompany(Rec.CurrentCompany);
        if DetailedGLEntryCZA.Get(xRec."Entry No.") then
            DetailedGLEntryCZA.Rename(Rec."Entry No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Detailed G/L Entry CZA");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed G/L Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertDetailedGLEntry(var Rec: Record "Detailed G/L Entry")
    begin
        SyncDetailedGLEntry(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed G/L Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyDetailedGLEntry(var Rec: Record "Detailed G/L Entry")
    begin
        SyncDetailedGLEntry(Rec);
    end;

    local procedure SyncDetailedGLEntry(var DetailedGLEntry: Record "Detailed G/L Entry")
    var
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if DetailedGLEntry.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Detailed G/L Entry") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Detailed G/L Entry CZA");
        DetailedGLEntryCZA.ChangeCompany(DetailedGLEntry.CurrentCompany);
        if not DetailedGLEntryCZA.Get(DetailedGLEntry."Entry No.") then begin
            DetailedGLEntryCZA.Init();
            DetailedGLEntryCZA."Entry No." := DetailedGLEntry."Entry No.";
            DetailedGLEntryCZA.SystemId := DetailedGLEntry.SystemId;
            DetailedGLEntryCZA.Insert(false, true);
        end;
        DetailedGLEntryCZA."G/L Entry No." := DetailedGLEntry."G/L Entry No.";
        DetailedGLEntryCZA."Applied G/L Entry No." := DetailedGLEntry."Applied G/L Entry No.";
        DetailedGLEntryCZA."G/L Account No." := DetailedGLEntry."G/L Account No.";
        DetailedGLEntryCZA."Posting Date" := DetailedGLEntry."Posting Date";
        DetailedGLEntryCZA."Document No." := DetailedGLEntry."Document No.";
        DetailedGLEntryCZA."Transaction No." := DetailedGLEntry."Transaction No.";
        DetailedGLEntryCZA.Amount := DetailedGLEntry.Amount;
        DetailedGLEntryCZA.Unapplied := DetailedGLEntry.Unapplied;
        DetailedGLEntryCZA."Unapplied by Entry No." := DetailedGLEntry."Unapplied by Entry No.";
        DetailedGLEntryCZA."User ID" := DetailedGLEntry."User ID";
        DetailedGLEntryCZA.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Detailed G/L Entry CZA");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed G/L Entry", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteDetailedGLEntry(var Rec: Record "Detailed G/L Entry")
    var
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Detailed G/L Entry") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Detailed G/L Entry CZA");
        DetailedGLEntryCZA.ChangeCompany(Rec.CurrentCompany);
        if DetailedGLEntryCZA.Get(Rec."Entry No.") then
            DetailedGLEntryCZA.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Detailed G/L Entry CZA");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed G/L Entry CZA", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameDetailedGLEntryCZA(var Rec: Record "Detailed G/L Entry CZA"; var xRec: Record "Detailed G/L Entry CZA")
    var
        DetailedGLEntry: Record "Detailed G/L Entry";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Detailed G/L Entry CZA") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Detailed G/L Entry");
        DetailedGLEntry.ChangeCompany(Rec.CurrentCompany);
        if DetailedGLEntry.Get(xRec."Entry No.") then
            DetailedGLEntry.Rename(Rec."Entry No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Detailed G/L Entry");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed G/L Entry CZA", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertDetailedGLEntryCZA(var Rec: Record "Detailed G/L Entry CZA")
    begin
        SyncDetailedGLEntryCZA(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed G/L Entry CZA", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyDetailedGLEntryCZA(var Rec: Record "Detailed G/L Entry CZA")
    begin
        SyncDetailedGLEntryCZA(Rec);
    end;

    local procedure SyncDetailedGLEntryCZA(var DetailedGLEntryCZA: Record "Detailed G/L Entry CZA")
    var
        DetailedGLEntry: Record "Detailed G/L Entry";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if DetailedGLEntryCZA.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Detailed G/L Entry CZA") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Detailed G/L Entry");
        DetailedGLEntry.ChangeCompany(DetailedGLEntryCZA.CurrentCompany);
        if not DetailedGLEntry.Get(DetailedGLEntryCZA."Entry No.") then begin
            DetailedGLEntry.Init();
            DetailedGLEntry."Entry No." := DetailedGLEntryCZA."Entry No.";
            DetailedGLEntry.SystemId := DetailedGLEntryCZA.SystemId;
            DetailedGLEntry.Insert(false, true);
        end;
        DetailedGLEntry."G/L Entry No." := DetailedGLEntryCZA."G/L Entry No.";
        DetailedGLEntry."Applied G/L Entry No." := DetailedGLEntryCZA."Applied G/L Entry No.";
        DetailedGLEntry."G/L Account No." := DetailedGLEntryCZA."G/L Account No.";
        DetailedGLEntry."Posting Date" := DetailedGLEntryCZA."Posting Date";
        DetailedGLEntry."Document No." := DetailedGLEntryCZA."Document No.";
        DetailedGLEntry."Transaction No." := DetailedGLEntryCZA."Transaction No.";
        DetailedGLEntry.Amount := DetailedGLEntryCZA.Amount;
        DetailedGLEntry.Unapplied := DetailedGLEntryCZA.Unapplied;
        DetailedGLEntry."Unapplied by Entry No." := DetailedGLEntryCZA."Unapplied by Entry No.";
        DetailedGLEntry."User ID" := DetailedGLEntryCZA."User ID";
        DetailedGLEntry.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Detailed G/L Entry");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed G/L Entry CZA", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteDetailedGLEntryCZA(var Rec: Record "Detailed G/L Entry CZA")
    var
        DetailedGLEntry: Record "Detailed G/L Entry";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Detailed G/L Entry CZA") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Detailed G/L Entry");
        DetailedGLEntry.ChangeCompany(Rec.CurrentCompany);
        if DetailedGLEntry.Get(Rec."Entry No.") then
            DetailedGLEntry.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Detailed G/L Entry");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif