// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.FinancialReports;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31432 "Acc. Sched. Ext. Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Acc. Sched. Extension Mgt. CZL", 'OnAfterSetCustLedgEntryFilters', '', false, false)]
    local procedure SetFiltersOnAfterSetCustLedgEntryFilters(AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        case AccScheduleExtensionCZL."Advance Payments CZZ" of
            AccScheduleExtensionCZL."Advance Payments CZZ"::Yes:
                CustLedgerEntry.SetFilter("Advance Letter No. CZZ", '<>%1', '');
            AccScheduleExtensionCZL."Advance Payments CZZ"::No:
                CustLedgerEntry.SetRange("Advance Letter No. CZZ", '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Acc. Sched. Extension Mgt. CZL", 'OnAfterSetVendLedgEntryFilters', '', false, false)]
    local procedure SetFiltersOnAfterSetVendLedgEntryFilters(AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL"; var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        case AccScheduleExtensionCZL."Advance Payments CZZ" of
            AccScheduleExtensionCZL."Advance Payments CZZ"::Yes:
                VendorLedgerEntry.SetFilter("Advance Letter No. CZZ", '<>%1', '');
            AccScheduleExtensionCZL."Advance Payments CZZ"::No:
                VendorLedgerEntry.SetRange("Advance Letter No. CZZ", '');
        end;
    end;
}
