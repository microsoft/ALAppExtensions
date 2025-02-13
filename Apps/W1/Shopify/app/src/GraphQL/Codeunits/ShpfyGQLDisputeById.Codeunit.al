namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL DisputeById (ID 30390) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30390 "Shpfy GQL DisputeById" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ shopifyPaymentsAccount { disputes(first: 1, query: \"id:{{Id}}\") { nodes { amount { amount currencyCode } reasonDetails { networkReasonCode reason } order { id } evidenceDueBy evidenceSentOn finalizedOn id status type } } } }"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(6);
    end;
}
