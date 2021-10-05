#if not CLEAN17
#pragma warning disable AL0432
codeunit 31190 "Sync.Dep.Fld-ExcelTemplate CZL"
{
    Permissions = tabledata "Excel Template" = rimd,
                  tabledata "Excel Template CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Excel Template", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameExcelTemplate(var Rec: Record "Excel Template"; var xRec: Record "Excel Template")
    var
        ExcelTemplateCZL: Record "Excel Template CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Excel Template") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Excel Template CZL");
        ExcelTemplateCZL.ChangeCompany(Rec.CurrentCompany);
        if ExcelTemplateCZL.Get(xRec.Code) then
            ExcelTemplateCZL.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Excel Template CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Excel Template", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertExcelTemplate(var Rec: Record "Excel Template")
    begin
        SyncExcelTemplate(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Excel Template", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyExcelTemplate(var Rec: Record "Excel Template")
    begin
        SyncExcelTemplate(Rec);
    end;

    local procedure SyncExcelTemplate(var Rec: Record "Excel Template")
    var
        ExcelTemplateCZL: Record "Excel Template CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
        OutStr: OutStream;
        InStr: InStream;
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Excel Template") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Excel Template CZL");
        ExcelTemplateCZL.ChangeCompany(Rec.CurrentCompany);
        if not ExcelTemplateCZL.Get(Rec.Code) then begin
            ExcelTemplateCZL.Init();
            ExcelTemplateCZL.Code := Rec.Code;
            ExcelTemplateCZL.SystemId := Rec.SystemId;
            ExcelTemplateCZL.Insert(false, true);
        end;
        ExcelTemplateCZL.Description := Rec.Description;
        ExcelTemplateCZL.Sheet := Rec.Sheet;
        ExcelTemplateCZL.Blocked := Rec.Blocked;
        if Rec.Template.HasValue() then begin
            Rec.CalcFields(Template);
            Rec.Template.CreateInStream(InStr);
            ExcelTemplateCZL.Template.CreateOutStream(OutStr);
            CopyStream(OutStr, InStr);
        end else
            Clear(ExcelTemplateCZL.Template);
        ExcelTemplateCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Excel Template CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Excel Template", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteExcelTemplate(var Rec: Record "Excel Template")
    var
        ExcelTemplateCZL: Record "Excel Template CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Excel Template") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Excel Template CZL");
        ExcelTemplateCZL.ChangeCompany(Rec.CurrentCompany);
        if ExcelTemplateCZL.Get(Rec.Code) then
            ExcelTemplateCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Excel Template CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Excel Template CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameExcelTemplateCZL(var Rec: Record "Excel Template CZL"; var xRec: Record "Excel Template CZL")
    var
        ExcelTemplate: Record "Excel Template";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Excel Template CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Excel Template");
        ExcelTemplate.ChangeCompany(Rec.CurrentCompany);
        if ExcelTemplate.Get(xRec.Code) then
            ExcelTemplate.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Excel Template");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Excel Template CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertExcelTemplateCZL(var Rec: Record "Excel Template CZL")
    begin
        SyncExcelTemplateCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Excel Template CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyExcelTemplateCZL(var Rec: Record "Excel Template CZL")
    begin
        SyncExcelTemplateCZL(Rec);
    end;

    local procedure SyncExcelTemplateCZL(var Rec: Record "Excel Template CZL")
    var
        ExcelTemplate: Record "Excel Template";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
        OutStr: OutStream;
        InStr: InStream;
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Excel Template CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Excel Template");
        ExcelTemplate.ChangeCompany(Rec.CurrentCompany);
        if not ExcelTemplate.Get(Rec.Code) then begin
            ExcelTemplate.Init();
            ExcelTemplate.Code := Rec.Code;
            ExcelTemplate.SystemId := Rec.SystemId;
            ExcelTemplate.Insert(false, true);
        end;
        ExcelTemplate.Description := Rec.Description;
        ExcelTemplate.Sheet := Rec.Sheet;
        ExcelTemplate.Blocked := Rec.Blocked;
        if Rec.Template.HasValue() then begin
            Rec.CalcFields(Template);
            Rec.Template.CreateInStream(InStr);
            ExcelTemplate.Template.CreateOutStream(OutStr);
            CopyStream(OutStr, InStr);
        end else
            Clear(ExcelTemplate.Template);
        ExcelTemplate.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Excel Template");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Excel Template CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteExcelTemplateCZL(var Rec: Record "Excel Template CZL")
    var
        ExcelTemplate: Record "Excel Template";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Excel Template CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Excel Template");
        ExcelTemplate.ChangeCompany(Rec.CurrentCompany);
        if ExcelTemplate.Get(Rec.Code) then
            ExcelTemplate.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Excel Template");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif