namespace Microsoft.Purchases.Payables;

codeunit 31135 "Vend. Entry-Edit Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure UpdateEntryOnBeforeVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry"; FromVendLedgEntry: Record "Vendor Ledger Entry")
    begin
        VendLedgEntry."Specific Symbol CZL" := FromVendLedgEntry."Specific Symbol CZL";
        VendLedgEntry."Variable Symbol CZL" := FromVendLedgEntry."Variable Symbol CZL";
        VendLedgEntry."Constant Symbol CZL" := FromVendLedgEntry."Constant Symbol CZL";
        VendLedgEntry."Bank Account Code CZL" := FromVendLedgEntry."Bank Account Code CZL";
        VendLedgEntry."Bank Account No. CZL" := FromVendLedgEntry."Bank Account No. CZL";
        VendLedgEntry."Transit No. CZL" := FromVendLedgEntry."Transit No. CZL";
        VendLedgEntry."IBAN CZL" := FromVendLedgEntry."IBAN CZL";
        VendLedgEntry."SWIFT Code CZL" := FromVendLedgEntry."SWIFT Code CZL";
        VendLedgEntry."VAT Date CZL" := FromVendLedgEntry."VAT Date CZL";
    end;
}