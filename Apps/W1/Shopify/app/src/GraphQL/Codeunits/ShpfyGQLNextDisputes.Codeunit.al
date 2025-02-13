namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL NextDisputes (ID 30389) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30389 "Shpfy GQL NextDisputes" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ shopifyPaymentsAccount { disputes(first: 100, query: \"id:>{{SinceId}}\", after: \"{{After}}\") { edges { cursor node { amount { amount currencyCode } reasonDetails { networkReasonCode reason } order { id } evidenceDueBy evidenceSentOn finalizedOn id status type } } pageInfo { hasNextPage } } } }"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(30);
    end;
}
