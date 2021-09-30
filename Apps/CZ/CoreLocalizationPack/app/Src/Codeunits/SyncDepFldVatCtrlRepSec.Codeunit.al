#if not CLEAN17
#pragma warning disable AL0432
codeunit 31172 "Sync.Dep.Fld-VatCtrlRepSec CZL"
{
    Permissions = tabledata "VAT Control Report Section" = rimd,
                  tabledata "VAT Ctrl. Report Section CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Section", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATControlReportSection(var Rec: Record "VAT Control Report Section"; var xRec: Record "VAT Control Report Section")
    var
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Control Report Section") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Section CZL");
        VATCtrlReportSectionCZL.ChangeCompany(Rec.CurrentCompany);
        if VATCtrlReportSectionCZL.Get(xRec.Code) then
            VATCtrlReportSectionCZL.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Section CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Section", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATControlReportSection(var Rec: Record "VAT Control Report Section")
    begin
        SyncVATControlReportSection(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Section", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATControlReportSection(var Rec: Record "VAT Control Report Section")
    begin
        SyncVATControlReportSection(Rec);
    end;

    local procedure SyncVATControlReportSection(var Rec: Record "VAT Control Report Section")
    var
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Control Report Section") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Section CZL");
        VATCtrlReportSectionCZL.ChangeCompany(Rec.CurrentCompany);
        if not VATCtrlReportSectionCZL.Get(Rec.Code) then begin
            VATCtrlReportSectionCZL.Init();
            VATCtrlReportSectionCZL."Code" := Rec.Code;
            VATCtrlReportSectionCZL.SystemId := Rec.SystemId;
            VATCtrlReportSectionCZL.Insert(false, true);
        end;
        VATCtrlReportSectionCZL.Description := Rec.Description;
        VATCtrlReportSectionCZL."Group By" := Rec."Group By";
        VATCtrlReportSectionCZL."Simplified Tax Doc. Sect. Code" := Rec."Simplified Tax Doc. Sect. Code";
        VATCtrlReportSectionCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Section CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Section", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATControlReportSection(var Rec: Record "VAT Control Report Section")
    var
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Control Report Section") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Section CZL");
        VATCtrlReportSectionCZL.ChangeCompany(Rec.CurrentCompany);
        if VATCtrlReportSectionCZL.Get(Rec.Code) then
            VATCtrlReportSectionCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Section CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Section CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATCtrlReportSectionCZL(var Rec: Record "VAT Ctrl. Report Section CZL"; var xRec: Record "VAT Ctrl. Report Section CZL")
    var
        VATControlReportSection: Record "VAT Control Report Section";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Section CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Control Report Section");
        VATControlReportSection.ChangeCompany(Rec.CurrentCompany);
        if VATControlReportSection.Get(xRec.Code) then
            VATControlReportSection.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Control Report Section");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Section CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATCtrlReportSectionCZL(var Rec: Record "VAT Ctrl. Report Section CZL")
    begin
        SyncVATCtrlReportSectionCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Section CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATCtrlReportSectionCZL(var Rec: Record "VAT Ctrl. Report Section CZL")
    begin
        SyncVATCtrlReportSectionCZL(Rec);
    end;

    local procedure SyncVATCtrlReportSectionCZL(var Rec: Record "VAT Ctrl. Report Section CZL")
    var
        VATControlReportSection: Record "VAT Control Report Section";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Section CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Control Report Section");
        VATControlReportSection.ChangeCompany(Rec.CurrentCompany);
        if not VATControlReportSection.Get(Rec.Code) then begin
            VATControlReportSection.Init();
            VATControlReportSection."Code" := Rec.Code;
            VATControlReportSection.SystemId := Rec.SystemId;
            VATControlReportSection.Insert(false, true);
        end;
        VATControlReportSection.Description := Rec.Description;
        VATControlReportSection."Group By" := Rec."Group By";
        VATControlReportSection."Simplified Tax Doc. Sect. Code" := Rec."Simplified Tax Doc. Sect. Code";
        VATControlReportSection.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Control Report Section");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Section CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATCtrlReportSectionCZL(var Rec: Record "VAT Ctrl. Report Section CZL")
    var
        VATControlReportSection: Record "VAT Control Report Section";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Section CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Control Report Section");
        VATControlReportSection.ChangeCompany(Rec.CurrentCompany);
        if VATControlReportSection.Get(Rec.Code) then
            VATControlReportSection.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Control Report Section");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif