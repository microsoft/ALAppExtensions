namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL GetWebhookSubs (ID 30394) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30394 "Shpfy GQL GetWebhookSubs" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ webhookSubscriptions( first: 10, topics:{{WebhookTopic}}, callbackUrl: \"{{NotificationUrl}}\" ) { edges { node { id } } } }"}');
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