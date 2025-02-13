namespace Microsoft.Integration.Shopify;

using System.Integration;

codeunit 30251 "Shpfy Webhooks API"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    internal procedure RegisterWebhookSubscription(var Shop: Record "Shpfy Shop"; WebhookTopic: Text): Text
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        JResponse: JsonToken;
        SubscriptionId: Text;
        Parameters: Dictionary of [Text, Text];
    begin
        CommunicationMgt.SetShop(Shop);
        GraphQLType := GraphQLType::CreateWebhookSubscription;
        Parameters.Add('WebhookTopic', WebhookTopic);
        Parameters.Add('NotificationUrl', GetNotificationUrl());
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        ExtractWebhookSubscriptionId(JResponse.AsObject(), SubscriptionId);
        exit(SubscriptionId);
    end;

    internal procedure GetWebhookSubscription(var Shop: Record "Shpfy Shop"; WebhookTopic: Text; var SubscriptionId: Text): Boolean
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Id: BigInteger;
        JResponse: JsonToken;
        JWebhooks: JsonArray;
        JWebhook: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        CommunicationMgt.SetShop(Shop);
        GraphQLType := GraphQLType::GetWebhookSubscriptions;
        Parameters.Add('WebhookTopic', WebhookTopic);
        Parameters.Add('NotificationUrl', GetNotificationUrl());
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        if JsonHelper.GetJsonArray(JResponse, JWebhooks, 'data.webhookSubscriptions.edges') then
            foreach JWebhook in JWebhooks do begin
                Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JWebhook, 'node.id'));
                if Id <> 0 then begin
                    SubscriptionId := Format(Id);
                    exit(true);
                end;
            end;

        exit(false);
    end;

    internal procedure DeleteWebhookSubscription(var Shop: Record "Shpfy Shop"; SubscriptionId: Text)
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
    begin
        CommunicationMgt.SetShop(Shop);
        GraphQLType := GraphQLType::DeleteWebhookSubscription;
        Parameters.Add('SubscriptionId', SubscriptionId);
        CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
    end;

    local procedure ExtractWebhookSubscriptionId(JResponse: JsonObject; var SubscriptionId: Text)
    var
        Id: BigInteger;
    begin
        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JResponse, 'data.webhookSubscriptionCreate.webhookSubscription.id'));
        if Id <> 0 then
            SubscriptionId := Format(Id);
    end;

    local procedure GetNotificationUrl(): Text
    var
        WebhookManagement: Codeunit "Webhook Management";
    begin
        exit(WebhookManagement.GetNotificationUrl());
    end;
}