// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;

codeunit 11734 "Purch. Inv. Header - Edit CZZ"
{
    Access = Internal;
    Permissions = tabledata "Vendor Ledger Entry" = r,
                  tabledata "Purch. Adv. Letter Entry CZZ" = rm;

    var
        RecursionDepth: Integer;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Inv. Header - Edit", 'OnRunOnAfterPurchInvHeaderEdit', '', false, false)]
    local procedure UpdateRelatedEntriesOnRunOnAfterPurchInvHeaderEdit(var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        UpdateRelatedVendorLedgerEntries(PurchInvHeader);
    end;

    local procedure UpdateRelatedVendorLedgerEntries(PurchInvHeader: Record "Purch. Inv. Header")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.ReadIsolation(IsolationLevel::UpdLock);
        VendorLedgerEntry.SetCurrentKey("Document No.");
        VendorLedgerEntry.SetRange("Document No.", PurchInvHeader."No.");
        VendorLedgerEntry.SetFilter("External Document No.", '<>%1', PurchInvHeader."Vendor Invoice No.");
        VendorLedgerEntry.SetFilter("Entry No.", '<>%1', PurchInvHeader."Vendor Ledger Entry No.");
        if VendorLedgerEntry.FindSet() then
            repeat
                VendorLedgerEntry."External Document No." := PurchInvHeader."Vendor Invoice No.";
                Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry);
                if VendorLedgerEntry."Advance Letter No. CZZ" <> '' then
                    UpdateAdvanceLetterEntries(VendorLedgerEntry);
            until VendorLedgerEntry.Next() = 0;
    end;

    local procedure UpdateAdvanceLetterEntries(VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        PurchAdvLetterEntryCZZ.ReadIsolation(IsolationLevel::UpdLock);
        PurchAdvLetterEntryCZZ.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
        PurchAdvLetterEntryCZZ.SetLoadFields("External Document No.");
        if PurchAdvLetterEntryCZZ.FindSet() then
            repeat
                PurchAdvLetterEntryCZZ."External Document No." := VendorLedgerEntry."External Document No.";
                PurchAdvLetterEntryCZZ.Modify(false);
                UpdateRelatedAdvanceLetterEntries(PurchAdvLetterEntryCZZ);
            until PurchAdvLetterEntryCZZ.Next() = 0;
    end;

    local procedure UpdateRelatedAdvanceLetterEntries(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        RelatedPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        if RecursionDepth > 10 then
            exit;
        RecursionDepth += 1;
        RelatedPurchAdvLetterEntryCZZ.ReadIsolation(IsolationLevel::UpdLock);
        RelatedPurchAdvLetterEntryCZZ.SetCurrentKey("Related Entry");
        RelatedPurchAdvLetterEntryCZZ.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        RelatedPurchAdvLetterEntryCZZ.SetLoadFields("External Document No.");
        if RelatedPurchAdvLetterEntryCZZ.FindSet() then
            repeat
                RelatedPurchAdvLetterEntryCZZ."External Document No." := PurchAdvLetterEntryCZZ."External Document No.";
                RelatedPurchAdvLetterEntryCZZ.Modify(false);
                UpdateRelatedAdvanceLetterEntries(RelatedPurchAdvLetterEntryCZZ);
            until RelatedPurchAdvLetterEntryCZZ.Next() = 0;
        RecursionDepth -= 1;
    end;
}