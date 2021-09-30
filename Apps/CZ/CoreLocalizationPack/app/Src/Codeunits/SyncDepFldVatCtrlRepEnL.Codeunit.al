#if not CLEAN17
#pragma warning disable AL0432
codeunit 31179 "Sync.Dep.Fld-VatCtrlRepEnL CZL"
{
    Permissions = tabledata "VAT Ctrl.Rep. - VAT Entry Link" = rimd,
                  tabledata "VAT Ctrl. Report Ent. Link CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl.Rep. - VAT Entry Link", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATCtrlRepVATEntryLink(var Rec: Record "VAT Ctrl.Rep. - VAT Entry Link"; var xRec: Record "VAT Ctrl.Rep. - VAT Entry Link")
    var
        VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl.Rep. - VAT Entry Link") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Ent. Link CZL");
        VATCtrlReportEntLinkCZL.ChangeCompany(Rec.CurrentCompany);
        if VATCtrlReportEntLinkCZL.Get(xRec."Control Report No.", xRec."Line No.", xRec."VAT Entry No.") then
            VATCtrlReportEntLinkCZL.Rename(Rec."Control Report No.", Rec."Line No.", Rec."VAT Entry No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Ent. Link CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl.Rep. - VAT Entry Link", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATCtrlRepVATEntryLink(var Rec: Record "VAT Ctrl.Rep. - VAT Entry Link")
    begin
        SyncVATControlReportEntLink(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl.Rep. - VAT Entry Link", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATCtrlRepVATEntryLink(var Rec: Record "VAT Ctrl.Rep. - VAT Entry Link")
    begin
        SyncVATControlReportEntLink(Rec);
    end;

    local procedure SyncVATControlReportEntLink(var Rec: Record "VAT Ctrl.Rep. - VAT Entry Link")
    var
        VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl.Rep. - VAT Entry Link") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Ent. Link CZL");
        VATCtrlReportEntLinkCZL.ChangeCompany(Rec.CurrentCompany);
        if not VATCtrlReportEntLinkCZL.Get(Rec."Control Report No.", Rec."Line No.", Rec."VAT Entry No.") then begin
            VATCtrlReportEntLinkCZL.Init();
            VATCtrlReportEntLinkCZL."VAT Ctrl. Report No." := Rec."Control Report No.";
            VATCtrlReportEntLinkCZL."Line No." := Rec."Line No.";
            VATCtrlReportEntLinkCZL."VAT Entry No." := Rec."VAT Entry No.";
            VATCtrlReportEntLinkCZL.SystemId := Rec.SystemId;
            VATCtrlReportEntLinkCZL.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Ent. Link CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl.Rep. - VAT Entry Link", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATCtrlRepVATEntryLink(var Rec: Record "VAT Ctrl.Rep. - VAT Entry Link")
    var
        VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl.Rep. - VAT Entry Link") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Ent. Link CZL");
        VATCtrlReportEntLinkCZL.ChangeCompany(Rec.CurrentCompany);
        if VATCtrlReportEntLinkCZL.Get(Rec."Control Report No.", Rec."Line No.", Rec."VAT Entry No.") then
            VATCtrlReportEntLinkCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Ent. Link CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Ent. Link CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATCtrlReportEntLinkCZL(var Rec: Record "VAT Ctrl. Report Ent. Link CZL"; var xRec: Record "VAT Ctrl. Report Ent. Link CZL")
    var
        VATCtrlRepVATEntryLink: Record "VAT Ctrl.Rep. - VAT Entry Link";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Ent. Link CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl.Rep. - VAT Entry Link");
        VATCtrlRepVATEntryLink.ChangeCompany(Rec.CurrentCompany);
        if VATCtrlRepVATEntryLink.Get(xRec."VAT Ctrl. Report No.", xRec."Line No.", xRec."VAT Entry No.") then
            VATCtrlRepVATEntryLink.Rename(Rec."VAT Ctrl. Report No.", Rec."Line No.", Rec."VAT Entry No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl.Rep. - VAT Entry Link");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Ent. Link CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATCtrlReportEntLinkCZL(var Rec: Record "VAT Ctrl. Report Ent. Link CZL")
    begin
        SyncVATCtrlReportEntLinkCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Ent. Link CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATCtrlReportEntLinkCZL(var Rec: Record "VAT Ctrl. Report Ent. Link CZL")
    begin
        SyncVATCtrlReportEntLinkCZL(Rec);
    end;

    local procedure SyncVATCtrlReportEntLinkCZL(var Rec: Record "VAT Ctrl. Report Ent. Link CZL")
    var
        VATCtrlRepVATEntryLink: Record "VAT Ctrl.Rep. - VAT Entry Link";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Ent. Link CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl.Rep. - VAT Entry Link");
        VATCtrlRepVATEntryLink.ChangeCompany(Rec.CurrentCompany);
        if not VATCtrlRepVATEntryLink.Get(Rec."VAT Ctrl. Report No.", Rec."Line No.", Rec."VAT Entry No.") then begin
            VATCtrlRepVATEntryLink.Init();
            VATCtrlRepVATEntryLink."Control Report No." := Rec."VAT Ctrl. Report No.";
            VATCtrlRepVATEntryLink."Line No." := Rec."Line No.";
            VATCtrlRepVATEntryLink."VAT Entry No." := Rec."VAT Entry No.";
            VATCtrlRepVATEntryLink.SystemId := Rec.SystemId;
            VATCtrlRepVATEntryLink.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl.Rep. - VAT Entry Link");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Ent. Link CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATCtrlReportEntLinkCZL(var Rec: Record "VAT Ctrl. Report Ent. Link CZL")
    var
        VATCtrlRepVATEntryLink: Record "VAT Ctrl.Rep. - VAT Entry Link";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Ent. Link CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl.Rep. - VAT Entry Link");
        VATCtrlRepVATEntryLink.ChangeCompany(Rec.CurrentCompany);
        if VATCtrlRepVATEntryLink.Get(Rec."VAT Ctrl. Report No.", Rec."Line No.", Rec."VAT Entry No.") then
            VATCtrlRepVATEntryLink.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl.Rep. - VAT Entry Link");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif