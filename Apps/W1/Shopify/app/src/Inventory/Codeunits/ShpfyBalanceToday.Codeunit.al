// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Availability;

codeunit 30212 "Shpfy Balance Today" implements "Shpfy Stock Calculation"
{
    procedure GetStock(var Item: Record Item): decimal;
    var
        ItemAvailabilityFormsMgt: codeunit "Item Availability Forms Mgt";
        GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable : decimal;
    begin
        ItemAvailabilityFormsMgt.CalcAvailQuantities(Item, true, GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable);
        exit(ProjAvailableBalance);
    end;
}

