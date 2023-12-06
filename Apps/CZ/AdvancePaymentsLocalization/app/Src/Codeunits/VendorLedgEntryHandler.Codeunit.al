// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Payables;

codeunit 31021 "Vendor Ledg. Entry Handler CZZ"
{
    var
        AppliedToAdvanceLetterErr: Label 'The entry is applied to advance letter and cannot be used to applying or unapplying.';

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure VendorLedgerEntryOnAfterCopyVendLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VendorLedgerEntry."Advance Letter No. CZZ" := GenJournalLine."Adv. Letter No. (Entry) CZZ";
        VendorLedgerEntry."Adv. Letter Template Code CZZ" := GenJournalLine."Adv. Letter Template Code CZZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnIsRelatedToAdvanceLetterCZL', '', false, false)]
    local procedure GetOnIsRelatedToAdvanceLetterCZL(VendorLedgerEntry: Record "Vendor Ledger Entry"; var IsRelatedToAdvanceLetter: Boolean)
    begin
        IsRelatedToAdvanceLetter := IsRelatedToAdvanceLetter or (VendorLedgerEntry."Advance Letter No. CZZ" <> '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnBeforeGetPayablesAccountNoCZL', '', false, false)]
    local procedure GetPayablesAccountNo(VendorLedgerEntry: Record "Vendor Ledger Entry"; var GLAccountNo: Code[20]; var IsHandled: Boolean)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
    begin
        if VendorLedgerEntry."Advance Letter No. CZZ" = '' then
            exit;

        PurchAdvLetterHeaderCZZ.Get(VendorLedgerEntry."Advance Letter No. CZZ");
        PurchAdvLetterHeaderCZZ.TestField("Advance Letter Code");
        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Purchase);
        AdvanceLetterTemplateCZZ.TestField("Advance Letter G/L Account");
        GLAccountNo := AdvanceLetterTemplateCZZ."Advance Letter G/L Account";
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnApplyVendEntryFormEntryOnAfterCheckEntryOpen', '', false, false)]
    local procedure CheckAdvanceOnApplyVendEntryFormEntryOnAfterCheckEntryOpen(ApplyingVendLedgEntry: Record "Vendor Ledger Entry")
    begin
        if ApplyingVendLedgEntry."Advance Letter No. CZZ" <> '' then
            Error(AppliedToAdvanceLetterErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnPostUnApplyVendorOnAfterGetVendLedgEntry', '', false, false)]
    local procedure CheckAdvanceOnPostUnApplyVendorOnAfterGetVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        if (VendorLedgerEntry."Advance Letter No. CZZ" <> '') or
           (VendorLedgerEntry."Adv. Letter Template Code CZZ" <> '')
        then
            Error(AppliedToAdvanceLetterErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnBeforeUnApplyVendor', '', false, false)]
    local procedure CheckAdvanceOnBeforeUnApplyVendor(DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.Get(DtldVendLedgEntry."Vendor Ledger Entry No.");
        if (VendorLedgerEntry."Advance Letter No. CZZ" <> '') or
           (VendorLedgerEntry."Adv. Letter Template Code CZZ" <> '')
        then
            Error(AppliedToAdvanceLetterErr);
    end;
}
