// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Purchase;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GST.Base;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;

codeunit 18082 "GST Vendor Ledger Entry"
{

    local procedure IsReverseCharge(PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if PurchaseHeader."GST Vendor Type" in ["GST Vendor Type"::Unregistered, "GST Vendor Type"::Import] then
            exit(true);

        if PurchaseHeader."GST Vendor Type" in ["GST Vendor Type"::Registered, "GST Vendor Type"::Unregistered, "GST Vendor Type"::SEZ] then begin
            PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchaseLine.SetFilter(Quantity, '<>%1', 0);
            PurchaseLine.SetRange("Non-GST Line", false);
            PurchaseLine.SetRange("GST Reverse Charge", true);
            if PurchaseLine.Count() <> 0 then
                exit(true);

        end;

        if PurchaseHeader."GST Vendor Type" = "GST Vendor Type"::SEZ then begin
            PurchaseLine.Reset();
            PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchaseLine.SetFilter(Quantity, '<>%1', 0);
            PurchaseLine.SetFilter("GST Group Code", '<>%1', '');
            PurchaseLine.SetRange("GST Group Type", PurchaseLine."GST Group Type"::Goods);
            if PurchaseLine.Count() <> 0 then
                exit(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure CopyInfortoVendorEntryOnPostLedgerEntryOnBeforeGenJnlPostLine(var PurchHeader: Record "Purchase Header"; var GenJnlLine: Record "Gen. Journal Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        GenJnlLine."Location Code" := PurchHeader."Location Code";
        GenJnlLine."GST Input Service Distribution" := PurchHeader."GST Input Service Distribution";
        GenJnlLine."GST Reverse Charge" := IsReverseCharge(PurchHeader);
        GenJnlLine."GST Vendor Type" := PurchHeader."GST Vendor Type";
        GenJnlLine."RCM Exempt" := PurchHeader."RCM Exempt";
        GenJnlLine."Location State Code" := PurchHeader."Location State Code";
        GenJnlLine."Location GST Reg. No." := PurchHeader."Location GST Reg. No.";
        if PurchHeader."Order Address Code" <> '' then begin
            GenJnlLine."Order Address Code" := PurchHeader."Order Address Code";
            GenJnlLine."Order Address State Code" := PurchHeader."GST Order Address State";
            GenJnlLine."Order Address GST Reg. No." := PurchHeader."Order Address GST Reg. No.";
        end else begin
            GenJnlLine."GST Bill-to/BuyFrom State Code" := PurchHeader.State;
            GenJnlLine."Vendor GST Reg. No." := PurchHeader."Vendor GST Reg. No.";
        end;

        PurchaseLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchHeader."No.");
        PurchaseLine.SetFilter(Type, '<>%1', PurchaseLine.Type::" ");
        PurchaseLine.SetFilter(Quantity, '<>%1', 0);
        if PurchaseLine.FindFirst() then
            GenJnlLine."GST Jurisdiction Type" := PurchaseLine."GST Jurisdiction Type";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitVendLedgEntry', '', false, false)]
    local procedure copyinfotovendorledgerentry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VendorLedgerEntry."GST Reverse Charge" := GenJournalLine."GST Reverse Charge";
        VendorLedgerEntry."Location Code" := GenJournalLine."Location Code";
        VendorLedgerEntry."GST Input Service Distribution" := GenJournalLine."GST Input Service Distribution";
        if GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Payment, GenJournalLine."Document Type"::Refund] then
            if (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Payment) and GenJournalLine."GST on Advance Payment" then begin
                VendorLedgerEntry."HSN/SAC Code" := GenJournalLine."HSN/SAC Code";
                VendorLedgerEntry."GST Group Code" := GenJournalLine."GST Group Code";
                VendorLedgerEntry."GST on Advance Payment" := GenJournalLine."GST on Advance Payment";
            end else
                if (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Refund) and (GenJournalLine."Applies-to Doc. No." <> '') then begin
                    VendorLedgerEntry.SetCurrentKey("Vendor No.", "Document Type", "Document No.", "GST Reverse Charge", "GST on Advance Payment");
                    VendorLedgerEntry.SetRange("Vendor No.", GenJournalLine."Account No.");
                    VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);
                    VendorLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
                    VendorLedgerEntry.SetRange("GST on Advance Payment", true);
                    VendorLedgerEntry.SetRange("HSN/SAC Code", GenJournalLine."HSN/SAC Code");
                    if not VendorLedgerEntry.IsEmpty() then begin
                        VendorLedgerEntry."HSN/SAC Code" := GenJournalLine."HSN/SAC Code";
                        VendorLedgerEntry."GST Group Code" := GenJournalLine."GST Group Code";
                    end;
                end;

        VendorLedgerEntry."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type";
        VendorLedgerEntry."Location State Code" := GenJournalLine."Location State Code";
        VendorLedgerEntry."RCM Exempt" := GenJournalLine."RCM Exempt";
        if GenJournalLine."Order Address Code" <> '' then begin
            VendorLedgerEntry."Buyer State Code" := GenJournalLine."Order Address State Code";
            VendorLedgerEntry."Buyer GST Reg. No." := GenJournalLine."Order Address GST Reg. No.";
        end else begin
            VendorLedgerEntry."Buyer State Code" := GenJournalLine."GST Bill-to/BuyFrom State Code";
            VendorLedgerEntry."Buyer GST Reg. No." := GenJournalLine."Vendor GST Reg. No.";
        end;

        VendorLedgerEntry."GST Vendor Type" := GenJournalLine."GST Vendor Type";
        VendorLedgerEntry."Location GST Reg. No." := GenJournalLine."Location GST Reg. No.";
        if VendorLedgerEntry."GST Vendor Type" in ["GST Vendor Type"::Import, "GST Vendor Type"::Unregistered, "GST Vendor Type"::SEZ] then
            if not (GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Payment, GenJournalLine."Document Type"::Refund]) then
                VendorLedgerEntry."GST Reverse Charge" := true
            else
                if VendorLedgerEntry."GST Vendor Type" = "GST Vendor Type"::Unregistered then
                    VendorLedgerEntry."GST Reverse Charge" := true
                else
                    VendorLedgerEntry."GST Reverse Charge" := GenJournalLine."GST Group Type" = GenJournalLine."GST Group Type"::Service;
    end;
}
