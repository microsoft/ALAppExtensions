// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

codeunit 30205 "Shpfy GQL OpenOrdersToImport" implements "Shpfy IGraphQL"
{
    Access = Internal;

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{orders(first:25, query: \"status:open updated_at:>''{{Time}}''\"){ pageInfo { hasNextPage } edges { cursor node { legacyResourceId name createdAt updatedAt channel { name } test fullyPaid unpaid displayFinancialStatus displayFulfillmentStatus subtotalLineItemsQuantity totalPriceSet { shopMoney { amount currencyCode } } customAttributes { key value } tags risk { assessments { riskLevel }} displayAddress { countryCodeV2 } shippingAddress { countryCodeV2 } billingAddress { countryCodeV2 } totalTaxSet { presentmentMoney { amount } shopMoney { amount } } purchasingEntity { ... on PurchasingCompany { company { id }}}}}}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(152);
    end;
}