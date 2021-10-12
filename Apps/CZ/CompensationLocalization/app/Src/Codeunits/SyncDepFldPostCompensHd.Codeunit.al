#if not CLEAN18
#pragma warning disable AL0432, AL0603, AA0072
codeunit 31292 "Sync.Dep.Fld-PostCompensHd CZC"
{
    Access = Internal;
    Permissions = tabledata "Posted Credit Header" = rimd,
                  tabledata "Posted Compensation Header CZC" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Posted Credit Header", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenamePostedCreditHeader(var Rec: Record "Posted Credit Header"; var xRec: Record "Posted Credit Header")
    var
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Credit Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Compensation Header CZC");
        PostedCompensationHeaderCZC.ChangeCompany(Rec.CurrentCompany);
        if PostedCompensationHeaderCZC.Get(xRec."No.") then
            PostedCompensationHeaderCZC.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Compensation Header CZC");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Credit Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPostedCredtiHeader(var Rec: Record "Posted Credit Header")
    begin
        SyncPostedCreditHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Credit Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPostedCreditHeader(var Rec: Record "Posted Credit Header")
    begin
        SyncPostedCreditHeader(Rec);
    end;

    local procedure SyncPostedCreditHeader(var Rec: Record "Posted Credit Header")
    var
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Credit Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Compensation Header CZC");
        PostedCompensationHeaderCZC.ChangeCompany(Rec.CurrentCompany);
        if not PostedCompensationHeaderCZC.Get(Rec."No.") then begin
            PostedCompensationHeaderCZC.Init();
            PostedCompensationHeaderCZC."No." := Rec."No.";
            PostedCompensationHeaderCZC.SystemId := Rec.SystemId;
            PostedCompensationHeaderCZC.Insert(false, true);
        end;
        PostedCompensationHeaderCZC.Description := Rec.Description;
        PostedCompensationHeaderCZC."Company No." := Rec."Company No.";
        PostedCompensationHeaderCZC."Company Name" := Rec."Company Name";
        PostedCompensationHeaderCZC."Company Name 2" := Rec."Company Name 2";
        PostedCompensationHeaderCZC."Company Address" := Rec."Company Address";
        PostedCompensationHeaderCZC."Company Address 2" := Rec."Company Address 2";
        PostedCompensationHeaderCZC."Company City" := Rec."Company City";
        PostedCompensationHeaderCZC."Company Contact" := Rec."Company Contact";
        PostedCompensationHeaderCZC."Company County" := Rec."Company County";
        PostedCompensationHeaderCZC."Company Country/Region Code" := Rec."Company Country/Region Code";
        PostedCompensationHeaderCZC."Company Post Code" := Rec."Company Post Code";
        PostedCompensationHeaderCZC."User ID" := Rec."User ID";
        PostedCompensationHeaderCZC."Salesperson/Purchaser Code" := Rec."Salesperson Code";
        PostedCompensationHeaderCZC."Document Date" := Rec."Document Date";
        PostedCompensationHeaderCZC."Posting Date" := Rec."Posting Date";
        PostedCompensationHeaderCZC."No. Series" := Rec."No. Series";
        PostedCompensationHeaderCZC."Company Type" := Rec.Type;
        PostedCompensationHeaderCZC.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Compensation Header CZC");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Credit Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeletePostedCreditHeader(var Rec: Record "Posted Credit Header")
    var
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Credit Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Compensation Header CZC");
        PostedCompensationHeaderCZC.ChangeCompany(Rec.CurrentCompany);
        if PostedCompensationHeaderCZC.Get(Rec."No.") then
            PostedCompensationHeaderCZC.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Compensation Header CZC");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Compensation Header CZC", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenamePostedCompensationHeaderCZC(var Rec: Record "Posted Compensation Header CZC"; var xRec: Record "Posted Compensation Header CZC")
    var
        PostedCreditHeader: Record "Posted Credit Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Compensation Header CZC") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Credit Header");
        PostedCreditHeader.ChangeCompany(Rec.CurrentCompany);
        if PostedCreditHeader.Get(xRec."No.") then
            PostedCreditHeader.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Credit Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Compensation Header CZC", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPostedCompensationHeaderCZC(var Rec: Record "Posted Compensation Header CZC")
    begin
        SyncPostedCompensationHeaderCZC(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Compensation Header CZC", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPostedCompensationHeaderCZC(var Rec: Record "Posted Compensation Header CZC")
    begin
        SyncPostedCompensationHeaderCZC(Rec);
    end;

    local procedure SyncPostedCompensationHeaderCZC(var Rec: Record "Posted Compensation Header CZC")
    var
        PostedCreditHeader: Record "Posted Credit Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Compensation Header CZC") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Credit Header");
        PostedCreditHeader.ChangeCompany(Rec.CurrentCompany);
        if not PostedCreditHeader.Get(Rec."No.") then begin
            PostedCreditHeader.Init();
            PostedCreditHeader."No." := Rec."No.";
            PostedCreditHeader.SystemId := Rec.SystemId;
            PostedCreditHeader.Insert(false, true);
        end;
        PostedCreditHeader.Description := Rec.Description;
        PostedCreditHeader."Company No." := Rec."Company No.";
        PostedCreditHeader."Company Name" := Rec."Company Name";
        PostedCreditHeader."Company Name 2" := Rec."Company Name 2";
        PostedCreditHeader."Company Address" := Rec."Company Address";
        PostedCreditHeader."Company Address 2" := Rec."Company Address 2";
        PostedCreditHeader."Company City" := Rec."Company City";
        PostedCreditHeader."Company Contact" := Rec."Company Contact";
        PostedCreditHeader."Company County" := Rec."Company County";
        PostedCreditHeader."Company Country/Region Code" := Rec."Company Country/Region Code";
        PostedCreditHeader."Company Post Code" := Rec."Company Post Code";
        PostedCreditHeader."User ID" := Rec."User ID";
        PostedCreditHeader."Salesperson Code" := Rec."Salesperson/Purchaser Code";
        PostedCreditHeader."Document Date" := Rec."Document Date";
        PostedCreditHeader."Posting Date" := Rec."Posting Date";
        PostedCreditHeader."No. Series" := Rec."No. Series";
        PostedCreditHeader.Type := Rec."Company Type".AsInteger();
        PostedCreditHeader.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Credit Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Compensation Header CZC", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeletePostedCompensationHeaderCZC(var Rec: Record "Posted Compensation Header CZC")
    var
        PostedCreditHeader: Record "Posted Credit Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Posted Compensation Header CZC") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Posted Credit Header");
        PostedCreditHeader.ChangeCompany(Rec.CurrentCompany);
        if PostedCreditHeader.Get(Rec."No.") then
            PostedCreditHeader.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Posted Credit Header");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif