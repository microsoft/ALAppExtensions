namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL CreateWebhookSub (ID 30393) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30393 "Shpfy GQL CreateWebhookSub" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"mutation { webhookSubscriptionCreate( topic: {{WebhookTopic}} webhookSubscription: {callbackUrl: \"{{NotificationUrl}}\", format: JSON} ) { userErrors { field message } webhookSubscription { id } } }"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(10);
    end;
}