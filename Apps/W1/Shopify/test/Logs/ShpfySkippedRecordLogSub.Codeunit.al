codeunit 139583 "Shpfy Skipped Record Log Sub."
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        ShopifyCustomerId: BigInteger;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Customer Events", OnBeforeFindMapping, '', true, false)]
    local procedure OnBeforeFindMapping(var Handled: Boolean; var ShopifyCustomer: Record "Shpfy Customer")
    begin
        ShopifyCustomer.Id := ShopifyCustomerId;
        Handled := true;
    end;

    local procedure MakeResponse(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        Uri: Text;
        GraphQlQuery: Text;
        GraphQLCmdMsg: Label '{"query":"{customers(first:100){pageInfo{endCursor hasNextPage} nodes{ legacyResourceId }}}"}', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            if GraphQlQuery.Contains(GraphQLCmdMsg) then
                                HttpResponseMessage := GetResult();
                end;
        end;
    end;

    local procedure GetResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{ "data": { "customers": { "pageInfo": { "hasNextPage": false }, "edges": [] } }, "extensions": { "cost": { "requestedQueryCost": 12, "actualQueryCost": 2, "throttleStatus": { "maximumAvailable": 2000, "currentlyAvailable": 1998, "restoreRate": 100 } } } }';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    internal procedure SetShopifyCustomerId(Id: BigInteger)
    begin
        ShopifyCustomerId := Id;
    end;

}
