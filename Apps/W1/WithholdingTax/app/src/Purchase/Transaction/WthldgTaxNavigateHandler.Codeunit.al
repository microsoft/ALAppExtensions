// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Foundation.Navigate;

codeunit 6787 "Wthldg Tax Navigate Handler"
{
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        WithholdingTaxEntry: Record "Withholding Tax Entry";

    [EventSubscriber(ObjectType::Page, Page::Navigate, OnAfterNavigateFindRecords, '', false, false)]
    local procedure OnAfterNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    begin
        if WithholdingTaxEntry.ReadPermission() then begin
            SetWithholdingEntryFilters(DocNoFilter, PostingDateFilter);
            DocumentEntry.InsertIntoDocEntry(Database::"Withholding Tax Entry", WithholdingTaxEntry.TableCaption(), WithholdingTaxEntry.Count);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, OnBeforeShowRecords, '', false, false)]
    local procedure OnBeforeShowRecords(var TempDocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text; var IsHandled: Boolean; ContactNo: Code[250])
    begin
        case TempDocumentEntry."Table ID" of
            Database::"Withholding Tax Entry":
                begin
                    SetWithholdingEntryFilters(DocNoFilter, PostingDateFilter);
                    Page.Run(0, WithholdingTaxEntry);
                end;
        end;
    end;

    local procedure SetWithholdingEntryFilters(DocNoFilter: Text; PostingDateFilter: Text)
    begin
        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetCurrentKey("Document No.", "Posting Date");
        WithholdingTaxEntry.SetFilter("Document No.", DocNoFilter);
        WithholdingTaxEntry.SetFilter("Posting Date", PostingDateFilter);
    end;
}
