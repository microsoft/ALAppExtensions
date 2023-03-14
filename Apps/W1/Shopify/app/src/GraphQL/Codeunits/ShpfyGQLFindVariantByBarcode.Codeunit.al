/// <summary>
/// Codeunit Shpfy GQL FindVariantByBarcode (ID 30132) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30132 "Shpfy GQL FindVariantByBarcode" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{productVariants(query: \"barcode:{{Barcode}}\", first: 1) { edges { node { legacyResourceId product { legacyResourceId }}}}}"}');
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
