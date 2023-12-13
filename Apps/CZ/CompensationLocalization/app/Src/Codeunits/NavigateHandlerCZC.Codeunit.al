// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Foundation.Navigate;

codeunit 31266 "Navigate Handler CZC"
{
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', false, false)]
    local procedure OnAfterNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text;
                                                PostingDateFilter: Text; Sender: Page Navigate)
    begin
        FindPostedCompesationHeader(DocumentEntry, DocNoFilter, PostingDateFilter, Sender);
    end;

    local procedure FindPostedCompesationHeader(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text; Navigate: Page Navigate)
    var
        PostedCompensationTxt: Label 'Posted Compensation';
        DocumentEntryDocumentType: Enum "Document Entry Document Type";
    begin
        if PostedCompensationHeaderCZC.ReadPermission() then begin
            PostedCompensationHeaderCZC.Reset();
            PostedCompensationHeaderCZC.SetFilter("No.", DocNoFilter);
            PostedCompensationHeaderCZC.SetFilter("Posting Date", PostingDateFilter);
            Navigate.InsertIntoDocEntry(DocumentEntry, Database::"Posted Compensation Header CZC", DocumentEntryDocumentType::" ",
                PostedCompensationTxt, PostedCompensationHeaderCZC.Count());
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnFindRecordsOnAfterSetSource', '', false, false)]
    local procedure OnFindRecordsOnAfterSetSource(var DocumentEntry: Record "Document Entry"; var PostingDate: Date;
                                                var DocType2: Text[100]; var DocNo: Code[20];
                                                var SourceType2: Integer; var SourceNo: Code[20]; var IsHandled: Boolean;
                                                var DocNoFilter: Text; var PostingDateFilter: Text)
    begin
        if NoOfRecords(DocumentEntry, Database::"Posted Compensation Header CZC") = 1 then begin
            PostedCompensationHeaderCZC.Reset();
            PostedCompensationHeaderCZC.SetFilter("No.", DocNoFilter);
            PostedCompensationHeaderCZC.SetFilter("Posting Date", PostingDateFilter);
            if not PostedCompensationHeaderCZC.FindFirst() then
                exit;
            PostingDate := PostedCompensationHeaderCZC."Posting Date";
            DocType2 := CopyStr(Format(PostedCompensationHeaderCZC."Company Type"), 1, MaxStrLen(DocType2));
            DocNo := PostedCompensationHeaderCZC."No.";
            SourceType2 := Database::"Posted Compensation Header CZC";
            SourceNo := PostedCompensationHeaderCZC."Company No.";
            IsHandled := true;
        end;
    end;

    local procedure NoOfRecords(var DocumentEntry: Record "Document Entry"; TableID: Integer): Integer
    begin
        DocumentEntry.SetRange(DocumentEntry."Table ID", TableID);
        if not DocumentEntry.FindFirst() then
            DocumentEntry.Init();
        DocumentEntry.SetRange(DocumentEntry."Table ID");
        exit(DocumentEntry."No. of Records");
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnBeforeNavigateShowRecords', '', false, false)]
    local procedure OnBeforeNavigateShowRecords(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; var TempDocumentEntry: Record "Document Entry"; var IsHandled: Boolean)
    begin
        case TableID of
            Database::"Posted Compensation Header CZC":
                begin
                    PostedCompensationHeaderCZC.Reset();
                    PostedCompensationHeaderCZC.SetFilter("No.", DocNoFilter);
                    PostedCompensationHeaderCZC.SetFilter("Posting Date", PostingDateFilter);
                    if TempDocumentEntry."No. of Records" = 1 then
                        Page.Run(Page::"Posted Compensation Card CZC", PostedCompensationHeaderCZC)
                    else
                        Page.Run(0, PostedCompensationHeaderCZC);
                    IsHandled := true;
                end;
        end;
    end;
}
