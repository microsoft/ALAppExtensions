namespace Microsoft.Integration.Shopify;

codeunit 30223 "Shpfy GQL NextOrderReturns" implements "Shpfy IGraphQL"
{

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ order(id: id: \"gid://shopify/Order/{{OrderId}}\") { returns(first: 20,  after:\"{{After}}\") { pageInfo { endCursor hasNextPage } nodes { id }}}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(73);
    end;
}