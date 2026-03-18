// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Navigate;

using Microsoft.Bank.Payment;

codeunit 10833 "Local Navigate Handler FR"
{
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        PaymentHeader: Record "Payment Header FR";
        [SecurityFiltering(SecurityFilter::Filtered)]
        PaymentHeaderArchive: Record "Payment Header Archive FR";
        [SecurityFiltering(SecurityFilter::Filtered)]
        PaymentLine: Record "Payment Line FR";
        [SecurityFiltering(SecurityFilter::Filtered)]
        PaymentLineArchive: Record "Payment Line Archive FR";

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', false, false)]
    local procedure OnAfterNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    begin
        if PaymentHeader.ReadPermission then begin
            SetPaymentHeaderFilters(DocNoFilter, PostingDateFilter);
            DocumentEntry.InsertIntoDocEntry(DATABASE::"Payment Header FR", PaymentHeader.TableCaption(), PaymentHeader.Count);
        end;
        if PaymentLine.ReadPermission then begin
            SetPaymentLineFilters(DocNoFilter, PostingDateFilter);
            DocumentEntry.InsertIntoDocEntry(DATABASE::"Payment Line FR", PaymentLine.TableCaption(), PaymentLine.Count);
        end;
        if PaymentHeaderArchive.ReadPermission then begin
            SetPaymentHeaderArchiveFilters(DocNoFilter, PostingDateFilter);
            DocumentEntry.InsertIntoDocEntry(DATABASE::"Payment Header Archive FR", PaymentHeaderArchive.TableCaption(), PaymentHeaderArchive.Count);
        end;
        if PaymentLineArchive.ReadPermission then begin
            SetPaymentLineArchiveFilters(DocNoFilter, PostingDateFilter);
            DocumentEntry.InsertIntoDocEntry(DATABASE::"Payment Line Archive FR", PaymentLineArchive.TableCaption(), PaymentLineArchive.Count);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnBeforeShowRecords', '', false, false)]
    local procedure OnBeforeShowRecords(var TempDocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text; var IsHandled: Boolean; ContactNo: Code[250])
    begin
        case TempDocumentEntry."Table ID" of
            DATABASE::"Payment Header FR":
                begin
                    SetPaymentHeaderFilters(DocNoFilter, PostingDateFilter);
                    PAGE.Run(0, PaymentHeader);
                end;
            DATABASE::"Payment Line FR":
                begin
                    SetPaymentLineFilters(DocNoFilter, PostingDateFilter);
                    PAGE.Run(0, PaymentLine);
                end;
            DATABASE::"Payment Header Archive FR":
                begin
                    SetPaymentHeaderArchiveFilters(DocNoFilter, PostingDateFilter);
                    PAGE.Run(0, PaymentHeaderArchive);
                end;
            DATABASE::"Payment Line Archive FR":
                begin
                    SetPaymentLineArchiveFilters(DocNoFilter, PostingDateFilter);
                    PAGE.Run(0, PaymentLineArchive)
                end;
        end;
    end;

    local procedure SetPaymentHeaderFilters(DocNoFilter: Text; PostingDateFilter: Text)
    begin
        PaymentHeader.Reset();
        PaymentHeader.SetCurrentKey("Posting Date");
        PaymentHeader.SetFilter("No.", DocNoFilter);
        PaymentHeader.SetFilter("Posting Date", PostingDateFilter);
    end;

    local procedure SetPaymentLineFilters(DocNoFilter: Text; PostingDateFilter: Text)
    begin
        PaymentLine.Reset();
        PaymentLine.SetCurrentKey("Posting Date");
        PaymentLine.SetFilter("Document No.", DocNoFilter);
        PaymentLine.SetFilter("Posting Date", PostingDateFilter);
    end;

    local procedure SetPaymentHeaderArchiveFilters(DocNoFilter: Text; PostingDateFilter: Text)
    begin
        PaymentHeaderArchive.Reset();
        PaymentHeaderArchive.SetCurrentKey("Posting Date");
        PaymentHeaderArchive.SetFilter("No.", DocNoFilter);
        PaymentHeaderArchive.SetFilter("Posting Date", PostingDateFilter);
    end;

    local procedure SetPaymentLineArchiveFilters(DocNoFilter: Text; PostingDateFilter: Text)
    begin
        PaymentLineArchive.Reset();
        PaymentLineArchive.SetCurrentKey("Posting Date");
        PaymentLineArchive.SetFilter("No.", DocNoFilter);
        PaymentLineArchive.SetFilter("Posting Date", PostingDateFilter);
    end;
}
