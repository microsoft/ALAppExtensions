// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Foundation.Navigate;

codeunit 31007 "Navigate Handler CZZ"
{
    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', false, false)]
    local procedure NavigateOnAfterNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        if SalesAdvLetterEntryCZZ.ReadPermission() then begin
            SalesAdvLetterEntryCZZ.SetFilter("Document No.", DocNoFilter);
            SalesAdvLetterEntryCZZ.SetFilter("Posting Date", PostingDateFilter);
            if SalesAdvLetterEntryCZZ.Count() > 0 then begin
                if DocumentEntry.FindLast() then;
                DocumentEntry.Init();
                DocumentEntry."Entry No." += 1;
                DocumentEntry."Table ID" := Database::"Sales Adv. Letter Entry CZZ";
                DocumentEntry."Table Name" := CopyStr(SalesAdvLetterEntryCZZ.TableCaption(), 1, MaxStrLen(DocumentEntry."Table Name"));
                DocumentEntry."No. of Records" := SalesAdvLetterEntryCZZ.Count();
                DocumentEntry.Insert();
            end;
        end;
        if PurchAdvLetterEntryCZZ.ReadPermission() then begin
            PurchAdvLetterEntryCZZ.SetFilter("Document No.", DocNoFilter);
            PurchAdvLetterEntryCZZ.SetFilter("Posting Date", PostingDateFilter);
            if PurchAdvLetterEntryCZZ.Count() > 0 then begin
                if DocumentEntry.FindLast() then;
                DocumentEntry.Init();
                DocumentEntry."Entry No." += 1;
                DocumentEntry."Table ID" := Database::"Purch. Adv. Letter Entry CZZ";
                DocumentEntry."Table Name" := CopyStr(PurchAdvLetterEntryCZZ.TableCaption(), 1, MaxStrLen(DocumentEntry."Table Name"));
                DocumentEntry."No. of Records" := PurchAdvLetterEntryCZZ.Count();
                DocumentEntry.Insert();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateShowRecords', '', true, false)]
    local procedure NavigateOnAfterNavigateShowRecords(var TempDocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        case TempDocumentEntry."Table ID" of
            Database::"Sales Adv. Letter Entry CZZ":
                begin
                    SalesAdvLetterEntryCZZ.SetFilter("Document No.", DocNoFilter);
                    SalesAdvLetterEntryCZZ.SetFilter("Posting Date", PostingDateFilter);
                    Page.Run(0, SalesAdvLetterEntryCZZ);
                end;
            Database::"Purch. Adv. Letter Entry CZZ":
                begin
                    PurchAdvLetterEntryCZZ.SetFilter("Document No.", DocNoFilter);
                    PurchAdvLetterEntryCZZ.SetFilter("Posting Date", PostingDateFilter);
                    Page.Run(0, PurchAdvLetterEntryCZZ);
                end;
        end;
    end;
}
