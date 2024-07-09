namespace Microsoft.Bank.Deposit;

using Microsoft.Foundation.Navigate;

codeunit 1699 "Navigate Bank Deposit Ext."
{
    Access = Internal;

    local procedure SetPostedBankDepositHeaderFilters(var PostedBankDepositHeader: Record "Posted Bank Deposit Header"; DocNoFilter: Text): Boolean
    begin
        if not PostedBankDepositHeader.ReadPermission() then
            exit(false);

        PostedBankDepositHeader.Reset();
        PostedBankDepositHeader.SetFilter("No.", DocNoFilter);
        exit(true);
    end;

    local procedure SetPostedBankDepositLineFilters(var PostedBankDepositLine: Record "Posted Bank Deposit Line"; DocNoFilter: Text; PostingDateFilter: Text; UseDocumentNo: Boolean): Boolean
    begin
        if not PostedBankDepositLine.ReadPermission() then
            exit(false);

        PostedBankDepositLine.Reset();
        PostedBankDepositLine.SetCurrentKey("Bank Deposit No.", "Posting Date");
        if UseDocumentNo then
            PostedBankDepositLine.SetFilter("Document No.", DocNoFilter)
        else
            PostedBankDepositLine.SetFilter("Bank Deposit No.", DocNoFilter);
        PostedBankDepositLine.SetFilter("Posting Date", PostingDateFilter);
        exit(true);
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', false, false)]
    local procedure OnAfterNavigateFindRecords(Sender: Page Navigate; var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text; var NewSourceRecVar: Variant)
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
    begin
        if SetPostedBankDepositHeaderFilters(PostedBankDepositHeader, DocNoFilter) then
            DocumentEntry.InsertIntoDocEntry(Database::"Posted Bank Deposit Header", PostedBankDepositHeader.TableCaption(), PostedBankDepositHeader.Count());

        if SetPostedBankDepositLineFilters(PostedBankDepositLine, DocNoFilter, PostingDateFilter, not Sender.GetNavigationFromPostedBankDeposit()) then
            DocumentEntry.InsertIntoDocEntry(Database::"Posted Bank Deposit Line", PostedBankDepositLine.TableCaption(), PostedBankDepositLine.Count());
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnBeforeShowRecords', '', false, false)]
    local procedure OnBeforeShowRecords(Sender: Page Navigate; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean; var TempDocumentEntry: Record "Document Entry" temporary; var IsHandled: Boolean)
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
    begin
        if ItemTrackingSearch or IsHandled then
            exit;

        if TempDocumentEntry."Table ID" = Database::"Posted Bank Deposit Header" then begin
            IsHandled := true;
            SetPostedBankDepositHeaderFilters(PostedBankDepositHeader, DocNoFilter);
            Page.Run(0, PostedBankDepositHeader);
            exit;
        end;
        if TempDocumentEntry."Table ID" = Database::"Posted Bank Deposit Line" then begin
            IsHandled := true;
            SetPostedBankDepositLineFilters(PostedBankDepositLine, DocNoFilter, PostingDateFilter, not Sender.GetNavigationFromPostedBankDeposit());
            Page.Run(0, PostedBankDepositLine);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnBeforeFindRecordsSetSources', '', false, false)]
    local procedure OnBeforeFindRecordsSetSources(Sender: Page Navigate; DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text; ExtDocNo: Text; var IsHandled: Boolean)
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        DocType: Text[100];
    begin
        if not Sender.GetNavigationFromPostedBankDeposit() then
            exit;
        if Sender.GetNoOfRecords(Database::"Posted Bank Deposit Header") <> 1 then
            exit;
        if not SetPostedBankDepositHeaderFilters(PostedBankDepositHeader, DocNoFilter) then
            exit;
        if IsHandled then
            exit;
        if not PostedBankDepositHeader.FindFirst() then
            exit;
        IsHandled := true;
        DocType := CopyStr(PostedBankDepositHeader.TableCaption(), 1, MaxStrLen(DocType));
        Sender.SetSource(PostedBankDepositHeader."Posting Date", DocType, PostedBankDepositHeader."No.", 4, PostedBankDepositHeader."Bank Account No.");
    end;
}