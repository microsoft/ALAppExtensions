namespace Microsoft.Purchases.Payables;

using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.GeneralLedger.Ledger;

codeunit 31135 "Vend. Entry-Edit Handler CZL"
{
    Access = Internal;

    var
        VATEntryInVATCtrlReportErr: Label 'The VAT Entries are already included in the VAT Control Report.';
        VATEntryClosedErr: Label 'The VAT Entries are already closed.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure UpdateEntryOnBeforeVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry"; FromVendLedgEntry: Record "Vendor Ledger Entry")
    begin
        if VendLedgEntry."External Document No." <> FromVendLedgEntry."External Document No." then
            CheckVATEntries(VendLedgEntry);

        VendLedgEntry."Specific Symbol CZL" := FromVendLedgEntry."Specific Symbol CZL";
        VendLedgEntry."Variable Symbol CZL" := FromVendLedgEntry."Variable Symbol CZL";
        VendLedgEntry."Constant Symbol CZL" := FromVendLedgEntry."Constant Symbol CZL";
        VendLedgEntry."Bank Account Code CZL" := FromVendLedgEntry."Bank Account Code CZL";
        VendLedgEntry."Bank Account No. CZL" := FromVendLedgEntry."Bank Account No. CZL";
        VendLedgEntry."Transit No. CZL" := FromVendLedgEntry."Transit No. CZL";
        VendLedgEntry."IBAN CZL" := FromVendLedgEntry."IBAN CZL";
        VendLedgEntry."SWIFT Code CZL" := FromVendLedgEntry."SWIFT Code CZL";
        VendLedgEntry."VAT Date CZL" := FromVendLedgEntry."VAT Date CZL";
        VendLedgEntry."External Document No." := FromVendLedgEntry."External Document No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnRunOnAfterVendLedgEntryMofidy', '', false, false)]
    local procedure UpdateEntriesOnRunOnAfterVendLedgEntryMofidy(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        UpdateVATEntries(VendorLedgerEntry);
        UpdateGLEntries(VendorLedgerEntry);
    end;

    local procedure CheckVATEntries(VendLedgEntry: Record "Vendor Ledger Entry")
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document No.", VendLedgEntry."Document No.");
        VATEntry.SetRange("Posting Date", VendLedgEntry."Posting Date");
        VATEntry.SetFilter("VAT Ctrl. Report No. CZL", '<>%1', '');
        if not VATEntry.IsEmpty() then
            Error(VATEntryInVATCtrlReportErr);

        VATEntry.SetRange("VAT Ctrl. Report No. CZL");
        VATEntry.SetRange(Closed, true);
        if not VATEntry.IsEmpty() then
            Error(VATEntryClosedErr);
    end;

    local procedure UpdateVATEntries(VendLedgEntry: Record "Vendor Ledger Entry")
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document No.", VendLedgEntry."Document No.");
        VATEntry.SetRange("Posting Date", VendLedgEntry."Posting Date");
        VATEntry.SetRange(Closed, false);
        VATEntry.SetRange("VAT Ctrl. Report No. CZL", '');
        VATEntry.SetFilter("External Document No.", '<>%1', VendLedgEntry."External Document No.");
        if VATEntry.FindSet() then
            repeat
                VATEntry."External Document No." := VendLedgEntry."External Document No.";
                Codeunit.Run(Codeunit::"VAT Entry - Edit", VATEntry);
            until VATEntry.Next() = 0;
    end;

    local procedure UpdateGLEntries(VendLedgEntry: Record "Vendor Ledger Entry")
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Document No.", VendLedgEntry."Document No.");
        GLEntry.SetRange("Posting Date", VendLedgEntry."Posting Date");
        GLEntry.SetFilter("External Document No.", '<>%1', VendLedgEntry."External Document No.");
        if GLEntry.FindSet() then
            repeat
                GLEntry."External Document No." := VendLedgEntry."External Document No.";
                Codeunit.Run(Codeunit::"G/L Entry-Edit", GLEntry);
            until GLEntry.Next() = 0;
    end;
}