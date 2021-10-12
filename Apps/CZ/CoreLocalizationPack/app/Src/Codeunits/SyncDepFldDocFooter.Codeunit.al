#if not CLEAN17
#pragma warning disable AL0432
codeunit 31157 "Sync.Dep.Fld-DocFooter CZL"
{
    Permissions = tabledata "Document Footer" = rimd,
                  tabledata "Document Footer CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Document Footer", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameDocumentFooter(var Rec: Record "Document Footer"; var xRec: Record "Document Footer")
    var
        DocumentFooterCZL: Record "Document Footer CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Document Footer") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Document Footer CZL");
        DocumentFooterCZL.ChangeCompany(Rec.CurrentCompany);
        if DocumentFooterCZL.Get(xRec."Language Code") then
            DocumentFooterCZL.Rename(Rec."Language Code");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Document Footer CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Footer", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertDocumentFooter(var Rec: Record "Document Footer")
    begin
        SyncDocumentFooter(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Footer", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyDocumentFooter(var Rec: Record "Document Footer")
    begin
        SyncDocumentFooter(Rec);
    end;

    local procedure SyncDocumentFooter(var Rec: Record "Document Footer")
    var
        DocumentFooterCZL: Record "Document Footer CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Document Footer") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Document Footer CZL");
        DocumentFooterCZL.ChangeCompany(Rec.CurrentCompany);
        if not DocumentFooterCZL.Get(Rec."Language Code") then begin
            DocumentFooterCZL.Init();
            DocumentFooterCZL."Language Code" := Rec."Language Code";
            DocumentFooterCZL.SystemId := Rec.SystemId;
            DocumentFooterCZL.Insert(false, true);
        end;
        DocumentFooterCZL."Footer Text" := Rec."Footer Text";
        DocumentFooterCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Document Footer CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Footer", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteDocumentFooter(var Rec: Record "Document Footer")
    var
        DocumentFooterCZL: Record "Document Footer CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Document Footer") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Document Footer CZL");
        DocumentFooterCZL.ChangeCompany(Rec.CurrentCompany);
        if DocumentFooterCZL.Get(Rec."Language Code") then
            DocumentFooterCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Document Footer CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Footer CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameDocumentFooterCZL(var Rec: Record "Document Footer CZL"; var xRec: Record "Document Footer CZL")
    var
        DocumentFooter: Record "Document Footer";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Document Footer CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Document Footer");
        DocumentFooter.ChangeCompany(Rec.CurrentCompany);
        if DocumentFooter.Get(xRec."Language Code") then
            DocumentFooter.Rename(Rec."Language Code");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Document Footer");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Footer CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertDocumentFooterCZL(var Rec: Record "Document Footer CZL")
    begin
        SyncDocumentFooterCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Footer CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyDocumentFooterCZL(var Rec: Record "Document Footer CZL")
    begin
        SyncDocumentFooterCZL(Rec);
    end;

    local procedure SyncDocumentFooterCZL(var Rec: Record "Document Footer CZL")
    var
        DocumentFooter: Record "Document Footer";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Document Footer CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Document Footer");
        DocumentFooter.ChangeCompany(Rec.CurrentCompany);
        if not DocumentFooter.Get(Rec."Language Code") then begin
            DocumentFooter.Init();
            DocumentFooter."Language Code" := Rec."Language Code";
            DocumentFooter.SystemId := Rec.SystemId;
            DocumentFooter.Insert(false, true);
        end;
        DocumentFooter."Footer Text" := CopyStr(Rec."Footer Text", 1, MaxStrLen(DocumentFooter."Footer Text"));
        DocumentFooter.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Document Footer");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Footer CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteDocumentFooterCZL(var Rec: Record "Document Footer CZL")
    var
        DocumentFooter: Record "Document Footer";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Document Footer CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Document Footer");
        DocumentFooter.ChangeCompany(Rec.CurrentCompany);
        if DocumentFooter.Get(Rec."Language Code") then
            DocumentFooter.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Document Footer");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif