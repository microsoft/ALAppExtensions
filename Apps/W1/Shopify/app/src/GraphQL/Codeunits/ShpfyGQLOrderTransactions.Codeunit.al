namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL OrderTransactions (ID 30312) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30312 "Shpfy GQL OrderTransactions" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ order(id: \"gid://shopify/Order/{{OrderId}}\") { transactions { authorizationCode createdAt errorCode formattedGateway gateway id kind paymentId receiptJson status test amountSet { presentmentMoney { amount currencyCode } shopMoney { amount currencyCode }} paymentDetails { ... on CardPaymentDetails { avsResultCode bin cvvResultCode number company }}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(3);
    end;
}
