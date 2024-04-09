// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Foundation.Navigate;

codeunit 31434 "Navigate Handler CZB"
{
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        [SecurityFiltering(SecurityFilter::Filtered)]
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', false, false)]
    local procedure OnAfterNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text;
                                                PostingDateFilter: Text; Sender: Page Navigate)
    begin
        FindIssuedBankStatementHeader(DocumentEntry, DocNoFilter, PostingDateFilter, Sender);
        FindIssuedPaymentOrderHeader(DocumentEntry, DocNoFilter, PostingDateFilter, Sender);
    end;

    local procedure FindIssuedBankStatementHeader(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text; Navigate: Page Navigate)
    begin
        if not IssBankStatementHeaderCZB.ReadPermission() then
            exit;
        IssBankStatementHeaderCZB.Reset();
        IssBankStatementHeaderCZB.SetFilter("No.", DocNoFilter);
        IssBankStatementHeaderCZB.SetFilter("Document Date", PostingDateFilter);
        Navigate.InsertIntoDocEntry(
            DocumentEntry, Database::"Iss. Bank Statement Header CZB", Enum::"Document Entry Document Type"::" ",
            IssBankStatementHeaderCZB.TableCaption, IssBankStatementHeaderCZB.Count);
    end;

    local procedure FindIssuedPaymentOrderHeader(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text; Navigate: Page Navigate)
    begin
        if not IssPaymentOrderHeaderCZB.ReadPermission() then
            exit;
        IssPaymentOrderHeaderCZB.Reset();
        IssPaymentOrderHeaderCZB.SetFilter("No.", DocNoFilter);
        IssPaymentOrderHeaderCZB.SetFilter("Document Date", PostingDateFilter);
        Navigate.InsertIntoDocEntry(
            DocumentEntry, Database::"Iss. Payment Order Header CZB", Enum::"Document Entry Document Type"::" ",
            IssPaymentOrderHeaderCZB.TableCaption, IssPaymentOrderHeaderCZB.Count);
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateShowRecords', '', false, false)]
    local procedure OnBeforeNavigateShowRecords(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; var TempDocumentEntry: Record "Document Entry")
    begin
        case TableID of
            Database::"Iss. Bank Statement Header CZB":
                begin
                    IssBankStatementHeaderCZB.Reset();
                    IssBankStatementHeaderCZB.SetFilter("No.", DocNoFilter);
                    IssBankStatementHeaderCZB.SetFilter("Document Date", PostingDateFilter);
                    if TempDocumentEntry."No. of Records" = 1 then begin
                        IssBankStatementHeaderCZB.FindFirst();
                        IssBankStatementHeaderCZB.SetRange("Bank Account No.", IssBankStatementHeaderCZB."Bank Account No.");
                        Page.Run(Page::"Iss. Bank Statement CZB", IssBankStatementHeaderCZB)
                    end else
                        Page.Run(0, IssBankStatementHeaderCZB);
                end;
            Database::"Iss. Payment Order Header CZB":
                begin
                    IssPaymentOrderHeaderCZB.Reset();
                    IssPaymentOrderHeaderCZB.SetFilter("No.", DocNoFilter);
                    IssPaymentOrderHeaderCZB.SetFilter("Document Date", PostingDateFilter);
                    if TempDocumentEntry."No. of Records" = 1 then begin
                        IssPaymentOrderHeaderCZB.FindFirst();
                        IssPaymentOrderHeaderCZB.SetRange("Bank Account No.", IssPaymentOrderHeaderCZB."Bank Account No.");
                        Page.Run(Page::"Iss. Payment Order CZB", IssPaymentOrderHeaderCZB)
                    end else
                        Page.Run(0, IssPaymentOrderHeaderCZB);
                end;
        end;
    end;
}
