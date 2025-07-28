// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL NextPayouts (ID 30392) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30392 "Shpfy GQL NextPayouts" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ shopifyPaymentsAccount { payouts(first: 100, query: \"id:>{{SinceId}}\", after: \"{{After}}\") { edges { cursor node { id status summary { adjustmentsFee { amount } adjustmentsGross { amount } chargesFee { amount } chargesGross { amount } refundsFee { amount } refundsFeeGross { amount } reservedFundsFee { amount } reservedFundsGross { amount } retriedPayoutsFee { amount } retriedPayoutsGross { amount currencyCode } } issuedAt net { amount currencyCode } } } pageInfo { hasNextPage } } } }"}');
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
