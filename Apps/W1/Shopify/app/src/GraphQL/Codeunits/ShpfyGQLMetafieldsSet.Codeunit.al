namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL MetafieldSet (ID 30168) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30350 "Shpfy GQL MetafieldsSet" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { metafieldsSet(metafields: [{{Metafields}}]) { metafields {legacyResourceId namespace key} userErrors {field, message}}}"}');
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