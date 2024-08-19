namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL GetProductOptions (ID 30345) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30345 "Shpfy GQL GetProductOptions" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{product(id: \"gid://shopify/Product/{{ProductId}}\") {id title options {id name}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(2);
    end;
}
