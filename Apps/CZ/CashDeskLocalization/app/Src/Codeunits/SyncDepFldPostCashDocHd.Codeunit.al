#if not CLEAN17
#pragma warning disable AL0432,AL0603
codeunit 31133 "Sync.Dep.Fld-PostCashDocHd CZP"
{
    Permissions = tabledata "Posted Cash Document Header" = rimd,
                  tabledata "Posted Cash Document Hdr. CZP" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.5';

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Header", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenamePostedCashDocumentHeader(var Rec: Record "Posted Cash Document Header"; var xRec: Record "Posted Cash Document Header")
    var
        PostedCashDocumentHeaderCZP: Record "Posted Cash Document Hdr. CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Hdr. CZP");
        PostedCashDocumentHeaderCZP.ChangeCompany(Rec.CurrentCompany);
        if PostedCashDocumentHeaderCZP.Get(xRec."Cash Desk No.", xRec."No.") then
            PostedCashDocumentHeaderCZP.Rename(Rec."Cash Desk No.", Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Hdr. CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPostedCashDocumentHeader(var Rec: Record "Posted Cash Document Header")
    begin
        SyncPostedCashDocumentHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPostedCashDocumentHeader(var Rec: Record "Posted Cash Document Header")
    begin
        SyncPostedCashDocumentHeader(Rec);
    end;

    local procedure SyncPostedCashDocumentHeader(var Rec: Record "Posted Cash Document Header")
    var
        PostedCashDocumentHeaderCZP: Record "Posted Cash Document Hdr. CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Hdr. CZP");
        PostedCashDocumentHeaderCZP.ChangeCompany(Rec.CurrentCompany);
        if not PostedCashDocumentHeaderCZP.Get(Rec."Cash Desk No.", Rec."No.") then begin
            PostedCashDocumentHeaderCZP.Init();
            PostedCashDocumentHeaderCZP."Cash Desk No." := Rec."Cash Desk No.";
            PostedCashDocumentHeaderCZP."No." := Rec."No.";
            PostedCashDocumentHeaderCZP.SystemId := Rec.SystemId;
            PostedCashDocumentHeaderCZP.Insert(false, true);
        end;
        PostedCashDocumentHeaderCZP."Pay-to/Receive-from Name" := Rec."Pay-to/Receive-from Name";
        PostedCashDocumentHeaderCZP."Pay-to/Receive-from Name 2" := Rec."Pay-to/Receive-from Name 2";
        PostedCashDocumentHeaderCZP."Posting Date" := Rec."Posting Date";
        PostedCashDocumentHeaderCZP."No. Printed" := Rec."No. Printed";
        PostedCashDocumentHeaderCZP."Created ID" := Rec."Created ID";
        PostedCashDocumentHeaderCZP."Released ID" := Rec."Released ID";
        PostedCashDocumentHeaderCZP."Document Type" := Rec."Cash Document Type";
        PostedCashDocumentHeaderCZP."No. Series" := Rec."No. Series";
        PostedCashDocumentHeaderCZP."Currency Code" := Rec."Currency Code";
        PostedCashDocumentHeaderCZP."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
        PostedCashDocumentHeaderCZP."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
        PostedCashDocumentHeaderCZP."Currency Factor" := Rec."Currency Factor";
        PostedCashDocumentHeaderCZP."Document Date" := Rec."Document Date";
        PostedCashDocumentHeaderCZP."VAT Date" := Rec."VAT Date";
        PostedCashDocumentHeaderCZP."Created Date" := Rec."Created Date";
        PostedCashDocumentHeaderCZP.Description := Rec.Description;
        PostedCashDocumentHeaderCZP."Salespers./Purch. Code" := Rec."Salespers./Purch. Code";
        PostedCashDocumentHeaderCZP."Amounts Including VAT" := Rec."Amounts Including VAT";
        PostedCashDocumentHeaderCZP."Reason Code" := Rec."Reason Code";
        PostedCashDocumentHeaderCZP."External Document No." := Rec."External Document No.";
        PostedCashDocumentHeaderCZP."Responsibility Center" := Rec."Responsibility Center";
        PostedCashDocumentHeaderCZP."Payment Purpose" := Rec."Payment Purpose";
        PostedCashDocumentHeaderCZP."Received By" := Rec."Received By";
        PostedCashDocumentHeaderCZP."Identification Card No." := Rec."Identification Card No.";
        PostedCashDocumentHeaderCZP."Paid By" := Rec."Paid By";
        PostedCashDocumentHeaderCZP."Received From" := Rec."Received From";
        PostedCashDocumentHeaderCZP."Paid To" := Rec."Paid To";
        PostedCashDocumentHeaderCZP."Registration No." := Rec."Registration No.";
        PostedCashDocumentHeaderCZP."VAT Registration No." := Rec."VAT Registration No.";
        PostedCashDocumentHeaderCZP."Partner Type" := Rec."Partner Type";
        PostedCashDocumentHeaderCZP."Partner No." := Rec."Partner No.";
        PostedCashDocumentHeaderCZP."Canceled Document" := Rec."Canceled Document";
        PostedCashDocumentHeaderCZP."Dimension Set ID" := Rec."Dimension Set ID";
        PostedCashDocumentHeaderCZP."EET Entry No." := Rec."EET Entry No.";
        PostedCashDocumentHeaderCZP.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Hdr. CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeletePostedCashDocumentHeader(var Rec: Record "Posted Cash Document Header")
    var
        PostedCashDocumentHeaderCZP: Record "Posted Cash Document Hdr. CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Hdr. CZP");
        PostedCashDocumentHeaderCZP.ChangeCompany(Rec.CurrentCompany);
        if PostedCashDocumentHeaderCZP.Get(Rec."Cash Desk No.", Rec."No.") then
            PostedCashDocumentHeaderCZP.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Hdr. CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Hdr. CZP", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenamePostedCashDocumentHeaderCZP(var Rec: Record "Posted Cash Document Hdr. CZP"; var xRec: Record "Posted Cash Document Hdr. CZP")
    var
        PostedCashDocumentHeader: Record "Posted Cash Document Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Hdr. CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Header");
        PostedCashDocumentHeader.ChangeCompany(Rec.CurrentCompany);
        if PostedCashDocumentHeader.Get(xRec."Cash Desk No.", xRec."No.") then
            PostedCashDocumentHeader.Rename(Rec."Cash Desk No.", Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Hdr. CZP", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPostedCashDocumentHeaderCZP(var Rec: Record "Posted Cash Document Hdr. CZP")
    begin
        SyncPostedCashDocumentHeaderCZP(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Hdr. CZP", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPostedCashDocumentHeaderCZP(var Rec: Record "Posted Cash Document Hdr. CZP")
    begin
        SyncPostedCashDocumentHeaderCZP(Rec);
    end;

    local procedure SyncPostedCashDocumentHeaderCZP(var Rec: Record "Posted Cash Document Hdr. CZP")
    var
        PostedCashDocumentHeader: Record "Posted Cash Document Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Hdr. CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Header");
        PostedCashDocumentHeader.ChangeCompany(Rec.CurrentCompany);
        if not PostedCashDocumentHeader.Get(Rec."Cash Desk No.", Rec."No.") then begin
            PostedCashDocumentHeader.Init();
            PostedCashDocumentHeader."Cash Desk No." := Rec."Cash Desk No.";
            PostedCashDocumentHeader."No." := Rec."No.";
            PostedCashDocumentHeader.SystemId := Rec.SystemId;
            PostedCashDocumentHeader.Insert(false, true);
        end;
        PostedCashDocumentHeader."Pay-to/Receive-from Name" := Rec."Pay-to/Receive-from Name";
        PostedCashDocumentHeader."Pay-to/Receive-from Name 2" := Rec."Pay-to/Receive-from Name 2";
        PostedCashDocumentHeader."Posting Date" := Rec."Posting Date";
        PostedCashDocumentHeader."No. Printed" := Rec."No. Printed";
        PostedCashDocumentHeader."Created ID" := Rec."Created ID";
        PostedCashDocumentHeader."Released ID" := Rec."Released ID";
        PostedCashDocumentHeader."Cash Document Type" := Rec."Document Type".AsInteger();
        PostedCashDocumentHeader."No. Series" := Rec."No. Series";
        PostedCashDocumentHeader."Currency Code" := Rec."Currency Code";
        PostedCashDocumentHeader."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
        PostedCashDocumentHeader."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
        PostedCashDocumentHeader."Currency Factor" := Rec."Currency Factor";
        PostedCashDocumentHeader."Document Date" := Rec."Document Date";
        PostedCashDocumentHeader."VAT Date" := Rec."VAT Date";
        PostedCashDocumentHeader."Created Date" := Rec."Created Date";
        PostedCashDocumentHeader.Description := Rec.Description;
        PostedCashDocumentHeader."Salespers./Purch. Code" := Rec."Salespers./Purch. Code";
        PostedCashDocumentHeader."Amounts Including VAT" := Rec."Amounts Including VAT";
        PostedCashDocumentHeader."Reason Code" := Rec."Reason Code";
        PostedCashDocumentHeader."External Document No." := Rec."External Document No.";
        PostedCashDocumentHeader."Responsibility Center" := Rec."Responsibility Center";
        PostedCashDocumentHeader."Payment Purpose" := Rec."Payment Purpose";
        PostedCashDocumentHeader."Received By" := CopyStr(Rec."Received By", 1, MaxStrLen(PostedCashDocumentHeader."Received By"));
        PostedCashDocumentHeader."Identification Card No." := Rec."Identification Card No.";
        PostedCashDocumentHeader."Paid By" := Rec."Paid By";
        PostedCashDocumentHeader."Received From" := Rec."Received From";
        PostedCashDocumentHeader."Paid To" := Rec."Paid To";
        PostedCashDocumentHeader."Registration No." := Rec."Registration No.";
        PostedCashDocumentHeader."VAT Registration No." := Rec."VAT Registration No.";
        PostedCashDocumentHeader."Partner Type" := Rec."Partner Type".AsInteger();
        PostedCashDocumentHeader."Partner No." := Rec."Partner No.";
        PostedCashDocumentHeader."Canceled Document" := Rec."Canceled Document";
        PostedCashDocumentHeader."Dimension Set ID" := Rec."Dimension Set ID";
        PostedCashDocumentHeader."EET Entry No." := Rec."EET Entry No.";
        PostedCashDocumentHeader.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Hdr. CZP", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeletePostedCashDocumentHeaderCZP(var Rec: Record "Posted Cash Document Hdr. CZP")
    var
        PostedCashDocumentHeader: Record "Posted Cash Document Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Cash Document Hdr. CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Cash Document Header");
        PostedCashDocumentHeader.ChangeCompany(Rec.CurrentCompany);
        if PostedCashDocumentHeader.Get(Rec."Cash Desk No.", Rec."No.") then
            PostedCashDocumentHeader.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Cash Document Header");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif