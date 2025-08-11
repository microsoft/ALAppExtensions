// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

interface "Shpfy Extended Stock Calculation" extends "Shpfy Stock Calculation"
{
    procedure GetStock(var Item: Record Item; var ShopLocation: Record "Shpfy Shop Location"): Decimal;
}