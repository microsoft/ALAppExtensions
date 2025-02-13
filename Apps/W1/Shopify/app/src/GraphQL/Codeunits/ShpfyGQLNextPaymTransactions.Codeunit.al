namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL NextPaymTransactions (ID 30387) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30387 "Shpfy GQL NextPaymTransactions" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ shopifyPaymentsAccount { balanceTransactions(first: 100, query: \"id:>{{SinceId}}\", after: \"{{After}}\") { edges { node { id test associatedPayout { id } amount { amount currencyCode } fee { amount currencyCode } net { amount currencyCode } sourceId sourceOrderTransactionId transactionDate type associatedOrder { id } } cursor } pageInfo { hasNextPage } } } }"}');
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
