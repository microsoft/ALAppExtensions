// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

codeunit 30102 "Shpfy GQL Modify Inventory" implements "Shpfy IGraphQL"
{
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"mutation inventorySetOnHandQuantities($input:InventorySetOnHandQuantitiesInput!) { inventorySetOnHandQuantities(input: $input) { userErrors { field message }}}","variables":{"input":{"reason":"correction","setQuantities":[]}}}');
    end;

    procedure GetExpectedCost(): Integer
    begin
        exit(10);
    end;
}