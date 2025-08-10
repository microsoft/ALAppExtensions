// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL PaymentTransactions (ID 30386) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30386 "Shpfy GQL PaymentTransactions" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ shopifyPaymentsAccount { balanceTransactions(first: 100, query: \"id:>{{SinceId}}\") { edges { node { id test associatedPayout { id } amount { amount currencyCode } fee { amount currencyCode } net { amount currencyCode } sourceId sourceOrderTransactionId transactionDate type associatedOrder { id } } cursor } pageInfo { hasNextPage } } } }"}');
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
