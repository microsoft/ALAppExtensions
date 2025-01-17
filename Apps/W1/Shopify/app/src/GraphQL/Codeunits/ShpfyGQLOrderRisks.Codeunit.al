namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL OrderRisks (ID 30144) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30144 "Shpfy GQL OrderRisks" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{order(id: \"gid://shopify/Order/{{OrderId}}\") {risk { assessments { facts { description sentiment } provider { title } riskLevel }}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(5);
    end;

}
