// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Foundation.Navigate;

codeunit 18686 "TDS Navigate Handler"
{
    var
        Navigate: Page Navigate;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', false, false)]
    local procedure FindTDSEntries(
        var DocumentEntry: Record "Document Entry";
        DocNoFilter: Text;
        PostingDateFilter: Text)
    var
        TDSEntry: Record "TDS Entry";
    begin
        if TDSEntry.ReadPermission() then begin
            TDSEntry.SetCurrentKey("Document No.", "Posting Date");
            TDSEntry.SetFilter("Document No.", DocNoFilter);
            TDSEntry.SetFilter("Posting Date", PostingDateFilter);
            Navigate.InsertIntoDocEntry(DocumentEntry, Database::"TDS Entry", 0, CopyStr(TDSEntry.TableCaption(), 1, 1024), TDSEntry.Count());
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateShowRecords', '', false, false)]
    local procedure ShowEntries(
        TableID: Integer;
        DocNoFilter: Text;
        PostingDateFilter: Text;
        var TempDocumentEntry: Record "Document Entry")
    var
        TDSEntry: Record "TDS Entry";
    begin
        TDSEntry.SetRange("Document No.", DocNoFilter);
        TDSEntry.SetFilter("Posting Date", PostingDateFilter);
        if TableID = Database::"TDS Entry" then
            Page.Run(Page::"TDS Entries", TDSEntry);
    end;
}
