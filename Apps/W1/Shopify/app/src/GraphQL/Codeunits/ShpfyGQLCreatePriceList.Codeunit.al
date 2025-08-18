// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL CreatePriceList (ID 30308) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30308 "Shpfy GQL CreatePriceList" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { priceListCreate(input: {name: \"{{Name}}\", currency: {{Currency}}, catalogId: \"gid://shopify/CompanyLocationCatalog/{{CatalogId}}\", parent: {adjustment: {type: PERCENTAGE_DECREASE, value: 0}, settings: {compareAtMode: NULLIFY}}}) { priceList {id}, userErrors {field, message}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(10);
    end;
}