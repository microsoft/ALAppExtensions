#if not CLEAN18
#pragma warning disable AL0432
codeunit 31138 "Sync.Dep.Fld-EETEntry CZL"
{
    Permissions = tabledata "EET Entry" = rimd,
                  tabledata "EET Entry CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"EET Entry", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameEETEntry(var Rec: Record "EET Entry"; var xRec: Record "EET Entry")
    var
        EETEntryCZL: Record "EET Entry CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry CZL");
        EETEntryCZL.ChangeCompany(Rec.CurrentCompany);
        if EETEntryCZL.Get(xRec."Entry No.") then
            EETEntryCZL.Rename(Rec."Entry No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertEETEntry(var Rec: Record "EET Entry")
    begin
        SyncEETEntry(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyEETEntry(var Rec: Record "EET Entry")
    begin
        SyncEETEntry(Rec);
    end;

    local procedure SyncEETEntry(var EETEntry: Record "EET Entry")
    var
        EETEntryCZL: Record "EET Entry CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if EETEntry.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry CZL");
        EETEntryCZL.ChangeCompany(EETEntry.CurrentCompany);
        if not EETEntryCZL.Get(EETEntry."Entry No.") then begin
            EETEntryCZL.Init();
            EETEntryCZL."Entry No." := EETEntry."Entry No.";
            EETEntryCZL.SystemId := EETEntry.SystemId;
            EETEntryCZL.Insert(false, true);
        end;
        EETEntryCZL."Cash Register Type" := "EET Cash Register Type CZL".FromInteger(EETEntry."Source Type");
        EETEntryCZL."Cash Register No." := EETEntry."Source No.";
        EETEntryCZL."Business Premises Code" := EETEntry."Business Premises Code";
        EETEntryCZL."Cash Register Code" := EETEntry."Cash Register Code";
        EETEntryCZL."Document No." := EETEntry."Document No.";
        EETEntryCZL.Description := EETEntry.Description;
        EETEntryCZL."Applied Document Type" := "EET Applied Document Type CZL".FromInteger(EETEntry."Applied Document Type");
        EETEntryCZL."Applied Document No." := EETEntry."Applied Document No.";
        EETEntryCZL."Created By" := EETEntry."User ID";
        EETEntryCZL."Created At" := EETEntry."Creation Datetime";
        EETEntryCZL."Status" := "EET Status CZL".FromInteger(EETEntry."EET Status");
        EETEntryCZL."Status Last Changed At" := EETEntry."EET Status Last Changed";
        EETEntryCZL."Message UUID" := EETEntry."Message UUID";
        EETEntry.CalcFields("Signature Code (PKP)");
        EETEntryCZL."Taxpayer's Signature Code" := EETEntry."Signature Code (PKP)";
        EETEntryCZL."Taxpayer's Security Code" := EETEntry."Security Code (BKP)";
        EETEntryCZL."Fiscal Identification Code" := EETEntry."Fiscal Identification Code";
        EETEntryCZL."Receipt Serial No." := EETEntry."Receipt Serial No.";
        EETEntryCZL."Total Sales Amount" := EETEntry."Total Sales Amount";
        EETEntryCZL."Amount Exempted From VAT" := EETEntry."Amount Exempted From VAT";
        EETEntryCZL."VAT Base (Basic)" := EETEntry."VAT Base (Basic)";
        EETEntryCZL."VAT Amount (Basic)" := EETEntry."VAT Amount (Basic)";
        EETEntryCZL."VAT Base (Reduced)" := EETEntry."VAT Base (Reduced)";
        EETEntryCZL."VAT Amount (Reduced)" := EETEntry."VAT Amount (Reduced)";
        EETEntryCZL."VAT Base (Reduced 2)" := EETEntry."VAT Base (Reduced 2)";
        EETEntryCZL."VAT Amount (Reduced 2)" := EETEntry."VAT Amount (Reduced 2)";
        EETEntryCZL."Amount - Art.89" := EETEntry."Amount - Art.89";
        EETEntryCZL."Amount (Basic) - Art.90" := EETEntry."Amount (Basic) - Art.90";
        EETEntryCZL."Amount (Reduced) - Art.90" := EETEntry."Amount (Reduced) - Art.90";
        EETEntryCZL."Amount (Reduced 2) - Art.90" := EETEntry."Amount (Reduced 2) - Art.90";
        EETEntryCZL."Amt. For Subseq. Draw/Settle" := EETEntry."Amt. For Subseq. Draw/Settle";
        EETEntryCZL."Amt. Subseq. Drawn/Settled" := EETEntry."Amt. Subseq. Drawn/Settled";
        EETEntryCZL."Canceled By Entry No." := EETEntry."Canceled By Entry No.";
        EETEntryCZL."Simple Registration" := EETEntry."Simple Registration";
        EETEntryCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteEETEntry(var Rec: Record "EET Entry")
    var
        EETEntryCZL: Record "EET Entry CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry CZL");
        EETEntryCZL.ChangeCompany(Rec.CurrentCompany);
        if EETEntryCZL.Get(Rec."Entry No.") then
            EETEntryCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameEETEntryCZL(var Rec: Record "EET Entry CZL"; var xRec: Record "EET Entry CZL")
    var
        EETEntry: Record "EET Entry";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry");
        EETEntry.ChangeCompany(Rec.CurrentCompany);
        if EETEntry.Get(xRec."Entry No.") then
            EETEntry.Rename(Rec."Entry No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertEETEntryCZL(var Rec: Record "EET Entry CZL")
    begin
        SyncEETEntryCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyEETEntryCZL(var Rec: Record "EET Entry CZL")
    begin
        SyncEETEntryCZL(Rec);
    end;

    local procedure SyncEETEntryCZL(var EETEntryCZL: Record "EET Entry CZL")
    var
        EETEntry: Record "EET Entry";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if EETEntryCZL.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry");
        EETEntry.ChangeCompany(EETEntryCZL.CurrentCompany);
        if not EETEntry.Get(EETEntryCZL."Entry No.") then begin
            EETEntry.Init();
            EETEntry."Entry No." := EETEntryCZL."Entry No.";
            EETEntry.SystemId := EETEntryCZL.SystemId;
            EETEntry.Insert(false, true);
        end;
        EETEntry."Source Type" := EETEntryCZL."Cash Register Type".AsInteger();
        EETEntry."Source No." := EETEntryCZL."Cash Register No.";
        EETEntry."Business Premises Code" := EETEntryCZL."Business Premises Code";
        EETEntry."Cash Register Code" := EETEntryCZL."Cash Register Code";
        EETEntry."Document No." := EETEntryCZL."Document No.";
        EETEntry.Description := EETEntryCZL.Description;
        EETEntry."Applied Document Type" := EETEntryCZL."Applied Document Type".AsInteger();
        EETEntry."Applied Document No." := EETEntryCZL."Applied Document No.";
        EETEntry."User ID" := EETEntryCZL."Created By";
        EETEntry."Creation Datetime" := EETEntryCZL."Created At";
        EETEntry."EET Status" := EETEntryCZL."Status".AsInteger();
        EETEntry."EET Status Last Changed" := EETEntryCZL."Status Last Changed At";
        EETEntry."Message UUID" := EETEntryCZL."Message UUID";
        EETEntryCZL.CalcFields("Taxpayer's Signature Code");
        EETEntry."Signature Code (PKP)" := EETEntryCZL."Taxpayer's Signature Code";
        EETEntry."Security Code (BKP)" := EETEntryCZL."Taxpayer's Security Code";
        EETEntry."Fiscal Identification Code" := EETEntryCZL."Fiscal Identification Code";
        EETEntry."Receipt Serial No." := EETEntryCZL."Receipt Serial No.";
        EETEntry."Total Sales Amount" := EETEntryCZL."Total Sales Amount";
        EETEntry."Amount Exempted From VAT" := EETEntryCZL."Amount Exempted From VAT";
        EETEntry."VAT Base (Basic)" := EETEntryCZL."VAT Base (Basic)";
        EETEntry."VAT Amount (Basic)" := EETEntryCZL."VAT Amount (Basic)";
        EETEntry."VAT Base (Reduced)" := EETEntryCZL."VAT Base (Reduced)";
        EETEntry."VAT Amount (Reduced)" := EETEntryCZL."VAT Amount (Reduced)";
        EETEntry."VAT Base (Reduced 2)" := EETEntryCZL."VAT Base (Reduced 2)";
        EETEntry."VAT Amount (Reduced 2)" := EETEntryCZL."VAT Amount (Reduced 2)";
        EETEntry."Amount - Art.89" := EETEntryCZL."Amount - Art.89";
        EETEntry."Amount (Basic) - Art.90" := EETEntryCZL."Amount (Basic) - Art.90";
        EETEntry."Amount (Reduced) - Art.90" := EETEntryCZL."Amount (Reduced) - Art.90";
        EETEntry."Amount (Reduced 2) - Art.90" := EETEntryCZL."Amount (Reduced 2) - Art.90";
        EETEntry."Amt. For Subseq. Draw/Settle" := EETEntryCZL."Amt. For Subseq. Draw/Settle";
        EETEntry."Amt. Subseq. Drawn/Settled" := EETEntryCZL."Amt. Subseq. Drawn/Settled";
        EETEntry."Canceled By Entry No." := EETEntryCZL."Canceled By Entry No.";
        EETEntry."Simple Registration" := EETEntryCZL."Simple Registration";
        EETEntry.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteEETEntryCZL(var Rec: Record "EET Entry CZL")
    var
        EETEntry: Record "EET Entry";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"EET Entry CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"EET Entry");
        EETEntry.ChangeCompany(Rec.CurrentCompany);
        if EETEntry.Get(Rec."Entry No.") then
            EETEntry.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"EET Entry");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif