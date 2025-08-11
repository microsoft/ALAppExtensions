// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL Disputes (ID 30388) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30388 "Shpfy GQL Disputes" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ shopifyPaymentsAccount { disputes(first: 100, query: \"id:>{{SinceId}}\") { edges { cursor node { amount { amount currencyCode } reasonDetails { networkReasonCode reason } order { id } evidenceDueBy evidenceSentOn finalizedOn id status type } } pageInfo { hasNextPage } } } }"}');
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
