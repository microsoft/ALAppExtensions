namespace Microsoft.Integration.Shopify;

codeunit 30168 "Shpfy GQL SalesChannels" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{publications(first: 10, catalogType: APP) { edges { node { id catalog { id ... on AppCatalog { apps(first: 1) { edges { node { id handle title } } } } } } } } }"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(22);
    end;
}
