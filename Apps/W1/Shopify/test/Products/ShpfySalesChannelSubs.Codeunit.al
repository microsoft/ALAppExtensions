codeunit 139614 "Shpfy Sales Channel Subs."
{
    EventSubscriberInstance = Manual;

    var
        GraphQueryTxt: Text;

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

    local procedure MakeResponse(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        Uri: Text;
        GraphQlQuery: Text;
        PublishProductTok: Label '{"query":"mutation {publishablePublish(id: \"gid://shopify/Product/', locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            if GraphQlQuery.Contains(PublishProductTok) then begin
                                HttpResponseMessage := GetEmptyPublishResponse();
                                GraphQueryTxt := GraphQlQuery;
                            end;
                end;
        end;
    end;

    local procedure GetEmptyPublishResponse(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
    begin
        BodyTxt := '{ "data": { "publishablePublish": { "userErrors": [] } }, "extensions": { "cost": { "requestedQueryCost": 10, "actualQueryCost": 10, "throttleStatus": { "maximumAvailable": 2000, "currentlyAvailable": 1990, "restoreRate": 100 } } } }';
        HttpResponseMessage.Content.WriteFrom(BodyTxt);
        exit(HttpResponseMessage);
    end;

    procedure GetGraphQueryTxt(): Text
    begin
        exit(GraphQueryTxt);
    end;

}
