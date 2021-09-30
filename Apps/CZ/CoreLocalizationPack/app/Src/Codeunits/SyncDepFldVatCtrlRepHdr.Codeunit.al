#if not CLEAN17
#pragma warning disable AL0432
codeunit 31177 "Sync.Dep.Fld-VatCtrlRepHdr CZL"
{
    Permissions = tabledata "VAT Control Report Header" = rimd,
                  tabledata "VAT Ctrl. Report Header CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Header", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATControlReportHeader(var Rec: Record "VAT Control Report Header"; var xRec: Record "VAT Control Report Header")
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Control Report Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Header CZL");
        VATCtrlReportHeaderCZL.ChangeCompany(Rec.CurrentCompany);
        if VATCtrlReportHeaderCZL.Get(xRec."No.") then
            VATCtrlReportHeaderCZL.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Header CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATControlReportHeader(var Rec: Record "VAT Control Report Header")
    begin
        SyncVATControlReportHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATControlReportHeader(var Rec: Record "VAT Control Report Header")
    begin
        SyncVATControlReportHeader(Rec);
    end;

    local procedure SyncVATControlReportHeader(var Rec: Record "VAT Control Report Header")
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Control Report Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Header CZL");
        VATCtrlReportHeaderCZL.ChangeCompany(Rec.CurrentCompany);
        if not VATCtrlReportHeaderCZL.Get(Rec."No.") then begin
            VATCtrlReportHeaderCZL.Init();
            VATCtrlReportHeaderCZL."No." := Rec."No.";
            VATCtrlReportHeaderCZL.SystemId := Rec.SystemId;
            VATCtrlReportHeaderCZL.Insert(false, true);
        end;
        VATCtrlReportHeaderCZL.Description := Rec.Description;
        VATCtrlReportHeaderCZL."Report Period" := Rec."Report Period";
        VATCtrlReportHeaderCZL."Period No." := Rec."Period No.";
        VATCtrlReportHeaderCZL.Year := Rec.Year;
        VATCtrlReportHeaderCZL."Start Date" := Rec."Start Date";
        VATCtrlReportHeaderCZL."End Date" := Rec."End Date";
        VATCtrlReportHeaderCZL."Created Date" := Rec."Created Date";
        VATCtrlReportHeaderCZL.Status := Rec.Status;
        VATCtrlReportHeaderCZL."VAT Statement Template Name" := Rec."VAT Statement Template Name";
        VATCtrlReportHeaderCZL."VAT Statement Name" := Rec."VAT Statement Name";
        VATCtrlReportHeaderCZL."No. Series" := Rec."No. Series";
        VATCtrlReportHeaderCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Header CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATControlReportHeader(var Rec: Record "VAT Control Report Header")
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Control Report Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Header CZL");
        VATCtrlReportHeaderCZL.ChangeCompany(Rec.CurrentCompany);
        if VATCtrlReportHeaderCZL.Get(Rec."No.") then
            VATCtrlReportHeaderCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Header CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Header CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATCtrlReportHeaderCZL(var Rec: Record "VAT Ctrl. Report Header CZL"; var xRec: Record "VAT Ctrl. Report Header CZL")
    var
        VATControlReportHeader: Record "VAT Control Report Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Header CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Control Report Header");
        VATControlReportHeader.ChangeCompany(Rec.CurrentCompany);
        if VATControlReportHeader.Get(xRec."No.") then
            VATControlReportHeader.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Control Report Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Header CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATCtrlReportHeaderCZL(var Rec: Record "VAT Ctrl. Report Header CZL")
    begin
        SyncVATCtrlReportHeaderCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Header CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATCtrlReportHeaderCZL(var Rec: Record "VAT Ctrl. Report Header CZL")
    begin
        SyncVATCtrlReportHeaderCZL(Rec);
    end;

    local procedure SyncVATCtrlReportHeaderCZL(var Rec: Record "VAT Ctrl. Report Header CZL")
    var
        VATControlReportHeader: Record "VAT Control Report Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Header CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Control Report Header");
        VATControlReportHeader.ChangeCompany(Rec.CurrentCompany);
        if not VATControlReportHeader.Get(Rec."No.") then begin
            VATControlReportHeader.Init();
            VATControlReportHeader."No." := Rec."No.";
            VATControlReportHeader.SystemId := rec.SystemId;
            VATControlReportHeader.Insert(false, true);
        end;
        VATControlReportHeader.Description := Rec.Description;
        VATControlReportHeader."Report Period" := Rec."Report Period";
        VATControlReportHeader."Period No." := Rec."Period No.";
        VATControlReportHeader.Year := Rec.Year;
        VATControlReportHeader."Start Date" := Rec."Start Date";
        VATControlReportHeader."End Date" := Rec."End Date";
        VATControlReportHeader."Created Date" := Rec."Created Date";
        VATControlReportHeader.Status := Rec.Status;
        VATControlReportHeader."VAT Statement Template Name" := Rec."VAT Statement Template Name";
        VATControlReportHeader."VAT Statement Name" := Rec."VAT Statement Name";
        VATControlReportHeader."No. Series" := Rec."No. Series";
        VATControlReportHeader.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Control Report Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Header CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATCtrlReportHeaderCZL(var Rec: Record "VAT Ctrl. Report Header CZL")
    var
        VATControlReportHeader: Record "VAT Control Report Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Header CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Control Report Header");
        VATControlReportHeader.ChangeCompany(Rec.CurrentCompany);
        if VATControlReportHeader.Get(Rec."No.") then
            VATControlReportHeader.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Control Report Header");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif