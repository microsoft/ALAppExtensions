// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.Attachment;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;

#pragma warning disable AA0210
codeunit 11737 "Purchase Handler CZP"
{
    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Payment Method Code', false, false)]
    local procedure UpdateCashDeskOnAfterPaymentMethodValidate(var Rec: Record "Purchase Header")
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

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterShowDoc', '', false, false)]
    local procedure ShowPostedCashDocumentOnAfterShowDoc(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        if GetPostedCashDocumentHdrCZP(VendorLedgerEntry, PostedCashDocumentHdrCZP) then
            Page.Run(Page::"Posted Cash Document CZP", PostedCashDocumentHdrCZP);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterShowPostedDocAttachment', '', false, false)]
    local procedure ShowPostedCashDocAttachmentOnAfterShowPostedDocAttachment(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        DocumentAttachmentDetails: Page "Document Attachment Details";
        RecordRef: RecordRef;
    begin
        if GetPostedCashDocumentHdrCZP(VendorLedgerEntry, PostedCashDocumentHdrCZP) then begin
            RecordRef.GetTable(PostedCashDocumentHdrCZP);
            DocumentAttachmentDetails.OpenForRecRef(RecordRef);
            DocumentAttachmentDetails.RunModal();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterHasPostedDocAttachment', '', false, false)]
    local procedure HasPostedCashDocAttachmentOnAfterHasPostedDocAttachment(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var HasPostedDocumentAttachment: Boolean)
    var
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        if GetPostedCashDocumentHdrCZP(VendorLedgerEntry, PostedCashDocumentHdrCZP) then
            HasPostedDocumentAttachment := PostedCashDocumentHdrCZP.HasPostedDocumentAttachment();
    end;

    local procedure GetPostedCashDocumentHdrCZP(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"): Boolean
    var
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
    begin
        if not (VendorLedgerEntry."Document Type" in [VendorLedgerEntry."Document Type"::Payment, VendorLedgerEntry."Document Type"::Refund]) then
            exit(false);
        PostedCashDocumentLineCZP.SetRange("Cash Document No.", VendorLedgerEntry."Document No.");
        PostedCashDocumentLineCZP.SetRange("Gen. Document Type", VendorLedgerEntry."Document Type".AsInteger());
        PostedCashDocumentLineCZP.SetRange("Account Type", PostedCashDocumentLineCZP."Account Type"::Vendor);
        PostedCashDocumentLineCZP.SetRange("Account No.", VendorLedgerEntry."Vendor No.");
        if not PostedCashDocumentLineCZP.FindFirst() then
            exit(false);
        if PostedCashDocumentHdrCZP.Get(PostedCashDocumentLineCZP."Cash Desk No.", PostedCashDocumentLineCZP."Cash Document No.") then
            exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnCheckAndUpdateOnAfterSetPostingFlags', '', false, false)]
    local procedure CheckCashDocumentActionOnCheckAndUpdateOnAfterSetPostingFlags(var PurchHeader: Record "Purchase Header")
    begin
        if not PurchHeader.Invoice then
            exit;
        if PurchHeader."Cash Document Action CZP".AsInteger() > PurchHeader."Cash Document Action CZP"::" ".AsInteger() then
            CashDeskManagementCZP.CheckUserRights(PurchHeader."Cash Desk Code CZP", PurchHeader."Cash Document Action CZP"::Create);
        if (PurchHeader."Cash Document Action CZP" = PurchHeader."Cash Document Action CZP"::Release) or
           (PurchHeader."Cash Document Action CZP" = PurchHeader."Cash Document Action CZP"::"Release and Print")
        then
            CashDeskManagementCZP.CheckUserRights(PurchHeader."Cash Desk Code CZP", PurchHeader."Cash Document Action CZP");
        if (PurchHeader."Cash Document Action CZP" = PurchHeader."Cash Document Action CZP"::Post) or
           (PurchHeader."Cash Document Action CZP" = PurchHeader."Cash Document Action CZP"::"Post and Print")
        then begin
            CashDeskManagementCZP.CheckUserRights(PurchHeader."Cash Desk Code CZP", PurchHeader."Cash Document Action CZP"::Release);
            CashDeskManagementCZP.CheckUserRights(PurchHeader."Cash Desk Code CZP", PurchHeader."Cash Document Action CZP");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure CreateCashDocumentOnAfterFinalizePostingOnBeforeCommit(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        if (PurchHeader."Cash Desk Code CZP" = '') or not PurchHeader.Invoice then
            exit;

        OnBeforeCreateCashDocument(PurchHeader, PurchInvHeader, PurchCrMemoHdr, GenJnlPostLine);
        if PurchHeader."Document Type" in [PurchHeader."Document Type"::Order, PurchHeader."Document Type"::Invoice] then
            CashDeskManagementCZP.CreateCashDocumentFromPurchaseInvoice(PurchInvHeader)
        else
            CashDeskManagementCZP.CreateCashDocumentFromPurchaseCrMemo(PurchCrMemoHdr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateCashDocument(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;
}
