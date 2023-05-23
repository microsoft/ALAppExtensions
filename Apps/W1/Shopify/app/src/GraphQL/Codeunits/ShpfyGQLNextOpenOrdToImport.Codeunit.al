codeunit 30206 "Shpfy GQL NextOpenOrdToImport" implements "Shpfy IGraphQL"
{
    Access = Internal;

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{orders(first:250, after:\"{{After}}\", query: \"status:open updated_at:>''{{Time}}''\"){pageInfo{hasNextPage} edges{cursor node{legacyResourceId name createdAt updatedAt test fullyPaid unpaid riskLevel displayFinancialStatus displayFulfillmentStatus subtotalLineItemsQuantity totalPriceSet{shopMoney{amount currencyCode}} customAttributes{key value} tags}}}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(752);
    end;
<<<<<<< HEAD
}
=======
}
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
