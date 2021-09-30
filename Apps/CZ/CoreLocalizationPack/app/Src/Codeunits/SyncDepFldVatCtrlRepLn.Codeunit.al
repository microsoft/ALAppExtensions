#if not CLEAN17
#pragma warning disable AL0432
codeunit 31178 "Sync.Dep.Fld-VatCtrlRepLn CZL"
{
    Permissions = tabledata "VAT Control Report Line" = rimd,
                  tabledata "VAT Ctrl. Report Line CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATControlReportLine(var Rec: Record "VAT Control Report Line"; var xRec: Record "VAT Control Report Line")
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Control Report Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Line CZL");
        VATCtrlReportLineCZL.ChangeCompany(Rec.CurrentCompany);
        if VATCtrlReportLineCZL.Get(xRec."Control Report No.", xRec."Line No.") then
            VATCtrlReportLineCZL.Rename(Rec."Control Report No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Line CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATControlReportLine(var Rec: Record "VAT Control Report Line")
    begin
        SyncVATControlReportLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATControlReportLine(var Rec: Record "VAT Control Report Line")
    begin
        SyncVATControlReportLine(Rec);
    end;

    local procedure SyncVATControlReportLine(var Rec: Record "VAT Control Report Line")
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Control Report Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Line CZL");
        VATCtrlReportLineCZL.ChangeCompany(Rec.CurrentCompany);
        if not VATCtrlReportLineCZL.Get(Rec."Control Report No.", Rec."Line No.") then begin
            VATCtrlReportLineCZL.Init();
            VATCtrlReportLineCZL."VAT Ctrl. Report No." := Rec."Control Report No.";
            VATCtrlReportLineCZL."Line No." := Rec."Line No.";
            VATCtrlReportLineCZL.SystemId := Rec.SystemId;
            VATCtrlReportLineCZL.Insert(false, true);
        end;
        VATCtrlReportLineCZL."VAT Ctrl. Report Section Code" := Rec."VAT Control Rep. Section Code";
        VATCtrlReportLineCZL."Posting Date" := Rec."Posting Date";
        VATCtrlReportLineCZL."VAT Date" := Rec."VAT Date";
        VATCtrlReportLineCZL."Original Document VAT Date" := Rec."Original Document VAT Date";
        VATCtrlReportLineCZL."Bill-to/Pay-to No." := Rec."Bill-to/Pay-to No.";
        VATCtrlReportLineCZL."VAT Registration No." := Rec."VAT Registration No.";
        VATCtrlReportLineCZL."Registration No." := Rec."Registration No.";
        VATCtrlReportLineCZL."Tax Registration No." := Rec."Tax Registration No.";
        VATCtrlReportLineCZL."Document No." := Rec."Document No.";
        VATCtrlReportLineCZL."External Document No." := Rec."External Document No.";
        VATCtrlReportLineCZL.Type := Rec.Type;
        VATCtrlReportLineCZL."VAT Bus. Posting Group" := Rec."VAT Bus. Posting Group";
        VATCtrlReportLineCZL."VAT Prod. Posting Group" := Rec."VAT Prod. Posting Group";
        VATCtrlReportLineCZL.Base := Rec.Base;
        VATCtrlReportLineCZL.Amount := Rec.Amount;
        VATCtrlReportLineCZL."VAT Rate" := Rec."VAT Rate";
        VATCtrlReportLineCZL."Commodity Code" := Rec."Commodity Code";
        VATCtrlReportLineCZL."Supplies Mode Code" := Rec."Supplies Mode Code";
        VATCtrlReportLineCZL."Corrections for Bad Receivable" := "VAT Ctrl. Report Corect. CZL".FromInteger(Rec."Corrections for Bad Receivable");
        VATCtrlReportLineCZL."Ratio Use" := Rec."Ratio Use";
        VATCtrlReportLineCZL.Name := Rec.Name;
        VATCtrlReportLineCZL."Birth Date" := Rec."Birth Date";
        VATCtrlReportLineCZL."Place of Stay" := Rec."Place of stay";
        VATCtrlReportLineCZL."Exclude from Export" := Rec."Exclude from Export";
        VATCtrlReportLineCZL."Closed by Document No." := Rec."Closed by Document No.";
        VATCtrlReportLineCZL."Closed Date" := Rec."Closed Date";
        VATCtrlReportLineCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Line CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Control Report Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATControlReportLine(var Rec: Record "VAT Control Report Line")
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Control Report Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Ctrl. Report Line CZL");
        VATCtrlReportLineCZL.ChangeCompany(Rec.CurrentCompany);
        if VATCtrlReportLineCZL.Get(Rec."Control Report No.", Rec."Line No.") then
            VATCtrlReportLineCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Ctrl. Report Line CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Line CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVATCtrlReportLineCZL(var Rec: Record "VAT Ctrl. Report Line CZL"; var xRec: Record "VAT Ctrl. Report Line CZL")
    var
        VATControlReportLine: Record "VAT Control Report Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Line CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Control Report Line");
        VATControlReportLine.ChangeCompany(Rec.CurrentCompany);
        if VATControlReportLine.Get(xRec."VAT Ctrl. Report No.", xRec."Line No.") then
            VATControlReportLine.Rename(Rec."VAT Ctrl. Report No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Control Report Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Line CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATCtrlReportLineCZL(var Rec: Record "VAT Ctrl. Report Line CZL")
    begin
        SyncVATCtrlReportLineCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Line CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATCtrlReportLineCZL(var Rec: Record "VAT Ctrl. Report Line CZL")
    begin
        SyncVATCtrlReportLineCZL(Rec);
    end;

    local procedure SyncVATCtrlReportLineCZL(var Rec: Record "VAT Ctrl. Report Line CZL")
    var
        VATControlReportLine: Record "VAT Control Report Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Line CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Control Report Line");
        VATControlReportLine.ChangeCompany(Rec.CurrentCompany);
        if not VATControlReportLine.Get(Rec."VAT Ctrl. Report No.", Rec."Line No.") then begin
            VATControlReportLine.Init();
            VATControlReportLine."Control Report No." := Rec."VAT Ctrl. Report No.";
            VATControlReportLine."Line No." := Rec."Line No.";
            VATControlReportLine.SystemId := Rec.SystemId;
            VATControlReportLine.Insert(false, true);
        end;
        VATControlReportLine."VAT Control Rep. Section Code" := Rec."VAT Ctrl. Report Section Code";
        VATControlReportLine."Posting Date" := Rec."Posting Date";
        VATControlReportLine."VAT Date" := Rec."VAT Date";
        VATControlReportLine."Original Document VAT Date" := Rec."Original Document VAT Date";
        VATControlReportLine."Bill-to/Pay-to No." := Rec."Bill-to/Pay-to No.";
        VATControlReportLine."VAT Registration No." := Rec."VAT Registration No.";
        VATControlReportLine."Registration No." := Rec."Registration No.";
        VATControlReportLine."Tax Registration No." := Rec."Tax Registration No.";
        VATControlReportLine."Document No." := Rec."Document No.";
        VATControlReportLine."External Document No." := Rec."External Document No.";
        VATControlReportLine.Type := Rec.Type;
        VATControlReportLine."VAT Bus. Posting Group" := Rec."VAT Bus. Posting Group";
        VATControlReportLine."VAT Prod. Posting Group" := Rec."VAT Prod. Posting Group";
        VATControlReportLine.Base := Rec.Base;
        VATControlReportLine.Amount := Rec.Amount;
        VATControlReportLine."VAT Rate" := Rec."VAT Rate";
        VATControlReportLine."Commodity Code" := Rec."Commodity Code";
        VATControlReportLine."Supplies Mode Code" := Rec."Supplies Mode Code";
        VATControlReportLine."Corrections for Bad Receivable" := Rec."Corrections for Bad Receivable".AsInteger();
        VATControlReportLine."Ratio Use" := Rec."Ratio Use";
        VATControlReportLine.Name := Rec.Name;
        VATControlReportLine."Birth Date" := Rec."Birth Date";
        VATControlReportLine."Place of stay" := Rec."Place of Stay";
        VATControlReportLine."Exclude from Export" := Rec."Exclude from Export";
        VATControlReportLine."Closed by Document No." := Rec."Closed by Document No.";
        VATControlReportLine."Closed Date" := Rec."Closed Date";
        VATControlReportLine.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Control Report Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Line CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATCtrlReportLineCZL(var Rec: Record "VAT Ctrl. Report Line CZL")
    var
        VATControlReportLine: Record "VAT Control Report Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Ctrl. Report Line CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Control Report Line");
        VATControlReportLine.ChangeCompany(Rec.CurrentCompany);
        if VATControlReportLine.Get(Rec."VAT Ctrl. Report No.", Rec."Line No.") then
            VATControlReportLine.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Control Report Line");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif