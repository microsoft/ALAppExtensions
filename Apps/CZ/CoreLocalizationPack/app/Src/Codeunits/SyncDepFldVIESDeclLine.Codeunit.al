#if not CLEAN17
#pragma warning disable AL0432
codeunit 31141 "Sync.Dep.Fld-VIESDeclLine CZL"
{
    Permissions = tabledata "VIES Declaration Line" = rimd,
                  tabledata "VIES Declaration Line CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVIESDeclarationLine(var Rec: Record "VIES Declaration Line"; var xRec: Record "VIES Declaration Line")
    var
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Line CZL");
        VIESDeclarationLineCZL.ChangeCompany(Rec.CurrentCompany);
        if VIESDeclarationLineCZL.Get(xRec."VIES Declaration No.", xRec."Line No.") then
            VIESDeclarationLineCZL.Rename(Rec."VIES Declaration No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Line CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVIESDeclarationLine(var Rec: Record "VIES Declaration Line")
    begin
        SyncVIESDeclarationLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVIESDeclarationLine(var Rec: Record "VIES Declaration Line")
    begin
        SyncVIESDeclarationLine(Rec);
    end;

    local procedure SyncVIESDeclarationLine(var Rec: Record "VIES Declaration Line")
    var
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Line CZL");
        VIESDeclarationLineCZL.ChangeCompany(Rec.CurrentCompany);
        if not VIESDeclarationLineCZL.Get(Rec."VIES Declaration No.", Rec."Line No.") then begin
            VIESDeclarationLineCZL.Init();
            VIESDeclarationLineCZL."VIES Declaration No." := Rec."VIES Declaration No.";
            VIESDeclarationLineCZL."Line No." := Rec."Line No.";
            VIESDeclarationLineCZL.SystemId := Rec.SystemId;
            VIESDeclarationLineCZL.Insert(false, true);
        end;
        VIESDeclarationLineCZL."Trade Type" := Rec."Trade Type";
        VIESDeclarationLineCZL."Line Type" := Rec."Line Type";
        VIESDeclarationLineCZL."Related Line No." := Rec."Related Line No.";
        VIESDeclarationLineCZL."EU Service" := Rec."EU Service";
        VIESDeclarationLineCZL."Country/Region Code" := Rec."Country/Region Code";
        VIESDeclarationLineCZL."VAT Registration No." := Rec."VAT Registration No.";
        VIESDeclarationLineCZL."Amount (LCY)" := Rec."Amount (LCY)";
        VIESDeclarationLineCZL."EU 3-Party Trade" := Rec."EU 3-Party Trade";
        VIESDeclarationLineCZL."Registration No." := Rec."Registration No.";
        VIESDeclarationLineCZL."EU 3-Party Intermediate Role" := Rec."EU 3-Party Intermediate Role";
        VIESDeclarationLineCZL."Number of Supplies" := Rec."Number of Supplies";
        VIESDeclarationLineCZL."Corrected Reg. No." := Rec."Corrected Reg. No.";
        VIESDeclarationLineCZL."Corrected Amount" := Rec."Corrected Amount";
        VIESDeclarationLineCZL."Trade Role Type" := Rec."Trade Role Type";
        VIESDeclarationLineCZL."System-Created" := Rec."System-Created";
        VIESDeclarationLineCZL."Report Page Number" := Rec."Report Page Number";
        VIESDeclarationLineCZL."Report Line Number" := Rec."Report Line Number";
        VIESDeclarationLineCZL."Record Code" := Rec."Record Code";
        VIESDeclarationLineCZL."VAT Reg. No. of Original Cust." := Rec."VAT Reg. No. of Original Cust.";
        VIESDeclarationLineCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Line CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVIESDeclarationLine(var Rec: Record "VIES Declaration Line")
    var
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Line CZL");
        VIESDeclarationLineCZL.ChangeCompany(Rec.CurrentCompany);
        if VIESDeclarationLineCZL.Get(Rec."VIES Declaration No.", Rec."Line No.") then
            VIESDeclarationLineCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Line CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Line CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVIESDeclarationLineCZL(var Rec: Record "VIES Declaration Line CZL"; var xRec: Record "VIES Declaration Line CZL")
    var
        VIESDeclarationLine: Record "VIES Declaration Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Line CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Line");
        VIESDeclarationLine.ChangeCompany(Rec.CurrentCompany);
        if VIESDeclarationLine.Get(xRec."VIES Declaration No.", xRec."Line No.") then
            VIESDeclarationLine.Rename(Rec."VIES Declaration No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Line CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVIESDeclarationLineCZL(var Rec: Record "VIES Declaration Line CZL")
    begin
        SyncVIESDeclarationLineCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Line CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVIESDeclarationLineCZL(var Rec: Record "VIES Declaration Line CZL")
    begin
        SyncVIESDeclarationLineCZL(Rec);
    end;

    local procedure SyncVIESDeclarationLineCZL(var Rec: Record "VIES Declaration Line CZL")
    var
        VIESDeclarationLine: Record "VIES Declaration Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Line CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Line");
        VIESDeclarationLine.ChangeCompany(Rec.CurrentCompany);
        if not VIESDeclarationLine.Get(Rec."VIES Declaration No.", Rec."Line No.") then begin
            VIESDeclarationLine.Init();
            VIESDeclarationLine."VIES Declaration No." := Rec."VIES Declaration No.";
            VIESDeclarationLine."Line No." := Rec."Line No.";
            VIESDeclarationLine.SystemId := Rec.SystemId;
            VIESDeclarationLine.Insert(false, true);
        end;
        VIESDeclarationLine."Trade Type" := Rec."Trade Type";
        VIESDeclarationLine."Line Type" := Rec."Line Type";
        VIESDeclarationLine."Related Line No." := Rec."Related Line No.";
        VIESDeclarationLine."EU Service" := Rec."EU Service";
        VIESDeclarationLine."Country/Region Code" := Rec."Country/Region Code";
        VIESDeclarationLine."VAT Registration No." := Rec."VAT Registration No.";
        VIESDeclarationLine."Amount (LCY)" := Rec."Amount (LCY)";
        VIESDeclarationLine."EU 3-Party Trade" := Rec."EU 3-Party Trade";
        VIESDeclarationLine."Registration No." := Rec."Registration No.";
        VIESDeclarationLine."EU 3-Party Intermediate Role" := Rec."EU 3-Party Intermediate Role";
        VIESDeclarationLine."Number of Supplies" := Rec."Number of Supplies";
        VIESDeclarationLine."Corrected Reg. No." := Rec."Corrected Reg. No.";
        VIESDeclarationLine."Corrected Amount" := Rec."Corrected Amount";
        VIESDeclarationLine."Trade Role Type" := Rec."Trade Role Type";
        VIESDeclarationLine."System-Created" := Rec."System-Created";
        VIESDeclarationLine."Report Page Number" := Rec."Report Page Number";
        VIESDeclarationLine."Report Line Number" := Rec."Report Line Number";
        VIESDeclarationLine."Record Code" := Rec."Record Code";
        VIESDeclarationLine."VAT Reg. No. of Original Cust." := Rec."VAT Reg. No. of Original Cust.";
        VIESDeclarationLine.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Line CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVIESDeclarationLineCZL(var Rec: Record "VIES Declaration Line CZL")
    var
        VIESDeclarationLine: Record "VIES Declaration Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Line CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Line");
        VIESDeclarationLine.ChangeCompany(Rec.CurrentCompany);
        if VIESDeclarationLine.Get(Rec."VIES Declaration No.", Rec."Line No.") then
            VIESDeclarationLine.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Line");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif