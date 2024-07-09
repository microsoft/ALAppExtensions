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
        GraphQLCmdMsg: Label '{ transactions { authorizationCode createdAt errorCode formattedGateway gateway id kind paymentId receiptJson status test amountSet { presentmentMoney { amount currencyCode } shopMoney { amount currencyCode }} paymentDetails { ... on CardPaymentDetails { avsResultCode bin cvvResultCode number company }}}', Locked = true;
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
    begin
        Body := '{"data":{"order":{"transactions":[{"authorizationCode":"53433","createdAt":"2024-06-11T09:58:22Z","errorCode":null,"formattedGateway":"(For Testing) Bogus Gateway","gateway":"bogus","id":"gid://shopify/OrderTransaction/6657081606262","kind":"SALE","paymentId":"rhVoj2pg5L3vVrybtYswqKnju","receiptJson":"{}","status":"SUCCESS","test":true,"amountSet":{"presentmentMoney":{"amount":"679.0","currencyCode":"DKK"},"shopMoney":{"amount":"679.0","currencyCode":"DKK"}},"paymentDetails":{"avsResultCode":null,"bin":"1","cvvResultCode":null,"number":"•••• •••• •••• 1","company":"Bogus"}}]}},"extensions":{"cost":{"requestedQueryCost":3,"actualQueryCost":3,"throttleStatus":{"maximumAvailable":2000.0,"currentlyAvailable":1997,"restoreRate":100.0}}}}';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;
}
