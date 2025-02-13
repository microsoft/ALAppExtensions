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
    begin
        case HttpRequestMessage.Method of
            'GET':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.Contains('webhooks.json') and Uri.Contains('?topic=') then
                        HttpResponseMessage := GetEmptyWebhookResponse();
                end;
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith('webhooks.json') then
                        HttpResponseMessage := GetCreateWebhookResponse();
                end;
            'DELETE':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.Contains('webhooks/') and Uri.EndsWith('.json') then
                        HttpResponseMessage := GetDeleteWebhookResponse();
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