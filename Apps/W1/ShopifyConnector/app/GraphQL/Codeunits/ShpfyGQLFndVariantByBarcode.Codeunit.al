/// <summary>
/// Codeunit Shpfy GQL FndVariantByBarcode (ID 70007693) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30132 "Shpfy GQL FndVariantByBarcode" implements "Shpfy IGraphQL"
{

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{productVariants(query: \"barcode:{{Barcode}}\", first: 1) { edges { node { legacyResourceId product { legacyResourceId }}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(25);
    end;

}
