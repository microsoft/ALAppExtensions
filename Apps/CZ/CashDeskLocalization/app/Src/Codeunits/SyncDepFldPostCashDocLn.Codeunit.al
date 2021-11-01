#if not CLEAN17
#pragma warning disable AL0432,AL0603
codeunit 31134 "Sync.Dep.Fld-PostCashDocLn CZP"
{
    Permissions = tabledata "Posted Cash Document Line" = rimd,
                  tabledata "Posted Cash Document Line CZP" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.5';

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenamePostedCashDocumentLine(var Rec: Record "Posted Cash Document Line"; var xRec: Record "Posted Cash Document Line")
    var
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Line CZP");
        PostedCashDocumentLineCZP.ChangeCompany(Rec.CurrentCompany);
        if PostedCashDocumentLineCZP.Get(xRec."Cash Desk No.", xRec."Cash Document No.", xRec."Line No.") then
            PostedCashDocumentLineCZP.Rename(Rec."Cash Desk No.", Rec."Cash Document No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Line CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPostedCashDocumentLine(var Rec: Record "Posted Cash Document Line")
    begin
        SyncPostedCashDocumentLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPostedCashDocumentLine(var Rec: Record "Posted Cash Document Line")
    begin
        SyncPostedCashDocumentLine(Rec);
    end;

    local procedure SyncPostedCashDocumentLine(var Rec: Record "Posted Cash Document Line")
    var
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Line CZP");
        PostedCashDocumentLineCZP.ChangeCompany(Rec.CurrentCompany);
        if not PostedCashDocumentLineCZP.Get(Rec."Cash Desk No.", Rec."Cash Document No.", Rec."Line No.") then begin
            PostedCashDocumentLineCZP.Init();
            PostedCashDocumentLineCZP."Cash Desk No." := Rec."Cash Desk No.";
            PostedCashDocumentLineCZP."Cash Document No." := Rec."Cash Document No.";
            PostedCashDocumentLineCZP."Line No." := Rec."Line No.";
            PostedCashDocumentLineCZP.SystemId := Rec.SystemId;
            PostedCashDocumentLineCZP.Insert(false, true);
        end;
        PostedCashDocumentLineCZP."Gen. Document Type" := Rec."Document Type";
        PostedCashDocumentLineCZP."Account Type" := Rec."Account Type";
        PostedCashDocumentLineCZP."Account No." := Rec."Account No.";
        PostedCashDocumentLineCZP."External Document No." := Rec."External Document No.";
        PostedCashDocumentLineCZP."Posting Group" := Rec."Posting Group";
        PostedCashDocumentLineCZP.Description := Rec.Description;
        PostedCashDocumentLineCZP.Amount := Rec.Amount;
        PostedCashDocumentLineCZP."Amount (LCY)" := Rec."Amount (LCY)";
        PostedCashDocumentLineCZP."Description 2" := Rec."Description 2";
        PostedCashDocumentLineCZP."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
        PostedCashDocumentLineCZP."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
        PostedCashDocumentLineCZP."Document Type" := Rec."Cash Document Type";
        PostedCashDocumentLineCZP."Currency Code" := Rec."Currency Code";
        PostedCashDocumentLineCZP."Cash Desk Event" := Rec."Cash Desk Event";
        PostedCashDocumentLineCZP."Salespers./Purch. Code" := Rec."Salespers./Purch. Code";
        PostedCashDocumentLineCZP."Reason Code" := Rec."Reason Code";
        PostedCashDocumentLineCZP."VAT Base Amount" := Rec."VAT Base Amount";
        PostedCashDocumentLineCZP."Amount Including VAT" := Rec."Amount Including VAT";
        PostedCashDocumentLineCZP."VAT Amount" := Rec."VAT Amount";
        PostedCashDocumentLineCZP."VAT Base Amount (LCY)" := Rec."VAT Base Amount (LCY)";
        PostedCashDocumentLineCZP."Amount Including VAT (LCY)" := Rec."Amount Including VAT (LCY)";
        PostedCashDocumentLineCZP."VAT Amount (LCY)" := Rec."VAT Amount (LCY)";
        PostedCashDocumentLineCZP."VAT Difference" := Rec."VAT Difference";
        PostedCashDocumentLineCZP."VAT %" := Rec."VAT %";
        PostedCashDocumentLineCZP."VAT Identifier" := Rec."VAT Identifier";
        PostedCashDocumentLineCZP."VAT Difference (LCY)" := Rec."VAT Difference (LCY)";
        PostedCashDocumentLineCZP."System-Created Entry" := Rec."System-Created Entry";
        PostedCashDocumentLineCZP."Gen. Posting Type" := Rec."Gen. Posting Type";
        PostedCashDocumentLineCZP."VAT Calculation Type" := Rec."VAT Calculation Type";
        PostedCashDocumentLineCZP."VAT Bus. Posting Group" := Rec."VAT Bus. Posting Group";
        PostedCashDocumentLineCZP."VAT Prod. Posting Group" := Rec."VAT Prod. Posting Group";
        PostedCashDocumentLineCZP."Use Tax" := Rec."Use Tax";
        PostedCashDocumentLineCZP."FA Posting Type" := Rec."FA Posting Type";
        PostedCashDocumentLineCZP."Depreciation Book Code" := Rec."Depreciation Book Code";
        PostedCashDocumentLineCZP."Maintenance Code" := Rec."Maintenance Code";
        PostedCashDocumentLineCZP."Duplicate in Depreciation Book" := Rec."Duplicate in Depreciation Book";
        PostedCashDocumentLineCZP."Use Duplication List" := Rec."Use Duplication List";
        PostedCashDocumentLineCZP."Responsibility Center" := Rec."Responsibility Center";
        PostedCashDocumentLineCZP."Dimension Set ID" := Rec."Dimension Set ID";
        PostedCashDocumentLineCZP."EET Transaction" := Rec."EET Transaction";
        PostedCashDocumentLineCZP.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Line CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeletePostedCashDocumentLine(var Rec: Record "Posted Cash Document Line")
    var
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Line CZP");
        PostedCashDocumentLineCZP.ChangeCompany(Rec.CurrentCompany);
        if PostedCashDocumentLineCZP.Get(Rec."Cash Desk No.", Rec."Cash Document No.", Rec."Line No.") then
            PostedCashDocumentLineCZP.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Line CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Line CZP", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenamePostedCashDocumentLineCZP(var Rec: Record "Posted Cash Document Line CZP"; var xRec: Record "Posted Cash Document Line CZP")
    var
        PostedCashDocumentLine: Record "Posted Cash Document Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Line CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Line");
        PostedCashDocumentLine.ChangeCompany(Rec.CurrentCompany);
        if PostedCashDocumentLine.Get(xRec."Cash Desk No.", xRec."Cash Document No.", xRec."Line No.") then
            PostedCashDocumentLine.Rename(Rec."Cash Desk No.", Rec."Cash Document No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Line CZP", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPostedCashDocumentLineCZP(var Rec: Record "Posted Cash Document Line CZP")
    begin
        SyncPostedCashDocumentLineCZP(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Line CZP", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPostedCashDocumentLineCZP(var Rec: Record "Posted Cash Document Line CZP")
    begin
        SyncPostedCashDocumentLineCZP(Rec);
    end;

    local procedure SyncPostedCashDocumentLineCZP(var Rec: Record "Posted Cash Document Line CZP")
    var
        PostedCashDocumentLine: Record "Posted Cash Document Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Line CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Line");
        PostedCashDocumentLine.ChangeCompany(Rec.CurrentCompany);
        if not PostedCashDocumentLine.Get(Rec."Cash Desk No.", Rec."Cash Document No.", Rec."Line No.") then begin
            PostedCashDocumentLine.Init();
            PostedCashDocumentLine."Cash Desk No." := Rec."Cash Desk No.";
            PostedCashDocumentLine."Cash Document No." := Rec."Cash Document No.";
            PostedCashDocumentLine."Line No." := Rec."Line No.";
            PostedCashDocumentLine.SystemId := Rec.SystemId;
            PostedCashDocumentLine.Insert(false, true);
        end;
        PostedCashDocumentLine."Document Type" := Rec."Gen. Document Type".AsInteger();
        PostedCashDocumentLine."Account Type" := Rec."Account Type".AsInteger();
        PostedCashDocumentLine."Account No." := Rec."Account No.";
        PostedCashDocumentLine."External Document No." := Rec."External Document No.";
        PostedCashDocumentLine."Posting Group" := Rec."Posting Group";
        PostedCashDocumentLine.Description := Rec.Description;
        PostedCashDocumentLine.Amount := Rec.Amount;
        PostedCashDocumentLine."Amount (LCY)" := Rec."Amount (LCY)";
        PostedCashDocumentLine."Description 2" := Rec."Description 2";
        PostedCashDocumentLine."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
        PostedCashDocumentLine."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
        PostedCashDocumentLine."Cash Document Type" := Rec."Document Type".AsInteger();
        PostedCashDocumentLine."Currency Code" := Rec."Currency Code";
        PostedCashDocumentLine."Cash Desk Event" := Rec."Cash Desk Event";
        PostedCashDocumentLine."Salespers./Purch. Code" := Rec."Salespers./Purch. Code";
        PostedCashDocumentLine."Reason Code" := Rec."Reason Code";
        PostedCashDocumentLine."VAT Base Amount" := Rec."VAT Base Amount";
        PostedCashDocumentLine."Amount Including VAT" := Rec."Amount Including VAT";
        PostedCashDocumentLine."VAT Amount" := Rec."VAT Amount";
        PostedCashDocumentLine."VAT Base Amount (LCY)" := Rec."VAT Base Amount (LCY)";
        PostedCashDocumentLine."Amount Including VAT (LCY)" := Rec."Amount Including VAT (LCY)";
        PostedCashDocumentLine."VAT Amount (LCY)" := Rec."VAT Amount (LCY)";
        PostedCashDocumentLine."VAT Difference" := Rec."VAT Difference";
        PostedCashDocumentLine."VAT %" := Rec."VAT %";
        PostedCashDocumentLine."VAT Identifier" := Rec."VAT Identifier";
        PostedCashDocumentLine."VAT Difference (LCY)" := Rec."VAT Difference (LCY)";
        PostedCashDocumentLine."System-Created Entry" := Rec."System-Created Entry";
        PostedCashDocumentLine."Gen. Posting Type" := Rec."Gen. Posting Type".AsInteger();
        PostedCashDocumentLine."VAT Calculation Type" := Rec."VAT Calculation Type";
        PostedCashDocumentLine."VAT Bus. Posting Group" := Rec."VAT Bus. Posting Group";
        PostedCashDocumentLine."VAT Prod. Posting Group" := Rec."VAT Prod. Posting Group";
        PostedCashDocumentLine."Use Tax" := Rec."Use Tax";
        PostedCashDocumentLine."FA Posting Type" := Rec."FA Posting Type".AsInteger();
        PostedCashDocumentLine."Depreciation Book Code" := Rec."Depreciation Book Code";
        PostedCashDocumentLine."Maintenance Code" := Rec."Maintenance Code";
        PostedCashDocumentLine."Duplicate in Depreciation Book" := Rec."Duplicate in Depreciation Book";
        PostedCashDocumentLine."Use Duplication List" := Rec."Use Duplication List";
        PostedCashDocumentLine."Responsibility Center" := Rec."Responsibility Center";
        PostedCashDocumentLine."Dimension Set ID" := Rec."Dimension Set ID";
        PostedCashDocumentLine."EET Transaction" := Rec."EET Transaction";
        PostedCashDocumentLine.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Line CZP", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeletePostedCashDocumentLineCZP(var Rec: Record "Posted Cash Document Line CZP")
    var
        PostedCashDocumentLine: Record "Posted Cash Document Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Line CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Line");
        PostedCashDocumentLine.ChangeCompany(Rec.CurrentCompany);
        if PostedCashDocumentLine.Get(Rec."Cash Desk No.", Rec."Cash Document No.", Rec."Line No.") then
            PostedCashDocumentLine.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Line");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif