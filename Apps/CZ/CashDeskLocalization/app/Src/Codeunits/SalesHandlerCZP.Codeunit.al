// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.Attachment;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;

#pragma warning disable AA0210
codeunit 11736 "Sales Handler CZP"
{
    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Payment Method Code', false, false)]
    local procedure UpdateCashDeskOnAfterPaymentMethodValidate(var Rec: Record "Sales Header")
    var
        PaymentMethod: Record "Payment Method";
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."Payment Method Code" = '' then
            Rec.Validate("Cash Desk Code CZP", '')
        else begin
            PaymentMethod.Get(Rec."Payment Method Code");
            Rec.Validate("Cash Desk Code CZP", PaymentMethod."Cash Desk Code CZP");
            Rec.Validate("Cash Document Action CZP", PaymentMethod."Cash Document Action CZP");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterShowDoc', '', false, false)]
    local procedure ShowPostedCashDocumentOnAfterShowDoc(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        if GetPostedCashDocumentHdrCZP(CustLedgerEntry, PostedCashDocumentHdrCZP) then
            Page.Run(Page::"Posted Cash Document CZP", PostedCashDocumentHdrCZP);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterShowPostedDocAttachment', '', false, false)]
    local procedure ShowPostedCashDocAttachmentOnAfterShowPostedDocAttachment(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        DocumentAttachmentDetails: Page "Document Attachment Details";
        RecordRef: RecordRef;
    begin
        if GetPostedCashDocumentHdrCZP(CustLedgerEntry, PostedCashDocumentHdrCZP) then begin
            RecordRef.GetTable(PostedCashDocumentHdrCZP);
            DocumentAttachmentDetails.OpenForRecRef(RecordRef);
            DocumentAttachmentDetails.RunModal();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterHasPostedDocAttachment', '', false, false)]
    local procedure HasPostedCashDocAttachmentOnAfterHasPostedDocAttachment(var CustLedgerEntry: Record "Cust. Ledger Entry"; var HasPostedDocumentAttachment: Boolean)
    var
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        if GetPostedCashDocumentHdrCZP(CustLedgerEntry, PostedCashDocumentHdrCZP) then
            HasPostedDocumentAttachment := PostedCashDocumentHdrCZP.HasPostedDocumentAttachment();
    end;

    local procedure GetPostedCashDocumentHdrCZP(var CustLedgerEntry: Record "Cust. Ledger Entry"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"): Boolean
    var
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
    begin
        if not (CustLedgerEntry."Document Type" in [CustLedgerEntry."Document Type"::Payment, CustLedgerEntry."Document Type"::Refund]) then
            exit(false);
        PostedCashDocumentLineCZP.SetRange("Cash Document No.", CustLedgerEntry."Document No.");
        PostedCashDocumentLineCZP.SetRange("Gen. Document Type", CustLedgerEntry."Document Type".AsInteger());
        PostedCashDocumentLineCZP.SetRange("Account Type", PostedCashDocumentLineCZP."Account Type"::Customer);
        PostedCashDocumentLineCZP.SetRange("Account No.", CustLedgerEntry."Customer No.");
        if not PostedCashDocumentLineCZP.FindFirst() then
            exit(false);
        if PostedCashDocumentHdrCZP.Get(PostedCashDocumentLineCZP."Cash Desk No.", PostedCashDocumentLineCZP."Cash Document No.") then
            exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnCheckAndUpdateOnAfterSetPostingFlags', '', false, false)]
    local procedure CheckCashDeskOnCheckAndUpdateOnAfterSetPostingFlags(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.CheckCashDocumentActionCZP();
        CheckCashDeskUserRights(SalesHeader);
    end;

    local procedure CheckCashDeskUserRights(var SalesHeader: Record "Sales Header")
    begin
        if not SalesHeader.Invoice then
            exit;
        if SalesHeader."Cash Document Action CZP".AsInteger() > SalesHeader."Cash Document Action CZP"::" ".AsInteger() then
            CashDeskManagementCZP.CheckUserRights(SalesHeader."Cash Desk Code CZP", SalesHeader."Cash Document Action CZP"::Create);
        if (SalesHeader."Cash Document Action CZP" = SalesHeader."Cash Document Action CZP"::Release) or
           (SalesHeader."Cash Document Action CZP" = SalesHeader."Cash Document Action CZP"::"Release and Print")
        then
            CashDeskManagementCZP.CheckUserRights(SalesHeader."Cash Desk Code CZP", SalesHeader."Cash Document Action CZP");
        if (SalesHeader."Cash Document Action CZP" = SalesHeader."Cash Document Action CZP"::Post) or
           (SalesHeader."Cash Document Action CZP" = SalesHeader."Cash Document Action CZP"::"Post and Print")
        then begin
            CashDeskManagementCZP.CheckUserRights(SalesHeader."Cash Desk Code CZP", SalesHeader."Cash Document Action CZP"::Release);
            CashDeskManagementCZP.CheckUserRights(SalesHeader."Cash Desk Code CZP", SalesHeader."Cash Document Action CZP");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure CreateCashDocumentOnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        if (SalesHeader."Cash Desk Code CZP" = '') or not SalesHeader.Invoice then
            exit;

        OnBeforeCreateCashDocument(SalesHeader, SalesInvoiceHeader, SalesCrMemoHeader, GenJnlPostLine);
        if SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice] then
            CashDeskManagementCZP.CreateCashDocumentFromSalesInvoice(SalesInvoiceHeader)
        else
            CashDeskManagementCZP.CreateCashDocumentFromSalesCrMemo(SalesCrMemoHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateCashDocument(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;
}
