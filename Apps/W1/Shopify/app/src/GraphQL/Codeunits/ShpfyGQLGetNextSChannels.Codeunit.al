namespace Microsoft.Integration.Shopify;
/// <summary>
/// Codeunit Shpfy GQL Get Next S. Channels (ID 30375) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30375 "Shpfy GQL Get Next S. Channels" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin

    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(32);
    end;
}
