codeunit 31062 "Cust. Entry-Edit Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust. Entry-Edit", 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure VendEntryEditOnBeforeCustLedgEntryModify(FromCustLedgEntry: Record "Cust. Ledger Entry"; var CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgEntry."Advance Letter No. CZZ" := FromCustLedgEntry."Advance Letter No. CZZ";
        CustLedgEntry.Prepayment := FromCustLedgEntry.Prepayment;
    end;
}