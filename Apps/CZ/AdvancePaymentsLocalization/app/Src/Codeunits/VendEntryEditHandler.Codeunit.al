codeunit 31061 "Vend. Entry-Edit Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure VendEntryEditOnBeforeVendLedgEntryModify(FromVendLedgEntry: Record "Vendor Ledger Entry"; var VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        VendLedgEntry."Adv. Letter Template Code CZZ" := FromVendLedgEntry."Adv. Letter Template Code CZZ";
        VendLedgEntry."Advance Letter No. CZZ" := FromVendLedgEntry."Advance Letter No. CZZ";
        VendLedgEntry.Prepayment := FromVendLedgEntry.Prepayment;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure RemoveAdvTemplateCodeOnBeforeCustLedgEntryModify(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        VendorLedgerEntry."Adv. Letter Template Code CZZ" := '';
    end;
}