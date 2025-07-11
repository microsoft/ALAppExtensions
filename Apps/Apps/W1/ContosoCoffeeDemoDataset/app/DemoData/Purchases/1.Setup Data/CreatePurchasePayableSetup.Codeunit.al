// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;
using Microsoft.Purchases.Document;
using Microsoft.Pricing.Calculation;

codeunit 5272 "Create Purchase Payable Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPurchase: Codeunit "Contoso Purchase";
        CreateNoSeries: Codeunit "Create No. Series";
        CreateJobQueueCategory: Codeunit "Create Job Queue Category";
    begin
        ContosoPurchase.InsertPurchasePayableSetup(3, true, true, true, CreateNoSeries.Vendor(), CreateNoSeries.PurchaseQuote(), CreateNoSeries.PurchaseOrder(), CreateNoSeries.PurchaseInvoice(), CreateNoSeries.PostedPurchaseInvoice(), CreateNoSeries.PurchaseCreditMemo(), CreateNoSeries.PostedPurchaseCreditMemo(), CreateNoSeries.PurchaseReceipt(), CreateNoSeries.BlanketPurchaseOrder(), 2, true, true, true, CreateJobQueueCategory.SalesPurchasePosting(), 1000, 1000, Enum::"Purchase Line Type"::Item, true, CreateNoSeries.PostedPurchaseShipment(), true, true, CreateNoSeries.PurchaseReturnOrder(), Enum::"Price Calculation Method"::"Lowest Price", CreateNoSeries.PurchasePriceList());
    end;
}
