codeunit 139583 "Shpfy Skipped Record Log Sub."
{
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
        GetCustomersGQLMsg: Label '{"query":"{customers(first:100){pageInfo{endCursor hasNextPage} nodes{ legacyResourceId }}}"}', Locked = true;
        GetProductMetafieldsGQLStartMsg: Label '{"query":"{product(id: \"gid://shopify/Product/', Locked = true;
        GetProductMetafieldsGQLEndMsg: Label '\") { metafields(first: 50) {edges{node{legacyResourceId updatedAt}}}}}"}', Locked = true;
        GetVariantMetafieldsGQLStartMsg: Label '{"query":"{productVariant(id: \"gid://shopify/ProductVariant/', Locked = true;
        GetVariantMetafieldGQLEndMsg: Label '\") { metafields(first: 50) {edges{ node{legacyResourceId updatedAt}}}}}"}', Locked = true;
        CreateFulfimentGQLStartMsg: Label '{"query": "mutation {fulfillmentCreateV2( fulfillment: {notifyCustomer: true, trackingInfo: {number: ', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            case true of
                                GraphQlQuery.Contains(GetCustomersGQLMsg):
                                    HttpResponseMessage := GetCustomersResult();
                                GraphQlQuery.StartsWith(GetProductMetafieldsGQLStartMsg) and GraphQlQuery.EndsWith(GetProductMetafieldsGQLEndMsg):
                                    HttpResponseMessage := GetProductMetafieldsEmptyResult();
                                GraphQlQuery.StartsWith(GetVariantMetafieldsGQLStartMsg) and GraphQlQuery.EndsWith(GetVariantMetafieldGQLEndMsg):
                                    HttpResponseMessage := GetVariantMetafieldsEmptyResult();
                                GraphQlQuery.StartsWith(CreateFulfimentGQLStartMsg):
                                    HttpResponseMessage := GetCreateFulfilmentFailedResult();
                            end;
                end;
        end;
    end;

    local procedure GetCustomersResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{ "data": { "customers": { "pageInfo": { "hasNextPage": false }, "edges": [] } }, "extensions": { "cost": { "requestedQueryCost": 12, "actualQueryCost": 2, "throttleStatus": { "maximumAvailable": 2000, "currentlyAvailable": 1998, "restoreRate": 100 } } } }';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetProductMetafieldsEmptyResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{ "data": { "customers": { "pageInfo": { "hasNextPage": false }, "edges": [] } }, "extensions": { "cost": { "requestedQueryCost": 12, "actualQueryCost": 2, "throttleStatus": { "maximumAvailable": 2000, "currentlyAvailable": 1998, "restoreRate": 100 } } } }';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetVariantMetafieldsEmptyResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{ "data": { "productVariant": { "metafields": { "edges": [] } } }, "extensions": { "cost": { "requestedQueryCost": 10, "actualQueryCost": 3, "throttleStatus": { "maximumAvailable": 2000, "currentlyAvailable": 1997, "restoreRate": 100 } } } }';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetCreateFulfilmentFailedResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{ "data": { "fulfillmentCreateV2": { "fulfillment": null, "userErrors": [ { "field": [ "fulfillment" ], "message": "Fulfillment order does not exist." } ] } }, "extensions": { "cost": { "requestedQueryCost": 24, "actualQueryCost": 10, "throttleStatus": { "maximumAvailable": 2000, "currentlyAvailable": 1990, "restoreRate": 100 } } } }';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    internal procedure SetShopifyCustomerId(Id: BigInteger)
    begin
        ShopifyCustomerId := Id;
    end;

}
