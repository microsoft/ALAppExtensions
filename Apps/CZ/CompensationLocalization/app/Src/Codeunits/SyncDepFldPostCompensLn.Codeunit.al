#if not CLEAN18
#pragma warning disable AL0432, AL0603, AA0072
codeunit 31293 "Sync.Dep.Fld-PostCompensLn CZC"
{
    Access = Internal;
    Permissions = tabledata "Posted Credit Line" = rimd,
                  tabledata "Posted Compensation Line CZC" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Posted Credit Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenamePostedCreditLine(var Rec: Record "Posted Credit Line"; var xRec: Record "Posted Credit Line")
    var
        PostedCompensationLineCZC: Record "Posted Compensation Line CZC";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Credit Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Compensation Line CZC");
        PostedCompensationLineCZC.ChangeCompany(Rec.CurrentCompany);
        if PostedCompensationLineCZC.Get(xRec."Credit No.", xRec."Line No.") then
            PostedCompensationLineCZC.Rename(Rec."Credit No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Compensation Line CZC");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Credit Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPostedCreditLine(var Rec: Record "Posted Credit Line")
    begin
        SyncPostedCreditLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Credit Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPostedCreditLine(var Rec: Record "Posted Credit Line")
    begin
        SyncPostedCreditLine(Rec);
    end;

    local procedure SyncPostedCreditLine(var Rec: Record "Posted Credit Line")
    var
        PostedCompensationLineCZC: Record "Posted Compensation Line CZC";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Credit Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Compensation Line CZC");
        PostedCompensationLineCZC.ChangeCompany(Rec.CurrentCompany);
        if not PostedCompensationLineCZC.Get(Rec."Credit No.", Rec."Line No.") then begin
            PostedCompensationLineCZC.Init();
            PostedCompensationLineCZC."Compensation No." := Rec."Credit No.";
            PostedCompensationLineCZC."Line No." := Rec."Line No.";
            PostedCompensationLineCZC.SystemId := Rec.SystemId;
            PostedCompensationLineCZC.Insert(false, true);
        end;
        PostedCompensationLineCZC."Source Type" := Rec."Source Type";
        PostedCompensationLineCZC."Source No." := Rec."Source No.";
        PostedCompensationLineCZC."Posting Group" := Rec."Posting Group";
        PostedCompensationLineCZC."Shortcut Dimension 1 Code" := Rec."Global Dimension 1 Code";
        PostedCompensationLineCZC."Shortcut Dimension 2 Code" := Rec."Global Dimension 2 Code";
        PostedCompensationLineCZC."Source Entry No." := Rec."Source Entry No.";
        PostedCompensationLineCZC."Posting Date" := Rec."Posting Date";
        PostedCompensationLineCZC."Document Type" := Rec."Document Type";
        PostedCompensationLineCZC."Document No." := Rec."Document No.";
        PostedCompensationLineCZC.Description := Rec.Description;
        PostedCompensationLineCZC."Variable Symbol" := Rec."Variable Symbol";
        PostedCompensationLineCZC."Currency Code" := Rec."Currency Code";
        PostedCompensationLineCZC."Currency Factor" := Rec."Currency Factor";
        PostedCompensationLineCZC."Ledg. Entry Original Amount" := Rec."Ledg. Entry Original Amount";
        PostedCompensationLineCZC."Ledg. Entry Remaining Amount" := Rec."Ledg. Entry Remaining Amount";
        PostedCompensationLineCZC.Amount := Rec.Amount;
        PostedCompensationLineCZC."Remaining Amount" := Rec."Remaining Amount";
        PostedCompensationLineCZC."Ledg. Entry Original Amt.(LCY)" := Rec."Ledg. Entry Original Amt.(LCY)";
        PostedCompensationLineCZC."Ledg. Entry Rem. Amt. (LCY)" := Rec."Ledg. Entry Rem. Amt. (LCY)";
        PostedCompensationLineCZC."Amount (LCY)" := Rec."Amount (LCY)";
        PostedCompensationLineCZC."Remaining Amount (LCY)" := Rec."Remaining Amount (LCY)";
        PostedCompensationLineCZC."Dimension Set ID" := Rec."Dimension Set ID";
        PostedCompensationLineCZC.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Compensation Line CZC");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Credit Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeletePostedCreditLine(var Rec: Record "Posted Credit Line")
    var
        PostedCompensationLineCZC: Record "Posted Compensation Line CZC";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Credit Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Compensation Line CZC");
        PostedCompensationLineCZC.ChangeCompany(Rec.CurrentCompany);
        if PostedCompensationLineCZC.Get(Rec."Credit No.", Rec."Line No.") then
            PostedCompensationLineCZC.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Compensation Line CZC");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Compensation Line CZC", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenamePostedCompensationLineCZC(var Rec: Record "Posted Compensation Line CZC"; var xRec: Record "Posted Compensation Line CZC")
    var
        PostedCreditLine: Record "Posted Credit Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Compensation Line CZC") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Credit Line");
        PostedCreditLine.ChangeCompany(Rec.CurrentCompany);
        if PostedCreditLine.Get(xRec."Compensation No.", xRec."Line No.") then
            PostedCreditLine.Rename(Rec."Compensation No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Credit Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Compensation Line CZC", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPostedCompensationLineCZC(var Rec: Record "Posted Compensation Line CZC")
    begin
        SyncPostedCompensationLineCZC(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Compensation Line CZC", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPostedCompensationLineCZC(var Rec: Record "Posted Compensation Line CZC")
    begin
        SyncPostedCompensationLineCZC(Rec);
    end;

    local procedure SyncPostedCompensationLineCZC(var Rec: Record "Posted Compensation Line CZC")
    var
        PostedCreditLine: Record "Posted Credit Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Compensation Line CZC") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Credit Line");
        PostedCreditLine.ChangeCompany(Rec.CurrentCompany);
        if not PostedCreditLine.Get(Rec."Compensation No.", Rec."Line No.") then begin
            PostedCreditLine.Init();
            PostedCreditLine."Credit No." := Rec."Compensation No.";
            PostedCreditLine."Line No." := Rec."Line No.";
            PostedCreditLine.SystemId := Rec.SystemId;
            PostedCreditLine.Insert(false, true);
        end;
        PostedCreditLine."Source Type" := Rec."Source Type";
        PostedCreditLine."Source No." := Rec."Source No.";
        PostedCreditLine."Posting Group" := Rec."Posting Group";
        PostedCreditLine."Global Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
        PostedCreditLine."Global Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
        PostedCreditLine."Source Entry No." := Rec."Source Entry No.";
        PostedCreditLine."Posting Date" := Rec."Posting Date";
        PostedCreditLine."Document Type" := Rec."Document Type";
        PostedCreditLine."Document No." := Rec."Document No.";
        PostedCreditLine.Description := Rec.Description;
        PostedCreditLine."Variable Symbol" := Rec."Variable Symbol";
        PostedCreditLine."Currency Code" := Rec."Currency Code";
        PostedCreditLine."Currency Factor" := Rec."Currency Factor";
        PostedCreditLine."Ledg. Entry Original Amount" := Rec."Ledg. Entry Original Amount";
        PostedCreditLine."Ledg. Entry Remaining Amount" := Rec."Ledg. Entry Remaining Amount";
        PostedCreditLine.Amount := Rec.Amount;
        PostedCreditLine."Remaining Amount" := Rec."Remaining Amount";
        PostedCreditLine."Ledg. Entry Original Amt.(LCY)" := Rec."Ledg. Entry Original Amt.(LCY)";
        PostedCreditLine."Ledg. Entry Rem. Amt. (LCY)" := Rec."Ledg. Entry Rem. Amt. (LCY)";
        PostedCreditLine."Amount (LCY)" := Rec."Amount (LCY)";
        PostedCreditLine."Remaining Amount (LCY)" := Rec."Remaining Amount (LCY)";
        PostedCreditLine."Dimension Set ID" := Rec."Dimension Set ID";
        PostedCreditLine.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Credit Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Compensation Line CZC", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeletePostedCompensationLineCZC(var Rec: Record "Posted Compensation Line CZC")
    var
        PostedCreditLine: Record "Posted Credit Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Compensation Line CZC") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Credit Line");
        PostedCreditLine.ChangeCompany(Rec.CurrentCompany);
        if PostedCreditLine.Get(Rec."Compensation No.", Rec."Line No.") then
            PostedCreditLine.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Credit Line");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif