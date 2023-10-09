namespace Microsoft.Integration.Shopify;

using System.Integration;

codeunit 30251 "Shpfy Webhooks API"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        WebhooksUrlTxt: Label 'webhooks.json', Locked = true;
        WebhookUrlTxt: Label 'webhooks/%1.json', Comment = '%1 - webhook id', Locked = true;
        WebhookCreateRequestTxt: Label '{"webhook": {"topic": "%1", "address": "%2", "format": "json" }}', Comment = '%1 - webhook topic, %2 - notification address', Locked = true;


    internal procedure RegisterWebhookSubscription(var Shop: Record "Shpfy Shop"; WebhookTopic: Text): Text
    var
        JResponse: JsonToken;
        SubscriptionId: Text;
        Response: Text;
        Request: Text;
        Url: Text;
    begin
        CommunicationMgt.SetShop(Shop);
        Url := CommunicationMgt.CreateWebRequestURL(WebhooksUrlTxt);
        Request := StrSubstNo(WebhookCreateRequestTxt, WebhookTopic, GetNotificationUrl());
        Response := CommunicationMgt.ExecuteWebRequest(Url, 'POST', Request);
        JResponse.ReadFrom(Response);
        ExtractWebhookSubscriptionId(JResponse.AsObject(), SubscriptionId);
        exit(SubscriptionId);
    end;

    internal procedure GetWebhookSubscription(var Shop: Record "Shpfy Shop"; WebhookTopic: Text; var SubscriptionId: Text): Boolean
    var
        JResponse: JsonToken;
        JWebhooks: JsonArray;
        JWebhook: JsonToken;
        Response: Text;
        Url: Text;
    begin
        CommunicationMgt.SetShop(Shop);
        Url := CommunicationMgt.CreateWebRequestURL(WebhooksUrlTxt + '?topic=' + WebhookTopic + '&address=' + GetNotificationUrl());
        Response := CommunicationMgt.ExecuteWebRequest(Url, 'GET', '');
        if JResponse.ReadFrom(Response) then
            if JsonHelper.GetJsonArray(JResponse, JWebhooks, 'webhooks') then
                foreach JWebhook in JWebhooks do begin
                    SubscriptionId := JsonHelper.GetValueAsText(JWebhook.AsObject(), 'id');
                    if SubscriptionId <> '' then
                        exit(true);
                end;

        exit(false);
    end;

    internal procedure DeleteWebhookSubscription(var Shop: Record "Shpfy Shop"; SubscriptionId: Text)
    var
        Response: Text;
        Url: Text;
    begin
        CommunicationMgt.SetShop(Shop);
        Url := CommunicationMgt.CreateWebRequestURL(StrSubstNo(WebhookUrlTxt, SubscriptionId));
        Response := CommunicationMgt.ExecuteWebRequest(Url, 'DELETE', '');
    end;

    local procedure ExtractWebhookSubscriptionId(JResponse: JsonObject; var SubscriptionId: Text)
    var
        JWebhookSubscription: JsonObject;
    begin
        if JsonHelper.GetJsonObject(JResponse, JWebhookSubscription, 'webhook') then
            SubscriptionId := JsonHelper.GetValueAsText(JWebhookSubscription, 'id');
    end;

    local procedure GetNotificationUrl(): Text
    var
        WebhookManagement: Codeunit "Webhook Management";
    begin
        exit(WebhookManagement.GetNotificationUrl());
    end;
}