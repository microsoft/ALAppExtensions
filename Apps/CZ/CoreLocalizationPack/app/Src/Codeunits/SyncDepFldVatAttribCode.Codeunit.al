#if not CLEAN17
#pragma warning disable AL0432
codeunit 31185 "Sync.Dep.Fld-VatAttribCode CZL"
{
    Permissions = tabledata "VAT Attribute Code" = rimd,
                  tabledata "VAT Attribute Code CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VAT Attribute Code", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATAttributeCode(var Rec: Record "VAT Attribute Code"; var xRec: Record "VAT Attribute Code")
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Attribute Code") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Attribute Code CZL");
        VATAttributeCodeCZL.ChangeCompany(Rec.CurrentCompany);
        if VATAttributeCodeCZL.Get(xRec."VAT Statement Template Name", xRec."Code") then
            VATAttributeCodeCZL.Rename(Rec."VAT Statement Template Name", Rec."Code");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Attribute Code CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Attribute Code", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATAttributeCode(var Rec: Record "VAT Attribute Code")
    begin
        SyncVATAttributeCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Attribute Code", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATAttributeCode(var Rec: Record "VAT Attribute Code")
    begin
        SyncVATAttributeCode(Rec);
    end;

    local procedure SyncVATAttributeCode(var Rec: Record "VAT Attribute Code")
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Attribute Code") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Attribute Code CZL");
        VATAttributeCodeCZL.ChangeCompany(Rec.CurrentCompany);
        if not VATAttributeCodeCZL.Get(Rec."VAT Statement Template Name", Rec."Code") then begin
            VATAttributeCodeCZL.Init();
            VATAttributeCodeCZL."VAT Statement Template Name" := Rec."VAT Statement Template Name";
            VATAttributeCodeCZL."Code" := Rec."Code";
            VATAttributeCodeCZL.SystemId := Rec.SystemId;
            VATAttributeCodeCZL.Insert(false, true);
        end;
        VATAttributeCodeCZL.Description := Rec.Description;
        VATAttributeCodeCZL."XML Code" := Rec."XML Code";
        VATAttributeCodeCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Attribute Code CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Attribute Code", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATAttributeCode(var Rec: Record "VAT Attribute Code")
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Attribute Code") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Attribute Code CZL");
        VATAttributeCodeCZL.ChangeCompany(Rec.CurrentCompany);
        if VATAttributeCodeCZL.Get(Rec."VAT Statement Template Name", Rec."Code") then
            VATAttributeCodeCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Attribute Code CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Attribute Code CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATAttributeCodeCZL(var Rec: Record "VAT Attribute Code CZL"; var xRec: Record "VAT Attribute Code CZL")
    var
        VATAttributeCode: Record "VAT Attribute Code";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Attribute Code CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Attribute Code");
        VATAttributeCode.ChangeCompany(Rec.CurrentCompany);
        if VATAttributeCode.Get(xRec."VAT Statement Template Name", xRec."Code") then
            VATAttributeCode.Rename(Rec."VAT Statement Template Name", Rec."Code");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Attribute Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Attribute Code CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATAttributeCodeCZL(var Rec: Record "VAT Attribute Code CZL")
    begin
        SyncVATAttributeCodeCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Attribute Code CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATAttributeCodeCZL(var Rec: Record "VAT Attribute Code CZL")
    begin
        SyncVATAttributeCodeCZL(Rec);
    end;

    local procedure SyncVATAttributeCodeCZL(var Rec: Record "VAT Attribute Code CZL")
    var
        VATAttributeCode: Record "VAT Attribute Code";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Attribute Code CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Attribute Code");
        VATAttributeCode.ChangeCompany(Rec.CurrentCompany);
        if not VATAttributeCode.Get(Rec."VAT Statement Template Name", Rec."Code") then begin
            VATAttributeCode.Init();
            VATAttributeCode."VAT Statement Template Name" := Rec."VAT Statement Template Name";
            VATAttributeCode."Code" := Rec."Code";
            VATAttributeCode.SystemId := Rec.SystemId;
            VATAttributeCode.Insert(false, true);
        end;
        VATAttributeCode.Description := CopyStr(Rec.Description, 1, MaxStrLen(VATAttributeCode.Description));
        VATAttributeCode."XML Code" := Rec."XML Code";
        VATAttributeCode.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Attribute Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Attribute Code CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATAttributeCodeCZL(var Rec: Record "VAT Attribute Code CZL")
    var
        VATAttributeCode: Record "VAT Attribute Code";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Attribute Code CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Attribute Code");
        VATAttributeCode.ChangeCompany(Rec.CurrentCompany);
        if VATAttributeCode.Get(Rec."VAT Statement Template Name", Rec."Code") then
            VATAttributeCode.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Attribute Code");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif