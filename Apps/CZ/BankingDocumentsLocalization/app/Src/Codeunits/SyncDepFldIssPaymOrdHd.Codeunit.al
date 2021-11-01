#if not CLEAN19
#pragma warning disable AL0432
codeunit 31341 "Sync.Dep.Fld-IssPaymOrdHd CZB"
{
    Access = Internal;
    Permissions = tabledata "Issued Payment Order Header" = rimd,
                  tabledata "Iss. Payment Order Header CZB" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Issued Payment Order Header", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIssuedPaymentOrderHeader(var Rec: Record "Issued Payment Order Header"; var xRec: Record "Issued Payment Order Header")
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Payment Order Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Payment Order Header CZB");
        IssPaymentOrderHeaderCZB.ChangeCompany(Rec.CurrentCompany);
        if IssPaymentOrderHeaderCZB.Get(xRec."No.") then
            IssPaymentOrderHeaderCZB.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Payment Order Header CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Payment Order Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIssuedPaymentOrderHeader(var Rec: Record "Issued Payment Order Header")
    begin
        SyncIssuedPaymentOrderHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Payment Order Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIssuedPaymentOrderHeader(var Rec: Record "Issued Payment Order Header")
    begin
        SyncIssuedPaymentOrderHeader(Rec);
    end;

    local procedure SyncIssuedPaymentOrderHeader(var IssuedPaymentOrderHeader: Record "Issued Payment Order Header")
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if IssuedPaymentOrderHeader.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Payment Order Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Payment Order Header CZB");
        IssPaymentOrderHeaderCZB.ChangeCompany(IssuedPaymentOrderHeader.CurrentCompany);
        if not IssPaymentOrderHeaderCZB.Get(IssuedPaymentOrderHeader."No.") then begin
            IssPaymentOrderHeaderCZB.Init();
            IssPaymentOrderHeaderCZB."No." := IssuedPaymentOrderHeader."No.";
            IssPaymentOrderHeaderCZB.SystemId := IssuedPaymentOrderHeader.SystemId;
            IssPaymentOrderHeaderCZB.Insert(false, true);
        end;
        IssPaymentOrderHeaderCZB."No. Series" := IssuedPaymentOrderHeader."No. Series";
        IssPaymentOrderHeaderCZB."Bank Account No." := IssuedPaymentOrderHeader."Bank Account No.";
        IssPaymentOrderHeaderCZB."Account No." := IssuedPaymentOrderHeader."Account No.";
        IssPaymentOrderHeaderCZB."Document Date" := IssuedPaymentOrderHeader."Document Date";
        IssPaymentOrderHeaderCZB."Currency Code" := IssuedPaymentOrderHeader."Currency Code";
        IssPaymentOrderHeaderCZB."Currency Factor" := IssuedPaymentOrderHeader."Currency Factor";
        IssPaymentOrderHeaderCZB."Payment Order Currency Code" := IssuedPaymentOrderHeader."Payment Order Currency Code";
        IssPaymentOrderHeaderCZB."Payment Order Currency Factor" := IssuedPaymentOrderHeader."Payment Order Currency Factor";
        IssPaymentOrderHeaderCZB."Pre-Assigned No. Series" := IssuedPaymentOrderHeader."Pre-Assigned No. Series";
        IssPaymentOrderHeaderCZB."Pre-Assigned No." := IssuedPaymentOrderHeader."Pre-Assigned No.";
        IssPaymentOrderHeaderCZB."Pre-Assigned User ID" := IssuedPaymentOrderHeader."Pre-Assigned User ID";
        IssPaymentOrderHeaderCZB."External Document No." := IssuedPaymentOrderHeader."External Document No.";
        IssPaymentOrderHeaderCZB."No. Exported" := IssuedPaymentOrderHeader."No. Exported";
        IssPaymentOrderHeaderCZB."File Name" := IssuedPaymentOrderHeader."File Name";
        IssPaymentOrderHeaderCZB."Foreign Payment Order" := IssuedPaymentOrderHeader."Foreign Payment Order";
        IssPaymentOrderHeaderCZB.IBAN := IssuedPaymentOrderHeader.IBAN;
        IssPaymentOrderHeaderCZB."SWIFT Code" := IssuedPaymentOrderHeader."SWIFT Code";
        IssPaymentOrderHeaderCZB."Unreliable Pay. Check DateTime" := IssuedPaymentOrderHeader."Uncertainty Pay.Check DateTime";
        IssPaymentOrderHeaderCZB.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Payment Order Header CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Payment Order Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIssuedPaymentOrderHeader(var Rec: Record "Issued Payment Order Header")
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Payment Order Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Payment Order Header CZB");
        IssPaymentOrderHeaderCZB.ChangeCompany(Rec.CurrentCompany);
        if IssPaymentOrderHeaderCZB.Get(Rec."No.") then
            IssPaymentOrderHeaderCZB.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Payment Order Header CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Payment Order Header CZB", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIssPaymentOrderHeaderCZB(var Rec: Record "Iss. Payment Order Header CZB"; var xRec: Record "Iss. Payment Order Header CZB")
    var
        IssuedPaymentOrderHeader: Record "Issued Payment Order Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Payment Order Header CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Payment Order Header");
        IssuedPaymentOrderHeader.ChangeCompany(Rec.CurrentCompany);
        if IssuedPaymentOrderHeader.Get(xRec."No.") then
            IssuedPaymentOrderHeader.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Payment Order Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Payment Order Header CZB", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIssPaymentOrderHeaderCZB(var Rec: Record "Iss. Payment Order Header CZB")
    begin
        SyncIssPaymentOrderHeaderCZB(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Payment Order Header CZB", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIssPaymentOrderHeaderCZB(var Rec: Record "Iss. Payment Order Header CZB")
    begin
        SyncIssPaymentOrderHeaderCZB(Rec);
    end;

    local procedure SyncIssPaymentOrderHeaderCZB(var IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB")
    var
        IssuedPaymentOrderHeader: Record "Issued Payment Order Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if IssPaymentOrderHeaderCZB.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Payment Order Header CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Payment Order Header");
        IssuedPaymentOrderHeader.ChangeCompany(IssPaymentOrderHeaderCZB.CurrentCompany);
        if not IssuedPaymentOrderHeader.Get(IssPaymentOrderHeaderCZB."No.") then begin
            IssuedPaymentOrderHeader.Init();
            IssuedPaymentOrderHeader."No." := IssPaymentOrderHeaderCZB."No.";
            IssuedPaymentOrderHeader.SystemId := IssPaymentOrderHeaderCZB.SystemId;
            IssuedPaymentOrderHeader.Insert(false, true);
        end;
        IssuedPaymentOrderHeader."No. Series" := IssPaymentOrderHeaderCZB."No. Series";
        IssuedPaymentOrderHeader."Bank Account No." := IssPaymentOrderHeaderCZB."Bank Account No.";
        IssuedPaymentOrderHeader."Account No." := IssPaymentOrderHeaderCZB."Account No.";
        IssuedPaymentOrderHeader."Document Date" := IssPaymentOrderHeaderCZB."Document Date";
        IssuedPaymentOrderHeader."Currency Code" := IssPaymentOrderHeaderCZB."Currency Code";
        IssuedPaymentOrderHeader."Currency Factor" := IssPaymentOrderHeaderCZB."Currency Factor";
        IssuedPaymentOrderHeader."Payment Order Currency Code" := IssPaymentOrderHeaderCZB."Payment Order Currency Code";
        IssuedPaymentOrderHeader."Payment Order Currency Factor" := IssPaymentOrderHeaderCZB."Payment Order Currency Factor";
        IssuedPaymentOrderHeader."Pre-Assigned No. Series" := IssPaymentOrderHeaderCZB."Pre-Assigned No. Series";
        IssuedPaymentOrderHeader."Pre-Assigned No." := IssPaymentOrderHeaderCZB."Pre-Assigned No.";
        IssuedPaymentOrderHeader."Pre-Assigned User ID" := IssPaymentOrderHeaderCZB."Pre-Assigned User ID";
        IssuedPaymentOrderHeader."External Document No." := IssPaymentOrderHeaderCZB."External Document No.";
        IssuedPaymentOrderHeader."No. Exported" := IssPaymentOrderHeaderCZB."No. Exported";
        IssuedPaymentOrderHeader."File Name" := IssPaymentOrderHeaderCZB."File Name";
        IssuedPaymentOrderHeader."Foreign Payment Order" := IssPaymentOrderHeaderCZB."Foreign Payment Order";
        IssuedPaymentOrderHeader.IBAN := IssPaymentOrderHeaderCZB.IBAN;
        IssuedPaymentOrderHeader."SWIFT Code" := IssPaymentOrderHeaderCZB."SWIFT Code";
        IssuedPaymentOrderHeader."Uncertainty Pay.Check DateTime" := IssPaymentOrderHeaderCZB."Unreliable Pay. Check DateTime";
        IssuedPaymentOrderHeader.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Payment Order Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Payment Order Header CZB", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIssPaymentOrderHeaderCZB(var Rec: Record "Iss. Payment Order Header CZB")
    var
        IssuedPaymentOrderHeader: Record "Issued Payment Order Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Payment Order Header CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Payment Order Header");
        IssuedPaymentOrderHeader.ChangeCompany(Rec.CurrentCompany);
        if IssuedPaymentOrderHeader.Get(Rec."No.") then
            IssuedPaymentOrderHeader.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Payment Order Header");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif