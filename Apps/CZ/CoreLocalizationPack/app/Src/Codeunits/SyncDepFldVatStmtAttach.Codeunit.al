#if not CLEAN17
#pragma warning disable AL0432
codeunit 31187 "Sync.Dep.Fld-VatStmtAttach CZL"
{
    Permissions = tabledata "VAT Statement Attachment" = rimd,
                  tabledata "VAT Statement Attachment CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Attachment", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATStatementAttachment(var Rec: Record "VAT Statement Attachment"; var xRec: Record "VAT Statement Attachment")
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Statement Attachment") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Statement Attachment CZL");
        VATStatementAttachmentCZL.ChangeCompany(Rec.CurrentCompany);
        if VATStatementAttachmentCZL.Get(xRec."VAT Statement Template Name", xRec."VAT Statement Name", xRec."Line No.") then
            VATStatementAttachmentCZL.Rename(Rec."VAT Statement Template Name", Rec."VAT Statement Name", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Statement Attachment CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Attachment", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATStatementAttachment(var Rec: Record "VAT Statement Attachment")
    begin
        SyncVATStatementAttachment(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Attachment", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATStatementAttachment(var Rec: Record "VAT Statement Attachment")
    begin
        SyncVATStatementAttachment(Rec);
    end;

    local procedure SyncVATStatementAttachment(var Rec: Record "VAT Statement Attachment")
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Statement Attachment") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Statement Attachment CZL");
        VATStatementAttachmentCZL.ChangeCompany(Rec.CurrentCompany);
        if not VATStatementAttachmentCZL.Get(Rec."VAT Statement Template Name", Rec."VAT Statement Name", Rec."Line No.") then begin
            VATStatementAttachmentCZL.Init();
            VATStatementAttachmentCZL."VAT Statement Template Name" := Rec."VAT Statement Template Name";
            VATStatementAttachmentCZL."VAT Statement Name" := Rec."VAT Statement Name";
            VATStatementAttachmentCZL."Line No." := Rec."Line No.";
            VATStatementAttachmentCZL.SystemId := Rec.SystemId;
            VATStatementAttachmentCZL.Insert(false, true);
        end;
        VATStatementAttachmentCZL.Date := Rec.Date;
        VATStatementAttachmentCZL.Description := Rec.Description;
        Rec.CalcFields(Attachment);
        VATStatementAttachmentCZL.Attachment := Rec.Attachment;
        VATStatementAttachmentCZL."File Name" := Rec."File Name";
        VATStatementAttachmentCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Statement Attachment CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Attachment", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATStatementAttachment(var Rec: Record "VAT Statement Attachment")
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Statement Attachment") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Statement Attachment CZL");
        VATStatementAttachmentCZL.ChangeCompany(Rec.CurrentCompany);
        if VATStatementAttachmentCZL.Get(Rec."VAT Statement Template Name", Rec."VAT Statement Name", Rec."Line No.") then
            VATStatementAttachmentCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Statement Attachment CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Attachment CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATStatementAttachmentCZL(var Rec: Record "VAT Statement Attachment CZL"; var xRec: Record "VAT Statement Attachment CZL")
    var
        VATStatementAttachment: Record "VAT Statement Attachment";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Statement Attachment CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Statement Attachment");
        VATStatementAttachment.ChangeCompany(Rec.CurrentCompany);
        if VATStatementAttachment.Get(xRec."VAT Statement Template Name", xRec."VAT Statement Name", xRec."Line No.") then
            VATStatementAttachment.Rename(Rec."VAT Statement Template Name", Rec."VAT Statement Name", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Statement Attachment");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Attachment CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATStatementAttachmentCZL(var Rec: Record "VAT Statement Attachment CZL")
    begin
        SyncVATStatementAttachmentCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Attachment CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATStatementAttachmentCZL(var Rec: Record "VAT Statement Attachment CZL")
    begin
        SyncVATStatementAttachmentCZL(Rec);
    end;

    local procedure SyncVATStatementAttachmentCZL(var Rec: Record "VAT Statement Attachment CZL")
    var
        VATStatementAttachment: Record "VAT Statement Attachment";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Statement Attachment CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Statement Attachment");
        VATStatementAttachment.ChangeCompany(Rec.CurrentCompany);
        if not VATStatementAttachment.Get(Rec."VAT Statement Template Name", Rec."VAT Statement Name", Rec."Line No.") then begin
            VATStatementAttachment.Init();
            VATStatementAttachment."VAT Statement Template Name" := Rec."VAT Statement Template Name";
            VATStatementAttachment."VAT Statement Name" := Rec."VAT Statement Name";
            VATStatementAttachment."Line No." := Rec."Line No.";
            VATStatementAttachment.SystemId := Rec.SystemId;
            VATStatementAttachment.Insert(false, true);
        end;
        VATStatementAttachment.Date := Rec.Date;
        VATStatementAttachment.Description := Rec.Description;
        Rec.CalcFields(Attachment);
        VATStatementAttachment.Attachment := Rec.Attachment;
        VATStatementAttachment."File Name" := Rec."File Name";
        VATStatementAttachment.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Statement Attachment");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Attachment CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATStatementAttachmentCZL(var Rec: Record "VAT Statement Attachment CZL")
    var
        VATStatementAttachment: Record "VAT Statement Attachment";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Statement Attachment CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Statement Attachment");
        VATStatementAttachment.ChangeCompany(Rec.CurrentCompany);
        if VATStatementAttachment.Get(Rec."VAT Statement Template Name", Rec."VAT Statement Name", Rec."Line No.") then
            VATStatementAttachment.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Statement Attachment");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif