/// <summary>
/// Codeunit Shpfy GQL FindVariantBySKU (ID 30131) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30131 "Shpfy GQL FindVariantBySKU" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{productVariants(query: \"sku:{{SKU}}\", first: 1) { edges { node { legacyResourceId product { legacyResourceId }}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(25);
    end;

}
