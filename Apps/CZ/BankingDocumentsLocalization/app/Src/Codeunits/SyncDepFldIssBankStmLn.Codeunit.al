#if not CLEAN19
#pragma warning disable AL0432,AL0603
codeunit 31344 "Sync.Dep.Fld-IssBankStmLn CZB"
{
    Access = Internal;
    Permissions = tabledata "Issued Bank Statement Line" = rimd,
                  tabledata "Iss. Bank Statement Line CZB" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Issued Bank Statement Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIssuedBankStatementLine(var Rec: Record "Issued Bank Statement Line"; var xRec: Record "Issued Bank Statement Line")
    var
        IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Bank Statement Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Bank Statement Line CZB");
        IssBankStatementLineCZB.ChangeCompany(Rec.CurrentCompany);
        if IssBankStatementLineCZB.Get(xRec."Bank Statement No.", xRec."Line No.") then
            IssBankStatementLineCZB.Rename(Rec."Bank Statement No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Bank Statement Line CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Bank Statement Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIssuedBankStatementLine(var Rec: Record "Issued Bank Statement Line")
    begin
        SyncIssuedBankStatementLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Bank Statement Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIssuedBankStatementLine(var Rec: Record "Issued Bank Statement Line")
    begin
        SyncIssuedBankStatementLine(Rec);
    end;

    local procedure SyncIssuedBankStatementLine(var IssuedBankStatementLine: Record "Issued Bank Statement Line")
    var
        IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if IssuedBankStatementLine.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Bank Statement Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Bank Statement Line CZB");
        IssBankStatementLineCZB.ChangeCompany(IssuedBankStatementLine.CurrentCompany);
        if not IssBankStatementLineCZB.Get(IssuedBankStatementLine."Bank Statement No.", IssuedBankStatementLine."Line No.") then begin
            IssBankStatementLineCZB.Init();
            IssBankStatementLineCZB."Bank Statement No." := IssuedBankStatementLine."Bank Statement No.";
            IssBankStatementLineCZB."Line No." := IssuedBankStatementLine."Line No.";
            IssBankStatementLineCZB.SystemId := IssuedBankStatementLine.SystemId;
            IssBankStatementLineCZB.Insert(false, true);
        end;
        IssBankStatementLineCZB.Type := IssuedBankStatementLine.Type;
        IssBankStatementLineCZB."No." := IssuedBankStatementLine."No.";
        IssBankStatementLineCZB."Cust./Vendor Bank Account Code" := IssuedBankStatementLine."Cust./Vendor Bank Account Code";
        IssBankStatementLineCZB.Description := IssuedBankStatementLine.Description;
        IssBankStatementLineCZB."Account No." := IssuedBankStatementLine."Account No.";
        IssBankStatementLineCZB."Variable Symbol" := IssuedBankStatementLine."Variable Symbol";
        IssBankStatementLineCZB."Constant Symbol" := IssuedBankStatementLine."Constant Symbol";
        IssBankStatementLineCZB."Specific Symbol" := IssuedBankStatementLine."Specific Symbol";
        IssBankStatementLineCZB.Amount := IssuedBankStatementLine.Amount;
        IssBankStatementLineCZB."Amount (LCY)" := IssuedBankStatementLine."Amount (LCY)";
        IssBankStatementLineCZB.Positive := IssuedBankStatementLine.Positive;
        IssBankStatementLineCZB."Transit No." := IssuedBankStatementLine."Transit No.";
        IssBankStatementLineCZB."Currency Code" := IssuedBankStatementLine."Currency Code";
        IssBankStatementLineCZB."Bank Statement Currency Code" := IssuedBankStatementLine."Bank Statement Currency Code";
        IssBankStatementLineCZB."Amount (Bank Stat. Currency)" := IssuedBankStatementLine."Amount (Bank Stat. Currency)";
        IssBankStatementLineCZB."Bank Statement Currency Factor" := IssuedBankStatementLine."Bank Statement Currency Factor";
        IssBankStatementLineCZB.IBAN := IssuedBankStatementLine.IBAN;
        IssBankStatementLineCZB."SWIFT Code" := IssuedBankStatementLine."SWIFT Code";
        IssBankStatementLineCZB.Name := IssuedBankStatementLine.Name;
        IssBankStatementLineCZB.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Bank Statement Line CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Bank Statement Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIssuedBankStatementLine(var Rec: Record "Issued Bank Statement Line")
    var
        IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Bank Statement Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Bank Statement Line CZB");
        IssBankStatementLineCZB.ChangeCompany(Rec.CurrentCompany);
        if IssBankStatementLineCZB.Get(Rec."Bank Statement No.", Rec."Line No.") then
            IssBankStatementLineCZB.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Bank Statement Line CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Bank Statement Line CZB", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIssBankStatementLineCZB(var Rec: Record "Iss. Bank Statement Line CZB"; var xRec: Record "Iss. Bank Statement Line CZB")
    var
        IssuedBankStatementLine: Record "Issued Bank Statement Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Bank Statement Line CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Bank Statement Line");
        IssuedBankStatementLine.ChangeCompany(Rec.CurrentCompany);
        if IssuedBankStatementLine.Get(xRec."Bank Statement No.", xRec."Line No.") then
            IssuedBankStatementLine.Rename(Rec."Bank Statement No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Bank Statement Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Bank Statement Line CZB", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIssBankStatementLineCZB(var Rec: Record "Iss. Bank Statement Line CZB")
    begin
        SyncIssBankStatementLineCZB(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Bank Statement Line CZB", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIssBankStatementLineCZB(var Rec: Record "Iss. Bank Statement Line CZB")
    begin
        SyncIssBankStatementLineCZB(Rec);
    end;

    local procedure SyncIssBankStatementLineCZB(var IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB")
    var
        IssuedBankStatementLine: Record "Issued Bank Statement Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if IssBankStatementLineCZB.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Bank Statement Line CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Bank Statement Line");
        IssuedBankStatementLine.ChangeCompany(IssBankStatementLineCZB.CurrentCompany);
        if not IssuedBankStatementLine.Get(IssBankStatementLineCZB."Bank Statement No.", IssBankStatementLineCZB."Line No.") then begin
            IssuedBankStatementLine.Init();
            IssuedBankStatementLine."Bank Statement No." := IssBankStatementLineCZB."Bank Statement No.";
            IssuedBankStatementLine."Line No." := IssBankStatementLineCZB."Line No.";
            IssuedBankStatementLine.SystemId := IssBankStatementLineCZB.SystemId;
            IssuedBankStatementLine.Insert(false, true);
        end;
        IssuedBankStatementLine.Type := IssBankStatementLineCZB.Type.AsInteger();
        IssuedBankStatementLine."No." := IssBankStatementLineCZB."No.";
        IssuedBankStatementLine."Cust./Vendor Bank Account Code" := IssBankStatementLineCZB."Cust./Vendor Bank Account Code";
        IssuedBankStatementLine.Description := IssBankStatementLineCZB.Description;
        IssuedBankStatementLine."Account No." := IssBankStatementLineCZB."Account No.";
        IssuedBankStatementLine."Variable Symbol" := IssBankStatementLineCZB."Variable Symbol";
        IssuedBankStatementLine."Constant Symbol" := IssBankStatementLineCZB."Constant Symbol";
        IssuedBankStatementLine."Specific Symbol" := IssBankStatementLineCZB."Specific Symbol";
        IssuedBankStatementLine.Amount := IssBankStatementLineCZB.Amount;
        IssuedBankStatementLine."Amount (LCY)" := IssBankStatementLineCZB."Amount (LCY)";
        IssuedBankStatementLine.Positive := IssBankStatementLineCZB.Positive;
        IssuedBankStatementLine."Transit No." := IssBankStatementLineCZB."Transit No.";
        IssuedBankStatementLine."Currency Code" := IssBankStatementLineCZB."Currency Code";
        IssuedBankStatementLine."Bank Statement Currency Code" := IssBankStatementLineCZB."Bank Statement Currency Code";
        IssuedBankStatementLine."Amount (Bank Stat. Currency)" := IssBankStatementLineCZB."Amount (Bank Stat. Currency)";
        IssuedBankStatementLine."Bank Statement Currency Factor" := IssBankStatementLineCZB."Bank Statement Currency Factor";
        IssuedBankStatementLine.IBAN := IssBankStatementLineCZB.IBAN;
        IssuedBankStatementLine."SWIFT Code" := IssBankStatementLineCZB."SWIFT Code";
        IssuedBankStatementLine.Name := IssBankStatementLineCZB.Name;
        IssuedBankStatementLine.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Bank Statement Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Bank Statement Line CZB", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIssBankStatementLineCZB(var Rec: Record "Iss. Bank Statement Line CZB")
    var
        IssuedBankStatementLine: Record "Issued Bank Statement Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Bank Statement Line CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Bank Statement Line");
        IssuedBankStatementLine.ChangeCompany(Rec.CurrentCompany);
        if IssuedBankStatementLine.Get(Rec."Bank Statement No.", Rec."Line No.") then
            IssuedBankStatementLine.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Bank Statement Line");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif