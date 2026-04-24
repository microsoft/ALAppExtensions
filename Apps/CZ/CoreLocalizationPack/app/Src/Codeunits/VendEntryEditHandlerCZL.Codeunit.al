namespace Microsoft.Purchases.Payables;

codeunit 31135 "Vend. Entry-Edit Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure UpdateEntryOnBeforeVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry"; FromVendLedgEntry: Record "Vendor Ledger Entry")
    begin
        VendLedgEntry.Validate("Specific Symbol CZL", FromVendLedgEntry."Specific Symbol CZL");
        VendLedgEntry.Validate("Variable Symbol CZL", FromVendLedgEntry."Variable Symbol CZL");
        VendLedgEntry.Validate("Constant Symbol CZL", FromVendLedgEntry."Constant Symbol CZL");
        VendLedgEntry.Validate("Bank Account Code CZL", FromVendLedgEntry."Bank Account Code CZL");
        VendLedgEntry.Validate("Bank Account No. CZL", FromVendLedgEntry."Bank Account No. CZL");
        VendLedgEntry.Validate("Transit No. CZL", FromVendLedgEntry."Transit No. CZL");
        VendLedgEntry.Validate("IBAN CZL", FromVendLedgEntry."IBAN CZL");
        VendLedgEntry.Validate("SWIFT Code CZL", FromVendLedgEntry."SWIFT Code CZL");
        VendLedgEntry.Validate("VAT Date CZL", FromVendLedgEntry."VAT Date CZL");
        VendLedgEntry.Validate("External Document No.", FromVendLedgEntry."External Document No.");
    end;
}