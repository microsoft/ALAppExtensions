#if not CLEAN19
#pragma warning disable AL0432
codeunit 31391 "Sync.Dep.Fld-IssPaymOrdLn CZZ"
{
    Access = Internal;
    Permissions = tabledata "Issued Payment Order Line" = rimd,
                  tabledata "Iss. Payment Order Line CZB" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Issued Payment Order Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIssuedPaymentOrderLine(var Rec: Record "Issued Payment Order Line")
    begin
        SyncIssuedPaymentOrderLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Payment Order Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIssuedPaymentOrderLine(var Rec: Record "Issued Payment Order Line")
    begin
        SyncIssuedPaymentOrderLine(Rec);
    end;

    local procedure SyncIssuedPaymentOrderLine(var IssuedPaymentOrderLine: Record "Issued Payment Order Line")
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if IssuedPaymentOrderLine.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Payment Order Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Payment Order Line CZB");
        IssPaymentOrderLineCZB.ChangeCompany(IssuedPaymentOrderLine.CurrentCompany);
        if not IssPaymentOrderLineCZB.Get(IssuedPaymentOrderLine."Payment Order No.", IssuedPaymentOrderLine."Line No.") then begin
            IssPaymentOrderLineCZB.Init();
            IssPaymentOrderLineCZB."Payment Order No." := IssuedPaymentOrderLine."Payment Order No.";
            IssPaymentOrderLineCZB."Line No." := IssuedPaymentOrderLine."Line No.";
            IssPaymentOrderLineCZB.Insert(false);
        end;
        IssPaymentOrderLineCZB."Purch. Advance Letter No. CZZ" := IssuedPaymentOrderLine."Letter No.";
        IssPaymentOrderLineCZB.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Payment Order Line CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Payment Order Line CZB", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIssPaymentOrderLineCZB(var Rec: Record "Iss. Payment Order Line CZB")
    begin
        SyncIssPaymentOrderLineCZB(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Payment Order Line CZB", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIssPaymentOrderLineCZB(var Rec: Record "Iss. Payment Order Line CZB")
    begin
        SyncIssPaymentOrderLineCZB(Rec);
    end;

    local procedure SyncIssPaymentOrderLineCZB(var IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB")
    var
        IssuedPaymentOrderLine: Record "Issued Payment Order Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if IssPaymentOrderLineCZB.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Payment Order Line CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Payment Order Line");
        IssuedPaymentOrderLine.ChangeCompany(IssPaymentOrderLineCZB.CurrentCompany);
        if not IssuedPaymentOrderLine.Get(IssPaymentOrderLineCZB."Payment Order No.", IssPaymentOrderLineCZB."Line No.") then begin
            IssuedPaymentOrderLine.Init();
            IssuedPaymentOrderLine."Payment Order No." := IssPaymentOrderLineCZB."Payment Order No.";
            IssuedPaymentOrderLine."Line No." := IssPaymentOrderLineCZB."Line No.";
            IssuedPaymentOrderLine.Insert(false);
        end;
        IssuedPaymentOrderLine."Letter No." := IssPaymentOrderLineCZB."Purch. Advance Letter No. CZZ";
        IssuedPaymentOrderLine.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Payment Order Line");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif