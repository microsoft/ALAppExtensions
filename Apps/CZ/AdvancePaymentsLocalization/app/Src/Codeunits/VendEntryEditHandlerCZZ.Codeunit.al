// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Payables;

codeunit 31061 "Vend. Entry-Edit Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure VendEntryEditOnBeforeVendLedgEntryModify(FromVendLedgEntry: Record "Vendor Ledger Entry"; var VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        VendLedgEntry."Adv. Letter Template Code CZZ" := FromVendLedgEntry."Adv. Letter Template Code CZZ";
        VendLedgEntry."Advance Letter No. CZZ" := FromVendLedgEntry."Advance Letter No. CZZ";
        VendLedgEntry.Prepayment := FromVendLedgEntry.Prepayment;
    end;
}
