// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Payables;
using System.Security.User;

codeunit 31061 "Vend. Entry-Edit Handler CZZ"
{
    Permissions = TableData "Purch. Adv. Letter Entry CZZ" = rm;

    var
        RecursionDepth: Integer;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure VendEntryEditOnBeforeVendLedgEntryModify(FromVendLedgEntry: Record "Vendor Ledger Entry"; var VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        VendLedgEntry."Adv. Letter Template Code CZZ" := FromVendLedgEntry."Adv. Letter Template Code CZZ";
        VendLedgEntry."Advance Letter No. CZZ" := FromVendLedgEntry."Advance Letter No. CZZ";
        VendLedgEntry.Prepayment := FromVendLedgEntry.Prepayment;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnRunOnAfterVendLedgEntryMofidy', '', false, false)]
    local procedure UpdateRelatedEntriesOnRunOnAfterVendLedgEntryMofidy(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        if not IsExtDocNoChangingAllowed() then
            exit;
        if VendorLedgerEntry."Advance Letter No. CZZ" <> '' then
            UpdateAdvanceLetterEntries(VendorLedgerEntry);
        if VendorLedgerEntry."Adv. Letter Template Code CZZ" <> '' then
            Codeunit.Run(Codeunit::"Update Rel.Vend.Ledg.Entry CZZ", VendorLedgerEntry);
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

    local procedure IsExtDocNoChangingAllowed(): Boolean
    var
        UserSetupAdvManagement: Codeunit "User Setup Adv. Management CZL";
    begin
        exit(UserSetupAdvManagement.IsExtDocNoChangingAllowed());
    end;
}
