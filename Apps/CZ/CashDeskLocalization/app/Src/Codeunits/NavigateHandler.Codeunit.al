// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Foundation.Navigate;

codeunit 11791 "Navigate Handler CZP"
{
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', false, false)]
    local procedure OnAfterNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text;
                                                PostingDateFilter: Text; Sender: Page Navigate)
    begin
        FindPostedCashDocumentHdr(DocumentEntry, DocNoFilter, PostingDateFilter, Sender);
        FindCashDeskLedgerEntries(DocumentEntry, DocNoFilter, PostingDateFilter);
    end;

    local procedure FindPostedCashDocumentHdr(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text; Navigate: Page Navigate)
    var
        PostedCashDocumentTxt: Label 'Posted Cash Document';
    begin
        if PostedCashDocumentHdrCZP.ReadPermission() then begin
            PostedCashDocumentHdrCZP.Reset();
            PostedCashDocumentHdrCZP.SetFilter("No.", DocNoFilter);
            PostedCashDocumentHdrCZP.SetFilter("Posting Date", PostingDateFilter);
            Navigate.InsertIntoDocEntry(DocumentEntry, Database::"Posted Cash Document Hdr. CZP", "Document Entry Document Type"::Quote,
                PostedCashDocumentTxt, PostedCashDocumentHdrCZP.Count());
        end;
    end;

    local procedure FindCashDeskLedgerEntries(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        BankAccount: Record "Bank Account";
        CashDeskLedgerEntryTxt: Label 'Cash Desk Ledger Entry';
    begin
        if NoOfRecords(DocumentEntry, Database::"Bank Account Ledger Entry") = 1 then begin
            BankAccountLedgerEntry.SetFilter("Document No.", DocNoFilter);
            BankAccountLedgerEntry.SetFilter("Posting Date", PostingDateFilter);
            if BankAccountLedgerEntry.FindFirst() then
                if BankAccount.Get(BankAccountLedgerEntry."Bank Account No.") then
                    if BankAccount."Account Type CZP" = BankAccount."Account Type CZP"::"Cash Desk" then begin
                        DocumentEntry.SetRange(DocumentEntry."Table ID", Database::"Bank Account Ledger Entry");
                        DocumentEntry.ModifyAll("Table Name", CashDeskLedgerEntryTxt);
                        DocumentEntry.SetRange(DocumentEntry."Table ID");
                    end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnFindRecordsOnAfterSetSource', '', false, false)]
    local procedure OnFindRecordsOnAfterSetSource(var DocumentEntry: Record "Document Entry"; var PostingDate: Date;
                                                var DocType2: Text[100]; var DocNo: Code[20];
                                                var SourceType2: Integer; var SourceNo: Code[20]; var IsHandled: Boolean;
                                                var DocNoFilter: Text; var PostingDateFilter: Text)
    begin
        if NoOfRecords(DocumentEntry, Database::"Posted Cash Document Hdr. CZP") = 1 then begin
            PostedCashDocumentHdrCZP.Reset();
            PostedCashDocumentHdrCZP.SetFilter("No.", DocNoFilter);
            PostedCashDocumentHdrCZP.SetFilter("Posting Date", PostingDateFilter);
            if not PostedCashDocumentHdrCZP.FindFirst() then
                exit;
            PostingDate := PostedCashDocumentHdrCZP."Posting Date";
            DocType2 := CopyStr(Format(PostedCashDocumentHdrCZP."Document Type"), 1, MaxStrLen(DocType2));
            DocNo := PostedCashDocumentHdrCZP."No.";
            SourceType2 := Database::"Posted Cash Document Hdr. CZP";
            SourceNo := PostedCashDocumentHdrCZP."Cash Desk No.";
            IsHandled := true;
        end;
    end;

    local procedure NoOfRecords(var DocumentEntry: Record "Document Entry"; TableID: Integer): Integer
    var
        DocEntryNoOfRecords: Integer;
    begin
        DocumentEntry.SetRange(DocumentEntry."Table ID", TableID);
        if not DocumentEntry.FindFirst() then
            DocumentEntry.Init();
        DocumentEntry.SetRange(DocumentEntry."Table ID");
        DocEntryNoOfRecords := DocumentEntry."No. of Records";
        if not DocumentEntry.FindLast() then
            DocumentEntry.Init();
        exit(DocEntryNoOfRecords);
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnBeforeNavigateShowRecords', '', false, false)]
    local procedure OnBeforeNavigateShowRecords(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; var TempDocumentEntry: Record "Document Entry"; var IsHandled: Boolean)
    begin
        case TableID of
            Database::"Posted Cash Document Hdr. CZP":
                begin
                    PostedCashDocumentHdrCZP.Reset();
                    PostedCashDocumentHdrCZP.SetFilter("No.", DocNoFilter);
                    PostedCashDocumentHdrCZP.SetFilter("Posting Date", PostingDateFilter);
                    if TempDocumentEntry."No. of Records" = 1 then
                        Page.Run(Page::"Posted Cash Document CZP", PostedCashDocumentHdrCZP)
                    else
                        Page.Run(0, PostedCashDocumentHdrCZP);
                    IsHandled := true;
                end;
        end;
    end;
}
