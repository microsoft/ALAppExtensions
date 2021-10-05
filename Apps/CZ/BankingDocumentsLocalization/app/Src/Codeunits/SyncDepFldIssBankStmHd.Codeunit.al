#if not CLEAN19
#pragma warning disable AL0432,AL0603
codeunit 31343 "Sync.Dep.Fld-IssBankStmHd CZB"
{
    Access = Internal;
    Permissions = tabledata "Issued Bank Statement Header" = rimd,
                  tabledata "Iss. Bank Statement Header CZB" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Issued Bank Statement Header", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIssuedBankStatementHeader(var Rec: Record "Issued Bank Statement Header"; var xRec: Record "Issued Bank Statement Header")
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Bank Statement Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Bank Statement Header CZB");
        IssBankStatementHeaderCZB.ChangeCompany(Rec.CurrentCompany);
        if IssBankStatementHeaderCZB.Get(xRec."No.") then
            IssBankStatementHeaderCZB.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Bank Statement Header CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Bank Statement Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIssuedBankStatementHeader(var Rec: Record "Issued Bank Statement Header")
    begin
        SyncIssuedBankStatementHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Bank Statement Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIssuedBankStatementHeader(var Rec: Record "Issued Bank Statement Header")
    begin
        SyncIssuedBankStatementHeader(Rec);
    end;

    local procedure SyncIssuedBankStatementHeader(var IssuedBankStatementHeader: Record "Issued Bank Statement Header")
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if IssuedBankStatementHeader.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Bank Statement Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Bank Statement Header CZB");
        IssBankStatementHeaderCZB.ChangeCompany(IssuedBankStatementHeader.CurrentCompany);
        if not IssBankStatementHeaderCZB.Get(IssuedBankStatementHeader."No.") then begin
            IssBankStatementHeaderCZB.Init();
            IssBankStatementHeaderCZB."No." := IssuedBankStatementHeader."No.";
            IssBankStatementHeaderCZB.SystemId := IssuedBankStatementHeader.SystemId;
            IssBankStatementHeaderCZB.Insert(false, true);
        end;
        IssBankStatementHeaderCZB."No. Series" := IssuedBankStatementHeader."No. Series";
        IssBankStatementHeaderCZB."Bank Account No." := IssuedBankStatementHeader."Bank Account No.";
        IssBankStatementHeaderCZB."Account No." := IssuedBankStatementHeader."Account No.";
        IssBankStatementHeaderCZB."Document Date" := IssuedBankStatementHeader."Document Date";
        IssBankStatementHeaderCZB."Currency Code" := IssuedBankStatementHeader."Currency Code";
        IssBankStatementHeaderCZB."Currency Factor" := IssuedBankStatementHeader."Currency Factor";
        IssBankStatementHeaderCZB."Bank Statement Currency Code" := IssuedBankStatementHeader."Bank Statement Currency Code";
        IssBankStatementHeaderCZB."Bank Statement Currency Factor" := IssuedBankStatementHeader."Bank Statement Currency Factor";
        IssBankStatementHeaderCZB."Pre-Assigned No. Series" := IssuedBankStatementHeader."Pre-Assigned No. Series";
        IssBankStatementHeaderCZB."Pre-Assigned No." := IssuedBankStatementHeader."Pre-Assigned No.";
        IssBankStatementHeaderCZB."Pre-Assigned User ID" := IssuedBankStatementHeader."Pre-Assigned User ID";
        IssBankStatementHeaderCZB."External Document No." := IssuedBankStatementHeader."External Document No.";
        IssBankStatementHeaderCZB."File Name" := IssuedBankStatementHeader."File Name";
        IssBankStatementHeaderCZB."Check Amount" := IssuedBankStatementHeader."Check Amount";
        IssBankStatementHeaderCZB."Check Amount (LCY)" := IssuedBankStatementHeader."Check Amount (LCY)";
        IssBankStatementHeaderCZB."Check Debit" := IssuedBankStatementHeader."Check Debit";
        IssBankStatementHeaderCZB."Check Debit (LCY)" := IssuedBankStatementHeader."Check Debit (LCY)";
        IssBankStatementHeaderCZB."Check Credit" := IssuedBankStatementHeader."Check Credit";
        IssBankStatementHeaderCZB."Check Credit (LCY)" := IssuedBankStatementHeader."Check Credit (LCY)";
        IssBankStatementHeaderCZB.IBAN := IssuedBankStatementHeader.IBAN;
        IssBankStatementHeaderCZB."SWIFT Code" := IssuedBankStatementHeader."SWIFT Code";
        IssBankStatementHeaderCZB."Payment Reconciliation Status" := IssuedBankStatementHeader."Payment Reconciliation Status";
        IssBankStatementHeaderCZB.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Bank Statement Header CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Bank Statement Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIssuedBankStatementHeader(var Rec: Record "Issued Bank Statement Header")
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Bank Statement Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Bank Statement Header CZB");
        IssBankStatementHeaderCZB.ChangeCompany(Rec.CurrentCompany);
        if IssBankStatementHeaderCZB.Get(Rec."No.") then
            IssBankStatementHeaderCZB.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Bank Statement Header CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Bank Statement Header CZB", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIssBankStatementHeaderCZB(var Rec: Record "Iss. Bank Statement Header CZB"; var xRec: Record "Iss. Bank Statement Header CZB")
    var
        IssuedBankStatementHeader: Record "Issued Bank Statement Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Bank Statement Header CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Bank Statement Header");
        IssuedBankStatementHeader.ChangeCompany(Rec.CurrentCompany);
        if IssuedBankStatementHeader.Get(xRec."No.") then
            IssuedBankStatementHeader.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Bank Statement Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Bank Statement Header CZB", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIssBankStatementHeaderCZB(var Rec: Record "Iss. Bank Statement Header CZB")
    begin
        SyncIssBankStatementHeaderCZB(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Bank Statement Header CZB", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIssBankStatementHeaderCZB(var Rec: Record "Iss. Bank Statement Header CZB")
    begin
        SyncIssBankStatementHeaderCZB(Rec);
    end;

    local procedure SyncIssBankStatementHeaderCZB(var IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB")
    var
        IssuedBankStatementHeader: Record "Issued Bank Statement Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if IssBankStatementHeaderCZB.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Bank Statement Header CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Bank Statement Header");
        IssuedBankStatementHeader.ChangeCompany(IssBankStatementHeaderCZB.CurrentCompany);
        if not IssuedBankStatementHeader.Get(IssBankStatementHeaderCZB."No.") then begin
            IssuedBankStatementHeader.Init();
            IssuedBankStatementHeader."No." := IssBankStatementHeaderCZB."No.";
            IssuedBankStatementHeader.SystemId := IssBankStatementHeaderCZB.SystemId;
            IssuedBankStatementHeader.Insert(false, true);
        end;
        IssuedBankStatementHeader."No. Series" := IssBankStatementHeaderCZB."No. Series";
        IssuedBankStatementHeader."Bank Account No." := IssBankStatementHeaderCZB."Bank Account No.";
        IssuedBankStatementHeader."Account No." := IssBankStatementHeaderCZB."Account No.";
        IssuedBankStatementHeader."Document Date" := IssBankStatementHeaderCZB."Document Date";
        IssuedBankStatementHeader."Currency Code" := IssBankStatementHeaderCZB."Currency Code";
        IssuedBankStatementHeader."Currency Factor" := IssBankStatementHeaderCZB."Currency Factor";
        IssuedBankStatementHeader."Bank Statement Currency Code" := IssBankStatementHeaderCZB."Bank Statement Currency Code";
        IssuedBankStatementHeader."Bank Statement Currency Factor" := IssBankStatementHeaderCZB."Bank Statement Currency Factor";
        IssuedBankStatementHeader."Pre-Assigned No. Series" := IssBankStatementHeaderCZB."Pre-Assigned No. Series";
        IssuedBankStatementHeader."Pre-Assigned No." := IssBankStatementHeaderCZB."Pre-Assigned No.";
        IssuedBankStatementHeader."Pre-Assigned User ID" := IssBankStatementHeaderCZB."Pre-Assigned User ID";
        IssuedBankStatementHeader."External Document No." := IssBankStatementHeaderCZB."External Document No.";
        IssuedBankStatementHeader."File Name" := IssBankStatementHeaderCZB."File Name";
        IssuedBankStatementHeader."Check Amount" := IssBankStatementHeaderCZB."Check Amount";
        IssuedBankStatementHeader."Check Amount (LCY)" := IssBankStatementHeaderCZB."Check Amount (LCY)";
        IssuedBankStatementHeader."Check Debit" := IssBankStatementHeaderCZB."Check Debit";
        IssuedBankStatementHeader."Check Debit (LCY)" := IssBankStatementHeaderCZB."Check Debit (LCY)";
        IssuedBankStatementHeader."Check Credit" := IssBankStatementHeaderCZB."Check Credit";
        IssuedBankStatementHeader."Check Credit (LCY)" := IssBankStatementHeaderCZB."Check Credit (LCY)";
        IssuedBankStatementHeader.IBAN := IssBankStatementHeaderCZB.IBAN;
        IssuedBankStatementHeader."SWIFT Code" := IssBankStatementHeaderCZB."SWIFT Code";
        IssuedBankStatementHeader."Payment Reconciliation Status" := IssBankStatementHeaderCZB."Payment Reconciliation Status";
        IssuedBankStatementHeader.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Bank Statement Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Bank Statement Header CZB", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIssBankStatementHeaderCZB(var Rec: Record "Iss. Bank Statement Header CZB")
    var
        IssuedBankStatementHeader: Record "Issued Bank Statement Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Bank Statement Header CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Bank Statement Header");
        IssuedBankStatementHeader.ChangeCompany(Rec.CurrentCompany);
        if IssuedBankStatementHeader.Get(Rec."No.") then
            IssuedBankStatementHeader.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Bank Statement Header");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif