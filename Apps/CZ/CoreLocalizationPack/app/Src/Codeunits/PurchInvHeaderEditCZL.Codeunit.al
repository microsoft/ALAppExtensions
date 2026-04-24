// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Purchases.Payables;

codeunit 11759 "Purch. Inv. Header - Edit CZL"
{
    Access = Internal;
    Permissions = TableData "VAT Entry" = r,
                  TableData "G/L Entry" = r,
                  TableData "Purch. Inv. Header" = r;

    var
        VATEntryInVATCtrlReportErr: Label 'The VAT Entries are already included in the VAT Control Report.';
        VATEntryClosedErr: Label 'The VAT Entries are already closed.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Inv. Header - Edit", 'OnBeforePurchInvHeaderModify', '', false, false)]
    local procedure PurchInvoiceEditOnBeforePurchInvHeaderModify(var PurchInvHeader: Record "Purch. Inv. Header"; PurchInvHeaderRec: Record "Purch. Inv. Header")
    begin
        if PurchInvHeader."Vendor Invoice No." <> PurchInvHeaderRec."Vendor Invoice No." then begin
            CheckRelatedVATEntries(PurchInvHeader);
            PurchInvHeaderRec.CheckAndConfirmExternalDocumentNumber();
        end;

        PurchInvHeader.Validate("Due Date", PurchInvHeaderRec."Due Date");
        PurchInvHeader.Validate("Bank Account Code CZL", PurchInvHeaderRec."Bank Account Code CZL");
        PurchInvHeader.Validate("Specific Symbol CZL", PurchInvHeaderRec."Specific Symbol CZL");
        PurchInvHeader.Validate("Variable Symbol CZL", PurchInvHeaderRec."Variable Symbol CZL");
        PurchInvHeader.Validate("Constant Symbol CZL", PurchInvHeaderRec."Constant Symbol CZL");
        PurchInvHeader.Validate("Vendor Invoice No.", PurchInvHeaderRec."Vendor Invoice No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Inv. Header - Edit", 'OnBeforeUpdateVendorLedgerEntryAfterSetValues', '', false, false)]
    local procedure PurchInvoiceEditOnBeforeUpdateVendorLedgerEntryAfterSetValues(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PurchInvHeader: Record "Purch. Inv. Header")
    begin
        VendorLedgerEntry."Due Date" := PurchInvHeader."Due Date";
        VendorLedgerEntry.Validate("Bank Account Code CZL", PurchInvHeader."Bank Account Code CZL");
        VendorLedgerEntry.Validate("Bank Account No. CZL", PurchInvHeader."Bank Account No. CZL");
        VendorLedgerEntry.Validate("Transit No. CZL", PurchInvHeader."Transit No. CZL");
        VendorLedgerEntry.Validate("IBAN CZL", PurchInvHeader."IBAN CZL");
        VendorLedgerEntry.Validate("SWIFT Code CZL", PurchInvHeader."SWIFT Code CZL");
        VendorLedgerEntry.Validate("Specific Symbol CZL", PurchInvHeader."Specific Symbol CZL");
        VendorLedgerEntry.Validate("Variable Symbol CZL", PurchInvHeader."Variable Symbol CZL");
        VendorLedgerEntry.Validate("Constant Symbol CZL", PurchInvHeader."Constant Symbol CZL");
        VendorLedgerEntry.Validate("External Document No.", PurchInvHeader."Vendor Invoice No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Inv. Header - Edit", 'OnRunOnAfterPurchInvHeaderEdit', '', false, false)]
    local procedure UpdateRelatedEntriesOnRunOnAfterPurchInvHeaderEdit(var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        UpdateRelatedVATEntries(PurchInvHeader);
        UpdateRelatedGLEntries(PurchInvHeader);
    end;

    local procedure CheckRelatedVATEntries(PurchInvHeader: Record "Purch. Inv. Header")
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document No.", PurchInvHeader."No.");
        VATEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
        VATEntry.SetFilter("VAT Ctrl. Report No. CZL", '<>%1', '');
        if not VATEntry.IsEmpty() then
            Error(VATEntryInVATCtrlReportErr);

        VATEntry.SetRange("VAT Ctrl. Report No. CZL");
        VATEntry.SetRange(Closed, true);
        if not VATEntry.IsEmpty() then
            Error(VATEntryClosedErr);
    end;

    local procedure UpdateRelatedVATEntries(PurchInvHeader: Record "Purch. Inv. Header")
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document No.", PurchInvHeader."No.");
        VATEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
        VATEntry.SetRange(Closed, false);
        VATEntry.SetRange("VAT Ctrl. Report No. CZL", '');
        VATEntry.SetFilter("External Document No.", '<>%1', PurchInvHeader."Vendor Invoice No.");
        if VATEntry.FindSet() then
            repeat
                VATEntry."External Document No." := PurchInvHeader."Vendor Invoice No.";
                Codeunit.Run(Codeunit::"VAT Entry - Edit", VATEntry);
            until VATEntry.Next() = 0;
    end;

    local procedure UpdateRelatedGLEntries(PurchInvHeader: Record "Purch. Inv. Header")
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Document No.", PurchInvHeader."No.");
        GLEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
        GLEntry.SetFilter("External Document No.", '<>%1', PurchInvHeader."Vendor Invoice No.");
        if GLEntry.FindSet() then
            repeat
                GLEntry."External Document No." := PurchInvHeader."Vendor Invoice No.";
                Codeunit.Run(Codeunit::"G/L Entry-Edit", GLEntry);
            until GLEntry.Next() = 0;
    end;
}