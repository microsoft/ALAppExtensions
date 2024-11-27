namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL MetafieldDefinitions (ID 30380) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30380 "Shpfy GQL MetafieldDefinitions" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ metafieldDefinitions(ownerType: {{OwnerType}}, first: 50) { edges { node { namespace name type { name } } } } }"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(16);
    end;

}
