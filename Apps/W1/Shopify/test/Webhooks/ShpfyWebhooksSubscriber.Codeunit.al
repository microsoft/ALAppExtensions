// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;

codeunit 139613 "Shpfy Webhooks Subscriber"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        JEmptyWebhook: JsonObject;
        JCreateWebhook: JsonObject;
        JDeleteWebhook: JsonObject;

    internal procedure InitCreateWebhookResponse(CreateWebhook: JsonObject; DeleteWebhook: JsonObject; EmptyWebhook: JsonObject)
    begin
        JEmptyWebhook := EmptyWebhook;
        JCreateWebhook := CreateWebhook;
        JDeleteWebhook := DeleteWebhook;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Webhooks Mgt.", 'OnScheduleWebhookNotificationTask', '', true, false)]
    local procedure OnScheduleWebhookNotificationTask(var IsTestInProgress: Boolean)
    begin
        IsTestInProgress := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientSend', '', true, false)]
    local procedure OnClientSend(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        MakeResponse(HttpRequestMessage, HttpResponseMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnGetContent', '', true, false)]
    local procedure OnGetContent(HttpResponseMessage: HttpResponseMessage; var Response: Text)
    begin
        HttpResponseMessage.Content.ReadAs(Response);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Background Syncs", 'OnCanCreateTask', '', true, false)]
    local procedure OnCanCreateTask(var CanCreateTask: Boolean)
    begin
        CanCreateTask := true;
    end;

    local procedure MakeResponse(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        Uri: Text;
        GraphQLQuery: Text;
        GetWebhooksGQLTxt: Label '{"query":"{ webhookSubscriptions(', Locked = true;
        CreateWebhookGQLTxt: Label '{"query":"mutation { webhookSubscriptionCreate', Locked = true;
        DeleteWebhookGQLTxt: Label '{"query":"mutation { webhookSubscriptionDelete', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQLQuery) then begin
                            if GraphQLQuery.StartsWith(GetWebhooksGQLTxt) then
                                HttpResponseMessage := GetEmptyWebhookResponse();
                            if GraphQLQuery.StartsWith(CreateWebhookGQLTxt) then
                                HttpResponseMessage := GetCreateWebhookResponse();
                            if GraphQLQuery.StartsWith(DeleteWebhookGQLTxt) then
                                HttpResponseMessage := GetDeleteWebhookResponse();
                        end;
                end;
        end;
    end;

    local procedure GetEmptyWebhookResponse(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
    begin
        HttpResponseMessage.Content.WriteFrom(Format(JEmptyWebhook));
        exit(HttpResponseMessage);
    end;

    local procedure GetCreateWebhookResponse(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
    begin
        HttpResponseMessage.Content.WriteFrom(Format(JCreateWebhook));
        exit(HttpResponseMessage);
    end;


    local procedure GetDeleteWebhookResponse(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
    begin
        HttpResponseMessage.Content.WriteFrom(Format(JDeleteWebhook));
        exit(HttpResponseMessage);
    end;
}