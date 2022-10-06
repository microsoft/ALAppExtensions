codeunit 31062 "Cust. Entry-Edit Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust. Entry-Edit", 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure CustEntryEditOnBeforeCustLedgEntryModify(FromCustLedgEntry: Record "Cust. Ledger Entry"; var CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgEntry."Adv. Letter Template Code CZZ" := FromCustLedgEntry."Adv. Letter Template Code CZZ";
        CustLedgEntry."Advance Letter No. CZZ" := FromCustLedgEntry."Advance Letter No. CZZ";
        CustLedgEntry.Prepayment := FromCustLedgEntry.Prepayment;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure RemoveAdvTemplateCodeOnBeforeCustLedgEntryModify(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry."Adv. Letter Template Code CZZ" := '';
    end;
}