// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Foundation.Navigate;

codeunit 18808 "TCS-Post Preview"
{
    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', false, false)]
    local procedure FindTCSEntries(
        var DocumentEntry: Record "Document Entry";
        DocNoFilter: Text;
        PostingDateFilter: Text)
    var
        TCSEntry: Record "TCS Entry";
    begin
        if TCSEntry.ReadPermission() then begin
            TCSEntry.Reset();
            TCSEntry.SetCurrentKey("Document No.", "Posting Date");
            TCSEntry.SetFilter("Document No.", DocNoFilter);
            TCSEntry.SetFilter("Posting Date", PostingDateFilter);
            DocumentEntry.InsertIntoDocEntry(DATABASE::"TCS Entry", 0, CopyStr(TCSEntry.TableCaption(), 1, 1024), TCSEntry.Count());
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnBeforeShowRecords', '', false, false)]
    local procedure ShowEntries(
        DocNoFilter: Text;
        PostingDateFilter: Text;
        var TempDocumentEntry: Record "Document Entry";
        var IsHandled: Boolean)
    var
        TCSEntry: Record "TCS Entry";
    begin
        if TempDocumentEntry."Table ID" = Database::"TCS Entry" then begin
            TCSEntry.Reset();
            TCSEntry.SetFilter("Document No.", DocNoFilter);
            TCSEntry.SetFilter("Posting Date", PostingDateFilter);
            Page.Run(Page::"TCS Entries", TCSEntry);
            IsHandled := true;
        end;
    end;
}
