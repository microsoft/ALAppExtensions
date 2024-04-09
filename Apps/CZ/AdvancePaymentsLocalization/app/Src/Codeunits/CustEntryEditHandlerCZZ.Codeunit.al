// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Receivables;

codeunit 31062 "Cust. Entry-Edit Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust. Entry-Edit", 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure CustEntryEditOnBeforeCustLedgEntryModify(FromCustLedgEntry: Record "Cust. Ledger Entry"; var CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgEntry."Adv. Letter Template Code CZZ" := FromCustLedgEntry."Adv. Letter Template Code CZZ";
        CustLedgEntry."Advance Letter No. CZZ" := FromCustLedgEntry."Advance Letter No. CZZ";
        CustLedgEntry.Prepayment := FromCustLedgEntry.Prepayment;
    end;
}
