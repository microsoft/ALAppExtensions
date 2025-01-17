namespace Microsoft.Integration.Shopify;

codeunit 30205 "Shpfy GQL OpenOrdersToImport" implements "Shpfy IGraphQL"
{
    Access = Internal;

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{orders(first:25, query: \"status:open updated_at:>''{{Time}}''\"){ pageInfo { hasNextPage } edges { cursor node { legacyResourceId name createdAt updatedAt channel { name } test fullyPaid unpaid displayFinancialStatus displayFulfillmentStatus subtotalLineItemsQuantity totalPriceSet { shopMoney { amount currencyCode } } customAttributes { key value } tags risk { assessments { riskLevel }} displayAddress { countryCode } shippingAddress { countryCode } billingAddress { countryCode } totalTaxSet { presentmentMoney { amount } shopMoney { amount } } purchasingEntity { ... on PurchasingCompany { company { id }}}}}}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(152);
    end;
}