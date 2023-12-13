namespace Microsoft.Sales.Receivables;

codeunit 31133 "Cust. Entry-Edit Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust. Entry-Edit", 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure UpdateEntryOnBeforeCustLedgEntryModify(var CustLedgEntry: Record "Cust. Ledger Entry"; FromCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgEntry."Specific Symbol CZL" := FromCustLedgEntry."Specific Symbol CZL";
        CustLedgEntry."Variable Symbol CZL" := FromCustLedgEntry."Variable Symbol CZL";
        CustLedgEntry."Constant Symbol CZL" := FromCustLedgEntry."Constant Symbol CZL";
        CustLedgEntry."Bank Account Code CZL" := FromCustLedgEntry."Bank Account Code CZL";
        CustLedgEntry."Bank Account No. CZL" := FromCustLedgEntry."Bank Account No. CZL";
        CustLedgEntry."Transit No. CZL" := FromCustLedgEntry."Transit No. CZL";
        CustLedgEntry."IBAN CZL" := FromCustLedgEntry."IBAN CZL";
        CustLedgEntry."SWIFT Code CZL" := FromCustLedgEntry."SWIFT Code CZL";
        CustLedgEntry."VAT Date CZL" := FromCustLedgEntry."VAT Date CZL";
    end;
}