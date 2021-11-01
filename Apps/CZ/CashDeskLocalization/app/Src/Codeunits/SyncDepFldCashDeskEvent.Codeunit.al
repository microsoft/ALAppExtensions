#if not CLEAN17
#pragma warning disable AL0432,AL0603
codeunit 31131 "Sync.Dep.Fld-CashDeskEvent CZP"
{
    Permissions = tabledata "Cash Desk Event" = rimd,
                  tabledata "Cash Desk Event CZP" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.5';

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk Event", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCashDeskEvent(var Rec: Record "Cash Desk Event"; var xRec: Record "Cash Desk Event")
    var
        CashDeskEventCZP: Record "Cash Desk Event CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk Event") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk Event CZP");
        CashDeskEventCZP.ChangeCompany(Rec.CurrentCompany);
        if CashDeskEventCZP.Get(xRec.Code) then
            CashDeskEventCZP.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk Event CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk Event", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCashDeskEvent(var Rec: Record "Cash Desk Event")
    begin
        SyncCashDeskEvent(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk Event", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCashDeskEvent(var Rec: Record "Cash Desk Event")
    begin
        SyncCashDeskEvent(Rec);
    end;

    local procedure SyncCashDeskEvent(var Rec: Record "Cash Desk Event")
    var
        CashDeskEventCZP: Record "Cash Desk Event CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk Event") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk Event CZP");
        CashDeskEventCZP.ChangeCompany(Rec.CurrentCompany);
        if not CashDeskEventCZP.Get(Rec.Code) then begin
            CashDeskEventCZP.Init();
            CashDeskEventCZP.Code := Rec.Code;
            CashDeskEventCZP.SystemId := Rec.SystemId;
            CashDeskEventCZP.Insert(false, true);
        end;
        CashDeskEventCZP."Cash Desk No." := Rec."Cash Desk No.";
        CashDeskEventCZP."Document Type" := Rec."Cash Document Type";
        CashDeskEventCZP.Description := Rec.Description;
        CashDeskEventCZP."Account Type" := Rec."Account Type";
        CashDeskEventCZP."Account No." := Rec."Account No.";
        CashDeskEventCZP."Gen. Document Type" := Rec."Document Type";
        CashDeskEventCZP."Global Dimension 1 Code" := Rec."Global Dimension 1 Code";
        CashDeskEventCZP."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
        CashDeskEventCZP."Gen. Posting Type" := Rec."Gen. Posting Type";
        CashDeskEventCZP."VAT Bus. Posting Group" := Rec."VAT Bus. Posting Group";
        CashDeskEventCZP."VAT Prod. Posting Group" := Rec."VAT Prod. Posting Group";
        CashDeskEventCZP."EET Transaction" := Rec."EET Transaction";
        CashDeskEventCZP.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk Event CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk Event", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCashDeskEvent(var Rec: Record "Cash Desk Event")
    var
        CashDeskEventCZP: Record "Cash Desk Event CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk Event") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk Event CZP");
        CashDeskEventCZP.ChangeCompany(Rec.CurrentCompany);
        if CashDeskEventCZP.Get(Rec.Code) then
            CashDeskEventCZP.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk Event CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk Event CZP", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCashDeskEventCZP(var Rec: Record "Cash Desk Event CZP"; var xRec: Record "Cash Desk Event CZP")
    var
        CashDeskEvent: Record "Cash Desk Event";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk Event CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk Event");
        CashDeskEvent.ChangeCompany(Rec.CurrentCompany);
        if CashDeskEvent.Get(xRec.Code) then
            CashDeskEvent.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk Event");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk Event CZP", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCashDeskEventCZP(var Rec: Record "Cash Desk Event CZP")
    begin
        SyncCashDeskEventCZP(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk Event CZP", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCashDeskEventCZP(var Rec: Record "Cash Desk Event CZP")
    begin
        SyncCashDeskEventCZP(Rec);
    end;

    local procedure SyncCashDeskEventCZP(var Rec: Record "Cash Desk Event CZP")
    var
        CashDeskEvent: Record "Cash Desk Event";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk Event CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk Event");
        CashDeskEvent.ChangeCompany(Rec.CurrentCompany);
        if not CashDeskEvent.Get(Rec.Code) then begin
            CashDeskEvent.Init();
            CashDeskEvent.Code := Rec.Code;
            CashDeskEvent.SystemId := Rec.SystemId;
            CashDeskEvent.Insert(false, true);
        end;
        CashDeskEvent."Cash Desk No." := Rec."Cash Desk No.";
        CashDeskEvent."Cash Document Type" := Rec."Document Type".AsInteger();
        CashDeskEvent.Description := Rec.Description;
        CashDeskEvent."Account Type" := Rec."Account Type".AsInteger();
        CashDeskEvent."Account No." := Rec."Account No.";
        CashDeskEvent."Document Type" := Rec."Gen. Document Type".AsInteger();
        CashDeskEvent."Global Dimension 1 Code" := Rec."Global Dimension 1 Code";
        CashDeskEvent."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
        CashDeskEvent."Gen. Posting Type" := Rec."Gen. Posting Type";
        CashDeskEvent."VAT Bus. Posting Group" := Rec."VAT Bus. Posting Group";
        CashDeskEvent."VAT Prod. Posting Group" := Rec."VAT Prod. Posting Group";
        CashDeskEvent."EET Transaction" := Rec."EET Transaction";
        CashDeskEvent.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk Event");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk Event CZP", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCashDeskEventCZP(var Rec: Record "Cash Desk Event CZP")
    var
        CashDeskEvent: Record "Cash Desk Event";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk Event CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk Event");
        CashDeskEvent.ChangeCompany(Rec.CurrentCompany);
        if CashDeskEvent.Get(Rec.Code) then
            CashDeskEvent.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk Event");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif