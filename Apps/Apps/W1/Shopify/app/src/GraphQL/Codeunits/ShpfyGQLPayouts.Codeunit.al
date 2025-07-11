namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL Payouts (ID 30391) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30391 "Shpfy GQL Payouts" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ shopifyPaymentsAccount { payouts(first: 100, query: \"id:>{{SinceId}}\") { edges { cursor node { id status summary { adjustmentsFee { amount } adjustmentsGross { amount } chargesFee { amount } chargesGross { amount } refundsFee { amount } refundsFeeGross { amount } reservedFundsFee { amount } reservedFundsGross { amount } retriedPayoutsFee { amount } retriedPayoutsGross { amount } } issuedAt net { amount currencyCode } } } pageInfo { hasNextPage } } } }"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(21);
    end;
}
