// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL InventoryActivate (ID 30381) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30381 "Shpfy GQL InventoryActivate" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"mutation inventoryBulkToggleActivation($inventoryItemId: ID!, $inventoryItemUpdates: [InventoryBulkToggleActivationInput!]!) { inventoryBulkToggleActivation(inventoryItemId: $inventoryItemId, inventoryItemUpdates: $inventoryItemUpdates) {userErrors { field message }}}","variables":{"inventoryItemId": "gid://shopify/InventoryItem/{{InventoryItemId}}","inventoryItemUpdates": []}}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(10);
    end;

}
