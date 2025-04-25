// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Common;

using Microsoft.Purchases.Setup;

codeunit 5146 "Create Common Purchase Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Purchases & Payables Setup" = rm;

    trigger OnRun()
    var
        PurchasePayablesSetup: Record "Purchases & Payables Setup";
        CommonNoSeries: Codeunit "Create Common No Series";
    begin
        PurchasePayablesSetup.Get();

        if PurchasePayablesSetup."Vendor Nos." = '' then
            PurchasePayablesSetup.Validate("Vendor Nos.", CommonNoSeries.Vendor());

        if PurchasePayablesSetup."Order Nos." = '' then
            PurchasePayablesSetup.Validate("Order Nos.", CommonNoSeries.PurchaseOrder());

        if PurchasePayablesSetup."Invoice Nos." = '' then
            PurchasePayablesSetup.Validate("Invoice Nos.", CommonNoSeries.PurchaseInvoice());

        if PurchasePayablesSetup."Posted Receipt Nos." = '' then
            PurchasePayablesSetup.Validate("Posted Receipt Nos.", CommonNoSeries.PostedReceipt());

        if PurchasePayablesSetup."Posted Invoice Nos." = '' then
            PurchasePayablesSetup.Validate("Posted Invoice Nos.", CommonNoSeries.PostedPurchaseInvoice());

        PurchasePayablesSetup.Modify();
    end;
}
