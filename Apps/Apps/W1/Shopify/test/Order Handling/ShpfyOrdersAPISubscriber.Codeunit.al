codeunit 139649 "Shpfy Orders API Subscriber"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;

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
        GraphQLCmdMsg: Label '{ transactions { authorizationCode createdAt errorCode formattedGateway gateway', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            if GraphQlQuery.Contains(GraphQLCmdMsg) then
                                HttpResponseMessage := GetOrderTransactionResult();
                end;
        end;
    end;

    local procedure GetOrderTransactionResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Order Handling/OrderTransactionResult.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;
}
