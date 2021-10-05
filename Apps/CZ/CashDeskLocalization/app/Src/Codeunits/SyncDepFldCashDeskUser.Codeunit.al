#if not CLEAN17
#pragma warning disable AL0432
codeunit 31126 "Sync.Dep.Fld-CashDeskUser CZP"
{
    Permissions = tabledata "Cash Desk User" = rimd,
                  tabledata "Cash Desk User CZP" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.5';

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk User", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCashDeskUser(var Rec: Record "Cash Desk User"; var xRec: Record "Cash Desk User")
    var
        CashDeskUserCZP: Record "Cash Desk User CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk User") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk User CZP");
        CashDeskUserCZP.ChangeCompany(Rec.CurrentCompany);
        if CashDeskUserCZP.Get(xRec."Cash Desk No.", xRec."User ID") then
            CashDeskUserCZP.Rename(Rec."Cash Desk No.", Rec."User ID");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk User CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk User", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCashDeskUser(var Rec: Record "Cash Desk User")
    begin
        SyncCashDeskUser(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk User", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCashDeskUser(var Rec: Record "Cash Desk User")
    begin
        SyncCashDeskUser(Rec);
    end;

    local procedure SyncCashDeskUser(var Rec: Record "Cash Desk User")
    var
        CashDeskUserCZP: Record "Cash Desk User CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk User") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk User CZP");
        CashDeskUserCZP.ChangeCompany(Rec.CurrentCompany);
        if not CashDeskUserCZP.Get(Rec."Cash Desk No.", Rec."User ID") then begin
            CashDeskUserCZP.Init();
            CashDeskUserCZP."Cash Desk No." := Rec."Cash Desk No.";
            CashDeskUserCZP."User ID" := Rec."User ID";
            CashDeskUserCZP.SystemId := Rec.SystemId;
            CashDeskUserCZP.Insert(false, true);
        end;
        CashDeskUserCZP.Create := Rec.Create;
        CashDeskUserCZP.Issue := Rec.Issue;
        CashDeskUserCZP.Post := Rec.Post;
        CashDeskUserCZP."Post EET Only" := Rec."Post EET Only";
        CashDeskUserCZP."User Full Name" := Rec.GetUserName(Rec."User ID");
        CashDeskUserCZP.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk User CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk User", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCashDeskUser(var Rec: Record "Cash Desk User")
    var
        CashDeskUserCZP: Record "Cash Desk User CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk User") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk User CZP");
        CashDeskUserCZP.ChangeCompany(Rec.CurrentCompany);
        if CashDeskUserCZP.Get(Rec."Cash Desk No.", Rec."User ID") then
            CashDeskUserCZP.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk User CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk User CZP", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCashDeskUserCZP(var Rec: Record "Cash Desk User CZP"; var xRec: Record "Cash Desk User CZP")
    var
        CashDeskUser: Record "Cash Desk User";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk User CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk User");
        CashDeskUser.ChangeCompany(Rec.CurrentCompany);
        if CashDeskUser.Get(xRec."Cash Desk No.", xRec."User ID") then
            CashDeskUser.Rename(Rec."Cash Desk No.", Rec."User ID");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk User");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk User CZP", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCashDeskUserCZP(var Rec: Record "Cash Desk User CZP")
    begin
        SyncCashDeskUserCZP(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk User CZP", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCashDeskUserCZP(var Rec: Record "Cash Desk User CZP")
    begin
        SyncCashDeskUserCZP(Rec);
    end;

    local procedure SyncCashDeskUserCZP(var Rec: Record "Cash Desk User CZP")
    var
        CashDeskUser: Record "Cash Desk User";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk User CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk User");
        CashDeskUser.ChangeCompany(Rec.CurrentCompany);
        if not CashDeskUser.Get(Rec."Cash Desk No.", Rec."User ID") then begin
            CashDeskUser.Init();
            CashDeskUser."Cash Desk No." := Rec."Cash Desk No.";
            CashDeskUser."User ID" := Rec."User ID";
            CashDeskUser.SystemId := Rec.SystemId;
            CashDeskUser.Insert(false, true);
        end;
        CashDeskUser.Create := Rec.Create;
        CashDeskUser.Issue := Rec.Issue;
        CashDeskUser.Post := Rec.Post;
        CashDeskUser."Post EET Only" := Rec."Post EET Only";
        CashDeskUser.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk User");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk User CZP", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCashDeskUserCZP(var Rec: Record "Cash Desk User CZP")
    var
        CashDeskUser: Record "Cash Desk User";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Cash Desk User CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Cash Desk User");
        CashDeskUser.ChangeCompany(Rec.CurrentCompany);
        if CashDeskUser.Get(Rec."Cash Desk No.", Rec."User ID") then
            CashDeskUser.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Cash Desk User");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif